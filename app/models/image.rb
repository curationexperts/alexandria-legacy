require 'active_fedora/aggregation'
class Image < ActiveFedora::Base
  include Metadata
  include Hydra::Collections::Collectible
  aggregates :generic_files

  def self.indexer
    ImageIndexer
  end

  # override the hash accessor to cast local objects to AF::Base
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
