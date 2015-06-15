class LocalAuthoritiesSearchBuilder < Hydra::SearchBuilder
  include Hydra::PolicyAwareAccessControlsEnforcement

  def only_models_for_local_authorities(solr_params)
    solr_params[:fq] ||= []
    models = [Agent, Person, Group, Organization, Topic]
    solr_params[:fq] << "{!terms f=has_model_ssim}#{models.join(',')}"
  end

end
