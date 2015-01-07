class RDF::DeepIndexingService < ActiveFedora::RDF::IndexingService
  # We're overiding the default indexer in order to index the RDF labels
  def append_to_solr_doc(solr_doc, solr_field_key, field_info, val)
    return super unless val.kind_of? ActiveTriples::Resource

    val.fetch # TODO This should not be in this method because it's slow. We should run it in a background job. See https://github.com/OregonDigital/oregondigital/blob/master/lib/oregon_digital/rdf/deep_fetch.rb
    val = val.solrize
    self.class.create_and_insert_terms(solr_field_key,
                                       val.first,
                                       field_info[:behaviors], solr_doc)
    if val.last.kind_of? Hash
      self.class.create_and_insert_terms("#{solr_field_key}_label",
                                         label(val),
                                         field_info[:behaviors], solr_doc)
    end
  end

  # Return a label for the solrized term:
  # @example
  #   label(["http://id.loc.gov/authorities/subjects/sh85062487", {:label=>"Hotels$http://id.loc.gov/authorities/subjects/sh85062487"}])
  #   => 'Hotels'
  def label(val)
    val.last[:label].split('$').first
  end
end
