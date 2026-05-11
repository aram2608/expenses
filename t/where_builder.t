use strict;
use warnings;
use Test2::V0;
use lib 'lib';
use Expenses::DB;

my ( $where, @binds );

( $where, @binds ) = Expenses::DB::where_builder();
is $where,  '', 'no filters: empty clause';
is \@binds, [], 'no filters: no binds';

( $where, @binds ) = Expenses::DB::where_builder( from => '2026-01-01' );
is $where,  ' WHERE date >= ?', 'from: correct clause';
is \@binds, ['2026-01-01'],     'from: correct bind';

( $where, @binds ) = Expenses::DB::where_builder( to => '2026-12-31' );
is $where,  ' WHERE date <= ?', 'to: correct clause';
is \@binds, ['2026-12-31'],     'to: correct bind';

( $where, @binds ) = Expenses::DB::where_builder( tag => 'dinner' );
is $where,  ' WHERE tag = ?', 'tag: correct clause';
is \@binds, ['dinner'],       'tag: correct bind';

( $where, @binds ) = Expenses::DB::where_builder( from => '2026-01-01', to => '2026-12-31' );
is $where,  ' WHERE date >= ? AND date <= ?', 'from+to: correct clause';
is \@binds, [ '2026-01-01', '2026-12-31' ],   'from+to: correct binds';

( $where, @binds ) = Expenses::DB::where_builder( from => '2026-05-01', tag => 'dinner' );
is $where,  ' WHERE date >= ? AND tag = ?', 'from+tag: correct clause';
is \@binds, [ '2026-05-01', 'dinner' ],     'from+tag: correct binds';

( $where, @binds ) =
    Expenses::DB::where_builder( from => '2026-01-01', to => '2026-12-31', tag => 'lunch' );
is $where,  ' WHERE date >= ? AND date <= ? AND tag = ?', 'all filters: correct clause';
is \@binds, [ '2026-01-01', '2026-12-31', 'lunch' ],      'all filters: correct binds';

done_testing;
