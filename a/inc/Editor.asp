<%

Sub Editor_View(Edt_MiniMode,Form_Content)
%>
<script>
var editFile_dir = "<%=DEF_BBS_HomeUrl%>a/";
</script>
<!--#include file="post_layer.asp"-->
<div class="editor_top">
<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr><td>
<%If Edt_MiniMode = 0 Then%>
<%Else%>
<table border=0 cellpadding=0 cellspacing=0 class="editor_table" width=100%>
<tr><td>
<table border=0 cellpadding=0 cellspacing=0><tr>
<td class=ico>
	<div class="layer_item">
	<div class="layer_icon_title"><a href="javascript:;" onclick="return false"><img src="<%=DEF_BBS_HomeUrl%>images/blank.gif" width="22" height="22" title="字体" class="a_pic" style="background-position:0px -44px" /></a></div>
	<div class="layer_iteminfo" id="menu_info_face" onclick="this.style.display='none';">
	<ul class="menu_list">
	<li unselectable=on class="menuhead">字体</li>
	<li unselectable=on onclick="insert('宋体');" style="font-family:宋体">宋体</li>
	<li unselectable=on onclick="insert('黑体');" style="font-family:黑体">黑体</li>
	<li unselectable=on onclick="insert('微软雅黑');" style="font-family:微软雅黑">微软雅黑</li>
	<li unselectable=on onclick="insert('Arial');" style="font-family:Arial">Arial</li>
	<li unselectable=on onclick="insert('Arial Black');" style="font-family:Arial Black">Arial Black</li>
	<li unselectable=on onclick="insert('Century Gothic');" style="font-family:Century Gothic">Century Gothic</li>
	<li unselectable=on onclick="insert('Comic Sans MS');" style="font-family:Comic Sans MS">Comic Sans MS</li>
	<li unselectable=on onclick="insert('Courier');" style="font-family:Courier">Courier</li>
	<li unselectable=on onclick="insert('Courier New');" style="font-family:Courier New">Courier New</li>
	<li unselectable=on onclick="insert('Times New Roman');" style="font-family:Times New Roman">Times New Roman</li>
	<li unselectable=on onclick="insert('Verdana');" style="font-family:Verdana">Verdana</li>
	<li unselectable=on onclick="insert('Impact');" style="font-family:Impact">Impact</li>
	<li unselectable=on onclick="insert('Wingdings');" style="font-family:Wingdings">Wingdings</li>
	</ul>
	</div>
	</div>
