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
	multi method add( Log::Any:U: Log::Any::Adapter $a, Str :$pipeline = '_default', :$filter, :$formatter = Nil, :$continue-on-match ) {
		return self.new.add( $a, :$pipeline, :$filter, :$formatter, :$continue-on-match );
	}

	# Log::Any.new.add
	multi method add( Log::Any:D: Log::Any::Adapter $a, Str :$pipeline = '_default', :$filter, :$formatter = Nil, :$continue-on-match ) {
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
			when Nil {
				# No formatter specified
			}
			default {
				die 'Unable to use formatter ' ~ $formatter.gist;
			}
		}

		unless %!pipelines{$pipeline} {
			# note "Adding adapter to pipeline $pipeline";
			%!pipelines{$pipeline} = Log::Any::Pipeline.new;
		}
		%!pipelines{$pipeline}.add( $a, :filter( $local-filter ), :formatter( $local-formatter ), :$continue-on-match );
	}

	multi method add( Log::Any:U:  Str :$pipeline = '_default', :$filter ) {
		return self.new.add( :$pipeline, :$filter );
	}

	multi method add( Log::Any:D:  Str :$pipeline = '_default', :$filter ) {
		my Log::Any::Filter $local-filter;
		given $filter {
			when Array {
				$local-filter = Log::Any::FilterBuiltIN.new( checks => @$filter );
			}
			when Log::Any::Filter {
				$local-filter = $filter;
			}
		}

		unless %!pipelines{$pipeline} {
			# note "Adding adapter to pipeline $pipeline";
			%!pipelines{$pipeline} = Log::Any::Pipeline.new;
		}

		%!pipelines{$pipeline}.add( Log::Any::Adapter::BlackHole.new, :filter( $local-filter ) );
	}

	# Add a pipeline object
	multi method add( Log::Any:U: Log::Any::Pipeline $p, Str:D :$pipeline = '_default', :$overwrite = False ) {
		Log::Any.new.add( $p, :$pipeline, :$overwrite );
	}

	multi method add( Log::Any:D: Log::Any::Pipeline $p, Str:D :$pipeline = '_default', :$overwrite = False ) {
		if %!pipelines{$pipeline} && ! $overwrite {
			die "Cannot overwrite existing pipeline ($pipeline).";
		}
		%!pipelines{$pipeline} = $p;
	}

	proto method log( Log::Any: :$msg!, :$severity!, :$category is copy, :$pipeline = '_default', :%extra-fields --> Bool ) {*}

	multi method log( Log::Any:U: :$msg!, :$severity!, :$category is copy, :$pipeline = '_default', :%extra-fields --> Bool ) {
		return Log::Any.new.log( :$msg, :$severity, :$category, :$pipeline, :%extra-fields);
	}

