require 'spec_helper'
require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  subject { ability }
  let(:ability) { Ability.new(user) }
  let(:image) { Image.create! }
  let(:local_group) { create(:group) }

  context 'for a normal user' do
    let(:user) { User.new }

    it {
      is_expected.to be_able_to(:read, image)

      is_expected.not_to be_able_to(:create, Image)
      is_expected.not_to be_able_to(:update, image)
      is_expected.not_to be_able_to(:destroy, image)

      is_expected.not_to be_able_to(:read, :local_authorities)
      is_expected.not_to be_able_to(:destroy, :local_authorities)

      is_expected.not_to be_able_to(:new_merge, local_group)
      is_expected.not_to be_able_to(:merge, local_group)
    }
  end

  context 'for an admin user' do
    let(:user) { create(:admin) }

    it {
      is_expected.to be_able_to(:read, image)
      is_expected.to be_able_to(:create, Image)
      is_expected.to be_able_to(:update, image)
      is_expected.to be_able_to(:update, SolrDocument.new)

      is_expected.not_to be_able_to(:destroy, image)

      is_expected.to be_able_to(:read, :local_authorities)
      is_expected.to be_able_to(:destroy, :local_authorities)

      is_expected.to be_able_to(:new_merge, local_group)
      is_expected.to be_able_to(:merge, local_group)
    }
  end
end
