package MetaStore::Kern;
use HTML::WebDAO::Engine;
use MetaStore::Config;
use Data::Dumper;
use strict;
use warnings;
use base qw(HTML::WebDAO::Engine);
__PACKAGE__->attributes qw/_conf/;

sub init {
    my $self = shift;
    my ( %opt ) = @_;
    $self->RegEvent( $self,"_sess_ended", \&commit );
    return $self->SUPER::init(@_);
}
sub config {
    my $self = shift;
    return $self->_conf
}
sub commit {
    my $self = shift;
}
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
