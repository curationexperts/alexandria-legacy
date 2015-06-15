require 'rails_helper'

describe BlacklightUrlHelper do
  describe "#url_for_document" do
    let(:document) { SolrDocument.new(has_model_ssim: [model], id: 'fk/4v/98/fk4v989d9j', identifier_ssm: ['ark:/99999/fk4v989d9j']) }
    context "with an image" do
      let(:model) { 'Image' }
      subject { helper.url_for_document(document) }
      it { is_expected.to eq '/lib/ark:/99999/fk4v989d9j' }
    end

    context "with an Etd" do
      let(:model) { 'Etd' }
      subject { helper.url_for_document(document) }
      it { is_expected.to eq '/lib/ark:/99999/fk4v989d9j' }
    end

    context "with a collection" do
      let(:model) { 'Collection' }
      subject { helper.url_for_document(document) }
      it { is_expected.to eq '/collections/fk4v989d9j' }
    end
  end
end
