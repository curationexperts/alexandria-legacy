require_relative './object_factory'

class CollectionFactory < ObjectFactory

  def run
    if Collection.exists?(attributes[:id])
      coll = Collection.find(attributes[:id])
      coll.update(attributes.except(:id))
      puts "  Updated. #{attributes[:id]}"
    else
      coll = Collection.create(attributes)
      puts "  Created #{coll.id}" if coll
    end
    coll
  end

end
