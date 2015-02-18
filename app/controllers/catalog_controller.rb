# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController

  # helper Openseadragon::OpenseadragonHelper

  include Blacklight::Catalog
  include Hydra::Controller::ControllerBehavior
  # These before_filters apply the hydra access controls
  # before_filter :enforce_show_permissions, :only=>:show
  # This applies appropriate access controls to all solr queries
  # CatalogController.solr_search_params_logic += [:add_access_controls_to_solr_params]
  CatalogController.solr_search_params_logic += [:only_images_and_collections]

  add_show_tools_partial(:edit, partial: 'catalog/edit', if: :editor?)

  configure_blacklight do |config|
    config.view.gallery.partials = [:index_header, :index]
    config.view.slideshow.partials = [:index]

    # config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    # config.show.partials.insert(1, :openseadragon)

    config.default_solr_params = {
      qf: 'title_tesim lc_subject_label_tesim',
      qt: 'search',
      rows: 10
    }

    # solr field configuration for search results/index views
    config.index.title_field = solr_name('title', :stored_searchable)
    config.index.display_type_field = 'has_model_ssim'

    config.index.thumbnail_field = 'thumbnail_url_ssm'

    config.show.partials = [:media, :show]

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _tsimed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    config.add_facet_field 'active_fedora_model_ssi', :label => 'Format'
    config.add_facet_field solr_name('location_label', :facetable), label: 'Location'
    config.add_facet_field solr_name('creator_label', :facetable), label: 'Creator'
    config.add_facet_field solr_name('lc_subject_label', :facetable), label: 'Subject'
    config.add_facet_field solr_name('publisher', :facetable), label: 'Publisher'
    config.add_facet_field solr_name('form_of_work_label', :facetable), label: 'Type'
    config.add_facet_field solr_name('collection_label', :symbol), label: 'Collection'

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.default_solr_params[:'facet.field'] = config.facet_fields.keys
    #use this instead if you don't want to query facets marked :show=>false
    #config.default_solr_params[:'facet.field'] = config.facet_fields.select{ |k, v| v[:show] != false}.keys


    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field solr_name('location_label', :stored_searchable), label: 'Location'
    config.add_index_field solr_name('lc_subject_label', :stored_searchable), label: 'Subject'
    config.add_index_field solr_name('publisher', :stored_searchable), label: 'Publisher'
    config.add_index_field solr_name('creator_label', :stored_searchable), label: 'Creator'
    config.add_index_field solr_name('form_of_work_label', :stored_searchable), label: 'Type'
    config.add_index_field solr_name('language', :stored_searchable, type: :string), label: 'Language'


    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field solr_name('collection_label', :symbol), label: 'Collection', helper_method: :link_to_collection
    config.add_show_field solr_name('location_label', :stored_searchable), label: 'Location'
    config.add_show_field solr_name('lc_subject_label', :stored_searchable), label: 'Subject'
    config.add_show_field solr_name('publisher', :stored_searchable), label: 'Publisher'
    config.add_show_field solr_name('creator_label', :stored_searchable), label: 'Creator'
    config.add_show_field solr_name('form_of_work_label', :stored_searchable), label: 'Type'
    config.add_show_field solr_name('language', :stored_searchable, type: :string), label:'Language'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field 'all_fields', :label => 'All Fields'

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      field.solr_local_parameters = {
        :qf => 'title_tesim',
        :pf => 'title_tesim'
      }
    end

    config.add_search_field('subject') do |field|
      field.solr_local_parameters = {
        qf: 'lc_subject_label_tesim',
        pf: 'lc_subject_label_tesim'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field "score desc, #{ImageIndexer::SORTABLE_DATE} desc, creator_label_si asc", label: 'relevance'
    config.add_sort_field "#{ImageIndexer::SORTABLE_DATE} asc, creator_label_si asc", label: 'year ascending'
    config.add_sort_field "#{ImageIndexer::SORTABLE_DATE} desc, creator_label_si asc", label: 'year descending'
    config.add_sort_field "creator_label_si asc, #{ImageIndexer::SORTABLE_DATE} asc", label: 'creator ascending'
    config.add_sort_field "creator_label_si desc, #{ImageIndexer::SORTABLE_DATE} asc", label: 'creator descending'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end


  protected
    def only_images_and_collections(solr_parameters, user_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "has_model_ssim:(\"#{Image.to_class_uri}\")" # OR \"#{CourseCollection.to_class_uri}\")"
    end
end
