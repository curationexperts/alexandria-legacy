module Importer
  class ModsImporter
    def self.import

      file = File.join(Rails.root, 'spec/fixtures/mods/cusbspcmss36_110008.xml')
      mods = Mods::Record.new.from_file(file)
      image = Image.create(id: mods.identifier.text,
                   location: mods.subject.geographic.valueURI.map { |uri| RDF::URI.new(uri) },
                   lcsubject: mods.subject.topic.valueURI.map { |uri| RDF::URI.new(uri) },
                   publisher: [mods.origin_info.publisher.text],
                   title: [mods.title_info.title.text],
                   workType: mods.genre.valueURI.map { |uri| RDF::URI.new(uri) })
    end
  end
end
