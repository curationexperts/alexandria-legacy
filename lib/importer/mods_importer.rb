module Importer
  class ModsImporter

    def initialize(files_directory, metadata_directory=nil)
      @files_directory = files_directory
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

      # Create the object(s) in fedora
      object_factory = factory(parser.model)
      object_factory.new(attributes, @files_directory).run
    rescue Oargun::RDF::Controlled::ControlledVocabularyError => e
      puts "  Skipping, due to #{e.message}"
    end

    def factory(model_class)
      (model_class.to_s + "Factory").constantize
    end

  end
end
