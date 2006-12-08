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

=head1 _get_ids_by_attr

    usage:
        _get_ids_by_attr({
            __class=>'_metastore_user',
            login=>'test'
            })
=cut

sub _get_ids_by_attr {
   my $self = shift;
   my ($attr,%opt) = @_;
   my $dbh        = $self->_dbh;
   my $table_name = $self->_table_name();
   my $where     = join " or ", map { '( tname in (' . $dbh->quote($_) . ') and tval LIKE (' . $dbh->quote( $attr->{$_} ) . ') )' } keys %$attr;
   my $count = scalar keys %$attr;
   my $sql = qq/ 
    select mid 
    from $table_name
    where $where
    group by mid HAVING ( count(*) = $count)/;
    if (my $orderby = $opt{orderby}) {
        $sql = qq/
            select mid, tval from $table_name
            where tname  like ('$orderby') and
            mid in ( $sql ) order by tval
        /;
        $sql .= ' DESC' if $opt{desc};
    }
    if (my $page = $opt{page} and my  $onpage= $opt{onpage} ) {
        $sql .= " limit ".( ($page-1) * $onpage ).",$onpage"
    }
    my $qrt = $self->_query_dbh($sql);
    my %res = ();
    while ( my $rec = $qrt->fetchrow_hashref ) {
        $res{$rec->{mid}}++
    }
    $qrt->finish;
    return [keys %res]
}
