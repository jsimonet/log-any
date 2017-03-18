use v6.c;

class Log::Any::Formatter {
	proto method format( :$msg!, :$category!, :$severity! ) { ... }
}

class Log::Any::FormatterBuiltIN is Log::Any::Formatter {
	has Str $.format = '\m';

	method format( :$msg!, :$category!, :$severity! ) {
		my $format = $!format;
		# Replace every tag by his value

		# TODO: current date time should be provided by Log::Any
		$format.subst-mutate( '\d', DateTime.new(now).Str, :g );
		$format.subst-mutate( '\s', $severity, :g );
		$format.subst-mutate( '\c', $category, :g );
		$format.subst-mutate( '\m', $msg, :g );

		return $format;
	}

}
