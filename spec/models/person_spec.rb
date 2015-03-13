require 'rails_helper'

describe Person do
  describe "#rdf_label" do
    let(:person) { described_class.new(foaf_name: 'Justin') }
    subject { person.rdf_label }
    it { is_expected.to eq ['Justin'] }
  end
end
