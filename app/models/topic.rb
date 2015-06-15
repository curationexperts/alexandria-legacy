class Topic < ActiveFedora::Base
  property :label, predicate: ::RDF::SKOS.prefLabel do |index|
    index.as :stored_searchable
  end
end
