#!/usr/bin/perl

#----------------------------------------------------------------------------------
# Tool to add imputed SNP info for individual cassava accessions to vcf file for display in jbrowse
#----------------------------------------------------------------------------------

use warnings;
use strict;

my $raw_vcf_file = $ARGV[0];
my $dosage_file = $ARGV[1];
my @header;
my $vcf_file;
my $imputed_file;
my $filtered_file;
my @genotypes;
my $placeholder;

open (SNPS, "<", $raw_vcf_file) || die "Can't open $raw_vcf_file!\n";

while (<SNPS>) {

#-----------------------------------------------------------------------------------
# Specify how many input lines (and therefore how many accessions) will be processed
#-----------------------------------------------------------------------------------

    last if ($. == 21);

#------------------------------------------------------------------
# Save header info that should be present in all files into an array
#-------------------------------------------------------------------

    if ($. <= 10) {
    print $. . "\n";
    push @header, $_;

    } else {

#--------------------------------------------------------------------------------------------------
# Take line with individual accession name and extract that name. Use name to create output vcf file
#---------------------------------------------------------------------------------------------------

    my $full_line = $_;
    chomp (my $accession_name = $full_line);
    print $accession_name;
    $accession_name =~ s/^\#\#SAMPLE\=\<ID\=([^,]+).*/$1/;
    print "Working on accession $accession_name\n";
    $vcf_file = $accession_name;
    $vcf_file = $vcf_file . ".vcf";
    print $vcf_file . "\n";
    open (OUT, ">", $vcf_file) || die "Can't open $vcf_file\n";

#--------------------------------------------------------------
# Print header and info about a single accession to output file
#--------------------------------------------------------------

    foreach my $line (@header) {
    print OUT $line;
    }
    print OUT $full_line;

#----------------------------------------------------------------------------------------------------------------
# extract SNP data pertaining to this accession from original vcf file using shell commands. print to output file
#----------------------------------------------------------------------------------------------------------------

    my $column_number = $.;
    $column_number--;
    system ("cut -f 1-9,$column_number $raw_vcf_file | tail -n +10002 >> $vcf_file");
    print "$vcf_file finished!\n";

#-----------------------------------------------------------------------
# extract imputed SNP data pertaining to this accession from dosage file 
#-----------------------------------------------------------------------

    open (IMPS, "<", $dosage_file) || die "Can't open $dosage_file!\n"; 
    while (<IMPS>) {
	if (m/^$accession_name/) {
	    chomp;
	    ($placeholder, @genotypes) = split /\t/;
	} else {
	    next;
	}
	open (VCF, "<", $vcf_file) || die "Can't open $vcf_file!\n";
	$imputed_file = $accession_name . "_imputed" . ".vcf";
	$filtered_file = $accession_name . "_filtered" . ".vcf";
	open (OUTFILE, ">", $imputed_file) || die "Can't open $imputed_file!\n";
	open (OUTFILE2, ">", $filtered_file) || die "Can't open $filtered_file!\n";
	
	LINE: while (<VCF>) {
	    if (!m/^chromosome/) {
		print OUTFILE $_;
		print OUTFILE2 $_;
	    } else {
		chomp;
		my ($CHROM, $POS, $ID, $REF, $ALT, $QUAL, $FILTER, $INFO, $FORMAT, $DATA) = split /\t/;
		if (length($ALT) > 1) {
		    shift @genotypes;
		    next LINE;
		} else {
       		    $_ = $DATA;
		    if (m/(^0|^1)/) {
			print OUTFILE join "\t", $CHROM, $POS, $ID, $REF, $ALT, $QUAL, $FILTER, $INFO, $FORMAT, $DATA;
			print OUTFILE "\n";
			print OUTFILE2 join "\t", $CHROM, $POS, $ID, $REF, $ALT, $QUAL, $FILTER, $INFO, $FORMAT, $DATA;
			print OUTFILE2 "\n";
			shift @genotypes;
		    } else {
			$_ = shift @genotypes;
			if ($_ <= 0.10) {
			    $DATA =~ s/\.\/\./0\/0/;
			} elsif ($_ >= 0.90 && $_ <= 1.10) {
			    $DATA =~ s/\.\/\./0\/1/;
			} elsif ($_ >= 1.90) {
			    $DATA =~ s/\.\/\./1\/1/;
			} else {
			    next LINE;
			}
			print OUTFILE join "\t", $CHROM, $POS, $ID, $REF, $ALT, $QUAL, $FILTER, $INFO, $FORMAT, $DATA;
			print OUTFILE "\n";
		    }
		}
	    }
	    next;
	}
	last;
    }
    close IMPS;
    close VCF;
    close OUTFILE;
    close OUTFILE2;

#----------------------------------------------------
# Report a completed accession and begin the next one
#----------------------------------------------------
    print "$vcf_file imputed file finished\n";
    system ( "bgzip $vcf_file" );
    system ( "bgzip $imputed_file" );
    system ( "bgzip $filtered_file" );
    system ( "tabix -p vcf $vcf_file.gz" );
    system ( "tabix -p vcf $imputed_file.gz" );
    system ( "tabix -p vcf $filtered_file.gz" );
    next;
    }
}


    
       
