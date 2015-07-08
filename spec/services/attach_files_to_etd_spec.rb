require 'rails_helper'

describe AttachFilesToETD do
  describe "run" do
    let(:files) { ["Plunkett_ucsb_0035D_11862.pdf"] }
    let(:zip_path) { 'fake_file.zip' }
    let(:etd) { ETD.create }
    let(:file_hash) { { 'pdf' => "#{Rails.root}/spec/fixtures/pdf/sample.pdf",
                        'xml' => "#{Rails.root}/spec/fixtures/proquest/Johnson_ucsb_0035N_12164_DATA.xml"
                    } }
    before do
      allow(ZipfileService).to receive(:find_file_containing).with(files.first).and_return(zip_path)
      allow(ZipfileService).to receive(:extract_files).with(zip_path).and_return(file_hash)
      described_class.run(etd, files)
    end

    it "attaches files" do
      expect(etd.generic_files.first).to be_kind_of GenericFile
      expect(etd.generic_files.first.original.size).to eq 218882
      expect(etd.proquest.size).to eq 5564
    end
  end
end
