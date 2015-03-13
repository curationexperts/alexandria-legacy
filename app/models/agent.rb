# Agent is a class in FOAF that has possible subclasses of
# Person, Group, or Organization.
# See:  http://xmlns.com/foaf/spec/#term_Agent

class Agent < ActiveFedora::Base

  property :foaf_name, predicate: ::RDF::FOAF.name, multiple: false do |index|
    index.as :stored_searchable, :symbol  # Need :symbol for exact match for ObjectFactory find_or_create_* methods.
  end

  def rdf_label
    Array(foaf_name)
  end

end
