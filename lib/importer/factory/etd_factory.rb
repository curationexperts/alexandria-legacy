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
        puts "filedir set"
        attributes[:files].each do |file_name|
          puts "looking for #{file_name}"
          zip_path = ZipfileService.find_file_containing(file_name)
          next unless zip_path
          files = ZipfileService.extract_files(zip_path)

          #create_file(etd, file_path)
          etd.generic_files.create do |gf|
            puts "  Attaching binary #{files['pdf']}"
            gf.original.mime_type = 'application/pdf'
            gf.original.original_name = File.basename(files['pdf'])
            gf.original.content = File.new(files['pdf'])
          end


          etd.proquest.mime_type = 'application/xml'
          etd.proquest.original_name = File.basename(files['xml'])
          etd.proquest.content = File.new(files['xml'])
        end
        etd.save # force a reindex after the files are created
        puts "Done with save"
      else
        puts "no files dir"
      end
    end

    def log_created(obj)
      puts "  Created #{klass.to_s.downcase} #{obj.id} (#{attributes[:system_number].first})"
    end
  end
end
