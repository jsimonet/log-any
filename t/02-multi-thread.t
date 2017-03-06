use v6.c;
use Test;

plan 2;

class ToLog {
	method foo {
		use Log::Any;
		Log::Any.notice( 'a test from ToLog' );
	}
}

use Log::Any::Adapter;
class MultiThreadTest is Log::Any::Adapter {
	has @.logs;

	method handle( $msg ) {
		push @!logs, $msg;
	}
}

my $mtt = MultiThreadTest.new;

{
	use Log::Any;
	Log::Any.add( $mtt );
}

await start {
	ToLog.foo();
}

{
	is $mtt.logs.elems, 1, 'Count logs ok';
	is $mtt.logs[0], 'a test from ToLog', 'Message log ok';
}
