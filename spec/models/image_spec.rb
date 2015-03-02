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

    context "for location" do
      it "should ignore empty ids" do
        subject.location_attributes = {"0" => { "id"=>"http://id.loc.gov/authorities/names/n87141298" },
                        "1" => { "id"=>"" } }
        expect(subject.location.size).to eq 1
      end
    end

    context "for lc_subject" do
      it "should ignore empty ids" do
        subject.lc_subject_attributes = {"0" => { "id"=>"http://id.loc.gov/authorities/subjects/sh85111007" },
                        "1" => { "id"=>"" } }
        expect(subject.lc_subject.size).to eq 1
      end
    end

    context "for form_of_work" do
      it "should ignore empty ids" do
        subject.form_of_work_attributes = {"0" => { "id"=>"http://vocab.getty.edu/aat/300026816" },
                        "1" => { "id"=>"" } }
        expect(subject.form_of_work.size).to eq 1
      end
    end
  end

  describe "#to_solr" do
    let(:image) { Image.new }
    it "calls the ImageIndexer" do
      expect_any_instance_of(ImageIndexer).to receive(:generate_solr_document)
      image.to_solr
    end
  end

  describe "dates" do
    let(:image) { Image.new }

    describe "ranges" do
      before do
        image.created_start = ['1911']
        image.created_end = ['1912']
        image.issued_start = ['1913']
        image.issued_end = ['1917']
      end

      it "stores them" do
        expect(image.created_start).to eq ['1911']
        expect(image.created_end).to eq ['1912']
        expect(image.issued_start).to eq ['1913']
        expect(image.issued_end).to eq ['1917']
      end
    end

    describe "points" do
      before do
        image.issued = ['1913']
      end
      it "stores them" do
        expect(image.issued).to eq ['1913']
      end
    end
  end

end
