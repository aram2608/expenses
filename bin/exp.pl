#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use Getopt::Long qw(GetOptionsFromArray);
use DateTime;

use DateTime::Format::Strptime;
use lib "$FindBin::Bin/../lib";
use Expenses::DB;

my %commands = (
    'add' => \&cmd_add,
    'total' => \&cmd_total,
    'help' => \&help,
);

my $cmd = shift @ARGV // 'help';
my $handler = $commands{$cmd} or die "Unknown command: $cmd\n";
$handler->(@ARGV);

sub help {
    print "Usage: $0 <SUBCOMMAND> [OPTS]\n";
    print "Available subcommands:\n";
    print "     add     Add a new expense\n";
    print "     total   Print total accumulated expenses\n";
    print "     help    Prints this help message\n";
    exit;
}

sub cmd_add {
    my @args = @_;
    my $tag;
    my $amount;
    my $date;
    my $help = 0;
    my @missing;

    GetOptionsFromArray(\@args,
    "tag=s" => \$tag,
    "amount=f"  => \$amount,
    "date=s" => \$date,
    "help|h|" => \$help,
    ) or die "Bad options for 'add'\n";

    push @missing, '--tag'    unless defined $tag;
    push @missing, '--amount' unless defined $amount;

    if ($help) {
        print "Adds a new expense to the database\n";
        print "Usage: $0 add <TAG> <AMOUNT> <DATE>\n";
        print "     --help, -h  Display this help message\n";
        exit;
    }

    if (@missing) {
      warn "Missing required arguments: " . join(", ", @missing) . "\n\n";
      print "Usage: $0 add <TAG> <AMOUNT> <DATE?>\n";
      exit 1;
    }

    my $parser = DateTime::Format::Strptime->new(
        pattern   => '%B, %d, %Y',
        on_error  => 'croak',
    );


    my $dt = (defined $date) ? $parser->parse_datetime($date) : DateTime->now();

    my $dbh = Expenses::DB::connect_db();

    my $formatted = $dt->strftime('%Y-%m-%d');
    my $cents = int($amount * 100 + 0.5);

    Expenses::DB::add_expense($tag, $cents, $formatted, $dbh);

    print "Added new expense: $tag, $amount, $formatted\n";

    $dbh->disconnect();
}

sub cmd_total {  
    my @args = @_;
    my $help = 0;

    GetOptionsFromArray(\@args,
    "help|h|" => \$help,
    ) or die "Bad options for 'total'\n";

    if ($help) {
        print "Prints the total accumulated expenses over time\n";
        print "Usage: $0 total>\n";
        print "     --help, -h  Display this help message\n";
        exit;
    }

    my $dbh = Expenses::DB::connect_db();

    Expenses::DB::print_total($dbh);

    $dbh->disconnect();
}
