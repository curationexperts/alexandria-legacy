class SearchBuilder < Hydra::SearchBuilder
  include Hydra::PolicyAwareAccessControlsEnforcement

  def only_images_and_collections(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "has_model_ssim:(\"#{Image.to_class_uri}\")" # OR \"#{CourseCollection.to_class_uri}\")"
  end
end
