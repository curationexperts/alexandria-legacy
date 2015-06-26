require 'active_fedora/aggregation'
class Image < ActiveFedora::Base
  include Metadata
  include NestedAttributes
  include Hydra::Collections::Collectible
  include LocalAuthorityHashAccessor

  aggregates :generic_files, predicate: ::RDF::URI("http://pcdm.org/models#hasMember")

  def self.indexer
    ImageIndexer
  end

  def to_param
    Identifier.noidify(id)
  end

end
