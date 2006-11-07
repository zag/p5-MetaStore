package MetaStore::DAOList;
use HTML::WebDAO;
use HTML::WebDAO::Comp::Label;
use HTML::WebDAO::Component;
use Objects::Collection::Item;
use MetaStore::Cmetatags;
use MetaStore::Cmetalinks;
use HTML::WebDAO::Base;
use MetaStore::DAOImage;
use MetaStore::Gallery;
use MetaStore::User;
use MetaStore;
use MetaStore::XMLStream;
use MetaStore::StoreDir;
use Data::Dumper;
use DBI;

use MIME::Base64;
use File::Temp qw/ tempfile tempdir /;
use File::Path;

use strict;
use warnings;
use base qw(HTML::WebDAO::Container);
attributes qw/  __meta_coll _config/;
sub init {
    my $self = shift;
    $self->SUPER::init(@_);
    my %arg =  @_;
    my %class_prefs = 
    map { 
        my ($key,$key2) = split /\./;
        $key => ( defined $key2 ? {$key2=>$arg{$_}} : $arg{$_})
        } keys %arg;
    _config $self (\%class_prefs);
    if (ref (my $collection =  $arg{collection}) ) {
      __meta_coll $self $collection
    } else {
    my ($database,$host,$user,$password
        ) = ( 
        'metameta',
        '127.0.0.1',
        'root',
        'zreboot37'
        );
  _log1 $self Dumper($self->getEngine->_conf->db);
      my ($database,$host,$user,$password
        ) = @{$self->getEngine->_conf->db}{qw/database host user password/};
  my $DSN = "mysql:database=$database;host=$host;";
  my $dbh = DBI->connect("DBI:$DSN",$user,$password,{
  RaiseError => 0, PrintError => 1, AutoCommit => 0 } 
  ) or die $DBI::errstr;
    my $props = new MetaStore::Cmetatags::
                        dbh => $dbh,
                        table => 'metatags',
                        field=> 'mid';
  my $metaobj = new Objects::Collection::AutoSQL::
                        dbh => $dbh,
                        table => 'metadata',
                        field=> 'mid',
                        delete_key =>1;
  my $links = new MetaStore::Cmetalinks::
                        dbh => $dbh,
                        table => 'metalinks',
                        field=> 'lsrc';
  my $meta_obj = new MetaStore:: props=>$props, meta=>$metaobj, links=>$links;;
  __meta_coll $self $meta_obj;
  }
  $self->__meta_coll->sub_ref( sub{ $self->_create_obj(@_) } );
  $self->getEngine()->register_class('MetaStore::DAOEntry'=>'entry');
  $self->getEngine()->register_class('MetaStore::DAOEntry'=>'_metastore_entry');
  $self->getEngine()->register_class('MetaStore::DAOImage'=>'_metastore_image');
  $self->getEngine()->register_class('MetaStore::Gallery'=>'_metastore_gallery');
  $self->getEngine()->register_class('MetaStore::User'=>'_metastore_user');
  my $res = {};
  map { 
        my $obj = $self->getEngine()->_createObj("entry_".$_->id,'entry',$_);
        $self->AddChild($obj);
    } values %$res;
  $self->RegEvent( "_sess_ended", \&commit );

}
sub fetch {};
sub commit {
    my $self= shift;
    $self->__meta_coll->commit;
}

sub test {
    my $self = shift;
    my %arg = @_;
    return "<h1>WORK !!!</h1><pre>".Dumper(\%arg)
}
sub self {
    return $_[0]
}
sub collections {
    my $self = shift;
    return $self->__meta_coll;
}

sub _create_obj {
    my $self = shift;
    my ( $id,$ref_attr ) = @_;
    my $store = new MetaStore::StoreDir:: ($self->_config->{store_root}||'/tmp/Meta2/');
    my $attr = $ref_attr->{props};
    my $class = $attr->{__class};
    my $addit = $self->_config->{$attr->{__class}}  || {};
#    _log1 $self "Create object ".$attr->{__class}." attr:".Dumper($attr)."addit:".Dumper($addit);
    my $obj;
    $obj = $self->getEngine()->_createObj(
        $id,
        $class,
        $attr,
        $ref_attr->{meta},
        $ref_attr->{links},
        $store->new($id),
        $id,
        $self->collections,
        ref($addit) eq 'ARRAY' ? @$addit : %$addit,
        );
    $self->AddChild($obj) if $obj;
    return $obj
}

sub _get_obj_by_name {
    my $self = shift;
    my ($name) = @_;
    my $res = $self->SUPER::_get_obj_by_name($name);
    unless ( $res ) {
        $res = $self->__meta_coll->fetch_object($name) ;
        return unless $res;
    }
    return $res;
}


