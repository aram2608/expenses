package Expenses::App::Command::Total;
use strict;
use warnings;
use App::Cmd::Setup -command;
use Expenses::DB;

sub abstract     { "Print total expenses stored in the database" }

sub opt_spec {
    return ();
}

sub execute {
  Expenses::DB::with_db(sub {
      my ($dbh) = @_;
      my $total = Expenses::DB::get_total($dbh);
      printf "Total: \$%s\n", Expenses::Format::cents_to_dollars($total);
  });
}

1;
