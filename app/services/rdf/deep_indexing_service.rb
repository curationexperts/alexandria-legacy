class RDF::DeepIndexingService < ActiveFedora::RDF::IndexingService
  # We're overiding the default indexer in order to index the RDF labels
  def append_to_solr_doc(solr_doc, solr_field_key, field_info, val)
    unless object.controlled_properties.include?(solr_field_key)
      return super
    end

    if val.kind_of?(ActiveTriples::Resource)
      begin
        # TODO This should not be in this method because it's slow. We should run it in a background job.
        # See https://github.com/OregonDigital/oregondigital/blob/master/lib/oregon_digital/rdf/deep_fetch.rb
        val.fetch
      rescue SocketError, IOError => e
        Rails.logger.error "Couldn't fetch RDF label for #{val.id}\n#{e.message}"
      end

      val = val.solrize
    end

    val = Array(val)
    self.class.create_and_insert_terms(solr_field_key,
                                       val.first,
                                       field_info[:behaviors], solr_doc)

    self.class.create_and_insert_terms("#{solr_field_key}_label",
                                       label(val),
                                       field_info[:behaviors], solr_doc)
  end

  # Return a label for the solrized term:
  # @example
  #   label(["http://id.loc.gov/authorities/subjects/sh85062487", {:label=>"Hotels$http://id.loc.gov/authorities/subjects/sh85062487"}])
  #   => 'Hotels'
  def label(val)
    val = val.last
    if val.kind_of?(Hash)
      val[:label].split('$').first
    else
      val
    end
  end
end
