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
    let(:image) { Image.new }
    it "calls the ImageIndexer" do
      expect_any_instance_of(ImageIndexer).to receive(:generate_solr_document)
      image.to_solr
    end
  end
end
