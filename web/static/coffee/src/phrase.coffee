################################################################################
# toggle_tx_editing
#
################################################################################
toggle_tx_editing = (row_id, editable) ->
	if editable
		# Hide and the correct buttons
		$("#tx-edit-btn-" + row_id).hide()
		$("#tx-done-btn-" + row_id).show()
		$("#tx-cancel-btn-" + row_id).show()

		# Hide the span and show the text input
		$("#tx-span-" + row_id).hide()
		$("#tx-input-" + row_id).show()
	else
		# Hide and the correct buttons
		$("#tx-edit-btn-" + row_id).show()
		$("#tx-done-btn-" + row_id).hide()
		$("#tx-cancel-btn-" + row_id).hide()

		# Hide the span and show the text input
		$("#tx-span-" + row_id).show()
		$("#tx-input-" + row_id).hide()


################################################################################
# ready
#
################################################################################
$(document).ready ->
	$(".tx-input").hide()
	$(".uk-button").hide()

	$("#show-deleted-checkbox").click (event) ->
		if $("#show-deleted-checkbox").prop('checked')
			window.location.search = jQuery.query.set("show-deleted", 1)
		else
			window.location.search = jQuery.query.set("show-deleted", 0)

	$(".tx-delete-btn").click (event) ->
		row_id = $(this).data("row-id")
		$("#tx-deleted-input-" + row_id).val(1)
		$("form:first").submit()

	$(".tx-edit-btn").click (event) ->
		row_id = $(this).data("row-id")
		toggle_tx_editing(row_id, 1)	

	$(".tx-cancel-btn").click (event) ->
		row_id = $(this).data("row-id")
		toggle_tx_editing(row_id, 0)

	$(".tx-done-btn").click (event) ->
		row_id = $(this).data("row-id")
		toggle_tx_editing(row_id, 0)

	$(".tx-down-btn").click (event) ->
		row_id = $(this).data("row-id")
		r = row_id.match(/^([A-Za-z]+)\-([0-9]+)$/)
		k = r[1]
		rank_clicked = Number(r[2])
		$("#tx-rank-input-" + k + "-" + rank_clicked).val(rank_clicked + 1)
		$("#tx-rank-input-" + k + "-" + (rank_clicked + 1)).val(rank_clicked)
		$("form:first").submit()

	$(".tx-up-btn").click (event) ->
		row_id = $(this).data("row-id")
		r = row_id.match(/^([A-Za-z]+)\-([0-9]+)$/)
		k = r[1]
		rank_clicked = Number(r[2])
		$("#tx-rank-input-" + k + "-" + rank_clicked).val(rank_clicked - 1)
		$("#tx-rank-input-" + k + "-" + (rank_clicked - 1)).val(rank_clicked)
		$("form:first").submit()

	$(".tx-audio-btn").click (event) ->
		row_id = $(this).data("row-id")
		# TODO
		alert("audio-" + row_id)

