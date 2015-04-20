var tile_id;


function strip_numeric(s) {
	return s.replace(/[^-\d\.]/g, '');
}


$(document).on("pagecontainerload", function(event, data) {
});


$(document).ready(function() {
	// Set the tile height to be a square
	tile_width = strip_numeric($(".overview-tile").first().css('width'));
	$('.overview-tile').css('height', tile_width + "px");

	// Set the margins
	row_width = strip_numeric($(".overview-row").first().css('width'));
	margin_width = Math.floor(row_width - (tile_width * 4)) / 5;
	$('.overview-tile').css('margin-right', margin_width);
	$('.overview-tile-left').css('margin-left', margin_width);

	$(".overview-tile-link").click(function(event) {
		event.preventDefault();
		tile_id = $(this).data("tile-id")
		//$.mobile.navigate("#study", { foo: "tom" });
		$.mobile.changePage("/fr/study");
	});

	$(window).on("navigate", function(event, data) {
		console.log(event);
		console.log(data.state);
	});

	// Set the button height to be a square
	btn_width = strip_numeric($(".study-btn").first().css('width'));
	$('.study-btn').css('height', btn_width + "px");
});