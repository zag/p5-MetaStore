package MetaStore::StoreDir;
use IO::File;
use File::Path;
use Data::Dumper;
use warnings;
use Encode;
use Carp;
use strict;
my $attrs={ _dir=>undef};
### install get/set accessors for this object.
for my $key ( keys %$attrs ) {
    no strict 'refs';
    *{__PACKAGE__."::$key"} = sub {
        my $self = shift;
        $self->{$key} = $_[0] if @_;
        return $self->{$key};
    }
}

sub new {
    my $class = shift;
    my $obj;
    if (ref $class) {
        $obj = $class;
        $class = ref $obj;
    }
    my $self = bless ({},$class);
    if (@_) {
      my $dir = shift;
      if ( $obj ) {
        $dir =~ s%^/%%;
        $dir = $obj->_dir.$dir;
      }
      $dir .="/" unless $dir =~ m%/$%;
      $self->_dir($dir)
    } else {
        carp "need path to dir";
        return 
    }
    return $self
}

sub _store_data {
    my ( $self, $mode, $name, $val ) = @_;
    return unless defined $val;
    my $file_name = $self->_get_path.$name;
    my $out = new IO::File:: "> $file_name" or die $!;
    local $/; $/=undef;
    if ( ref $val ) {
       if ( UNIVERSAL::isa( $val, 'IO::Handle') or ( ref $val  eq 'GLOB') or UNIVERSAL::isa($val, 'Tie::Handle') ) {
        $out->print(<$val>);
        $val->close;
        } else {
             $out->print( ( $mode =~ /utf8/ ) ? $self->_utfx2utf($$val) : $$val );
    }
    } else {
        $out->print( ( $mode =~ /utf8/ ) ? $self->_utfx2utf($val) : $val );
#         $val;
    }
    $out->close or die $!;

}
sub _utfx2utf {
  my ( $self, $str ) = @_;
  $str = encode( 'utf8', $str ) if utf8::is_utf8($str);
  return $str;
}

sub _utf2utfx {
  my ( $self, $str ) = @_;
  $str = decode( 'utf8', $str ) unless utf8::is_utf8($str);
  return $str;
}
sub _get_path {
    my $self = shift;
    my $key = shift;
    my $dir  = $self->_dir;
    mkpath( $dir, 0 ) unless -e $dir;
    return $dir
}

sub putText {
   my $self = shift;
   return $self->_store_data(">:utf8",@_)
}

sub putRaw {
   my $self = shift;
   return $self->_store_data(">",@_)
}
sub getRaw_fh {
    my $self = shift;
    my $key = shift;
    my $fh = new IO::File:: "< ".$self->_dir.$key or return;
    return $fh
}

sub getRaw {
    my $self = shift;
    if ( my $fd = $self->getRaw_fh(@_) ) {
    my $data;
    {
     local $/; undef $/;
     $data = <$fd>;
    }
    $fd->close;
    return $data
    } else { return}
}

sub getText {
    my $self = shift;
    return $self->_utf2utfx($self->getRaw(@_))
}
sub getText_fh {
    my $self = shift;
    return $self->getRaw_fh(@_)
}
sub get_path_to_key {
    my $self = shift;
    my $key = shift;
    my $dir = $self->_dir;
    return $dir.$key
}
sub get_keys {
    my $self = shift;
    my $dir = $self->_dir;
    return [] unless -e $dir;
    opendir DIR, $dir or die $!;
    my @keys;
    while ( my $key = readdir DIR ) {
        next if $key =~/^\.\.?$/ or -d "$dir/$key";
        push @keys,$key
    }
    return \@keys
}
sub clean {
    my $self = shift;
    my $dir = $self->_dir;
    rmtree($dir,0);
}
1;
