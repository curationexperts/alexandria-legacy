module Importer
  class ModsParser
    attr_reader :mods, :model

    CREATOR = "http://id.loc.gov/vocabulary/relators/cre".freeze
    COLLECTOR = "http://id.loc.gov/vocabulary/relators/col".freeze

    NAMESPACES = { 'mods'.freeze => Mods::MODS_NS }

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
        files: mods.extension.xpath('./fileName').map(&:text),
        collection: collection,
        series_name: mods.xpath("//mods:relatedItem[@type='series']").titleInfo.title.map(&:text)
      })
    end

    def collection_attributes
      common_attributes
    end

    def common_attributes
      human_readable_id = mods.identifier.map(&:text)
      {
        id: persistent_id(human_readable_id.first),
        accession_number: human_readable_id,
        title: untyped_title,
        alternative: mods.title_info.alternative_title.to_a,
        description: description,
        lc_subject: mods.subject.topic.valueURI.map { |uri| RDF::URI.new(uri) },
        creator:   creator,
        collector: creator(COLLECTOR),
        extent: mods.physical_description.extent.map{|node| strip_whitespace(node.text)},
        earliestDate: earliest_date,
        latestDate: latest_date,
        issued: issued,
        date_other: mods.origin_info.dateOther.map(&:text),
        language: mods.language.languageTerm.valueURI.map { |uri| RDF::URI.new(uri) },
        digital_origin: mods.physical_description.digitalOrigin.map(&:text),
        publisher: mods.origin_info.publisher.map(&:text),
        location: mods.subject.geographic.valueURI.map { |uri| RDF::URI.new(uri) },
        sub_location: mods.location.holdingSimple.xpath('./mods:copyInformation/mods:subLocation').map(&:text),
        form_of_work: mods.genre.valueURI.map { |uri| RDF::URI.new(uri) },
        work_type: mods.typeOfResource.map(&:text),
        citation: citation,
        note: note,
        record_origin: mods.record_info.recordOrigin.map{|node| strip_whitespace(node.text) },
        description_standard: mods.record_info.descriptionStandard.map(&:text)
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

    def persistent_id(raw_id)
      raw_id.downcase.gsub(/\s*/, '')
    end

    def collection
      human_readable_id = Array(mods.related_item.at_xpath('mods:identifier[@type="local"]'.freeze).text)

      { id: persistent_id(human_readable_id.first),
        accession_number: human_readable_id,
        title: mods.at_xpath("//mods:relatedItem[@type='host']".freeze, NAMESPACES).titleInfo.title.text.strip
      }
    end

    # Remove multiple whitespace
    def citation
      mods.xpath('//mods:note[@type="preferred citation"]'.freeze, NAMESPACES).map do |node|
        node.text.gsub(/\n\s+/, "\n")
      end
    end

    def note
      mods.xpath('//mods:note[@type!="preferred citation"]'.freeze, NAMESPACES).map do |node|
        node.text.gsub(/\n\s+/, "\n")
      end

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

  end
end
