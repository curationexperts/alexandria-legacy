class ZipfileService

  # @param [String] filename a partial filename
  # @return [String, NilClass] the name of the zipfile containing the filename
  def self.find_file_containing(filename)
    results = `for f in *.zip; do unzip -l $f | grep -q #{filename} && echo $f; done`
    results.chomp!
    results.empty? ? nil : results
  end

  # @param [String] file_path path of the file to extract from the zip file
  # @param [String] zip_path path to the zip file
  # @return [String] path to the extracted file
  def self.extract_single_file(file_path, zip_path)
    `unzip -j "#{zip_path}" "#{file_path}" -d "#{Dir.tmpdir}"`
    File.join(Dir.tmpdir, File.basename(file_path))
  end
end
