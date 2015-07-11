require 'rails_helper'

describe DownloadsController do

  describe '#asset' do
    before do
      allow(controller).to receive(:params).and_return(id: 'ca%2Fc0%2Ff3%2Ff4%2Fcac0f3f4-ea8f-414d-a7a5-3253ef003b1a')
    end
    it "decodes the id" do
      expect(ActiveFedora::Base).to receive(:find).with('ca/c0/f3/f4/cac0f3f4-ea8f-414d-a7a5-3253ef003b1a')
      controller.asset
    end
  end

end
