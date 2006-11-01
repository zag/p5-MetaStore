package MetaStore::Auth;
use Data::Dumper;
use File::Path;
use strict;
use warnings;
use HTML::WebDAO::Base;
use base qw(HTML::WebDAO::Component);
attributes qw( __metadb );
sub init {
    my $self = shift;
#    my %args = map {%{$_}} @_;
    __metadb $self shift (@_);
}

sub form {
    my $self= shift;
    my @form = $self->PrepareForm(
     "<strong>name:</strong>",
     {type=>"input",name=>'usr',value=>"",size=>30},
     "<br/><strong>pass:</strong>",
     '<input type="password" name="pw"/>',
     '<input value="Set" type="submit" />'
        );
    return $self->CompileForm({data=>\@form, sendto=>$self->url_method('login')});

}
sub suss {
    return $_[0];
}
sub get_base {
    my $self = shift;
    my %args = @_;
    my ($login,$pass) =  @args{qw/usr pw/};
#    return "TEST";
    return $self->GetURL();
}
sub login {
    my $self =shift;
    my %args = @_;
    my ($login,$pass) =  @args{qw/usr pw/};
    my $sess;
    $self->SendEvent("_sess_servise",{
		funct 	=> 'getsess',
		par	=> {},
		result	=> \$sess
			});

    my $uid = $sess->get_id;
    my $meta_obj = $self->call_path($self->__metadb);
    my ($user) = 
#          map { $_->sess_id eq "$uid"}
          grep { $_->_attr->{_login} eq $login and $_->_attr->{_pass} eq $pass }
          values %{ $meta_obj->fetch_objects({
                 tval=>'_metastore_user',
                 tname=>'__class'}) };
    _log1 $self "Not found user for $uid \$login,\$pass $login,$pass" unless $user;
    if ($user)  {
        _log4 $self "set for user :".$user->_attr->{sess_id}."->$uid";
        $user->_attr->{sess_id}=$uid;
        return $self->GetURL() if $args{get_base};
    }
    my $redirect_url = $self->url_method("suss");
    return "fail" if $args{get_base};
#    return $self->GetURL() if $args{get_base};
    return {header=>"Location: $redirect_url\n\n",data=>'refersh'};
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
