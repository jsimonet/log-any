use v6;
use Test;

plan 2;

class ToLog {
	method foo {
		use Log::Any;
		Log::Any.notice( 'a test from ToLog' );
	}
}

my $p = start {
	sleep 1;
	ToLog.foo();
}

{
	use Log::Any;
	class MultiThreadTest is Log::Any::Adapter {
		has @.logs;

		method handle( $msg ) {
			push @!logs, $msg;
		}
	}

	my $a = MultiThreadTest.new;
	Log::Any.add( $a );

	await $p;

	is $a.logs.elems, 1;
	is $a.logs[0], 'a test from ToLog';
}
