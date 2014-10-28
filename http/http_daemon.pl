#!/usr/bin/perl
use strict;
use warnings;
use Carp;
use POSIX qw( setsid );
use IO::Socket;
use File::Find;
use File::stat;

my $dir = "/home";
my @results; 
my $input; 

my $server_port = get_server_port();

daemonize();

handle_connections( $server_port );

exit;

sub daemonize {
chdir '/' or die "Can't read /dev/null:$!";
open STDIN, '/dev/null' or die "Can't read /dev/null: $!";
open STDOUT, '>> /dev/null' or die "Can't write to /dev/null: $!";
open STDERR, '>> /dev/null' or die "Can't write to /dev/null: $!";
defined(my $pid=fork) or die "Can't fork: $!";
exit if $pid;
setsid or die "Can't start a new session: $!";
umask 0;
}

sub get_server_port {
    my $server = IO::Socket::INET->new(
        'Proto'     => 'tcp',
        'LocalPort' => 8888,
        'Listen'    => SOMAXCONN,
        'Reuse'     => 1,
    );
    die "can't setup server" unless $server;

    return $server;
}

sub handle_connections {
    my $port = shift;
    my $handled = 0;

    while ( my $client = $port->accept() ) {
        $handled++;
        chomp ( my $input = <$client> );
	$input =~ s/.+\s\/(.+)\s.+$/$1/;
	if ($input =~ m/\D+/) {
		print $client "ERROR: You must provide an integer number as URL\n";
        print $client "Bye, bye.\n";
	} else {
        my @file_results = find_files($input);
	print $client @file_results, "\n";
        close $client;
	}
    }

    return;
}

sub find_files {
$input = shift;
@results = ();

find (\&wanted, $dir);
sub wanted {
my $file = "$File::Find::dir/$_";

        if ($file =~ /\/_+/) {
                my $length = $file;
                $length = length($length) if $length =~ s/^.+\/(_.+)$/$1/;
                my $stat = stat($file);
                my $ctime = $stat->ctime;
                my $current_time = time;
                my $diff = $current_time - $ctime;
		# hardcoding time
                if ($diff <= $input) {
                #push @results,  "CT: $current_time - CT: $ctime = DIFF: $diff <= INPUT: $input ? :: {\"files\": [\"$file\"],\n\t\"median_length\": $length}\n";
                push @results,  "{\"files\": [\"$file\"],\n\t\"median_length\": $length}\n";
                }
        }
}
return @results;

}
