use v6.c;

class Log::Any::Formatter {
	proto method format( :$date-time, :$msg!, :$category!, :$severity!, :%tags ) { ... }
}

class Log::Any::FormatterBuiltIN is Log::Any::Formatter {
	has Str $.format = '\m';

	method format( :$date-time, :$msg!, :$category!, :$severity!, :%tags ) {
		my $format = $!format;
		# Replace every tag by his value

		$format.subst-mutate( '\d', $date-time, :g );
		$format.subst-mutate( '\s', $severity, :g );
		$format.subst-mutate( '\c', $category, :g );
		$format.subst-mutate( '\m', $msg, :g );

		for %tags.kv -> $k, $v {
			$format.subst-mutate( '\t{'~$k~'}', $v, :g );
		}

		return $format;
	}

}
