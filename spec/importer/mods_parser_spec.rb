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

    it 'finds metadata for the collection' do
      expect(attributes[:collection][:id]).to eq 'sbhcmss78'
      expect(attributes[:collection][:title]).to eq 'Joel Conway / Flying A Studio photograph collection'
    end

    it "should import earliestDate" do
      expect(attributes[:earliestDate]).to eq [1910]
    end

    it "should import latestDate" do
      expect(attributes[:latestDate]).to eq [1919]
    end

    context "with a file that has dateIssued" do
      let(:file) { 'spec/fixtures/mods/cusbspcmss36_110108.xml' }
      it "should import issued" do
        expect(attributes[:issued]).to eq [1925]
      end
    end
  end
end

