class Image < ActiveFedora::Base
  include Metadata
  include Hydra::Collections::Collectible


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

  # override the accessor to cast local objects to AF::Base
  # TODO move this into Oargun using the casting functionality of ActiveTriples
  def [](arg)
    Array(super).map do |item|
      if item.kind_of?(Oargun::ControlledVocabularies::Creator) && item.rdf_subject.start_with?(ActiveFedora.fedora.host)
        ActiveFedora::Base.find(ActiveFedora::Base.uri_to_id(item.rdf_subject))
      else
        item
      end
    end
  end

end
