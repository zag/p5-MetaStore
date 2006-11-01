package MetaStore::Mem;
use Objects::Collection;
use Objects::Collection::Base;
use Objects::Collection::Item;
use Data::Dumper;

use strict;
use warnings;

our @ISA = qw(Objects::Collection);
our $VERSION = '0.01';

attributes qw/ _mem_cache /;

sub _init {
    my $self = shift;
    my %args = @_;
    $self->_mem_cache( $args{mem}||{});
    $self->SUPER::_init();
    return 1
}

sub _delete {
    my $self = shift;
    my @ids = map { $_->{id} } @_;
    my $coll = $self->_mem_cache;
    delete  @{$coll}{@ids}
}

sub _create {
    my $self = shift;
    my %args = @_;
    my $coll = $self->_mem_cache;
    my ($max) = sort { $b <=> $a } keys %$coll;
    $coll->{++$max} = \%args;
    return { $max => \%args }
}
sub _fetch {
    my $self = shift;
    my @ids = map { $_->{id} } @_;
    my $coll = $self->_mem_cache;
    my %res;
    for (@ids) {
        $res{$_}=$coll->{$_} if exists $coll->{$_};
    }
    return \%res
}

sub _prepare_record {
    my ( $self, $key, $ref ) = @_;
    return $ref;
}

sub _fetch_all {
    my $self = shift;
    return [ keys %{$self->_mem_cache} ]
}
sub commit {
    my $self = shift;
}

# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

MetaStore - Perl extension for blah blah blah

=head1 SYNOPSIS

  use MetaStore;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for MetaStore, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.


=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Zagatski Alexandr, E<lt>zag@zagE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Zagatski Alexandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
