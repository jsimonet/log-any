use v6.c;

use Log::Any::Pipeline;

class Log::Any {
	my $instance;

	has %!pipelines;

	method new { self.instance }

	submethod instance {
		# TODO: add default pipeline
		$instance = Log::Any.bless unless $instance;
		return $instance;
	}

	method get-pipeline( Str:D $p-name ) {
		my $pipeline-instance = %!pipelines{$p-name};

		# Get the "default pipeline" if wanted pipeline does not exists
		$pipeline-instance //= %!pipelines{'_default'};

		return $pipeline-instance;
	}

	method add( Log::Any::Adapter $a ) {
		my $p = self.get-pipeline( '_default' );
		$p.add( $a );
	}

	method log( :$msg!, :$severity!, :$category, :$facility, :$pipeline = '_default' ) {
		# Search the pipeline
		my $pipeline-instance = self.get-pipeline( $pipeline );
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
