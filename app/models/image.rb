class Image < ActiveFedora::Base
  include Metadata
  include Hydra::Collections::Collectible

  has_many :generic_files

  def self.indexer
    ImageIndexer
  end

  def to_solr(solr_doc={}, opts={})
    solr_doc = super(solr_doc, opts)
    index_collection_ids(solr_doc)
    solr_doc
  end

end
