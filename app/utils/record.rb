module Record

  # Input should be an ActiveFedora::Base object
  def self.references_for(record)
    record.resource.query(object: RDF::URI(record.uri)).map{|statement| ActiveFedora::Base.uri_to_id(statement.subject) }
  end

end
