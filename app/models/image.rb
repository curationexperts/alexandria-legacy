class Image < ActiveFedora::Base
  include Metadata
  include Hydra::Collections::Collectible

  accepts_nested_attributes_for :creator
  has_many :generic_files

  def self.indexer
    ImageIndexer
  end

end
