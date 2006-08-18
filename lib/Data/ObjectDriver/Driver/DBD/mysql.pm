# $Id$

package Data::ObjectDriver::Driver::DBD::mysql;
use strict;
use warnings;
use base qw( Data::ObjectDriver::Driver::DBD );

use Carp qw( croak );
use Data::ObjectDriver::Errors;

use constant ERROR_MAP => {
    1062 => Data::ObjectDriver::Errors->UNIQUE_CONSTRAINT,
};

sub fetch_id { $_[3]->{mysql_insertid} || $_[3]->{insertid} }

sub map_error_code {
    my $dbd = shift;
    my($code, $msg) = @_;
    return ERROR_MAP->{$code};
}

sub sql_for_unixtime {
    return "UNIX_TIMESTAMP()";
}

# yes, MySQL supports LIMIT on a DELETE
sub can_delete_with_limit { 1 }

sub bulk_insert {
    my $dbd = shift;
    my $dbh = shift;
    my $table = shift;

    my $cols = shift;
    my $rows_ref = shift;

    my $sql = "INSERT INTO $table("  . join(',', @{$cols}) . ") VALUES\n";
    my $statement_length = length($sql);

    foreach my $row (@{$rows_ref}) {
	my $line = join(',', map { defined($_) ?  $dbh->quote($_) : 'NULL'} @{$row});
	$statement_length += length($line);
	$sql .= $line . "\n";
    }

    # For now just write all data, at some point we need to lookup the
    # maximum packet size for SQL

    return $dbh->do($sql);
}

1;
