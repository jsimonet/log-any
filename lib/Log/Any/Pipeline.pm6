use v6.c;

use Log::Any::Adapter;
use Log::Any::Filter;
use Log::Any::Formatter;

=begin pod
=head1 Log::Any::Pipeline

	A pipeline have to choose which Adapter will handle the log, depending on the
	Log's attributes (category, severity, size of the message, etc.).

	A pipeline is composed of elements, which contains an Adapter and possibly
	a Filter, a Formatter and/or a Proxy.
=end pod

class Log::Any::Pipeline {

	has @!adapters;

	method add( Log::Any::Adapter $a, Log::Any::Filter :$filter, Log::Any::Formatter :$formatter, :$proxy ) {
		#note "{now} adding adapter $a.WHAT().^name()";
		my %elem = adapter => $a;

		if $filter.defined {
			%elem{'filter'} = $filter;
		}

		if $formatter.defined {
			%elem{'formatter'} = $formatter;
		}

		if $proxy.defined {
			%elem{'proxy'} = $proxy;
		}

		push @!adapters, %elem;
	}

=begin pod
=head2 get-next-elem

	This method returns the next element of the pipeline wich is matching
	the filter.
=end pod
	method !get-next-elem( :$msg, :$severity, :$category ) {
		my %next-elem;

		for @!adapters -> %elem {
			# Filter : check if the adapter meets the requirements
			with %elem{'filter'} {
				next unless  %elem{'filter'}.filter( :$msg, :$severity, :$category );
			}
			# Without filter, it's ok
			%next-elem = %elem;
			last;
		}

		return %next-elem;
	}

	method dispatch( DateTime :$dateTime!, :$msg!, :$severity!, :$category! ) {
		#note "{now} dispatching $msg, adapter count : @!adapters.elems()";

		my %elem = self!get-next-elem( :$msg, :$severity, :$category );
		if %elem {
			# Formatter
			my $msg-formatted = $msg;
			$msg-formatted = %elem{'formatter'}.?format( :$dateTime, :$msg, :$category, :$severity );

			# Proxies
			my $proxy-result = $msg-formatted;
			#my $proxy-result = %elem{'proxy'}.?proxy( :$msg, :$severity, :$category );

			# !!! if msg-formatted contains the date, no message will be identical...
			if %elem{'proxy'} {
				$proxy-result = %elem{'proxy'}.?proxy( msg => $msg );
			}

			# Handling
			if $proxy-result ~~ Promise {
				note "proxy is a promise", $proxy-result;
				$proxy-result.then( -> $v {
					say "result of promise : "~$v.result.perl;
					given $v.result {
						when Seq {
							#note $v.result.perl;
							for $_ -> $m {
								note "m is $m.perl()";
								%elem{'adapter'}.handle( $m );
							}
						}
						when Array {
							note "array";
							for $_ -> $m {
								my $msg-formatted = %elem{'formatter'}.?format( msg => $m );
								dd $msg-formatted;
								$msg-formatted //= $msg;
								dd $msg-formatted;
								%elem{'adapter'}.handle( $msg-formatted );
							}
						}
						when Str {
							note "str";
							%elem{'adapter'}.handle( $_ );
						}
						default { die "Oops" }
					}
				});
			} elsif $proxy-result ~~ Str {
				#note "logging $msg-formatted";
				%elem{'adapter'}.handle( $msg-formatted );
			} else {
				die "oops", $proxy-result.WHAT.perl;
			}
		}
	}

	method will-dispatch( :$severity, :$category ) returns Bool {
		return self!get-next-elem( :$severity, :$category ).so;
	}

	# Dump the adapters
	method gist {
		return 'Log::Any::Pipeline.new(adapters => ' ~ @!adapters.gist ~ ')';
	}

}
