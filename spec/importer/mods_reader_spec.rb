require 'rails_helper'
require 'importer'

describe Importer::ModsImporter do
  it "should create a new image" do
    expect {
      Importer::ModsImporter.import
    }.to change { Image.count }.by(1)
  end
end
