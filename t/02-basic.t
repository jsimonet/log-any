use v6.c;

use Test;

plan 12;

use Log::Any;

# Can call some methods
ok Log::Any.error( 'an error' ),      'Log::Any.error()';
ok Log::Any.warning( 'a warning' ),   'Log::Any.warning()';
ok Log::Any.info( 'an information' ), 'Log::Any.info()';
ok Log::Any.notice( 'a notice' ),     'Log::Any.notice()';
ok Log::Any.debug( 'a debug' ),       'Log::Any.debug()';
ok Log::Any.trace( 'a trace' ),       'Log::Any.trace()';

my $l = Log::Any.new;
ok $l.error( 'an error' ),      '$l.error()';
ok $l.warning( 'a warning' ),   '$l.warning()';
ok $l.info( 'an information' ), '$l.info()';
ok $l.notice( 'a notice' ),     '$l.notice()';
ok $l.debug( 'a debug' ),       '$l.debug()';
ok $l.trace( 'a trace' ),       '$l.trace()';
