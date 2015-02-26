require 'rails_helper'

describe CollectionsHelper do

  describe '#display_collector' do
    let(:collector) { ['http://id.loc.gov/authorities/names/n79064013'] }
    let(:label) { ['Jules Verne'] }
    subject { helper.display_collector(document: solr_doc) }

    context 'when there is a human-friendly label' do
      let(:solr_doc) { SolrDocument.new('collector_ssm' => collector, 'collector_label_ssm' => label) }

      it 'displays the label' do
        expect(subject).to eq label
      end
    end

    context 'when there is no human-friendly label' do
      let(:solr_doc) { SolrDocument.new('collector_ssm' => collector) }

      it 'displays the collector' do
        expect(subject).to eq collector
      end
    end
  end

end
