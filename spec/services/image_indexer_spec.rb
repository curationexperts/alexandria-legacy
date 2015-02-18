require 'rails_helper'

describe ImageIndexer do
  subject { ImageIndexer.new(image).generate_solr_document }

  context "with an issued date" do
    let(:image) { Image.new(issued: ['1925-11']) }

    it "indexes dates for display" do
      expect(subject['issued_tesim']).to eq ["1925-11"]
    end

    it "makes a sortable date field" do
      expect(subject['date_si']).to eq '1925-11'
    end

    it "makes a facetable year field" do
      expect(subject['year_iim']).to eq [1925]
    end
  end

  context "with earliestDate and latestDate" do
    let(:earliestDate) { ['1917'] }
    let(:latestDate) { ['1923'] }
    let(:issued) { [earliestDate.first, latestDate.first] }
    let(:image) { Image.new(earliestDate: earliestDate, latestDate: latestDate, issued: issued) }

    it "indexes dates for display" do
      expect(subject['earliestDate_tesim']).to eq ["1917"]
      expect(subject['latestDate_tesim']).to eq ["1923"]
    end

    it "makes a sortable date field" do
      expect(subject['date_si']).to eq "1917"
    end

    it "makes a facetable year field" do
      expect(subject['year_iim']).to eq [1917, 1918, 1919, 1920, 1921, 1922, 1923]
    end
  end
end
