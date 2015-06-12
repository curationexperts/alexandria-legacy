require 'rails_helper'

describe Etd do
  let(:etd) { Etd.new }

  before do
    etd.marc.content = File.open('spec/fixtures/marc/single_etd.mrc')
  end

  subject { etd.to_solr }

  it "has title" do
    expect(subject['title_tesim']).to eq ["Sacred travels religious identity and its effect on the reception of travelers in the Eastern Roman Mediterranean"]
  end
end
