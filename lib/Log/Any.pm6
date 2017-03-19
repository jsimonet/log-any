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
	multi method add( Log::Any:U: Log::Any::Adapter $a, Str :$pipeline = '_default', :$filter, :$formatter ) {
		return self.new.add( $a, :$filter, :$formatter );
	}

	# Log::Any.new.add
	multi method add( Log::Any:D: Log::Any::Adapter $a, Str :$pipeline = '_default', :$filter, :$formatter ) {
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

		unless %!pipelines{$pipeline} {
			%!pipelines{$pipeline} = Log::Any::Pipeline.new;
		}
		%!pipelines{$pipeline}.add( $a, :filter( $local-filter ), :formatter( $local-formatter ) );
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
	multi method log(Log::Any:D: :$msg!, :$severity!, :$category is copy, :$pipeline is copy --> Bool ) {
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

		# Capture the date as soon as possible
		my $dateTime = DateTime.new( now );

		# Use the specified pipeline, or the default one
		$pipeline //= '_default';
		my $pipeline-instance = %!pipelines{ $pipeline } // %!pipelines{'_default'};
		$pipeline-instance.dispatch( :$dateTime, :$msg, :$severity, :$category );

		return True;
	}


	method emergency( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'emergency' ), :$category, :$pipeline );
	}

	method alert( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'alert' ), :$category, :$pipeline);
	}

	method critical( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'critical' ), :$category, :$pipeline );
	}

	method error( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'error' ), :$category, :$pipeline );
	}

	method warning( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'warning' ), :$category, :$pipeline );
	}

	method info( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'info' ), :$category, :$pipeline );
	}

	method notice( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'notice' ), :$category, :$pipeline );
	}

	method debug( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'debug' ), :$category, :$pipeline );
	}

	method trace( $msg, :$category, :$pipeline --> Bool ) {
		self.log( :$msg, :severity( 'trace' ), :$category, :$pipeline );
	}

}
