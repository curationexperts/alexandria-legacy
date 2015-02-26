require 'rails_helper'
require 'importer'

describe Importer::ModsImporter do
  let(:image_directory) { 'spec/fixtures/images' }
  let(:importer) { Importer::ModsImporter.new(image_directory) }

  before { allow($stdout).to receive(:puts) } # squelch output

  describe "#import an Image" do
    let(:file) { 'spec/fixtures/mods/cusbspcmss36_110108.xml' }

    let(:identifier1) { double('ARK1', id: 'ark:/99999/fk41234567') }
    let(:identifier2) { double('ARK2', id: 'ark:/99999/fk49876543') }

    it "creates a new image, files, and a collection" do
      image = nil
      expect(identifier1).to receive(:target=).with(/http:\/\/test\.host\/catalog\/ark:\/99999\/fk41234567$/)
      expect(identifier2).to receive(:target=).with(/http:\/\/test\.host\/catalog\/ark:\/99999\/fk49876543$/)
      expect(identifier1).to receive(:save)
      expect(identifier2).to receive(:save)
      expect_any_instance_of(ImageFactory).to receive(:mint_ark).and_return(identifier1)
      expect_any_instance_of(CollectionFactory).to receive(:mint_ark).and_return(identifier2)

      expect {
        image = importer.import(file)
      }.to change { Image.count }.by(1).
        and change { GenericFile.count }.by(2).
        and change { Collection.count }.by(1)

      original = image.generic_files.first.original
      expect(original.mime_type).to eq 'image/tiff'
      expect(original.original_name).to eq 'cusbspcmss36_110108_1_a.tif'

      # Image.reload doesn't clear @file_association
      reloaded = Image.find(image.id)
      expect(reloaded.generic_files.first).not_to be_nil
      expect(reloaded.generic_files.aggregation.head.next).not_to be_nil

      expect(reloaded.identifier.first).to match /^ark:\/99999\/fk4\w{7}$/

      coll = reloaded.collections.first
      expect(coll.accession_number).to eq ['SBHC Mss 36']
      expect(coll.title).to eq 'Santa Barbara picture postcards collection'
      expect(coll.members).to eq [reloaded]

      solr_doc = ActiveFedora::SolrService.query("id:#{image.id}").first
      expect(solr_doc['collection_label_ssim']).to eq ['Santa Barbara picture postcards collection']
    end

    context 'when the collection already exists' do
      let!(:coll) { Collection.create(id: 'fk44174k70', accession_number: ['SBHC Mss 36']) }
      before do
        # skip creating files
        allow_any_instance_of(ImageFactory).to receive(:after_create)
      end

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
