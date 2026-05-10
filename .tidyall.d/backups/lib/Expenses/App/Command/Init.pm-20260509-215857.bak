package Expenses::App::Command::Init;
use strict;
use warnings;
use App::Cmd::Setup -command;
use DBI;
use FindBin;

sub abstract     { "Initialize the application" }

sub opt_spec {
    return ();
}

sub execute {
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

    print "Created database successfuly\n";

    $dbh->disconnect();
}

1;
