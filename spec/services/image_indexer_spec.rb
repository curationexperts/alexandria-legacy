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

  context "with a generic_file" do
    let(:generic_file) { GenericFile.new(id: 'bf/74/27/75/bf742775-2a24-46dc-889e-cca03b27b5f3') }
    let(:image) { Image.new(generic_files: [generic_file]) }

    it "should have a thumbnail image" do
      expect(subject['thumbnail_url_ssm']).to eq ['http://test.host/images/bf%2F74%2F27%2F75%2Fbf742775-2a24-46dc-889e-cca03b27b5f3%2Foriginal/full/300,/0/native.jpg']
    end

    it "should have a medium image" do
      expect(subject['image_url_ssm']).to eq ['http://test.host/images/bf%2F74%2F27%2F75%2Fbf742775-2a24-46dc-889e-cca03b27b5f3%2Foriginal/full/600,/0/native.jpg']
    end

    it "should have a large image" do
      expect(subject['large_image_url_ssm']).to eq ['http://test.host/images/bf%2F74%2F27%2F75%2Fbf742775-2a24-46dc-889e-cca03b27b5f3%2Foriginal/full/1000,/0/native.jpg']
    end
  end

  context "with a title" do
    let(:image) { Image.new(title: 'War and Peace') }

    it 'should have a title' do
      expect(subject['title_tesim']).to eq ['War and Peace']
    end
  end

  context "with subject" do
    let(:lc_subject) { [RDF::URI.new('http://id.loc.gov/authorities/subjects/sh85062487')] }
    let(:image) { Image.new(lc_subject: lc_subject) }

    it "should have a subject" do
      expect(subject['lc_subject_tesim']).to eq ['http://id.loc.gov/authorities/subjects/sh85062487']
      expect(subject['lc_subject_label_tesim']).to eq ['Hotels']
    end
  end

  context "with creator" do
    let(:creator) { [RDF::URI.new("http://id.loc.gov/authorities/names/n87914041")] }
    let(:image) { Image.new(creator: creator) }

    it "should have a creator" do
      expect(subject['creator_tesim']).to eq ['http://id.loc.gov/authorities/names/n87914041']
      expect(subject['creator_label_tesim']).to eq ["American Film Manufacturing Company"]
      expect(subject['creator_label_si']).to eq "American Film Manufacturing Company"
    end
  end

  context "with collections" do
    let(:long_books) { Collection.create!(title: 'Long Books') }
    let(:boring_books) { Collection.create!(title: 'Boring Books') }
    let(:image) { Image.new(collections: [boring_books, long_books]) }

    it 'has collections' do
      expect(subject['collection_ssim']).to eq [boring_books.id, long_books.id]
      expect(subject['collection_label_ssim']).to include 'Long Books', 'Boring Books'
    end
  end

end
