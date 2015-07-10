class ObjectIndexer < ActiveFedora::IndexingService

  def rdf_service
    RDF::DeepIndexingService
  end

  ISSUED = Solrizer.solr_name('issued', :displayable)
  CREATED = Solrizer.solr_name('created', :displayable)
  COPYRIGHTED = Solrizer.solr_name('date_copyrighted', :displayable)
  VALID = Solrizer.solr_name('date_valid', :displayable)
  OTHER = Solrizer.solr_name('date_other', :displayable)

  SORTABLE_DATE = Solrizer.solr_name('date', :sortable)
  FACETABLE_YEAR = 'year_iim'

  COLLECTION_LABEL = Solrizer.solr_name('collection_label', :symbol)
  COLLECTION = Solrizer.solr_name('collection', :symbol)

  def generate_solr_document
    super do |solr_doc|
      solr_doc[COLLECTION] = object.collection_ids
      # TODO if we need to optimize, we could pull this from solr
      solr_doc[COLLECTION_LABEL] = object.collections.map &:title
      solr_doc[ISSUED] = issued
      solr_doc[CREATED] = created
      solr_doc[COPYRIGHTED] = display_date('date_copyrighted')
      solr_doc[OTHER] = display_date('date_other')
      solr_doc[VALID] = display_date('date_valid')
      solr_doc[SORTABLE_DATE] = sortable_date
      solr_doc[FACETABLE_YEAR] = facetable_year

      index_contributors(solr_doc)
      solr_doc['rights_holder_label_tesim'] = object['rights_holder'].flat_map(&:rdf_label)
      solr_doc['note_label_tesim'] = object.notes.map(&:value)
      yield(solr_doc) if block_given?
    end
  end

  private

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

    def issued
      return unless object.issued.present?
      object.issued.first.display_label
    end

    # Create a date field for sorting on
    def sortable_date
      Array(key_date).first.try(:earliest_year)
    end

    # Create a year field (integer, multiple) for faceting on
    def facetable_year
      Array(key_date).flat_map{ |d| d.try(:to_a) }
    end

    def key_date
      # Look through all the dates in order of importance, and
      # find the first one that has a value assigned.
      date_names = [:created, :issued, :date_copyrighted, :date_other, :date_valid]

      date = nil
      date_names.each do |date_name|
        if object[date_name].present?
          date = object[date_name].sort{ |a,b| a.earliest_year <=> b.earliest_year }
          break
        end
      end
      date
    end

    def host
      Rails.application.config.host_name
    rescue NoMethodError
      raise "host_name is not configured"
    end

end
