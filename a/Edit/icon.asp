<% @codepage=65001 EnableSessionState=False%>
<%Option Explicit
%>
<!--#include file="../../inc/UBBCode_Setup.asp"-->
var iconp = -1;
var iconCookie = 1;
<%
Dim reqflag
If Request.queryString("f") = "msg" Then
	reqflag = 1
Else
	reqflag = 0
end If
If DEF_UbbIconGNum >= 1 Then
	%>
	var icon_start=<%=DEF_UbbIconMin(0)%>;
	var icon_end=<%=DEF_UbbIconMax(0)%>;
	<%
Else
	%>
	var icon_start=1;
	var icon_end=<%=DEF_UBBiconNumber%>;
	<%
End If%>;
var icon_index=1;
var iconnum = icon_end-icon_start+1;
var iconmp = ((iconnum%16)==0)?parseInt(iconnum/16)-1:parseInt(iconnum/16);
var edt_face_pg = 16;
var icon_layer;

function icon_set(i,min,max)
{
	if(icon_index==i)return;
	icon_start = min;
	icon_end = max;
	icon_index = i;
	iconnum = max-min+1;
	iconmp = ((iconnum%16)==0)?parseInt(iconnum/16)-1:parseInt(iconnum/16);
	IconPage(0);
	IconPageLst();
	LD.Cookie.Add(DEF_MasterCookies + "_iconG",i);
}

function IconLoad(elm)
{
	elm.onload=null;
	if(Browser.safari || Browser.is_ie_lower || Browser.ie6 )
	{
		if (elm.width>32) {
		 var oldVW = elm.width,oldVH=elm.height*(32 /oldVW); elm.width=32; elm.height = oldVH; }
		 if (elm.height>32) { var oldVH = elm.height,oldVW=elm.width*(32 /oldVH); elm.height=32; elm.width = oldVW; }
	}
}

function IconPage(pn)
{
	if(isUndef(pn)){iconp ++ ;}else{iconp=pn;}
	if(iconp<0)iconp=0;
	if(iconp>iconmp)iconp=0;
	var n,m=iconp*edt_face_pg+edt_face_pg,str,t;
	if(m>iconnum)m=iconnum;
	str = "";
	for(n=iconp*edt_face_pg+icon_start;n<m+icon_start;n++)
	{
		if(n<10){t="0"+n;}else{t=n;}
		str+="<div class=\"icon_min\"";
		if(Browser.safari||Browser.safari3)str+=" style=\"border:1px #cccccc solid;width:34px;height:34px;cursor:pointer;float:left;text-align:center;margin:1px;\""
		str+=" onclick=\"edt_icon('" + t + "');<%If reqflag <> 1 Then%>LD.hide(\'editor_icon\');<%End If%>\"><table><tr><td align=center><img onload=\"IconLoad(this);\" src=\"../images/UBBicon/em" + t + ".GIF\"";
		str+="></td></tr></table></div><div class=\"icon_min_value\"><img src=\"../images/UBBicon/em" + t + ".GIF\" /></div>";
	}
	str+="";
	$id("Icon0").innerHTML=str;
	icon_layer = null;
	icon_layer = new LayerMenu('icon_min','icon_min_value','prompt');
}

function IconPageLst()
{
	var s="";
	if(iconmp>0)
	for(var n=0;n<=iconmp;n++)
	s+="<a href=#icon onclick=\"IconPage(" + n + ");\" class=j_page>" + (n + 1) + "</a>";
	if(iconmp>0)s+="<a href=#icon onclick=\"IconPage();\">…</a>";
	$id('j_page_icon').innerHTML=s;
	$id('j_page_icon').style.display=iconmp>0?'':'none';
	
}

function IconInitSel()
{
	var T = $id('menu_info_icon');
	if(T)
	{
		iconCookie = LD.Cookie.Get(DEF_MasterCookies + "_iconG");
		if(iconCookie!="")
		{
			iconCookie = parseInt(iconCookie);
			if(iconCookie>=1&&iconCookie<=T.options.length){
			T.options[iconCookie-1].selected=true;
			icon_index = 0;
			eval("icon_set("+T.value+");");
			}
		}
	}
}

var wstr='';
wstr+='<table style="width:345px;"><tr style="cursor: move;" onmousedown="LD.move.mousedown($id(\'editor_icon\'),event);"><td colspan=2>';
<%
If DEF_UbbIconGNum >= 1 Then%>

wstr+='<div style="float:left;"><select style="width:110px;" id="menu_info_icon" onchange="eval(\'icon_set(\'+this.value+\');\');">';
<%Dim N
For N = 1 to DEF_UbbIconGNum
	%>
	wstr+='<option value="<%=N%>,<%=DEF_UbbIconMin(N-1)%>,<%=DEF_UbbIconMax(N-1)%>"><%=DEF_UbbIconG(N-1)%></option>';
	<%
	Next
%>
wstr+='</select></div>';
<%Else%>
	wstr+='插入<a href=<%=DEF_BBS_HomeUrl%>User/Help/Ubb.asp?icon target=_blank>表情</a>';
<%End If%>
<%If reqflag <> 1 Then
%>wstr+='<div class="layer_close"><a href="javascript:;" onclick="LD.hide(\'editor_icon\');return false;" class="unsel" hidefocus="true" title="close" /></a></div>';<%
End If%>
wstr+='</td><tr><td align=left valign=top>';
wstr+='<table border="0" cellspacing="0" cellpadding="0"><tr><td>';
wstr+='<span class=j_page id="j_page_icon"></span>';
wstr+='</td></tr></table>';
wstr+='<hr class=splitline><div id=Icon0></div></td></tr></table>';
if($id('editor_icon'))$id('editor_icon').innerHTML = wstr;
IconInitSel();
layer_initselect();
IconPageLst();
IconPage();