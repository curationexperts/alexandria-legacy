class ControlledVocabularyInput < MultiValueInput

  protected

    # Delegate this completely to the form.
    def collection
      @collection ||= object[attribute_name]
    end

    def build_field(value, index)
      options = input_html_options.dup

      if value.respond_to? :rdf_label
        if value.node?
          build_options_for_new_row(attribute_name, index, options)
        else
          build_options_for_existing_row(attribute_name, index, value, options)
        end
      end
      if @rendered_first_element
        options[:id] = nil
        options[:required] = nil
      else
        options[:id] ||= input_dom_id
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
      text_field + hidden_id_field(value, options)
    end

    def hidden_id_field(value, options)
      return if value.node?
      options[:name] = options[:name].gsub("hidden_label", "id")
      options[:value] = value.rdf_subject
      @builder.hidden_field(attribute_name, options)
    end

    def build_options_for_new_row(attribute_name, index, options)
      options[:name] = "#{@builder.object_name}[#{attribute_name}_attributes][#{index}][id]"
      options[:value] = ''
    end

    def build_options_for_existing_row(attribute_name, index, value, options)
      # TODO fetch is slow
      begin
        value.fetch
        options[:value] = value.rdf_label.first
      rescue IOError
        options[:value] = "Error fetching value for #{value.rdf_subject}"
      end
      options[:readonly] = true
      options[:name] = "#{@builder.object_name}[#{attribute_name}_attributes][#{index}][hidden_label]"
    end
end
