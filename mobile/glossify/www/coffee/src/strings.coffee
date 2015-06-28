define ->

	_strings =
		loginFailed: 'login failed, email or password incorrect'
		unexpectedFailure: 'unexpected failure'
		invalidEmail: 'The email address you entered is invalid.  Please use a real email address.'
		invalidPassword: 'The email/password you entered is invalid.'
		ajaxError: "We're sorry, there was a problem communicating with the website. Please try again."


	_getString = (k) ->
		_strings[k]


	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		getString: (k) -> _getString(k)

	}

