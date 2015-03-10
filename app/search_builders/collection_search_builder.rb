class CollectionSearchBuilder < Hydra::Collections::SearchBuilder
  include Hydra::PolicyAwareAccessControlsEnforcement
end
