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
      mods = Mods::Record.new.from_file(file)
      if Image.exists?(mods.identifier.text)
        puts "  Skipping. #{mods.identifier.text} already exists"
        return
      end
      image = create_image(mods)
      puts "  Created #{image.id}" if image
    end

    def create_image(mods)
      image = Image.create(id: mods.identifier.text,
                   location: mods.subject.geographic.valueURI.map { |uri| RDF::URI.new(uri) },
                   lcsubject: mods.subject.topic.valueURI.map { |uri| RDF::URI.new(uri) },
                   publisher: [mods.origin_info.publisher.text],
                   title: [mods.title_info.title.text],
                   workType: mods.genre.valueURI.map { |uri| RDF::URI.new(uri) })

        mods.extension.xpath('./fileName').each do |file_node|
          create_file(image, file_node.text)
        end
      image
    rescue Oargun::RDF::Controlled::ControlledVocabularyError => e
      puts "Skipping, due to #{e.message}"
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
