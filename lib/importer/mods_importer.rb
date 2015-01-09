module Importer
  class ModsImporter
    IMAGE_DIRECTORY = '../alexandria-images/special_collections/mss36-sb-postcards/tiff-a16/'

    def initialize(dirname=nil)
      @dirname = dirname
    end

    def import_all
      count = 0
      Dir.glob("#{@dirname}/**/*").each do |filename|
        next if File.directory?(filename)
        import(filename)
        count += 1
      end
      count
    end

    def self.import
      file = File.join(Rails.root, 'spec/fixtures/mods/cusbspcmss36_110108.xml')
      importer = ModsImporter.new.import(file)
    end

    def import(file)
      puts "Importing: #{file}"
      mods = Mods::Record.new.from_file(file)
      if Image.exists?(mods.identifier.text)
        puts "  Skipping. #{mods.identifier.text} already exists"
        return
      end
      image = create_image(mods)
      puts "  Created #{image.id}"
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
    end

    def create_file(image, file_name)
      path = image_path(file_name)
      unless File.exists?(path)
        puts "File doesn't exist at #{path}"
        return
      end
      image.generic_files.create do |gf|
        puts "  Reading image #{file_name}"
        gf.original.content = File.new(path)
        gf.original.save
      end
    end

    def image_path(file_name)
      File.join(image_dir, file_name)
    end

    def image_dir
      IMAGE_DIRECTORY
    end

  end
end
