package Expenses::App::Command::Tags;
use strict;
use warnings;
use App::Cmd::Setup -command;
use Expenses::DB;

sub abstract { "Print all the tags in the database" }

sub opt_spec {
    return ();
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    Expenses::DB::with_db(
        sub {
            my ($dbh) = @_;
            my $tags = Expenses::DB::get_tags($dbh);
            print "$_\n" for @$tags;
        }
    );
}

1;
