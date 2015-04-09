require 'rails_helper'

describe 'MultiValueSelectInput', type: :input do
  let(:image) { Image.new }
  let(:builder) { SimpleForm::FormBuilder.new(:image, image, view, {}) }
  let(:input) { MultiValueSelectInput.new(builder, :digital_origin, nil, :multi_value_select, options) }

  let(:base_options) { { as: :multi_value_select, required: true, collection: ['one', 'two'] } }
  let(:options) { base_options }

  subject { input.input(nil) } 
  context "when a blank is requested" do
    let(:options) { base_options.merge(include_blank: true) }
    it 'renders a blank option' do
      expect(subject).to have_selector 'select option[value=""]'
    end
  end

  context "when a blank is not requested" do
    it 'has no blanks' do
      expect(subject).to have_selector 'select option:first-child', text: 'one'
    end
  end
end

