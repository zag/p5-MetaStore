package MetaStore::Image;
use Objects::Collection::Base;
use Objects::Collection::Item;
use Data::Dumper;
use File::Path;

use strict;
use warnings;
attributes qw/ _tmp_path /;
our @ISA = qw(MetaStore::BlogItem);
our $VERSION = '0.01';
sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    my %arg = @_;
    $self->_attr->{title} ||= '';
    $self->_attr->{hiden} ||= '0';
    $self->_tmp_path('/tmp/images/'.$self->id.'/');
#    $self->_attr->{store_path};
    return 1;
}
sub meta {
   my $self = shift;
   my $args = shift;
   if ( $args ) {
    my $path = $self->_tmp_path;
    unless ( -d $path ) {
                mkpath($path);
         }
    open FH,">${path}data";
    { local $/; $/=undef;
    print FH $args->{image}
    }
    close FH;
   } else {
    return <>
   }
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
