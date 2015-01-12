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
      if Image.exists?(attributes[:id])
        i = Image.find(attributes[:id])
        i.update(attributes.except(:id, :files))
        puts "  Updated. #{attributes[:id]}"
      else
        image = create_image(attributes)
        puts "  Created #{image.id}" if image
      end
    rescue Oargun::RDF::Controlled::ControlledVocabularyError => e
      puts "  Skipping, due to #{e.message}"
    end

    def create_image(attributes)
      Image.create(attributes.except(:files)).tap do |image|
        attributes[:files].each do |file_path|
          create_file(image, file_path)
        end
      end
    end

    def create_file(image, file_name)
      path = image_path(file_name)
      unless File.exists?(path)
        puts "  * File doesn't exist at #{path}"
        return
      end
      image.generic_files.create do |gf|
        puts "  Reading image #{file_name}"
        gf.original.content = File.new(path)
        gf.save!
      end
    end

    def image_path(file_name)
      File.join(image_dir, file_name)
    end

    def image_dir
      @image_directory
    end
  end
end
