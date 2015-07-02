require 'traject'
require File.expand_path('../config/environment',  __FILE__)
Rails.application.eager_load!
AdminPolicy.ensure_admin_policy_exists
require 'object_factory_writer'
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
  provide "writer_class_name", "ObjectFactoryWriter"
  # provide "writer_class_name", "Traject::JsonWriter"
  # TODO use the solr.yml
  # provide "solr.url", "http://localhost:8983/solr/development"
  # provide "solr_writer.commit_on_close", "true"
end

# These are the tags in the file
#["005", "006", "007", "008", "020", "035", "040", "100", "245", "264", "300", "336", "337", "338", "500", "502", "520", "546", "653", "650", "655", "710", "720", "791", "792", "856", "852", "946", "947", "948", "956", "001"]
#
# Find a record with an ark
# reader = MARC::Reader.new('/Users/justin/workspace/ucsb_sample_data/etd_20150612.mrc')
# record3 = reader.find { |record| record.fields.any? { |f| f.tag == '856' && f.subfields.any? { |sf| sf.code == 'u' && /alexandria/.match(sf.value) } }  }
#  => http://alexandria.ucsb.edu/lib/ark:/48907/f3dv1h0q
#
#
# see http://alexandria.ucsb.edu/catalog/adrl:f3000017
# to_field 'last_transaction_datetime', extract_marc("005")
# to_field 'Fixed-Length Data Elements', extract_marc("006")
# to_field 'f007', extract_marc("007")
# to_field 'f008', extract_marc("008")
# to_field "language_code", extract_marc("008[35-37]")
to_field "language", marc_languages
to_field "created_start", marc_publication_date

to_field 'isbn', extract_marc("020")

ark_extractor = MarcExtractor.new("856u", :separator => nil)

to_field 'identifier', lambda { |record, accumulator, context|
  fields = ark_extractor.extract(record).map do |field|
    ark_from_alexandria_uri(field)
  end.compact
  if fields.empty?
    #puts "No ARK, Skipping."
    context.skip! # TODO mint an ark instead of skiping the record
  else
    # TODO update ARK to point at alexandria-v2?
    accumulator << fields.first
  end
}

to_field 'id', lambda { |record, accumulator, context|
  accumulator << Identifier.ark_to_id(context.output_hash['identifier'].first)
}

# to_field "format_s", marc_formats
# to_field 'active_fedora_model_ssi', literal("Thesis or dissertation")
# to_field 'form_of_work_label_tesim', literal("Thesis or dissertation")
# to_field 'has_model_ssim', literal("Etd")

to_field 'title', extract_marc("245a", trim_punctuation: true)
# TODO 245c is the statment of responsibility. Per call on 2015-6-17
#
# TODO embargo and open access status come from XML from proquest.
#    linked on the pdf name in the marc record (contained in the proquest zip file)
#
# TODO there are two versions of proquest xml files with different ways of encoding embargos
#    Spring 2014 change over date.
#
# TODO we need to extract the pdf names from the directory of zip files so that we can match marc records (pdf name) to zip file.
#
#
# to_field 'broad_subject',     marc_lcc_to_broad_category
# to_field "geographic_facet",  marc_geo_facet
#
to_field 'author', extract_marc("100a", trim_punctuation: true)
# to_field 'title', extract_marc("245") # also has statement of responsibility, needs to strip type
# to_field 'filing_version', extract_marc_filing_version # title with statement of responsibility stripped, but still has colin and slashes


to_field 'published', extract_marc("264", trim_punctuation: true)
to_field 'description', extract_marc("300")
to_field 'advisor', extract_marc("500") # and committee members
to_field 'dissertation', extract_marc("502")
to_field 'bibliography', extract_marc("504")



# to_field 'f506', extract_marc("506") # access rights statement
to_field 'summary', extract_marc("520")
# to_field 'f588', extract_marc("588") # basis of description

#
# 650 4 	|a Sociology, General.
# 650 4 	|a Environmental Studies.
# 650 4 	|a Anthropology, Cultural.
#
to_field 'keyword_ssim', extract_marc("653") #Test this when we have records that have keywords and ark.

extract655a = MarcExtractor.new("655a", :separator => nil)
extract655zx = MarcExtractor.new("655zx", :separator => ' -- ')
to_field "genre", lambda { |record, accumulator|
  values = [extract655a.extract(record).map { |s| Traject::Macros::Marc21.trim_punctuation(s) }.join(' : ')]
  values << extract655zx.extract(record)
  accumulator << values.join(' -- ')
}

to_field 'degree_grantor', extract_marc("710ab")
to_field 'discipline', extract_marc('650')
to_field 'fulltext_link', extract_marc("856u")
# to_field 'f948', extract_marc("948")
to_field 'filename', extract_marc("956f")

# to_field 'read_access_group', literal('public') #TODO replace with isGovernedBy_ssim ?
# to_field 'collection_label', literal('Electronic Theses and Dissertations')
