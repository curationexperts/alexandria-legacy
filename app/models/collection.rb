class Collection < ActiveFedora::Base
  #include Hydra::AccessControls::Permissions
  include Hydra::Collections::Relations
  include Metadata

  accepts_nested_attributes_for :creator, reject_if: proc { |attributes| attributes[:id].blank? }
  accepts_nested_attributes_for :collector, reject_if: proc { |attributes| attributes[:id].blank? }

  def self.indexer
    CollectionIndexer
  end

  def to_param
    Identifier.noidify(id)
  end

end
