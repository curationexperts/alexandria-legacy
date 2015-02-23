module Importer
  class ModsParser
    attr_reader :mods, :model

    CREATOR = "http://id.loc.gov/vocabulary/relators/cre".freeze
    COLLECTOR = "http://id.loc.gov/vocabulary/relators/col".freeze

    def initialize(file)
      @mods = Mods::Record.new.from_file(file)
      @model = if collection?
                 Collection
               elsif image?
                 Image
               end
    end

    def collection?
      type_keys = mods.typeOfResource.attributes.map(&:keys).flatten
      return false unless type_keys.include?('collection')
      mods.typeOfResource.attributes.any?{|hash| hash.fetch('collection').value == 'yes'}
    end

    # For now the only things we import are collections and
    # images, so if it's not a collection, assume it's an image.
    # TODO:  Identify images or other record types based on
    #        the data in <mods:typeOfResource>.
    def image?
      !collection?
    end

    def attributes
      if model == Collection
        collection_attributes
      else
        record_attributes
      end
    end

    def record_attributes
      common_attributes.merge!({
        id: mods.identifier.text,
        files: mods.extension.xpath('./fileName').map(&:text),
        collection: collection
      })
    end

    def collection_attributes
      dc_id = mods.identifier.map(&:text)
      common_attributes.merge!({
        id: collection_id(dc_id.first),
        identifier: dc_id
      })
    end

    def common_attributes
      {
        title: untyped_title,
        alternative: mods.title_info.alternative_title.to_a,
        description: description,
        lc_subject: mods.subject.topic.valueURI.map { |uri| RDF::URI.new(uri) },
        creator:   creator,
        collector: creator(COLLECTOR),
        physical_extent: mods.physical_description.extent.map{|node| strip_whitespace(node.text)},
        earliestDate: earliest_date,
        latestDate: latest_date,
        issued: issued,
        language: mods.language.languageTerm.valueURI.map { |uri| RDF::URI.new(uri) },
        digital_origin: mods.physical_description.digitalOrigin.map(&:text),
        publisher: [mods.origin_info.publisher.text],
        location: mods.subject.geographic.valueURI.map { |uri| RDF::URI.new(uri) },
        form_of_work: mods.genre.valueURI.map { |uri| RDF::URI.new(uri) },
        work_type: mods.typeOfResource.map(&:text),
        rights: rights
      }.merge(coordinates)
    end

    # returns a hash with :latitude and :longitude
    def coordinates
      coords =  mods.subject.cartographics.coordinates.map(&:text)
      # a hash where any value defaults to an empty array
      result = Hash.new { |h, k| h[k] = [] }
      coords.each_with_object(result) do |coord, result|
        (latitude, longitude) = coord.split(/,\s*/)
        result[:latitude] << latitude
        result[:longitude] << longitude
      end
    end

    def description
      mods.abstract.map{|e| strip_whitespace(e.text) }
    end

    def strip_whitespace(text)
      text.gsub("\n", " ").gsub("\t", "")
    end

    def creator(role=CREATOR)
      uris = []
      names = []

      if mods.corporate_name.role.roleTerm.valueURI == [role]
        uris += mods.corporate_name.valueURI
        names += mods.corporate_name.map{|names| names.namePart.text }
      end

      if mods.personal_name.role.roleTerm.valueURI == [role]
        uris += mods.personal_name.valueURI
        names += mods.personal_name.map{|names| names.namePart.text }
      end

      if !uris.blank?
        uris.map { |uri| RDF::URI.new(uri) }
      else
        names
      end
    end

    def earliest_date
      # Use a string because it may be any ISO8601 format:
      [created_start, issued_start].reject(&:empty?)
    end

    def latest_date
      # Use a string because it may be any ISO8601 format:
      [created_end, issued_end].reject(&:empty?)
    end

    def issued
      # Use a string because it may be any ISO8601 format:
      mods.origin_info.dateIssued.map(&:text)
    end

    def collection_id(raw_id)
      raw_id.downcase.gsub(/\s*/, '')
    end

    def collection
      dc_id = Array(mods.related_item.at_xpath('mods:identifier[@type="local"]'.freeze).text)

      { id: collection_id(dc_id.first),
        identifier: dc_id,
        title: mods.at_xpath("//prefix:relatedItem[@type='host']".freeze, {'prefix'.freeze => Mods::MODS_NS}).titleInfo.title.text.strip
      }
    end

    private
      def created_end
        created_range_limit('end'.freeze)
      end

      def created_start
        created_range_limit('start'.freeze)
      end

      def created_range_limit(point)
        mods.origin_info.dateCreated.css("[point=\"#{point}\"]").text
      end

      def issued_end
        issued_range_limit('end'.freeze)
      end

      def issued_start
        issued_range_limit('start'.freeze)
      end
      def issued_range_limit(point)
        mods.origin_info.dateIssued.css("[point=\"#{point}\"]").text
      end

      def untyped_title
        mods.xpath('/m:mods/m:titleInfo[not(@type)]/m:title/text()', 'm' => Mods::MODS_NS).to_s
      end

      def rights
        raw_data = mods.extension.xpath('./copyrightStatus').map(&:text).map(&:downcase)

        raw_data.map do |rights_string|
          uri = case rights_string
            when 'unknown'
              Oargun::Vocabularies::EURIGHTS[:"unknown/"]
            when 'public domain'
              Oargun::Vocabularies::CCPUBLIC[:"mark/1.0/"]
            when 'copyrighted'
              Oargun::Vocabularies::EURIGHTS[:"rr-f/"]
            else
              raise Oargun::RDF::Controlled::ControlledVocabularyError.new("The 'copyrightStatus' contained data that isn't in the controlled vocabulary: #{rights_string}")
            end

          RDF::URI.new(uri)
        end
      end

  end
end
