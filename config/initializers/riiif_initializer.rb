Riiif::Image.file_resolver = Riiif::HTTPFileResolver
Riiif::Image.info_service = lambda do |id, file|
  resp = get_solr_response_for_doc_id id
  doc = resp.first['response']['docs'].first
  { height: doc['height_isi'], width: doc['width_isi'] }
end
include Blacklight::SolrHelper
def blacklight_config
  CatalogController.blacklight_config
end

### ActiveSupport::Benchmarkable (used in Blacklight::SolrHelper) depends on a logger method

def logger
  Rails.logger
end

Riiif::HTTPFileResolver.id_to_uri = lambda do |id|
  ActiveFedora::Base.id_to_uri(id)
end

Riiif::Engine.config.cache_duration_in_days = 365
