require 'rails_helper'

RSpec.describe "welcome/index.html.erb", :type => :view do

  it 'has a link to search for ETDs' do
    render
    expect(rendered).to have_link 'electronic theses and dissertations', href: catalog_index_path('f[object_type_sim][]' => 'Thesis or dissertation')
  end

end
