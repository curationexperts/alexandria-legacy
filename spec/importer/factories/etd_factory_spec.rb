require 'rails_helper'
require 'importer'
describe Importer::Factory::ETDFactory do
  let(:factory) { described_class.new(attributes, Settings.etd_download_root) }
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

