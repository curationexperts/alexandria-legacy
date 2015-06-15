
require 'traject/macros/marc_format_classifier'
require 'traject/macros/marc21_semantics'
require 'solrizer'
require_relative 'app/utils/identifier'
extend Traject::Macros::Marc21Semantics
extend Traject::Macros::MarcFormats

def ark_from_alexandria_uri(uri)
  md = /http:\/\/alexandria\.ucsb\.edu\/lib\/(ark:\/\d{5}\/.*)/.match(uri)
  md[1] if md
end

settings do
  # provide "writer_class_name", "Traject::JsonWriter"
  # TODO use the solr.yml
  provide "solr.url", "http://localhost:8983/solr/development"
  provide "solr_writer.commit_on_close", "true"
end

# see http://alexandria.ucsb.edu/catalog/adrl:f3000017
# to_field 'last_transaction_datetime', extract_marc("005")
# to_field 'Fixed-Length Data Elements', extract_marc("006")
# to_field 'f007', extract_marc("007")
# to_field 'f008', extract_marc("008")
# to_field "language_code", extract_marc("008[35-37]")
to_field "language_ssim", marc_languages
to_field "year_iim", marc_publication_date
to_field "date_created_ss", marc_publication_date

to_field 'isbn_ssim', extract_marc("020")

extractor = MarcExtractor.new("856u", :separator => nil)
IDENTIFIER = Solrizer.solr_name('identifier', :displayable)

to_field IDENTIFIER, lambda { |record, accumulator, context|
  fields = extractor.extract(record).map do |field|
    ark_from_alexandria_uri(field)
  end.compact
  if fields.empty?
    context.skip! # TODO mint an ark instead of skiping the record
  else
    # TODO update ARK to point at alexandria-v2?
    accumulator << fields.first
  end
}

to_field 'id', lambda { |record, accumulator, context|
  accumulator << Identifier.ark_to_id(context.output_hash[IDENTIFIER].first)
}

# to_field "format_s", marc_formats
to_field 'active_fedora_model_ssi', literal("Thesis or dissertation")
to_field 'form_of_work_label_tesim', literal("Thesis or dissertation")
to_field 'has_model_ssim', literal("Etd")

to_field 'title_tesim',       marc_sortable_title
# to_field 'broad_subject',     marc_lcc_to_broad_category
# to_field "geographic_facet",  marc_geo_facet
#
to_field 'author_tesim', extract_marc("100")
# to_field 'title', extract_marc("245") # also has statement of responsibility, needs to strip type
# to_field 'filing_version', extract_marc_filing_version # title with statement of responsibility stripped, but still has colin and slashes
to_field 'published_ss', extract_marc("260")
to_field 'description_ssim', extract_marc("300")
to_field 'advisor_tesim', extract_marc("500") # and committee members
to_field 'dissertation_ssim', extract_marc("502")
to_field 'bibliography_ssim', extract_marc("504")
# to_field 'f506', extract_marc("506") # access rights statement
to_field 'description_tesim', extract_marc("520")
# to_field 'f588', extract_marc("588") # basis of description
#
# 650 4 	|a Sociology, General.
# 650 4 	|a Environmental Studies.
# 650 4 	|a Anthropology, Cultural.
to_field 'genre_ssim', extract_marc("655a")
# to_field 'genere_institution', extract_marc("655z")
to_field 'department_ssim', extract_marc("655x")
# to_field 'degree_grantor', extract_marc("710")
to_field 'fulltext_link_ssim', extract_marc("856")
# to_field 'f948', extract_marc("948")
to_field 'filename_ssim', extract_marc("956")

to_field 'read_access_group_ssim', literal('public') #TODO replace with isGovernedBy_ssim ?
to_field 'collection_label_ssim', literal('Electronic Theses and Dissertations')
