require 'rails_helper'

describe RDF::Solr do
  let(:graph) { RDF::Graph.load('spec/fixtures/sh85062487.rdf') }
  let(:solr) { Blacklight.default_index.connection }
  let(:repo) { described_class.new(solr) }
  let(:uri) { RDF::URI('http://id.loc.gov/authorities/subjects/sh85062487') }
  let(:pattern) { RDF::Query::Pattern.from([uri, nil, nil]) }

  it "should store graphs" do
    repo.insert_graph(graph)
    sleep 2 #wait for solr to commit

    label = nil
    repo.query_pattern(pattern) do |stmt|
      label = stmt.object if stmt.predicate == RDF::SKOS.prefLabel
    end
    expect(label.to_s).to eq 'Hotels'
  end

end
