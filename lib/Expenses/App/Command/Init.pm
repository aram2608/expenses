package Expenses::App::Command::Init;
use strict;
use warnings;
use App::Cmd::Setup -command;
use Expenses::DB;

sub abstract { "Initialize the application" }

sub opt_spec {
    return ();
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    my $dbh = Expenses::DB::connect_db();
    $dbh->do(<<~'SQL');
        CREATE TABLE IF NOT EXISTS expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tag TEXT NOT NULL,
            amount INTEGER NOT NULL,
            date TEXT NOT NULL DEFAULT (date('now'))
        )
    SQL

    print "Created database successfully\n";

    $dbh->disconnect();
}

1;
