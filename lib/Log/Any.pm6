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

	method add( Log::Any::Adapter $a ) {
		unless self.DEFINITE {
			self.new.add( $a );
			return;
		}

		%!pipelines{'_default'}.add( $a );
	}

	method log( :$msg!, :$severity!, :$category is copy, :$facility, :$pipeline = '_default' ) {

		# Depending if we are calling the method from an instancied Log::Any, or not
		unless self.DEFINITE {
			return Log::Any.new.log( :$msg, :$severity, :$category, :$facility, :$pipeline );
		}

		# Search the package name of caller if $category is not set
		# Can be null (Any) (no caller package)
		# TODO : limit to some level?
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
