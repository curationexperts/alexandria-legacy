class Collection < ActiveFedora::Base
  include Hydra::Collection

  def self.indexer
    CollectionIndexer
  end

  property :extent, :predicate => ::RDF::DC.extent do |index|
    index.as :searchable, :displayable
  end

  property :workType, predicate: ::RDF::DC.type, class_name: Oargun::ControlledVocabularies::WorkType do |index|
    index.as :stored_searchable, :facetable
  end

  property :lcsubject, predicate: ::RDF::DC.subject, class_name: Oargun::ControlledVocabularies::Subject do |index|
    index.as :stored_searchable, :facetable
  end

end
