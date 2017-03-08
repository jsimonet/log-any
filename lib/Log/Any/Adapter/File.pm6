use v6.c;

use Log::Any::Adapter;

class Log::Any::Adapter::File is Log::Any::Adapter {
	has IO::Handle $!fh;

	method BUILD( :$file-name ) {
		$!fh = open $file-name, :a;
		die "File $file-name is not writable" if $!fh.e && ! $!fh.w;
	}

	method handle( $msg ) {
		$!fh.say( $msg );
		return False;
	}

}
