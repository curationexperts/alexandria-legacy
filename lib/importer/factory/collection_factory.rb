module Importer::Factory
  class CollectionFactory < ObjectFactory
    def find
      klass.where(accession_number_ssim: attributes[:accession_number].first).first
    end

    def klass
      Collection
    end
  end
end
