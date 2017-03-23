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

	method add( Log::Any::Adapter $a, Log::Any::Filter :$filter, Log::Any::Formatter :$formatter ) {
		#note "{now} adding adapter $a.WHAT().^name()";
		my %elem = adapter => $a;

		if $filter.defined {
			%elem{'filter'} = $filter;
		}

		if $formatter.defined {
			%elem{'formatter'} = $formatter;
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
			my $msgToHandle = $msg;
			$msgToHandle = %elem{'formatter'}.?format( :$dateTime, :$msg, :$category, :$severity );

			# Proxies

			# Handling
			%elem{'adapter'}.handle( $msgToHandle );
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
