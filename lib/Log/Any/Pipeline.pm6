use v6.c;

use Log::Any::Adapter;
use Log::Any::Filter;

=begin pod
=head1 Log::Any::Pipeline
A pipeline have to choose which Adapter will handle the log, depending on the
Log's attributes (category, severity, size of the message, etc.).
=end pod

class Log::Any::Pipeline {

	has @!adapters;

	method add( Log::Any::Adapter $a, Log::Any::Filter :$filter ) {
		#note "{now} adding adapter $a.WHAT().^name()";
		my %elem = adapter => $a;
		if $filter.defined {
			%elem{'filter'} = $filter;
		}
		push @!adapters, %elem;
	}

	method dispatch( :$msg!, :$severity!, :$category! ) {
		#note "{now} dispatching $msg, adapter count : @!adapters.elems()";
		for @!adapters -> %elem {
			# Filter : check if the adapter meets the requirements
			with %elem{'filter'} {
				next unless  %elem{'filter'}.filter( :$msg, :$severity, :$category );
			}

			# Formatter
			# Proxies
			%elem{'adapter'}.handle( $msg );

			last;
		}
	}

}
