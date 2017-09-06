package Test2::Harness::Util::TestFile;
use strict;
use warnings;

our $VERSION = '0.001006';

use Carp qw/croak/;

use File::Spec();

use Test2::Harness::Util qw/open_file/;

use Test2::Harness::Util::HashBase qw{
    -file -_scanned -_headers -_shbang
};

sub init {
    my $self = shift;

    my $file = $self->file;

    # We want absolute path
    $file = File::Spec->rel2abs($file);
    $self->{+FILE} = $file;

    croak "Invalid test file '$file'" unless -f $file;
}

my %DEFAULTS = (
    timeout   => 1,
    fork      => 1,
    preload   => 1,
    stream    => 1,
    isolation => 0,
);

sub check_feature {
    my $self = shift;
    my ($feature, $default) = @_;

    $default = $DEFAULTS{$feature} unless defined $default;

    return $default unless defined $self->headers->{features}->{$feature};
    return 1 if $self->headers->{features}->{$feature};
    return 0;
}

sub check_category {
    my $self = shift;
    $self->_scan unless $self->{+_SCANNED};
    return $self->{+_HEADERS}->{category};
}

sub headers {
    my $self = shift;
    $self->_scan unless $self->{+_SCANNED};
    return {} unless $self->{+_HEADERS};
    return {%{$self->{+_HEADERS}}};
}

sub shbang {
    my $self = shift;
    $self->_scan unless $self->{+_SCANNED};
    return {} unless $self->{+_SHBANG};
    return {%{$self->{+_SHBANG}}};
}

sub switches {
    my $self = shift;

    my $shbang   = $self->shbang       or return [];
    my $switches = $shbang->{switches} or return [];

    return $switches;
}

sub _scan {
    my $self = shift;

    return if $self->{+_SCANNED}++;

    my $fh = open_file($self->{+FILE});

    my %headers;
    for (my $ln = 1; my $line = <$fh>; $ln++) {
        chomp($line);
        next if $line =~ m/^\s*$/;

        if ($ln == 1 && $line =~ m/^#!/) {
            my $shbang = $self->_parse_shbang($line);
            if ($shbang) {
                $self->{+_SHBANG} = $shbang;
                next;
            }
        }

        next if $line =~ m/^(use|require|BEGIN)/;
        last unless $line =~ m/^\s*#\s*HARNESS-(.+)$/;

        my ($dir, @args) = split /-/, lc($1);
        if ($dir eq 'no') {
            my ($feature) = @args;
            $headers{features}->{$feature} = 0;
        }
        elsif ($dir eq 'yes' || $dir eq 'use') {
            my ($feature) = @args;
            $headers{features}->{$feature} = 1;
        }
        elsif ($dir eq 'category' || $dir eq 'cat') {
            my ($name) = @args;
            $headers{category} = $name;
        }
        else {
            warn "Unknown harness directive '$dir' at $self->{+FILE} line $ln.\n";
        }
    }

    $self->{+_HEADERS} = \%headers;
}

sub _parse_shbang {
    my $self = shift;
    my $line = shift;

    return {} if !defined $line;

    my %shbang;

    # NOTE: Test this, the dashes should be included with the switches
    my $shbang_re = qr{
        ^
          \#!.*\bperl.*?        # the perl path
          (?: \s (-.+) )?       # the switches, maybe
          \s*
        $
    }xi;

    if ($line =~ $shbang_re) {
        my @switches = grep { m/\S/ } split /\s+/, $1 if defined $1;
        $shbang{switches} = \@switches;
        $shbang{line}     = $line;
    }

    return \%shbang;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Test2::Harness::Job::TestFile - Logic to scan a test file.

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