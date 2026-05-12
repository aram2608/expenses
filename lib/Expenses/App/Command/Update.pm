package Expenses::App::Command::Update;
use strict;
use warnings;
use App::Cmd::Setup -command;
use Expenses::App::Util qw(parse_date);
use Expenses::DB;
use Expenses::Format;

sub abstract { "Update an expenses field" }

sub opt_spec {
    return (
        [ "id=s",     "the id for the expense to be updated (required)" ],
        [ "tag=s",    "tag for the expense e.g. 'dinner'" ],
        [ "note=s",   "note for the expense e.g. 'New book' " ],
        [ "date=s",   "date for the expense e.g. 'May, 05, 2026' " ],
        [ "amount=f", "the cost for the expense in dollars e.g. 20.50 " ],
    );
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;
    $self->usage_error("--id is required") unless defined $opt->id;
    $self->usage_error("at least one of --tag, --note, --date, --amount is required")
        unless defined $opt->tag
        || defined $opt->note
        || defined $opt->date
        || defined $opt->amount;
}

sub execute {
    my ( $self, $opt, $args ) = @_;

    my $date = defined $opt->date ? parse_date( $opt->date ) : undef;

    Expenses::DB::with_db(
        sub {
            my ($dbh) = @_;
            Expenses::DB::update_expense(
                $dbh,
                id     => $opt->id,
                tag    => $opt->tag,
                note   => $opt->note,
                amount => $opt->amount,
                date   => $date,
            );
        }
    );
}

1;

