<%
Sub cms_DisplayUserCenter(info)

	%>
	<script language="JavaScript" type="text/javascript">
	function swap_view(str,sobj)
	{
		var obj=$id(str);
		obj.style.display=(obj.style.display=='none'?'':'none');
		sobj.className=(sobj.className=='swap_collapse'?'swap_open':'swap_collapse');
	}
	</script>
	<%
	%>
			<div class="user_itemlist">
			<%If Check_jdsupervisor() = 1 Then%>
			<div class="swap_collapse" onclick="swap_view('master_part_4',this);"><span>总管理员</span></div>
			<ul id="master_part_4">
			<li><a href="<%=DEF_BBS_HomeUrl%>article/center.asp?action=newsclass&list=1"><div class=ttt>分类管理</div></A></li>			
			<li><a href="<%=DEF_BBS_HomeUrl%>article/center.asp?action=newsclass"><div class=ttt>分类添加</div></A></li>
			<li><hr class=splitline></li>
			<li><a href="<%=DEF_BBS_HomeUrl%>article/center.asp?action=newsarticle"><div class=ttt>文章添加</div></A></li>
			<li><a href="<%=DEF_BBS_HomeUrl%>article/center.asp?action=newsmanage"><div class=ttt>文章管理</div></A></li>
			<li><hr class=splitline></li>
			<li><a href="<%=DEF_BBS_HomeUrl%>article/center.asp?action=setchannel"><div class=ttt>设置首页栏目内容</div></A></li>
			<li><a href="<%=DEF_BBS_HomeUrl%>article/center.asp?action=editfile&form_fileid=0"><div class=ttt>编辑首页图片新闻</div></A></li>
			<li><a href="<%=DEF_BBS_HomeUrl%>article/center.asp?action=editfile&form_fileid=1"><div class=ttt>自定义网站底部信息</div></A></li>
			<li><a href="<%=DEF_BBS_HomeUrl%>article/center.asp?action=editfile&form_fileid=2"><div class=ttt>CSS样式表</div></A></li>
			<li><hr class=splitline></li>
			<li><a href="<%=DEF_BBS_HomeUrl%>article/center.asp?action=updatecache"><div class=ttt>立即更新系统缓存</div></A></li>
			</ul>
			<%
			end if%>
			</div>
	<%

End Sub

Function cms_DisplayLoginForm(title)

	response.Write "<span class=cms_error>权限不足！</span>"

End Function

Sub cms_manage_Navigate(Str)

	If Str = "" Then exit sub
	%>
	
		<div class="navigate_sty">
			<div class="navigate_string">
			<a name=home>当前位置：</a>
			<%
			Response.Write "<a href=" & DEF_BBS_HomeUrl & "index.asp target=_blank><span class=""navigate_string_home"">CMS首页</span></a>"
			
			Response.write Str%>
		</div>
	</div>
	<%

End Sub

Sub UserTopicTopInfo(info)

	
%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="user_table">
	<tr>
		<td valign="top" class="tdright">

<%End Sub

Sub cms_UserTopicBottomInfo

%>		</td>
	</tr>
	</table><%

End Sub

Sub article_center_Head(headString)
	
	Dim Temp
	GetStyleInfo()
	%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
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
		End If%> - <%=headString%>
	</title>
	<link rel="stylesheet" id="css" type="text/css" href="<%=DEF_BBS_homeUrl%>article/inc/default.css" title="cssfile" />
	<script type="text/javascript">
	<!--
	var DEF_MasterCookies = "<%=htmlencode(DEF_MasterCookies)%>";
	var GBL_Style = "<%=GBL_Board_BoardStyle%>";
	-->
	</script>
	<script src="<%=DEF_BBS_HomeUrl%>inc/js/jquery.js" type="text/javascript"></script>
	<script src="<%=DEF_BBS_HomeUrl%>inc/js/common.js" type="text/javascript"></script>
	
	<link rel="stylesheet" type="text/css" href="<%=DEF_BBS_HomeUrl%>inc/js/easyui/easyui.css">
	<script type="text/javascript" src="<%=DEF_BBS_HomeUrl%>inc/js/jquery.easyui.js"></script>

</head>
<body id="body">
<iframe name="hidden_frame" id="hidden_frame" style="display:none"></iframe>

	<%

End Sub

Sub cms_center_Bottom

	%>
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

Function Update_CheckSetupRIDExist(RID,extend)

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select ID,RID,ValueStr,ClassNum,SaveData from LeadBBS_Setup where RID=" & RID & extend,1),0)
	If Rs.Eof Then
		Update_CheckSetupRIDExist = 0
	Else
		Update_CheckSetupRIDExist = 1
	End If
	Rs.Close
	Set Rs = Nothing

End Function

Sub Update_InsertSetupRID(RID,ValueStr,ClassNum,saveData,extend)

	If Update_CheckSetupRIDExist(RID,extend) = 0 Then
		CALL LDExeCute("insert into LeadBBS_Setup(RID,ValueStr,ClassNum,saveData) values(" & Rid & ",'" & Replace(ValueStr,"'","''") & "'," & ClassNum & ",'" & Replace(saveData,"'","''") & "')",1)
	Else
		CALL LDExeCute("Update LeadBBS_Setup Set ValueStr='" & Replace(ValueStr,"'","''") & "',ClassNum=" & ClassNum & ",saveData='" & Replace(saveData,"'","''") & "' where RID=" & RID & extend,1)
	End If

End Sub%>