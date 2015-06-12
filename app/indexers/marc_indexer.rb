class MarcIndexer < ActiveFedora::IndexingService
  def generate_solr_document
    super.tap do |solr_doc|
      marc_ds = object.marc.content
      marc_indexer = Traject::Indexer.new writer_class_name: "QueueWriter"
      marc_indexer.load_config_file('traject_config.rb')
      marc_indexer.process(marc_ds)
      solr_doc.merge! marc_indexer.writer.queue.pop
    end
  end
end
