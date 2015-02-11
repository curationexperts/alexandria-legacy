class Collection < ActiveFedora::Base
  include Hydra::Collection

  property :extent, :predicate => ::RDF::DC.extent do |index|
    index.as :searchable, :displayable
  end

end
