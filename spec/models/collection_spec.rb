require 'rails_helper'

describe Collection do
  describe "#to_solr" do

    context 'collector with a URI' do
      let(:url) { 'http://id.loc.gov/authorities/names/n79064013' }
      subject { Collection.new(collector: [RDF::URI.new(url)]).to_solr }

      it 'has fields for collector' do
        expect(subject['collector_teim']).to eq [url]
        expect(subject['collector_ssm']).to eq [url]
        expect(subject['collector_label_teim']).to eq ["Verne, Jules, 1828-1905"]
        expect(subject['collector_label_ssm']).to eq ["Verne, Jules, 1828-1905"]
      end
    end

    context 'collector with a string' do
      let(:jules_verne) { 'Jules Verne' }
      subject { Collection.new(collector: [jules_verne]).to_solr }

      it 'has fields for collector' do
        expect(subject['collector_teim']).to eq [jules_verne]
        expect(subject['collector_ssm']).to eq [jules_verne]
      end
    end

    context 'with subject' do
      let(:label) { 'Motion picture industry' }
      let(:url) { 'http://id.loc.gov/authorities/subjects/sh85088047' }
      let(:lc_subject) { [RDF::URI.new(url)] }
      subject { Collection.new(lc_subject: lc_subject).to_solr }

      it 'has human-readable labels for subject' do
        expect(subject["lc_subject_tesim"]).to eq [url]
        expect(subject["lc_subject_sim"]).to eq [url]
        expect(subject["lc_subject_label_tesim"]).to eq [label]
        expect(subject["lc_subject_label_sim"]).to eq [label]
      end
    end

    context 'with form_of_work' do
      let(:label) { 'black-and-white negatives' }
      let(:url) { 'http://vocab.getty.edu/aat/300128343' }
      let(:type) { [RDF::URI.new(url)] }
      subject { Collection.new(form_of_work: type).to_solr }

      it 'has human-readable labels for form_of_work' do
        expect(subject["form_of_work_sim"]).to eq [url]
        expect(subject["form_of_work_tesim"]).to eq [url]
        expect(subject["form_of_work_label_sim"]).to eq [label]
        expect(subject["form_of_work_label_tesim"]).to eq [label]
      end
    end
  end
end
