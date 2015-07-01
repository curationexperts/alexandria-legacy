module Importer
  class CSVParser
    URI_FIELDS = ['lc_subject', 'language', 'form_of_work', 'institution', 'rights_holder', 'copyright_status', 'license'] + Metadata::MARCREL.keys.map(&:to_s)

    def initialize(file_name)
      @file_name = file_name
    end

    def each(&block)
      headers = nil
      CSV.foreach(@file_name) do |row|
        if headers
          yield 'Image', attributes(headers, row)
        else
          headers = row
        end
      end
    end

    private

      def attributes(headers, row)
        {}.tap do |processed|
          headers.each_with_index do |header, index|
            extract_field(header, row[index], processed)
          end
        end
      end

      def extract_field(header, val, processed)
        case header
          when 'title'
            # title is singular
            processed[:title] = val
          when 'created_start', 'created_finish', 'created_label', 'created_start_qualifier', 'created_end_qualifier'
            #TODO extract dates
          when 'files'
            processed[:files] ||= []
            processed[:files] << val if val
          when 'collection_id', 'collection_title', 'collection_accession_number'
            processed[:collection] ||= {}
            val = [val] if header == 'collection_accession_number'
            processed[:collection][header.gsub('collection_', '').to_sym] = val
          else
            # Everything else is multivalued
            processed[header.to_sym] ||= []
            processed[header.to_sym] << (URI_FIELDS.include?(header) ? RDF::URI(val.rstrip) : val)
        end
     end
  end
end
