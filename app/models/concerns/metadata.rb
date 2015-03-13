require 'concerns/relators'
module Metadata
  extend ActiveSupport::Concern

  RELATIONS = {
    contributor:         ::RDF::DC.contributor,
    creator:             ::RDF::DC.creator,
  }.merge(MARCREL)

  included do
    # For ARKs
    property :identifier, predicate: ::RDF::DC.identifier do |index|
      index.as :displayable
    end

    property :accession_number, predicate: ::RDF::URI('http://opaquenamespace.org/ns/cco/accessionNumber') do |index|
      index.as :symbol, :stored_searchable # symbol is needed for exact match search in the CollectionFactory
    end

    property :title, predicate: ::RDF::DC.title, multiple: false do |index|
      index.as :stored_searchable
    end

    property :alternative, predicate: ::RDF::DC.alternative do |index|
      index.as :stored_searchable
    end

    # property :creator, predicate: ::RDF::DC.creator, class_name: Oargun::ControlledVocabularies::Creator do |index|
    #   index.as :stored_searchable, :facetable
    # end
    RELATIONS.each do |field_name, predicate|
      property field_name, predicate: predicate, class_name: Oargun::ControlledVocabularies::Creator do |index|
        index.as :stored_searchable, :facetable
      end
    end

    # property :contributor, predicate: ::RDF::DC.contributor do |index|
    #   index.as :stored_searchable
    # end

    property :description, predicate: ::RDF::DC.description do |index|
      index.as :stored_searchable
    end

    property :latitude, predicate: RDF::EXIF.gpsLatitude do |index|
       index.as :displayable
    end

    property :language, predicate: RDF::DC.language,
      class_name: Oargun::ControlledVocabularies::Language do |index|
        index.as :displayable
    end

    property :longitude, predicate: RDF::EXIF.gpsLongitude do |index|
       index.as :displayable
    end

    property :location, predicate: RDF::DC.spatial,
      class_name: Oargun::ControlledVocabularies::Geographic do |index|
        index.as :stored_searchable, :facetable
    end

    property :place_of_publication, predicate: Oargun::Vocabularies::MARCREL.pup

    property :lc_subject, predicate: RDF::DC.subject, class_name: Oargun::ControlledVocabularies::Subject do |index|
      index.as :stored_searchable, :facetable
    end

    property :publisher, predicate: RDF::DC.publisher do |index|
      index.as :stored_searchable, :facetable
    end

    property :work_type, predicate: RDF::DC.type do |index|
      index.as :stored_searchable
    end

    property :series_name, predicate: ::RDF::URI('http://opaquenamespace.org/ns/seriesName') do |index|
      index.as :displayable
    end

    # Dates
    property :issued, predicate: RDF::DC.issued do |index|
      index.as :displayable
    end

    property :issued_start, predicate: RDF::URI('http://www.loc.gov/mods/rdf/v1#dateIssuedStart') do |index|
      index.as :displayable
    end

    property :issued_end, predicate: RDF::URI('http://www.loc.gov/mods/rdf/v1#dateIssuedEnd') do |index|
      index.as :displayable
    end

    property :created_start, predicate: RDF::Vocab::MODS.dateCreatedStart do |index|
      index.as :displayable
    end

    property :created_end, predicate: RDF::Vocab::MODS.dateCreatedEnd do |index|
      index.as :displayable
    end

    property :date_other, predicate: RDF::DC.date


    # RDA
    property :form_of_work, predicate: RDF::URI('http://www.rdaregistry.info/Elements/w/#formOfWork.en'),
        class_name: Oargun::ControlledVocabularies::WorkType do |index|
      index.as :stored_searchable, :facetable
    end

    property :citation, predicate: RDF::URI('http://www.rdaregistry.info/Elements/u/#preferredCitation.en')

    # MODS
    property :digital_origin, predicate: RDF::Vocab::MODS.digitalOrigin

    property :note, predicate: RDF::Vocab::MODS.note

    property :description_standard, predicate: RDF::Vocab::MODS.recordDescriptionStandard

    property :extent, predicate: RDF::DC.extent do |index|
      index.as :searchable, :displayable
    end

    property :sub_location, predicate: RDF::Vocab::MODS.locationCopySublocation do |index|
      index.as :displayable
    end

    property :record_origin, predicate: RDF::Vocab::MODS.recordOrigin

    property :use_restrictions, predicate: RDF::Vocab::MODS.accessCondition

    id_blank = proc { |attributes| attributes[:id].blank? }

    RELATIONS.keys.each do |relation|
      accepts_nested_attributes_for relation, reject_if: id_blank, allow_destroy: true
    end
    accepts_nested_attributes_for :location, reject_if: id_blank, allow_destroy: true
    accepts_nested_attributes_for :lc_subject, reject_if: id_blank, allow_destroy: true
    accepts_nested_attributes_for :form_of_work, reject_if: id_blank, allow_destroy: true

    def self.contributor_fields
      RELATIONS.keys
    end

    belongs_to :admin_policy, class_name: "Hydra::AdminPolicy", predicate: ActiveFedora::RDF::ProjectHydra.isGovernedBy
  end

  def controlled_properties
    @controlled_properties ||= self.class.properties.each_with_object([]) do |(key, value), arr|
      if value["class_name"] && (value["class_name"] < ActiveTriples::Resource || value["class_name"].new.resource.class < ActiveTriples::Resource)
        arr << key
      end
    end
  end

  def ark
    identifier.first
  end
end
