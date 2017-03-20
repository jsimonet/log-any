#!env perl6
use v6.c;

=begin pod
=head1 Basic test file of Log::Any.
=para
This test file tests if basic methods can be called, if the formatter is working correctly and if the generated date by Log::Any is correct.
=end pod

use Test;

plan 21;

use Log::Any;

# Can call some methods
ok Log::Any.error( 'an error' ),      'Log::Any.error()';
ok Log::Any.warning( 'a warning' ),   'Log::Any.warning()';
ok Log::Any.info( 'an information' ), 'Log::Any.info()';
ok Log::Any.notice( 'a notice' ),     'Log::Any.notice()';
ok Log::Any.debug( 'a debug' ),       'Log::Any.debug()';
ok Log::Any.trace( 'a trace' ),       'Log::Any.trace()';

my $l = Log::Any.new;
ok $l.emergency( 'an emergency' ), '$l.emergency()';
ok $l.alert( 'an alert' ),         '$l.alert()';
ok $l.critical( 'a critic' ),      '$l.critical()';
ok $l.warning( 'a warning' ),      '$l.warning()';
ok $l.info( 'an information' ),    '$l.info()';
ok $l.notice( 'a notice' ),        '$l.notice()';
ok $l.debug( 'a debug' ),          '$l.debug()';
ok $l.trace( 'a trace' ),          '$l.trace()';

dies-ok { $l.log( :msg('msg'), :severity('unknownSeverity') ) }, 'unknown severity dies';
dies-ok { $l.log( :msg('msg'), :severity('') ) }, 'empty severity dies';

ok $l.log( :msg(''), :severity('trace' ) ), 'Empty message allowed';

class AdapterDebug is Log::Any::Adapter {
	has @.logs;

	method handle( $msg ) {
		push @!logs, $msg;
	}
}

# Default pipeline
my $a = AdapterDebug.new;
Log::Any.add( $a );
Log::Any.log( :msg( 'test-1' ), :category( 'test-basic' ), :severity('debug') );
is $a.logs, [ 'test-1' ], 'Log "test-1" with default pipeline';

Log::Any.info( "msg\nwith \n newlines\n\n" );
is $a.logs[*-1], 'msg\nwith \n newlines\n\n', 'Newlines correctly removed';


# Formatter test
# test-2 pipeline
$a.logs = [];
Log::Any.add( $a, :pipeline( 'test-2' ), :formatter( '\d \s \c \m' ) );

my $before-log = DateTime.new( now );
Log::Any.log( :pipeline( 'test-2' ), :msg('test-2'), :severity( 'trace' ), :category( 'test-category' ) );
my $after-log = DateTime.new( now );

with $a.logs[*-1] {
	like $_, /^ (<-[\s]>+) \s 'trace test-category test-2' $/, 'Log with formatter in test-2 pipeline';
	# Check if log dateTime is after $before-log, and before $after-log
	with $_ ~~ /^ (<-[\s]>+)/ {
		my $log-dateTime = DateTime.new( $_.Str );
		if $before-log < $log-dateTime < $after-log {
			pass "Log DateTime is in the interval";
		} else {
			flunk "Log DateTime is not in the interval";
		}
	} else {
		flunk "Failed to extract dateTime from log message";
	}
} else {
	flunk 'Log with formatter in test-2 pipeline';
}
