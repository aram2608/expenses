package Expenses::DB;
use strict;
use warnings;
use DBI;
use FindBin;

sub connect_db {
    my $db_path = "$FindBin::Bin/../expenses.db";
    my $dbh = DBI->connect("DBI:SQLite:dbname=$db_path", "", "", {
        RaiseError => 1,
        AutoCommit => 1,
    });

    return $dbh;
}

sub add_expense {
    my ($tag, $amount, $date, $dbh) = @_;
   
    my $sth = $dbh->prepare("INSERT INTO expenses (tag, amount, date) VALUES (?, ?, ?)");

    $sth->execute(
        $tag, 
        $amount, 
        $date
    ) or die "Failed to add expense: $tag, $amount, $date\n";

    $sth->finish();
}

sub get_total {
    my ($dbh) = @_;
    return $dbh->selectrow_array("SELECT SUM(amount) FROM expenses");
}

sub get_tags {
    my ($dbh) = @_;
    return $dbh->selectcol_arrayref("SELECT DISTINCT tag FROM expenses ORDER BY tag");
}

sub with_db {
  my ($callback) = @_;
  my $dbh = connect_db();
  $callback->($dbh);
  $dbh->disconnect;
}

1;

