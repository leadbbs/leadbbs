<!--#include file="cms_setup.asp"-->
<!--#include file="splitpage_fun.asp"-->
<!--#include file="form_fun.asp"-->
<!--#include file="sideinfo_fun.asp"-->
<!--#include file="../../inc/ubbcode.asp"-->
<!--#include file="cache_fun.asp"-->
<%
Const article_SiteName = "论坛综合信息"
Dim DEF_pageHeader : DEF_pageHeader = "<" & "%" & "@ LANGUAGE=" & "VBScript CodePage=65001%" & ">" & VbCrLf & "<" & "%Response.Charset = ""utf-8""%" & ">"
dim Form_UpFlag,init_Upload
Form_UpFlag = 0
init_Upload = 0

If Request.QueryString("dontRequestFormFlag") = "" Then
		Form_UpFlag = 0
Else
	Form_UpFlag = 1
end if

Sub article_SiteHead(headString)
	
	Dim Temp
	GetStyleInfo()
	%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"  xml:lang="zh-CN" lang="zh-CN">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="description" content="<%=htmlencode(DEF_GBL_Description)%>" />
	<title>
		<%
		If DEF_SiteNameString <> "" Then
			Response.Write DEF_SiteNameString
		Else
			Response.Write article_SiteName
		End If
		if headString <> "" then
			response.write " - " & headString
		end if%>
	</title>
	<link rel="stylesheet" id="css" type="text/css" href="<%=DEF_BBS_homeUrl%>article/inc/default<%
	'If GBL_Board_BoardStyle > 0 Then Response.Write GBL_Board_BoardStyle
%>.css" title="cssfile" />
	<script type="text/javascript">
	<!--
	var DEF_MasterCookies = "<%=htmlencode(DEF_MasterCookies)%>";
	var GBL_Style = "<%=GBL_Board_BoardStyle%>";
	-->
	</script>
	<script src="<%=DEF_BBS_HomeUrl%>inc/js/jquery.js" type="text/javascript"></script>
	<script src="<%=DEF_BBS_HomeUrl%>inc/js/common.js" type="text/javascript"></script>

</head>
<body id="body">
<iframe name="hidden_frame" id="hidden_frame" style="display:none"></iframe>
<a name="top"></a>

<div class="area" id="top_area">
<div style="text-align:left;position:relative;">
<a class="cms_logo"></a>

</div>
<div class="cms_loginform" style="">
<%
if GBL_UserID = 0 Then
 %><ul class="list_line">
		<li><a href="<%=DEF_BBS_HomeUrl%>user/<%=DEF_RegisterFile%>">注册</a></li>
		<li><a href="<%=DEF_BBS_HomeUrl%>user/Login.asp" onclick="return(pub_command('登录',this,'anc_delbody','&dir=<%=DEF_BBS_HomeUrl%>'<%
		If GetBinarybit(DEF_Sideparameter,10) = 1 Then
			response.write ",'',560,''"
		end if%>));">登录</a></li>
		</ul>
 <%
Else
	If GBL_CHK_User <> "" Then
		Response.Write "<span class='head_hellowords'>"
		Select Case Hour(DEF_Now)
		Case 0,1:Response.Write "午夜"
		Case 2,3,4:Response.Write "深夜"
		Case 5,6,7:Response.Write "早上"
		Case 8,9,10:Response.Write "上午"
		Case 11,12:Response.Write "中午"
		Case 13,14,15,16,17,18:Response.Write "下午"
		Case 19,20:Response.Write "黄昏"
		Case 21,22,23:Response.Write "晚上"
		End Select
	%>好，
	</span>
	<%	If GBL_CHK_Pass = "" Then%>
			<%=htmlEncode(GetTrueName(GBL_CHK_User,GBL_CHK_TrueName))%> <a href="<%=DEF_BBS_HomeUrl%>User/<%=DEF_RegisterFile%>?action=bind" style="position:relative;" title="您需要绑定或完善帐号信息."><img src="<%=DEF_BBS_HomeUrl%>images/app/<%=GBL_AppType%>.gif" border="0" style="position:absolute;" /><span style="padding-left:18px;">完善/绑定帐号</span></a>
	<%	Else
	%>
	<span class="head_hellouser">
		<%=htmlEncode(GetTrueName(GBL_CHK_User,GBL_CHK_TrueName))%> <%
		if Check_jdsupervisor() = 1 Then%>
		<a href="<%=DEF_BBS_HomeUrl%><%=DEF_ManageDir%>/">[进入管理]</a> 
		<%End if%>
	</span><%
		End If
		If GBL_CHK_Flag = 1 or (GBL_CHK_User <> "" and GBL_AppType <> "") Then
			%><a href="<%=DEF_BBS_HomeUrl%>User/login.asp?action=logout" onclick="return(pub_msg(this,'layer_ajaxmsg','&sure=1','setTimeout(\'document.location.reload();\',1000);'));" class="head_logout">退出</a><%
		End If
	End If
