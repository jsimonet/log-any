use v6.c;

=begin pod
=head1 Test if Log::Any logs correctly.
=end pod

use Test;

plan 13;

use Log::Any;
use Log::Any::Adapter;

class AdapterDebug is Log::Any::Adapter {
	has @.logs;
	method handle( $msg ) {
		push @!logs, $msg;
	}
}

my $a = AdapterDebug.new;


# MSG
# msg filter on Str
Log::Any.add( $a, :filter( [msg => 'msgfilter'] ) );

Log::Any.info( 'does not match' );
is $a.logs.elems, 0, '"does not match" does not match "msgfilter"';

Log::Any.info( 'msgfilter' );
is $a.logs.elems, 1, '"msgfilter" match "msgfilter"';

Log::Any.info( 'begin msgfilter' );
is $a.logs.elems, 1, '"begin msgfilter" does not match "msgfilter"';
Log::Any.info( 'msgfilter end' );
is $a.logs.elems, 1, '"msgfilter end" does not match "msgfilter"';


# msg filter on regex
$a.logs = [];
Log::Any.add( $a, :filter( [ msg => /msgfilter/] ), pipeline => 'msg regex filter' );

Log::Any.info( 'does not match', pipeline => 'msg regex filter' );
is $a.logs.elems, 0, '"does not match" does not match /msgfilter/';

Log::Any.info( 'msgfilter', :pipeline('msg regex filter') );
is $a.logs.elems, 1, '"msgfilter" match /msgfilter/';

Log::Any.info( 'begin msgfilter', :pipeline('msg regex filter') );
is $a.logs[*-1], 'begin msgfilter', '"begin msgfilter" match /msgfilter/';
Log::Any.info( 'msgfilter end', :pipeline('msg regex filter') );
is $a.logs[*-1], 'msgfilter end', '"msgfilter end" match /msgfilter/';


# CATEGORY
# get caller class name

class Foo {
	method foo( $pipeline ) {
		Log::Any.info( 'msg from Foo::foo', :pipeline( $pipeline ) );
	}

	method get-method( $pipeline ) {
		return { Log::Any.info( 'msg from Foo::get-method', :pipeline( $pipeline ) ) };
	}
}

class Bar {
	method bar( $pipeline ) {
		my &met = Foo.get-method( $pipeline );
		&met();
	}
}

$a.logs = [];
Log::Any.add( $a, :formatter( '\c \m' ), :pipeline('caller category') );

Foo.foo( 'caller category' );
is $a.logs[*-1], 'Foo msg from Foo::foo', 'Direct call from Foo::foo';

Bar.bar( 'caller category' );
is $a.logs[*-1], 'Bar msg from Foo::get-method', 'Indirect call from Bar::bar';

# category filter on Str

$a .= new;
my $b = AdapterDebug.new;
Log::Any.add(
	$a,
	:filter( [ :category( 'Foo' ) ] ),
	:pipeline('filter on caller category'),
	:formatter( '\c \m' )
);
Log::Any.add(
	$b,
	:pipeline( 'filter on caller category' ),
	:formatter( '\c \m' )
);

Foo.foo( 'filter on caller category' );
Bar.bar( 'filter on caller category' );

is $a.logs[*-1], 'Foo msg from Foo::foo', 'Category filtering';
is $b.logs[*-1], 'Bar msg from Foo::get-method', 'Category filtering';

# category filter on regex

# SEVERITY

$a .= new;
Log::Any.add( $a, :pipeline( 'filter on severity' ), :filter( [ severity => 'info' ] ) );

# Only the first log should be present in the Adapter
Log::Any.info( :pipeline( 'filter on severity' ), 'info severity' );
Log::Any.warning( :pipeline( 'filter on severity' ), 'error severity' );
is $a.elems == 1 && $a.logs[*-1], 'info severity';


# MULTIPLE FILTERS
