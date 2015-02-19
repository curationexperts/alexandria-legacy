require 'rails_helper'

describe CollectionsHelper do

  describe '#display_date_created' do
    let(:earliest) { '1910' }
    let(:latest)   { '1919' }

    subject { helper.display_dates(document: solr_doc) }

    context 'with earliestDate and latestDate' do
      let(:solr_doc) do
        SolrDocument.new(earliestDate_tesim: [earliest],
                         latestDate_tesim: [latest])
      end

      it 'returns the date range' do
        expect(subject).to eq "#{earliest}-#{latest}"
      end
    end

    context 'with only earliestDate' do
      let(:solr_doc) do
        SolrDocument.new(earliestDate_tesim: [earliest])
      end

      it 'returns the date' do
        expect(subject).to eq "#{earliest}"
      end
    end

    context 'with only earliestDate' do
      let(:solr_doc) do
        SolrDocument.new(latestDate_tesim: [latest])
      end

      it 'returns the date' do
        expect(subject).to eq "#{latest}"
      end
    end

    context 'with no dates' do
      let(:solr_doc) { SolrDocument.new }

      it 'returns empty string' do
        expect(subject).to eq ''
      end
    end
  end  #  '#display_date_created'


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
