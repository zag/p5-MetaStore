package MetaStore::DAOEntry;
use HTML::WebDAO;
use HTML::WebDAO::Component;
use Template;
use Objects::Collection::Item;
use MetaStore;
use Data::Dumper;
use strict;
use warnings;
use Objects::Collection::Item;
use HTML::WebDAO::Base;
use Time::Local;
use base qw(HTML::WebDAO::Component Objects::Collection::Item);
attributes qw/  _meta _links isEdit _meta_props _meta_store _pars _store _id/;

sub init {
    my $self = shift;
    _attr $self shift(@_);
    _meta $self shift(@_);
    _links $self shift(@_);
    _store $self shift(@_);
    _id $self shift(@_);
    _meta_props $self shift(@_);
    _meta_store $self $self->_meta_props;
    isEdit $self 0;
    my $attr = $self->_attr;
    $attr->{time_create}  = time unless exists $attr->{time_create};
    $attr->{time_publish} = time unless exists $attr->{time_publish};
    $attr->{is_public}    = 0    unless exists $attr->{is_public};
    $attr->{title}        = ''   unless exists $attr->{title};
    $self->set_pars(@_);

}

sub set_pars {
    my $self = shift;
    my %args = @_;
    _pars $self ( \%args );

    #    _log4 $self Dumper($self->_pars)
}

sub links {
    my $self  = shift;
    my $links = $self->_links;
    $links->{list} = [@_] if @_;
    return $links->{list} || [];
}

sub parse_TT {
    my $self = shift;
    my ( $template, $predefined ) = @_;
    my $conf = $self->getEngine->config;
    $template = $conf->get_full_path($conf->general->{template_dir}, $template );
    my $template_obj = new Template
      INTERPOLATE => 1,
      EVAL_PERL   => 1,
       ABSOLUTE   =>1,
      VARIABLES   => $predefined,
      or do { $self->logmsgs( "TTK Error:", [$Template::ERROR] ); return };
    my $res;
    $template_obj->process( $template, $predefined, \$res ) or do {
        my $error = $template_obj->error();
        $self->_log1( "TTK Error:" . $error );
        return;
    };
    return $res;
}

sub set_attr {
    my $self = shift;
    my %args = @_;
    my $attr = $self->_attr;
    if ( exists $args{meta} ) {
        $self->meta( $args{meta} );
        delete $args{meta};
    }
    while ( my ( $key, $val ) = each %args ) {
        $attr->{$key} = $val;
    }
}

sub guid {
    my $self = shift;
    return $self->_attr->{guid};
}

sub id {
    return $_[0]->_id;
}

sub meta {
    my $self = shift;
    $self->_meta->{mdata} = $_[0] if $_[0];
    return $self->_meta->{mdata};
}

sub save {
    my $self = shift;
    my %args = @_;
    my $obj  = $self;
    LOG $self "SAVE:" . Dumper( \%args );
    map { $args{$_} = $self->mysql2time( $args{$_} ) } grep { /^time_/ } keys %args;
    $obj->meta( $args{meta} ) if $args{meta};
    $obj->_attr->{title}        = $args{title}        if $args{title};
    $obj->_attr->{time_publish} = $args{time_publish} if $args{time_publish};
    $obj->_attr->{is_public} = $args{is_public} || 0;
    $self->isEdit(0);
    $self;
}

sub dump {
    my $self  = shift;
    my $store = shift;
    my %tmp_attr;
    while ( my ( $key, $val ) = each %{ $self->_attr } ) {
        $val = $self->time2mysql($val) if $key =~ /^time/;
        $val = $tmp_attr{$key} = $val;
    }
    return { attributes => \%tmp_attr, meta => $self->meta };
}

sub restore {
    my ( $self, $store, $restore ) = @_;
    return unless $restore or $store;
    my %tmp_attr;
    while ( my ( $key, $val ) = each %{ $restore->{attributes} } ) {
        $val = $self->mysql2time($val) if $key =~ /^time/;
        $tmp_attr{$key} = $val;
    }
    %{ $self->_attr } = %tmp_attr;
    $self->meta( $restore->{meta} );
}

