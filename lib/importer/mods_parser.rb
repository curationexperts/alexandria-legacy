module Importer
  class ModsParser
    attr_reader :mods
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
        workType: mods.genre.valueURI.map { |uri| RDF::URI.new(uri) },
        files: mods.extension.xpath('./fileName').map(&:text)
      }
    end

    def creator
      if mods.corporate_name.role.roleTerm.valueURI == ["http://id.loc.gov/vocabulary/relators/cre"]
        mods.corporate_name.valueURI
      elsif mods.personal_name.role.roleTerm.valueURI == ["http://id.loc.gov/vocabulary/relators/cre"]
        mods.personal_name.valueURI
      else
        []
      end
    end
  end
end
