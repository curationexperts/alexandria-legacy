require 'rails_helper'
require 'importer'
require 'importer/factories/image_factory'

describe Importer::ModsImporter do
  let(:image_directory) { 'spec/fixtures/images' }

  before { allow($stdout).to receive(:puts) } # squelch output

  describe "#import an Image" do
    let(:importer) { Importer::ModsImporter.new(image_directory) }
    let(:file) { 'spec/fixtures/mods/cusbspcmss36_110108.xml' }
    let(:collection_id) { 'sbhcmss36' }

    it "should create a new image and files" do
      image = nil
      expect {
        image = importer.import(file)
      }.to change { Image.count }.by(1).
      and change { GenericFile.count }.by(2)

      original = image.generic_files.first.original
      expect(original.mime_type).to eq 'image/tiff'
      expect(original.original_name).to eq 'cusbspcmss36_110108_1_a.tif'

    end

    it 'creates a collection' do
      expect {
        importer.import(file)
      }.to change { Collection.count }.by(1)

      expect(Image.count).to eq 1
      image = Image.first

      coll = Collection.find(collection_id)
      expect(coll.identifier).to eq ['SBHC Mss 36']
      expect(coll.title).to eq 'Santa Barbara picture postcards collection'
      expect(coll.members).to eq [image]
      expect(image.collections).to eq [coll]
    end

    context 'when the collection already exists' do
      let!(:coll) { Collection.create(id: collection_id) }

      it 'it adds image to existing collection' do
        expect(coll.members.count).to eq 0

        expect {
          importer.import(file)
        }.to change { Collection.count }.by(0)

        expect(coll.reload.members.count).to eq 1
      end
    end
  end

end
