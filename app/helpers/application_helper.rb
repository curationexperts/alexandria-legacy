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
    collection_id = Array(stuff.fetch(:document)[ImageIndexer::COLLECTION]).first
    if collection_id
      link_to stuff.fetch(:value).first, collections.collection_path(collection_id)
    else
      stuff.fetch(:value).first
    end
  end

  def display_notes(data)
    safe_join(Array(data[:value]), '<br/>'.html_safe)
  end

  def admin_user?
    current_user && current_user.admin?
  end

  def show_delete_link?(config, options)
    document = options.fetch(:document)
    klass = document['active_fedora_model_ssi'].constantize
    is_local = klass.included_modules.include?(LocalAuthority)

    admin_user? && is_local
  end

end
