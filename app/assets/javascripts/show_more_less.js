// This code operates the "show more" & "show less" links
// to toggle between long descriptions and truncated
// descriptions.

function showMoreOrLess(e){
  $(this).toggle();
  $(this).siblings().toggle();
}

// Reveal hidden fields
function reveal(e){
  $('#documents .reveal-js').show();
}

Blacklight.onLoad(function() {
  $('#documents .show-more').bind('click', {}, showMoreOrLess);
  $('#documents .show-less').bind('click', {}, showMoreOrLess);
  reveal();
})

