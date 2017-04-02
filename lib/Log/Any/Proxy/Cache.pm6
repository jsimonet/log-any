use v6.c;

class Log::Any::Proxy::Cache {

	# Use a Message class as key in place of :$msg?
	has %.seen-logs;

	# Minimum number of messages to begin watch
	has $.min-same-messages = 3;

	# Maximum number of messages stored into the queue simultaneously
	has $.queue-max-size = 3;

	has Promise $!p;
	has $.promise-timeout = 1; # second

	has $!lock;

	method proxy( :$msg, :$severity, :$category ) {
		my $result;

		$!lock = Lock.new;

		%!seen-logs{ $msg } += 1;

		# A falsy promise is currently running
		if ( ! $!p.defined || $!p.so ) && max( values %!seen-logs ) >= $!min-same-messages {
			note "Creating a promise {now}";
			$!p = Promise.in( $!promise-timeout ).then({
				note "reacting {now}";
				# Copy %!seen-logs into a local variable
				my %logs = %!seen-logs;
				# What happens if the proxy is called at this moment in time ?
				%!seen-logs = Hash.new;
				$result = Array.new: map {
					"« $_ » message has been seen "~%logs{$_}~" times during the last {$!promise-timeout}s";
				}, keys %logs;
				$result
			});
			$result = $!p;
		} else {
			note "timer is False or no enough logs provided ({max values %!seen-logs}) {now}";
			$result = $msg;
		}

		return $result;
	}

}
