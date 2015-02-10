factory_dir = File.join(File.dirname(__FILE__), 'importer', 'factories')
Dir[File.join(factory_dir, '**', '*.rb')].each do |file|
  require file
end

module Importer
  extend ActiveSupport::Autoload
  autoload :ModsImporter
  autoload :ModsParser
end
