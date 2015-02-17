class Ability
  include Hydra::Ability

  # Define any customized permissions here.
  def custom_permissions
    can :read, ActiveFedora::Base

    if current_user.admin?
      can [:create, :update], [ActiveFedora::Base, SolrDocument]
      can [:create, :show, :add_user, :remove_user, :index], Role
    end
  end
end
