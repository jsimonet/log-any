use v6.c;

use Log::Any::Pipeline;

class Log::Any {
	my $instance;

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

	proto method log(Log::Any: :$msg!, :$severity!, :$category is copy, :$facility, :$pipeline = '_default' --> Bool ) {*}

	multi method log(Log::Any:U: :$msg!, :$severity!, :$category is copy, :$facility, :$pipeline = '_default' --> Bool ) {
		return Log::Any.new.log( :$msg, :$severity, :$category, :$facility, :$pipeline );
	}

	multi method log(Log::Any:D: :$msg!, :$severity!, :$category is copy, :$facility, :$pipeline = '_default' --> Bool ) {
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

	method error( $msg, :$category ) {
		self.log( :$msg, :severity( 'error' ), :$category );
	}

	method warning( $msg, :$category ) {
		self.log( :$msg, :severity( 'warning' ), :$category );
	}

	method info( $msg, :$category ) {
		self.log( :$msg, :severity( 'info' ), :$category );
	}

	method notice( $msg, :$category ) {
		self.log( :$msg, :severity( 'notice' ), :$category );
	}

	method debug( $msg, :$category ) {
		self.log( :$msg, :severity( 'debug' ), :$category );
	}

	method trace( $msg, :$category ) {
		self.log( :$msg, :severity( 'trace' ), :$category );
	}

}
