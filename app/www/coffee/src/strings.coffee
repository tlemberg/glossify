define ->

	_strings =
		loginFailed: 'login failed, email or password incorrect'
		unexpectedFailure: 'unexpected failure'
		invalidEmail: 'invalid email'
		invalidPassword: 'invalid password'


	_getString = (k) ->
		_strings[k]


	############################################################################
	# Exposed objects
	#
	############################################################################
	return {

		getString: (k) -> _getString(k)

	}

