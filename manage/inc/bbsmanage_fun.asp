<%
Response.Expires = 0 
Response.ExpiresAbsolute = DEF_Now - 1
Response.AddHeader "pragma","no-cache"
Response.AddHeader "cache-control","private" 
Response.CacheControl = "no-cache"

const DEF_NeedAnswer = 1

Dim DEF_pageHeader : DEF_pageHeader = "<" & "%" & "@ LANGUAGE=" & "VBScript CodePage=65001%" & ">" & VbCrLf & "<" & "%Response.Charset = ""utf-8""%" & ">"

Sub displayVerifycode

	Dim Url
	Url = filterUrlstr(Left(Request("dir"),100))
	If Request("dir") = "" Then
		If inStr(Request.ServerVariables("QUERY_STRING"),"dir=") then
			Url = ""
		Else
			Url = DEF_BBS_HomeUrl
		End If
	End If
%>
		<input name="ForumNumber" id="ForumNumber" maxlength="4" value="<%=htmlencode(Session(DEF_MasterCookies & "RndNum_par") & "")%>" onfocus="verify_load(0,'<%=url%>');" class="fminpt input_1" />
		<img src="<%=Url%>images/blank.gif" id="verifycode" align="middle" onclick="verify_load(1,'<%=url%>');" /> 
		<a href="javascript:;" id=verify_click onclick="this.style.display='none';verify_load(1,'<%=url%>');return false;">点此显示验证码</a>
		<noscript>     
		<div class="verifycode"><img src="<%=Url%>User/number.asp?r=1" id="verifycode" class="verifycode" align="middle" onclick="verify_load(1,'<%=url%>');" /></div>
		</noscript>
<%End Sub

Function DisplayLoginForm
%>
	<table class=login_table>
	<tr>
	<td>
	<div class=title>管理员登陆</div>
	<%
	If Request("submitflag") = "" Then
	Else
		Response.Write "<p class=""alert"">" & GBL_CHK_TempStr & "</p>"
	End If
	%>
	<script language="javascript">
	function submitonce(theform)
	{
		if (document.all||document.getElementById)
		{
			for (i=0;i<theform.length;i++)
			{
				var tempobj=theform.elements[i];
				if(tempobj.type.toLowerCase()=="submit"||tempobj.type.toLowerCase()=="reset")
				tempobj.disabled=true;
			}
		}
	}
	</script>
<form action=<%=DEF_BBS_HomeUrl & DEF_ManageDir%>/Default.asp method="post" onSubmit="submitonce(this);" target="_top">
	<div class="value2">用户名　： <input name=user type=text maxlength=20 size=22 value="<%=htmlencode(GBL_CHK_user)%>" class="fminpt input_2"></div>
	<div class="value2">密码　　： <input name=pass type=password maxlength=20 size=22 value="<%'=htmlencode(GBL_CHK_pass)
%>" class="fminpt input_2"></div>
	<%If DEF_NeedAnswer = 1 Then%>
	<div class="value2">问题答案： <input name=MPass type=password maxlength=20 size=22 value="<%'=htmlencode(GBL_CHK_pass)
%>" class="fminpt input_2"> <span class="note">填写找回密码用的答案</span></div>
	<%End If%>
	<div class="value2">验证码　： <%displayVerifycode()%><br>
	<div class="value2">有效期　： <select name="CkiExp" id="CkiExp">
				<option value="-99">安全</option>
				<option value="-1">无效</option>
				<option value="365">一年</option>
				<option value=1>一天</option>
				<option value=2>两天</option>
				<option value=7>一周</option>
				<option value=31>一月</option>
			</select> <span class="note">Cookie保留时间</span>
	</div>
	<div class="splitline"></div>
	<div class="value2">
	　　　　　 <input name=submitflag type=hidden value="ddddls-+++"> <input type=submit value="登录" class="fmbtn">
	<input type=reset value="取消" class="fmbtn">
	</div>
</form>
	</td>
	</tr>
	</table>
<%

End Function


Sub frame_TopInfo

%>
	<div class="frame_body">

<%End Sub

Sub frame_BottomInfo

%>
	</div>
	<div style="height:100px;"></div>
<%

End Sub

