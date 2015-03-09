require 'factory_girl'

FactoryGirl.define do
  factory :image do
    factory :public_image do
      before(:create) { AdminPolicy::ensure_admin_policy_exists }
      admin_policy_id AdminPolicy::PUBLIC_POLICY_ID
    end
  end
end
