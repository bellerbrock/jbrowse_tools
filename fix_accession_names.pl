#!/usr/bin/perl

use strict;
use warnings;

my $dosage_file = $ARGV[0];

open (LINES, "<", $dosage_file) || die "Can't open dosage file $dosage_file!\n";

open (NEW, ">", "fixed_imputed.txt") || die "Can't open output file!\n";

while (<LINES>) {
    chomp(my $accession = $_);
    if ($accession =~ m/([A-Za-z0-9_]+)\.([A-Za-z0-9_]+)\.([A-Za-z0-9_]+)/) {
	$accession =~ s/([A-Za-z0-9_]+)\.([A-Za-z0-9_]+)\.([A-Za-z0-9_]+)/$1-$2:$3/;
    } else {
	$accession =~ s/([A-Za-z0-9_]+)\.([A-Za-z0-9_]+)/$1:$2/;
    }
    print NEW $accession . "\n"; 
}

print "Dosage file accession names fixed!\n";
