require 'rails_helper'
require 'object_factory_writer'

describe ObjectFactoryWriter do
  let(:writer) { described_class.new({}) }

  describe "#put" do
    let(:traject_context) { double(output_hash: traject_hash) }
    let(:traject_hash) { { 'author' => ['Valerie'], 'title' => ["How to be awesome"],
                           'created_start' => ['2013'],
                           'filename' => ['My_stuff.pdf'],
                           'isbn' => ['1234'],
                           'identifier' => ['ark:/99999/fk4zp46p1g'],
                           'id' => ['fk/4z/p4/6p/fk4zp46p1g'],
    } }
    it "calls the etd factory" do
      expect(writer).to receive(:build_object).with(
        author: ['Valerie'],
        isbn: ['1234'],
        identifier: ['ark:/99999/fk4zp46p1g'],
        id: 'fk/4z/p4/6p/fk4zp46p1g',
        files: ['My_stuff.pdf'], created_attributes: [{ start: ['2013'] }],
        admin_policy_id: "authorities/policies/public",
        collection: { id: "etds", title: "Electronic Theses and Dissertations", accession_number: ['etds'] },
        title: 'How to be awesome',
      )

      writer.put(traject_context)

    end
  end
end
