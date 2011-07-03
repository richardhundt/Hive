use inc::Module::Install;

name('Hive');
author('Richard Hundt <perl@kulabs.com>');
abstract('Flow-Based Programming for Perl');
license('artistic');
version_from('lib/Hive.pm');
build_requires('Test::More');

my @depends = qw/
    Coro
    Event
    Coro::Event
    IO::Scalar
/;

requires( map { $_ => undef } @depends );

check_nmake();
&WriteAll();
