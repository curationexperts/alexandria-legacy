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

    # TODO Current indexer can't handle a string for author. It's expecting a URI
    attributes.delete('author')

    ## Delete entries that aren't in the schema yet
    attributes.delete('isbn')
    attributes.delete('published')
    attributes.delete('description')
    attributes.delete('advisor')
    attributes.delete('dissertation')
    attributes.delete('bibliography')
    attributes.delete('summary')
    attributes.delete('genre')
    attributes.delete('degree_grantor')
    attributes.delete('discipline')
    attributes.delete('fulltext_link')

    attributes[:files] = attributes.delete('filename')

    # attributes[:read_access_group] = 'public' #TODO replace with isGovernedBy_ssim
    attributes[:admin_policy_id] = AdminPolicy::PUBLIC_POLICY_ID

    # TODO get a real collection properties
    attributes[:collection] = { id: "etds", title: "Electronic Theses and Dissertations", accession_number: ['etds'] }

    build_object(attributes)
  end

  private

    def build_object(attributes)
      factory.new(attributes, Settings.proquest_directory).run
    end

    def factory
      Importer::Factory.for('ETD')
    end
end
