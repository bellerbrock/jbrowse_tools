#!/usr/bin/perl

use strict;
use warnings;

my $dosage_file = $ARGV[0];
my $out_file = $dosage_file . ".filtered";

open (LINES , '<', $dosage_file) || die "Can't open dosage file $dosage_file\n";

open (FILE , '>', $out_file) || die "Can't open outfile $out_file\n";

while (<LINES>) {
    if (m/NA\tNA\tNA\tNA/) {
	next;
    } else {
	print FILE;
    }
}
print "$dosage_file filtered!\n";
