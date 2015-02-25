require 'rails_helper'
require 'importer'

describe Importer::ModsImporter do
  let(:image_directory) { 'spec/fixtures/images' }
  let(:importer) { Importer::ModsImporter.new(image_directory) }

  before { allow($stdout).to receive(:puts) } # squelch output

  describe "#import an Image" do
    let(:file) { 'spec/fixtures/mods/cusbspcmss36_110108.xml' }
    let(:collection_id) { 'sbhcmss36' }

    it "should create a new image and files" do
      image = nil
      expect_any_instance_of(Ezid::Identifier).to receive(:target=).with(/http:\/\/test\.host\/catalog\/ark:\/99999\/fk4\w{7}$/)
      expect {
        image = importer.import(file)
      }.to change { Image.count }.by(1).
      and change { GenericFile.count }.by(2)

      original = image.generic_files.first.original
      expect(original.mime_type).to eq 'image/tiff'
      expect(original.original_name).to eq 'cusbspcmss36_110108_1_a.tif'

      # Image.reload doesn't clear @file_association
      reloaded = Image.find(image.id)
      expect(reloaded.generic_files.first).not_to be_nil
      expect(reloaded.generic_files.aggregation.head.next).not_to be_nil

      expect(reloaded.identifier.first).to match /^ark:\/99999\/fk4\w{7}$/
    end

    it 'creates a collection' do
      expect {
        importer.import(file)
      }.to change { Collection.count }.by(1)

      expect(Image.count).to eq 1
      image = Image.first

      coll = Collection.find(collection_id)
      expect(coll.accession_number).to eq ['SBHC Mss 36']
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

  describe "#import a Collection" do
    let(:file) { 'spec/fixtures/mods/sbhcmss78_FlyingAStudios_collection.xml' }

    it 'creates a collection' do
      coll = nil
      expect {
        coll = importer.import(file)
      }.to change { Collection.count }.by(1)

      expect(coll.id).to match /^fk4\w{7}$/
      expect(coll.accession_number).to eq ['SBHC Mss 78']
      expect(coll.title).to eq 'Joel Conway / Flying A Studio photograph collection'
    end

    context 'when the collection already exists' do
      let!(:existing) { Collection.create(id: 'fk4bv7mw47', accession_number: ['SBHC Mss 78']) }

      it 'it adds metadata to existing collection' do
        coll = nil
        expect {
          coll = importer.import(file)
        }.to change { Collection.count }.by(0)

        expect(coll.id).to eq 'fk4bv7mw47'
        expect(coll.accession_number).to eq ['SBHC Mss 78']
        expect(coll.title).to eq 'Joel Conway / Flying A Studio photograph collection'
      end
    end
  end

end
