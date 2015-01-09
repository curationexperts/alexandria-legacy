class GenericFile < ActiveFedora::Base
  belongs_to :image, predicate: ActiveFedora::RDF::RelsExt.isPartOf

  contains :original
end
