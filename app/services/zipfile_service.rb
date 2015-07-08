class ZipfileService

  # @param [String] filename a partial filename
  # @return [String, NilClass] the name of the zipfile containing the filename
  def self.find_file_containing(filename)
    results = `for f in #{wildcard_zip}; do unzip -l $f | grep -q #{filename} && echo $f; done`
    results.chomp!
    results.empty? ? nil : results
  end

  # TODO there may be more than one PDF file to be returned. There is an original
  # and optional supplemental files
  # @param [String] zip_path path to the zip file
  # @return [Hash] paths to the extracted files, keyed by extension
  def self.extract_files(zip_path)
    output = `unzip -j "#{zip_path}" -d "#{Dir.tmpdir}"`
    output.split("\n").grep(/inflating/).each_with_object({}) do |line, h|
      filename = line.gsub(/\s*inflating: /, '').rstrip
      h[File.extname(filename).split('.').last] = filename

    end
  end

  private

    # @return [String] a pattern for seaching the zip files.
    def self.wildcard_zip
      File.join(Shellwords.escape(Settings.proquest_directory), '*.zip')
    end

end
