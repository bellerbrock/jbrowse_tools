#!/usr/bin/perl

use warnings;
use strict;

my $log_file = $ARGV[0];
my $dosage_file = $ARGV[1];
my $temp_file = "temp.txt";

my $chrom_snps = `grep -o "S10_" $log_file | wc -l`;
print "S10 = $chrom_snps\n";
$chrom_snps++;
system ( "cut -f 2-$chrom_snps $dosage_file > $dosage_file.S10" );
system ( "cut --complement -f 2-$chrom_snps $dosage_file > $temp_file.S11" );

for (my $i = 11; $i < 20; $i++) {
    my $l = $i + 1;
    $chrom_snps = `grep -o "S$i" $log_file | wc -l`;
    $chrom_snps++;
    print "S$i = $chrom_snps\n";
    system ( "cut -f 2-$chrom_snps $temp_file.S$i > $dosage_file.S$i" );
    system ( "cut --complement -f 2-$chrom_snps $temp_file.S$i > $temp_file.S$l" );
}

$chrom_snps = `grep -o "S1_" $log_file | wc -l`;
$chrom_snps++;
print "S1 = $chrom_snps\n";
system ( "cut -f 2-$chrom_snps $temp_file.S20 > $dosage_file.S1" );
system ( "cut --complement -f 2-$chrom_snps $temp_file.S20 > $temp_file.S2" );

for (my $i = 2; $i < 10; $i++) {
    my $l = $i + 1;
    $chrom_snps = `grep -o "S$i" $log_file | wc -l`;
    $chrom_snps++;
    print "S$i = $chrom_snps\n";
    system ( "cut -f 2-$chrom_snps $temp_file.S$i > $dosage_file.S$i" );
    system ( "cut --complement -f 2-$chrom_snps $temp_file.S$i > $temp_file.S$l" );
}
`rm *temp.txt*`;
print "done!\n";
