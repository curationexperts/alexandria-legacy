require 'rails_helper'
require 'importer'
describe Importer::Factory::ETDFactory do
  let(:factory) { described_class.new(attributes, Settings.proquest_directory) }
  let(:collection_attrs) { { accession_number: ["etds"] } }

  let(:attributes) do
    {
      id: 'f3/gt/5k/61/f3gt5k61',
      collection: collection_attrs, files: [], created_attributes: [{ start: [2014] }],
      system_number: ['123'],
      author: ['Valerie'],
      identifier: ['ark:/48907/f3gt5k61']
    }.with_indifferent_access
  end

  # squelch output
  before { allow($stdout).to receive(:puts) }

  context "when a collection already exists" do
    let!(:coll) { Collection.create(collection_attrs) }

    it "should not create a new collection" do
      expect(coll.members.count).to eq 0
      obj = nil
      expect {
        obj = factory.run
      }.to change { Collection.count }.by(0)
      expect(coll.reload.members.count).to eq 1
      expect(coll.members.first).to be_instance_of ETD
      expect(obj.id).to eq 'f3/gt/5k/61/f3gt5k61'
      expect(obj.system_number).to eq ['123']
      expect(obj.identifier).to eq ['ark:/48907/f3gt5k61']
      expect(obj.author).to eq ['Valerie']
    end
  end


  describe "after_create" do
    let(:attributes) do
      { files: ["Plunkett_ucsb_0035D_11862.pdf"] }
    end
    let(:etd) { ETD.create }

    it "attaches files" do
      expect(AttachFilesToETD).to receive(:run).with(etd, attributes[:files])
      factory.after_create(etd)
    end
  end
end

