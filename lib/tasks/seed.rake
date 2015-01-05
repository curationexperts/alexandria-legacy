require 'rake'

namespace :alexandria do
  namespace :solr do
    desc "Index test data into solr"
    task :seed do
      docs = YAML::load(File.open(File.expand_path(File.join('spec', 'fixtures', 'sample_solr_documents.yml'), Rails.root)))
      Blacklight.solr.add docs
      Blacklight.solr.commit
    end
  end
end
