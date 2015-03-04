class ObjectFactory

  attr_reader :attributes, :files_directory

  def initialize(attributes, files_dir)
    @files_directory = files_dir
    @attributes = attributes
  end

  def run
    if obj = find
      obj.attributes = transform_attributes.except(:id)
      before_save(obj)
      obj.save!
      puts "  Updated #{klass.to_s.downcase} #{obj.id} (#{attributes[:accession_number].first})"
    else
      obj = create
      puts "  Created #{klass.to_s.downcase} #{obj.id} (#{attributes[:accession_number].first})"
    end
    after_save(obj)
    obj
  end

  # override after_save if you want to put something here.
  def after_save(obj)
  end

  # override before_save if you want to put something here.
  def before_save(obj)
  end

  # override after_create if you want to put something here.
  def after_create(obj)
  end

  def create_attributes
    transform_attributes
  end

  def find
    klass.find(attributes[:id]) if klass.exists?(attributes[:id])
  end

  def create
    attrs = create_attributes
    identifier = mint_ark
    attrs.merge!(identifier: [identifier.id], id: identifier.id.split(/\//).last)
    klass.new(attrs) do |obj|
      before_save(obj)
      obj.save!
      after_create(obj)
      identifier.target = path_for(obj)
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

  def find_or_create_contributors(fields, attrs)
    Hash.new.tap do |contributors|
      fields.each do |field|
        next unless attrs.key?(field)
        contributors[field] = []

        attributes[field].each do |value|
          if value.is_a?(RDF::URI)
            contributors[field] << value
          elsif value.is_a?(Hash)
            contributor = contributor_classes[value[:type]].where(foaf_name: value[:name]).first
            contributor ||= contributor_classes[value[:type]].create(foaf_name: value[:name])
            contributors[field] << RDF::URI.new(contributor.uri)
          end
        end
      end
    end
  end

  private

    def host
      Rails.application.config.host_name
    end

    def path_for(obj)
      "http://#{host}/lib/#{obj.ark}"
    end

    # Map the MODS name type to the correct model.
    # Example:
    # <mods:name type="personal">
    # A name with type="personal" should map to the Person model
    def contributor_classes
      { 'personal' => Person,
        'corporate' => Organization,
        'conference' => Group,
        'family' => Group }
    end

    def transform_attributes
      contributors = find_or_create_contributors(klass.contributor_fields, attributes)
      attributes.merge(contributors)
    end

end
