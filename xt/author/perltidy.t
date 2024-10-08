#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use File::Find;
use Test::More;
use Test::PerlTidy;

our $VERSION = '9999';

if ( !$ENV{AUTHOR_TESTING} ) {
    plan skip_all => 'these tests are for testing by the author';
}

my @files_to_exclude = qw(Makefile.PL .build blib local);
my $xt_dir           = File::Spec->join('xt');

find(
    sub {
        return if $_ eq q(.);
        return if $_ eq 'perltidy.t';

        my $filename = File::Spec->join( $xt_dir, $_ );

        push @files_to_exclude, qr{\Q$filename\E}msx;
    },
    $xt_dir,
);

run_tests( exclude => \@files_to_exclude );
