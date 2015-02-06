module CollectionsHelper
  def has_collection_search_parameters?
    !params[:cq].blank?
  end
end