</td>
<td class=ico>
	<div class="layer_item" unselectable=on>
	<div class="layer_icon_title"><a href="javascript:;" onclick="return false"><img src="<%=DEF_BBS_HomeUrl%>images/blank.gif" class="a_pic" style="background-position:0px -462px;" title="字号" /></a></div>
	<div class="layer_iteminfo" onclick="this.style.display='none';">
	<ul class="menu_list">
	<li unselectable=on class="menuhead">文字大小</li>
	<li unselectable=on onclick="addcontent(3,'font-size:8px;');" style="font-size:8px;">8</li>
	<li unselectable=on onclick="addcontent(3,'font-size:9px;');" style="font-size:9px;">9</li>
	<li unselectable=on onclick="addcontent(3,'font-size:10px;');" style="font-size:10px;">10</li>
	<li unselectable=on onclick="addcontent(3,'font-size:11px;');" style="font-size:11px;">11</li>
	<li unselectable=on onclick="addcontent(3,'font-size:12px;');" style="font-size:12px;">12</li>
	<li unselectable=on onclick="addcontent(3,'font-size:14px;');" style="font-size:14px;">14</li>
	<li unselectable=on onclick="addcontent(3,'font-size:16px;');" style="font-size:16px;">16</li>
	<li unselectable=on onclick="addcontent(3,'font-size:18px;');" style="font-size:18px;">18</li>
	<li unselectable=on onclick="addcontent(3,'font-size:20px;');" style="font-size:20px;">20</li>
	<li unselectable=on onclick="addcontent(3,'font-size:22px;');" style="font-size:22px;">22</li>
	<li unselectable=on onclick="addcontent(3,'font-size:24px;');" style="font-size:24px;">24</li>
	<li unselectable=on onclick="addcontent(3,'font-size:26px;');" style="font-size:26px;">26</li>
	<li unselectable=on onclick="addcontent(3,'font-size:28px;');" style="font-size:28px;">28</li>
	<li unselectable=on onclick="addcontent(3,'font-size:36px;');" style="font-size:36px;">36</li>
	<li unselectable=on onclick="addcontent(3,'font-size:48px;');" style="font-size:48px;">48</li>
	<li unselectable=on onclick="addcontent(3,'font-size:72px;');" style="font-size:72px;">72</li>
	<!--
	<li unselectable=on onclick="addcontent(0,'size','/size','8px');" style="font-size:8px;">8</li>
	<li unselectable=on onclick="addcontent(0,'size','/size','9px');" style="font-size:9px;">9</li>
	<li unselectable=on onclick="addcontent(0,'size','/size','10px');" style="font-size:10px;">10</li>
	<li unselectable=on onclick="addcontent(0,'size','/size','11px');" style="font-size:11px;">11</li>
	<li unselectable=on onclick="addcontent(0,'size','/size','12px');" style="font-size:12px;">12</li>
	<li unselectable=on onclick="addcontent(0,'size','/size','14px');" style="font-size:14px;">14</li>
	<li unselectable=on onclick="addcontent(0,'size','/size','18px');" style="font-size:18px;">16</li>
	<li unselectable=on onclick="addcontent(0,'size','/size','18px');" style="font-size:18px;">18</li>
	<li unselectable=on onclick="addcontent(0,'size','/size','20px');" style="font-size:20px;">20</li>
	<li unselectable=on onclick="addcontent(0,'size','/size','22px');" style="font-size:22px;">22</li>
	<li unselectable=on onclick="addcontent(0,'size','/size','24px');" style="font-size:24px;">24</li>
	<li unselectable=on onclick="addcontent(0,'size','/size','26px');" style="font-size:26px;">26</li>
	<li unselectable=on onclick="addcontent(0,'size','/size','28px');" style="font-size:28px;">28</li>
	<li unselectable=on onclick="addcontent(0,'size','/size','36px');" style="font-size:36px;">36</li>
	<li unselectable=on onclick="addcontent(0,'size','/size','48px');" style="font-size:48px;">48</li>
	<li unselectable=on onclick="addcontent(0,'size','/size','72px');" style="font-size:72px;">72</li>-->
	</ul>
	</div>
	</div>
	</td>
