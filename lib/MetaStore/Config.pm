package MetaStore::Config;

=head1 NAME

MetaStore::Config - Configuration file class.

=head1 SYNOPSIS

    use MetaStore::Config;
    my $conf = new MetaStore::Config:: ( $opt{config} );

=head1 DESCRIPTION

Configuration file class 

=head1 METHODS

=cut

use strict;
use warnings;
use HTML::WebDAO::Base;
use base 'HTML::WebDAO::Base';
use Config::Simple;
__PACKAGE__->attributes qw/ __conf _path/ ;
sub _init {
    my $self = shift;
    my $file_path = shift;
    $self->__conf(new Config::Simple:: $file_path);
    $self->_path(  $file_path );
    return 1;
}

sub get_full_path {
    my $self = shift;
    my @req_path = @_;
    my $req_path = join "/",@req_path;
    return $req_path if $req_path =~ /^\//;
    my @ini_path  = split( "/",$self->_path);
    pop @ini_path;
    my $path = join "/"=>@ini_path,$req_path;
    _log1 $self "File $path not exists" unless -e $path;
    return $path;
}

sub AUTOLOAD { 
    my $self = shift;
    return if $MetaStore::Config::AUTOLOAD =~ /::DESTROY$/;
    ( my $auto_sub ) = $MetaStore::Config::AUTOLOAD =~ /.*::(.*)/;
      $self->__conf->param( -block => $auto_sub )
}
1;
__END__

=head1 SEE ALSO

MetaStore, Config::Simple,README

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

