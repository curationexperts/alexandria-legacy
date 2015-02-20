class Image < ActiveFedora::Base
  include Metadata
  include Hydra::Collections::Collectible

  accepts_nested_attributes_for :creator, reject_if: proc { |attributes| attributes[:id].blank? }

  after_save :save_aggregator

  def save_aggregator
    generic_files.save
  end

  # has_one :aggregation
  # has_many :generic_files, through: :aggregation
  def generic_files
    @file_association ||= FileAssociation.new(self, { class_name: 'GenericFile' } )
  end

  def generic_files=(vals)
    generic_files.target = vals
  end

  def generic_file_ids=(vals)
    generic_files.target_ids = vals
  end

  def generic_file_ids
    generic_files.target_ids
  end

  def self.indexer
    ImageIndexer
  end

end
