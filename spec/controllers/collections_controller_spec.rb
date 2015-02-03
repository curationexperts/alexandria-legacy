require 'rails_helper'

describe CollectionsController do
  describe "#index" do
    let!(:collection1) { create :collection }
    let!(:collection2) { create :collection }
    let!(:image) { create :image }
    let(:user) { create :user }

    before { sign_in user }

    it "should show a list of collections" do
      get :index
      expect(response).to be_successful
      expect(assigns[:document_list].map(&:id)).to eq [collection1.id, collection2.id]
    end
  end
end
