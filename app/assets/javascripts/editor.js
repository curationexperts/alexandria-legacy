//= require hydra-editor/hydra-editor
//= require handlebars-v3.0.0.js

(function($) {
    var source = "<li class=\"field-wrapper input-group input-append\">" +
      "<input class=\"string controlled_vocabulary optional form-control image_{{name}} form-control multi-text-field\" name=\"image[{{name}}_attributes][{{index}}][hidden_label]\" value=\"\" id=\"image_{{name}}_attributes_{{index}}_hidden_label\" type=\"text\">" +
      "<input name=\"image[{{name}}_attributes][{{index}}][id]\" value=\"\" id=\"image_{{name}}_attributes_{{index}}_id\" type=\"hidden\" data-id=\"remote\">" +
      "<input name=\"image[{{name}}_attributes][{{index}}][_destroy]\" id=\"image_{{name}}_attributes_{{index}}__destroy\" value=\"\" data-destroy=\"true\" type=\"hidden\"><span class=\"input-group-btn field-controls\"><button class=\"btn btn-success add\"><i class=\"icon-white glyphicon-plus\"></i><span>Add</span></button></span></li>";

    var template = Handlebars.compile(source);

    var ControlledVocabFieldManager = function(element, options) {
        var that = this;
        var basic_manager = new HydraEditor.FieldManager(element, options);
        basic_manager.createNewField = function($activeField) {
              var new_index = $activeField.siblings().size() + 1;
              // TODO it's always subject
              $newField = $(template({ "name": "lc_subject", "index": new_index }));
              $newInput = $('input.multi-text-field', $newField);
              $newInput.focus();
              addAutocompleteToEditor($newInput);
              this.element.trigger("managed_field:add", $newInput);
              return $newField
        };

        // Instead of removing the line, we override this method to add a
        // '_destroy' hidden parameter
        basic_manager.removeFromList = function( event ) {
          event.preventDefault();
          var field = $(event.target).parents(this.fieldWrapperClass);
          field.find('[data-destroy]').val('true')
          field.hide();
          this.element.trigger("managed_field:remove", field);
        }

        return basic_manager;
    }

    $.fn.manage_controlled_vocab_fields = function(option) {
        return this.each(function() {
            var $this = $(this);
            var data  = $this.data('manage_fields');
            var options = $.extend({}, HydraEditor.FieldManager.DEFAULTS, $this.data(), typeof option == 'object' && option);

            if (!data) $this.data('manage_fields', (data = new ControlledVocabFieldManager(this, options)));
        })
    }
})(jQuery);

Blacklight.onLoad(function() {
  $('.controlled_vocabulary.form-group').manage_controlled_vocab_fields();
});
