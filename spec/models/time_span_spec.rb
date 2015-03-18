require 'rails_helper'

describe TimeSpan do
  describe "#start" do
    before do
      subject.start = ['1930']
    end
    it "has start" do
      expect(subject.start).to eq ['1930']
    end
  end
end
