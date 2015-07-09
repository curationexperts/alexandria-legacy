require 'rails_helper'

describe AttachFilesToETD do
  describe "run" do
    let(:file) { "Plunkett_ucsb_0035D_11862.pdf" }
    let(:zip_path) { 'fake_file.zip' }
    let(:etd) { ETD.create }
    let(:file_struct) do
      ZipfileService::ExtractedFiles.new(
        "#{Rails.root}/spec/fixtures/pdf/sample.pdf",
        "#{Rails.root}/spec/fixtures/proquest/Johnson_ucsb_0035N_12164_DATA.xml",
        ["#{Rails.root}/spec/fixtures/images/cusbspcmss36_110108_1_a.tif",
          "#{Rails.root}/spec/fixtures/images/cusbspcmss36_110108_2_a.tif"]
      )
    end
    before do
      allow_any_instance_of(ZipfileService).to receive(:extract_files).and_return(file_struct)
      described_class.run(etd, file)
    end

    it "attaches files" do
      expect(etd.generic_files).to all(be_kind_of GenericFile)
      expect(etd.generic_files[0].original.size).to eq 218882
      expect(etd.generic_files[1].original.mime_type).to eq 'image/tiff'
      expect(etd.generic_files[2].original.mime_type).to eq 'image/tiff'

      expect(etd.proquest.size).to eq 5564
    end
  end
end
