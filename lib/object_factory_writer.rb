require 'importer'
require 'traject'
# require 'traject/util'
# require 'traject/qualified_const_get'

class ObjectFactoryWriter
  # include Traject::QualifiedConstGet

  # The passed-in settings
  attr_reader :settings

  def initialize(argSettings)
    @settings = Traject::Indexer::Settings.new(argSettings)
  end

  def serialize(context)
    # null
  end

  def close
    puts "closing"
    # null
  end

  # Add a single context to fedora
  def put(context)
    attributes = context.output_hash.with_indifferent_access

    # created date is a TimeSpan
    created = attributes.delete('created_start')
    attributes[:created_attributes] = [{ start: created }] if created

    # title must be singular
    title = attributes.delete('title')
    attributes[:title] = title.first
    attributes[:id] = attributes.delete('id').first

    # Delete entries that aren't in the schema yet
    attributes.delete('published')
    attributes.delete('description')
    attributes.delete('dissertation')
    attributes.delete('bibliography')
    attributes.delete('summary')
    attributes.delete('genre')
    attributes.delete('degree_grantor')
    attributes.delete('discipline')
    attributes.delete('fulltext_link')

    attributes[:files] = attributes.delete('filename')

    # When we first create an ETD, we might not yet have the
    # metadata from ProQuest that contains the access and
    # embargo data.  Since we don't know whether or not this
    # ETD is under embargo, we'll assume the most strict
    # access level.  This policy might change later when the
    # ProQuest metadata gets imported.
    attributes[:admin_policy_id] = AdminPolicy::ADMIN_USER_POLICY_ID

    # TODO get a real collection properties
    attributes[:collection] = { id: "etds", title: "Electronic Theses and Dissertations", accession_number: ['etds'] }

    attributes.merge!(parse_relators(attributes.delete('names'), attributes.delete('relators')))

    build_object(attributes)
  end

  private

    def build_object(attributes)
      factory.new(attributes, Settings.proquest_directory).run
    end

    def factory
      Importer::Factory.for('ETD')
    end

    # @param [Array] names : a list of names
    # @param [Array] relators : a list of roles that correspond to those names
    # @return [Hash] relator fields
    # Example:
    #     name = ['Paul J. Atzberger', 'Frodo Baggins']
    #     relators = ['degree supervisor.', 'adventurer']
    # will return the thesis advisor:
    #     { degree_supervisor: ['Paul J. Atzberger'] }
    def parse_relators(names, relators)
      fields = {}

      ds = names.find_all.with_index { |_, index| relators[index].match(/degree supervisor/i) }
      fields[:degree_supervisor] = ds unless ds.blank?

      fields
    end

end
