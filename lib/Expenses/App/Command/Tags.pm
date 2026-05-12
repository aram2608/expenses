package Expenses::App::Command::Tags;
use strict;
use warnings;
use App::Cmd::Setup -command;
use Expenses::App::Util qw(parse_date_range);
use Expenses::DB;

sub abstract { "Print all the tags in the database" }

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
            my $tags = Expenses::DB::get_tags(
                $dbh,
                ( defined $from ? ( from => $from ) : () ),
                ( defined $to   ? ( to   => $to )   : () ),
            );
            print "$_\n" for @$tags;
        }
    );
}

1;

=head1 NAME

Expenses::App::Command::Tags - List all expense tags

=head1 SYNOPSIS

    exp.pl tags [--date-from 'May, 01, 2026'] [--date-to 'May, 31, 2026']

=cut
