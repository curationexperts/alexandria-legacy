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
        image = Image.find(attributes[:id])
        image.update(attributes.except(:id, :files, :collection))
        puts "  Updated. #{attributes[:id]}"
      else
        image = create_image(attributes)
        puts "  Created #{image.id}" if image
      end
      add_image_to_collection(image, attributes)
      image
    rescue Oargun::RDF::Controlled::ControlledVocabularyError => e
      puts "  Skipping, due to #{e.message}"
    end

    def create_image(attributes)
      Image.create(attributes.except(:files, :collection)).tap do |image|
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
        gf.original.mime_type = mime_type(path)
        gf.original.original_name = File.basename(path)
        gf.original.content = File.new(path)
        gf.save!
      end
    end

    def mime_type(file_name)
      mime_types = MIME::Types.of(file_name)
      mime_types.empty? ? "application/octet-stream" : mime_types.first.content_type
    end

    def image_path(file_name)
      File.join(image_dir, file_name)
    end

    def image_dir
      @image_directory
    end

    def add_image_to_collection(image, attrs)
      id = attrs[:collection][:id]

      coll = if Collection.exists?(id)
               Collection.find(id)
             else
               Collection.create(attrs[:collection])
             end

      coll.members << image
      coll.save
    end

  end
end
