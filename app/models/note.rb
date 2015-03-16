class Note < ActiveFedora::Base
  property :value, predicate: ::RDF::Vocab::MODS.noteGroupValue, multiple: false
  property :note_type, predicate: ::RDF::Vocab::MODS.noteGroupType, multiple: false
end
