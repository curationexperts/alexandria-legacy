class Ability
  include Hydra::Ability

  # Define any customized permissions here.
  def custom_permissions
    can :read, ActiveFedora::Base

    if current_user.admin?
      can [:create, :update], [ActiveFedora::Base, SolrDocument]
    end
  end
end
