package MetaStore::MemnotUnique;
use Objects::Collection;
use Objects::Collection::Base;
use Objects::Collection::Item;
use Data::Dumper;
use MetaStore::Mem;

use strict;
use warnings;

our @ISA = qw(MetaStore::Mem);
our $VERSION = '0.01';

sub _create {
    my $self = shift;
    my %args = @_;
    return {} unless %args;
    my $coll_ref = $self->_obj_cache();
    my $coll = $self->_mem_cache;
    my %created;
    while ( my ($id, $attr_hash_ref) = each %args ) {
        next if exists $coll_ref->{$id};
        $coll->{$id} = $attr_hash_ref;
        my $res = $self->_prepare_record($id,$attr_hash_ref);
        $coll_ref->{$id} = $res;
        $created{$id}++
    }
    return \%created
}

sub _fetch {
    my $self = shift;
    my $coll = $self->_mem_cache;
    my @extra;
    my @ids;
    foreach my $ref (@_) {
     if ( exists $ref->{id} ) {
       push @ids, $ref->{id}
     }
     else {
       #now do extra convert to id
       #push @extra, $ref 
       if ( my $value = $ref->{tval}) {
          while ( my ($id,$record) = each %$coll ){
            my %values;
            @values{ values %{$record} } = ();
            push @ids, $id if exists $values{$value}
          }
       }
     }
    }
    print  Dumper(\@extra) if @extra;
    my %res;
    for (@ids) {
        next unless $_;
        $coll->{$_} = {} unless exists $coll->{$_};
        $res{$_}=$coll->{$_}
    }
    return \%res
}

sub _prepare_record {
    my ( $self, $key, $ref ) = @_;
    return $ref;
}

sub _delete {
    my $self = shift;
    my @ids = map { $_->{id} } @_;
    my $coll = $self->_mem_cache;
    delete  @{$coll}{@ids}
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
