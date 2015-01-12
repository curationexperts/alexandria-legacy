class Image < ActiveFedora::Base
  include Metadata
  include Hydra::Collections::Collectible

  has_many :generic_files

  def self.indexer
    ImageIndexer
  end

end
