package MetaStore::Auth;

use strict;
use warnings;
use Data::Dumper;
use base 'MetaStore::Base';
our $VERSION = '0.01';
__PACKAGE__->attributes qw(  current_user _users);

sub init {
    my $self = shift;
    my %opt  = @_;
    my ( $users, $sess, ) =
      @opt{qw/ users session  /};
    my $sess_id = $sess->get_id;
    $self->_users($users);
    $self->current_user( $users->get_by_sess($sess_id) || $users->get_guest );
    return 1;
}

=head1 is_access



sub is_access {
    my $self     = shift;
    my $mod_name = shift || return undef;
    my $reg      = $self->_conf->{auth_for};
    nnreturn 1 unless $mod_name =~ m/$reg/i;
    my $a_id = $self->current_user->attr->{access_id};
    my $hash = $self->_access_obj->fetch_object($a_id);
    my $res  = exists $hash->{$mod_name};
    _log4 $self "CHECK PERM for module $mod_name for user "
      . $self->current_user
      . " is $res";
    return $res;
}

=cut

=head1 auth_by_login_pass

=cut

sub auth_by_login_pass {
    my $self = shift;
    my %args = @_;
    my ( $login, $pass, $sess_obj ) = @args{qw/  usr pass session/};
    my $user = $self->_users->get_by_log_pass( lg => $login, pw => $pass )
      || return;
    $user->attr->{sess_id} = $sess_obj->get_id;
    return $user;
}

=head1 is_authed

=cut

sub is_authed {
    my $self = shift;
    my $user = shift || $self->current_user;
    return not $user->isa('MetaStore::Auth::UserGuest');
}

=head1 logout

=cut

sub logout {
    my $self = shift;
    my $user = shift || $self->current_user || return;
    $user->attr->{sess_id} = '';
    return 1;
}

sub commit {
    my $self = shift;
    $self->_users->store_changed;
}
1;
__END__

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=cut

