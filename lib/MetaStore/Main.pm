package MetaStore::Main;
use HTML::WebDAO::Base;
use Data::Dumper;
use strict;
use warnings;
use base qw(HTML::WebDAO::Component);
attributes qw/ _pull _obj_path/;
sub init {
    my $self = shift;
    $self->_pull([]);
    _obj_path $self  shift;
    return $self->SUPER::init(@_);
}

sub obj_coll {
    my $self = shift;
    return $self->call_path($self->_obj_path);
}


sub all {
    my $self = shift;
    $self->_pull([ values %{ $self->obj_coll->fetch_objects({tval=>['_metastore_gallery','_metastore_entry']})} ]);
}

sub gallery {
    my $self = shift;
    $self->_pull([ values %{ $self->obj_coll->fetch_objects({tval=>'_metastore_gallery'})} ]);
}
sub blogs {
    my $self = shift;
    $self->_pull([ values %{ $self->obj_coll->fetch_objects({tval=>'_metastore_entry'})} ]);
}

sub fetch {
    my $self = shift;
    $self->blogs unless scalar @{$self->_pull};
    return join "\n"=>map { $_->fetch }
         
        sort {$b->_attr->{time_publish} <=> $a->_attr->{time_publish}}
        grep { $_->_attr->{time_publish} < time() }
        grep { $_->_attr->{ is_public } }
        @{$self->_pull}
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