End If

dim classid
classid = tonum(request.querystring("classid"),0)
%>

</div>
</div>
<div class="head_top_out">
	<div class="area">
		<div class="head_top">
				<div class="layer_item3">
				<a class="<%if classid=0 then
						response.write "cms_top_sel"
					else
						response.write "cms_top_item"
					end if%>" href=<%=DEF_BBS_HomeUrl%>index.asp id="nav_indexpage"><span class="head_item_title">首页</span></a>
				</div>
				<%
				dim cmscacheClass
				set cmscacheClass = new cms_cache_Class
				cmscacheClass.CMS_NAVIGATECLASS
				set cmscacheClass = nothing
				'response.write article_view_newsClass("listflag=1 or listflag=2",classid)
%>
				<!--<a class="cms_top_item" href=<%=DEF_BBS_HomeUrl%>boards.asp>论坛</a>	-->

		</div>
	</div>
</div>
	<%

End Sub

Sub cms_DisplayBBSNavigate(Str)

	If Str = "" Then exit sub
	%>
	
	<div class="navigate_sty_out">
	<div class="area">
		<div class="navigate_sty">
			<div class="navigate_string">
			<a name=home>当前位置：</a>
			<%
			Response.Write "<a href=" & DEF_BBS_HomeUrl & "index.asp><span class=""navigate_string_home"">首页</span></a>"
			
			Response.write Str%>
		</div>
	</div>
	</div>
	</div>
	<%

End Sub

sub cms_bodyhead(sideinfo)%>

<div class="area">
<div class="cms_body_box">
<div class="cms_body<%If sideinfo="homepage" then
	response.write "cms_body_homepage"
else
	response.write "cms_body_inpage"
end if%>">
<div class="main">
	<div class="content_side_right" id="p_side">
		<%
		select case sideinfo
			case "homepage":
				call cms_sideinfo_homepage
		end select
		
		%>
	</div>
	<div class="content_main_right">
		<div class="content_main_2_right">
		<div class="content_main_body">
		
<%End Sub


Sub cms_bodyBottom%>


		
		</div>
		</div>
	</div>
</div>
</div>
</div>
</div>

<%End Sub


sub cms_fullbodyhead
	Boards_Body_Head("")
	Global_TableHead()
%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="user_table">
	<tr>
		<td valign="top" class="tdright">

<%End Sub

Sub cms_fullbodyBottom
%>		</td>
	</tr>
	</table><%Global_TableBottom
	Boards_Body_Bottom()
End Sub


Sub cms_SiteBottom

	%>
			<a name="bottom"></a>
			<div class="bottominfo">
				<div class="area">
				<div class="copyright">
					<!--#include file="sitebottom_info.asp"-->
				</div>
				<%PageExeCuteInfo%>
				</div>
			</div>
	<script type="text/javascript">
	<!--
		new LayerMenu('layer_item','layer_iteminfo');
		new LayerMenu('layer_item2','layer_iteminfo2');
		//layer_initselect();
		
		var alls = document.getElementsByTagName('form'); 
		for(var i=0; i<alls.length; i++)
		{
			submit_disable(alls[i],1);
		}
		if (typeof initLightbox == 'function')initLightbox();
	-->
	</script>
	</body>
	</html><%

End Sub


Function requestFormData(name)

	requestFormData = Request.QueryString(name)
	If requestFormData = "" Then requestFormData = GetFormData(name)

End Function

Function GetFormData(name)

	If Form_UpFlag = 0 Then
		GetFormData = Request.form(name)
	Else
		if init_Upload = 1 then GetFormData = Form_UpClass.form(name)
	End If
	If GetFormData = "" Then GetFormData = Request.QueryString(name)

End Function

Function Check_jdsupervisor

	If GBL_CHK_User <> "" and inStr(GBL_CHK_User,",") = 0 and gbl_chk_flag = 1 and inStr(LCase(DEF_SupervisorUserName),"," & LCase(GBL_CHK_User) & ",") > 0 Then
		Check_jdsupervisor = 1
	Else
		Check_jdsupervisor = 0
	End If

End Function%>