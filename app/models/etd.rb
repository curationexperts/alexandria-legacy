require 'active_fedora/aggregation'
class ETD < ActiveFedora::Base
  include Metadata
  include LocalAuthorityHashAccessor
  include Hydra::AccessControls::Embargoable

  property :system_number, predicate: ::RDF::Vocab::MODS.recordIdentifier do |index|
    index.as :symbol
  end

  property :isbn, predicate: ::RDF::Vocab::Identifiers.isbn do |index|
    index.as :symbol
  end

  property :degree_grantor, predicate: ::RDF::Vocab::MARCRelators.dgg do |index|
    index.as :symbol
  end

  property :keywords, predicate: ::RDF::DC11.subject do |index|
    index.as :symbol
  end

  include NestedAttributes

  include Hydra::Collections::Collectible
  aggregates :generic_files, predicate: ::RDF::URI("http://pcdm.org/models#hasMember")

  contains :proquest

  def self.indexer
    ETDIndexer
  end

  def to_param
    Identifier.noidify(id)
  end

end

