set :stage, :production
set :rails_env, 'production'

server ENV['SERVER'], user: 'deploy', roles: [:web, :app, :db]
set :ssh_options, port: 22, keys: ['~/.ssh/id_rsa']