<td width=23 class=ico><a href=#ic title=加粗 onclick="addcontent(0,'B','/B');" class="a_pic" style="background-position:0px -242px;"></a></td>
<td width=23 class=ico><a href=#ic title=斜体 onclick="addcontent(0,'I','/I');" class="a_pic" style="background-position:0px -726px;"></a></td>
<td width=23 class=ico><a href=#ic title=下划线 onclick="addcontent(0,'U','/U');" class="a_pic" style="background-position:0px -330px;"></a></td>
<td width=23 class=ico><a href=#ic title=中划线 onclick="addcontent(0,'STRIKE','/STRIKE');" class="a_pic" style="background-position:0px -440px;"></a></td>
<td><div class="a_pic" style="background-position:0px -638px;width:10px;height:16px;"></div></td><td>
<td width=23 class=ico><a href=#ic title=剪切 onclick="addcontent(2,'cut');" class="a_pic" style="background-position:0px -132px"></a></td>
<td width=23 class=ico><a href=#ic title=复制 onclick="addcontent(2,'copy');" class="a_pic" style="background-position:0px -176px"></a></td>
<td width=23 class=ico><a href=#ic title=常规粘贴 onclick="addcontent(2,'paste');" class="a_pic" style="background-position:0px -572px;"></a></td>
<td width=23 class=ico><a href=#ic title=删除 onclick="addcontent(2,'delete');" class="a_pic" style="background-position:0px -110px"></a></td>
<td width=23 class=ico><a href=#ic title=清除样式 onclick="addcontent(2,'RemoveFormat');" class="a_pic" style="background-position:0px -506px;"></a></td>
<td><div class="a_pic" style="background-position:0px -638px;width:10px;height:16px;"></div></td><td>
<td width=23 class=ico><a href=#ic title=撤消 onclick="addcontent(2,'undo');" class="a_pic" style="background-position:0px -308px;"></a></td>
<td width=23 class=ico><a href=#ic title=恢复 onclick="addcontent(2,'redo');" class="a_pic" style="background-position:0px -528px;"></a></td>
<td><div class="a_pic" style="background-position:0px -638px;width:10px;height:16px;"></div></td><td>
<td width=23 class=ico><a href=#ic title=引用 onclick="insert('quote');" class="a_pic" style="background-position:0px -550px;"></a></td>
<td width=23 class=ico><a href=#ic title=代码 onclick="insert('code');" class="a_pic" style="background-position:0px -220px;"></a></td>
<td><div class="a_pic" style="background-position:0px -638px;width:10px;height:16px;"></div></td><td>
<td width=23 class=ico><a href=#ic title=插入特殊字符 onclick="editor_view(this,'editor_symbol','symbol.asp?id=56','symbol.js?id=31');" class="a_pic" style="background-position:0px -374px;"></a></td>
<td width=23 class=ico><a href=#ic title=插入分隔线 onclick="addcontent(0,'hr');" class="a_pic" style="background-position:0px 0px"></a></td>
<td width=23 class=ico><a href=#ic title=全屏切换 id="editor_fullscr" class="a_pic" style="background-position:0px -792px"></a></td>
</tr></table></td>
</tr></table>
<table border=0 cellpadding=0 cellspacing=0 width=100%>
<tr height=29>
<td>
<table border=0 cellpadding=0 cellspacing=0><tr height=29 align=center>
<td width=23 class=ico><a href=#ic title=插入表情 onclick="editor_view(this,'editor_icon','','icon.asp');" class="a_pic" style="background-position:0px -88px"></a></td>
<td width=23 class=ico><a href=#ic title=左对齐 onclick="addcontent(0,'ALIGN','/ALIGN','left');" class="a_pic" style="background-position:0px -682px;"></a></td>
<td width=23 class=ico><a href=#ic title=居中对齐 onclick="addcontent(0,'ALIGN','/ALIGN','center');" class="a_pic" style="background-position:0px -704px;"></a></td>
<td width=23 class=ico><a href=#ic title=右对齐 onclick="addcontent(0,'ALIGN','/ALIGN','right');" class="a_pic" style="background-position:0px -660px;"></a></td>
<td><div class="a_pic" style="background-position:0px -638px;width:10px;height:16px;"></div></td><td>
<td width=23 class=ico><a href=#ic title=编号 onclick="addcontent(2,'insertorderedlist');" class="a_pic" style="background-position:0px -748px;"></a></td>
<td width=23 class=ico><a href=#ic title=项目符号 onclick="addcontent(2,'insertunorderedlist');" class="a_pic" style="background-position:0px -770px;"></a></td>
<td width=23>
	<div class="layer_item">
	<div class="layer_icon_title"><a href="javascript:;" onclick="return false"><img src="<%=DEF_BBS_HomeUrl%>images/blank.gif" class="a_pic" style="background-position:0px -616px;" title="行距" /></a></div>
	<div class="layer_iteminfo" id="menu_info_lineheight" onclick="this.style.display='none';">
	<ul class="menu_list">
	<li unselectable=on onclick="addcontent(3,'line-height','1');">100%</li>
	<li unselectable=on onclick="addcontent(3,'line-height','0.5');">50%</li>
	<li unselectable=on onclick="addcontent(3,'line-height','1.5');">150%</li>
	<li unselectable=on onclick="addcontent(3,'line-height','2');">200%</li>
	<li unselectable=on onclick="addcontent(3,'line-height','2.5');">250%</li>
	<li unselectable=on onclick="addcontent(3,'line-height','3');">300%</li>
	<li unselectable=on onclick="addcontent(3,'line-height','4');">400%</li>
	</ul>
	</div>
	</div>

