class Image < ActiveFedora::Base
  include Metadata
  include Hydra::Collections::Collectible

  accepts_nested_attributes_for :creator, reject_if: proc { |attributes| attributes[:id].blank? }
  has_many :generic_files

  def self.indexer
    ImageIndexer
  end

end
