require 'rails_helper'

describe Person do
  describe "#rdf_label" do
    let(:person) { described_class.new(foaf_name: 'Justin') }
    subject { person.rdf_label }
    it { is_expected.to eq ['Justin'] }
  end

  describe "#to_partial_path" do
    subject { described_class.new.to_partial_path }
    it { is_expected.to eq 'catalog/document' }
  end
end
