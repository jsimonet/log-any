# NAME

Log::Any

# SYNOPSIS

```perl6
use Log::Any::Adapter::File ( '/path/to/file.log' ); # If possible at init time

use Log::Any;
Log.info( 'yolo' );
Log.error( :category('security'), 'oups');
Log.log( :msg('msg from app'), :category( 'network' ), :severity( Log::Any::INFO ) );
```

# DESCRIPTION

Log::Any is a library to generate and handle application logs.
A log is a message indicating an application status in a moment in time. It has attributes, like a _severity_ (error, warning, …), a _category_, a _date_ and a _message_.

These attributes are used by the "Formatter" to format the log.

They also can be used to filter logs and to choose where the log will be handled (via Adapters).

# FACILITIES

A _facility_ can be used to define alternatives environments (a set of adapters, formatters and options). This allows for some logs to take alternatives path for logging.
If a lib produces logs with a specific facility which is not defined in the log consumers, it will use the default facility.

# ADAPTERS

An adapter handles a log by storing it, or sending it elsewhere.

A few examples:

	- Log::Any::Adapter::File
	- Log::Any::Adapter::Database::SQL
	- Log::Any::Adapter::STDOUT

## FORMATTERS

Often, logs need to be formatted to simplify the storage (time-series databases), or the analysis (grep, log parser).
Formatters are just a string which defines the log format.

Formatters will use the attributes of a Log.

|Symbol|Signification|Description                                  |Default value             |
|------|-------------|---------------------------------------------|--------------------------|
|\\d   |Date (UTC)   |The date on which the log was generated      |Current date time         |
|\\c   |Category     |Can be any anything specified by the user    |The current package/module|
|\\s   |Severity     |Indicates if it's an information, or an error| none                     |
|\\m   |Message      |Payload, explains what is going on           | none                     |

```perl6
use Log::Any::Adapter::STDOUT( :format( '\d \c \m' ) );
```

You can of course use variables in the formatter, but since _\\_ is already used in Perl6 strings interpolation, you have to escape them.

```perl6
my $prefix = 'myapp ';
use Log::Any::Adapter::STDOUT( :path('/path/to/file.log', :format( "$prefix \\d \\c \\s \\m" ) );
```

# EXTRA FEATURES

## Wrapping

### STDOUT, STDERR

Sometimes, applications or libraries are already available, and prints their logs to STDOUT and/or STDERR. Log::Any could captures theses logs and manage them.

### EXCEPTIONS

Catches all unhandled exceptions to log them.

# APPENDICE

use Log::Any ( :async );

--async : enable asynchornous mode
	wait for adapter to write data to the file/network/whatever…

--log-on-error : keep in cache logs in streams (all, from trace to info)
	- if an error occurs (how to detect, using a level?), log the stacktrace ;
	- if nothing special occurs, log what as specified in the filters.
