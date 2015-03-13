# Agent is a class in FOAF that has possible subclasses of
# Person, Group, or Organization.
# See:  http://xmlns.com/foaf/spec/#term_Agent

class Agent < ActiveFedora::Base

  property :foaf_name, predicate: ::RDF::FOAF.name, multiple: false do |index|
    index.as :stored_searchable
  end

  def rdf_label
    Array(foaf_name)
  end

end
