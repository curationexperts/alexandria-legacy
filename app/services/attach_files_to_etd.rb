class AttachFilesToETD

  def self.run(etd, file_names)
    service = AttachFilesToETD.new(etd)
    file_names.each do |file_name|
      zip_path = ZipfileService.find_file_containing(file_name)
      next unless zip_path
      service.attach_contents_of_zipfile(zip_path)
    end
  end

  attr_reader :etd

  def initialize(etd)
    @etd = etd
  end

  def attach_contents_of_zipfile(zip_path)
    files = ZipfileService.extract_files(zip_path)

    attach_proquest(files['xml'])
    attach_original(files['pdf'])
    # TODO
    # attach_supplementals(files['pdf'])
  end

  private

    def attach_original(path)
      etd.generic_files.create do |gf|
        puts "  Attaching binary #{path}"
        gf.original.mime_type = 'application/pdf'
        gf.original.original_name = File.basename(path)
        gf.original.content = File.new(path)
      end
    end

    def attach_proquest(path)
      etd.proquest.mime_type = 'application/xml'
      etd.proquest.original_name = File.basename(path)
      etd.proquest.content = File.new(path)
    end
end
