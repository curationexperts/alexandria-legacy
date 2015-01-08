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

end

