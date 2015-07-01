module Importer
  class CSVImporter
    def initialize(files_directory, metadata_file)
      AdminPolicy.ensure_admin_policy_exists
      @files_directory = files_directory
      @metadata_file = metadata_file
    end

    def import_all
      parser = CSVParser.new(@metadata_file)
      count = 0
      parser.each do |model, attributes|
        create_fedora_objects(model, attributes.merge(admin_policy_id: AdminPolicy::PUBLIC_POLICY_ID))
        # TODO need to get the file to import too.
        count += 1
      end
      count
    end


    # Select a factory to create the objects in fedora.
    # For example, if we are importing a MODS record for an
    # image, the ModsParser will return an Image model, so
    # we'll select the ImageFactory to create the fedora
    # objects.
    def create_fedora_objects(model, attributes)
      object_factory = (model.to_s + "Factory").constantize
      object_factory.new(attributes, @files_directory).run
    end


  end
end
