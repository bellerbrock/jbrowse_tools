#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;
use Try::Tiny;
use CXGN::DB::InsertDBH;

our ($opt_H, $opt_D, $opt_t);

getopts('H:D:t');

my $dbhost = $opt_H;
my $dbname = $opt_D;

# store database handle and schema

my $dbh = CXGN::DB::InsertDBH->new( { dbhost=>$dbhost,
				      dbname=>$dbname,
				      dbargs => {AutoCommit => 0,
						 RaiseError => 1}
				    }
);	

# prepare sql statements
	
my $term_query = "SELECT cvterm_id, name FROM cvterm WHERE cv_id = 50;";
my $insert_statement = "INSERT INTO materialized_traits VALUES ( ? , ?);";
my $t=$dbh->prepare($term_query);
my $i=$dbh->prepare($insert_statement);

# collect trait names and cvterm_ids

try {

    $t->execute;

# insert into materialized trait table

    &insert_loop($t);

} catch {
    # Rollback if transaction failed                                          
    $dbh->rollback();
    die "An error occured! Transaction rolled back!" . $_ . "\n";
};

if (!$opt_t) {
    # commit if this is not a test run                                         
    $dbh->commit();
    print "Insertion succeeded! Commiting insertion of traits \n\n";

} else {
    # Rolling back because test run                                            
    print "No errors occurred. Rolling back test run. \n\n";
    $dbh->rollback();
}

sub insert_loop {
    my $sth = $_[0];
    while (my($cvterm_id,$name) = $sth->fetchrow_array) {
	$name =~ s/(.*)/CO:$1/;  # Add 'CO:' to name
	print STDERR "Inserting $name trait into materialized trait table\n";
	$i->execute($cvterm_id,$name);
    }
}
