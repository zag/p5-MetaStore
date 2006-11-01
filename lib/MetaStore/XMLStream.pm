package MetaStore::XMLStream;
use XML::Parser;
use XML::Writer;
use IO::File;
use Data::Dumper;
use warnings;
use Carp;
use Encode;
use strict;
my $attrs={ _file=>undef, _file_handle=>undef,_writer=>undef, _events=>{}, _need_close=>undef};
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
    $class = ref $class if ref $class;
    my $self = bless ({},$class);
    if (@_) {
      my $file = shift;
      if (ref $file and ( UNIVERSAL::isa($file, 'IO::Handle') or (ref $file) eq 'GLOB') or UNIVERSAL::isa($file, 'Tie::Handle') )  {
        $self->_file_handle($file);
      } else {
        $self->_file($file)
      }
    } else {
        carp "need filename or filehandle";
        return 
    }
    return $self
}
sub _get_handle {
    my $self = shift;
    my $mode = shift;
    unless ( $self->_file_handle ) {
        $self->_file_handle(new IO::File:: ( $mode ? ">" : "<").$self->_file );
        $self->_need_close(1);#close FH when close
    }
    return  $self->_file_handle
}

sub _get_writer {
    my $self = shift;
    unless ($self->_writer) {
        my $fh = $self->_get_handle(1);
        my $writer = new XML::Writer:: 
            OUTPUT      =>  $fh,
            DATA_MODE   =>  'true',
            DATA_INDENT =>  2;
        $writer->xmlDecl("UTF-8");
        $self->_writer($writer)

    }
    return $self->_writer
}

sub startTag {
    my $self = shift;
    my $writer = $self->_get_writer;
    return $writer->startTag(@_)
}
sub closeTag {
    my $self = shift;
    my $writer = $self->_get_writer;
    return $writer->endTag(@_)
}
sub __ref2xml {
    my $self = shift;
    my $writer = shift;
    my $ref = shift;
    return unless $ref;
    my $type = 'hashref';
    my $res_as_hash = $ref;
    if ( ref $ref  eq 'ARRAY')  {
        $res_as_hash={};
        my $key = 0;
        foreach my $val (@$ref) {
            $res_as_hash->{ $key++ } = $val
        }
        $type = 'arrayref';
    }
    $writer->startTag('value',type=>$type);
    while ( my ($key,$val) = each %$res_as_hash ) {
            $writer->startTag('key',name=>$key);
                if ( ref($val)) {
                  $self->__ref2xml($writer,$val)
                 } else {
                  $writer->characters( $self->_utfx2utf($val) );
                 }
            $writer->endTag('key');
        }
    $writer->endTag('value');
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

sub write {
    my $self = shift;
    my $ref = shift or return;
    my $writer = $self->_get_writer;
    return $self->__ref2xml($writer,$ref);
}
sub _xml2hash_handler {
    my $self = shift;
    my ( $struct, $data,$elem,%attr ) = @_;
    my ($state,$shared) = @{$struct}{'state','shared'};
    my $tag_stack = $shared->{tag_stack} || [];
    $shared->{tag_stack}=$tag_stack;
    for ($state) {

    /1/ && do {
            my $new =  { name=>$elem,'attr'=>\%attr};
            push @$tag_stack,$new ;
            if ( $elem eq 'value' ) {
                $new->{type} = $attr{type};
                for ( $new->{type} ) {
                    /hashref/ && do { $new->{value} = {} }
                              ||
                    /arrayref/ && do { $new->{value} = [] }
                }
            }
            }
        ||
    /2/ && do {
            if ( my $current = pop @{$tag_stack} ) {
                push @{$tag_stack},$current;
                if ( $current->{name} eq 'key' ) {
                      unless ( ref $current->{value} ) {
                      $current->{value} .= $elem;
                      return; #clear return value
                      }
                 }
                    
             }
                
            }
        ||
    /3/ && do {
            if ( my $current = pop @{$tag_stack} ) {
                    my $parent = pop @{$tag_stack};
                    die "Stack error ".Dumper() unless $current->{name} eq $elem;
                if ( $elem eq 'key') {
                    push @{$tag_stack},$parent;
                    my $ref_val;
                    for ( $parent->{type} ) {
                       /hashref/ && do {
                                $parent->{value} ||={};
                                $parent->{value}->{$current->{attr}->{name}} = $current->{value}
                            }
                                ||
                        /arrayref/ && do {
                                $parent->{value} ||=[];
                                ${$parent->{value}}[$current->{attr}->{name}] = $current->{value}
                                    }
                    }

                } 
                elsif  ($elem eq 'value') {
                   if ( $parent ) {
                    push @{$tag_stack},$parent;
                    $parent->{value} = $current->{value}  ;
                    } else {
                        my $events = $self->_events();
                        $events->{'curr'} = sub { $self->_parse_stream(@_) };
                        $self->_parse_stream({%$struct,state=>4},$current->{value});
                    }

                }
                
            } else {  die "empty stack !".Dumper(\@_)}
     }
    } #for
} #sub

sub _parse_stream {
    my $self = shift;
    my ( $struct, $data,$elem,%attr ) = @_;
    my ($state,$shared,$tags) = @{$struct}{'state','shared','tags'};
    my $stream_stack = $shared->{stream_stack}||[];
    $shared->{stream_stack} = $stream_stack;
    if ( $state == 1 && exists($tags->{$elem}))  {
        return unless defined $tags->{$elem};
        push @{$stream_stack},{ name=>$elem,attr=>\%attr};
        $self->_events({'curr'=> sub { $self->_xml2hash_handler(@_) } });
    }
    if ( $state == 4 ) {
        my $current = pop @{$stream_stack};
        $current->{value} = $data;
        return unless my $handler = $tags->{$current->{name}};
        $handler->(value=>$current->{value},attr=>$current->{attr});
        return
    }
}
sub _handle_ev{
    my $self = shift;
    my $events = $self->_events;
    return $events->{'curr'}->(@_)
}

sub read {
    my $self = shift;
    my $tags = shift or return;
    my $file_in = $self->_get_handle();
    $self->_events({'curr'=> sub { $self->_parse_stream(@_) }});
    my $shared = {};
    my $parser = new XML::Parser(
            Handlers =>{
                Start=> sub { $self->_handle_ev({state=>1,shared=>$shared,tags=>$tags},@_)},
                Char=> sub { $self->_handle_ev({state=>2,shared=>$shared,tags=>$tags},@_)},
                End=> sub { $self->_handle_ev({state=>3,shared=>$shared,tags=>$tags},@_)},
                }
                );
    $parser->parse($file_in);

}
sub close {
    my $self = shift;
    $self->_file_handle->close if $self->_need_close and $self->_file_handle;
}


1;
