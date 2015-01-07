def configure_repositories
  ActiveTriples::Repositories.clear_repositories!
  if Rails.env.test?
    ActiveTriples::Repositories.add_repository :vocabs, RDF::Repository.new
  else
    ActiveTriples::Repositories.add_repository :vocabs, RDF::Repository.new
    #RDF::Mongo::Repository.new(:host => ENV['MONGODB_HOST'] || "localhost", :port => ENV["MONGODB_PORT"] || 27017, :collection => 'vocabs')
  end
end
configure_repositories
Rails.application.config.to_prepare do
  configure_repositories
end
