require 'traject'
require File.expand_path('../config/environment', __FILE__)
Rails.application.eager_load!
AdminPolicy.ensure_admin_policy_exists
require 'object_factory_writer'
require 'traject/macros/marc_format_classifier'
require 'traject/macros/marc21_semantics'
require 'solrizer'
require_relative 'app/utils/identifier'
extend Traject::Macros::Marc21Semantics
extend Traject::Macros::MarcFormats

settings do
  provide 'writer_class_name', 'ObjectFactoryWriter'
  provide 'marc_source.type', 'xml'
  # Don't use threads. Workaround for https://github.com/fcrepo4/fcrepo4/issues/880
  provide 'processing_thread_pool', 0
end

ark_extractor = MarcExtractor.new('024a', separator: nil)

to_field 'identifier', lambda { |record, accumulator, context|
  fields = ark_extractor.extract(record).compact
  if fields.empty?
    puts 'No ARK, Skipping.'
    context.skip!
  else
    # TODO: update ARK to point at alexandria-v2?
    accumulator << fields.first
  end
}

to_field 'id', lambda { |_record, accumulator, context|
  accumulator << Identifier.ark_to_id(context.output_hash['identifier'].first)
}

to_field 'system_number', extract_marc('001', default: nil)
to_field 'language', marc_languages
to_field 'created_start', marc_publication_date
to_field 'isbn', extract_marc('020a', default: nil)
to_field 'title', extract_marc('245ab', trim_punctuation: true, default: nil)
to_field 'author', extract_marc('100a', trim_punctuation: true, default: nil)
to_field 'place_of_publication', extract_marc('264a', trim_punctuation: true, default: nil)
to_field 'publisher', extract_marc('264b', trim_punctuation: true, default: nil)
to_field 'issued', extract_marc('264c', trim_punctuation: true, default: nil)
to_field 'extent', extract_marc('300a', default: nil)
to_field 'dissertation_degree', extract_marc('502b', default: nil)
to_field 'dissertation_institution', extract_marc('502c', default: nil)
to_field 'dissertation_year', extract_marc('502d', trim_punctuation: true, default: nil)

# Names with relators, e.g. thesis advisor
to_field 'names',    extract_marc('720a')
to_field 'relators', extract_marc('720e', allow_duplicates: true)
to_field 'description', extract_marc('520a', default: nil)

to_field 'degree_grantor', extract_marc('710ab', trim_punctuation: true, default: nil)

extract856u = MarcExtractor.new('856u', separator: nil)
to_field 'fulltext_link', lambda { |record, accumulator|
  accumulator << extract856u.extract(record).grep(/proquest/).first
}

to_field 'filename', extract_marc('956f', default: nil)
