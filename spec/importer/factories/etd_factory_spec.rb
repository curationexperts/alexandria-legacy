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
      expect(obj.system_number).to eq ['123']
    end
  end


  describe "after_create" do
    let(:attributes) do
      {
        files: ["Plunkett_ucsb_0035D_11862.pdf"]
      }
    end
    let(:zip_path) { 'fake_file.zip' }
    let(:etd) { ETD.create }
    let(:file_hash) { { 'pdf' => "#{Rails.root}/spec/fixtures/pdf/sample.pdf",
                        'xml' => "#{Rails.root}/spec/fixtures/proquest/Johnson_ucsb_0035N_12164_DATA.xml"
                    } }
    before do
      allow(ZipfileService).to receive(:find_file_containing).with(attributes[:files].first).and_return(zip_path)
      allow(ZipfileService).to receive(:extract_files).with(zip_path).and_return(file_hash)
      factory.after_create(etd)
    end
    it "attaches files" do
      expect(etd.generic_files.first).to be_kind_of GenericFile
      expect(etd.generic_files.first.original.size).to eq 218882
      expect(etd.proquest.size).to eq 5564
    end
  end
end

