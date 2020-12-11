#!/usr/bin/perl

use strict;
use LWP::Simple;
use HTML::Parser;
use CSS::DOM;

#TODO: Get rid of this?
use HTML::DOM;
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

# These may go away...

my %FILES_USING_SELECTORS;
my %SELECTORS_IN_FILES;

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

	if (is_css_file($name)) {
		process_css($name, $content);
		return;
	}

	if (is_html_file($name)) {
		process_html($name, $content);
		return;
	}
}

sub	generate_report {

	return;
}

sub 	is_html_file {
	my($name) = @_;

	#TODO: This will need to be expanded in a loop.
	if ($name =~ m/\.html$/i) {
		return 1;
	}

	return 0;
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
	my($css);

	print "Processing $name as css file.\n";

	$css = CSS::DOM::parse($content);
	my @rules = $css->cssRules;

	foreach my $rule (@rules) {
		if (ref($rule) eq "SCALAR") {
			process_css_selector($name, $rule->selectorText);
			process_css_body($name, $rule->cssText);
		}
	}


	return 1;
}

sub 	process_html {
	my($name, $content) = @_;

	print "Processing $name as html file.\n";
	return 1;
}

sub	process_css_selector {
	my($name, $selectors) = @_;

	foreach my $selector (split(/\s+/, $selectors)) {
		if ($selector =~ m/(\S+):.+/) {
			$selector = $1;
		}

		if ($selector =~ m/^\#.+/) {
			process_css_id($name, $selector);
			next;
		}

		if ($selector =~ m/^\..+/) {
			process_css_class($name, $selector);
			next;
		}

		process_css_entity($name, $selector);
	}

}

sub	process_css_body {
	my($name, $body) = @_;

	# print "$name\tcss body\t$body\n";
}

sub	process_css_id {
	my($name, $selector) = @_;

	print "$name\tcss id\t$selector\n";
}

sub	process_css_class {
	my($name, $selector) = @_;

	print "$name\tcss class\t$selector\n";
}

sub	process_css_entity {
	my($name, $selector) = @_;

	print "$name\tcss entity\t$selector\n";
}