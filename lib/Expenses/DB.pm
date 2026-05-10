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

sub get_total {
    my ( $dbh, $from, $to ) = @_;
    my $total;
    if ( defined $from && defined $to ) {
        $total =
            $dbh->selectrow_array( "SELECT SUM(amount) FROM expenses WHERE date BETWEEN ? AND ?",
            undef, $from, $to );
    } elsif ( defined $from ) {
        $total = $dbh->selectrow_array(
            "SELECT SUM(amount) FROM expenses WHERE date BETWEEN ? AND date('now')",
            undef, $from );
    } else {
        $total = $dbh->selectrow_array("SELECT SUM(amount) FROM expenses");
    }
    return $total // 0;
}

sub get_tags {
    my ( $dbh, $from, $to ) = @_;
    if ( defined $from && defined $to ) {
        return $dbh->selectcol_arrayref(
            "SELECT DISTINCT tag FROM expenses WHERE date BETWEEN ? AND ? ORDER BY tag",
            undef, $from, $to );
    } elsif ( defined $from ) {
        return $dbh->selectcol_arrayref(
            "SELECT DISTINCT tag FROM expenses WHERE date BETWEEN ? AND date('now') ORDER BY tag",
            undef, $from );
    } else {
        return $dbh->selectcol_arrayref("SELECT DISTINCT tag FROM expenses ORDER BY tag");
    }
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

