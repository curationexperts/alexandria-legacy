class ImageIndexer < ActiveFedora::IndexingService
  def rdf_service
    RDF::DeepIndexingService
  end

  CREATOR_MULTIPLE = Solrizer.solr_name('creator_label', :stored_searchable)

  def generate_solr_document
    super.tap do |solr_doc|
      object.index_collection_ids(solr_doc)
      solr_doc['thumbnail_url_ssm'.freeze] = generic_file_thumbnails
      solr_doc['image_url_ssm'.freeze] = generic_file_images
      solr_doc['large_image_url_ssm'.freeze] = generic_file_large_images
      solr_doc[Solrizer.solr_name('creator_label', :sortable)] = solr_doc.fetch(CREATOR_MULTIPLE).first if solr_doc.key? CREATOR_MULTIPLE
    end
  end

  protected

    def generic_file_thumbnails
      generic_file_images('300,'.freeze)
    end

    def generic_file_large_images
      generic_file_images('1000,'.freeze)
    end

    def generic_file_images size='600,'
      object.generic_file_ids.map do |id|
        Riiif::Engine.routes.url_helpers.image_url("#{id}/original", size: size, host: host)
      end
    end

    def host
      Rails.application.config.host_name
    rescue NoMethodError
      raise "host_name is not configured"
    end
end