sub time2mysql {
    my ( $self, $time ) = @_;
    $time = time() unless defined($time);
    my ( $sec, $min, $hour, $day, $month, $year ) = ( localtime($time) )[ 0, 1, 2, 3, 4, 5 ];
    $year  += 1900;
    $month += 1;
    $time = sprintf( '%.4d-%.2d-%.2d %.2d:%.2d:%.2d', $year, $month, $day, $hour, $min, $sec );
    return $time;
}

sub mysql2time {
    my ( $self, $time ) = @_;
    return time() unless $time;
    my ( $year, $month, $day, $hour, $min, $sec ) =
      $time =~ m/(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)/;
    return '0' unless ( $year + $month + $day + $hour + $min + $sec );
    $year  -= 1900;
    $month -= 1;
    $time = timelocal( $sec, $min, $hour, $day, $month, $year );
    return $time;
}

sub delete {
    my $self = shift;
    $self->_store->clean;
}

sub form {
    my $self = shift;
    my %arg  = @_;
    my $attr = $self->_attr;
    my $edit = <<END;
    <script language="javascript" type="text/javascript" src="/js/tiny_mce/tiny_mce.js"></script>
    <script language="javascript" type="text/javascript">
initArray = {
//    mode : "specific_textareas",
        mode: "textareas",
      textarea_trigger : "title",
      width : "100%",
      theme : "advanced",
    content_css : "/data/style.css",
      theme_advanced_buttons1 : "bold,italic,strikethrough,separator,bullist,numlist,outdent,indent,separator,justifyleft,justifycenter,justifyright,separator,link,unlink,image,wordpress,separator,undo,redo,code,preview",
       theme_advanced_buttons2 : "",
       theme_advanced_buttons3 : "",
       theme_advanced_toolbar_location : "top",
       theme_advanced_toolbar_align : "left",
       theme_advanced_path_location : "bottom",
       theme_advanced_resizing : true,
       browsers : "msie,gecko,opera",
       dialog_type : "modal",
       theme_advanced_resize_horizontal : false,
       entity_encoding : "raw",
       relative_urls : false,
       remove_script_host : false,
       force_p_newlines : true,
       force_br_newlines : false,
       convert_newlines_to_brs : false,
       remove_linebreaks : true,
//       save_callback : "wp_save_callback",
 valid_elements : "a[accesskey|charset|class|coords|dir<ltr?rtl|href|hreflang|id|lang|name|onblur|onclick|ondblclick|onfocus|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|rel|rev|shape<circle?default?poly?rect|style|tabindex|title|target|type],abbr[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],acronym[class|dir<ltr?rtl|id|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],address[class|align|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],applet[align<bottom?left?middle?right?top|alt|archive|class|code|codebase|height|hspace|id|name|object|style|title|vspace|width],area[accesskey|alt|class|coords|dir<ltr?rtl|href|id|lang|nohref<nohref|onblur|onclick|ondblclick|onfocus|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|shape<circle?default?poly?rect|style|tabindex|title|target],base[href|target],basefont[color|face|id|size],bdo[class|dir<ltr?rtl|id|lang|style|title],big[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],blockquote[dir|style|cite|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],body[alink|background|bgcolor|class|dir<ltr?rtl|id|lang|link|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onload|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|onunload|style|title|text|vlink],br[class|clear<all?left?none?right|id|style|title],button[accesskey|class|dir<ltr?rtl|disabled<disabled|id|lang|name|onblur|onclick|ondblclick|onfocus|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|tabindex|title|type|value],caption[align<bottom?left?right?top|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],center[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],cite[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],code[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],col[align<center?char?justify?left?right|char|charoff|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|span|style|title|valign<baseline?bottom?middle?top|width],colgroup[align<center?char?justify?left?right|char|charoff|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|span|style|title|valign<baseline?bottom?middle?top|width],dd[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],del[cite|class|datetime|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],dfn[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],dir[class|compact<compact|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],div[align<center?justify?left?right|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],dl[class|compact<compact|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],dt[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],em/i[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],fieldset[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],font[class|color|dir<ltr?rtl|face|id|lang|size|style|title],form[accept|accept-charset|action|class|dir<ltr?rtl|enctype|id|lang|method<get?post|name|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|onreset|onsubmit|style|title|target],frame[class|frameborder|id|longdesc|marginheight|marginwidth|name|noresize<noresize|scrolling<auto?no?yes|src|style|title],frameset[class|cols|id|onload|onunload|rows|style|title],h1[align<center?justify?left?right|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],h2[align<center?justify?left?right|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],h3[align<center?justify?left?right|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],h4[align<center?justify?left?right|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],h5[align<center?justify?left?right|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],h6[align<center?justify?left?right|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],head[dir<ltr?rtl|lang|profile],hr[align<center?left?right|class|dir<ltr?rtl|id|lang|noshade<noshade|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|size|style|title|width],html[dir<ltr?rtl|lang|version],iframe[align<bottom?left?middle?right?top|class|frameborder|height|id|longdesc|marginheight|marginwidth|name|scrolling<auto?no?yes|src|style|title|width],img[align<bottom?left?middle?right?top|alt|border|class|dir<ltr?rtl|height|hspace|id|ismap<ismap|lang|longdesc|name|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|src|style|title|usemap|vspace|width],input[accept|accesskey|align<bottom?left?middle?right?top|alt|checked<checked|class|dir<ltr?rtl|disabled<disabled|id|ismap<ismap|lang|maxlength|name|onblur|onclick|ondblclick|onfocus|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|onselect|readonly<readonly|size|src|style|tabindex|title|type<button?checkbox?file?hidden?image?password?radio?reset?submit?text|usemap|value],ins[cite|class|datetime|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],isindex[class|dir<ltr?rtl|id|lang|prompt|style|title],kbd[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],label[accesskey|class|dir<ltr?rtl|for|id|lang|onblur|onclick|ondblclick|onfocus|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],legend[align<bottom?left?right?top|accesskey|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],li[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title|type|value],link[charset|class|dir<ltr?rtl|href|hreflang|id|lang|media|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|rel|rev|style|title|target|type],map[class|dir<ltr?rtl|id|lang|name|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],menu[class|compact<compact|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],meta[content|dir<ltr?rtl|http-equiv|lang|name|scheme],noframes[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],noscript[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],object[align<bottom?left?middle?right?top|archive|border|class|classid|codebase|codetype|data|declare|dir<ltr?rtl|height|hspace|id|lang|name|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|standby|style|tabindex|title|type|usemap|vspace|width],ol[class|compact<compact|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|start|style|title|type],optgroup[class|dir<ltr?rtl|disabled<disabled|id|label|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],option[class|dir<ltr?rtl|disabled<disabled|id|label|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|selected<selected|style|title|value],p[align<center?justify?left?right|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],param[id|name|type|value|valuetype<DATA?OBJECT?REF],pre/listing/plaintext/xmp[align|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title|width],q[cite|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],s[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],samp[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],script[charset|defer|language|src|type],select[class|dir<ltr?rtl|disabled<disabled|id|lang|multiple<multiple|name|onblur|onclick|ondblclick|onfocus|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|size|style|tabindex|title],small[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],span[align<center?justify?left?right|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],strike[class|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],strong/b[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],style[dir<ltr?rtl|lang|media|title|type],sub[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],sup[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],table[align<center?left?right|bgcolor|border|cellpadding|cellspacing|class|dir<ltr?rtl|frame|height|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|rules|style|summary|title|width],tbody[align<center?char?justify?left?right|char|class|charoff|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title|valign<baseline?bottom?middle?top],td[abbr|align<center?char?justify?left?right|axis|bgcolor|char|charoff|class|colspan|dir<ltr?rtl|headers|height|id|lang|nowrap<nowrap|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|rowspan|scope<col?colgroup?row?rowgroup|style|title|valign<baseline?bottom?middle?top|width],textarea[accesskey|class|cols|dir<ltr?rtl|disabled<disabled|id|lang|name|onblur|onclick|ondblclick|onfocus|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|onselect|readonly<readonly|rows|style|tabindex|title],tfoot[align<center?char?justify?left?right|char|charoff|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title|valign<baseline?bottom?middle?top],th[abbr|align<center?char?justify?left?right|axis|bgcolor|char|charoff|class|colspan|dir<ltr?rtl|headers|height|id|lang|nowrap<nowrap|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|rowspan|scope<col?colgroup?row?rowgroup|style|title|valign<baseline?bottom?middle?top|width],thead[align<center?char?justify?left?right|char|charoff|class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title|valign<baseline?bottom?middle?top],title[dir<ltr?rtl|lang],tr[abbr|align<center?char?justify?left?right|bgcolor|char|charoff|class|rowspan|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title|valign<baseline?bottom?middle?top],tt[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],u[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title],ul[class|compact<compact|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title|type],var[class|dir<ltr?rtl|id|lang|onclick|ondblclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|style|title]",
plugins : "preview"
                                                                                                };
                                                                                                
                                                                                                
                                                                                                tinyMCE.init(initArray);
/*                                                                                                tinyMCE.init({
    mode : "textareas",
    valid_elements : "a[href],strong/b,div[align|class],br,+p[style|dir|class],img[src],code,blockqoute",
    plugins : "preview",
    content_css : "/data/style.css"
    });
*/
    </script>
END
    my @form = $self->PrepareForm(
        "<strong>title:</strong>",
        { type => "input", name => 'title', value => $attr->{title}, size => 30 },
        "<br /><strong>time_publish:</strong>",
        {
            type  => "input",
            name  => 'time_publish',
            value => $self->time2mysql( $attr->{time_publish} ),
            size  => 30,
            id    => 'time_publish'
        },
        '<span id="f_trigger_c">set</span>',
        "<br/><strong>is_public:</strong>",
        {
            type  => "checkbox",
            name  => "is_public",
            value => "1",
            $attr->{is_public} ? ( checked => 1 ) : ()
        },
        q!<textarea name="meta" cols="55" rows="20">! . $self->meta . '</textarea>',
        '<input value="Set" type="submit" >'
    );
    my $res = q! <script type="text/javascript">
Calendar.setup({
    inputField     :    "time_publish",     // id of the input field
    ifFormat       :    "%Y-%m-%d %H:%M:%S",      // format of the input field
    button         :    "f_trigger_c",  // trigger for the calendar (button ID)
    align          :    "Tl",           // alignment (defaults to "Bl")
    singleClick    :    true,
    firstDay       :      1 , //Mondey
    });
</script>!;
    return $edit
      . $self->CompileForm( { data => \@form, sendto => $self->url_method('save') } )
      . $res;
}

sub setEdit {
    $_[0]->isEdit(1);
    return $_[0];
}

sub test {
    my $self = shift;
    my %arg  = @_;

    #    $self->Height($arg{Height});
    #    $self->Mode($arg{Mode});
    #    return $self;
    return "<h1>WORK !!!</h1><pre>" . Dumper( \%arg );
}

sub fetch_entr {
    my $self     = shift;
    my $attr     = $self->_attr;
    my $id       = $self->_obj_name;
    my $template = $self->_pars->{template};
    return $self->parse_TT( $template, { attr => $attr, owner => $self, id => $id } );
}

sub fetch {
    my $self = shift;
    return $self->form if ( $self->isEdit );
    return $self->fetch_entr;

    #    return "Obj ".$obj->id.":".$obj->meta."<br/><pre>".
    Dumper(
        {

            #    '$obj->id'=>$obj->id,
            '$self->url_method(test)' => $self->url_method( 'test', 'editmode' => 1 ),
            '$self->MyName'           => $self->MyName,

        }
      )
      . '</pre><a href="'
      . $self->url_method( 'setEdit', 'editmode' => 1 )
      . '"> edit</a>';
}

# Preloaded methods go here.

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
