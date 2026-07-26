<%
Response.Expires = 0 
Response.ExpiresAbsolute = DEF_Now - 1
Response.AddHeader "pragma","no-cache"
Response.AddHeader "cache-control","private" 
Response.CacheControl = "no-cache"

Dim BDM_isBoardMasterFlag,BDM_SpecialPopedomFlag
BDM_isBoardMasterFlag = 0
BDM_SpecialPopedomFlag = 0

Sub CheckisBoardMasterFlag

	If GBL_UserID > 0 and GBL_CHK_Flag=1 Then
		If  GetBinarybit(GBL_CHK_UserLimit,10) = 1 or CheckSupervisorUserName() = 1 Then
			BDM_isBoardMasterFlag = 1
		Else
			GBL_CHK_Flag = 0
			GBL_UserID = 0
		End If
		If BDM_isBoardMasterFlag = 1 and (GetBinarybit(GBL_CHK_UserLimit,12) = 1 or CheckSupervisorUserName() = 1) Then BDM_SpecialPopedomFlag = 1
	Else
		GBL_CHK_Flag = 0
	End If

End Sub

Function DisplayUserCenter(Sel)

	CheckisBoardMasterFlag()
	%>
	<script language="JavaScript" type="text/javascript">
	function swap_view(str,sobj)
	{
		var obj=$id(str);
		obj.style.display=(obj.style.display=='none'?'':'none');
		sobj.className=(sobj.className=='swap_collapse'?'swap_open':'swap_collapse');
	}
	</script>
	<div class="title"><%=DEF_PointsName(6)%><br />Control Pannel</div>
	<%
		If BDM_isBoardMasterFlag = 1 Then%>		
			<div class="user_itemlist">
			<div class="swap_collapse" onclick="swap_view('master_part_1',this);"><span>帖子部分</span></div>
			<ul id="master_part_1">
			<li id="bm_manage_1"><a href="<%=DEF_BBS_HomeUrl%>User/BoardMaster/ClearTopAnc.asp">取消全部总固顶</a></li>
			</ul><%
			If BDM_SpecialPopedomFlag = 1 Then%>
			<div class="swap_collapse" onclick="swap_view('master_part_2',this);"><span>用户部分</span></div>
			<div id="master_part_2">
			<ul>
			<li id="bm_manage_2"><a href="<%=DEF_BBS_HomeUrl%>User/BoardMaster/User/LimitUserManage.asp">限制用户管理</a></li>
			<li id="bm_manage_3"><a href="<%=DEF_BBS_HomeUrl%>User/BoardMaster/User/LimitUserManage.asp?action=specialuser&GBL_Assort=3">屏蔽用户发言</a></li>
			<li id="bm_manage_4"><a href="<%=DEF_BBS_HomeUrl%>User/BoardMaster/User/LimitUserManage.asp?action=specialuser&GBL_Assort=4">禁止用户发言</a></li>
			<li id="bm_manage_5"><a href="<%=DEF_BBS_HomeUrl%>User/BoardMaster/User/LimitUserManage.asp?action=specialuser&GBL_Assort=5">禁止用户修改</a></li>
			<li id="bm_manage_6"><a href="<%=DEF_BBS_HomeUrl%>User/BoardMaster/User/LimitUserManage.asp?action=fobip">屏蔽用户IP地址</a></li>
			<li id="bm_manage_7"><a href="<%=DEF_BBS_HomeUrl%>User/BoardMaster/User/LimitUserManage.asp?action=modifyuser">清理用户资料</a></li>
			</ul>
			<hr class="splitline2">
			<ul>
			<li id="bm_manage_10"><a href="<%=DEF_BBS_HomeUrl%>User/BoardMaster/User/LimitUserManage.asp?action=clear">解除到期用户及屏蔽IP</a>
			</ul>
			</div>
			<%
			End If
			If (GetBinarybit(GBL_CHK_UserLimit,18) = 1 or CheckSupervisorUserName() = 1) Then%>
			<div class="swap_collapse" onclick="swap_view('master_part_3',this);"><span>审核部分</span></div>
			<ul id="master_part_3">
			<li id="bm_manage_8"><a href="<%=DEF_BBS_HomeUrl%>User/BoardMaster/ClearTopAnc.asp?action=1&typeflag=0">先审后看帖</a></li>
			<li id="bm_manage_9"><a href="<%=DEF_BBS_HomeUrl%>User/BoardMaster/ClearTopAnc.asp?action=1&typeflag=1">先看后审帖</a></li>
			</ul>
			<%End If%>
			</div>
			<%
		End If
	If Sel > 0 Then%>
	<script language="JavaScript" type="text/javascript">
	$id("bm_manage_<%=Sel%>").className = "select";
	</script>
