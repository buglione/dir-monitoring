#!/bin/perl
use strict;
use warnings;
use File::Find;
use POSIX qw(setsid);
use LWP::Simple;

my $dir = "/home";
my $logfile = "/var/log/newfiles.log";

# start the daemon
&daemonize;

while (1) {
    sleep 1;

my @files;
find (\&new_wanted, $dir);

sub new_wanted { 
my $file = "$File::Find::dir/$_";

	if (($file =~ /\/_+/) and (!grep /^$file$/, @files)) {
		&log($file, $logfile);
		push @files, $file ;
	}
}

}

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

sub log {
my $file = shift;
my $logfile = shift;
open (LOG,  ">>$logfile") or die "Can't open logfile: $!";
print LOG "$file\n";
close (LOG);
}

