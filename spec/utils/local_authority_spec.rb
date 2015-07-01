require 'rails_helper'

describe LocalAuthority do

  describe '::local_authority_models' do
    subject { LocalAuthority.local_authority_models }

    it 'returns all the classes that are local authorities' do
      expect(subject).to eq [Agent, Person, Group, Organization, Topic]
    end
  end

  describe '::local_authority?' do
    subject { LocalAuthority.local_authority?(record) }

    context 'for a fedora object' do
      context 'that is a local authority' do
        let(:record) { Person.new }
        it { is_expected.to eq true }
      end

      context 'that isnt a local authority' do
        let(:record) { Image.new }
        it { is_expected.to eq false }
      end
    end

    context 'for a solr document' do
      context 'that is a local authority' do
        let(:record) { SolrDocument.new('active_fedora_model_ssi' => 'Topic') }
        it { is_expected.to eq true }
      end

      context 'that isnt a local authority' do
        let(:record) { SolrDocument.new('active_fedora_model_ssi' => 'Image') }
        it { is_expected.to eq false }
      end
    end
  end

end
