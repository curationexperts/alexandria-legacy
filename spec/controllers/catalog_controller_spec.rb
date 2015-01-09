require 'rails_helper'

describe CatalogController do

  describe "the search results" do
    let!(:generic_file) { GenericFile.create! }
    let!(:image) { Image.create! }

    it "only shows images (not GenericFiles" do
      get :index
      found = assigns[:document_list].map(&:id)
      expect(found).to include(image.id)
      expect(found).to_not include(generic_file.id)
    end
  end
end
