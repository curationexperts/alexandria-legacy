class ObjectFactory

  attr_reader :attributes, :files_directory

  def initialize(attributes, files_dir)
    @files_directory = files_dir
    @attributes = attributes
  end

  def run
    if obj = find
      obj.update(attributes.except(:id))
      puts "  Updated #{klass.to_s.downcase} #{obj.id} (#{attributes[:accession_number].first})"
    else
      obj = create
      after_create(obj)
      puts "  Created #{klass.to_s.downcase} #{obj.id} (#{attributes[:accession_number].first})"
    end
    after_save(obj)
    obj
  end

  # override after_save if you want to put something here.
  def after_save(obj)
  end

  # override after_create if you want to put something here.
  def after_create(obj)
  end

  def create_attributes
    attributes
  end

  def find
    klass.find(attributes[:id]) if klass.exists?(attributes[:id])
  end

  def create
    attrs = create_attributes
    identifier = mint_ark
    attrs.merge!(identifier: [identifier.id], id: identifier.id.split(/\//).last)
    klass.create(attrs) do |object|
      identifier.target = path_for(object)
      identifier.save
    end
  end

  def klass
    raise "You must implement the klass method"
  end

  # @return [Ezid::Identifier] the new identifier
  def mint_ark
    Ezid::Identifier.create
  end

  private

    def host
      Rails.application.config.host_name
    end

    def path_for(obj)
      "http://#{host}/catalog/#{obj.ark}"
    end
end
