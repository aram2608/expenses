use strict;
use warnings;
use Test2::V0;
use lib 'lib';
use DBI;
use Expenses::DB;

sub test_dbh {
    my $dbh =
        DBI->connect( 'DBI:SQLite:dbname=:memory:', '', '', { RaiseError => 1, AutoCommit => 1 } );
    $dbh->do(
'CREATE TABLE expenses (id INTEGER PRIMARY KEY, tag TEXT, amount INTEGER, date TEXT, note TEXT)'
    );
    return $dbh;
}

my $dbh = test_dbh();
Expenses::DB::add_expense( $dbh, 'dinner', 500,  '2026-04-29' );
Expenses::DB::add_expense( $dbh, 'dinner', 2500, '2026-05-01' );
Expenses::DB::add_expense( $dbh, 'lunch',  1200, '2026-05-02' );

is Expenses::DB::get_total($dbh), 4200, 'total without filter';
is Expenses::DB::get_total( $dbh, tag  => 'dinner' ),     3000, 'total by tag';
is Expenses::DB::get_total( $dbh, from => '2026-05-02' ), 1200, 'total from date';
is Expenses::DB::get_total( $dbh, from => '2026-04-29', to => '2026-05-01', ), 3000,
    'total from and to date';

my $tags = Expenses::DB::get_tags($dbh);
is $tags, [ 'dinner', 'lunch' ], 'tags sorted';

done_testing;
