require_relative './object_factory'

class ImageFactory < ObjectFactory

  def klass
    Image
  end

  def after_save(image)
    add_image_to_collection(image, attributes)
  end

  def after_create(image)
    if files_directory
      attributes[:files].each do |file_path|
        create_file(image, file_path)
      end
      image.save # force a reindex after the files are created
    end
  end

  def create_attributes
    transform_attributes.except(:files, :collection)
  end

  def create_file(image, file_name)
    path = image_path(file_name)
    unless File.exists?(path)
      puts "  * File doesn't exist at #{path}"
      return
    end
    image.generic_files.create do |gf|
      puts "  Attaching binary #{file_name}"
      gf.original.mime_type = mime_type(path)
      gf.original.original_name = File.basename(path)
      gf.original.content = File.new(path)
    end
  end

  def mime_type(file_name)
    mime_types = MIME::Types.of(file_name)
    mime_types.empty? ? "application/octet-stream" : mime_types.first.content_type
  end

  def image_path(file_name)
    File.join(files_directory, file_name)
  end

  def add_image_to_collection(image, attrs)
    collection_attrs = attrs[:collection].merge(admin_policy_id: attributes[:admin_policy_id])
    CollectionFactory.new(collection_attrs).run do |coll|
      coll.members << image
      coll.save!
    end
    # reload the collectoin association so we can reindex with the collection
    image.association(:collections).reload
    image.update_index
  end

end
