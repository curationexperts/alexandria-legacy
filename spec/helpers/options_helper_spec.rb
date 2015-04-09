require 'rails_helper'

describe OptionsHelper do
  describe "#digital_origin_options" do
    subject { helper.digital_origin_options }
    it { is_expected.to eq ["digitized other analog", "born digital", "reformatted digital", "digitized microfilm"] }
  end
end
