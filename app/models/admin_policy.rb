module AdminPolicy
  PUBLIC_POLICY_ID = 'authorities/policies/public'.freeze

  def self.ensure_admin_policy_exists
    unless Hydra::AdminPolicy.exists?(PUBLIC_POLICY_ID)
      public_policy = Hydra::AdminPolicy.create(id: PUBLIC_POLICY_ID, title: ['Public Access'])
      public_policy.default_permissions.build(type: "group", name: "public", access: "read")
      public_policy.save!
    end
  end
end
