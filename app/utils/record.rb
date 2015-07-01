module Record

  # This method finds all fedora records that have a reference to this record in any metadata field.
  # The input should be an ActiveFedora::Base object.
  # The return value will be an array of fedora IDs.
  def self.references_for(record)
    record.resource.query(object: record.uri).map{|statement| ActiveFedora::Base.uri_to_id(statement.subject) }
  end

end
