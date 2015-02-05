class CollectionsController < ApplicationController
  include Blacklight::Catalog
  include Hydra::CollectionsControllerBehavior

  self.solr_search_params_logic += [:only_collections]

  # include Blacklight::Catalog::SearchContext

  # TODO move this to hydra-collections
  def index
    # run the solr query to find the collections
    (@response, @document_list) = get_search_results( rows: 100)
  end

protected

  # Override rails path for the views
  # (Fixed a problem where the collection show page
  # won't display the list of members because
  # it can't find the partials.)
  def _prefixes
    @_prefixes ||= super + ['catalog']
  end

  def include_collection_ids(*)
    return if action_name == 'index'
    super
  end

  def only_collections(solr_parameters, user_parameters)
    return unless action_name == 'index'
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: Collection.to_class_uri)
  end

  # Override Blacklight method so that you can search and
  # facet within the current collection.
  def search_action_url(*args)
    if action_name == 'show'
      collections.collection_url(*args)
    else
      super(*args)
    end
  end

end