<%
	End If

End Function

Function DisplayLoginForm(title)

%>
<div class=title><%=title%></div>
<form action=<%=DEF_BBS_HomeUrl%>User/login.asp method="post" onSubmit="submit_disable(this);">
	<div class=value2>用户名: <input name=user type=text maxlength=20 size=22 value="<%
	If GBL_CHK_user = "" or isNull(GBL_CHK_user) Then
		Response.Write htmlencode(Request("user"))
	Else
		Response.Write htmlencode(GBL_CHK_user)
	End If%>" class='fminpt input_2'>
	<input type=hidden value=<%
	'If Request("submitflag") <> "ddddls-+++" Then
		If Request("u") <> "" Then
			Response.Write htmlencode(Request("u"))
		Else
			Dim HomeUrl,u
			HomeUrl = LD_GetUrl(0)
			u = filterUrlstr(Request.QueryString("u"))
			If Left(u,1) <> "/" and Left(u,1) <> "\" and Left(u,Len(HomeUrl)) <> HomeUrl Then u = ""
			If u = "" Then
				u = Lcase(Request.ServerVariables("HTTP_REFERER"))
				If Left(u,Len(HomeUrl)) <> Lcase(HomeUrl) Then u = ""
				If inStr(u,"/user/login.asp") > 0 Then u = ""
			End If
			Response.Write htmlencode(u)
		End If
	'End If
%> name=u></div>
	<div class=value2>密　码: <input name=pass type=password maxlength=20 size=22 value="<%'=htmlencode(GBL_CHK_pass)
%>" class='fminpt input_2'></div>
	<div class=value2>有效期: <Select name=CkiExp>
			<option value="-99">安全
			<option value="-1">无效
			<option value=31>一月
			<option value="365">一年
			<option value=1>一天
			<option value=2>两天
			<option value=7 selected>一周
		</select> Cookie保留时间
	</div>
	<div class=value2>
	<input name=submitflag type=hidden value="ddddls-+++">
	<input type=submit value="登录" class="fmbtn btn_2"> <input type=reset value="取消" class="fmbtn btn_2">
	<a href=UserGetPass.asp>密码找回</a> <a href=<%=DEF_BBS_HomeUrl%>User/UserGetPass.asp?act=active><span class=redfont>激活账号</span></a>
	</div>
</form>
	<div class=value2>注意：选择安全登录，将不会在您本地硬盘存储任何账户信息</div>
<%
End Function

Sub UserTopicTopInfo(sel)
%>
<div class="area">
<%
	Global_TableHead()
%>

<div class="main user_table">
	<%If GBL_CHK_Flag=1 Then%>
	<div class="content_side_left tdleft" id="p_side"><%DisplayUserCenter(sel)%>
	</div><%End If%>
	<div class="content_main_left">
		<div class="content_main_2_left">
		<div class="content_main_body tdright">
			<div class="tdright_collapse">

<%End Sub

Sub UserTopicBottomInfo

%>			</div></div>
	</div>
	</div>
</div><%Global_TableBottom%>
</div><%

End Sub%>