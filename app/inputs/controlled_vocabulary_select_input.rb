# This allows you to select which vocabulary is controlling the field
class ControlledVocabularySelectInput < ControlledVocabularyInput

  protected
    def build_field(value, index)
      select_tag + template.content_tag(:div, class: 'col-md-8') { super }
    end

    def select_tag
      template.content_tag(:div, class: 'col-md-4') do
        template.select_tag('vocab', template.options_for_select({ 'LC Subject Headings' => 'lcsh' }), class: 'form-control')
      end
    end

    def inner_wrapper
       <<-HTML
         <li class="field-wrapper row">
             #{yield}
         </li>
       HTML
    end
end
