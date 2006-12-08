package MetaStore::Base;
use Data::Dumper;
use Time::Local;
use Template;
use Template::Plugin::Date;
use HTML::WebDAO::Base;
use strict;
use warnings;
use base qw/HTML::WebDAO::Base/;
our $VERSION = '0.01';

sub _init {
    my $self = shift;
    return $self->init(@_);
}

sub init{ 1 };

sub time2mysql {
    my ( $self, $time ) = @_;
    $time = time() unless defined($time);
    my ( $sec, $min, $hour, $day, $month, $year ) = ( localtime($time) )[ 0, 1, 2, 3, 4, 5 ];
    $year  += 1900;
    $month += 1;
    $time = sprintf( '%.4d-%.2d-%.2d %.2d:%.2d:%.2d', $year, $month, $day, $hour, $min, $sec );
    return $time;
}

sub mysql2time {
    my ( $self, $time ) = @_;
    return time() unless $time;
    my ( $year, $month, $day, $hour, $min, $sec ) = $time =~ m/(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)/;
    return '0' unless ( $year + $month + $day + $hour + $min + $sec );
    $year  -= 1900;
    $month -= 1;
    $time = timelocal( $sec, $min, $hour, $day, $month, $year );
    return $time;
}

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