</td>
<td><div class="a_pic" style="background-position:0px -638px;width:10px;height:16px;"></div></td><td>
<td width=23 class=ico><a href=#ic title=上标 onclick="addcontent(0,'SUP','/SUP');" class="a_pic" style="background-position:0px -396px;"></a></td>
<td width=23 class=ico><a href=#ic title=下标 onclick="addcontent(0,'SUB','/SUB');" class="a_pic" style="background-position:0px -418px;"></a></td>
<td><div class="a_pic" style="background-position:0px -638px;width:10px;height:16px;"></div></td><td>
<td width=23 class=ico><a href=#ic title=字体颜色 onclick="editor_sAction = 'forecolor';editor_view(this,'editor_selcolor','','selcolor.js');" class="a_pic" style="background-position:0px -66px"></a></td>
<td width=23 class=ico><a href=#ic title=字体背景颜色 onclick="editor_sAction = 'backcolor';editor_view(this,'editor_selcolor','','selcolor.js');" class="a_pic" style="background-position:0px -264px;"></a></td>
<td><div class="a_pic" style="background-position:0px -638px;width:10px;height:16px;"></div></td><td>
<td width=23 class=ico><a href=#ic title=插入或修改超级链接 onclick="edt_link();" class="a_pic" style="background-position:0px -154px"></a></td>
<td width=23 class=ico><a href=#ic title=取消超级链接或标签 onclick="addcontent(2,'UnLink');" class="a_pic" style="background-position:0px -286px;"></a></td>
<td><div class="a_pic" style="background-position:0px -638px;width:10px;height:16px;"></div></td><td>
<td width=23 class=ico><a href=#ic unselectable=on title=插入或修改表格 onclick="if(typeof(editor_inittable)=='function')editor_inittable();editor_view(this,'editor_insttable','table.asp','table.js');" class="a_pic" style="background-position:0px -352px;"></a></td>
<td width=23 class=ico><a href=#ic title=插入或修改图片 onclick="if(typeof(editor_InitimgDocument)=='function')editor_InitimgDocument();editor_view(this,'editor_img','img.asp','img.js');" class="a_pic" style="background-position:0px -22px"></a></td>
<td width=23 class=ico><a href=#ic title=插入多媒体 onclick="if(typeof(editor_Initmedia)=='function')editor_Initmedia();editor_view(this,'editor_media','media.asp?0','media.js?0');" class="a_pic" style="background-position:0px -594px;"></a></td>
<td><div class="a_pic" style="background-position:0px -638px;width:10px;height:16px;"></div></td><td>
<td class=ico>
	<div class="layer_item">
	<div class="layer_icon_title"><a href="javascript:;" onclick="return false"><img src="<%=DEF_BBS_HomeUrl%>images/blank.gif" width="22" height="22" title="炫彩字" class="a_pic" style="background-position:0px -814px" /></a></div>
	<div class="layer_iteminfo" id="menu_info_face" onclick="this.style.display='none';">
	<ul class="menu_list">
	<li unselectable=on class="menuhead">文字秀</li>
	<li unselectable=on onclick="addcontent(0,'tshow','/tshow','2,22,12,#056f34');"><img src=<%=DEF_BBS_HomeUrl%>images/font/font_2_demo.png></li>
	<li unselectable=on onclick="addcontent(0,'tshow','/tshow','1,40,14,#9b1916');"><img src=<%=DEF_BBS_HomeUrl%>images/font/font_1_demo.png></li>
	<li unselectable=on onclick="addcontent(0,'FLY','/FLY');">飞行</li>
	<li unselectable=on onclick="addcontent(0,'SHADOW','/SHADOW','2,gray,2');">阴影字</li>
	</ul>
	</div>
	</div>
</td>
</tr></table></td></tr></table>

<%End If%>
</td></tr>
</table>
</div>

