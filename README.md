perl-debugger
=============

Perl Debugger class


### Features

- Log method to log strings and scalar variables
- Dump method to inspect data structures, objects and other variables
- Provide stacktraces
- Provide timing
	- Script
	- Methods only
	- Arbitrary points
- A pure perl library


### How to use

All you need to do is import the library by putting this in your script:
`use Debugger;`

#### Constructor arguments

`log_file => path/to/debug/file`

This is optional and defaults to `debug.log` where the script is stored.


### Examples

#### Object instantiation

	my $debug = new Debugger();
Or
	my $debug = new Debugger({
		'log_file' => '/path/to/debug/file'
	});


#### Log a message or scalar variable

	my $x = "some text in this variable";
	$debug->log($x);

Will output `some text in this variable` into the log file.


#### Dump an object or variable

##### Example 1
	my @lines = get_lines();

	$debug->dump(\@lines);

Will output the contents of `@lines` to the log file.

##### Example 2
	my $class = new Some::Class();
	$debug->dump($class);

#### Time a script

	# Top of script
	my $debug = new Debugger(); # <- Time starts from constructor

	... rest of script

	$debug->timestamp(); # <- Provides time difference from constructor to this point and logs it

#### Provide a stacktrace
	
	sub a_function_nested_deeply {
		my $self = shift;

		$debug->stacktrace(); # <- Provide how we got here via stacktrace;
	}


#### Output a counter

    my $debug = new Debugger();
    
    while ($meets_criteria) {
    	$debug->counter();

    	$meets_criteria = check_criteria();
    }