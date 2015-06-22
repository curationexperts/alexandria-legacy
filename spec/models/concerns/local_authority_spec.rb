require 'rails_helper'

class TestObject < ActiveFedora::Base
  include LocalAuthority
end


describe LocalAuthority do
  subject { TestObject.create }

  context '#referenced_by' do
    context 'when record isnt referenced by any other record' do
      it 'returns empty list' do
        expect(subject.referenced_by).to eq []
      end
    end

    context 'when record is referenced by another record' do
      let!(:image) { Image.create(creator: [subject]) }

      it 'returns list of object IDs' do
        subject.reload
        expect(subject.referenced_by).to eq [image.id]
      end
    end
  end

end
