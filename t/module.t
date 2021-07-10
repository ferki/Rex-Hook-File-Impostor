#!/usr/bin/env perl

use 5.010;
use warnings;
use autodie;

use Carp;
use File::Path qw(remove_tree);
use File::Temp;
use Rex::Commands::File;
use Rex::Hook::File::Impostor;
use Test2::V0;
use Test::File 1.443;

our $VERSION = '9999';

plan tests => 9;

my $managed_file  = File::Temp->new('original_XXXX')->filename();
my $impostor_file = Rex::Hook::File::Impostor::get_impostor_for($managed_file);
my $impostor_directory = Rex::Hook::File::Impostor::get_impostor_directory();

my $original_content = 'original';
my $impostor_content = 'impostor';

open my $FILE, '>', $managed_file;
print {$FILE} $original_content or croak "Couldn't write to $managed_file";
close $FILE;

file_exists_ok($managed_file);
file_not_exists_ok($impostor_file);
file_contains_like( $managed_file, qr{$original_content}msx );

file $managed_file, content => $impostor_content;

file_exists_ok($managed_file);
file_exists_ok($impostor_file);

file_contains_like( $managed_file,  qr{$original_content}msx );
file_contains_like( $impostor_file, qr{$impostor_content}msx );

unlink $managed_file, $impostor_file;
remove_tree( $impostor_directory, { safe => 1 } );

file_not_exists_ok($managed_file);
file_not_exists_ok($impostor_directory);
