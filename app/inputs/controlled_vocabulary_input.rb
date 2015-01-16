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
        value = value.rdf_label.first
        options[:name] = "#{@builder.object_name}[#{attribute_name}_attributes][#{index}][id]"
      end
      options[:value] = value
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
      uri_field = nil
      if uri
        options[:name] = options[:name].gsub("id", "hidden_label")
        options[:value] = uri
        uri_field = @builder.hidden_field(attribute_name, options)
      end
      text_field + uri_field
    end
end
