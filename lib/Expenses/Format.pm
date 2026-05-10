package Expenses::Format;
use strict;
use warnings;

sub cents_to_dollars { sprintf( '%.2f', $_[0] / 100 ) }
sub dollars_to_cents { int( $_[0] * 100 + 0.5 ) }

1;

=head1 NAME

Expenses::Format - Amount formatting helpers

=head1 FUNCTIONS

=head2 cents_to_dollars($cents)

Returns a string like C<"12.50"> from an integer cent value.

=head2 dollars_to_cents($dollars)

Returns an integer cent value from a float dollar amount.

=cut
