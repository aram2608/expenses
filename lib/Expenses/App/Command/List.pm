package Expenses::App::Command::List;
use strict;
use warnings;
use App::Cmd::Setup -command;
use Expenses::App::Util qw(parse_date_range);
use Expenses::DB;

sub abstract    { "Print all the entries in the database" }
sub description { "Print all entries in the database, can be subset by 'date'" }

sub opt_spec {
    return (
        [ "date-to=s",   "end date e.g. 'May, 09, 2026' (requires --date-from)" ],
        [ "date-from=s", "start date e.g. 'May, 09, 2026'" ],
    );
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;
    $self->usage_error("--date-to requires --date-from")
        if defined $opt->date_to && !defined $opt->date_from;
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    my ( $from, $to ) = parse_date_range($opt);

    Expenses::DB::with_db(
        sub {
            my ($dbh) = @_;
            my $expenses = Expenses::DB::get_expenses(
                $dbh,
                ( defined $from ? ( from => $from ) : () ),
                ( defined $to   ? ( to   => $to )   : () ),
            );
            printf "%i %s %-12s %8.2f %s\n", $_->{id}, $_->{date}, $_->{tag}, $_->{amount} / 100,
                $_->{note} // ''
                for @$expenses;
        }
    );
}

1;

