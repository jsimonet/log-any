use v6.c;

use Test;

plan 17;

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
