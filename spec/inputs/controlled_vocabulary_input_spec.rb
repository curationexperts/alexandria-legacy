require 'rails_helper'

describe 'ControlledVocabularyInput', type: :input do
  let(:image) { Image.new }
  let(:bar1) { double('value 1', rdf_label: ['Item 1'], rdf_subject: 'http://example.org/1') }
  let(:bar2) { double('value 2', rdf_label: ['Item 2'], rdf_subject: 'http://example.org/2') }
  let(:builder) { SimpleForm::FormBuilder.new(:image, image, view, {}) }
  let(:input) { ControlledVocabularyInput.new(builder, :creator, nil, :multi_value, {}) }

  describe '#input' do
    before { allow(image).to receive(:[]).with(:creator).and_return([bar1, bar2]) }
    it 'renders multi-value' do
      expect(input).to receive(:build_field).with(bar1, 0)
      expect(input).to receive(:build_field).with(bar2, 1)
      input.input({})
    end
  end

  describe '#build_field' do
    subject { input.send(:build_field, bar1, 0) }

    it 'renders multi-value' do
      expect(subject).to have_selector('input.image_creator.multi_value')
      expect(subject).to have_field('image[creator_attributes][0][id]', with: 'Item 1')
      expect(subject).to have_selector('input[name="image[creator_attributes][0][hidden_label]"][value="http://example.org/1"]')

    end
  end
end
