# An RDF store on Solr
module RDF
  class Solr < ::RDF::Repository
    attr_reader :solr, :options

    DEFAULT_GRAPH_FIELD = 'graph_ss'

    def initialize(solr_conn=nil, options={})
      @solr = solr_conn
      @options = options
    end

    def graph_field
      @graph_field ||= options[:graph_field] || DEFAULT_GRAPH_FIELD
    end

    # @see RDF::Mixin::Queryable#query_pattern
    def query_pattern(pattern, options = {}, &block)
      raise "Unsupported query_pattern, #{pattern}" unless pattern.predicate.nil? && pattern.object.nil?
      result = solr.get 'select', params: { q: "_query_:\"{!raw f=id}#{pattern.subject}\"", fl: graph_field }
      first_result = result.fetch('response'.freeze).fetch('docs'.freeze).first
      return unless first_result
      raw_graph = first_result.fetch(graph_field)
      RDF::Reader.for(:ttl).new(raw_graph) do |reader|
        reader.each_statement(&block)
      end
    end

    def insert_graph(graph)
      docs = split_graph(graph).map do |id, graph|
        { id: id, graph_field => graph.dump(:ttl) }
      end
      solr.add docs, add_attributes: add_attributes
    end

    def add_attributes
      # commitWithin is time in ms
      { commitWithin: 10 }
    end

    # split one graph into several graphs
    def split_graph(graph)
      graphs_by_uri = {}
      bnodes = {}
      graph.each_statement do |s|
        # TODO handle b-nodes
        next if s.subject.node? || s.object.node?
        graphs_by_uri[s.subject] ||= RDF::Graph.new
        graphs_by_uri[s.subject].insert s
      end
      graphs_by_uri
    end
  end
end
