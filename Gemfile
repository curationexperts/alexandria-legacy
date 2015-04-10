source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
# Use postgres in production as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'hydra-head', '9.1.1'
# gem 'active-fedora', '~> 9.0.7'
gem 'active-fedora', github: 'projecthydra/active_fedora', branch: 'fix_inverse_of_has_many'

gem 'active-triples', github: 'jcoyne/ActiveTriples', branch: 'dce-ucsb'
gem 'hydra-editor', '~> 1.0.3'
gem 'hydra-role-management'
gem 'hydra-collections', '~> 5.0.1'
gem 'rdf-vocab', '~> 0.7.0'
gem 'rdf-marmotta', '~> 0.0.8'

# Blacklight 5.11.3 causes a bug on the show collections page.
# Shouldn't be too hard to work through, but no time now.
gem 'blacklight', '5.11.2'

gem 'rsolr', '~> 1.0.12'
gem 'activefedora-aggregation', '~> 0.2.0'

gem 'mods', '~> 2.0.3'
gem 'oargun', github: 'curationexperts/oargun'
gem 'linked_vocabs', github: 'no-reply/linked_vocabs' # Waiting on 0.3.0
gem 'blacklight-gallery'
gem 'riiif', '~> 0.1.0'
gem 'ezid-client', '~> 1.0'
# This stuff is pre 0.5.0
gem 'qa', github: 'projecthydra-labs/questioning_authority', branch: 'sub_authorities_to_classes'

gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype', ref: '384fcb5d11b6'

gem 'devise'
gem 'devise-guests', '~> 0.3'

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-activemodel-mocks'
  gem 'factory_girl_rails', '~> 4.4'
  gem 'jettywrapper'
  # gem 'http_logger'
  gem 'capybara'
  gem 'byebug'
  gem 'sqlite3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'awesome_print'
end

group :test do
  gem 'timecop', '0.7.3'
  gem 'webmock', require: false
  gem 'vcr'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
end

