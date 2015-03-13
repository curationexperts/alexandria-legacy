class ImageIndexer < ActiveFedora::IndexingService
  def rdf_service
    RDF::DeepIndexingService
  end

  CREATOR_MULTIPLE = Solrizer.solr_name('creator_label', :stored_searchable)
  ISSUED = Solrizer.solr_name('issued', :displayable)
  ISSUED_START = Solrizer.solr_name('issued_start', :displayable)
  CREATED_START = Solrizer.solr_name('created_start', :displayable)
  SORTABLE_CREATOR = Solrizer.solr_name('creator_label', :sortable)
  SORTABLE_DATE = Solrizer.solr_name('date', :sortable)
  FACETABLE_YEAR = 'year_iim'
  COLLECTION_LABEL = Solrizer.solr_name('collection_label', :symbol)
  COLLECTION = Solrizer.solr_name('collection', :symbol)
  CONTRIBUTOR_LABEL = Solrizer.solr_name('contributor_label', :stored_searchable)

  def generate_solr_document
    super do |solr_doc|
      solr_doc[COLLECTION] = object.collection_ids
      # TODO if we need to optimize, we could pull this from solr
      solr_doc[COLLECTION_LABEL] = object.collections.map &:title
      solr_doc['thumbnail_url_ssm'.freeze] = generic_file_thumbnails
      solr_doc['image_url_ssm'.freeze] = generic_file_images
      solr_doc['large_image_url_ssm'.freeze] = generic_file_large_images
      solr_doc[SORTABLE_CREATOR] = sortable_creator(solr_doc)
      solr_doc[SORTABLE_DATE] = sortable_date(solr_doc)
      solr_doc[FACETABLE_YEAR] = facetable_year(solr_doc)
      solr_doc[CONTRIBUTOR_LABEL] = contributors
    end
  end

  private

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
    def sortable_date(solr_doc)
      if solr_doc.key? ISSUED
        solr_doc.fetch(ISSUED).first
      elsif solr_doc.key? ISSUED_START
        solr_doc.fetch(ISSUED_START).first
      elsif solr_doc.key? CREATED_START
        solr_doc.fetch(CREATED_START).first
      end
    end

    # Create a year field (integer, multiple) for faceting on
    def facetable_year(solr_doc)
      if object.issued_start.present?
        start = extract_year(object.issued_start.first)
        stop = extract_year(object.issued_end.first)
        (start..stop).to_a
      elsif object.issued.present?
        object.issued.map { |date| extract_year(date) }
      elsif object.created_start.present?
        start = extract_year(object.created_start.first)
        stop = extract_year(object.created_end.first)
        (start..stop).to_a
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

    private
      def host
        Rails.application.config.host_name
      rescue NoMethodError
        raise "host_name is not configured"
      end

      def extract_year(date)
        # Date.iso8601 doesn't support YYYY dates
        if /^\d{4}$/ =~ date
          date.to_i
        else
          Date.iso8601(date).year
        end
      rescue ArgumentError
        raise "Invalid date: #{date.inspect} in #{object.id}"
      end
end
