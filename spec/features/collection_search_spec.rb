require 'rails_helper'

feature 'Collection search page' do

  let!(:collection1) { create(:public_collection, title: 'Red') }
  let!(:collection2) { create(:public_collection, title: 'Pink') }

  let(:user) { create :user }

  before do
    AdminPolicy.ensure_admin_policy_exists
    sign_in user
  end

  scenario 'Search for something' do
    visit collections.collections_path
    fill_in 'q', with: "Pink"
    click_button 'Search'
    expect(page).to have_content "Pink"
    expect(page).not_to have_content "Red"
  end
end

