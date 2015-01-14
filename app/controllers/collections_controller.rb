class CollectionsController < ApplicationController
  include Hydra::CollectionsControllerBehavior
  include Blacklight::Catalog::SearchContext

  # Override rails path for the views
  # (Fixed a problem where the collection show page
  # won't display the list of members because
  # it can't find the partials.)
  def _prefixes
    @_prefixes ||= super + ['catalog']
  end

end
