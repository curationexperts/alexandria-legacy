require 'spec_helper'
require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  subject { ability }
  let(:ability) { Ability.new(user) }
  let(:image) { Image.create! }

  context 'for a normal user' do
    let(:user) { User.new }

    it {
      is_expected.to be_able_to(:read, image)

      is_expected.not_to be_able_to(:create, Image)
      is_expected.not_to be_able_to(:update, image)
      is_expected.not_to be_able_to(:destroy, image)
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
    }
  end
end
