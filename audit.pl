#!/usr/bin/perl

use strict;
use LWP::Simple;

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

	$first = $a[0];

	if (-f $first) {
		$SCAN_TYPE = "file";
	}

	if (-d $first) {
		$SCAN_TYPE = "dir";
	}

	if ($SCAN_TYPE eq "") {
		$SCAN_TYPE = "url";
	}

	push(@STACK, $first);

	foreach my $i (@a) {

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
			if (-d $item) {
				scan_directory($item);
				next;
			}
		}

		if (-f $item) {
			$content = read_file($item);
		}

		if ($SCAN_TYPE eq "url") {
			$content = read_url($item);
		}

		process_content($item, $content);
	}
}

sub	scan_directory {
	my($item) = @_;

	opendir (my $dh, $item);

	while (my $f = readdir $dh) {
		if ($f eq ".") { next; }
		if ($f eq "..") { next; }

		if (-d "${item}/$f") {
			if ($FOLLOW == 1) {
				scan_directory("${item}/${f}");
			}
			next;
		}

		push(@STACK, "${item}/$f");
	}
}

sub	read_file {
	my($item) = @_;
	my($content);

	local $/;
	open (my $fh, "<", $item) or print "Can not open $item\n";
	$content = <$fh>;
	close $fh;

	return $content;
}

sub	read_url {
	my($item) = @_;

	return get($item);
}

sub process_content {
	my($name, $content) = @_;

	print "Processing $name\n";

	if (is_css_file($name)) {
		process_css($name, $content);
		return;
	}

	process_html($name, $content);
}

sub	generate_report {

	return;
}

sub 	is_css_file {
	my($name) = @_;

	#TODO: This will need to be expanded in a loop.
	if ($name =~ m/\.css$/i) {
		return 1;
	}

	return 0;
}

sub 	process_css {
	my($name, $content) = @_;

	return 1;
}

sub 	process_html {
	my($name, $content) = @_;

	return 1;
}