require 'rails_helper'

describe ImageForm do
  describe ".build_permitted_params" do
    subject { described_class.build_permitted_params }

    it "should include complex fields" do
      expect(subject).to include(creator_attributes: [:id])
      expect(subject).to include(location_attributes: [:id])
      expect(subject).to include(lc_subject_attributes: [:id])
      expect(subject).to include(form_of_work_attributes: [:id])
    end
  end
end
