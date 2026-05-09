

my @colors = ("red", "blue", "green");

my %ages = ("Alice" => 25, "Bob" => 30);


print $ages{"Alice"} . "\n";

foreach my $person (keys %ages) {
    print "$person is $ages{$person} years old\n"; 
}

foreach my $color (@colors) {
    print "$color\n";
}

# $_ is the default variable, if something is not set it is set
for (1..5) {
    print "Counting: $_\n";
}

