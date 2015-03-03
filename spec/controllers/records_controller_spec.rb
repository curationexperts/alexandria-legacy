require 'rails_helper'

describe RecordsController do
  routes { HydraEditor::Engine.routes }
  let(:user) { create :admin }
  before { sign_in user }

  # Don't bother indexing this record (speeds up test)
  before { allow_any_instance_of(Image).to receive(:update_index) }

  describe "#update" do
    let(:image) { Image.create!(id: '7', creator_attributes: initial_creators) }

    context "Adding new creators" do
      let(:initial_creators) { [{id: "http://id.loc.gov/authorities/names/n87914041"}] }
      let(:creator_attributes) { { "0" => { "id"=>"http://id.loc.gov/authorities/names/n87914041",
                                 "hidden_label"=>"http://id.loc.gov/authorities/names/n87914041"},
                        "1" => { "id"=>"http://id.loc.gov/authorities/names/n87141298",
                                 "hidden_label"=>"http://dummynamespace.org/creator/"},
                        "2" => { "id"=>"",
                                 "hidden_label"=>"http://dummynamespace.org/creator/"},
                        } }

      it "adds creators" do
        patch :update, id: image, image: { creator_attributes: creator_attributes }
        expect(image.reload.creator_ids).to eq ["http://id.loc.gov/authorities/names/n87914041",
                                              "http://id.loc.gov/authorities/names/n87141298"]
      end
    end

    context "removing a creator" do

      let(:initial_creators) do
        [{ id: "http://id.loc.gov/authorities/names/n87914041" },
         { id: "http://id.loc.gov/authorities/names/n81019162" }]
      end

      let(:creator_attributes) do
        {
          "0"=>{ "id"=>"http://id.loc.gov/authorities/names/n87914041", "_destroy"=>"" },
          "1"=>{ "id"=>"http://id.loc.gov/authorities/names/n81019162", "_destroy"=>"true" },
          "2"=>{ "id"=>"", "_destroy"=>"" }
        }
      end

      it "removes creators" do
        patch :update, id: image, image: { creator_attributes: creator_attributes }
        expect(image.reload.creator_ids).to eq ["http://id.loc.gov/authorities/names/n87914041"]
      end
    end
  end
end
