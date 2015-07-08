module Importer::Factory
  class ETDFactory < ObjectFactory
    include WithAssociatedCollection

    def klass
      ETD
    end

    def after_create(etd)
      return unless files_directory

      # TODO move to background job
      AttachFilesToETD.run(etd, attributes[:files])
      etd.save # force a reindex after the files are created
    end

    def log_created(obj)
      puts "  Created #{klass.to_s.downcase} #{obj.id} (#{attributes[:system_number].first})"
    end

    def log_updated(obj)
      puts "  Updated #{klass.to_s.downcase} #{obj.id} (#{attributes[:system_number].first})"
    end
  end
end
