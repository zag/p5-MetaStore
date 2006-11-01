package MetaStore::Manager;
use Objects::Collection::Base;
use HTML::WebDAO;
use MetaStore::StoreDir;
use MetaStore::XMLStream;
use MetaStore::Base;
use Data::Dumper;
use Archive::Zip;
use IO::Zlib;
use XML::LibXML;
use File::Temp qw/ tempfile tempdir /;
use File::Path;

use strict;
use warnings;

our @ISA = qw(HTML::WebDAO::Component MetaStore::Base);
our $VERSION = '0.01';
attributes qw/ _obj_path _pull/;
sub init {
    my $self = shift;
    $self->_pull("");
    _obj_path $self  shift;
    return $self->SUPER::init(@_);
}

sub post_entry {
    my $self = shift;
    my $class = shift;
    my %arg = @_;
    my $obj = $self->meta_store->__meta_coll->create_object(class=>$class);
    $obj->set_attr(%arg) if %arg;
    return $obj
}

sub post_blog_entry {
    my $self = shift;
    my %args = @_;
    map {
        $args{$_} = $self->mysql2time($args{$_})
    } grep {/^time_/} keys %args;
    LOG $self "post_blog_entry:".Dumper(\%args);
    if ( my $obj = $self->post_entry('_metastore_entry',%args) ){
        LOG $self "Create :".$obj->id
    }
#        $self->post_entry('_metastore_entry',@_);
    return $self;
}
sub meta_coll {
    
}
sub meta_store {
    my $self = shift;
    return $self->call_path($self->_obj_path);
}
sub obj_coll {
    my $self = shift;
    return $self->meta_store->collections;
    return $self->call_path($self->_obj_path);
}

sub view_item {
    my $self= shift;
    my %args = @_;
    if ( my $obj = $self->obj_coll->fetch_object($args{id}) ) {
        $self->_pull($obj->fetch);
        return ;
    }
    return
}

sub delete_item {
    my $self= shift;
    my %args = @_;
    if ( my $obj = $self->obj_coll->fetch_object($args{id}) ) {
        $self->obj_coll->delete_objects($obj->id);
        return ;
    }
    return
}

sub edit_item {
    my $self= shift;
    my %args = @_;
    if ( my $obj = $self->obj_coll->fetch_object($args{id}) ) {
        $self->_pull($obj->form);
        return ;
    }
    return
}

sub edit_attr_form {
    
}
sub format_item {
    my $self = shift;
    my $obj = shift;
    my %addition = @_;
    return $obj->parse_TT('templ/view_item.txt', { %addition,owner=>$self, entry=>$obj});
}
sub create {
    my $self = shift;
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
        {type=>"input",name=>'title',value=>'title',size=>30},
        "<br /><strong>time_publish:</strong>",
        {type=>"input",name=>'time_publish',value=>$self->time2mysql(),size=>30, id=>'time_publish'},
        '<span id="f_trigger_c">set</span>',
        "<br/><strong>is_public:</strong>",
        {type=>"checkbox",name=>"is_public",value=>"1",checked=>1},
        q!<textarea name="meta" cols="55" rows="20">!."text".'</textarea>',
        '<input value="Set" type="submit" >'
        );
    my $res =q! <script type="text/javascript">
Calendar.setup({
    inputField     :    "time_publish",     // id of the input field
    ifFormat       :    "%Y-%m-%d %H:%M:%S",      // format of the input field
    button         :    "f_trigger_c",  // trigger for the calendar (button ID)
    align          :    "Tl",           // alignment (defaults to "Bl")
    singleClick    :    true,
    firstDay       :      1 , //Mondey
    });
</script>!;
$self->_pull($edit.$self->manager_menu.$self->CompileForm({data=>\@form, sendto=>$self->url_method('post_blog_entry')}).$res);
    return $self;
}

sub manager_menu {
    my $self = shift;
    my $res =q! <ul id="genmenu">!.
    join "", map {qq! <li> $_ </li>! } 
             map { qq! <a href="$_->[0]" id="navHome"> $_->[1]</a>!}
             map { [$self->url_method($_->[0]),$_->[1] ]}
             (['create','create'], ['list','list'], ['find','find']);
             
    return $res."</ul>"
}
sub fetch{
    my $self= shift;
    return $self->_pull if $self->_pull;
    my $i;
#    return $self->manager_menu;
    my @form = $self->PrepareForm(
        "<strong>upload file:</strong>",
        {type=>"file",name=>'pack',value=>'',size=>30},
        '<input value="Set" type="submit" >'
        );
    my $res = $self->CompileForm({data=>\@form, sendto=>$self->url_method('set_package'),enctype=>'multipart/form-data'});

    return $self->manager_menu .$res.join ""=> map { 
        $i++;
        $self->format_item($_,nodd=>($i % 2), 
            viewurl=>$self->url_method("view_item",id=>$_->_obj_name),
            editurl=>$self->url_method("edit_item",id=>$_->_obj_name),
            );
        } values %{$self->obj_coll->fetch_objects({tval=>'_metastore_gallery'},{tval=>'_metastore_entry'})};
#        } values %{$self->obj_coll->_fetch_all};
#    return "test";
}

