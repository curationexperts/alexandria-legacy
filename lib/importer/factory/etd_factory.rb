module Importer::Factory
  class ETDFactory < ObjectFactory
    include WithAssociatedCollection

    def klass
      ETD
    end

    def update(obj)
      update_created_date(obj)
      super
    end

    def after_create(etd)
      return unless files_directory

      Rails.logger.warn "Files for etd #{etd.id} were: #{attributes[:files]}, expected only 1" unless attributes[:files].size == 1

      # TODO move to background job
      AttachFilesToETD.run(etd, attributes[:files].first)
      etd.save # force a reindex after the files are created
    end

    def log_created(obj)
      puts "  Created #{klass.to_s.downcase} #{obj.id} (#{attributes[:system_number].first})"
    end

    def log_updated(obj)
      puts "  Updated #{klass.to_s.downcase} #{obj.id} (#{attributes[:system_number].first})"
    end

private

    def update_created_date(obj)
      return if attributes[:created_attributes].blank?

      new_date = Array(attributes.fetch(:created_attributes)).first.fetch(:start, nil)
      return unless new_date

      existing_date = obj.created.flat_map(&:start)

      if existing_date == new_date
        attributes.delete(:created_attributes)
      else
        obj.created.clear  # to be replaced by new date
      end
    end

  end
end
