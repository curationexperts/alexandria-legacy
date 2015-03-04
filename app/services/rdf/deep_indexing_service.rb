class RDF::DeepIndexingService < ActiveFedora::RDF::IndexingService
  # We're overiding the default indexer in order to index the RDF labels
  def append_to_solr_doc(solr_doc, solr_field_key, field_info, val)
    if val.kind_of?(ActiveTriples::Resource) && object.controlled_properties.include?(solr_field_key)
      append_label_and_uri(solr_doc, solr_field_key, field_info, val)
    else
      super
    end
  end

  def add_assertions(*)
    fetch_external
    super
  end

  def fetch_external
    object.controlled_properties.each do |property|
      object[property].each do |value|
        resource = value.respond_to?(:resource) ? value.resource : value
        next unless resource.kind_of?(ActiveTriples::Resource)
        old_label = resource.rdf_label.first
        next unless old_label == resource.rdf_subject.to_s || old_label.nil?
        fetch_value(resource) if resource.kind_of? ActiveTriples::Resource
        if !value.kind_of?(ActiveFedora::Base) && old_label != resource.rdf_label.first && resource.rdf_label.first != resource.rdf_subject.to_s
          resource.persist! # Stores the fetched values into our RDF::Solr repository
        end
      end
    end
  end

  def fetch_value(value)
    Rails.logger.info "Fetching #{value.rdf_subject} from the authorative source. (this is slow)"
    value.fetch
  rescue IOError, SocketError => e
    # IOError could result from a 500 error on the remote server
    # SocketError results if there is no server to connect to
    Rails.logger.error "Unable to fetch #{value.rdf_subject} from the authorative source.\n#{e.message}"
  end

  def append_label_and_uri(solr_doc, solr_field_key, field_info, val)
    # begin
    #   # TODO This should not be in this method because it's slow. We should run it in a background job.
    #   # See https://github.com/OregonDigital/oregondigital/blob/master/lib/oregon_digital/rdf/deep_fetch.rb
    #   val.fetch
    # rescue SocketError, IOError => e
    #   Rails.logger.error "Couldn't fetch RDF label for #{val.id}\n#{e.message}"
    # end
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
