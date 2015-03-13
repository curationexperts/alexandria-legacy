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
      expect(attributes[:location]).to eq ["http://id.loc.gov/authorities/names/n79081574"]
      expect(attributes[:form_of_work]).to eq ["http://vocab.getty.edu/aat/300134920", "http://vocab.getty.edu/aat/300046300"]
      expect(attributes[:extent]).to eq ['1 photograph : glass plate negative ; 13 x 18 cm (5 x 7 format)']
      expect(attributes[:accession_number]).to eq ['cusbspcsbhc78_100239']
      expect(attributes[:sub_location]).to eq ['Department of Special Collections']
      expect(attributes[:citation]).to eq ["[Identification of Item], Joel Conway / Flying A Studio\nPhotograph Collection. SBHC Mss 78. Department of Special Collections, UC Santa Barbara\nLibrary, University of California, Santa Barbara."]
      expect(attributes[:note]).to eq ["Gift from Pat Eagle-Schnetzer and Ronald Conway, and purchase\nfrom Joan Cota (Conway children), 2009."]
      expect(attributes[:record_origin]).to eq ['Converted from CSV to MODS 3.4 using local mapping.', Importer::ModsParser::ORIGIN_TEXT]
      expect(attributes[:description_standard]).to eq ['local']
      expect(attributes[:series_name]).to eq ['Series 4: Glass Negatives']
      expect(attributes[:use_restrictions]).to eq ['Use governed by the UCSB Special Collections policy.']
    end

    context "with a file that has a publisher" do
      let(:file) { 'spec/fixtures/mods/cusbspcmss36_110108.xml' }

      it 'imports publisher' do
        expect(attributes[:publisher]).to eq ['[Cross & Dimmit Pictures]']
      end
    end

    context "with a file that has a photographer" do
      let(:file) { 'spec/fixtures/mods/cusbmss228-p00003.xml' }

      it 'imports photographer' do
        expect(attributes[:photographer]).to eq ['http://id.loc.gov/authorities/names/n97003180']
      end
    end

    it "imports creator" do
      expect(attributes[:creator]).to eq ['http://id.loc.gov/authorities/names/n87914041']
    end

    it "imports language" do
      expect(attributes[:language]).to eq ['http://id.loc.gov/vocabulary/iso639-2/zxx']
    end

    it "imports work_type" do
      expect(attributes[:work_type]).to eq ['still image']
    end

    it "imports digital origin" do
      expect(attributes[:digital_origin]).to eq ["digitized other analog"]
    end

    context "with a file that has coordinates" do
      let(:file) { 'spec/fixtures/mods/cusbspcmss36_110089.xml' }
      it "imports coordinates" do
        expect(attributes[:latitude]).to eq ['34.442982']
        expect(attributes[:longitude]).to eq ['-119.657362']
      end
    end

    context "with a file that has dateOther" do
      let(:file) { 'spec/fixtures/mods/cusbspcmss36_110089.xml' }
      it "imports date_other" do
        expect(attributes[:date_other]).to eq ['undated']
      end
    end

    it 'finds metadata for the collection' do
      expect(attributes[:collection][:id]).to eq 'sbhcmss78'
      expect(attributes[:collection][:accession_number]).to eq ['SBHC Mss 78']
      expect(attributes[:collection][:title]).to eq 'Joel Conway / Flying A Studio photograph collection'
    end

    context "with a range of dateCreated" do
      it "imports created_start" do
        expect(attributes[:created_start]).to eq ['1910']
      end

      it "imports created_end" do
        expect(attributes[:created_end]).to eq ['1919']
      end
    end

    context "with a file that has a range of dateIssued" do
      let(:file) { 'spec/fixtures/mods/cusbspcmss36_110089.xml' }
      it "imports issued" do
        expect(attributes[:issued]).to eq []
      end

      it "imports issued_start" do
        expect(attributes[:issued_start]).to eq ['1900']
      end

      it "imports issued_end" do
        expect(attributes[:issued_end]).to eq ['1959']
      end
    end

    context "with a file that has a single dateIssued" do
      let(:file) { 'spec/fixtures/mods/cusbspcmss36_110108.xml' }
      it "imports issued" do
        expect(attributes[:issued]).to eq ['1925']
      end
    end

    context "with a file that has an alternative title" do
      let(:file) { 'spec/fixtures/mods/cusbspcmss36_110089.xml' }
      it "distinguishes between title and alternative title" do
        expect(attributes[:title]).to eq 'Patio, Gavit residence'
        expect(attributes[:alternative]).to eq ['Lotusland']
      end
    end

    context "with a file that has placeTerm" do
      let(:file) { 'spec/fixtures/mods/cusbspcmss36_110089.xml' }
      it 'reads the place' do
        expect(attributes[:place_of_publication]). to eq ['Santa Barbara, California']
      end
    end
  end


  describe "#attributes for a Collection record" do
    let(:file) { 'spec/fixtures/mods/sbhcmss78_FlyingAStudios_collection.xml' }

    it 'finds the metadata' do
      expect(attributes[:id]).to eq 'sbhcmss78'
      expect(attributes[:accession_number]).to eq ['SBHC Mss 78']
      expect(attributes[:title]).to eq 'Joel Conway / Flying A Studio photograph collection'
      expect(attributes[:creator]).to be_nil
      expect(attributes[:collector]).to eq [{name: 'Conway, Joel', type: 'personal'}]
      expect(attributes[:description]).to eq ['Black and white photographs relating to the Flying A Studios (aka American Film Manufacturing Company), a film company that operated in Santa Barbara (1912-1920).']
      expect(attributes[:created_start]).to eq ['1910']
      expect(attributes[:created_end]).to eq ['1919']
      expect(attributes[:extent]).to eq ['702 digital objects']
      expect(attributes[:lc_subject]).to eq ["http://id.loc.gov/authorities/subjects/sh85088047", "http://id.loc.gov/authorities/subjects/sh99005024"]
      expect(attributes[:form_of_work]).to eq ["http://vocab.getty.edu/aat/300046300", "http://vocab.getty.edu/aat/300128343"]
      expect(attributes[:language]).to eq ['http://id.loc.gov/vocabulary/iso639-2/zxx']
      expect(attributes[:work_type]).to eq ['still image']
      expect(attributes[:sub_location]).to eq ['Department of Special Collections']
      expect(attributes[:record_origin]).to eq ['Human created', Importer::ModsParser::ORIGIN_TEXT ]

      # TODO: There is another location in the fixture file
      # that doesn't have a valueURI.  How should that be
      # handled?
      expect(attributes[:location]).to eq ["http://id.loc.gov/authorities/names/n79041717"]
    end
  end

end
