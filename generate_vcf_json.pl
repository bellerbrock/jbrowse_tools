#! /usr/bin/perl

use strict;
use warnings;
use File::Slurp;

my $dir = $ARGV[0];
my $out = $ARGV[1] || "vcf_tracks.json";
my @files = ` dir -GD -1 --hide *.tbi $dir ` ; 

for my $file (@files) { 
    chomp $file;
    print "File = $file \n" ;
    my $path = $dir . "/" . $file ; 
    $file =~ s/([^.]+).*/$1/s;
    my $key = $file . "_SNPs" ; 
    print "$key \n";
#    my $json = ' 
#{    
#         "storeClass" : "JBrowse/Store/SeqFeature/VCFTabix",
#         "urlTemplate" : "' . $path . '",#
#	 "category" : "VCF SNPs",
#         "label" : "' . $file .'",
#         "type" : "HTMLVariants",
#         "key" : "' . $key .'"
#}, '  ; 

    my $json = '
[ tracks . ' . $key . ' ]
storeClass = JBrowse/Store/SeqFeature/VCFTabix
urlTemplate = ' . $path .'
category = VCF
type = JBrowse/View/Track/HTMLVariants
key = ' . $key  .'
label = ' . $file  . '
' ;

    write_file( $out, {append => 1}, $json) ;

}
