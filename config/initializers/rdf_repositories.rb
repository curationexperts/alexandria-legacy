def configure_repositories
  ActiveTriples::Repositories.clear_repositories!
  ActiveTriples::Repositories.add_repository :vocabs, RDF::Solr.new()
end

configure_repositories
Rails.application.config.to_prepare do
  configure_repositories
end
