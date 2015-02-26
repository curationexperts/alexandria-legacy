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
    link_to stuff.fetch(:value).first, collections.collection_path(stuff.fetch(:document)[ImageIndexer::COLLECTION].first)
  end

  def display_dates(args)
    start_field = args.fetch(:field)
    end_field = start_field.sub(/_start_/, '_end_')
    doc = args.fetch(:document)
    start_date = doc[start_field]
    end_date = doc[end_field]

    if start_date && end_date
      "#{Array(start_date).first}-#{Array(end_date).first}"
    elsif start_date
      Array(start_date).join(', ')
    elsif end_date
      Array(end_date).join(', ')
    end
  end

end
