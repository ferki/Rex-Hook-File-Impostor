package Rex::Hook::File::Impostor;

# ABSTRACT: execute Rex file management commands on a copy of the original file

use 5.012;
use warnings;

use Digest::MD5;
use English qw( -no_match_vars );
use File::Basename;
use File::Spec;
use Rex 1.013004 -base;
use Rex::Hook;
use Sys::Hostname;

our $VERSION = '9999';

register_function_hooks { before => { file => \&copy_file, }, };

sub copy_file {
    my ( $original_file, @opts ) = @_;

    my $impostor_file = get_impostor_for($original_file);

    Rex::Logger::debug("Copying $original_file to $impostor_file");

    mkdir dirname($impostor_file);
    cp $original_file, $impostor_file;

    return $impostor_file, @opts;
}

sub get_impostor_for {
    my $file = shift;

    return File::Spec->catfile( get_impostor_directory(), $file );
}

sub get_impostor_directory {
    my $hasher = Digest::MD5->new();

    $hasher->add(hostname);
    $hasher->add($PID);

    my $unique_id = $hasher->hexdigest();

    my $tmp_dir = File::Spec->catfile( Rex::Config->get_tmp_dir(),
        'rex_hook_file_impostor', $unique_id );

    mkdir $tmp_dir;
    return $tmp_dir;
}

1;

__END__

=for :stopwords CPAN sponsorware

=head1 SYNOPSIS

    use Rex::Hook::File::Impostor;

=head1 DESCRIPTION

This module lets L<Rex|https://metacpan.org/pod/Rex> execute file management commands on a copy of the file instead of the original one.

This could be particularly useful when it is loaded conditionally to be combined with other modules. For example together with L<Rex::Hook::File::Diff|https://metacpan.org/pod/Rex::Hook::File::Diff>, it could be used to show a diff of file changes without actually changing the original file contents.

It works by installing a L<before hook|https://metacpan.org/pod/Rex::Commands::File#Hooks> for file commands, which makes a copy of the original file into a temporary directory, and then overrides the original arguments of the L<file commands|https://metacpan.org/pod/Rex::Commands::File#file>.

=head1 DIAGNOSTICS

This module does not do any error checking (yet).

=head1 CONFIGURATION AND ENVIRONMENT

It uses the same temporary directory that is used by Rex. Therefore it can be configured with L<set_tmp_dir|https://metacpan.org/pod/Rex::Config#set_tmp_dir>:

    Rex::Config->set_tmp_dir($tmp_dir);

This module does not use any environment variables.

=head1 DEPENDENCIES

See the included C<cpanfile>.

=head1 INCOMPATIBILITIES

There are no known incompatibilities with other modules.

=head1 BUGS AND LIMITATIONS

There are no known bugs. Make sure they are reported.

=cut
