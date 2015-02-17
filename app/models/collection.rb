class Collection < ActiveFedora::Base
  include Metadata
  include Hydra::Collection

  accepts_nested_attributes_for :creator, reject_if: proc { |attributes| attributes[:id].blank? }

  def self.indexer
    CollectionIndexer
  end

end
