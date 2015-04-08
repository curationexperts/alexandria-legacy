require 'rails_helper'
require 'importer'
describe ImageFactory do
  let(:factory) { described_class.new(attributes) }
  let(:collection_attrs) { { accession_number: ['SBHC Mss 36'] } }
  let(:attributes) { { collection: collection_attrs, files: [], accession_number: ['123'] } }

  context "when a collection already exists" do
    let!(:coll) { Collection.create(collection_attrs.merge(id: 'fk44174k70')) }

    it "should not create a new collection" do
      expect(coll.members.count).to eq 0
      expect {
        factory.run
      }.to change { Collection.count }.by(0)
      expect(coll.reload.members.count).to eq 1
    end
  end
end
