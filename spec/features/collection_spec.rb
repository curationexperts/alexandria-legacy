require 'rails_helper'

RSpec.feature 'Collection show page:', :type => :feature do

  let(:red_attrs)  {{ title: 'Red',
                      publisher: ['Colors Pub', 'Red Pub'] }}
  let(:pink_attrs) {{ title: 'Pink',
                      publisher: ['Colors Pub', 'Pink Pub'] }}

  let(:colors_attrs) {{ title: 'Colors' }}
  let(:colors) { create_collection_with_images(colors_attrs, [red_attrs, pink_attrs]) }

  let(:user) { create :user }

  before {
    sign_in user 
    colors
  }

  scenario 'Use facets to browse collection members' do
    visit collections.collection_path(colors)
    expect(page).to have_content red_attrs[:title]
    expect(page).to have_content pink_attrs[:title]

    within('#facets #facet-publisher_sim') do
      click_link 'Colors Pub'
    end
    expect(page).to have_content red_attrs[:title]
    expect(page).to have_content pink_attrs[:title]

    within('#facets #facet-publisher_sim') do
      click_link 'Pink Pub'
    end
    expect(page).to_not have_content red_attrs[:title]
    expect(page).to     have_content pink_attrs[:title]
  end

end
