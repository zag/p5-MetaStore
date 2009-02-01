#!/usr/bin/perl
  use WebDAO;
  use MetaStore;
  use MetaStore::Mem;
  use MetaStore::MemnotUnique;
  use Data::Dumper;
  use MetaStore::StoreDir;
  use IO::File;
  use Getopt::Long;
  use Data::Dumper;
  use Pod::Usage; 
  use IO::Zlib;
  use File::Temp qw/ tempfile tempdir /;
  use File::Path;
  use strict;
  use warnings;
  use Fcntl;
  $|++;
  my $man = 0;
  my $help = 0;
  my ($image,$preview)=('','');
#  my $meta = 'Dummy meta';
  my $title="Default title";
  my %opt = (help=>\$help,man=>\$man, image=>\$image,preview=>\$preview);#meta=>\$meta,);
  GetOptions(\%opt,
        'help|?','man','c|create','a|add','l|list','d=s', 'id=s','t|title=s'=>\$title, 'preview=s'=>\$preview, 'p|pack','u|unpack','T|test')
        or pod2usage(2);
  pod2usage(1) if $help;
  pod2usage(-exitstatus => 0, -verbose => 2) if $man;
  my $gallery_path = $opt{d};
  mkpath($gallery_path) unless -e $gallery_path;
 pod2usage(-exitstatus => 2, -message=>'Set -d "local path to dir for operate" ') unless $gallery_path;
my $eng=WebDAO::Engine->new("index",'',
    register=>{
        'MetaStore::DAOList' => 'meta_store',
        });
