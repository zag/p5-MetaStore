package MetaStore::Perm;
use Data::Dumper;
use File::Path;
use strict;
use warnings;
use HTML::WebDAO::Base;
use base qw(HTML::WebDAO::Element);
attributes qw/ __init /;
sub init {
    my $self = shift;
#    my %args = map {%{$_}} @_;
    my %arg = @_;
    my %prefs;
    while ( my ($key,$val) = each %arg) {
        my ($sub_key, $ord) = split /\./,$key;
       if ( defined $ord ) {
            $prefs{$sub_key}->[$ord] = $val
       } else {
        $prefs{$key} =$val;
       }
    }
    $self->__init(\%prefs);
}

sub __get_self_refs {
    my $self = shift;
    #get user
    my %args = %{$self->__init};
    my $uid = $self->getEngine->_session->get_id;
    my $meta_obj = $self->call_path($args{metadb});
    return unless $meta_obj;
#    _log4 $self "Begin check perm !";
    my ($user) = 
            grep { $_->sess_id eq "$uid"}
#            map { _log4 $self "check ".Dumper($_->_attr) ;$_}
            values %{ $meta_obj->fetch_objects({
                    tval=>'_metastore_user',
                    tname=>'__class'}) };
#    _log4 $self "Prem fail for $uid" unless $user;
    return $user ? $args{auth} : $args{noauth};
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
