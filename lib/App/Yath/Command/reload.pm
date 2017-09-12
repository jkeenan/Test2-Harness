package App::Yath::Command::reload;
use strict;
use warnings;

our $VERSION = '0.001008';

use POSIX ":sys_wait_h";
use Cwd qw/realpath/;
use File::Path qw/remove_tree/;
use Time::HiRes qw/sleep/;

use File::Spec();

use Test2::Harness::Feeder::Run;
use Test2::Harness::Run::Runner::Persist;
use Test2::Harness::Run;
use Test2::Harness::Util::File::JSON;

use App::Yath::Util qw/find_pfile/;
use Test2::Harness::Util qw/open_file/;

use parent 'App::Yath::Command';
use Test2::Harness::Util::HashBase;

sub group { 'persist' }

sub show_bench      { 0 }
sub has_jobs        { 0 }
sub has_runner      { 0 }
sub has_logger      { 0 }
sub has_display     { 0 }
sub manage_runner   { 0 }
sub always_keep_dir { 0 }

sub summary { "Reload the persistent test runner" }
sub cli_args { "" }

sub description {
    return <<"    EOT";
foo bar baz
    EOT
}

sub run {
    my $self = shift;

    my $pfile = find_pfile()
        or die "Could not find " . $self->pfile_name . " in current directory, or any parent directories.\n";

    my $data = Test2::Harness::Util::File::JSON->new(name => $pfile)->read();

    print "\nSending SIGHUP to $data->{pid}\n\n";
    kill('HUP', $data->{pid}) or die "Could not send signal!\n";
    return 0;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

App::Yath::Command::persist

=head1 DESCRIPTION

=head1 SOURCE

The source code repository for Test2-Harness can be found at
F<http://github.com/Test-More/Test2-Harness/>.

=head1 MAINTAINERS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 AUTHORS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 COPYRIGHT

Copyright 2017 Chad Granum E<lt>exodist7@gmail.comE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://dev.perl.org/licenses/>

=cut