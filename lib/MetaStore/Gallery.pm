package MetaStore::Gallery;
use Data::Dumper;
use HTML::WebDAO::Base;
use strict;
use Template;
use warnings;
use base qw( MetaStore::DAOEntry );
attributes qw/_template _template_view _template_preview _poll/;

sub set_pars {
    my $self = shift;
    my %args = @_;
    my ( $templ1, $templ2,$templ3 ) = split( /\|/, $args{template});
    _template  $self  $templ1;
    _template_view $self  $templ2;
    _template_preview $self  $templ3;
#    logmsgs $self Dumper(\%args);
}

sub links {
    my $self = shift;
    return $self->SUPER::links(@_)
}
sub add_image {
    my $self = shift;
    my $img = shift || return;
    my $links = $self->links;
    unless ( grep { $_ eq $img->id } @$links ) {
        push @$links, $img->id;
        $self->links(@$links);
    }
}
sub delete {
    my $self = shift;
    my @ids = map {$_->id} grep { $_ } @{$self->images};
    $self->_meta_props->delete_objects(@ids);
    $self->SUPER::delete(@_);
}
sub images {
    my $self = shift;
    my $objs = $self->_meta_props;
    my @linked = @{ $self->links };
    my @images = @{$objs->fetch_objects(@linked)}{@linked};
    return \@images
}
sub fetch {
    my $self = shift;
    return $self->preview unless $self->_poll;
#    LOG $self "fetch for ".$self->guid . Dumper([map {[caller($_)]}(1..5)]);
    my $str = $self->meta.join "\n"=>map {
        my $url_view = $self->url_method("view_image",id=>$_->_obj_name);
        qq!<div class="shadow"><a href="$url_view"><img src="@{[$_->url_preview]}"/></a></div>!;
        } @{$self->images};
    return '<div class="post-footer">&nbsp;'.$str.'</div>';
}
sub preview {
    my $self = shift;
    my $template = $self->_template_preview ||return;
    my @all = @{$self->images};
    my $img_obj = shift @all;
    my $image_url = $img_obj->url_preview;
    my $predefined = { 
        owner=>$self,
        attr=>$self->_attr,
        image_url=>$image_url,
        images=>[$img_obj,@all]
        };
    return $self->parse_TT($template, $predefined);
    
}
sub view {
    my $self = shift;
#    return $self->meta;
    my $template = $self->_template_view ||return;
    my @all = @{$self->images};
    my $img_obj = shift @all;
    my $image_url = $img_obj->url_preview;
    my $predefined = { 
        owner=>$self,
        attr=>$self->_attr,
        image_url=>$image_url,
        images=>[$img_obj,@all]
        };
    $self->_poll($self->parse_TT($template, $predefined));
    return $self
}
sub view_image {
    my $self = shift;
    my $template = $self->_template ||return;
    my %args = @_;
    my $id =$args{id};
    my $img_obj = $self->_meta_props->fetch_object($id);
    return $self unless $img_obj;
    my $image_url = $img_obj->url_view;
    my @all = @{$self->images};
    my $next;
    while (my $img = shift @all) {
        next if $img->_obj_name ne $id;
        $next = shift @all;
        last;
    }
#    $next ||=  $img_obj;
    my $next_url= $next
                ? $self->url_method("view_image",id=>$next->id)
                : "#"
                ;
    my $predefined = { 
        owner=>$self,
        next_url=>$next_url,
        image_url=>$image_url,
        next_image_url=>$next ? $next->url_view :"#"
        };
    return $self->parse_TT($template, $predefined);
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
