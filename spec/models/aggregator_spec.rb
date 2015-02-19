require 'rails_helper'

describe Aggregator do
  let(:target1) { ActiveFedora::Base.create }
  let(:target2) { ActiveFedora::Base.create }
  let(:aggregator) { Aggregator.create }

  describe "#target=" do
    before do
      aggregator.target= [target1, target2]
    end
    subject { aggregator.to_a }
    it { is_expected.to eq [target1, target2] }
  end

  describe "#<<" do
    context "the first one" do
      before do
        aggregator << target1
      end

      it "should set head and tail" do
        expect(aggregator.head.target).to eq target1
        expect(aggregator.head).to eq aggregator.tail
      end
    end

    context "the second one" do
      before do
        aggregator << target1
        aggregator << target2
      end

      it "should set head and tail" do
        expect(aggregator.head.target).to eq target1
        expect(aggregator.tail.target).to eq target2
      end

      it "should establish next on the proxy" do
        expect(aggregator.head.next).to eq aggregator.tail
      end
    end
  end

  describe "readers" do
    before do
      aggregator << target1
      aggregator << target2
    end

    describe "#target_ids" do
      subject { aggregator.target_ids }
      it { is_expected.to eq [target1.id, target2.id] }
    end
  end
end
