class Image < ActiveFedora::Base
  include Hydra::Works::WorkBehavior
  include Metadata
  include NestedAttributes
  include LocalAuthorityHashAccessor
  include HumanReadableType
  self.human_readable_type = "Image"

  include Hydra::AccessControls::Embargoable
  include EmbargoBehavior

  has_and_belongs_to_many :issued, predicate: ::RDF::DC.issued, class_name: 'TimeSpan', inverse_of: :issued_images

  has_and_belongs_to_many :date_copyrighted, predicate: ::RDF::DC.dateCopyrighted, class_name: 'TimeSpan', inverse_of: :date_copyrighted_images

  accepts_nested_attributes_for :issued, reject_if: :time_span_blank, allow_destroy: true
  accepts_nested_attributes_for :date_copyrighted, reject_if: :time_span_blank, allow_destroy: true

  validates_vocabulary_of :rights_holder
  validates_vocabulary_of :form_of_work

  def self.indexer
    ImageIndexer
  end

  def to_param
    Identifier.noidify(id)
  end

  # When a collection of these are rendered, which partial should be used
  def to_partial_path
    'catalog/document'
  end
end
