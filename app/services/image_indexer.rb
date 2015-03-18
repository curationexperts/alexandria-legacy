class ImageIndexer < ActiveFedora::IndexingService
  def rdf_service
    RDF::DeepIndexingService
  end

  ISSUED = Solrizer.solr_name('issued', :displayable)
  CREATED = Solrizer.solr_name('created', :displayable)
  SORTABLE_DATE = Solrizer.solr_name('date', :sortable)
  FACETABLE_YEAR = 'year_iim'

  CREATOR_MULTIPLE = Solrizer.solr_name('creator_label', :stored_searchable)
  SORTABLE_CREATOR = Solrizer.solr_name('creator_label', :sortable)
  CONTRIBUTOR_LABEL = Solrizer.solr_name('contributor_label', :stored_searchable)

  COLLECTION_LABEL = Solrizer.solr_name('collection_label', :symbol)
  COLLECTION = Solrizer.solr_name('collection', :symbol)
  INSTITUTION = Solrizer.solr_name('institution', :stored_searchable)

  def generate_solr_document
    super do |solr_doc|
      solr_doc[COLLECTION] = object.collection_ids
      # TODO if we need to optimize, we could pull this from solr
      solr_doc[COLLECTION_LABEL] = object.collections.map &:title
      solr_doc['thumbnail_url_ssm'.freeze] = generic_file_thumbnails
      solr_doc['image_url_ssm'.freeze] = generic_file_images
      solr_doc['large_image_url_ssm'.freeze] = generic_file_large_images
      solr_doc[SORTABLE_CREATOR] = sortable_creator(solr_doc)
      solr_doc[ISSUED] = issued
      solr_doc[CREATED] = created
      solr_doc[SORTABLE_DATE] = sortable_date
      solr_doc[FACETABLE_YEAR] = facetable_year
      solr_doc[CONTRIBUTOR_LABEL] = contributors
      solr_doc[INSTITUTION] = institution
    end
  end

  private

    def institution
      return unless object.institution.present?
      object.institution.first.display_label
    end

    def created
      return unless object.created.present?
      object.created.first.display_label
    end

    def issued
      return unless object.issued.present?
      object.issued.first.display_label
    end

    def contributors
      Metadata::MARCREL.keys.each_with_object([]) do |field, list|
        next if object[field].empty?
        list.push *object[field].map { |val|
          val.respond_to?(:rdf_label) && val.rdf_label.first }
      end
    end

    # Create a creator field suitable for sorting on
    def sortable_creator(solr_doc)
      solr_doc.fetch(CREATOR_MULTIPLE).first if solr_doc.key? CREATOR_MULTIPLE
    end

    # Create a date field for sorting on
    def sortable_date
      key_date.try(:sortable)
    end

    # Create a year field (integer, multiple) for faceting on
    def facetable_year
      key_date.try(:facetable)
    end

    def key_date
      if object.issued.present?
        object.issued.first
      elsif object.created.present?
        object.created.first
      end
    end

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
