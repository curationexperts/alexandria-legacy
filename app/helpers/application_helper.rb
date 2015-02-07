module ApplicationHelper

  def on_campus_network_prefixes
    ['128.111', '169.231']
  end

  def on_campus?
    on_campus_network_prefixes.any? {|prefix| request.remote_ip.start_with?(prefix) }
  end

  def editor?(_, stuff)
    document = stuff.fetch(:document)
    can? :edit, document
  end

  def link_to_collection(stuff)
    link_to stuff.fetch(:value).first, collections.collection_path(stuff.fetch(:document)[Solrizer.solr_name(:collection)].first)
  end

end
