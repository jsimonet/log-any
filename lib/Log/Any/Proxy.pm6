use v6.c;

class Log::Any::Proxy {

	# Return the value to be logged
	# -> Falsy value : response is not propagated to the handler
	# -> Str : the value is propagated "as in" to the handler
	# -> Array of Str : each string is propagated to the handler
	# -> A promise : the result will be asynchronous,
	#    the handler will be called asynchronously
	method proxy { ...  }
}
