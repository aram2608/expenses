Bug Report — expenses CLI

Generated 2026-05-10

---
Bug 1 — tags silently includes future-dated entries when only --date-from is given

Severity: Medium
File: lib/Expenses/App/Command/Tags.pm:39

Description

Total defaults $to to today when --date-from is given without --date-to (line 39 of Total.pm). Tags has no such default, so exp.pl tags
--date-from "Jan, 01, 2026" returns tags from any future-dated entries as well — inconsistent with what total --date-from "Jan, 01, 2026" would
count.

Total.pm (has it):
$to //= DateTime->now->strftime('%Y-%m-%d') if defined $from;  # line 39

Tags.pm (missing it):
# no equivalent — $to stays undef, so no upper bound is applied

Fix

Add use DateTime; to the imports and insert the default after parsing:

use DateTime;
# ...
$from = $parser->parse_datetime( $opt->date_from )->strftime('%Y-%m-%d')
  if defined $opt->date_from;
$to = $parser->parse_datetime( $opt->date_to )->strftime('%Y-%m-%d')
  if defined $opt->date_to;

$to //= DateTime->now->strftime('%Y-%m-%d') if defined $from;  # <-- add this

---
Bug 2 — add confirmation message shows unrounded input, not the stored amount

Severity: Low
File: lib/Expenses/App/Command/Add.pm:45

Description

The stored amount is correctly converted to integer cents via dollars_to_cents (which rounds), but the confirmation print uses $opt->amount —
the raw float from the command line — not the rounded value. For an input like --amount 10.999, the DB stores 1100 cents ($11.00), but the user
sees:

Added: groceries, $10.999, 2026-05-10

Fix

Convert cents back to the canonical display string:

# Before
print "Added: " . $opt->tag . ", \$" . $opt->amount . ", $formatted\n";

# After
printf "Added: %s, \$%s, %s\n",
  $opt->tag,
  Expenses::Format::cents_to_dollars($cents),
  $formatted;

---
Bug 3 — dollars_to_cents silently mismaps certain amounts due to floating-point error

Severity: Low
File: lib/Expenses/Format.pm:6

Description

sub dollars_to_cents { int( $_[0] * 100 + 0.5 ) }

Multiplication by 100 in IEEE 754 double precision produces values slightly below the exact half-cent boundary for some inputs. Example:

┌───────┬──────────────────────┬───────────┬──────────┬──────────┐
│ Input │ $_[0] * 100 (actual) │   + 0.5   │ int(...) │ Expected │
├───────┼──────────────────────┼───────────┼──────────┼──────────┤
│ 2.675 │ 267.4999999999…      │ 267.9999… │ 267      │ 268      │
├───────┼──────────────────────┼───────────┼──────────┼──────────┤
│ 1.005 │ 100.4999999999…      │ 100.9999… │ 100      │ 101      │
└───────┴──────────────────────┴───────────┴──────────┴──────────┘

The error only affects amounts whose floating-point representation of × 100 falls just below a .5 boundary, but it rounds silently in the wrong
direction.

Fix

Use sprintf to delegate rounding to the C runtime's decimal-aware formatter:

sub dollars_to_cents { int( sprintf('%.0f', $_[0] * 100) ) }

sprintf '%.0f' applies banker's / round-half-even on most platforms, which handles the edge cases that raw IEEE arithmetic misses.
Alternatively, parse the dollar string as two integer parts to avoid floating-point entirely:

sub dollars_to_cents {
  my ($dollars, $cents) = split /\./, sprintf('%.2f', $_[0]);
  return $dollars * 100 + $cents;
}
