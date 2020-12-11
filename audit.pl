#!/usr/bin/perl

use strict;

#################################################################################################

my $FOLLOW = 0;
my $SCAN_TYPE = "";
my @STACK;
my @IDS;
my @CLASSES;

my %RESULTS;

my @DISPLAY_IDS;
my @DISPLAY_CLASSES;
my @DISPLAY_LIST;

#################################################################################################

parse_params(@ARGV);

print_request();

process_stack();

generate_report();

exit;

#################################################################################################

sub parse_params {
	my(@a) = @_;
	my($first);

	$first = 1;

	foreach my $i (@a) {

		if ($first == 1) {
			$first = 0;
			push(@STACK, $i);

			if (-f $i) {
				$SCAN_TYPE = "file";
				next;
			}

			if (-d $i) {
				$SCAN_TYPE = "dir";
				next;
			}

			$SCAN_TYPE = "url";
			next;
		}

		if ($i eq "-follow") {
			$FOLLOW = 1;
			next;
		}

		if ($i eq "-nofollow") {
			$FOLLOW = 0;
			next;
		}

		if ($i =~ m/\.(\w+)/) {
			push(@DISPLAY_CLASSES, $i);
			next;
		}

		if ($i =~ m/\#(\S+)/) {
			push(@DISPLAY_IDS, $i);
			next;
		}

	}
}

sub	print_request {
	print "Going to do a $SCAN_TYPE scan starting with ($STACK[0]).\n";
	print "We\'ll display:\n";
	print "\tID\'s: " . join(", ", @DISPLAY_IDS) . "\n";
	print "\tCLASS\'s: " . join(", ", @DISPLAY_CLASSES) . "\n";
}

sub	process_stack {
	while (my $item = pop(@STACK)) {
		my($content);

		if ($SCAN_TYPE eq "dir") {
			scan_directory($item);
			next;
		}

		if ($SCAN_TYPE eq "file") {
			$content = read_file($item);
		}

		if ($SCAN_TYPE eq "url") {
			$content = read_url($item);
		}

		#process_content($content);
	}
}

sub	scan_directory {
	my($item) = @_;

}

sub	read_file {
	my($item) = @_;

	print "Reading $item\n";
}

sub	read_url {
	my($item) = @_;

}

sub	generate_report {

}