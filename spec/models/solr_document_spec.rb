require 'rails_helper'

describe SolrDocument do
  context "for an image" do
    let(:image) { create(:image) }
    let(:document) { SolrDocument.new(id: image.id, identifier_ssm: ['ark:/99999/fk4v989d9j']) }

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

    describe "#ark" do
      subject { document.ark }
      it { is_expected.to eq 'ark:/99999/fk4v989d9j' }
    end
  end

  context '#to_param' do
    let(:noid) { 'f123456789' }
    let(:id)   { '12/34/56/f123456789' }

    subject { document.to_param }

    context 'for an object with an ARK' do
      let(:document) { SolrDocument.new(id: id, identifier_ssm: ["ark:/99999/#{noid}"]) }

      it 'converts the ark to a noid' do
        expect(subject).to eq noid
      end
    end

    context 'for an object without an ARK' do
      let(:document) { SolrDocument.new(id: id, identifier_ssm: nil) }
      it 'converts the id to a noid' do
        expect(subject).to eq noid
      end
    end
  end
end
