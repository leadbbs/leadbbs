<!-- #include file=../../inc/BBSsetup.asp -->
<!-- #include file=../../inc/Board_Popfun.asp -->
<!-- #include file=../inc/bbsmanage_Fun.asp -->
<%
DEF_BBS_HomeUrl = "../../"
InitDatabase

Dim GBL_ID,Form_ID

Dim KillID
KillID = Left(Request("KillID"),14)
If isNumeric(KillID) = 0 or KillID = "" or InStr(KillID,",") > 0 Then KillID = 0
KillID = Fix(cCur(KillID))

If KillID < 0 Then KillID = 0

GBL_CHK_TempStr=""
GBL_ID = checkSupervisorPass
Form_ID = GBL_ID
Form_ID = cCur(Form_ID)
If Form_ID < 0 Then Form_ID = 0
If Form_ID=0 or GBL_CHK_Flag<>1 Then
	GBL_CHK_TempStr = GBL_CHK_TempStr & "你没有登录<br>" & VbCrLf
End If
siteHead("   解除屏蔽的ＩＰ地址")
%>
<script language=javascript>
	window.moveTo(window.screen.width/2-225,window.screen.height/2-18);
</script>
<table align=center border=0 cellpadding=0 cellspacing=0>
<tbody>
<tr> 
	<td height=21 width="650">
	<%
	Dim Rs,SQL,SQLendString
	If GBL_CHK_TempStr = "" Then
		SQL = sql_select("Select ID from LeadBBS_ForbidIP where id=" & KillID,1)
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			Rs.close
			Set Rs = Nothing
			Response.Write "找不到记录！<br>" & VbCrLf
		Else
			Rs.close
			Set Rs = Nothing
			If Request.Form("DeleteSureFlag")="dk9@dl9s92lw_SWxl" Then
				%>
				成功删除编号为<font color=ff0000 class=redfont><%=KillID%></font>屏蔽IP段吗!
				<%
				CALL LDExeCute("Delete from LeadBBS_ForbidIP where id=" & KillID,1)
			Else
				%>
				<form name=DellClientForm action=DeleteIP.asp method=post>
					<input type=hidden name=DeleteSureFlag value="dk9@dl9s92lw_SWxl">
					<input type=hidden name=KillID value="<%=htmlencode(KillID)%>">
					<b>确认要删除编号为<font color=ff0000 class=redfont><%=KillID%></font>的屏蔽IP段吗？</b>
					<p><input type=submit value=确定 class=fmbtn>
					<input type=button value=不删 onclick="javascript:window.close();" class=fmbtn>
				</form>
				<%
			End If
		End If
	Else%>
		<table width=96%>
		<tr>
		<td>
		<%Response.Write "<p align=left><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b>"
		Response.Write "</p>"%>
		</td>
		</tr>
		</table>
	<%End If%></td>
</tr>

</table>
<html>
<head>
	<title>
		<%=DEF_SiteNameString%>
	</title>
	<meta HTTP-EQUIV="Content-Type" content="text/html; charset=gb2312">
	<link rel="stylesheet" type="text/css" href="<%=DEF_BBS_homeurl%>/inc/style.css">
</head>
<%

closeDataBase
SiteBottom_Spend
%>