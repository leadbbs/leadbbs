<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass()
Const LMT_MaxListLogNum = 300

Manage_sitehead DEF_SiteNameString & " - 管理员",""

frame_TopInfo()
DisplayUserNavigate("论坛日志")
If GBL_CHK_Flag=1 Then
	If Request("clear") = "yes" Then
		ClearForumLog()
	Else
		DisplayForumLog()
	End If
Else
DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

Function DisplayForumLog

	'0-系统日志
	'1-其它日志
	'51-管理员登录日志
	'52-总版主登录日志
	'53-普通版主登录日志
	'54-普通会员登录日志
	'101-版主删除帖子日志
	'102-版主精华帖子日志
	'103-版主转移帖子日志
	'104-版主修改帖子日志
	'105-版主奖罚会员日志
	'106-版主固顶帖子日志
	'151-总版主封除用户日志
	'152-总版主封除IP日志
	'152-总版主强制修改用户资料日志
	'153-总版主强制修改用户资料日志
	'154-总版主总固顶帖子日志
	'201-区版主区固顶帖子日志
	%>
	<script language=javascript>
	var lastID=0,Count=0;
	function s(ID,LogType,LogTime,LogInfo,UserName,IP,BoardID)
	{
		if(ID=="")return;
		Count +=1;lastID=ID;
		if(BoardID==0){BoardID="";}else{BoardID="版面:" + BoardID;}
		LogTime = LogTime.substr(0,4) + "-" + LogTime.substr(4,2) + "-" + LogTime.substr(6,2) + " " + LogTime.substr(8,2) + ":" + LogTime.substr(10,2) + ":" + LogTime.substr(12,2)
		switch(parseInt(LogType))
		{
			case 0: LogType="<span class=greenfont>系统日志</span>";break;
			case 1: LogType="其它日志";break;
			case 9: LogType="论坛动态";break;
			case 51: LogType="管理员登录";break;
			case 52: LogType="<%=DEF_PointsName(6)%>登录";break;
			case 53: LogType="版主登录";break;
			case 54: LogType="普通会员登录";break;
			case 101: LogType="版主删除帖子";break;
			case 102: LogType="版主精华帖子";break;
			case 103: LogType="版主转移帖子";break;
			case 104: LogType="版主修改帖子";break;
			case 105: LogType="版主奖罚会员";break;
			case 106: LogType="版主固顶帖子";break;
			case 151: LogType="<%=DEF_PointsName(6)%>封除用户";break;
			case 152: LogType="<%=DEF_PointsName(6)%>封除IP";break;
			case 153: LogType="<%=DEF_PointsName(6)%>强制修改用户资料";break;
			case 154: LogType="<%=DEF_PointsName(6)%>总固顶帖子";break;
			case 201: LogType="<%=DEF_PointsName(7)%>区固顶帖子";break;
		}
		document.write("<tr><td class=tdbox>" + ID + "<br>" + BoardID + "</td><td class=tdbox>" + LogType + "<br><a href=\"<%=DEF_BBS_HomeUrl%>User/LookUserInfo.asp?name=" + escape(UserName) + "\" target=_blank>" + UserName + "</a></td><td class=tdbox>" + IP + "<br>" + LogTime+"</td><td class=tdbox>" + LogInfo + "</tr>");
	}
	</script>
				<div class=frameline>
				<b><span class=grayfont>最新日志(<%=LMT_MaxListLogNum%>条)</span> <a HREF=ForumLog.asp?clear=yes>清除2天前的论坛日志(至少保留最近的300条日志)</a></b></div>
				<table border=0 cellpadding=0 cellspacing=0 width=100% class=frame_table>
				<tbody>
				<tr class=frame_tbhead>
					<td width=74><div class=value>序号|版面</div></td>
					<td width=90><div class=value>类型/用户</div></td>
					<td width=176><div class=value>IP地址/时间</div></td>
					<td><div class=value>日志信息</div></td>
				</tr>
				<%
	Dim FirstID
	FirstID = Left(Request("ID"),14)
	If isNumeric(FirstID) = 0 Then FirstID = 0
	FirstID = cCur(Fix(FirstID))

	Dim Rs,SQL
	If FirstID = 0 Then
		SQL = sql_select("select ID,LogType,LogTime,LogInfo,UserName,IP,BoardID from LeadBBS_Log Order by id DESC",LMT_MaxListLogNum)
	Else
		SQL = sql_select("select ID,LogType,LogTime,LogInfo,UserName,IP,BoardID from LeadBBS_Log where ID<" & LngStr(FirstID) & " Order by id DESC",LMT_MaxListLogNum)
	End If

	OpenDatabase()
	Set Rs = LDExeCute(SQL,0)
	Dim Num
	Dim GetData
	If Not rs.Eof Then
		Response.Write "<script language=javascript>" & VbCrLf & "s("""
		Response.Write RsGetString(Rs,""",""",""");" & VbCrLf & "s(""","")
		%>","","","");
		</script>
		<%
	Else
		Num = -1
	End If
	Rs.close
	Set Rs = Nothing
	closeDataBase%>
				</table>
				<%If FirstID > 0 Then Response.Write "<a href=ForumLog.asp>返回首页</a> "%>
		<script language=javascript>
			if(Count>=<%=LMT_MaxListLogNum%>)document.write("<a href=ForumLog.asp?id=" + lastID + ">下一页</a>");
		</script>
	<%

End Function

Sub ClearForumLog

	If Request.Form("submitflag") = "yes" then
		Dim SQL,Rs,FilterTime,LogData
		FilterTime = GetTimeValue(DateAdd("d", -2, DEF_Now))
		SQL = sql_select("Select ID,LogTime from LeadBBS_Log order by ID DESC",300)
		Set Rs = LDExeCute(SQL,0)
		If Not Rs.Eof Then
			LogData = Rs.GetRows(-1)
			Rs.Close
			Set Rs = Nothing
			SQL = cCur(LogData(1,Ubound(LogData,2)))
			If SQL < FilterTime Then FilterTime = SQL
		Else
			Rs.Close
			Set Rs = Nothing
		End If
		Response.Write "<p>清除工作将执行以下语句...<p>"
		SQL = "Delete from LeadBBS_Log where LogTime<" & FilterTime
		Response.Write "<p>" & SQL
		Con.CommandTimeout = 120
		CALL LDExeCute(SQL,1)
		Response.Write "<p>执行完毕，成功清除两天前的论坛日志(至少保留最近的300条日志)！"
		Response.Write "<p><a href=ForumLog.asp>点击这里返回查看日志．</a>"
	Else
			%><p><br>
				注意：此功能将完成以下功能：<br><br>
				&nbsp; &nbsp; &nbsp; 1.清除论坛两天之前的论坛日志，清除后将不能恢复日志。<br>
				<br>
				<b><font color=ff0000 class=redfont>确认信息： 真的要开始清除操作么？</font></b><br><br>
				<form action=ForumLog.asp method=post name=LeadBBSFm id=LeadBBSFm>
				<input name=submitflag value=yes type=hidden>
				<input name=clear value=yes type=hidden>
				<input type=button value="点击开始清除" onclick="javascript:LeadBBSFm.submit();this.disabled=true;" class=fmbtn>
				</form>
			<%
	End If

End Sub
%>