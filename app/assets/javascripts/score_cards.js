// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
  $('.datepicker').datepicker({ dateFormat: "yy-mm-dd" });
});

$(function() {
	$('[data-toggle="tooltip"]').tooltip();
});

$(function() {
	$("input[data-clear-form]").on("click", function() {
		$(this).closest('form').find("input[type=text]").removeAttr("value");
	});
});

