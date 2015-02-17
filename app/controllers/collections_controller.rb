class CollectionsController < ApplicationController
  include Blacklight::Catalog
  include Hydra::CollectionsControllerBehavior

  self.solr_search_params_logic += [:only_collections]

  # include Blacklight::Catalog::SearchContext

  # TODO move this to hydra-collections
  def index
    # run the solr query to find the collections
    (@response, @document_list) = get_search_results
  end

  def show
    super
    solr_resp, @document = get_solr_response_for_doc_id(@collection.id)
  end

  # Queries Solr for members of the collection.
  # Populates @response and @member_docs similar to Blacklight Catalog#index populating @response and @documents
  def query_collection_members
    query = params[:cq]

    #default the rows to 100 if not specified then merge in the user parameters and the attach the collection query
    solr_params =  params.symbolize_keys.merge(q: query)

    # run the solr query to find the collections
    (@response, @member_docs) = get_search_results(solr_params)
  end

  configure_blacklight do |config|
    # Fields for the Collection's show page
    config.add_show_field Solrizer.solr_name('earliestDate', :stored_searchable), label: 'Creation Date', helper_method: :display_dates
    config.add_show_field Solrizer.solr_name('extent', :displayable), label: 'Extent'

    # Fields for the Collection index page
    # (Clear out fields that were added by the CatalogController)
    config.index_fields.clear
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
