class DeepIndexer < ActiveFedora::IndexingService
  def rdf_service
    RDF::DeepIndexingService
  end
end
