require 'rails_helper'

describe Collection do
  describe "#to_solr" do

    context 'with subject' do
      let(:label) { 'Motion picture industry' }
      let(:url) { 'http://id.loc.gov/authorities/subjects/sh85088047' }
      let(:lcsubject) { [RDF::URI.new(url)] }
      subject { Collection.new(lcsubject: lcsubject).to_solr }

      it 'has human-readable labels for subject' do
        expect(subject["lcsubject_tesim"]).to eq [url]
        expect(subject["lcsubject_sim"]).to eq [url]
        expect(subject["lcsubject_label_tesim"]).to eq [label]
        expect(subject["lcsubject_label_sim"]).to eq [label]
      end
    end

    context 'with workType' do
      let(:label) { 'black-and-white negatives' }
      let(:url) { 'http://vocab.getty.edu/aat/300128343' }
      let(:type) { [RDF::URI.new(url)] }
      subject { Collection.new(workType: type).to_solr }

      it 'has human-readable labels for workType' do
        expect(subject["workType_sim"]).to eq [url]
        expect(subject["workType_tesim"]).to eq [url]
        expect(subject["workType_label_sim"]).to eq [label]
        expect(subject["workType_label_tesim"]).to eq [label]
      end
    end
  end
end
