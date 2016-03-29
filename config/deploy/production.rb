set :stage, :production
set :rails_env, 'production'

set :default_env,
    'http_proxy' => 'http://10.3.100.201:3128',
    'https_proxy' => 'http://10.3.100.201:3128'

server ENV['SERVER'], user: ENV.fetch('USER', 'adrl'), roles: [:web, :app, :db, :resque_pool]
set :ssh_options, port: 22, keys: [ENV.fetch('KEYFILE', '~/.ssh/id_rsa')]
