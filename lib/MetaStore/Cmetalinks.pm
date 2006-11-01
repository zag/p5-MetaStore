package  MetaStore::Cmetalinks;
use strict;
use warnings;
use Data::Dumper;
use Objects::Collection::AutoSQLnotUnique;
use Objects::Collection::AutoSQL;
our @ISA = qw(Objects::Collection::AutoSQLnotUnique);
sub after_load {
    my $self = shift;
    my %attr;
    foreach my $rec (@_) {
        my ($name,$val) = @{$rec}{qw/ lid ldst /};
            $attr{$name} = $val
    }
    return {list=>[ map { $attr{$_} } sort { $a <=> $b } keys %attr ]}
}
sub before_save {
    my $self = shift;
    my $attr = shift;
    my @res;
    my $array = $attr->{list}||[];
    my $i;
    foreach my $rec (@$array) {
            $i++;
            push @res,{ ldst=>$rec , lid=>$i } 
    }
    return \@res
}

sub _prepare_record {
#    my ( $self, $key, $ref ) = @_;
    my $self = shift;
    my ( $key, $ref ) = @_;
    unless (scalar keys %$ref) {
        $ref = {list=>[]}
    }
    return $self->Objects::Collection::AutoSQL::_prepare_record($key,$ref);
}

