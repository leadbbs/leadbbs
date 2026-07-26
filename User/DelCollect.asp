<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="../inc/Board_Popfun.asp"-->
<%
DEF_BBS_HomeUrl = "../"
InitDatabase()
UpdateOnlineUserAtInfo GBL_board_ID,"删除收件信息"
Dim GBL_ID,Form_ID

Dim DelID
DelID = Left(Request("DelID"),14)
If isNumeric(DelID) = 0 or DelID = "" or InStr(DelID,",") > 0 Then DelID = 0
DelID = Fix(cCur(DelID))

If DelID < 0 Then DelID = 0

GBL_CHK_TempStr=""
GBL_ID = GBL_UserID
Form_ID = GBL_ID
Form_ID = cCur(Form_ID)
If Form_ID < 0 Then Form_ID = 0
If Form_ID=0 Then
	GBL_CHK_TempStr = GBL_CHK_TempStr & "你没有登录<br>" & VbCrLf
End If

siteHead("   删除收藏帖子")%>
<script language=javascript>
	window.moveTo(window.screen.width/2-225,window.screen.height/2-18);
</script>
<table align=center border=0 cellpadding=0 cellspacing=0>
<tbody>
<tr> 
	<td height=21 width="650">
	<%
	Dim Rs,SQL,SQLendString,ClearFlag
	If GBL_CHK_TempStr = "" Then
		ClearFlag = Request("ClearFlag")
		If ClearFlag = "dkeJje5" or ClearFlag = "dkeJje6" Then
			If GBL_UserID<1 or CheckSupervisorUserName() = 0 or ClearFlag = "dkeJje5" Then
				SQL = "delete from LeadBBS_CollectAnc where UserID=" & GBL_UserID
			Else
				SQL = "delete from LeadBBS_CollectAnc"
			End If

			If Request.Form("DeleteSureFlag")="dk9@dl9s92lw_SWxl" Then
				%>
				成功删除所有收藏帖子!
				<%
				CALL LDExeCute(SQL,1)
			Else
				%>
				<form name=DellClientForm action=DelCollect.asp method=post>
					<input type=hidden name=DeleteSureFlag value="dk9@dl9s92lw_SWxl">
					<input type=hidden name=ClearFlag value="<%=htmlencode(ClearFlag)%>">
					<input type=hidden name=DelID value="<%=htmlencode(DelID)%>">
					<b><%If GBL_UserID<1 or CheckSupervisorUserName() = 0 or ClearFlag = "dkeJje5" Then%>确认要删除您的所有收藏帖子吗？删除后将不能恢复！<%Else
					%><font color=Red class=redfont>您是管理员，确定要删除所有人的收藏帖子吗，删除后将无法恢复！</font><%End If%></b>
					<p><input type=submit value=确定 class=fmbtn>
					<input type=button value=不删 onclick="javascript:window.close();" class=fmbtn>
				</form>
				<%
			End If
		Else
			If GBL_UserID<1 or CheckSupervisorUserName() = 0 Then
				SQL = sql_select("Select * from LeadBBS_CollectAnc where UserID=" & GBL_UserID & " and id=" & DelID,1)
			Else
				SQL = sql_select("Select * from LeadBBS_CollectAnc where id=" & DelID,1)
			End If
			Set Rs = LDExeCute(SQL,0)
			If Rs.Eof Then
				Rs.Close
				Set Rs = Nothing
				Response.Write "找不到记录！<br>" & VbCrLf
			Else
				Rs.Close
				Set Rs = Nothing
				If Request.Form("DeleteSureFlag")="dk9@dl9s92lw_SWxl" Then
					%>
					成功删除编号为<font color=ff0000 class=redfont><%=DelID%></font>的收藏帖子!
					<%
					CALL LDExeCute("Delete from LeadBBS_CollectAnc where id=" & DelID,1)
				Else
					%>
					<form name=DellClientForm action=DelCollect.asp method=post>
						<input type=hidden name=DeleteSureFlag value="dk9@dl9s92lw_SWxl">
						<input type=hidden name=ClearFlag value="<%=htmlencode(ClearFlag)%>">
						<input type=hidden name=DelID value="<%=htmlencode(DelID)%>">
						<b>确认要删除编号为<font color=ff0000 class=redfont><%=DelID%></font>的收藏帖子吗？</b>
						<p><input type=submit value=确定 class=fmbtn>
						<input type=button value=不删 onclick="javascript:window.close();" class=fmbtn>
					</form>
					<%
				End If
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
<%

closeDataBase()
%>