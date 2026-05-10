package Expenses::App::Command::Total;
use strict;
use warnings;
use App::Cmd::Setup -command;
use DateTime;
use DateTime::Format::Strptime;
use Expenses::DB;
use Expenses::Format;

sub abstract { "Print total expenses stored in the database" }

sub opt_spec {
    return (
        [ "date-to=s",   "end date e.g. 'May, 09, 2026' (requires --date-from)" ],
        [ "date-from=s", "start date e.g. 'May, 09, 2026'" ],
        [ "tag=s",       "tag for the expense e.g. 'dinner'" ],
    );
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    die "--date-to requires --date-from\n"
        if defined $opt->date_to && !defined $opt->date_from;

    my ( $from, $to, $tag );

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

    $to //= DateTime->now->strftime('%Y-%m-%d') if defined $from;

    die "--date-from must not be after --date-to\n"
        if defined $from && defined $to && $from gt $to;

    $tag = $opt->tag if defined $opt->tag;

    Expenses::DB::with_db(
        sub {
            my ($dbh) = @_;
            my $total = Expenses::DB::get_total( $dbh, from => $from, to => $to, tag => $tag );
            printf "Total: \$%s\n", Expenses::Format::cents_to_dollars($total);
        }
    );
}

1;

=head1 NAME

Expenses::App::Command::Total - Print total expenses

=head1 SYNOPSIS

    exp.pl total [--date-from 'May, 01, 2026'] [--date-to 'May, 31, 2026'] [--tag groceries]

=cut
