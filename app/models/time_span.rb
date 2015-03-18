class TimeSpan < ActiveFedora::Base
  property :start, predicate: ::RDF::Vocab::EDM.begin
  property :finish, predicate: ::RDF::Vocab::EDM.end
  property :start_qualifier, predicate: ::RDF::Vocab::CRM.P80_end_is_qualified_by
  property :finish_qualifier, predicate: ::RDF::Vocab::CRM.P79_beginning_is_qualified_by
  property :label, predicate: ::RDF::SKOS.prefLabel
  property :note, predicate: ::RDF::SKOS.note

  def range?
    start.present? && finish.present?
  end


  # Return a string for display of this record
  def display_label
    if label.present?
      label.first
    elsif range?
      "#{start.first}-#{finish.first}"
    else
      start.first
    end
  end

  # return a string suitable for sorting in Solr.
  def sortable
    start.first
  end

  # Return an array of years, for faceting in Solr.
  def facetable
    if range?
      (extract_year(start.first)..extract_year(finish.first)).to_a
    else
      extract_year(start.first)
    end
  end

  private
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
