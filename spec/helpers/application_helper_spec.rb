require 'rails_helper'

describe ApplicationHelper do

  def stub_remote_ip(ip)
    allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip) { ip }
  end

  describe '#on_campus?' do
    it 'designates whether or not the user is on campus' do
      stub_remote_ip('123.456.789.111')
      expect(helper.on_campus?).to eq false

      stub_remote_ip('128.111.111.111')
      expect(helper.on_campus?).to eq true

      stub_remote_ip('169.231.111.111')
      expect(helper.on_campus?).to eq true
    end
  end

  describe "#editor?" do
    before { allow(controller).to receive(:current_user).and_return(user) }
    subject { helper.editor?(nil, { document: SolrDocument.new }) }

    context "for an admin" do
      let(:user) { create :admin }
      it { is_expected.to be true }
    end

    context "for a non-admin user" do
      let(:user) { create :user }
      it { is_expected.to be false }
    end
  end

  describe "#link_to_collection" do
    let(:document) { SolrDocument.new(collection_tesim: ['1234'] ) }
    subject { helper.link_to_collection(value: ['collection title'], document: document) }
    it { is_expected.to eq '<a href="/collections/1234">collection title</a>' }
  end

end

