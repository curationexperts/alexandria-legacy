require 'rails_helper'
require 'importer'

describe Importer::ModsParser do
  let(:parser) { Importer::ModsParser.new(file) }

  describe "#attributes" do
    let(:file) { 'spec/fixtures/mods/cusbspcsbhc78_100239.xml' }
    let(:attributes) { parser.attributes }

    it "should import creator" do
      expect(attributes[:creator]).to eq ['http://id.loc.gov/authorities/names/n87914041']
    end
  end
end

