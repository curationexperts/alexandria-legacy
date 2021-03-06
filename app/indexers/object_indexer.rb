class ObjectIndexer < CurationConcerns::WorkIndexer
  def rdf_service
    RDF::DeepIndexingService
  end

  self.thumbnail_field = 'thumbnail_url_ssm'.freeze

  ISSUED = Solrizer.solr_name('issued', :displayable)
  CREATED = Solrizer.solr_name('created', :displayable)
  COPYRIGHTED = Solrizer.solr_name('date_copyrighted', :displayable)
  VALID = Solrizer.solr_name('date_valid', :displayable)
  OTHER = Solrizer.solr_name('date_other', :displayable)

  SORTABLE_DATE = Solrizer.solr_name('date', :sortable)
  FACETABLE_YEAR = 'year_iim'.freeze

  COLLECTION_LABEL = Solrizer.solr_name('collection_label', :symbol)
  COLLECTION = Solrizer.solr_name('collection', :symbol)

  def generate_solr_document
    super do |solr_doc|
      collection_ids, collection_titles = collections
      solr_doc[COLLECTION] = collection_ids
      solr_doc[COLLECTION_LABEL] = collection_titles

      solr_doc[CREATED] = created
      solr_doc[OTHER] = display_date('date_other')
      solr_doc[VALID] = display_date('date_valid')

      solr_doc[SORTABLE_DATE] = sortable_date
      solr_doc[FACETABLE_YEAR] = facetable_year

      index_contributors(solr_doc)
      solr_doc['note_label_tesim'] = object.notes.flat_map(&:value)
      yield(solr_doc) if block_given?
    end
  end

  private

    # returns two arrays, a list of ids and a list of titles
    def collections
      return [] unless object.id
      query = ActiveFedora::SolrQueryBuilder.construct_query_for_rel(member_ids: object.id,
                                                                     has_model: Collection.to_class_uri)
      results = ActiveFedora::SolrService.query(query, fl: 'title_tesim id'.freeze)
      results.map { |coll| [coll['id'], coll['title_tesim']] }.transpose.map(&:flatten)
    end

    def index_contributors(solr_doc)
      ContributorIndexer.new(object).generate_solr_document(solr_doc)
    end

    def display_date(date_name)
      Array(object[date_name]).map(&:display_label)
    end

    def created
      return unless object.created.present?
      object.created.first.display_label
    end

    # Create a date field for sorting on
    def sortable_date
      Array(sorted_key_date).first.try(:earliest_year)
    end

    # Create a year field (integer, multiple) for faceting on
    def facetable_year
      Array(sorted_key_date).flat_map { |d| d.try(:to_a) }
    end

    def key_date
      return @key_date if @key_date

      # Look through all the dates in order of importance, and
      # find the first one that has a value assigned.
      date_names = [:created, :issued, :date_copyrighted, :date_other, :date_valid]

      date_names.each do |date_name|
        if object[date_name].present?
          @key_date = object[date_name]
          break
        end
      end
      @key_date
    end

    def sorted_key_date
      return unless key_date
      key_date.sort { |a, b| a.earliest_year <=> b.earliest_year }
    end
end
