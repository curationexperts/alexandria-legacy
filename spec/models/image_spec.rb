require 'rails_helper'

describe Image do
  it 'should have a title' do
    subject.title = 'War and Peace'
    expect(subject.title).to eq 'War and Peace'
  end

  it 'has collections' do
    expect(subject.collections).to eq []
  end

  describe "nested attributes" do
    context "for creator" do
      it "should ignore empty ids" do
        subject.creator_attributes = {"0" => { "id"=>"http://id.loc.gov/authorities/names/n87141298" },
                        "1" => { "id"=>"" } }
        expect(subject.creator.size).to eq 1
      end
    end
  end

  describe "#to_solr" do
    context "with a title" do
      subject { Image.new(title: 'War and Peace').to_solr }

      it 'should have a title' do
        expect(subject['title_tesim']).to eq ['War and Peace']
      end
    end

    context "with subject" do
      let(:lcsubject) { [RDF::URI.new('http://id.loc.gov/authorities/subjects/sh85062487')] }
      subject { Image.new(lcsubject: lcsubject).to_solr }

      it "should have a subject" do
        expect(subject['lcsubject_tesim']).to eq ['http://id.loc.gov/authorities/subjects/sh85062487']
        expect(subject['lcsubject_label_tesim']).to eq ['Hotels']
      end
    end

    context "with creator" do
      let(:creator) { [RDF::URI.new("http://id.loc.gov/authorities/names/n87914041")] }
      subject { Image.new(creator: creator).to_solr }

      it "should have a creator" do
        expect(subject['creator_tesim']).to eq ['http://id.loc.gov/authorities/names/n87914041']
        expect(subject['creator_label_tesim']).to eq ["American Film Manufacturing Company"]
        expect(subject['creator_label_si']).to eq "American Film Manufacturing Company"
      end
    end

    context "with issued_date" do
      let(:issued_date) { [1925] }
      subject { Image.new(issued: issued_date).to_solr }

      it "should have a issued_date" do
        expect(subject['issued_isim']).to eq ["1925"]
        expect(subject['date_ii']).to eq "1925"
      end
    end

    context "with earliestDate and latestDate" do
      let(:earliestDate) { [1917] }
      let(:latestDate) { [1923] }
      subject { Image.new(earliestDate: earliestDate, latestDate: latestDate).to_solr }

      it "should have a dates indexed" do
        expect(subject['earliestDate_isim']).to eq ["1917"]
        expect(subject['latestDate_isim']).to eq ["1923"]
        expect(subject['date_ii']).to eq "1917"
      end
    end

    context "with a generic_file" do
      let(:generic_file) { GenericFile.new(id: 'bf/74/27/75/bf742775-2a24-46dc-889e-cca03b27b5f3') }
      subject { Image.new(generic_files: [generic_file]).to_solr }

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

    context "with collections" do
      let(:long_books) { Collection.create!(title: 'Long Books') }
      let(:boring_books) { Collection.create!(title: 'Boring Books') }

      subject {
        image = Image.new(title: 'War and Peace')
        image.collections = [boring_books, long_books]
        image.to_solr
      }

      it 'has collections' do
        expect(subject['collection_sim']).to eq [boring_books.id, long_books.id]
        expect(subject['collection_tesim']).to eq [boring_books.id, long_books.id]
      end
    end
  end

end
