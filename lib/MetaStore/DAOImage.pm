package MetaStore::DAOImage;
use HTML::WebDAO::Base;
use MetaStore;
use MetaStore::DAOEntry;
use Data::Dumper;
use File::Path;
use strict;
use warnings;
use base qw(MetaStore::DAOEntry);

sub _call_method {
    my $self = shift;
    my ( $method, @path ) = @{ shift @_ };
    return $self->SUPER::_call_method( [$method], @_ );
}

sub set_attr {
    my $self = shift;
    my %args = @_;
    my $attr = $self->_attr;
    my ( $file, $preview ) = map {
        my @keys = ( $_, $_ . "_data" );
        my $res = [ @args{@keys} ];
        delete @args{@keys};
        $res
    } qw/ meta preview/;
    $args{meta} = join "|" => $file->[0], $preview->[0];
    my $id = $self->_obj_name;
    mkpath("/tmp/Meta/$id/");
    foreach my $ref ( $file, $preview ) {
        logmsgs $self '$id' . $id . "filepath /tmp/Meta/$id/" . $ref->[0];
#        my $file_path  = $self->getEngine->_conf->
        open FH, ">/tmp/Meta/$id/" . $ref->[0] or die $!;
        { local $/; $/ = undef; print FH $ref->[1] };
        close FH;
    }
    return $self->SUPER::set_attr(%args);
}

sub set_image {
    my $self = shift;
    my ( $prop_name, $image_name, $raw ) = @_;
    my $store = $self->_store;
    my $attr  = $self->_attr;
    $attr->{$prop_name} = $image_name;
    $store->putRaw( $image_name, $raw );
}

sub test {
    my $self = shift;
    my %arg  = @_;

    #    $self->Height($arg{Height});
    #    $self->Mode($arg{Mode});
    #    return $self;
    return "<h1>WORK !!!</h1><pre>" . Dumper( \%arg );
}

sub view {
    my $self = shift;
    my $res  = $self->_store->getRaw( $self->_attr->{_image} );
    my $filepath = $self->_store->get_path_to_key ( $self->_attr->{_image} );
#    return {header=>"Content-Type: image/jpeg\nContent-Length: $size\nETag: \"$preview\"\nLast-Modified: Sun, 25 Sep 2005 03:34:32 GMT\n\n",data=>$res}
    return {
        header => "Content-Type: image/jpeg\nLast-Modified: Sun, 25 Sep 2005 03:34:32 GMT\n\n",
        headers => {"Last-Modified",'Sun, 25 Sep 2005 03:34:32 GMT'},
        data   => $res,
        file    => $filepath,
        type   => 'image/jpeg'
      }

}

sub view_preview {
    my $self = shift;
    my $res  = $self->_store->getRaw( $self->_attr->{_image_preview} );
    my $filepath = $self->_store->get_path_to_key ( $self->_attr->{_image_preview} );
    return {
        header => "Content-Type: image/jpeg\nLast-Modified: Sun, 25 Sep 2005 03:34:32 GMT\n\n",
        headers => {"Last-Modified",'Sun, 25 Sep 2005 03:34:32 GMT'},
        data   => $res,
        file    => $filepath,
        type   => 'image/jpeg'
      }

      #    return {header=>"Content-Type: image/jpeg\n\n",data=>$res}
}

sub url_preview {
    my $self = shift;
    my ( $view, $preview ) = @{ $self->_attr }{qw/ _image _image_preview/};
    $self->url_method("view_preview/$preview");
}

sub url_view {
    my $self = shift;
    my ( $view, $preview ) = @{ $self->_attr }{qw/ _image _image_preview/};
    $self->url_method("view/$view");
}

sub fetch {
    my $self = shift;
    my ( $view, $preview ) = @{ $self->_attr }{qw/ _image _image_preview/};
    my $url_preview = $self->url_method("view_preview/$preview");
    my $url_view    = $self->url_method("view/$view");
    return qq!<div class="shadow"><a href="$url_view"><img src="$url_preview"/></a></div>!;
}

sub dump {
    my $self   = shift;
    my $stream = shift;
    my $_store = $self->_store;
    foreach my $key ( @{ $_store->get_keys } ) {
        $stream->putRaw( $key, $_store->getRaw_fh($key) );
    }
    return $self->SUPER::dump($stream);
}

sub restore {
    my ( $self, $store, $restore ) = @_;
    $self->SUPER::restore( $store, $restore );
    my $_store = $self->_store;
    foreach my $key ( @{ $store->get_keys } ) {
        $_store->putRaw( $key, $store->getRaw_fh($key) );
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
