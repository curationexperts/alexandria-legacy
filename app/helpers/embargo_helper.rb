module EmbargoHelper

  # Because we're storing admin policies in the embargos, we need to lookup the object.
  def after_visibility(curation_concern)
    id = ActiveFedora::Base.uri_to_id(curation_concern.visibility_after_embargo.id)
    Hydra::AdminPolicy.find(id).title
  end

  # TODO this is slow and could be cached.
  def visibility_options(_)
    Hydra::AdminPolicy.all
  end
end
