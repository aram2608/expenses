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

    # Dollar amounts are stored with cents as the last two digits
    # So 10 dollars == 1000
    # Display
    # my $display = sprintf('$%.2f', $amount_cents / 100);
    # Store
    # my $cents = int($user_input * 100 + 0.5);
    my $sql = <<~'SQL';
        CREATE TABLE IF NOT EXISTS expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tag TEXT NOT NULL,
            amount INTEGER NOT NULL,
            date TEXT NOT NULL DEFAULT (date('now'))
        )
    SQL

    $dbh->do($sql);

    print "Connected to database successfuly\n";

    return $dbh;
}

sub add_expense {
    my ($tag, $amount, $date, $dbh) = @_;
   
    my $sth = $dbh->prepare(
        "INSERT INTO expenses (tag, amount, date) VALUES (?, ?, ?)"
    ) or die "Failed to prepare SQL statement: $dbh->errstr()\n";
    $sth->execute(
        $tag, 
        $amount, 
        $date
    ) or die "Failed to add expense: $tag, $amount, $date\n";

    $sth->finish();
}

sub print_total {
   my ($dbh) = @_;

    my $sth = $dbh->prepare(
        "SELECT SUM(amount) FROM expenses"
    ) or die "Failed to prepare SQL statement: $dbh->errstr()\n";
    $sth->execute() or die "Failed to sum expenses\n";

    my $total = $sth->fetchrow();

    my $formmated =  sprintf('$%.2f', $total / 100);

    print "Total expenses: $formmated\n"; 

    $sth->finish();
}

1;

