require 'rails_helper'

describe RecordsController do
  routes { HydraEditor::Engine.routes }
  let(:user) { create :admin }
  before { sign_in user }

  # Don't bother indexing this record (speeds up test)
  before { allow_any_instance_of(Image).to receive(:update_index) }

  describe "#update" do
    let(:image) { Image.create!(id: 'fk/4d/n4/9s/fk4dn49s80', creator_attributes: initial_creators) }

    context "Adding new creators" do
      let(:initial_creators) { [{id: "http://id.loc.gov/authorities/names/n87914041"}] }
      let(:contributor_attributes) { { "0" => { "id"=>"http://id.loc.gov/authorities/names/n87914041",
                                 "hidden_label"=>"http://id.loc.gov/authorities/names/n87914041"},
                        "1" => { "id"=>"http://id.loc.gov/authorities/names/n87141298",
                                 'predicate' => 'creator',
                                 "hidden_label"=>"http://dummynamespace.org/creator/"},
                        "2" => { "id"=>"",
                                 "hidden_label"=>"http://dummynamespace.org/creator/"},
                        } }

      it "adds creators" do
        patch :update, id: image, image: { contributor_attributes: contributor_attributes }
        expect(image.reload.creator_ids).to eq ["http://id.loc.gov/authorities/names/n87914041",
                                              "http://id.loc.gov/authorities/names/n87141298"]
      end
    end

    context "removing a creator" do

      let(:initial_creators) do
        [{ id: "http://id.loc.gov/authorities/names/n87914041" },
         { id: "http://id.loc.gov/authorities/names/n81019162" }]
      end

      let(:contributor_attributes) do
        {
          "0"=>{ "id"=>"http://id.loc.gov/authorities/names/n87914041", "_destroy"=>"" },
          "1"=>{ "id"=>"http://id.loc.gov/authorities/names/n81019162", predicate: 'creator', "_destroy"=>"true" },
          "2"=>{ "id"=>"", "_destroy"=>"" }
        }
      end

      it "removes creators" do
        patch :update, id: image, image: { contributor_attributes: contributor_attributes }
        expect(image.reload.creator_ids).to eq ["http://id.loc.gov/authorities/names/n87914041"]
      end
    end

    context "dates" do
      let(:ts_attributes) {
        {
          "start" => ["2014"],
          "start_qualifier" => [""],
          "finish" => [""],
          "finish_qualifier" => [""],
          "label" => [""],
          "note" => [""],
        }
      }

      let(:time_span) { TimeSpan.new(ts_attributes) }

      let(:initial_creators) { [{id: "http://id.loc.gov/authorities/names/n87914041"}] }

      context "created" do
        context "creating a new date" do
          it "persists the nested object" do
            patch :update, id: image, image: {
              created_attributes: { "0" => ts_attributes },
              creator_attributes: initial_creators
            }

            image.reload

            created_date = image.created.first

            expect(image.created.count).to eq(1)

            expect(created_date.start).to eq(["2014"])
            expect(created_date).to be_persisted
          end
        end

        context "when the created date already exists" do
          before do
            time_span.save!
            image.created << time_span
            image.save!
          end

          it "allows deletion of the existing timespan" do
            image.reload
            expect(image.created.count).to eq(1)

            patch :update, id: image, image: {
              creator_attribues: initial_creators,
              created_attributes: {
                "0" => { id: time_span.id, _destroy: "true" }
              }
            }

            image.reload

            expect(image.created.count).to eq(0)
          end

          it "allows updating the existing timespan" do
            patch :update, id: image, image: {
              created_attributes: {
                "0" => ts_attributes.merge(id: time_span.id, start: ["1337"], start_qualifier: ["approximate"])
              },
              creator_attributes: initial_creators
            }

            image.reload

            expect(image.created.count).to eq(1)

            created_date = image.created.first

            expect(created_date.id).to eq(time_span.id)
            expect(created_date.start).to eq(["1337"])
            expect(created_date.start_qualifier).to eq(["approximate"])
          end
        end
      end
    end
  end
end
