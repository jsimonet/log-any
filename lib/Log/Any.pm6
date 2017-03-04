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

	method get-pipeline( Str:D $p-name ) {
		my $pipeline-instance = %!pipelines{$p-name};

		# Get the "default pipeline" if wanted pipeline does not exists
		$pipeline-instance //= %!pipelines{'_default'};

		return $pipeline-instance;
	}

	method add( Log::Any::Adapter $a ) {
		unless self.DEFINITE {
			self.new.add( $a );
			return;
		}

		%!pipelines{'_default'}.add( $a );
	}

	method log( :$msg!, :$severity!, :$category, :$facility, :$pipeline = '_default' ) {
		# Depending if we are calling the method from an instancied Log::Any, or not
		unless self.DEFINITE {
			return Log::Any.new.log( :$msg, :$severity, :$category, :$facility, :$pipeline );
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
