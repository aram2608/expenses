package Expenses::DB;
use strict;
use warnings;
use DBI;
use FindBin;

sub connect_db {
    my $db_path = "$FindBin::Bin/../expenses.db";
    my $dbh     = DBI->connect(
        "DBI:SQLite:dbname=$db_path",
        "", "",
        {   RaiseError => 1,
            AutoCommit => 1,
        }
    );

    return $dbh;
}

sub add_expense {
    my ( $dbh, $tag, $amount, $date ) = @_;

    my $sth = $dbh->prepare("INSERT INTO expenses (tag, amount, date) VALUES (?, ?, ?)");
    $sth->execute( $tag, $amount, $date );
}

sub where_builder {
    my (%f) = @_;
    my ( @clauses, @binds );
    if ( defined $f{from} ) { push @clauses, "date >= ?"; push @binds, $f{from} }
    if ( defined $f{to} )   { push @clauses, "date <= ?"; push @binds, $f{to} }
    if ( defined $f{tag} )  { push @clauses, "tag = ?";   push @binds, $f{tag} }
    return ( @clauses ? " WHERE " . join( " AND ", @clauses ) : "" ), @binds;
}

sub get_total {
    my ( $dbh,   %f )     = @_;
    my ( $where, @binds ) = where_builder(%f);
    return $dbh->selectrow_array( "SELECT SUM(amount) FROM expenses$where", undef, @binds ) // 0;
}

sub get_tags {
    my ( $dbh,   %f )     = @_;
    my ( $where, @binds ) = where_builder(%f);
    return $dbh->selectcol_arrayref( "SELECT DISTINCT tag FROM expenses$where ORDER BY tag",
        undef, @binds );
}

sub with_db {
    my ($callback) = @_;
    my $dbh = connect_db();
    eval { $callback->($dbh) };
    my $err = $@;
    $dbh->disconnect;
    die $err if $err;
}

1;

=head1 NAME

Expenses::DB - SQLite database access

=head1 FUNCTIONS

=head2 connect_db

Returns a connected DBI handle to C<expenses.db>.

=head2 with_db($callback)

Connects, invokes C<$callback-E<gt>($dbh)>, then disconnects. Dies on error.

=head2 add_expense($dbh, $tag, $amount, $date)

Inserts one expense row. C<$amount> is in cents; C<$date> is C<YYYY-MM-DD>.

=head2 get_total($dbh, %filter)

Returns the SUM of amounts in cents matching the filter. Keys: C<from>, C<to>, C<tag>.

=head2 get_tags($dbh, %filter)

Returns an arrayref of distinct tags matching the filter. Keys: C<from>, C<to>.

=head2 where_builder(%filter)

Returns C<($where_clause, @binds)> for building SQL. Keys: C<from>, C<to>, C<tag>.

=cut

