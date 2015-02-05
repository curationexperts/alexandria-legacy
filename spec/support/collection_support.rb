module CollectionSupport

  def create_collection_with_images(collection_attrs, attrs_for_images)
    collection = Collection.create!(collection_attrs)
    attrs_for_images.each do |attrs|
      image = Image.new(attrs)
      image.collections << collection
      image.save!
    end
    collection
  end

end
