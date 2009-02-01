use Module::Build;
Module::Build->new
    ( module_name => 'MetaStore',
    license => 'perl',
   prereq => {
       'Objects::Collection'=>'0.02',
       'Data::UUID'=>'0.11',
       'WebDAO'=>'1.00',
       'MIME::Base64'=>'3.07',
       'Archive::Zip'=>'1.16',
       'IO::Zlib'=>'1.04',
       'Template'=>'2.14',
       'XML::Flow'=>'0.82',
       'JSON'=>2.07
	     },
   dist_version_from=>'lib/MetaStore.pm',
   dist_author=>'Zahatski Aliaksandr zag@cpan.org',
    create_makefile_pl=>$ENV{DO_OUTCPAN} ? 'traditional':'passthrough'
    )->create_build_script;
