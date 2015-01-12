require 'rails_helper'
require 'importer'

describe Importer::ModsImporter do
  let(:image_directory) { 'spec/fixtures/images' }
  let(:importer) { Importer::ModsImporter.new(image_directory) }
  let(:file) { 'spec/fixtures/mods/cusbspcmss36_110108.xml' }

  before { allow($stdout).to receive(:puts) } # squelch output

  describe "#import" do
    it "should create a new image and files" do
      expect {
        importer.import(file)
      }.to change { Image.count }.by(1).
      and change { GenericFile.count }.by(2)
    end
  end
end
