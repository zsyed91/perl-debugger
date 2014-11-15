###
# A pure perl debugger class to inspect objects, variables, and provide stacktraces 
#   along with timing scripts, methods, etc
# Check https://github.com/zsyed91/perl-debugger/ for the latest updates.
#
# Author:       Zshawn Syed
# Version:      1.0.0
# Licence:      Perl-Debugger is licenced under MIT licence (http://opensource.org/licenses/MIT)
### 

package Debugger;
use strict;

use Data::Dumper;



sub new {

	my ($class, $args) = @_;


	my $self = {};

	$self->{'log_file'} = $args->{'log_file'} || 'debug.log';

	$self->{'header_printed'} = 0;
	$self->{'start_time'} = time();

	bless $self, $class;

	return $self;
}


# Simply print the contents out to the log file
sub log {
	my $self = shift;
	my $message = shift;


	$self->_print($message);
}


# Provide a full stacktrace at point of method invocation
sub stacktrace {
	my $self = shift;

	my $level = 0;

	my $output;

	$self->_print("*" x 50 . "\n[ STACKTRACE ]\n\n");
	while(my @stack = caller($level++)) {
		$output = <<EOC;
	[Level $level]
			Package: $stack[0]
			   File: $stack[1]
			   Line: $stack[2]
			 Method: $stack[3]

EOC
		$self->_print($output);
	}

	$self->_print("*" x 50 . "\n\n");

}



# Do a data dump on the contents and print it to the log file
sub dump {
	my $self = shift;
	my $message = shift;

	$self->_print(Dumper $message);
}


# Get how long it took to run a script from object init to this function call
sub timestamp {
	my $self = shift;

	my $final_time = time() - $self->{'start_time'};

	$self->log("Script took $final_time seconds.");
}

sub _print_header {
	my $self = shift;

	$self->{'header_printed'} = 1;

	my $now_time = localtime();

	my $message = "-" x 50 . "\n"
	              . "[ $now_time ]\n\n\n";
	$self->_print($message);
		
}



sub _print {
	my $self = shift;
	my $message = shift;


	unless ($self->{'header_printed'}) {
		$self->_print_header();
	}

	open my $filehandle, '>>', $self->{'log_file'} or die "Could not open $self->{'log_file'}\n $!";

	print $filehandle $message, "\n";
}





1;