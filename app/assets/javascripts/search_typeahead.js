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
        autoselect: (typeAheadInput.data('autocomplete-autoselect') || true),
        path: '/'
      }, options);

      var results;
      if (settings.bloodhound) {
        results = settings.bloodhound();
      } else {
        results = initBloodhound(settings.path);
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

function addAutocompleteToEditor($field, path) {
  $field.alexandriaSearchTypeAhead({ path: path}).on(
      'typeahead:selected typeahead:autocompleted', function(e, data) {
    uri = data['id'].replace("info:lc", "http://id.loc.gov");
    $(this).closest('.field-wrapper').find('[data-id]').val(uri);
  });
}

Blacklight.onLoad(function(){
  addAutocompleteToEditor($('input.image_lc_subject:not([readonly])'), '/qa/search/loc/subjects');
  addAutocompleteToEditor($('input.image_location:not([readonly])'), '/qa/search/loc/names');
});

