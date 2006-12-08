package MetaStore::Item;
use MetaStore::Base;
use Data::Dumper;
use strict;
use warnings;

our @ISA = qw( MetaStore::Base );
our $VERSION = '0.01';
__PACKAGE__->attributes qw/ __init_rec  _attr/;

sub _init {
    my $self = shift;
    my $ref = shift;
    $ref->{id} or die "Need id !".__PACKAGE__;
    _attr $self $ref->{attr};
    __init_rec $self $ref;
    return $self->SUPER::_init(@_);
}

#method fo init
sub _create {
    my $self = shift;
}
sub _changed {
   my $self = shift;
    if ( my $ar = tied %{ $self->_attr } ) {
        return $ar->_changed;
    }
    return 0;
}

sub _get_attr {
    my $self = shift;
    return $self->_attr;
}

sub id {
    my $self = shift;
    return $self->__init_rec->{id};
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
