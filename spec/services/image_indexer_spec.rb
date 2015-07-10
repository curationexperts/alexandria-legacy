require 'rails_helper'

describe ImageIndexer do
  subject { ImageIndexer.new(image).generate_solr_document }

  context "with a generic_file" do
    let(:generic_file) { GenericFile.new(id: 'bf/74/27/75/bf742775-2a24-46dc-889e-cca03b27b5f3') }
    let(:image) { Image.new(generic_files: [generic_file]) }

    it "has images" do
      expect(subject['thumbnail_url_ssm']).to eq ['http://test.host/images/bf%2F74%2F27%2F75%2Fbf742775-2a24-46dc-889e-cca03b27b5f3%2Foriginal/full/300,/0/native.jpg']
      expect(subject['image_url_ssm']).to eq ['http://test.host/images/bf%2F74%2F27%2F75%2Fbf742775-2a24-46dc-889e-cca03b27b5f3%2Foriginal/full/600,/0/native.jpg']
      expect(subject['large_image_url_ssm']).to eq ['http://test.host/images/bf%2F74%2F27%2F75%2Fbf742775-2a24-46dc-889e-cca03b27b5f3%2Foriginal/full/1000,/0/native.jpg']
    end
  end

end
