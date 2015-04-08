class ImageForm
  include HydraEditor::Form
  self.model_class = Image

  self.terms = [:title, :accession_number, :alternative, :description,
                :series_name, :work_type, :form_of_work, :extent,
                :place_of_publication, :location, :lc_subject, :publisher,
                :creator, :contributor, :latitude, :longitude, :digital_origin,
                :sub_location, :use_restrictions, :license, :created, :issued,
                :date_valid, :date_other, :date_copyrighted, :copyright_status ]

  self.required_fields = [] # Required fields

  # ARK is a read only value on the form.
  def ark
    model.ark
  end

  # record_origin is a read only value on the form.
  def record_origin
    model.record_origin
  end

  NESTED_ASSOCIATIONS = [:created, :issued, :date_valid, :date_other, :date_copyrighted]

  protected

    def initialize_fields
      # we're making a local copy of the attributes that we can modify.
      @attributes = model.attributes
      terms.each { |key| initialize_field(key) }
    end

    # Refactor this to call super when this PR is merged: https://github.com/projecthydra-labs/hydra-editor/pull/60
    def initialize_field(key)
      if reflection = model_class.reflect_on_association(key)
        if reflection.collection?
          association = model.send(key)

          if association.empty?
            self[key] = Array(association.build)
          else
            self[key] = association
          end
        else
          raise ArgumentError, "Association ''#{key}'' is not a collection"
        end
      elsif class_name = model_class.properties[key.to_s].class_name
        self[key] += [class_name.new]
      elsif self.class.multiple?(key)
        self[key] = Array.wrap(self[key]) + ['']
      elsif self[key].blank?
        self[key] = ''
      end
    end

    def self.model_attributes(form_params)
      clean_params = super

      NESTED_ASSOCIATIONS.each do |assoc|
        Array(clean_params["#{assoc}_attributes"]).each do |index, attrs|
          strip_active_fedora_prefix!(attrs)
        end
      end

      clean_params
    end

    def self.strip_active_fedora_prefix!(model_attributes)
      if model_attributes[:id] && model_attributes[:id].present?
        model_attributes[:id].to_s.gsub! /#{fedora_url_prefix}/, ''
      end
    end

    def self.fedora_url_prefix
      "#{active_fedora_config.fetch(:url)}#{active_fedora_config.fetch(:base_path)}\/"
    end

    def self.active_fedora_config
      ActiveFedora.config.credentials
    end

    def self.permitted_time_span_params
      [ :id,
        :_destroy,
        {
          :start            => [],
          :start_qualifier  => [],
          :finish           => [],
          :finish_qualifier => [],
          :label            => [],
          :note             => []
        }
      ]
    end

    def self.build_permitted_params
      permitted = super
      permitted.delete(creator: [])
      permitted.delete(location: [])
      permitted.delete(lc_subject: [])
      permitted.delete(form_of_work: [])
      permitted.delete(license: [])
      permitted.delete(copyright_status: [])
      permitted << { creator_attributes: [:id, :_destroy] }
      permitted << { location_attributes: [:id, :_destroy] }
      permitted << { lc_subject_attributes: [:id, :_destroy] }

      # Time spans
      permitted << { created_attributes: permitted_time_span_params }
      permitted << { issued_attributes: permitted_time_span_params }
      permitted << { date_other_attributes: permitted_time_span_params }
      permitted << { date_valid_attributes: permitted_time_span_params }
      permitted << { date_copyrighted_attributes: permitted_time_span_params }

      permitted << { form_of_work_attributes: [:id, :_destroy] }
      permitted << { license_attributes: [:id, :_destroy] }
      permitted << { copyright_status_attributes: [:id, :_destroy] }
      permitted
    end
end
