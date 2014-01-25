$(function() {
	$("input[data-clear-form]").on("click", function() {
		$(this).closest('form').find("input[type=text]").removeAttr("value");
	});
});