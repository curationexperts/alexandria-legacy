require 'rails_helper'
require 'importer'

describe Importer::ModsParser do
  let(:parser) { Importer::ModsParser.new(file) }
  let(:attributes) { parser.attributes }

  describe "Determine which kind of record it is:" do
    describe "for a collection:" do
      let(:file) { 'spec/fixtures/mods/sbhcmss78_FlyingAStudios_collection.xml' }

      it 'knows it is a Collection' do
        expect(parser.collection?).to eq true
        expect(parser.image?).to eq false
        expect(parser.model).to eq Collection
      end
    end

    describe "for an image:" do
      let(:file) { 'spec/fixtures/mods/cusbspcsbhc78_100239.xml' }

      it 'knows it is an Image' do
        expect(parser.image?).to eq true
        expect(parser.collection?).to eq false
        expect(parser.model).to eq Image
      end
    end
  end


  describe "#attributes for an Image record" do
    let(:file) { 'spec/fixtures/mods/cusbspcsbhc78_100239.xml' }

    it 'finds metadata for the image' do
      expect(attributes[:description]).to eq ['Another description', 'Man with a smile eyes to camera.']
    end

    it "should import creator" do
      expect(attributes[:creator]).to eq ['http://id.loc.gov/authorities/names/n87914041']
    end

    it 'finds metadata for the collection' do
      expect(attributes[:collection][:id]).to eq 'sbhcmss78'
      expect(attributes[:collection][:identifier]).to eq ['SBHC Mss 78']
      expect(attributes[:collection][:title]).to eq 'Joel Conway / Flying A Studio photograph collection'
    end

    it "should import earliestDate" do
      expect(attributes[:earliestDate]).to eq ['1910']
    end

    it "should import latestDate" do
      expect(attributes[:latestDate]).to eq ['1919']
    end

    context "with a file that has dateIssued" do
      let(:file) { 'spec/fixtures/mods/cusbspcmss36_110108.xml' }
      it "should import issued" do
        expect(attributes[:issued]).to eq ['1925']
      end
    end
  end


  describe "#attributes for a Collection record" do
    let(:file) { 'spec/fixtures/mods/sbhcmss78_FlyingAStudios_collection.xml' }

    it 'finds the metadata' do
      expect(attributes[:id]).to eq 'sbhcmss78'
      expect(attributes[:identifier]).to eq ['SBHC Mss 78']
      expect(attributes[:title]).to eq 'Joel Conway / Flying A Studio photograph collection'
      expect(attributes[:creator]).to eq []
      expect(attributes[:description]).to eq 'Black and white photographs relating to the Flying A Studios (aka American Film Manufacturing Company), a film company that operated in Santa Barbara (1912-1920).'
      expect(attributes[:date_created]).to eq ['1910-1919']
      expect(attributes[:extent]).to eq ['702 digital objects']
      expect(attributes[:lcsubject]).to eq ["http://id.loc.gov/authorities/subjects/sh85088047", "http://id.loc.gov/authorities/subjects/sh99005024"]
      expect(attributes[:workType]).to eq ["http://vocab.getty.edu/aat/300046300", "http://vocab.getty.edu/aat/300128343"]
    end
  end

end

