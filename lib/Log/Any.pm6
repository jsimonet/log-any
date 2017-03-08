use v6.c;

use Log::Any::Pipeline;

=begin pod
=head1 Log::Any
=end pod
class Log::Any {
	my $instance;
	my constant @SEVERITIES = <trace debug info notice warning error critical alert emergency>;

	has %!pipelines = { '_default' => Log::Any::Pipeline.new };

	method new {
		unless $instance {
			$instance = Log::Any.bless;
		}
		return $instance;
	}

	# Log::Any.add
	multi method add( Log::Any:U: Log::Any::Adapter $a ) {
		return self.new.add( $a );
	}

	# Log::Any.new.add
	multi method add( Log::Any:D: Log::Any::Adapter $a ) {
		%!pipelines{'_default'}.add( $a );
	}

	proto method log(Log::Any: :$msg!, :$severity!, :$category is copy, :$pipeline = '_default' --> Bool ) {*}

	multi method log(Log::Any:U: :$msg!, :$severity!, :$category is copy, :$pipeline = '_default' --> Bool ) {
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
		die "Unknown severity $severity" unless $severity ~~ @SEVERITIES.any;

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