# my $file_restore = shift @ARGV;
 my $store_root = new MetaStore::StoreDir:: $gallery_path;
 my ($hash1, $hash2, $hash3 ) = map {
    my $item = $_;
    unless ( my $fh = $store_root->getRaw_fh($_) ){
        {}
    }
    else {
     file2ref MetaStore::DAOList::($fh) || {};
    }
 } qw/meta.xml props.xml links.xml/;
 #now read metas from cache dir
 foreach my $doc_id (keys %$hash1) {
    my $store = $store_root->new($doc_id);
    my $meta_file = 'meta.xhtml';
    next unless -e $store->get_path_to_key($meta_file);
    $hash1->{$doc_id}->{mdata} = $store->getText($meta_file);
    unlink $store->get_path_to_key($meta_file);
 }
  #create collections
  my $meta = new MetaStore::Mem:: mem=>$hash1;
  my $props = new MetaStore::MemnotUnique:: mem=>$hash2;
  my $links = new MetaStore::MemnotUnique:: mem=>$hash3;
  my $meta_obj = new MetaStore:: props=>$props, meta=>$meta, links=>$links;
  #create DAOList object
  my $list = $eng->_createObj("metadb","meta_store",
                    {
                      'collection' => $meta_obj
                    },
                    {
                        'store_root' => $gallery_path
                    },
                    {
                      '_metastore_entry' => {
                                            'template' => 'templ/blog_entry.txt'
                                          }
                    },
                    {
                      '_metastore_image' => {
                                            'template' => 'test.txt'
                                          }
                    },
                    {
                      '_metastore_gallery' => {
                                              'template' => 'templ/gallery.txt'
                                            }
                    }
);

  if ( $opt{c} ) {
     my  $obj  = $meta_obj->create_object(class=>'_metastore_gallery');
     pod2usage(-exitstatus => 2, -message=>'already created object gallery')
         unless  $obj->id() == 1;
     $obj->save(title=>$title);
     print $obj->id ."\n"
  }
  if ($opt{a}){
  my $image_file = shift @ARGV;
  pod2usage(-exitstatus => 0, -message=>'not exists image file for add ') 
    unless -e $image_file;
  pod2usage(-exitstatus => 0, -message=>'not exists preview image file ') 
    unless -e $preview;
  my $gallery = $meta_obj->fetch_object($opt{id}||1);
  pod2usage(-exitstatus => 2, -message=>'use -c for  create gallery first')
         unless  $gallery;
  
  my ( $image_name, $preview_name ) = 
     map { ( reverse split (/\//,$_))[0] }
  ($image_file,$preview);
  my $obj = $meta_obj->create_object(class=>'_metastore_image');
  $obj->save(title=>$title);
  $obj->set_image('_image', $image_name, new IO::File:: "< $image_file");
  $obj->set_image('_image_preview', $preview_name, new IO::File:: "< $preview");
  $gallery->add_image($obj);
  }
  if ($opt{p}) {
   my $file_name = (shift @ARGV) || $store_root->_dir."dump.xml.gz";
   my $fh = IO::Zlib->new("$file_name", "wb9");
   $list->_dump_objects(
    list=>[ $opt{id} || @{ $list->collections->_fetch_all_ids } ],
    file=>$fh);
   undef $fh if $fh;
  }
  if ($opt{u}) {
    my $file_name = (shift @ARGV) || $store_root->_dir."dump.xml.gz";
    my $fh = IO::Zlib->new("$file_name", "rb");
    my $dir = tempdir( CLEANUP => 0 );
    my $temp_store = new MetaStore::StoreDir:: $dir;
    $temp_store->putRaw("temp_restore",$fh);
    $fh->close;
    if ( my $tmp_fd = $temp_store->getRaw_fh("temp_restore") ) {
        $list->_restore_objects(file=>$tmp_fd);
        $tmp_fd->close;
    }
    rmtree($dir,0);
  }
  
  if ($opt{l}) {
    my $ref = $list->collections->_fetch_all;
    foreach  my $id ( sort {$a <=> $b} keys %$ref ) {
        my $obj = $ref->{$id};
        print join "\t", $id ,$obj->_attr->{__class}, $obj->guid;
        print "\n";
    }
  }
  if ($opt{T}) {
    my $gallery = $meta_obj->fetch_object($opt{id}||1);
#    $gallery->links(1,2,3,4);
    print Dumper($hash3);
#    print "links:";
#    print Dumper($gallery->links);
#    die "$gallery";
    #$meta_obj->delete_objects($opt{id});
#    unless  ( my $test_obj = $meta_obj->fetch_object($opt{id}) ) {
#       pod2usage(-exitstatus => 2, -message=>"Can not find object with id $opt{id}")
#    }
#    else {
#        $meta_obj->delete_objects($test_obj->id)
#    }
  }
foreach my $ref ([ 'meta.xml' => $hash1 ], [ 'props.xml'=> $hash2 ], [ 'links.xml'=> $hash3 ]) {
    my $file = $store_root->_dir.$ref->[0];
    $list->ref2file($file,$ref->[1] || {})
 }
#store meta for handy editing
 foreach my $doc_id (keys %$hash1) {
    my $store = $store_root->new($doc_id);
    my $meta_file = 'meta.xhtml';
    $store->putText($meta_file,$hash1->{$doc_id}->{mdata}) if exists $hash1->{$doc_id}->{mdata} ;
 }


=cut

=head1 NAME

  meta_publish.pl  - tool for RPC MetaStore

=head1 SYNOPSIS

  meta_publish.pl [options]

   options:

    -help  - print help message
    -man   - print man page
    -d directory    - set work directory
    -l     - list stored objects

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits

=item B<-man>

Prints manual page and exits

=item B<-tag> L<tagname>

Set L<tagname> for use as vendor tag when indexing

=item B<-d> L<directory>

Set L<directory> for use in all commands.

=item B<-l>,B<-list>

List L<keys> from VenIndexer storage for specifyed (by B<-tag>) L<tagname>. 

=item B<-d>,B<-delete>

Delete L<keys> from VenIndexer storage for specifyed (by B<-tag>) L<tagname>. Keys read from L<STDIN>

=item B<-i>,B<-index>

Index data in VenIndexer storage for specifyed (by B<-tag>) L<tagname>. Data read from L<STDIN>

=back

=head1 DESCRIPTION

B<salad_index_dict.pl>  - programm for index salad database.

=cut

