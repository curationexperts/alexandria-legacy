require 'oargun'
module Metadata
  extend ActiveSupport::Concern
  included do
    property :title, predicate: ::RDF::DC.title do |index|
      index.as :stored_searchable
    end
    property :creator, predicate: ::RDF::DC.creator do |index|
      index.as :stored_searchable
    end
    property :contributor, predicate: ::RDF::DC.contributor do |index|
      index.as :stored_searchable
    end
    property :description, predicate: ::RDF::DC.description do |index|
      index.as :stored_searchable
    end

    property :geobox, predicate: RDF::URI('https://schema.org/box') do |index|
       index.as :stored_searchable
    end

    property :location, predicate: RDF::DC.spatial,
      class_name: Oargun::ControlledVocabularies::Geographic do |index|
       index.as :stored_searchable, :facetable
    end

    property :lcsubject, predicate: RDF::DC.subject, class_name: Oargun::ControlledVocabularies::Subject do |index|
      index.as :stored_searchable, :facetable
    end

    property :publisher, predicate: RDF::DC.publisher do |index|
      index.as :stored_searchable, :facetable
    end

    property :workType, predicate: RDF::DC.type, class_name: Oargun::ControlledVocabularies::WorkType do |index|
      index.as :stored_searchable, :facetable
    end
  end
end
