package MetaStore::Auth::User;

use strict;
use warnings;
use MetaStore::Item;
use Data::Dumper;
our @ISA = qw(MetaStore::Item);

our $VERSION = '0.01';


=pod

=head1 NAME

MetaStore::Auth::User

=head1 SYNOPSIS



=head1 DESCRIPTION

MetaStore::Auth::User

=head1 METHODS

=cut

sub _init {
    my $self = shift;
    return $self->SUPER::_init(@_);
}
sub attr {
    my $self = shift;
    return $self->_attr;
}
1;
__END__

=head1 AUTHOR

Aliaksandr P. Zahatski, <zahatski@gmail.com>

=cut
