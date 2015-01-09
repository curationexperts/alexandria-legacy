class ImageIndexer < ActiveFedora::IndexingService
  def rdf_service
    RDF::DeepIndexingService
  end

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['thumbnail_url_ssm'] = generic_file_thumbnails
    end
  end

  protected

    def generic_file_thumbnails
      object.generic_file_ids.map do |id|
        Riiif::Engine.routes.url_helpers.image_url("#{id}/original", size: '300,', host: host)
      end
    end

    def host
      Rails.application.config.host_name
    rescue NoMethodError
      raise "host_name is not configured"
    end
end
