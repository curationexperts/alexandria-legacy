class Etd < ActiveFedora::Base
  contains 'marc'

  def self.indexer
    MarcIndexer
  end
end
