class CollectionSearchBuilder < Hydra::Collections::SearchBuilder
  include Hydra::AccessControlsEnforcement

  def only_collections(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: Collection.to_class_uri)
  end
end
