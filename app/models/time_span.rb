class TimeSpan < ActiveFedora::Base
  property :start, predicate: ::RDF::Vocab::EDM.begin
  property :finish, predicate: ::RDF::Vocab::EDM.end
  property :start_qualifier, predicate: ::RDF::Vocab::CRM.P80_end_is_qualified_by
  property :finish_qualifier, predicate: ::RDF::Vocab::CRM.P79_beginning_is_qualified_by
  property :label, predicate: ::RDF::SKOS.prefLabel
  property :note, predicate: ::RDF::SKOS.note

  # temp fix for https://github.com/projecthydra/active_fedora/issues/752 
  has_many :images, predicate: ::RDF::DC.created, inverse_of: :created

  # MODS date qualifiers
  APPROX = "approximate"
  INFERRED = "inferred"
  QUESTIONABLE = "questionable"

  QUALIFIERS = [APPROX, INFERRED, QUESTIONABLE]

  def self.qualifiers
    QUALIFIERS
  end

  def range?
    start.any?(&:present?) && finish.any?(&:present?)
  end

  #def node?
  #  false
  #end

  # Return a string for display of this record
  def display_label
    if label.present?
      label.first
    else
      start_string = qualified_date(start, start_qualifier)
      finish_string = qualified_date(finish, finish_qualifier)
      [start_string, finish_string].compact.join(' - ')
    end
  end

  def qualified_date(date, qualifier)
    if qualifier.include?(APPROX) || qualifier.include?(QUESTIONABLE)
      "ca. #{date.first}"
    else
      date.first
    end
  end

  # return a string suitable for sorting in Solr.
  def sortable
    earliest_year
  end

  # Return an array of years, for faceting in Solr.
  def facetable
    if range?
      (extract_year(start.first)..extract_year(finish.first)).to_a
    else
      extract_year(start.first)
    end
  end

  def earliest_year
    start.sort { |a, b| extract_year(a) <=> extract_year(b) }.first
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
      raise "Invalid date: #{date.inspect} in #{self.inspect}"
    end
end
