module Importer
  class ModsImporter

    def initialize(image_directory, metadata_directory=nil)
      @image_directory = image_directory
      @metadata_directory = metadata_directory
    end

    def import_all
      count = 0
      Dir.glob("#{@metadata_directory}/**/*").each do |filename|
        next if File.directory?(filename)
        import(filename)
        count += 1
      end
      count
    end

    def import(file)
      puts "Importing: #{file}"
      parser = ModsParser.new(file)
      attributes = parser.attributes
      ImageFactory.new(attributes, @image_directory).run
    rescue Oargun::RDF::Controlled::ControlledVocabularyError => e
      puts "  Skipping, due to #{e.message}"
    end

  end
end
