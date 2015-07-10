class ETDIndexer < ObjectIndexer
  def generate_solr_document
    super do |solr_doc|
      unless object.generic_file_ids.empty?
        solr_doc['original_download_url_ssm'.freeze] = original_download_url
      end
    end
  end

  private

  def original_download_url
    [Rails.application.routes.url_helpers.download_url(object.generic_file_ids[0], host: host)]
  end


end
