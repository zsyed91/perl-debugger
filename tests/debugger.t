use lib '..';

use Test::Spec;
use Debugger;



describe "A Debugger" => sub {
    my $debug;
    my $file = 'debug.log';

    before all => sub {
        $debug = new Debugger({'log_file' => $file});
    };


    it "should be of class Debugger" => sub {
        
        isa_ok($debug, 'Debugger');
    };

    it "should be able to have debugging methods" => sub {
        can_ok($debug, qw/log dump stacktrace timestamp counter/);
    };



    describe "opens the log file and" => sub {

        it "should create a new file if it does not exist" => sub {

            if (-e $file) {
                unlink $file;
            }

            $debug = new Debugger();
            $debug->log("new file created.");

            my $file_created = -e $file;

            ok($file_created);

        };


        it "should append to the log file if it exists" => sub {

            if (!-e $file){
                open my $filehandle, '>', $file or die "Could not create `$file` for testing:\n $!";
                close $filehandle;
            }

            $debug->log("this is appending content");

            open my $filehandle, '<', $file or die "Could not open `$file` for reading\n $!";

            my $hits = 0;
            while(<$filehandle>) {
            
                if ($_ =~ /^new file created.\s+$/) {
                    $hits++;
                }
                elsif( $_ =~ /^this is appending content\s+$/) {
                    $hits++;
                }
            }

            ok($hits == 2);
            close $filehandle;
        };


        it "should provide a stacktrace" => sub {
            $debug->stacktrace();   

            open my $filehandle, '<', $file or die "Could not open `$file` for reading:\n$!";

            my $stack = 0;
            while (<$filehandle>) {
                if ($_ =~ /STACKTRACE/) {
                    $stack++;
                }
                elsif($_ =~ /Package: /) {
                    $stack++;
                }
                elsif($_ =~ /File: /) {
                    $stack++;
                }
                elsif($_ =~ /Line: /) {
                    $stack++;
                }
                elsif($_ =~ /Method: /) {
                    $stack++;
                }
            }

            close $filehandle;

            ok($stack >= 5);
        };

        it "should provide a timestamp of script time in seconds if > 1s" => sub {

            # Create some time delay to ensure greater than one second time elapses
            sleep 1;

            $debug->timestamp();
            open my $filehandle, '<', $file or die "Could not open `$file` for reading:\n$!";

            my $timestamp = 0;
            while (<$filehandle>) {
                if ($_ =~ /^Script took \d+\.\d+ seconds.\s+$/) {
                    $timestamp = 1;
                    last;
                }
            }

            close $filehandle;

            ok($timestamp == 1);

        };

        it "should provide a timestamp of script time in milliseconds if < 1s" => sub {

            my $debug = Debugger->new();
            $debug->timestamp();
            open my $filehandle, '<', $file or die "Could not open `$file` for reading:\n$!";

            my $timestamp = 0;
            while (<$filehandle>) {
                if ($_ =~ /^Script took \d+\.\d+ milliseconds.\s+$/) {
                    $timestamp = 1;
                    last;
                }
            }

            close $filehandle;

            ok($timestamp == 1);

        };

        it "should output the counter" => sub {
            $debug->counter();

            open my $filehandle, '<', $file or die "Coult not open `$file` for reading\n$!";

            my @lines = <$filehandle>;
            close $filehandle;

            my $line = pop @lines;

            chomp $line;

            ok($line == 1);
        };

        it "should output the correct count from the counter" => sub {
            if (-e $file) {
                unlink $file;
            }

            $debug = new Debugger();

            $debug->counter();
            $debug->counter();
            $debug->counter();

            open my $filehandle, '<', $file or die "Coult not open `$file` for reading\n$!";

            my @lines = <$filehandle>;

            my $line = pop @lines;

            chomp $line;

            ok($line == 3);
        };

    };

};


runtests unless caller;