require 'rails_helper'

describe RecordsController do
  routes { HydraEditor::Engine.routes }
  let(:user) { create :admin }
  before { sign_in user }

  describe "#update" do
    let(:image) { Image.create!(id: '7') }
    context "Adding new creators" do
      let(:creator) { { "0" => { "id"=>"http://id.loc.gov/authorities/names/n87914041",
                                 "hidden_label"=>"http://id.loc.gov/authorities/names/n87914041"},
                        "1" => { "id"=>"http://id.loc.gov/authorities/names/n87141298",
                                 "hidden_label"=>"http://dummynamespace.org/creator/"} } }
      it "should add creators" do
        patch :update, id: image, image: { creator_attributes: creator }
        expect(image.reload.creator.size).to eq 2
      end
    end
  end
end
