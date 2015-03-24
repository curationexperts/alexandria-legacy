//= require hydra-editor/hydra-editor
(function($) {
    var TimeSpanManager = function(element, options) {
        var that = this;
        var basic_manager = new HydraEditor.FieldManager(element, options);
        basic_manager.createNewField = function($activeField) {
              var new_index = $activeField.siblings().size() + 1;
              $newField = $(HandlebarsTemplates['editor/time_span']({name: options.name, "index": new_index}));
              $newInput = $('input.multi-text-field', $newField);
              $newInput.focus();
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

    $.fn.manage_time_span_fields = function(option) {
        return this.each(function() {
            var $this = $(this);
            var data  = $this.data('manage_fields');
            var options = $.extend({}, HydraEditor.FieldManager.DEFAULTS, $this.data(), typeof option == 'object' && option);

            if (!data) $this.data('manage_fields', (data = new TimeSpanManager(this, options)));
        })
    }

})(jQuery);

Blacklight.onLoad(function() {
  //$('.time-span.form-group').manage_time_span_fields();
});
