var tile_id;


function strip_numeric(s) {
	return s.replace(/[^-\d\.]/g, '');
}


$(document).ready(function() {
	// Set the button height to be a square
	btn_width = strip_numeric($(".study-btn").first().css('width'));
	$('.study-btn').css('height', btn_width + "px");
});