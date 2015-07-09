module BlacklightUrlHelper
  include Blacklight::UrlHelperBehavior

  def url_for_document doc, options = {}
    return unless doc
    case Array(doc['has_model_ssim']).first
    when 'Collection'
      collections.collection_path(doc)
    when 'Image', 'ETD'
      ark_path(doc.ark.html_safe)
    else
      super
    end
  end

  # we're using our own helper rather than the generated route helper because the
  # default helper escapes slashes. https://github.com/rails/rails/issues/16058
  def ark_path(ark)
    "/lib/#{ark}"
  end

  def track_collection_path(*args)
    track_solr_document_path(*args)
  end

end
