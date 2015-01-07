module Importer
  class ModsImporter

    def initialize(dirname=nil)
      @dirname = dirname
    end

    def import_all
      count = 0
      Dir.glob("#{@dirname}/**/*").each do |filename|
        next if File.directory?(filename)
        import_file(filename)
        count += 1
      end
      count
    end

    def self.import
      file = File.join(Rails.root, 'spec/fixtures/mods/cusbspcmss36_110008.xml')
      importer = ModsImporter.new.import_file(file)
    end

    def import_file(file)
      puts "Importing: #{file}"
      mods = Mods::Record.new.from_file(file)
      if Image.exists?(mods.identifier.text)
        puts "  Skipping. #{mods.identifier.text} already exists"
        return
      end
      image = Image.create(id: mods.identifier.text,
                   location: mods.subject.geographic.valueURI.map { |uri| RDF::URI.new(uri) },
                   lcsubject: mods.subject.topic.valueURI.map { |uri| RDF::URI.new(uri) },
                   publisher: [mods.origin_info.publisher.text],
                   title: [mods.title_info.title.text],
                   workType: mods.genre.valueURI.map { |uri| RDF::URI.new(uri) })
      puts "  Created #{image.id}"
    end
  end
end
