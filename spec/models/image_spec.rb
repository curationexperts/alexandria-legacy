require 'rails_helper'

describe Image do
  it 'should have a title' do
    subject.title = ['War and Peace']
    expect(subject.title).to eq ['War and Peace']
  end

  describe "#to_solr" do
    context "with a title" do
      subject { Image.new(title: ['War and Peace']).to_solr }

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
  end

end
