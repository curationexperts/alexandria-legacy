class ControlledVocabularyInput < MultiValueInput

  protected

    # Delegate this completely to the form.
    def collection
      @collection ||= object[attribute_name]
    end

    def build_field(value, index)
      options = input_html_options.dup
      value = value.resource if value.kind_of? ActiveFedora::Base

      if value.respond_to? :rdf_label
        options[:name] = name_for(attribute_name, index, 'hidden_label'.freeze)
        options[:id] = id_for(attribute_name, index, 'hidden_label'.freeze)
        if value.node?
          build_options_for_new_row(attribute_name, index, options)
        else
          build_options_for_existing_row(attribute_name, index, value, options)
        end
      end
      if @rendered_first_element
        options[:required] = nil
      end
      options[:class] ||= []
      options[:class] += ["#{input_dom_id} form-control multi-text-field"]
      options[:'aria-labelledby'] = label_id
      @rendered_first_element = true
      text_field = if options.delete(:type) == 'textarea'.freeze
        @builder.text_area(attribute_name, options)
      else
        @builder.text_field(attribute_name, options)
      end
      text_field + hidden_id_field(value, index) + destroy_widget(attribute_name, index)
    end

    def destroy_widget(attribute_name, index)
      @builder.hidden_field(attribute_name,
                            name: name_for(attribute_name, index, '_destroy'.freeze),
                            id: id_for(attribute_name, index, '_destroy'.freeze),
                            value: "", data: { destroy: true })
    end

    def hidden_id_field(value, index)
      name = name_for(attribute_name, index, 'id'.freeze)
      id = id_for(attribute_name, index, 'id'.freeze)
      hidden_value = value.node? ? '' : value.rdf_subject
      @builder.hidden_field(attribute_name, name: name, id: id, value: hidden_value, data: { id: 'remote' })
    end

    def build_options_for_new_row(attribute_name, index, options)
      options[:value] = ''
    end

    def build_options_for_existing_row(attribute_name, index, value, options)
      options[:value] = value.rdf_label.first || "Unable to fetch label for #{value.rdf_subject}"
      options[:readonly] = true
    end

    def name_for(attribute_name, index, field)
      "#{@builder.object_name}[#{attribute_name}_attributes][#{index}][#{field}]"
    end

    def id_for(attribute_name, index, field)
      [@builder.object_name, "#{attribute_name}_attributes", index, field].join('_'.freeze)
    end
end
