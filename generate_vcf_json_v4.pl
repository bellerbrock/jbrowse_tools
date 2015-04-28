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
hooks.modify = function( track, feature, div ) { div.style.backgroundColor = track.config.variantIsHeterozygous(feature) ? \'red\' : \'blue\' ;  div.style.opacity = track.config.variantIsImputed(feature) ? \'0.33\' : \'1.0\'; }
key = ' . $key  .'
# multiline callbacks can be defined in tracks.conf format files
variantIsHeterozygous = function( feature ) {
    /* javascript comments inside callback should use this format, not double slash format */
    var genotypes = feature.get(\'genotypes\');
    for( var sampleName in genotypes ) {
        try {
            var gtString = genotypes[sampleName].GT.values[0];
            if( ! /^1([\|\/]1)*$/.test( gtString) && ! /^0([\|\/]0)*$/.test( gtString ) )
                return true;
        } catch(e) {}
    }
    return false;
    /* note: the body of the function including the closing brackets should be spaced away from the left-most column
        there should also not be empty lines */
  }
variantIsImputed = function( feature ) {
    var genotypes = feature.get(\'genotypes\');
    for( var sampleName in genotypes ) {
        try {
            var dpString = genotypes[sampleName].DP.values[0];
            if( /^0$/.test( dpString) )
                return true;
        } catch(e) {}
    }
    return false;
  }
storeClass = JBrowse/Store/SeqFeature/VCFTabix
urlTemplate = ' . $path .'
category = VCF
type = JBrowse/View/Track/HTMLVariants
metadata.category = VCF
metadata.Description = Variants called from combined_vcf_files_20150420.vcf.  Heterozygous variants are shown in red, homozygous variants in blue. Imputed variants shown 1/3 opacity.
label = ' . $file  . '
' ;

    write_file( $out, {append => 1}, $json) ;

}
