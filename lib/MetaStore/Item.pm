package MetaStore::Item;
use Objects::Collection::Base;
use Objects::Collection::Item;
use Data::Dumper;
use strict;
use warnings;

our @ISA = qw(Objects::Collection::Item);
our $VERSION = '0.01';
attributes qw/_id _meta_ref /;
sub init {
    my $self = shift;
    my $id  = shift;
    _id $self $id;
    my $meta_ref = shift;
    _meta_ref $self  $meta_ref;
}

sub id {
    my $self = shift;
    return $self->_id;
}

sub meta {
    my $self = shift;
    $self->_meta_ref->{mdata}=$_[0] if $_[0];
    return $self->_meta_ref->{mdata}
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