<div class=editor>
<textarea tabindex="3" cols=80 style="width: 100%;height:220px; word-break: break-all;" id=Form_Content name=Form_Content rows=16 ONSELECT="storeCaret(this);" onclick="storeCaret(this);" ONKEYUP="storeCaret(this);" onkeydown="if(ctlkey(event)==false)return(false);"><%If Form_Content <> "" Then Response.Write VbCrLf & Server.htmlEncode(Form_Content)%></textarea></div>
<div class=editor_choose><table border="0" cellPadding="0" cellSpacing="0" width="100%">
	<tr>
	<td align="left" valign="top">
	<div id="LEADEDT_TXT" style="display:block;">
	<map name="LEADEDT_Map1">
	<area shape="polygon" coords="5, 3, 12, 14, 43, 14, 49, 6, 43, 0" alt="纯文本和编码编辑模式" onclick="edt_setmode(1);">
	<area shape="polygon" coords="87, 14, 91, 5, 87, 0, 50, 0, 46, 9, 49, 14" alt="HTML代码编辑模式" onclick="edt_setmode(0);">
	</map> <img src="<%=DEF_BBS_HomeUrl%>images/blank.gif" class="a_editmode a_modeedit" usemap="#LEADEDT_Map1" border="0"></div>

	<div id="LEADEDT_EDIT" style="display:none">
	<map name="LEADEDT_Map2">
	<area shape="polygon" coords="5, 3, 12, 14, 43, 14, 49, 6, 43, 0" alt="纯文本和编码编辑模式" onclick="edt_setmode(1);">
	<area shape="polygon" coords="87, 14, 91, 5, 87, 0, 50, 0, 46, 9, 49, 14" alt="HTML代码编辑模式" onclick="edt_setmode(0);">
	</map> <img src="<%=DEF_BBS_HomeUrl%>images/blank.gif" class="a_editmode a_modetext" usemap="#LEADEDT_Map2" border="0"></div>
	</td>
	<td align=right>
	<span style="display:block" class="a_editcollapse" src="<%=DEF_BBS_HomeUrl%>images/blank.gif"></span>
	<div style="position:fixed;left:100px;top:100px;color:#fff;display:block;background:#000;" id="test"></div>
	<script>

	$(".a_editcollapse").mousedown(function(event){
	LD.editcollapse.mousedown(this,event);
	});
	
LD.editcollapse = {
	posX:0,
	posY:0,
	fdiv:null,
	oldX:-999,
	oldY:-999,
	divH:0,
	oldcpseY:0,
	oldEditorY:0,
	fm:0,
	mousedown:function(div,e)
	{
		$("body").attr("unselectable","on").css("user-select","none");
		oldX=e.clientX;
		oldY=e.clientY;
		divH = $(".editor").height();
		oldcpseY = LD.getY($(".a_editcollapse")[0],"abs");
		oldEditorY = LD.getY($("#LEADEDT")[0],"abs");
		if(!oldEditorY||oldEditorY==0)oldEditorY = LD.getY($("#Form_Content")[0],"abs");
		if(!e) e = window.event;
		var tar=e.srcElement||e.target;
		if(tar)
		if(tar.tagName)
		if("|input|a|img|".indexOf("|" + tar.tagName.toLowerCase() + "|")!=-1)return;
		LD.editcollapse.fdiv = div;
		LD.editcollapse.id=div.id;
		LD.editcollapse.posX = e.clientX - LD.getX(div,"abs");
		LD.editcollapse.posY = e.clientY - LD.getY(div,"abs");
		$(edt_doc).bind("mousemove",function(event){LD.fm=1;window.parent.LD.editcollapse.mousemove(event)});
		$(document).bind("mousemove",function(event){LD.fm=0;LD.editcollapse.mousemove(event)});
		edt_doc.onmouseup = document.onmouseup = function()
		{
			document.onmousemove = edt_doc.onmousemove = null;
			$(edt_doc).unbind("mousemove");
			$(document).unbind("mousemove");
			$("body").attr("unselectable","off").css("user-select","inherit");
		}
	},

	mousemove:function(ev)
	{
		if(ev==null) ev = window.event;
		var sT = $(document).scrollTop();
		var cY = (LD.fm==0)?ev.clientY:ev.clientY+(oldEditorY-sT);
		var v = ev.clientY - oldcpseY;
		v = cY-(oldcpseY-sT);
		v = divH+v-parseInt($(".a_editcollapse").height()/2);
		if(v<40||v>800)return;
		if(oldY!=ev.clientY)
		{$(".editor").css("height",(v)+"px");
		$(edt_htmobj).css("height",(v)+"px");
		$(edt_txtobj).css("height",(v)+"px");}
	}
};

