class AttachFilesToETD

  def self.run(etd, pdf_file_name)
    AttachFilesToETD.new(etd, pdf_file_name).run
  end

  attr_reader :etd, :pdf_file_name

  def initialize(etd, pdf_file_name)
    @etd = etd
    @pdf_file_name = pdf_file_name
  end

  def run
    files = zip_service.extract_files
    return unless files

    attach_proquest(files.proquest) if files.proquest
    attach_original(files.pdf) if files.pdf
    # TODO
    # attach_supplementals(files.supplemental)
  end


  private


    def zip_service
      @zip_service ||= ZipfileService.new(pdf_file_name)
    end

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
