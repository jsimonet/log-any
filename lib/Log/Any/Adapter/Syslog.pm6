use v6.c;

use Log::Any::Adapter;

use Log::Syslog::Native;

constant %LOGLEVEL = %(
	trace => Log::Syslog::Native::LogLevel::Debug,
	debug => Log::Syslog::Native::LogLevel::Debug,
	info => Log::Syslog::Native::LogLevel::Info,
	notice => Log::Syslog::Native::LogLevel::Notice,
	warning => Log::Syslog::Native::LogLevel::Warning,
	error => Log::Syslog::Native::LogLevel::Error,
	critical => Log::Syslog::Native::LogLevel::Critical,
	alert => Log::Syslog::Native::LogLevel::Alert,
	emergency => Log::Syslog::Native::LogLevel::Emergency,
);

class Log::Any::Adapter::Syslog is Log::Any::Adapter {
	has $!log = Log::Syslog::Native.new(ident => $*PROGRAM-NAME.IO.basename, facility => Log::Syslog::Native::Daemon);

	method handle( $msg, :$severity ) {
		$!log.log(%LOGLEVEL{$severity}, $msg);
		return True;
	}

}
