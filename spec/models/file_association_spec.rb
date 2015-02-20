require 'rails_helper'

describe FileAssociation do
  let(:generic_file1) { create :generic_file }
  let(:generic_file2) { create :generic_file }

  let(:image) { create :image }

  before do
    image.generic_files = [generic_file2, generic_file1]
    image.save
  end

  let(:reloaded) { Image.find(image.id) } # because reload doesn't clear this association

  it "should save the images in order" do
    expect(reloaded.generic_files).to eq [generic_file2, generic_file1]
  end
end
