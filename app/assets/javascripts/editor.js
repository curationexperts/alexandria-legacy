//= require hydra-editor/hydra-editor

(function($) {
    var ControlledVocabFieldManager = function(element, options) {
        var that = this;
        var basic_manager = new HydraEditor.FieldManager(element, options);
        basic_manager.createNewField = function($activeField) {
              var new_index = $activeField.siblings().size() + 1;
              $newField = $activeField.clone();
              $newChildren = $newField.children('input');
              that.updateName($newChildren, new_index);
              $newChildren.val('').removeProp('required');
              $newChildren.first().focus();
              this.element.trigger("managed_field:add", $newChildren.first());
              return $newField
        };

        // Instead of removing the line, we override this method to add a
        // '_destroy' hidden parameter
        basic_manager.remove_from_list = function( event ) {
          event.preventDefault();
          var field = $(event.target).parents(this.fieldWrapperClass);
          field.find('[data-destroy]').val('true')
          field.hide();
          this.element.trigger("managed_field:remove", field);
        }

        return basic_manager;
    }

    ControlledVocabFieldManager.prototype = {
        updateName: function ($newChildren, new_index) {
            var re = /\[\d+\]/
            $newChildren.each(function() {
              var $child = $(this);
              var new_name = $child.attr('name').split(re).join('[' + new_index + ']');
              $child.attr('name', new_name);
            });

        }
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
