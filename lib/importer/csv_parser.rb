module Importer
  class CSVParser
    include Enumerable
    URI_FIELDS = ['lc_subject', 'language', 'form_of_work', 'institution', 'rights_holder', 'copyright_status', 'license'] + Metadata::MARCREL.keys.map(&:to_s)

    def initialize(file_name)
      @file_name = file_name
    end

    # @yieldparam attributes [Hash] the attributes from one row of the file
    def each(&block)
      headers = nil
      CSV.foreach(@file_name) do |row|
        if headers
          yield attributes(headers, row)
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
        return unless val
        case header
          when 'title'
            # title is singular
            processed[:title] = val
          when /^(created|issued|date_copyrighted|date_valid)_(.*)$/
            key = "#{$1}_attributes".to_sym
            # TODO this only handles one date of each type
            processed[key] ||= [{}]
            update_date(processed[key].first, $2, val)
          when 'note_value', 'note_type'
            $stderr.puts "Note property: #{header} => #{val}"

            #TODO extract notes
          when 'files'
            processed[:files] ||= []
            processed[:files] << val if val
          when /^collection_(.*)$/
            processed[:collection] ||= {}
            update_collection(processed[:collection], $1, val)
          when 'finding_aid'
            # TODO I don't know what this is for. Either we need to add it to the data model, or it should not appear in (collection) CSVs
            $stderr.puts "Ignoring unknown property: #{header} => #{val}"
          else
            # Everything else is multivalued
            processed[header.to_sym] ||= []
            processed[header.to_sym] << (URI_FIELDS.include?(header) ? RDF::URI(val.rstrip) : val)
        end
     end

     def update_collection(collection, field, val)
       val = [val] if field == 'accession_number'
       collection[field.to_sym] = val
     end

     def update_date(date, field, val)
       date[field.to_sym] ||= []
       date[field.to_sym] << val
     end
  end
end
