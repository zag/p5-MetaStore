package  MetaStore::Cmetatags;
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
        my ($name,$val) = @{$rec}{qw/tname tval/};
        unless ( exists $attr{$name}) {
            $attr{$name} = $val
        } else {
            if ( ref($attr{$name}) ) {
                push @{$attr{$name}},$val
            }
            else {
                $attr{$name} = [ $attr{$name} , $val]
            }
        }
    }
    return \%attr
}
sub before_save {
    my $self = shift;
    my $attr = shift;
    my @res;
    while ( my ($name,$val) = each %$attr ) {
            push @res,map { { tname=>$name, tval=>$_ } } ref($val) ? @$val : ($val)
    }
    return \@res
}

sub _prepare_record {
    my $self = shift;
    return $self->Objects::Collection::AutoSQL::_prepare_record(@_);
}

