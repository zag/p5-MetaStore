package MetaStore::Config;
use strict;
use warnings;
use HTML::WebDAO::Base;
use base 'HTML::WebDAO::Base';
use Config::Simple;
__PACKAGE__->attributes qw/ __conf/ ;
sub init {
    my $self = shift;
    my $file_path = shift;
    __conf $self new Config::Simple:: $file_path;
    _log1 $self "init with $file_path !";
    return 1;
}

sub AUTOLOAD { 
    my $self = shift;
    return if $MetaStore::Config::AUTOLOAD =~ /::DESTROY$/;
    ( my $auto_sub ) = $MetaStore::Config::AUTOLOAD =~ /.*::(.*)/;
      $self->__conf->param( -block => $auto_sub )
}
1;
