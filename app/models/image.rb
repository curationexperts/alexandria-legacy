class Image < ActiveFedora::Base
  include Metadata
  has_many :generic_files

  def self.indexer
    DeepIndexer
  end
end
