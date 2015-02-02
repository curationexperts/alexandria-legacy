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
        title: mods.title_info.title.text,
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
      # Integers trigger https://github.com/ruby-rdf/rdf/issues/167
      # [mods.origin_info.dateCreated.css('[point="start"]'.freeze).text.to_i]
      # So just doing a string for now:
      [mods.origin_info.dateCreated.css('[point="start"]'.freeze).text]
    end

    def latest_date
      # Integers trigger https://github.com/ruby-rdf/rdf/issues/167
      # [mods.origin_info.dateCreated.css('[point="end"]'.freeze).text.to_i]
      # So just doing a string for now:
      [mods.origin_info.dateCreated.css('[point="end"]'.freeze).text]
    end

    def issued
      # Integers trigger https://github.com/ruby-rdf/rdf/issues/167
      # [mods.origin_info.dateIssued.text.to_i]
      # So just doing a string for now:
      [mods.origin_info.dateIssued.text]
    end

    def collection
      dc_id = Array(mods.related_item.at_xpath('mods:identifier[@type="local"]'.freeze).text)
      id = dc_id.first.downcase.gsub(/\s*/, '')

      { id: id,
        identifier: dc_id,
        title: mods.at_xpath("//prefix:relatedItem[@type='host']".freeze, {'prefix'.freeze => Mods::MODS_NS}).titleInfo.title.text.strip
      }
    end

  end
end
