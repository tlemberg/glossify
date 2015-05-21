################################################################################
# Module properties
#
################################################################################
audioContext = undefined
recorder     = undefined
task_id      = undefined


################################################################################
# $(document).ready
#
################################################################################
$(document).ready ->

	# Get the task_id
	task_id = $('#task-id-input').val()

	try

		window.URL             = window.URL || window.webkitURL
		window.AudioContext    = window.AudioContext || window.webkitAudioContext
		navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia
		
		audioContext = new AudioContext()
		console.log('Audio context set up.')
		console.log('navigator.getUserMedia ' + (navigator.getUserMedia ? 'available.' : 'not present!'))

	catch e

    	console.log('No web audio support in this browser!')
    
    navigator.getUserMedia({audio: true}, startUserMedia, (e) ->
		console.log('No live audio input: ' + e)

	# Hide rows
	$(".row").not(".row-1").hide()

	# Click event
	$(".record-btn").click (event) ->
		startRecording()

	# Click event
	$(".done-btn").click (event) ->
		stopRecording($(this).data('index'))


################################################################################
# startUserMedia
#
################################################################################
startUserMedia = (stream) ->
	input = audioContext.createMediaStreamSource(stream)
	console.log("Media stream initialized")

	recorder = new Recorder(input)
	console.log("Recorder initialized")


################################################################################
# startRecording
#
################################################################################
startRecording = ->

	# Record
	recorder.record()

	# Change UI
	$(".record-btn").hide()
	$(".done-btn").show()

	console.log("Recording")


################################################################################
# stopRecording
#
################################################################################
stopRecording = (index) ->

	# Change UI
	$(".record-btn").show()
	$(".done-btn").hide()

	filename = "#{ task_id }_#{ index }"
	uploadAudio(filename)


################################################################################
# uploadAudio
#
################################################################################
uploadAudio = ->

	recorder.exportWAV (blob) ->

		# Construct the form
		fromData = new FormData()
		fromData.append('fname', filename)
		fromData.append('data', blob)

		# Send AJAX
		$.ajax
			type       : 'post'
			url        : '/upload-audio'
			data       : fromData
			processData: false
			contentType: false


