require 'rails_helper'

describe BlacklightUrlHelper do
  describe "#url_for_document" do
    context "with an image" do
      let(:document) { SolrDocument.new(has_model_ssim: ['Image'], identifier_ssm: ['ark:/99999/fk4v989d9j']) }
      subject { helper.url_for_document(document) }
      it { is_expected.to eq '/lib/ark:/99999/fk4v989d9j' }
    end
  end
end
