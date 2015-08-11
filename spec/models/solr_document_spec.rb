require 'rails_helper'

describe SolrDocument do
  context "for an image" do
    let(:image) { create(:image) }
    let(:document) { SolrDocument.new(id: image.id, identifier_ssm: ['ark:/99999/fk4v989d9j'], has_model_ssim: [Image.to_class_uri]) }

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

    describe "#etd?" do
      subject { document.etd? }
      it { is_expected.to be false }
    end
  end

  context "for an etd" do
    let(:etd_document) { SolrDocument.new(id: 'foobar', has_model_ssim: [ETD.to_class_uri]) }

    describe "#etd?" do
      subject { etd_document.etd? }
      it { is_expected.to be true }
    end

    describe "generic_files" do
      subject { etd_document.generic_files }
      context "with generic files" do
        let(:generic_file_document) { SolrDocument.new(id: 'bf/74/27/75/bf742775-2a24-46dc-889e-cca03b27b5f3') }
        before do
          etd_document['generic_file_ids_ssim'] = [generic_file_document.id]
          ActiveFedora::SolrService.add(generic_file_document)
          ActiveFedora::SolrService.commit
        end

        it "looks up the generic_files" do
          expect(subject.map(&:id)).to eq [generic_file_document.id]
        end
      end

      context "without generic files" do
        it { is_expected.to be_empty }
      end
    end
  end

  describe '#to_param' do
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

  describe "#after_embargo_status" do
    before { AdminPolicy.ensure_admin_policy_exists }
    let(:document) { SolrDocument.new(
        visibility_during_embargo_ssim: ['authorities/policies/ucsb_on_campus'],
        visibility_after_embargo_ssim: ['authorities/policies/public'],
        embargo_release_date_dtsi: '2010-10-10T00:00:00Z'
    ) }
    subject { document.after_embargo_status }
    it { is_expected.to eq ' - Becomes Public access on 10/10/2010' }
  end
end
