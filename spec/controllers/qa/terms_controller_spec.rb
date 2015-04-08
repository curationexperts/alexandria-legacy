require 'rails_helper'

describe Qa::TermsController do
  routes { Qa::Engine.routes }

  describe "license vocabulary" do
    it "returns terms" do
      get :search, vocab: 'local', sub_authority: 'license', q: 'ND'
      expect(response).to be_success
    end
  end

  describe "sub_location vocabulary" do
    it "returns terms" do
      get :search, vocab: 'local', sub_authority: 'sub_location', q: 'ND'
      expect(response).to be_success
    end
  end
end