#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Std;

our ($opt_v, $opt_g);

getopts('v:g:');

my ($chrom, $SNP_pos, $id, $refNT, @extra); 
my @leftovers;
my $found =0;
my $vcf = $opt_v;
my $fasta = $opt_g;
my $results = $vcf;
$results =~ s/.vcf/.val/;
my $chrom_counter = 1;
my $skip_to_next_fasta_chrom =0;
my $chrom_pos = 0;
my $correct_refs = 0;
my $total_correct = 0;
my $incorrect_refs = 0;
my $total_incorrect =0;
my $start_chrom =1;

open (VCF, '<', $vcf) || die "Can't open vcf file $vcf";
open (FASTA, '<', $fasta) || die "Can't open fasta file $fasta";
open (RESULTS, '>', $results) || die "Can't open result file $results";

print STDERR "Working on >Chromosome01\n";

# open vcf, store snp position and ref allele
VCF: while (<VCF>) {
    if (m/^#/) {
	next;
    } else {
	($chrom, $SNP_pos, $id, $refNT, @extra) = split /\t/, $_;
	next unless ($refNT =~ /[A-Z]{1}/ && length($refNT) ==1); # skip indels
	$chrom =~ s/\D//g; # in case chrom # has text
	if ($chrom > $chrom_counter) {
	    $start_chrom = sprintf("%02d", $chrom); #pad with 0s to ensure 2 digits                                                                                                 
            $start_chrom =~ s/(.*)/>Chromosome$1\n/;
	    $chrom_pos =0;
	    $skip_to_next_fasta_chrom = 1;
	    print RESULTS "Chromosome $chrom_counter totals: $correct_refs refNTs correct, $incorrect_refs incorrect.\n";
	    print STDERR "Chromosome $chrom_counter totals: $correct_refs refNTs correct, $incorrect_refs incorrect.\n";
	    print STDERR "Working on $start_chrom\n";
	    $chrom_counter++;
	    $total_correct += $correct_refs;       
	    $total_incorrect += $incorrect_refs;
	    $correct_refs = 0;
	    $incorrect_refs = 0;
	    redo;
	} else {
	    if ($skip_to_next_fasta_chrom == 0){
		&digest_NTs(@leftovers);       
		if ($found ==1) {
		    $found =0;
		    next VCF;
		}
	    }
	    while (<FASTA>) {
		if ($skip_to_next_fasta_chrom == 1 && (!m/$start_chrom/)) {
		    next;
		} elsif ($skip_to_next_fasta_chrom == 1 && (m/$start_chrom/)) {
		    $skip_to_next_fasta_chrom =0;
		}    
		next if m/$start_chrom/;
		chomp $_;
		my @line = split(//, $_);
		&digest_NTs(@line);
		if ($found ==1) {
                    $found =0;
                    next VCF;
                }
		next;
	    }
	}
	next;
    }
}

print RESULTS "Whole genome total: $total_correct refNTs correct, $total_incorrect incorrect.\n";
    
sub digest_NTs () {
    # to iterate through NTs one by one without replacement, keeping track of count and checking each position that a refNT should match
    my $NT;
    my (@NTs) = @_;
    while ($NT=shift(@NTs)) {
	$chrom_pos++;
	if ($chrom_pos == $SNP_pos) {
	    $_ = $NT;
	    if (/$refNT/) {
		$correct_refs++;
		print STDERR "First correct refNT ($refNT) for chrom $chrom found at position $chrom_pos, matches actual NT $NT\n" if ($correct_refs ==1);
		print RESULTS "First correct refNT ($refNT) for chrom $chrom found at position $chrom_pos, matches actual NT $NT\n" if ($correct_refs ==1);
		@leftovers = @NTs;
		$found =1;
		return $found;
	    } else {
		$incorrect_refs++;
		print STDERR "First incorrect refNT ($refNT) for chrom $chrom found at position $chrom_pos, should be $NT\n" if ($incorrect_refs ==1);
		print RESULTS "First incorrect refNT ($refNT) for chrom $chrom found at position $chrom_pos, should be $NT\n" if ($incorrect_refs ==1);
		@leftovers = @NTs;
		$found =1;
		return $found;
	    }
	} else {
	    next;
	}
    }
}
