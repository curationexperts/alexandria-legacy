class Proxy < ActiveFedora::Base
  belongs_to :aggregator, predicate: ::RDF::Vocab::ORE.proxyIn
  belongs_to :target, predicate: ::RDF::Vocab::ORE.proxyFor, class_name: 'ActiveFedora::Base'
  belongs_to :next, predicate: ::RDF::Vocab::IANA.next, class_name: 'Proxy'
  belongs_to :prev, predicate: ::RDF::Vocab::IANA.prev, class_name: 'Proxy'

  def as_list
    if self.next
      [self] + self.next.as_list
    else
      [self]
    end
  end

end
