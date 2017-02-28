use v6.c;

use Log::Any::Adapter;

class Log::Any::Adapter::STDOUT is Log::Any::Adapter {

	method handle( $msg ) {
		# Remove traling newline
		say $msg.chomp;
		return True;
	}

}
