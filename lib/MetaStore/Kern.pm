package MetaStore::Kern;

=head1 NAME

MetaStore::Kern - Class of kernel object.

=head1 SYNOPSIS

    use MetaStore::Kern;
    use base qw/ MetaStore::Kern /;

=head1 DESCRIPTION

Class of kernel object.

=head1 METHODS

=cut

use HTML::WebDAO::Engine;
use MetaStore::Config;
use Data::Dumper;
use Carp;
use strict;
use warnings;
use base qw(HTML::WebDAO::Engine);
__PACKAGE__->attributes qw/_conf __template_obj__/;

=head2 init

Initialize object

=cut

sub init {
    my $self = shift;
    my (%opt) = @_;
    $self->RegEvent( $self, "_sess_ended", sub { $self->commit } );
    return $self->SUPER::init(@_);
}

sub config {
    my $self = shift;
    return $self->_conf;
}

sub auth {
    my $self = shift;
    _log1 $self "method auth not bared !";
    croak "$self doesn't define an auth method";
}

sub create_object {
    my $self = shift;
    return $_[0]->_createObj(@_);
}

sub _createObj {
    my $self     = shift;
    my $name_mod = $_[1];
    return unless $self->auth->is_access($name_mod);
    return $self->SUPER::_createObj(@_);
}

sub parse_template {
    my $self = shift;
    my ( $template, $predefined ,$template_config) = @_;
    $predefined->{self}   = $self unless exists $predefined->{self};
    $predefined->{system} = $self unless exists $predefined->{system};
    $template_config ||= {};
#    my $template_obj = $self->__template_obj__ || new Template
    my $template_obj = new Template
      INTERPOLATE => 1,
      EVAL_PERL   => 0,
      ABSOLUTE    => 1,
      RELATIVE    => 1,
      %{$template_config},
      VARIABLES   => $predefined,
      or do { $self->_log1( "TTK Error:", [$Template::ERROR] ); return };
    $self->__template_obj__($template_obj);
    $template_obj->context->stash->update({});
    $template_obj->context->reset;
    my $res;
    $template_obj->process( $template, $predefined, \$res ) or do {
        my $error = $template_obj->error();
        $self->_log1( "TTK Error:" . $error . "; file: $template");
        return;
    };
    return $res;
}

sub commit {
    my $self = shift;
}
sub _destroy {
    my $self = shift;
    $self->_conf(undef);
    $self->SUPER::_destroy(@_)
}
1;
__END__

=head1 SEE ALSO

Metasore, README

=head1 AUTHOR

Zahatski Aliaksandr, <zag@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005-2006 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

