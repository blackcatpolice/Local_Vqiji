class Ability
  include CanCan::Ability

  def initialize(user)
    admin = Admin.get(user.id)
    if user.name
      #
      can :index,   Store::Product
      can :new,     Store::Product
      can :create,  Store::Product
      can :edit,    Store::Product
      can :update,  Store::Product
      can :destroy, Store::Product
      #
      can :index,   Store::ProductType
      can :new,     Store::ProductType
      can :create,  Store::ProductType
      can :edit,    Store::ProductType
      can :update,  Store::ProductType
      can :destroy, Store::ProductType
      #
      can :index,   Store::Order
      can :show,    Store::Order
      can :destroy, Store::Order
      can :update,  Store::Order
    end
    
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