=begin pod
=head2 method log
=head3 Parameters
=head3 Exceptions
Dies if severity is unknown.
=end pod
	multi method log(Log::Any:D: :$msg!, :$severity!, :$category is copy, :$pipeline is copy, :%extra-fields --> Bool ) {
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
			$category //= '';
		}

		# Capture the date as soon as possible
		my $date-time = DateTime.now;

		# Use the specified pipeline, or the default one
		$pipeline //= '_default';
		# note "Logging using pipeline $pipeline";
		my $pipeline-instance = %!pipelines{ $pipeline } // %!pipelines{'_default'};
		$pipeline-instance.dispatch( :$date-time, :$msg, :$severity, :$category, :%extra-fields, );

		return True;
	}


	# Check if the filter will be accepted with the specified attributes
	multi method will-log( Log::Any:U: :$severity!, :$category is copy, :$pipeline = '_default', :%extra-fields ) returns Bool {
		return Log::Any.new.will-log( :$severity, :$category, :$pipeline );
	}

	multi method will-log( Log::Any:D: :$severity!, :$category is copy, :$pipeline = '_default', :%extra-fields ) returns Bool {

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
			$category //= '';
		}

		# Use the specified pipeline, or the default one
		$pipeline //= '_default';
		# note "Logging using pipeline $pipeline";
		my $pipeline-instance = %!pipelines{ $pipeline } // %!pipelines{'_default'};

		return $pipeline-instance.will-dispatch( :$severity, :$category, :%extra-fields );
	}


	method emergency( $msg, :$category, :$pipeline, :%extra-fields --> Bool ) {
		self.log( :$msg, :severity( 'emergency' ), :$category, :$pipeline, :%extra-fields );
	}

	method alert( $msg, :$category, :$pipeline, :%extra-fields --> Bool ) {
		self.log( :$msg, :severity( 'alert' ), :$category, :$pipeline, :%extra-fields );
	}

	method critical( $msg, :$category, :$pipeline, :%extra-fields --> Bool ) {
		self.log( :$msg, :severity( 'critical' ), :$category, :$pipeline, :%extra-fields );
	}

	method error( $msg, :$category, :$pipeline, :%extra-fields --> Bool ) {
		self.log( :$msg, :severity( 'error' ), :$category, :$pipeline, :%extra-fields );
	}

	method warning( $msg, :$category, :$pipeline, :%extra-fields --> Bool ) {
		self.log( :$msg, :severity( 'warning' ), :$category, :$pipeline, :%extra-fields );
	}

	method info( $msg, :$category, :$pipeline, :%extra-fields --> Bool ) {
		self.log( :$msg, :severity( 'info' ), :$category, :%extra-fields, :$pipeline, :%extra-fields );
	}

	method notice( $msg, :$category, :$pipeline, :%extra-fields --> Bool ) {
		self.log( :$msg, :severity( 'notice' ), :$category, :$pipeline, :%extra-fields );
	}

	method debug( $msg, :$category, :$pipeline, :%extra-fields --> Bool ) {
		self.log( :$msg, :severity( 'debug' ), :$category, :$pipeline, :%extra-fields );
	}

	method trace( $msg, :$category, :$pipeline, :%extra-fields --> Bool ) {
		self.log( :$msg, :severity( 'trace' ), :$category, :$pipeline, :%extra-fields );
	}


	method will-emergency( :$category, :$pipeline = '_default', :%extra-fields ) returns Bool {
		return self.will-log( :severity('emergency'), :$category, :$pipeline, :%extra-fields );
	}

	method will-alert( :$category, :$pipeline = '_default', :%extra-fields ) returns Bool {
		return self.will-log( :severity('alert'), :$category, :$pipeline, :%extra-fields );
	}

	method will-critical( :$category, :$pipeline = '_default', :%extra-fields ) returns Bool {
		return self.will-log( :severity('critical'), :$category, :$pipeline, :%extra-fields );
	}

	method will-error( :$category, :$pipeline = '_default', :%extra-fields ) returns Bool {
		return self.will-log( :severity('error'), :$category, :$pipeline, :%extra-fields );
	}

	method will-warning( :$category, :$pipeline = '_default', :%extra-fields ) returns Bool {
		return self.will-log( :severity('warning'), :$category, :$pipeline, :%extra-fields );
	}

	method will-info( :$category, :$pipeline = '_default', :%extra-fields ) returns Bool {
		return self.will-log( :severity('info'), :$category, :$pipeline, :%extra-fields );
	}

	method will-notice( :$category, :$pipeline = '_default', :%extra-fields ) returns Bool {
		return self.will-log( :severity('notice'), :$category, :$pipeline, :%extra-fields );
	}

	method will-debug( :$category, :$pipeline = '_default', :%extra-fields ) returns Bool {
		return self.will-log( :severity('debug'), :$category, :$pipeline, :%extra-fields );
	}

	method will-trace( :$category, :$pipeline = '_default', :%extra-fields ) returns Bool {
		return self.will-log( :severity('trace'), :$category, :$pipeline, :%extra-fields );
	}

	# Dump Log::Any pipelines
	multi method gist( Log::Any:D: ) {
		return 'Log::Any.new(pipelines => ' ~ %!pipelines.gist ~ ', severities => ' ~ %!severities.gist ~ ')';
	}

	multi method gist( Log::Any:U: ) {
		return Log::Any.new.gist;
	}
}
