package MetaStore::Mem;

=head1 NAME

MetaStore::Mem - class for collections of data, stored in memory.

=head1 SYNOPSIS

    use MetaStore::Mem;
    my $meta = new MetaStore::Mem:: mem=>$hash1;

=head1 DESCRIPTION

Class for collections of data, stored in memory.

=head1 METHODS

=cut

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

1;
__END__

=head1 SEE ALSO

MetaStore, Objects::Collection,README

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005-2006 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

