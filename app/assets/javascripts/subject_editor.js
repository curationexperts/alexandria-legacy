//= require editor
var subject_manager_fields = "<input class=\"string {{class}} optional form-control image_{{name}} form-control multi-text-field\" name=\"image[{{name}}_attributes][{{index}}][hidden_label]\" value=\"\" id=\"image_{{name}}_attributes_{{index}}_hidden_label\" data-attribute=\"{{name}}\" type=\"text\">" +
  "<input name=\"image[{{name}}_attributes][{{index}}][id]\" value=\"\" id=\"image_{{name}}_attributes_{{index}}_id\" type=\"hidden\" data-id=\"remote\">" +
  "<input name=\"image[{{name}}_attributes][{{index}}][_destroy]\" id=\"image_{{name}}_attributes_{{index}}__destroy\" value=\"\" data-destroy=\"true\" type=\"hidden\"><span class=\"input-group-btn field-controls\"><button class=\"btn btn-success add\"><i class=\"icon-white glyphicon-plus\"></i><span>Add</span></button></span>";
var select_manager_select = "<select name=\"vocab\" id=\"vocab\" class=\"form-control\"><option value=\"lcsh\">LC Subject Headings</option><option value=\"tgm\">Graphic Materials</option></select>"

var subject_manager_wrapper = "<li class=\"field-wrapper row\">"+
  "<div class=\"col-md-4\">"+select_manager_select+"</div>" +
  "<div class=\"col-md-8\"><div class=\"input-group input-group-append\">"+
  subject_manager_fields +"</div></div>" +
  "</li>";

var subject_manager_template = Handlebars.compile(subject_manager_wrapper);
function SubjectManager(element, options) {
    ControlledVocabFieldManager.call(this, element, options);
}

SubjectManager.prototype = Object.create(ControlledVocabFieldManager.prototype, {
    /* TODO hook up other vocabs */
    _addInitialClasses: { value: function () {
          this.element.addClass("managed");
    }},

    _appendControls: {
        value: function() {
            $.each($(this.fieldWrapperClass + ' .col-md-8', this.element), function() {
                wrapper = "<div class=\"input-group input-group-append\"></div>"
                $(this).children().wrapAll(wrapper);
            });
            $(this.fieldWrapperClass + ' .input-group-append', this.element).append(this.controls);
            $('.field-controls:not(:last)', this.element).append(this.remover);
            $('.field-controls:last', this.element).append(this.adder);
        }
    },

    _changeControlsToRemove: { value: function($activeField) {
          var $removeControl = this.remover.clone();
          $activeFieldControls = $('.field-controls', $activeField);
          $('.add', $activeFieldControls).remove();
          $activeFieldControls.prepend($removeControl);
    }},

    newFieldTemplate: {
        value: function(fieldName, index) {
            return $(subject_manager_template({ "name": fieldName, "index": index, "class": "controlled_vocabulary_select" }));
        }
    },
})

SubjectManager.prototype.constructor = SubjectManager;

$.fn.manage_subject_fields = function(option) {
    return this.each(function() {
        var $this = $(this);
        var data  = $this.data('manage_fields');
        var options = $.extend({}, HydraEditor.FieldManager.DEFAULTS, $this.data(), typeof option == 'object' && option);

        if (!data) $this.data('manage_fields', (data = new SubjectManager(this, options)));
    })
}

Blacklight.onLoad(function() {
  $('.controlled_vocabulary_select.form-group').manage_subject_fields();
});


