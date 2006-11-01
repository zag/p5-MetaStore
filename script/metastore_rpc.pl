#!/usr/bin/perl
  use LWP::UserAgent;
  use Getopt::Long;
  use Data::Dumper;
  use Pod::Usage; 
  use strict;
  use XML::Writer;
  use IO::File;

  $|++;
  my $man = 0;
  my $help = 0;
  my $url  = 'http://site.zag/';
  my $global_ua;
  my ($image,$preview)=('','');
  my $meta = 'Dummy meta';
  my $title="Default title";
  my %opt = (help=>\$help,man=>\$man, url=>\$url,image=>\$image,preview=>\$preview,meta=>\$meta,);
  GetOptions(\%opt,
        'help|?','man','h|host=s', 'u|upload','d|download')
        or pod2usage(2);
  pod2usage(1) if $help or !( $opt{u} or $opt{d});
  pod2usage(-exitstatus => 0, -verbose => 2) if $man;
  print "login:";
  my $res = &dao_rpc('perm/login',get_base=>1, usr=>'test', pw=>'test');
  pod2usage(-exitstatus => 1, -message=>'Check username or password ') if $res =~ /^fail/i;
  print "ok\n";
  $url =~ s%/+$%%;
  $url .= "$res/";
  if ($opt{u}) {
    my $package = shift @ARGV;
    pod2usage(-exitstatus => 1, -message=>"not found package file $package") unless -e $package;
    my $res =  &dao_rpc('manager/set_package',pack=>[$package],test=>1);
    pod2usage(-exitstatus => 1, -message=>'Error upload package') unless $res == 1;
    exit 0;
  }
  if ($opt{d}) {
    my $package = shift @ARGV;
    my @list = @ARGV;
    my $res =  &dao_rpc('manager/get_package',list=>join"_"=>@list);
    my $fd = new IO::File:: "> $package";
    { local $/; undef $/; $fd->print($res) }
    $fd->close;
    exit 0;
  }
  sub dao_rpc {
    my $publish_url = $url;
    my $path = shift;
    my %arg = @_;
    my $ua = $global_ua || LWP::UserAgent->new;
    $global_ua ||= $ua;
    $ua->agent("MyApp/0.1 ");
    my $res;
    unless ( grep { ref($_) eq 'ARRAY' } values %arg ) {
      $res = $ua->post($publish_url.$path,[%arg])
     } else {
      $res = $ua->post(
                $publish_url.$path,
                Content_Type => 'form-data',
                Content=>[%arg]
                );
    }
    unless ( $res->is_success ) {
        print "err: " . $res->status_line . "\n";
        return undef;
    } else {
	return $res->content
    }
    
  }

sub _dao_rpc {
    my $publish_url = $url;
    my $path = shift;
    my %arg = @_;
    my $ua = $global_ua || LWP::UserAgent->new;
    $global_ua ||= $ua;
    $ua->agent("MyApp/0.1 ");
    my $res = $ua->post($publish_url.$path,[%arg]);
    unless ( $res->is_success ) {
        print "err: " . $res->status_line . "\n";
        return undef;
    } else {
	return $res->content
    }
    
  }
    sub pub_entry {
        my $method = 'metadb/post_blog_entry';
        my $res = &dao_rpc($method,
            meta=>$meta,
            publish_date=>time,
            title=>$title
            );
        return $res

    }
    sub pub_gallery {
       my ( $images )  = @_;
     my $res = &dao_rpc('metadb/post_gallery',
        meta=>$meta,
        publish_date=>time,
        title=>$title,
        images =>$images
        );
    }
    sub pub_image {
        my ($image,$preview) = @_;
        my $method = 'metadb/post_image';
        my ($image_data,$preview_data) = map {
        my $data;
        { local $/; $/=undef; open FH,"<$_"; $data = <FH>; close FH};
        [ $_,$data]
        } ($image,$preview);
        my $res = &dao_rpc($method,
           meta=>( reverse grep { $_ } split (/\//,$image_data->[0]))[0],#$file->[0],
           meta_data=>$image_data->[1],
           preview=>( reverse grep { $_ } split (/\//,$preview_data->[0]))[0],#$preview->[0],
           preview_data=>$preview_data->[1],
           publish_date=>time,
           title=>$title || $image_data->[0]);
        return $res;
    }


=cut

=head1 NAME

  meta_publish.pl  - tool for RPC MetaStore

=head1 SYNOPSIS

  meta_publish.pl [options]

   options:

    -help  - print help message
    -man   - print man page

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits

=item B<-man>

Prints manual page and exits

=item B<-tag> L<tagname>

Set L<tagname> for use as vendor tag when indexing

=item B<-d>,B<-delete>

Delete L<keys> from VenIndexer storage for specifyed (by B<-tag>) L<tagname>. Keys read from L<STDIN>

=item B<-i>,B<-index>

Index data in VenIndexer storage for specifyed (by B<-tag>) L<tagname>. Data read from L<STDIN>

=back

=head1 DESCRIPTION

B<salad_index_dict.pl>  - programm for index salad database.

=cut

