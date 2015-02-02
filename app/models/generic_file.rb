class GenericFile < ActiveFedora::Base
  belongs_to :image, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf

  contains :original
end
