module BlacklightUrlHelper
  include Blacklight::UrlHelperBehavior

  def url_for_document doc, options = {}
    if doc && doc['has_model_ssim'] == ['Collection']
      collections.collection_path(doc.id)
    else
      super
    end
  end
end
