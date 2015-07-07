require 'rails_helper'

describe ZipfileService do
  describe "#wildcard_zip" do
    subject { described_class.wildcard_zip }
    it { is_expected.to eq "\"#{Rails.root}/tmp/download_root/proquest/*.zip\"" }
  end
end
