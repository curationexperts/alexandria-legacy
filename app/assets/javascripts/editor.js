//= require hydra-editor/hydra-editor
//= require handlebars-v3.0.0.js

var source = "<li class=\"field-wrapper input-group input-append\">" +
  "<input class=\"string {{class}} optional form-control image_{{name}} form-control multi-text-field\" name=\"image[{{name}}_attributes][{{index}}][hidden_label]\" value=\"\" id=\"image_{{name}}_attributes_{{index}}_hidden_label\" data-attribute=\"{{name}}\" type=\"text\">" +
  "<input name=\"image[{{name}}_attributes][{{index}}][id]\" value=\"\" id=\"image_{{name}}_attributes_{{index}}_id\" type=\"hidden\" data-id=\"remote\">" +
  "<input name=\"image[{{name}}_attributes][{{index}}][_destroy]\" id=\"image_{{name}}_attributes_{{index}}__destroy\" value=\"\" data-destroy=\"true\" type=\"hidden\"><span class=\"input-group-btn field-controls\"><button class=\"btn btn-success add\"><i class=\"icon-white glyphicon-plus\"></i><span>Add</span></button></span></li>";

var template = Handlebars.compile(source);

function ControlledVocabFieldManager(element, options) {
    HydraEditor.FieldManager.call(this, element, options); // call super constructor.
}

ControlledVocabFieldManager.prototype = Object.create(HydraEditor.FieldManager.prototype,
    {
      createNewField: { value: function($activeField) {
              var fieldName = $activeField.find('input').data('attribute');
              var index = $activeField.siblings().size() + 1;
              $newField = this.newFieldTemplate(fieldName, index);
              this.addBehaviorsToInput($newField)
              return $newField
        }},

        newFieldTemplate: function(fieldName, index) {
            return $(template({ "name": fieldName, "index": index, "class": "controlled_vocabulary" }));
        },

        addBehaviorsToInput: { value: function($newField) {
              $newInput = $('input.multi-text-field', $newField);
              $newInput.focus();
              addAutocompleteToEditor($newInput);
              this.element.trigger("managed_field:add", $newInput);
        }},

        // Instead of removing the line, we override this method to add a
        // '_destroy' hidden parameter
      removeFromList: { value: function( event ) {
            event.preventDefault();
            var field = $(event.target).parents(this.fieldWrapperClass);
            field.find('[data-destroy]').val('true')
            field.hide();
            this.element.trigger("managed_field:remove", field);
      }}

    }
);
ControlledVocabFieldManager.prototype.constructor = ControlledVocabFieldManager;

$.fn.manage_controlled_vocab_fields = function(option) {
    return this.each(function() {
        var $this = $(this);
        var data  = $this.data('manage_fields');
        var options = $.extend({}, HydraEditor.FieldManager.DEFAULTS, $this.data(), typeof option == 'object' && option);

        if (!data) $this.data('manage_fields', (data = new ControlledVocabFieldManager(this, options)));
    })
}


Blacklight.onLoad(function() {
  $('.controlled_vocabulary.form-group').manage_controlled_vocab_fields();
});
