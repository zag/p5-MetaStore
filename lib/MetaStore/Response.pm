package MetaStore::Response;

#$Id$

use Data::Dumper;
use HTML::WebDAO::Response;
use base qw( HTML::WebDAO::Response );
__PACKAGE__->attributes qw/  __json __html __xml /;
use strict;

=head1 NAME

MetaStore::Response - Response class

=head1 SYNOPSIS

  use MetaStore::Response;

=head1 DESCRIPTION

Class for set response headers. Add functionality to return context.

=head1 METHODS

=cut

=head2 json 

=cut

sub json : lvalue {
    my $self = shift;
    $self->{__json};
}

sub html : lvalue {
    my $self = shift;
    $self->{__html};
}

sub xml : lvalue {
    my $self = shift;
    $self->{__xml};
}

sub js : lvalue {
    my $self = shift;
    $self->{__jscript};
}

sub _destroy {
    my $self = shift;
    $self->{__js} = undef;
    $self->{__json} = undef;
    $self->{__html} = undef;
    $self->{__xml} = undef;
    $self->auto( [] );
}
1;
__END__

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=cut

