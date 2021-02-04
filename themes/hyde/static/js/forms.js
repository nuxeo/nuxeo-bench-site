"use strict";
var attempt_number = 0;
var initialisation_interval;

var initialise_forms = function(has_interval) {
  return function() {
    var $marketo_update = $(".marketo-update:not(.initialised)");

    // Put label after the input element
    if ($marketo_update.length && $marketo_update.find("label").length) {
      var $form = $marketo_update
        .find("label")
        .first()
        .closest("form");

      if ($marketo_update.length === 1) {
        clearInterval(initialisation_interval);
      }
      $form.closest('.marketo-update').addClass('initialised');

      // Remove Astrixes
      $form.find('.mktoAsterix').remove();

      // Add placeholder
      $form.find('.mktoInstruction').each((i, e) => {
        const $hint = $(e);
        const $placeholder = $hint.parent().find('input,textarea');

        // Only replace the placeholder if not populated
        if (!$placeholder.attr('placeholder')) {
          $placeholder.attr('placeholder', $hint.text());
        }
      });

      // Turn autocomplete off
      const $all_inputs = $form
        .find('.mktoField')
        .not(':hidden,[type="checkbox"]');

      $form
        .attr('autocomplete', 'off')
        .prepend(
          '<input autocomplete="false" name="hidden" type="text" style="display:none;">'
        );
      $all_inputs.attr('autocomplete', 'nah');
    } else if (has_interval && attempt_number++ > 20) {
      clearInterval(initialisation_interval);
    }
  };
};

initialisation_interval = setInterval(initialise_forms(true), 200);
