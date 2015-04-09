//= require typeahead.bundle.js
// require handlebars-v1.3.0.js

(function($){
  $.fn.alexandriaSearchTypeAhead = function( options ) {
    $.each(this, function(){
      addAutocompleteBehavior($(this), options);
    });

    function addAutocompleteBehavior( typeAheadInput, settings ) {
      var settings = $.extend({
        highlight: (typeAheadInput.data('autocomplete-highlight') || true),
        hint: (typeAheadInput.data('autocomplete-hint') || false),
        autoselect: (typeAheadInput.data('autocomplete-autoselect') || true)
      }, options);

      var controlledVocabMap = {
        'form_of_work':     '/qa/search/getty/aat',
        'location':         '/qa/search/loc/names',
        'sub_location':     '/qa/search/local/sub_location',
        'lc_subject':       '/qa/search/loc/subjects',
        'license':          '/qa/search/local/license',
        'copyright_status': '/qa/search/loc/copyrightStatus',
        'language':         '/qa/search/loc/iso639-2'
      };

      function qaPathForField(input) {
        fieldName = input.data('attribute');
        return controlledVocabMap[fieldName];
      }

      var results;
      if (settings.bloodhound) {
        results = settings.bloodhound();
      } else {
        results = initBloodhound(qaPathForField(typeAheadInput));
      }

      typeAheadInput.typeahead(settings, {
        displayKey: 'label',
        source: results.ttAdapter()
      })
    }

    return this;
  }
})( jQuery );

function initBloodhound(path) {
  var results = new Bloodhound({
    datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.title); },
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    limit: 10,
    remote: {
      url: path + '?q=%QUERY',
      filter: function(response) {
        return $.map(response, function(doc) {
          return doc;
        })
      }
    }
  });
  results.initialize();
  return results;
}

function storeControlledVocabularyData(input, data) {
    uri = data['id'].replace("info:lc", "http://id.loc.gov");
    input.closest('.field-wrapper').find('[data-id]').val(uri);
}

function lockControlledVocabularyFields(input) {
   input.typeahead("destroy");
   input.attr("readonly", "readonly");
}

function addAnotherField(input) {
  input.closest('.form-group').find('.add').click();
}

function addAutocompleteToEditor($field, path) {
    $field.alexandriaSearchTypeAhead().on(
        'typeahead:selected typeahead:autocompleted', function(e, data) {
            storeControlledVocabularyData($(this), data);
            lockControlledVocabularyFields($(this));
            addAnotherField($(this));
    }).on(
    'change', function(e) {
      // They didn't select anything. Clear the field.
      $(this).typeahead('val', '');
    });
}

Blacklight.onLoad(function(){
  addAutocompleteToEditor($('input.image_lc_subject:not([readonly])'));
  addAutocompleteToEditor($('input.image_location:not([readonly])'));
  addAutocompleteToEditor($('input.image_sub_location:not([readonly])'));
  addAutocompleteToEditor($('input.image_form_of_work:not([readonly])'));
  addAutocompleteToEditor($('input.image_license:not([readonly])'));
  addAutocompleteToEditor($('input.image_copyright_status:not([readonly])'));
  addAutocompleteToEditor($('input.image_language:not([readonly])'));
});

