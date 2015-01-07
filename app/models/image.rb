class Image < ActiveFedora::Base
  include Metadata

  def self.indexer
    DeepIndexer
  end
end
