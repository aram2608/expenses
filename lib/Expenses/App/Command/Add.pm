package Expenses::App::Command::Add;
use strict;
use warnings;
use App::Cmd::Setup -command;
use DateTime;
use Expenses::App::Util qw(parse_date);
use Expenses::DB;
use Expenses::Format;

sub abstract { "Add a new expense" }

sub opt_spec {
    return (
        [ "tag=s",    "expense tag (required)" ],
        [ "amount=f", "expense amount in dollars (required)" ],
        [ "date=s",   "date e.g. 'May, 09, 2026' (default: today)" ],
        [   "note=s",
            "description of expense e.g. 'War and War' (default: 'No description provided' "
        ],
    );
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;
    $self->usage_error("--tag is required")                  unless defined $opt->tag;
    $self->usage_error("--amount is required")               unless defined $opt->amount;
    $self->usage_error("--amount must be greater than zero") unless $opt->amount > 0;
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    my $formatted =
        defined $opt->date ? parse_date( $opt->date ) : DateTime->now->strftime('%Y-%m-%d');
    my $cents = Expenses::Format::dollars_to_cents( $opt->amount );

    Expenses::DB::with_db(
        sub {
            my ($dbh) = @_;
            Expenses::DB::add_expense( $dbh, $opt->tag, $cents, $formatted, $opt->note, );
            printf "Added: %s, \$%s, %s\n",
                $opt->tag,
                Expenses::Format::cents_to_dollars($cents),
                $formatted;
        }
    );
}

1;

=head1 NAME

Expenses::App::Command::Add - Add a new expense

=head1 SYNOPSIS

    exp.pl add --tag groceries --amount 42.50 [--date 'May, 09, 2026']

=cut
