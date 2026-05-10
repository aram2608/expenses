package Expenses::App;
use strict;
use warnings;

use App::Cmd::Setup -app;
1;

=head1 NAME

Expenses::App - App::Cmd application root

=head1 DESCRIPTION

Wires up the L<App::Cmd> framework. Commands are auto-discovered under
C<Expenses::App::Command::*>.

=cut
