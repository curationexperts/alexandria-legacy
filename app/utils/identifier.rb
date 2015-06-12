module Identifier
  def self.treeify(identifier)
    (identifier.scan(/..?/).first(4) + [identifier]).join('/')
  end

  def self.noidify(id)
    id.to_s.split('/')[-1]
  end

  def self.ark_to_noid(ark)
    if matches = /^ark:\/\d{5}\/(f\w{7,9})$/.match(ark)
      matches[1]
    end
  end

  def self.ark_to_id(ark)
    if a = ark_to_noid(ark)
      treeify(a)
    end
  end
end
