require 'rails_helper'

describe OptionsHelper do
  describe "#digital_origin_options" do
    subject { helper.digital_origin_options }
    it { is_expected.to eq ["digitized other analog", "born digital", "reformatted digital", "digitized microfilm"] }
  end

  describe "#description_standard_options" do
    subject { helper.description_standard_options }
    it { is_expected.to eq ['aacr', 'rda', 'dacs', 'dcrmg', 'fgdc', 'iso19115', 'local', 'none'] }
  end

  describe "#sub_location_options" do
    subject { helper.sub_location_options }
    it { is_expected.to eq ["Department of Special Collections", "Main Library", "Map & Imagery Laboratory"] }
  end
end
