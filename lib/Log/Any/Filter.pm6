use v6.c;

use Log::Any::Definitions;

class Log::Any::Filter {
	proto method filter returns Bool { * }
}

class Log::Any::FilterBuiltIN is Log::Any::Filter {
	has Pair @.checks where .value ~~ Str | Regex;
	has @.severities = @Log::Any::Definitions::SEVERITIES;

	method filter( :$msg!, :$severity!, :$category! ) returns Bool {
		for @!checks -> $f {
			given $f.key {
				when 'severity' {
					if $severity ~~ /^ '<' | '>' | '<=' | '>=' | '=' | '!' / {
						note 'special test for severity';
						return False;
					} else {
						note "testing if $severity is above $f.value()";
						return False;
					}
				}
				when 'category' {
					#note "checking $f.key() with $f.value().perl()";
					return False unless $category ~~ $f.value();
				}
				when 'msg' {
					#note "checking $f.key() with $f.value().perl()";
					return False unless $msg ~~ $f.value();
				}
				default {
					#note "default, oops";
					return False;
				}
			}
		}
		return True;
	}
}