Function CheckSupervisorPass

	dim sumitflag,MPass
	if dontRequestFormFlag = "" then
		sumitflag = Request.Form("submitflag")
		MPass = Request.Form("MPass")
	else
		If Session(DEF_MasterCookies & "Manager") <> "manage" Then
			GBL_CHK_Flag = 0
			checkSupervisorPass = 0
			GBL_CHK_TempStr = "操作超时,请重新登录！" & VbCrLf
			Exit Function
		end if
		sumitflag = Request.querystring("submitflag")
		MPass = Request.querystring("MPass")
	end if
	If sumitflag = "ddddls-+++" Then
		dim referer:referer = replace(Cstr(Request.ServerVariables("HTTP_REFERER")),"\","/")
		referer = Mid(referer,instr(referer,"://")+3,len(Cstr(Request.ServerVariables("SERVER_NAME"))))
		If referer <> Cstr(Request.ServerVariables("SERVER_NAME")) Then
			GBL_CHK_Flag = 0
			CheckSupervisorPass = 0
			GBL_CHK_TempStr = "此操作只有管理员才能操作！<br>" & VbCrLf
			Exit Function
		End If
		Dim NumCheck
		NumCheck = CheckRndNumber()
		If NumCheck = 0 Then
			GBL_CHK_Flag = 0
			CheckSupervisorPass = 0
			GBL_CHK_TempStr = "验证码错误！<br>" & VbCrLf
			Exit Function
		End If
	End If

	If GBL_CHK_Flag = 1 and (GBL_CHK_User <> "" and inStr(GBL_CHK_User,",") = 0 and inStr(LCase("," & DEF_SupervisorUserName & ","),"," & LCase(GBL_CHK_User) & ",") > 0) and GBL_UserID > 0 Then
	Else
		GBL_CHK_Flag = 0
		checkSupervisorPass = 0
		GBL_CHK_TempStr = "此功能只有管理员才能操作[1]！<br>" & VbCrLf
		Exit Function
	End If

	If DEF_NeedAnswer = 1 Then
	If Session(DEF_MasterCookies & "Manager") <> "manage" Then
		If CheckUserAnswer(GBL_CHK_User,Left(MPass,22)) = 0 Then
			GBL_CHK_Flag = 0
			checkSupervisorPass = 0
			GBL_CHK_TempStr = "此功能只有管理员才能操作[2]！<br>" & VbCrLf
			Exit Function
		End If
		Session(DEF_MasterCookies & "Manager") = "manage"
	End If
	end if

	GBL_CHK_Flag = 1
	checkSupervisorPass = 1	

End Function

Function CheckRndNumber

	If DEF_EnableAttestNumber = 0 Then
		CheckRndNumber = 1
		Exit Function
	End If

	Dim RndNumber
	RndNumber = Left(Session(DEF_MasterCookies & "RndNum") & "",4)
	If RndNumber = "" Then
		Randomize
		RndNumber = Fix(Rnd*9999)+1
		Session(DEF_MasterCookies & "RndNum") = RndNumber
	End If

	Dim ForumNumber
	ForumNumber = Left(Request.Form("ForumNumber"),4)
	If LCase(RndNumber) = LCase(ForumNumber) Then
		CheckRndNumber = 1
	Else
		CheckRndNumber = 0
	End If
	Randomize

End Function

Function CheckUserAnswer(UserName,Answer)

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select Answer from LeadBBS_User where UserName='" & Replace(UserName,"'","''") & "'",1),0)
	If Rs.Eof Then
		CheckUserAnswer = 0
	Else
		If MD5(Answer) = Rs(0) Then
			CheckUserAnswer = 1
		Else
			CheckUserAnswer = 0
		End If
	End if
	Rs.Close
	Set Rs = Nothing

End Function

Sub Manage_sitehead(headString,classStr)

%>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml"  xml:lang="zh-CN" lang="zh-CN">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="description" content="<%=htmlencode(DEF_GBL_Description)%>" />
	<title>
		<%=Replace(headString,"<","&lt;")%> - Powered by <%=DEF_Version%>
	</title>
	<link rel="stylesheet" id="css" type="text/css" href="<%=DEF_BBS_homeUrl & DEF_ManageDir%>/inc/manage.css" title="managecssfile" />
	<script type="text/javascript">
	<!--
	var DEF_MasterCookies = "<%=htmlencode(DEF_MasterCookies)%>";
	var GBL_Style = "<%=GBL_Board_BoardStyle%>";
	-->
	</script>
	<script src="<%=DEF_BBS_HomeUrl%>inc/js/jquery.js" type="text/javascript"></script>
	<script src="<%=DEF_BBS_HomeUrl%>inc/js/common.js" type="text/javascript"></script>
</head>
<body id="body"<%If classStr <> "" Then%> class="<%=classStr%>" scroll="no"<%
Else%><%
End If%>>
<iframe name="hidden_frame" id="hidden_frame" style="display:none"></iframe>
<a name="top"></a>

<%
End Sub

Sub Manage_Sitebottom(flag)

	If flag = "" Then
	%>
	<div class="createtime">
	LeadBBS Copyright <span style="font:11px Tahoma,Arial,sans-serif;">&copy;</span>2003-<%=year(DEF_Now)%>.
	<%
		Response.Write " Page created in " & FormatNumber(cCur(Timer - DEF_PageExeTime1),4,True) & " seconds width " & GBL_DBNum & " queries."
	%>
	</div>
	<%End If%>
	<script type="text/javascript">
	<!--
		if (typeof submit_disable == 'function')
		{
		new LayerMenu('layer_item','layer_iteminfo');
		new LayerMenu('layer_item2','layer_iteminfo2');
		layer_initselect();
		
		var alls = document.getElementsByTagName('form'); 
		for(var i=0; i<alls.length; i++)
		{
			submit_disable(alls[i],1);
		}
		if (typeof initLightbox == 'function')initLightbox();
		}
	-->
	</script>
	</body>
	</html>
	<%

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

End Sub
%>