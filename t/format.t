use strict;
use warnings;
use Test2::V0;
use lib 'lib';
use Expenses::Format;

is Expenses::Format::dollars_to_cents(10.00), 1000,    'whole dollars';
is Expenses::Format::dollars_to_cents(10.50), 1050,    'half dollar';
is Expenses::Format::cents_to_dollars(1050),  '10.50', 'back to dollars';

done_testing;
