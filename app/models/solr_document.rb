# -*- encoding : utf-8 -*-
class SolrDocument

  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument


  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Document::Email )

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)
  use_extension(ExportAsTurtle)

  ##
  # Offer the source (ActiveFedora-based) model to Rails for some of the
  # Rails methods (e.g. link_to).
  # @example
  #   link_to '...', SolrDocument(id: 'bXXXXXX5').new => <a href="/dams_object/bXXXXXX5">...</a>
  def to_model
    @model ||= if curation_concern?
                 ActiveFedora::Base.load_instance_from_solr(id, self)
               else
                 super
               end
  end

  # Something besides a local authority
  def curation_concern?
    case self.fetch('has_model_ssim').first
    when Collection.to_class_uri, Image.to_class_uri, ETD.to_class_uri
      true
    else
      false
    end
  end

  # blank if there is no embargo or the embargo status
  def after_embargo_status
    return if self['visibility_after_embargo_ssim'].blank?
    date = Date.parse self['embargo_release_date_dtsi']
    policy = AdminPolicy.find(self['visibility_after_embargo_ssim'].first)
    " - Becomes #{policy} on #{date.to_s(:us)}"

  end

  def etd?
    self['has_model_ssim'] == [ETD.to_class_uri]
  end

  def admin_policy_id
    fetch('isGovernedBy_ssim').first
  end

  def to_param
    Identifier.ark_to_noid(ark) || Identifier.noidify(id)
  end

  def ark
    Array(self[Solrizer.solr_name('identifier', :displayable)]).first
  end

  def generic_files
    @generic_files ||= begin
      if ids = self['generic_file_ids_ssim']
        load_generic_files(ids)
      else
        []
      end
    end
  end

  private

    def load_generic_files(ids)
      docs = ActiveFedora::SolrService.query("{!terms f=id}#{ids.join(',')}").map { |res| SolrDocument.new(res) }
      ids.map { |id| docs.find { |doc| doc.id == id } }
    end
end
