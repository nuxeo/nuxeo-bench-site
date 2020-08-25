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
      $form.closest(".marketo-update").addClass("initialised");

      $form.find("label").each((i, e) => {
        var $label = $(e);
        // Remove gutter div - not necessary
        $label.siblings(".mktoGutter").remove();

        var $special_parent = $label.parent(".mktoLogicalField");
        var $input = $label.siblings(
          ".mktoField:not([type=checkbox],[type=radio])"
        );

        // 3-step swap
        if ($input.length && !$special_parent.length) {
          var $temp = $("<div>");

          $input.before($temp);
          $label.before($input);
          $temp.after($label).remove();
        }
      });

      var $all_inputs = $form
        .find(".mktoField")
        .not(':hidden,[type="checkbox"]');

      $form
        .attr("autocomplete", "off")
        .prepend(
          '<input autocomplete="false" name="hidden" type="text" style="display:none;">'
        );
      $all_inputs.attr("autocomplete", "nah");

      $form.on("change blur", "input", function() {
        var $this = $(this);
        if ($this.val() !== "") {
          $this.addClass("filled");
        } else {
          $this.removeClass("filled");
        }
      });
    } else if (has_interval && attempt_number++ > 20) {
      clearInterval(initialisation_interval);
    }
  };
};

initialisation_interval = setInterval(initialise_forms(true), 200);
