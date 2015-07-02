require 'rails_helper'
require 'importer'
describe Importer::Factory::ETDFactory do
  let(:factory) { described_class.new(attributes) }
  let(:collection_attrs) { { accession_number: ["etds"] } }

  let(:attributes) do
    {
      collection: collection_attrs, files: [], accession_number: ['123'],
      created_attributes: [{ start: [2014] }]
    }
  end

  # squelch output
  before { allow($stdout).to receive(:puts) }

  context "when a collection already exists" do
    let!(:coll) { Collection.create(collection_attrs) }

    it "should not create a new collection" do
      expect(coll.members.count).to eq 0
      expect {
        VCR.use_cassette('ezid') do
          factory.run
        end
      }.to change { Collection.count }.by(0)
      expect(coll.reload.members.count).to eq 1
      expect(coll.members.first).to be_instance_of ETD
    end
  end
end

