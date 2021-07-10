#!/usr/bin/env perl

use 5.006;
use warnings;
use autodie;

use File::Temp;
use Rex::Hook::File::Impostor;
use Test2::V0;

our $VERSION = '9999';

plan tests => 1;

my $managed_file = File::Temp->new(
    TEMPLATE => 'managed_file_XXXX',
    DIR      => Rex::Config->get_tmp_dir(),
)->filename();

my $impostor_file = Rex::Hook::File::Impostor::get_impostor_for($managed_file);
my $impostor_directory = Rex::Hook::File::Impostor::get_impostor_directory();

is( $impostor_file, File::Spec->join( $impostor_directory, $managed_file ) );
