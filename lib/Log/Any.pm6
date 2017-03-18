use v6.c;

use Log::Any::Pipeline;
use Log::Any::Filter;
use Log::Any::Formatter;
use Log::Any::Definitions;

=begin pod
=head1 Log::Any
=end pod
class Log::Any {
	my $instance;

	has %!pipelines = { '_default' => Log::Any::Pipeline.new };

	has %!severities = %Log::Any::Definitions::SEVERITIES;

	method new {
		unless $instance {
			$instance = Log::Any.bless;
		}
		return $instance;
	}

	# Log::Any.add
	multi method add( Log::Any:U: Log::Any::Adapter $a, :$filter, :$formatter ) {
		return self.new.add( $a, :$filter, :$formatter );
	}

	# Log::Any.new.add
	multi method add( Log::Any:D: Log::Any::Adapter $a, :$filter, :$formatter ) {
		my Log::Any::Filter $local-filter;
		my Log::Any::Formatter $local-formatter;

		given $filter {
			when Array {
				$local-filter = Log::Any::FilterBuiltIN.new( checks => @$filter );
			}
			when Log::Any::Filter {
				$local-filter = $filter;
			}
		}

		given $formatter {
			when Str {
				$local-formatter = Log::Any::FormatterBuiltIN.new( :format( $formatter ) );
			}
			when Log::Any::Formatter {
				$local-formatter = $formatter;
			}
			default {
				$local-formatter = Log::Any::FormatterBuiltIN.new;
			}
		}

		%!pipelines{'_default'}.add( $a, :filter( $local-filter ), :formatter( $local-formatter ) );
	}

	proto method log( Log::Any: :$msg!, :$severity!, :$category is copy, :$pipeline = '_default' --> Bool ) {*}

	multi method log( Log::Any:U: :$msg!, :$severity!, :$category is copy, :$pipeline = '_default' --> Bool ) {
		return Log::Any.new.log( :$msg, :$severity, :$category, :$pipeline );
	}

=begin pod
=head2 method log
=head3 Parameters
=head3 Exceptions
Dies if severity is unknown.
=end pod
	multi method log(Log::Any:D: :$msg!, :$severity!, :$category is copy, :$pipeline = '_default' --> Bool ) {
		# Check if the severity is handled
		die "Unknown severity $severity" unless %!severities{$severity};

		# Search the package name of caller if $category is not set
		# Can be null (Any) (no caller package)
		unless $category {
			# Search the package name of the caller
			for Backtrace.new -> $b {
				if $b.code ~~ Routine {
					if $b.code.package.^name ~~ /^ 'Log::Any' | ^ 'Backtrace' / {
						next;
					}
					$category = $b.code.package.^name;
					last;
				}
			}
		}

		# Use the specified pipeline, or the default one
		my $pipeline-instance = %!pipelines{ $pipeline } // %!pipelines{'_default'};
		$pipeline-instance.dispatch( :$msg, :$severity, :$category );

		return True;
	}


	method emergency( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'emergency' ), :$category );
	}

	method alert( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'alert' ), :$category );
	}

	method critical( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'critical' ), :$category );
	}

	method error( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'error' ), :$category );
	}

	method warning( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'warning' ), :$category );
	}

	method info( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'info' ), :$category );
	}

	method notice( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'notice' ), :$category );
	}

	method debug( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'debug' ), :$category );
	}

	method trace( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'trace' ), :$category );
	}

}
