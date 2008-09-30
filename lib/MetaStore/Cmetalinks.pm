package  MetaStore::Cmetalinks;

=head1 NAME

MetaStore::Cmetalinks - class for collections of data, stored in database.

=head1 SYNOPSIS

    use MetaStore::Cmetalinks;
    my $links = new MetaStore::Cmetalinks::
      dbh   => $dbh,
      table => 'metalinks',
      field => 'lsrc';

=head1 DESCRIPTION

Class for collections of data, stored in database.

=head1 METHODS

=cut


use strict;
use warnings;
use Data::Dumper;
use Objects::Collection::AutoSQLnotUnique;
use Objects::Collection::AutoSQL;
our @ISA = qw(Objects::Collection::AutoSQLnotUnique);
sub after_load {
    my $self = shift;
    my %attr = ();
    foreach my $rec (@_) {
        my ($name,$val, $type ) = @{$rec}{qw/ lid ldst lex/};
            $attr{$type}{$name} = $val
    }
    while ( my ($type, $list) = each %attr) {
        $attr{$type} = [ map { $list->{$_} } sort { $a <=> $b } keys %$list ]
    }
    return \%attr;
}

sub before_save {
    my $self = shift;
    my $attr = shift;
    my @res;
    while ( my ($type, $array ) = each %$attr) {
    $array ||= [];
    my $i;
    foreach my $rec (@$array) {
            $i++;
            push @res,{ ldst=>$rec , lid=>$i, lex => $type } 
    }
    }
    return \@res
}

sub _prepare_record {
    my $self = shift;
    my ( $key, $ref ) = @_;
    return $self->Objects::Collection::AutoSQL::_prepare_record($key,$ref);
}
1;
__END__

=head1 SEE ALSO

MetaStore, Objects::Collection::AutoSQLnotUnique,README

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2008 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

