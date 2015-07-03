module Importer::Factory
  class ETDFactory < ObjectFactory
    include WithAssociatedCollection

    def klass
      ETD
    end

    def after_create(etd)
      # TODO move to background job
      # TODO call FindZipfileService.find_file_containing(filename)
      if files_directory
        attributes[:files].each do |file_name|
          zip_path = ZipfileService.find_file_containing(file_name)
          next unless zip_path
          path = ZipfileService.extract_file_from_zip(file_name, zip_path)

          #create_file(etd, file_path)
          etd.generic_files.create do |gf|
            puts "  Attaching binary #{file_name}"
            gf.original.mime_type = 'application/pdf'
            gf.original.original_name = File.basename(path)
            gf.original.content = File.new(path)
          end
        end
        etd.save # force a reindex after the files are created
      end
    end
  end
end
