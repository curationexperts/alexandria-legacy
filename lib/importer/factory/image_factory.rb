module Importer::Factory
  class ImageFactory < ObjectFactory
    include WithAssociatedCollection

    def klass
      Image
    end

    def after_create(image)
      if files_directory
        attributes[:files].each do |file_path|
          create_file(image, file_path)
        end
        image.save # force a reindex after the files are created
      end
    end

    def create_file(image, file_name)
      path = image_path(file_name)
      unless File.exist?(path)
        puts "  * File doesn't exist at #{path}"
        return
      end
      file_set = FileSet.new(admin_policy_id: image.admin_policy_id)
      puts "  Attaching binary #{file_name}"
      Hydra::Works::AddFileToFileSet.call(file_set,
                                          File.new(path),
                                          :original_file)
      image.ordered_members << file_set
    end

    def mime_type(file_name)
      mime_types = MIME::Types.of(file_name)
      mime_types.empty? ? 'application/octet-stream' : mime_types.first.content_type
    end

    def image_path(file_name)
      File.join(files_directory, file_name)
    end
  end
end
