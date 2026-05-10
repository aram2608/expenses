#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Expenses::App;
Expenses::App->run;

=head1 NAME

exp.pl - CLI entry point for the Expenses application

=head1 SYNOPSIS

    exp.pl <command> [options]

=cut
