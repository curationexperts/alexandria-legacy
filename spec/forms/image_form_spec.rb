require 'rails_helper'

describe ImageForm do
  describe ".build_permitted_params" do
    subject { described_class.build_permitted_params }

    let(:time_span_params) {
      [ :id,
        :_destroy,
        {
          :start            => [],
          :start_qualifier  => [],
          :finish           => [],
          :finish_qualifier => [],
          :label            => [],
          :note             => []
        }
      ]
    }

    it "should include complex fields" do
      expect(subject).to include(creator_attributes: [:id, :_destroy])
      expect(subject).to include(location_attributes: [:id, :_destroy])
      expect(subject).to include(lc_subject_attributes: [:id, :_destroy])
      expect(subject).to include(form_of_work_attributes: [:id, :_destroy])
      expect(subject).to include(license_attributes: [:id, :_destroy])
      expect(subject).to include(copyright_status_attributes: [:id, :_destroy])
      expect(subject).to include(language_attributes: [:id, :_destroy])
      expect(subject).to include(created_attributes: time_span_params)
      expect(subject).to include(issued_attributes: time_span_params)
      expect(subject).to include(date_other_attributes: time_span_params)
      expect(subject).to include(date_valid_attributes: time_span_params)
      expect(subject).to include(date_copyrighted_attributes: time_span_params)
    end

    it "should include simple fields" do
      expect(subject).to include(accession_number: [])
      expect(subject).to include(sub_location: [])
      expect(subject).to include(use_restrictions: [])
      expect(subject).to include(series_name: [])
      expect(subject).to include(place_of_publication: [])
      expect(subject).to include(extent: [])
      expect(subject).to include(digital_origin: [])
      expect(subject).to include(alternative: [])
      expect(subject).to include(latitude: [])
      expect(subject).to include(longitude: [])
    end
  end

  describe "an instance" do
    let(:image) { Image.new(identifier: ['ark:/99999/fk4f76j320'], record_origin: ["This is the origin"] ) }
    let(:instance) { described_class.new image }

    describe "#ark" do
      subject { instance.ark }
      it { is_expected.to eq 'ark:/99999/fk4f76j320' }
    end

    describe "#record_origin" do
      subject { instance.record_origin }
      it { is_expected.to eq ['This is the origin'] }
    end
  end

  describe 'model_attributes' do
    let(:request_params) {
      {
        created_attributes: {
          "0" => {
            id: "http://localhost:8983/fedora/rest/test/de/ad/be/ef/deadbeef",
            start: ["1337"],
            start_qualifier: ["approximate"],
            finish: ["2015"],
            finish_qualifier: ["exact"],
            label: ["some-label"],
            note: ["some-note"]
          }
        }
      }.with_indifferent_access
    }

    let(:params) { ActionController::Parameters.new(request_params) }
    let(:model_attributes) { ImageForm.model_attributes(params) }

    context 'for complex nested associations' do
      context 'the :id attribute' do
        it 'removes the activefedora prefix' do
          created_attributes = model_attributes.fetch(:created_attributes)

          expect(created_attributes.fetch("0").fetch(:id)).to eq("de/ad/be/ef/deadbeef")
        end
      end
    end
  end
end
