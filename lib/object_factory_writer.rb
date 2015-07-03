require 'importer'
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
    # null
  end

  # Add a single context to fedora
  def put(context)
    attributes = context.output_hash

    # created date is a TimeSpan
    created = attributes.delete('created_start')
    attributes[:created_attributes] = [{start: created}] if created

    # title must be singular
    title = attributes.delete('title')
    attributes[:title] = title.first

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

    # TODO ObjectFactory requires an accession number, but maybe it shouldn't
    attributes[:accession_number] = []

    Importer::Factory.for('ETD').new(attributes, Settings.etd_download_root).run
  end
end
