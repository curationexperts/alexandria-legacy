class LocalAuthoritiesSearchBuilder < Hydra::SearchBuilder
  include Hydra::PolicyAwareAccessControlsEnforcement

  def only_models_for_local_authorities(solr_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << "has_model_ssim:(\"#{Person.to_class_uri}\" OR \"#{Group.to_class_uri}\" OR \"#{Organization.to_class_uri}\" OR \"#{Agent.to_class_uri}\")"
  end

end
