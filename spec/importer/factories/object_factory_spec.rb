require 'rails_helper'
require 'importer'

describe ObjectFactory do

  describe '#find_or_create_contributors' do
    let(:fields) { [:creator, :collector, :contributor] }
    let(:afmc) { 'http://id.loc.gov/authorities/names/n87914041' }
    let(:joel) { 'Joel Conway' }

    # The attributes hash that comes from the ModsParser
    let(:attributes) do
      afmc_uri = RDF::URI.new(afmc)
      { creator: [afmc_uri],
        contributor: [afmc_uri, { name: joel, type: 'personal' }] }
    end

    subject { CollectionFactory.new(attributes, './tmp') }

    context "when contributors don't exist yet" do
      it "creates the contributors and returns a hash of the contributors" do
        expect(Person.count).to eq 0
        contributors = nil

        expect {
          contributors = subject.find_or_create_contributors(fields, attributes)
        }.to change { Person.count }.by(1)

        expect(contributors.keys.sort).to eq [:contributor, :creator]
        expect(contributors[:creator].first.class).to eq RDF::URI
        expect(contributors[:creator]).to eq [afmc]
        expect(contributors[:contributor].count).to eq 2
        expect(contributors[:contributor].map(&:class).uniq).to eq [RDF::URI]
        new_person = Person.first
        expect(new_person.foaf_name).to eq joel
        expect(contributors[:contributor]).to include new_person.uri
        expect(contributors[:contributor]).to include afmc
      end
    end

    context "when contributors already exist" do
      let!(:person) { Person.create(foaf_name: joel) }

      it "returns a hash of the contributors" do
        contributors = nil
        expect {
          contributors = subject.find_or_create_contributors(fields, attributes)
        }.to change { Person.count }.by(0)

        expect(contributors.keys.sort).to eq [:contributor, :creator]
        expect(contributors[:creator].first.class).to eq RDF::URI
        expect(contributors[:creator]).to eq [afmc]
        expect(contributors[:contributor].count).to eq 2
        expect(contributors[:contributor].map(&:class).uniq).to eq [RDF::URI]
        expect(contributors[:contributor]).to include afmc
        expect(contributors[:contributor]).to include person.uri
      end
    end
  end

end
