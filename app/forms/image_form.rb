class ImageForm
  include HydraEditor::Form
  self.model_class = Image
  self.terms = [:title, :creator, :contributor, :description, :location, :lc_subject,
                :publisher, :workType, :date, :earliestDate, :issued, :latestDate]
  self.required_fields = [] # Required fields

  protected
    def initialize_fields
      # we're making a local copy of the attributes that we can modify.
      @attributes = model.attributes
      terms.each { |key| initialize_field(key) }
    end

    # Refactor this to call super when this PR is merged: https://github.com/projecthydra-labs/hydra-editor/pull/60
    def initialize_field(key)
      if class_name = model_class.properties[key.to_s].class_name
        self[key] += [class_name.new]
      elsif self.class.multiple?(key)
        self[key] = Array.wrap(self[key]) + ['']
      elsif self[key].blank?
        self[key] = ''
      end
    end

    def self.build_permitted_params
      permitted = super
      permitted << { creator_attributes: [:id] }
      permitted
    end
end
