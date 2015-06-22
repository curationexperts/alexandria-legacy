module LocalAuthority
  extend ActiveSupport::Concern

  def referenced_by
    self.resource.query(object: RDF::URI(self.uri)).map{|statement| ActiveFedora::Base.uri_to_id(statement.subject) }
  end

end
