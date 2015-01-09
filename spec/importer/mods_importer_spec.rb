require 'rails_helper'
require 'importer'

describe Importer::ModsImporter do
  it "should create a new image and files" do
    expect {
      Importer::ModsImporter.import
    }.to change { Image.count }.by(1).and change { GenericFile.count }.by(2)
  end
end
