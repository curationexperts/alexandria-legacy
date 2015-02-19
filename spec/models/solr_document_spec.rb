require 'rails_helper'

describe SolrDocument do
  context "for an image" do
    let(:image) { create(:image) }
    let(:document) { SolrDocument.new(id: image.id) }

    describe "#repository_model" do
      subject { document.repository_model }
      it "converts to a model" do
        expect(subject).to be_kind_of Image
        expect(subject.resource).to be_kind_of ActiveTriples::Resource
      end
    end

    describe "#export_as_ttl" do
      subject { document.export_as_ttl }
      it { is_expected.to match '<info:fedora/fedora-system:def/model#hasModel> "Image"' }
    end
  end
end
