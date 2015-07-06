require 'active_fedora/aggregation'
class ETD < ActiveFedora::Base
  include Metadata
  property :system_number, predicate: ::RDF::Vocab::MODS.recordIdentifier do |index|
    index.as :symbol
  end

  include NestedAttributes

  include Hydra::Collections::Collectible
  aggregates :generic_files, predicate: ::RDF::URI("http://pcdm.org/models#hasMember")

  contains :proquest

  def self.indexer
    ImageIndexer
  end

  def to_param
    Identifier.noidify(id)
  end

  # TODO this is a duplicate of Image
  # override the hash accessor to cast local objects to AF::Base
  # TODO move this into Oargun using the casting functionality of ActiveTriples
  def [](arg)
    reflection = self.class.reflect_on_association(arg.to_sym)
    # Checking this avoids setting properties like head_id (belongs_to) to an array
    if (reflection && reflection.collection?) || !reflection
      Array(super).map do |item|
        if item.kind_of?(Oargun::ControlledVocabularies::Creator) && item.rdf_subject.start_with?(ActiveFedora.fedora.host)
          ActiveFedora::Base.find(ActiveFedora::Base.uri_to_id(item.rdf_subject))
        else
          item
        end
      end
    else
      super
    end
  end
end