sub _dump_objects {
     my $self = shift;
     my %args = @_;
     my @ids = @{ $args{list} };
     my $file = $args{file};
     my $meta_store = $self->__meta_coll;
     my @obj4Dump = values %{ $meta_store->fetch_objects(@ids) };
     #expand by links
     my @linked_ids;
     foreach my $obj ( @obj4Dump ) {
        my @lids  = @{ $obj->links || [] };
        push @linked_ids,@lids;
     }
     #add objects ids
     push @linked_ids, map { $_->id } @obj4Dump;
     #now uniq
     my %uniq;
     my @ordered_ids = grep { ! $uniq{$_}++ } @linked_ids;
     @obj4Dump = @{ $meta_store->fetch_objects(@ordered_ids) } {@ordered_ids};
     my $fd;
     my $stream;
     unless ( $file ) {
       my $tmpdir = tempdir( CLEANUP => 1 );
       ($fd,$file) = tempfile( DIR => $tmpdir );
       $stream = new MetaStore::XMLStream:: $fd;
      }
      else {
        $stream = new MetaStore::XMLStream:: $file;
      }
     $stream->startTag('Dump');
     foreach my $obj (@obj4Dump) {
       my $dir = tempdir( CLEANUP => 1 );
       my $temp_store = new MetaStore::StoreDir:: $dir;
       my $attr = $obj->_attr;
       my $guid = $obj->guid || $meta_store->make_uuid;
       $obj->_attr->{guid} = $guid;
        my $dmp = $obj->dump($temp_store);
         foreach my $key ( @{$temp_store->get_keys} ) {
           $stream->startTag("raw_data",name=>"$key", pguid=>$guid);
           $stream->write({ data=>encode_base64( $temp_store->getRaw($key) ) });
           $stream->closeTag("raw_data");
         }
       $stream->startTag('entry',class=>$attr->{__class}, guid=>$guid);
       #convert linked ids to uuids
       my @links_ids = @{$obj->links};
       my @links_uuids;
       foreach my $id ( @links_ids ) {
        if (my $obj = $meta_store->fetch_object($id)){
            push @links_uuids, $obj->guid
        }
       }
       $stream->write({ object => $dmp, links=>\@links_uuids });
       $stream->closeTag('entry');
       rmtree($dir,0);
    }
    $stream->closeTag('Dump');
    $fd->close if $fd;
    return $file
}

sub _restore_objects {
     my $self = shift;
     my %args = @_;
     my $file = $args{file};
     my $stream = new MetaStore::XMLStream:: $file;
     my $meta_store = $self->__meta_coll;
     my $dir = tempdir( CLEANUP => 0 );
     our $store_root = new MetaStore::StoreDir:: $dir;
     our %guid_map_id;
     my %tags=(
            Dump=>undef,
            raw_data=>sub {
                my %args= @_;
                my $attr = $args{attr};
                my $value = $args{value};
                my ($pguid, $name) = @{$args{attr}}{qw/ pguid name /};
                my $current_store = $store_root->new($pguid);
                $current_store->putRaw( $name,decode_base64($value->{data}));
            },
            entry=>sub { 
                my %args= @_;
                my $attr = $args{attr};
                my $value = $args{value};
                my $obj = $meta_store->fetch_by_guid($attr->{guid});
                unless ( $obj ) {
                    $obj = $meta_store->create_object(guid=>$attr->{guid},class=>$attr->{class});
                }
                $guid_map_id{ $attr->{guid} } = $obj->id;
                my ($object,$links) = @$value{qw/ object links /};
                $obj->restore($store_root->new($attr->{guid}),$object);
                my @restored_ids;
                foreach my $uuid (@$links) {
                    my $tmp_obj = $meta_store->fetch_object($guid_map_id{$uuid}) || $meta_store->fetch_by_guid($uuid);
                    if ( $tmp_obj ) {
                        push @restored_ids,$tmp_obj->id;
                    }
                    else {
                        LOG $self "restore: can't find obj for uuid: $uuid"
                    };
                }#foreach
                #resore links
                $obj->links(@restored_ids)
                });
    $stream->read(\%tags);
    $meta_store->commit();
    rmtree($dir,0);
}

sub ref2file {
    my $self = shift;
    my $file = shift;
    my $ref  = shift;
    return unless ref $ref;
    my $stream = new MetaStore::XMLStream:: $file;
    $stream->startTag('Dump');
    $stream->write($ref);
    $stream->closeTag('Dump');
    $stream->close;
}

sub file2ref {
    my $self = shift;
    my $file = shift;
    my $stream = new MetaStore::XMLStream:: $file;
    our $ref;
    my %tags=(
            Dump=>sub{
               my %args= @_;
               my $value = $args{value};
               $ref = $value
               }
            );
    $stream->read(\%tags);
    $stream->close;
    $ref
}

sub _destroy {
    my $self = shift;
    my $meta = $self->__meta_coll;
    $meta->props->get_dbh->disconnect;
    $self->SUPER::_destroy();
}




sub post_image {
    my $self = shift;
    return $self->post_entry('_metastore_image',@_);
}

sub create_blog_entry {
    my $self = shift;
    return $self->post_entry('_metastore_entry',@_);
}

sub post_gallery {
    my $self = shift;
    return $self->post_entry('_metastore_gallery',@_);
}

sub _post_entry {
    my $self = shift;
    my $class = shift;
    my %arg = @_;
    my $obj = $self->__meta_coll->create_object(class=>$class);
    $obj->set_attr(%arg);
    return $obj->_obj_name
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
