class ControlledVocabularyInput < MultiValueInput

  protected

    # Delegate this completely to the form.
    def collection
      @collection ||= object[attribute_name]
    end

    def build_field(value, index)
      options = input_html_options.dup

      if value.respond_to? :rdf_label
        uri = value.rdf_subject.to_s
        if value.node?
          options[:name] = "#{@builder.object_name}[#{attribute_name}_attributes][#{index}][id]"
          options[:value] = ''
        else
          # TODO fetch is slow
          value.fetch
          options[:readonly] = true
          options[:value] = value.rdf_label.first
          options[:name] = "#{@builder.object_name}[#{attribute_name}_attributes][#{index}][hidden_label]"
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
      elsif uri
        @builder.text_field(attribute_name, options)
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
end
