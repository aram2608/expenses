use strict;
use warnings;
use Test2::V0;
use lib 'lib';
use Expenses::DB;

my ( $sql, @binds );

( $sql, @binds ) = Expenses::DB::update_builder( undef, id => 1, tag => 'food' );
is $sql,    'UPDATE expenses SET tag = ? WHERE id = ?', 'single field: sql';
is \@binds, [ 'food', 1 ],                              'single field: binds';

( $sql, @binds ) =
    Expenses::DB::update_builder( undef, id => 2, tag => 'dinner', amount => 1500 );
is $sql,    'UPDATE expenses SET tag = ?, amount = ? WHERE id = ?', 'two fields: sql';
is \@binds, [ 'dinner', 1500, 2 ],                                  'two fields: binds';

( $sql, @binds ) = Expenses::DB::update_builder(
    undef,
    id     => 3,
    tag    => 'lunch',
    amount => 800,
    note   => 'sandwich',
    date   => '2026-05-11',
);
is $sql, 'UPDATE expenses SET tag = ?, amount = ?, note = ?, date = ? WHERE id = ?',
    'all fields: sql';
is \@binds, [ 'lunch', 800, 'sandwich', '2026-05-11', 3 ], 'all fields: binds';

my @empty = Expenses::DB::update_builder( undef, id => 4 );
is \@empty, [], 'no update fields: returns empty list';

done_testing;
