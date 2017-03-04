use v6.c;

use Log::Any::Adapter;

=begin pod
=head1 Log::Any::Pipeline
A pipeline have to choose which Adapter will handle the log, depending on the
Log's attributes (category, severity, size of the message, etc.).
=end pod

class Log::Any::Pipeline {

	has @!adapters;

	method add( Log::Any::Adapter $a ) {
		#note "{now} adding adapter $a.WHAT().^name()";
		push @!adapters, $a;
	}

	method dispatch( :$msg!, :$severity!, :$category! ) {
		#note "{now} dispatching $msg, adapter count : @!adapters.elems()";
		for @!adapters -> $adapt {
			# Check if the adapter meets the requirements

			#$adapt.handle( :$msg, :$severity, :$category );
			$adapt.handle( $msg );
			last;
		}
	}

}