var editor_isfull = 0,old_overflow,old_editor_top_w,old_editor_w,old_editor_h;

$("#editor_fullscr").click(function(){
		$(LD.mnu_cureWin).hide();
		$("#editor_selcolor").hide();
	if(Browser.ie6||Browser.ie7){alert("\u0049\u0045\u6D4F\u89C8\u5668\u7248\u672C\u8FC7\u65E7\uFF0C\u8BF7\u5347\u7EA7\u3002");
	return;}
	if($("body").css("width")=="0px")
	{
		$("body").css({"width": "auto",
		"height": "auto",
		"overflow": old_overflow,
		"position": "static",
		"z-index": "auto"});
		
		$(".editor_top").css({"position":"static",
		"width":old_editor_top_w,
		"height":"auto",
		"z-index": "auto",
		"left":"0px",
		"top":"0px"});
		
		$(".editor").css({"position":"static",
		"width":old_editor_w,
		"height":old_editor_h,
		"z-index": "auto",
		"left":"0px",
		"top":"0px"});
		$(edt_htmobj).css("height",old_editor_h);
		$(edt_txtobj).css("height",old_editor_h);
		editor_isfull = 0;
		$(window).unbind("resize");
		$(".layer_onclickitem").css({"position":"absolute",
		"z-index": "1"
		});
		$("#editor_selcolor").css("z-index","2");
		$(".layer_iteminfo").css("z-index","1");
		$(".ld_alert").css("z-index","auto");
		window.alert = new_alert;
		
		return;
	}
	
	old_overflow = $("body").css("overflow");
	old_editor_top_w = $(".editor_top").css("width");
	old_editor_w = $(".editor").css("width");
	old_editor_h = $(".editor").css("height");
	$(window).resize(function(){editor_resize()});
	var editor_resize = function()
	{
		$("body").css({"width": "0px",
		"height": "0px",
		"overflow": "hidden",
		"position": "static",
		"z-index": "9995"});
		
		$(".editor_top").css({"position":"fixed",
		"width":"100%",
		"height":"auto",
		"z-index": "9995",
		"left":"0px",
		"top":"0px"});
		
		var h = parseInt($(".editor_top").css("padding-top").replace(/px/gi,""))+parseInt($(".editor_top").css("padding-bottom").replace(/px/gi,""));
		var w = parseInt($(".editor").css("padding-left").replace(/px/gi,""))+parseInt($(".editor").css("padding-right").replace(/px/gi,""));
		var rh = parseInt($(".editor").css("padding-top").replace(/px/gi,""))+parseInt($(".editor").css("padding-bottom").replace(/px/gi,""));
		var th = ($(window).height()-2-($(".editor_top").height()+h+rh))+"px";
		$(".editor").css({"position":"fixed",
		"width":($(window).width()-w)+"px",
		"height":th,
		"z-index": "6666",
		"left":"0px",
		"top":($(".editor_top").height()+h)+"px"});
		$(edt_htmobj).css("height",th);
		$(edt_txtobj).css("height",th);
		$(".layer_onclickitem").css({"position":"fixed",
		"z-index": "9996"
		});
		
		$(".layer_iteminfo").css("z-index","9996");
		$("#editor_selcolor").css("z-index","9997");
		$(".ld_alert").css("z-index","9999");
		window.alert = old_alert;
		editor_isfull = 1;
	}
	
	editor_resize();
});

	</script>
	</td>
	</tr>
	</table>
</div>
<%End Sub%>
