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

  describe "with multiple start dates" do
    before do
      subject.start = ['1930', '1912', '1920']
    end

    it 'finds the earliest year' do
      expect(subject.earliest_year).to eq '1912'
    end

    it 'sorts on the earliest year' do
      expect(subject.sortable).to eq '1912'
    end
  end

end
