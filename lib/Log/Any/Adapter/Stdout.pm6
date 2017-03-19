use v6.c;

use Log::Any::Adapter;

class Log::Any::Adapter::STDOUT is Log::Any::Adapter {

	method handle( $msg ) {
		$*OUT.say: $msg;
		return True;
	}

}
