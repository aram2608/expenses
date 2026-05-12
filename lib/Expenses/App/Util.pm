package Expenses::App::Util;
use strict;
use warnings;
use DateTime::Format::Strptime;
use Exporter 'import';

our @EXPORT_OK = qw(parse_date parse_date_range);

my $PARSER = DateTime::Format::Strptime->new(
    pattern  => '%B, %d, %Y',
    on_error => 'croak',
);

sub parse_date {
    my ($str) = @_;
    return $PARSER->parse_datetime($str)->strftime('%Y-%m-%d');
}

sub parse_date_range {
    my ($opt) = @_;
    my ( $from, $to );
    $from = parse_date( $opt->date_from ) if defined $opt->date_from;
    $to   = parse_date( $opt->date_to )   if defined $opt->date_to;
    die "--date-from must not be after --date-to\n"
        if defined $from && defined $to && $from gt $to;
    return ( $from, $to );
}

1;
