require 'tmpdir'
module Importer
  module ETDImporter
    def self.write_marc_file(zipfiles, output_file)
      marcs = find_marc_for_zipfiles(zipfiles)

      File.open(output_file, 'w') do |f|
        f.write <<-EOS
<?xml version="1.0"?>
<zs:searchRetrieveResponse xmlns:zs="http://www.loc.gov/zing/srw/"><zs:version>1.1</zs:version><zs:numberOfRecords>#{marcs.count}</zs:numberOfRecords><zs:records>
      EOS
        f.write marcs.join("\n")
        f.write('</zs:records></zs:searchRetrieveResponse>')

        puts "Wrote MARC metadata to #{output_file}"
      end
    end

    private

      # @param [String] zipfile The path to the .zip file
      #
      # @return [Array]
      def self.unzip(zipfile, dest)
        unless File.exist?("#{Settings.proquest_directory}/#{File.basename(zipfile)}")
          FileUtils.cp zipfile, Settings.proquest_directory
          puts "Copied zipfiles to #{Settings.proquest_directory}"
        end

        xml ||= []
        system 'unzip', '-o', zipfile, '-d', dest

        Dir.glob("#{dest}/**/*.xml") do |x|
          puts "Found #{x}"
          xml << x
        end

        xml
      end

      def self.extract_binary_filename(xml_file_name)
        Nokogiri::XML(File.open(xml_file_name)).css('DISS_binary').children.first.to_s
      end

      def self.query_pegasus(binary_filename)
        search = Curl::Easy.perform("http://pegasus.library.ucsb.edu:5661/sba01pub?version=1.1&operation=searchRetrieve&maximumRecords=1&startRecord=1&query=(marc.947.a=pqd%20and%20marc.956.f=#{binary_filename})")
        result = search.body_str
        return false unless result.include?('zs:numberOfRecords>1')
        search.body_str
      end

      PAYLOAD_HEADER = "<?xml version=\"1.0\"?>\n<zs:searchRetrieveResponse xmlns:zs=\"http://www.loc.gov/zing/srw/\"><zs:version>1.1</zs:version><zs:numberOfRecords>1</zs:numberOfRecords><zs:records>".freeze
      PAYLOAD_FOOTER = '</zs:records></zs:searchRetrieveResponse>'.freeze

      def self.strip_wrapper(payload)
        payload.sub(PAYLOAD_HEADER, '').sub(PAYLOAD_FOOTER, '')
      end

      def self.parse_file(xml_file_name)
        binary_filename = extract_binary_filename(xml_file_name)
        result = query_pegasus(binary_filename)
        if !result
          $stderr.puts "Error: failed to retrieve record for #{binary_filename}"
        else
          strip_wrapper(result)
        end
      end

      def self.find_marc_for_zipfiles(zipfiles)
        Dir.mktmpdir do |temp|
          zipfiles
            .map { |f| unzip(f, temp) }
            .flatten.uniq
            .map { |x| parse_file(x) }
        end
      end
  end
end