sub set_package {
    my $self = shift;
    my %arg = @_;
    my $pack = $arg{pack};
    my $dao_list = $self->meta_store;
    my ($fh, $tmp_file) = tempfile();
    my $bytes_to_read = 20480; my $msg = '';
    while ($bytes_to_read) {
       $bytes_to_read = sysread ($pack,$msg,$bytes_to_read);
       syswrite $fh,$msg,$bytes_to_read if $bytes_to_read;
     }
    $fh->close;
    my $fz = IO::Zlib->new($tmp_file, "rb");

    my $dir = tempdir( CLEANUP => 0 );
    my $temp_store = new MetaStore::StoreDir:: $dir;
    $temp_store->putRaw("temp_restore",$fz);
    $fz->close;
    if ( my $tmp_fd = $temp_store->getRaw_fh("temp_restore") ) {
        $self->meta_store->_restore_objects(file=>$tmp_fd);
        $tmp_fd->close;
    }
    rmtree($dir,0);
    unlink $tmp_file;
    return 1;
}
sub get_package {
    my $self = shift;
    my %arg = @_;
    my @list = split(/[^\d]+/,$arg{list});
    @list = @{$self->meta_store->__meta_coll->_fetch_all_ids} unless scalar @list;
    my $tmpdir = tempdir( CLEANUP => 0 );
    my $temp_store = new MetaStore::StoreDir:: $tmpdir;
    my $key = 'export.gz';
    my $file = $temp_store->get_path_to_key($key);
    my $fz = IO::Zlib->new($file, "wb9");
    $self->meta_store->_dump_objects(list=>\@list,file=>$fz);
    $fz->close;
    LOG $self "Temp dir id $tmpdir";
    return {header=>"Content-Type: application/x-gzip\nLast-Modified: Sun, 25 Sep 2005 03:34:32 GMT\n\n",data=>$temp_store->getRaw($key), call_back=>sub { rmtree($tmpdir,0) } };
#    return Dumper($temp_store->getRaw($key));
    return "$tmpdir $file ";
    return Dumper(\@list);
  

}

sub upload_pack {
    my $self = shift;
    my %arg = @_;
    my $pack = $arg{pack};
    my ($fh, $tmp_file) = tempfile();
    my $bytes_to_read = 1024; my $msg = '';
    while ($bytes_to_read) {
       $bytes_to_read = sysread ($pack,$msg,$bytes_to_read);
       syswrite $fh,$msg,$bytes_to_read if $bytes_to_read;
     }
    my $zip = new Archive::Zip::;
    $zip->read($tmp_file);
    my $dir = tempdir( CLEANUP => 0 );
    my $status = $zip->extractTree('',"$dir/");
    my $dom = ( new XML::LibXML::) ->parse_file("$dir/index.xml");
    #first restore images
    my @images_list;
    my @images = $dom->findnodes(q!//entry[@class='_metastore_image']!);
    foreach my $image (@images) {
     my %attr;
     map { $attr{ $_->getAttribute('name') } = $_->textContent } @{ $image->findnodes('attributes/attr') };
    $attr{meta} = $attr{image};
    delete $attr{image};
    map {
        my $data ;
        my $file = "$dir/$attr{$_}";
        { local $/; $/=undef; open FH,"<$file"; $data = <FH>; close FH;}
        $attr{$_."_data"} = $data;
        my ( $filename ) = reverse split ( /\//,$attr{$_});
        $attr{$_} = $filename;
    }   (qw/meta preview/);
     my $meta = ( $image->findnodes('meta') )[0]->textContent;
     my $obj = $self->meta_store->__meta_coll->create_item(class=>'_metastore_image');
     $obj->set_attr(%attr) if %attr;
    push @images_list, $obj->_obj_name;
    #print Dumper({ 'attr'=>\%attr,meta=>$meta});#$image->toString();
    }

    my ($gallery_node) = $dom->findnodes(q!//entry[@class='_metastore_gallery']!);
    my %gallery_attr;
    foreach my $attr (  $gallery_node->findnodes(q!attributes/attr!) ) {
      $gallery_attr{$attr->getAttribute('name')} = $attr->textContent;
#    print $attr->toString;
    }
    my $gallery_meta = ($gallery_node->findnodes('meta') )[0]->textContent;
    $gallery_attr{meta} = $gallery_meta;
    $gallery_attr{images} = join " "=>@images_list;
    my $obj1 = $self->meta_store->__meta_coll->create_item(class=>'_metastore_gallery');
    $obj1->set_attr(%gallery_attr) if %gallery_attr;    
    return "$dir :$status :$tmp_file";
    return Dumper(\%arg);
    return "size:".length ($pack);
    ;
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
