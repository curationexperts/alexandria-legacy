require 'rails_helper'
require 'traject/command_line'

describe 'Traject importer' do
  describe 'import a cylinder record' do
    let(:traject_config) { File.join(Rails.root, 'lib', 'traject', 'audio_config.rb') }
    let(:command) { Traject::CommandLine.new(['-c', traject_config, marc_file]) }

    let!(:collection) { Collection.create!(title: ['Wax Cylinders'], accession_number: ['Cylinders']) }

    before do
      ActiveFedora::Base.find(id).destroy(eradicate: true) if ActiveFedora::Base.exists? id

      AudioRecording.destroy_all
      Organization.destroy_all
      Person.destroy_all
      Group.destroy_all

      # Less output when running specs
      # allow($stdout).to receive(:puts)
      # allow($stderr).to receive(:puts)

      # Don't fetch external records during specs
      allow_any_instance_of(RDF::DeepIndexingService).to receive(:fetch_external)
    end

    context "marcfile with language" do
      let(:marc_file) { File.join(fixture_path, 'marcxml', 'cylinder_sample_marc.xml') }
      # IDs from the MARC file
      let(:id) { 'f3999999' }

      it 'creates the audio record' do
        expect(command.execute).to be true

        # These new records should have been created
        expect(AudioRecording.count).to eq 1
        expect(Person.count).to eq 3
        expect(Group.count).to eq 1
        expect(Organization.count).to eq 2

        audio = AudioRecording.first

        expect(audio.language.first.rdf_subject).to eq RDF::URI('http://id.loc.gov/vocabulary/iso639-2/eng')
        expect(audio.matrix_number).to eq []
        expect(audio.in_collections).to eq [collection]

        # Check all the contributors are correct
        [:performer, :instrumentalist, :lyricist, :arranger, :singer].each do |property_name|
          contributor = audio.send(property_name)
          expect(contributor.map(&:class).uniq).to eq [Oargun::ControlledVocabularies::Creator]
        end

        # Check local authorities were created for performers
        ids = audio.performer.map { |s| s.rdf_label.first.gsub(%r{^.*\/}, '') }
        perfs = ids.map { |id| ActiveFedora::Base.find(id) }
        org = perfs.find { |target| target.is_a? Organization }
        group = perfs.find { |target| target.is_a? Group }
        person = perfs.find { |target| target.is_a? Person }

        expect(org.foaf_name).to eq 'United States. National Guard Bureau. Fife and Drum Corps.'
        expect(group.foaf_name).to eq 'Allen field c text 1876 field q text'
        expect(person.foaf_name).to eq 'Milner, David,'

        # Check local authorities were created for singers
        ids = audio.singer.map { |s| s.rdf_label.first.gsub(Regexp.new('^.*\/'), '') }
        singers = ids.map { |id| ActiveFedora::Base.find(id) }
        org, person = singers.partition { |obj| obj.is_a?(Organization) }.map(&:first)
        expect(org.foaf_name).to eq 'Louisiana Five. text from b.'
        expect(person.foaf_name).to eq 'Collins, Arthur.'
        expect(person.class).to eq Person

        # This is the same person who is listed as 3 different
        # types of contributor.
        person_id = audio.instrumentalist.first.rdf_label.first.gsub(Regexp.new('^.*\/'), '')
        person = Person.find(person_id)
        expect(person.foaf_name).to eq 'Allen, Thos. S., 1876-1919.'

        [:instrumentalist, :lyricist, :arranger].each do |property_name|
          contributor = audio.send(property_name)
          contributor_id = contributor.first.rdf_label.first.gsub(Regexp.new('^.*\/'), '')
          expect(contributor_id).to eq person.id
        end
      end
    end

    context "marc file without language" do
      let(:marc_file) { File.join(fixture_path, 'marcxml', 'cylinder_sample_without_language_marc.xml') }
      # IDs from the MARC file
      let(:id) { 'f3888888' }

      it 'creates the audio record' do
        expect(command.execute).to be true

        # These new records should have been created
        expect(AudioRecording.count).to eq 1
        audio = AudioRecording.first
        expect(audio.language).to eq []
      end
    end
  end
end
