package Expenses::Format;

sub cents_to_dollars { sprintf('%.2f', $_[0] / 100) }
sub dollars_to_cents { int($_[0] * 100 + 0.5) }

1;
