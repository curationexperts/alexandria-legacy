class Aggregator < ActiveFedora::Base
  has_many :proxies
  belongs_to :head, predicate: ::RDF::Vocab::IANA['first'], class_name: 'Proxy'
  belongs_to :tail, predicate: ::RDF::Vocab::IANA.last, class_name: 'Proxy'

  def first
    head.target
  end

  # This can be a very expensive operation. avoid if possible
  def to_a
    @target ||= list_of_proxies.map(&:target)
  end

  def target= (collection)
    link_target(build_proxies(collection))
  end

  def target_ids=(object_ids)
    link_target(build_proxies_with_ids(object_ids))
  end

  # Set the links on the nodes in the list
  def link_target(new_proxies)
    new_proxies.each_with_index do |proxy, idx|
      proxy.next_id = new_proxies[idx+1].id unless new_proxies.length - 1 <= idx
      proxy.prev_id = new_proxies[idx-1].id unless idx == 0
    end

    self.head = new_proxies.first
    self.tail = new_proxies.last
    self.proxies = new_proxies
  end

  # TODO clear out the old proxies (or reuse them)
  def build_proxies(objects)
    # need to create the proxies before we can add the links otherwise the linked to resource won't exist
    objects.map do |object|
      Proxy.create(id: mint_proxy_id, target: object)
    end
  end

  # TODO clear out the old proxies (or reuse them)
  def build_proxies_with_ids(object_ids)
    # need to create the proxies before we can add the links otherwise the linked to resource won't exist
    object_ids.map do |file_id|
      Proxy.create(id: mint_proxy_id, target_id: file_id)
    end
  end

  def target_ids
    list_of_proxies.map(&:target_id)
  end

  # @param obj [ActiveFedora::Base]
  def << (obj)
    node = if persisted?
             proxies.create(id: mint_proxy_id, target: obj, prev: tail)
           else
             proxies.build(id: mint_proxy_id, target: obj, prev: tail)
           end
    # set the old tail, if present, to have this new proxy as its next
    self.tail.update(next: node) if tail
    # update the tail to point at the new node
    self.tail = node
    # if this is the first node, set it to be the head
    self.head = node unless head
    reset_target!
  end

  def mint_proxy_id
    "#{id}/#{SecureRandom.uuid}"
  end

  def self.find_or_initialize(id)
    find(id)
  rescue ActiveFedora::ObjectNotFoundError
    new(id)
  end

  def reset_target!
    @proxy_list = nil
    @target = nil
  end

  # return the proxies in order
  def list_of_proxies
    @proxy_list ||= if head
      head.as_list
    else
      []
    end
  end
end
