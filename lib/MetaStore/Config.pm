package MetaStore::Config;
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
    _log1 $self "init with $file_path !".$self->__conf;
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
