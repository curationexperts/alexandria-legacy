class LocalAuthoritiesController < ApplicationController

  include Hydra::Catalog
  include Hydra::Controller::ControllerBehavior

  LocalAuthoritiesController.search_params_logic += [:only_models_for_local_authorities]

  configure_blacklight do |config|
    config.search_builder_class = LocalAuthoritiesSearchBuilder

    config.default_solr_params = {
      qf: 'foaf_name_tesim',
      wt: 'json',
      qt: 'search',
      rows: 10
    }

    config.add_search_field('name') do |field|
      field.solr_local_parameters = {
        :qf => 'foaf_name_tesim',
        :pf => 'foaf_name_tesim'
      }
    end

    config.add_facet_field 'active_fedora_model_ssi', :label => 'Type'

    config.index.title_field = ['foaf_name_tesim', 'label_tesim']
  end  # configure_blacklight

  # Override rails path for the views so that we can use
  # regular blacklight views from app/views/catalog
  def _prefixes
    @_prefixes ||= super + ['catalog']
  end 
end
