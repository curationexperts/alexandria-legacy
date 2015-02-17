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

end
