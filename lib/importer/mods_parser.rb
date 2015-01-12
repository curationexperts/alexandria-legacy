module Importer
  class ModsParser
    attr_reader :mods

    CREATOR = "http://id.loc.gov/vocabulary/relators/cre".freeze

    def initialize(file)
      @mods = Mods::Record.new.from_file(file)
    end

    def attributes
      {
        id: mods.identifier.text,
        location: mods.subject.geographic.valueURI.map { |uri| RDF::URI.new(uri) },
        lcsubject: mods.subject.topic.valueURI.map { |uri| RDF::URI.new(uri) },
        creator:   creator.map { |uri| RDF::URI.new(uri) },
        publisher: [mods.origin_info.publisher.text],
        title: [mods.title_info.title.text],
        earliestDate: earliest_date,
        latestDate: latest_date,
        issued: issued,
        workType: mods.genre.valueURI.map { |uri| RDF::URI.new(uri) },
        files: mods.extension.xpath('./fileName').map(&:text),
        collection: collection
      }
    end

    def creator
      if mods.corporate_name.role.roleTerm.valueURI == [CREATOR]
        mods.corporate_name.valueURI
      elsif mods.personal_name.role.roleTerm.valueURI == [CREATOR]
        mods.personal_name.valueURI
      else
        []
      end
    end

    def earliest_date
      [mods.origin_info.dateCreated.css('[point="start"]'.freeze).text.to_i]
    end

    def latest_date
      [mods.origin_info.dateCreated.css('[point="end"]').freeze.text.to_i]
    end

    def issued
      [mods.origin_info.dateIssued.text.to_i]
    end

    def collection
      dc_id = mods.related_item.at_xpath('mods:identifier[@type="local"]').text
      id = dc_id.downcase.gsub(/\s*/, '')

      { id: id,
        title: mods.at_xpath("//prefix:relatedItem[@type='host']", {'prefix' => Mods::MODS_NS}).titleInfo.title.text.strip
      }
    end

  end
end
