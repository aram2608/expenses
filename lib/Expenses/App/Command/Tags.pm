package Expenses::App::Command::Tags;
use strict;
use warnings;
use App::Cmd::Setup -command;
use DateTime::Format::Strptime;
use Expenses::DB;

sub abstract { "Print all the tags in the database" }

sub opt_spec {
    return (
        [ "date-to=s",   "end date e.g. 'May, 09, 2026' (requires --date-from)" ],
        [ "date-from=s", "start date e.g. 'May, 09, 2026'" ],
    );
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    die "--date-to requires --date-from\n"
        if defined $opt->date_to && !defined $opt->date_from;

    my ( $from, $to );

    if ( defined $opt->date_from || defined $opt->date_to ) {
        my $parser = DateTime::Format::Strptime->new(
            pattern  => '%B, %d, %Y',
            on_error => 'croak',
        );
        $from = $parser->parse_datetime( $opt->date_from )->strftime('%Y-%m-%d')
            if defined $opt->date_from;
        $to = $parser->parse_datetime( $opt->date_to )->strftime('%Y-%m-%d')
            if defined $opt->date_to;
    }

    die "--date-from must not be after --date-to\n"
        if defined $from && defined $to && $from gt $to;

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
