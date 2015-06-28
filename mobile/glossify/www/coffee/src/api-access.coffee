requirejs.config
	baseUrl: 'coffee/lib',
	paths:
		jquery: '../../js/jquery-2.1.3.min'

requirejs ['jquery', 'storage', 'api'], ($, storage, api) ->

	
	_setBodyHtml = (apiSummary) ->
		# Iterate over the functions and their parameters
		divs = []
		options = []
		first = true
		for funcName in Object.keys(apiSummary)

			# Create an option
			optionHtml = """
				<option value='#{ funcName }'>#{ funcName }</option>
			"""
			options.push(optionHtml)

			inputs = []
			for param in apiSummary[funcName]['params']
				inputHtml = """
					<tr>
						<td>#{ param }</td>
						<td><input id='arg-#{ funcName }-#{param}' type='text' /></td>
					</tr>
				"""
				inputs.push(inputHtml)

			allInputsHtml = inputs.join('')

			inputDivHtml = """
				<table>
					#{ allInputsHtml }
				</table>
			"""

			submitDivHtml = """
				<div>
					<input type="submit" data-func-name='#{ funcName }' class='submit-btn' />
				</div>
			"""

			if first
				firstClass = 'func-div-first'
			else
				firstClass = ''

			divHtml = """
				<div id='func-div-#{ funcName }' class='func-div #{ firstClass }'>
					<h2>#{ funcName }</h2>
					#{ inputDivHtml }
					#{ submitDivHtml }
				</div>
			"""

			divs.push(divHtml)

			first = false

		allOptionsHtml = options.join('')
		selectHtml = """
			<select id='func-select'>#{ allOptionsHtml }</select>
		"""

		divsHtml = divs.join('')

		outputHtml = """
			<div>
				<h2>Output</h2>
				<div id='response-text'></div>
			</div>
		"""

		bodyHtml = """
			#{ selectHtml }
			#{ divsHtml }
			#{ outputHtml }
		"""

		$('body').html(bodyHtml)

		$('.func-div').hide()
		$('.func-div-first').show()


	_registerEvents = (apiSummary) ->
		$('#func-select').change (event) ->
			$('#response-text').html('')

			funcName = $(this).val()

			$('.func-div').hide()
			$("#func-div-#{ funcName }").show()

		$('.submit-btn').click (event) ->
			funcName = $(this).data('func-name')
			paramValues = []
			for param in apiSummary[funcName]['params']
				paramValues.push($("#arg-#{ funcName }-#{param}").val())

			func = apiSummary[funcName]['func']

			handler = (json) ->
				$('#response-text').html(JSON.stringify(json))

			if paramValues.length == 0
				func(handler)
			else if paramValues.length == 1
				func(paramValues[0], handler)
			else if paramValues.length == 2
				func(paramValues[0], paramValues[1], handler)
			else if paramValues.length == 3
				func(paramValues[0], paramValues[1], paramValues[2], handler)


	$(document).ready (event) ->

		# Get a summary of the API functions and the parameters they accept
		apiSummary = api.apiSummary()

		_setBodyHtml(apiSummary)

		_registerEvents(apiSummary)
