<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass()

Manage_sitehead DEF_SiteNameString & " - 管理员",""

Dim GBL_CTG_DELETEID
GBL_CTG_DELETEID = Left(Request("GBL_CTG_DELETEID"),14)
If isNumeric(GBL_CTG_DELETEID) = 0 Then GBL_CTG_DELETEID = 0
GBL_CTG_DELETEID = cCur(GBL_CTG_DELETEID)
If GBL_CTG_DELETEID < 0 Then GBL_CTG_DELETEID = 0
GBL_CHK_TempStr=""
If GBL_CTG_DELETEID=0 Then
	GBL_CHK_TempStr = GBL_CHK_TempStr & "没有选择要删除的用户<br>" & VbCrLf
End If

frame_TopInfo()
DisplayUserNavigate("删除用户")
If GBL_CHK_Flag=1 Then
	If GBL_CHK_TempStr="" Then
		If Request.Form("DeleteSuer")="E72ksiOkw2" Then
			If DeleteUser(GBL_CTG_DELETEID)>0 Then
				Response.Write "<br><p><font color=008800 class=greenfont><b>已经成功删除ID为" & GBL_CTG_DELETEID & "的用户！</b></font></p>"
				CALL LDExeCute("Update LeadBBS_SiteInfo Set UserCount=UserCount-1",1)
				UpdateStatisticDataInfo -1,1,1
			else
				Response.Write "<br><p><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font></p>"
			End If
		Else
			%>
			<p><form action=UserDelete.asp method=post>
			<b><font color=ff0000 class=redfont>确认信息： 真的要删除此用户吗？如果此用户是<%=DEF_PointsName(8)%>,<br>
			请到相应版面删除此用户版主权限.<br>
			删除用户后，并不删除此用户发表的帖子，但帖子将成为游客发表状态．<br><br>
			<input type=hidden name=GBL_CTG_DELETEID value="<%=urlencode(GBL_CTG_DELETEID)%>">
			<input type=hidden name=DeleteSuer value="E72ksiOkw2">
			
			<input type=button value=不删除 onclick="javascript:history.go(-1);" class=fmbtn>
			<input type=submit value=当然删除 class=fmbtn>
			
			</form>
		<%End If
	Else%>
		<table width=96%>
		<tr>
			<td>
				<%Response.Write GBL_CHK_TempStr%>
			</td>
		</tr>
		</table>
	<%End If
Else
DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

rem 删除某用户
Function DeleteUser(ID)

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select ID,UserName from LeadBBS_User where ID=" & ID,1),0)
	If Rs.Eof Then
		DeleteUser = 0
		Rs.Close
		Set Rs = Nothing
		GBL_CHK_TempStr = GBL_CHK_TempStr & "找不到此用户！<br>" & VbCrLf
	Else
		GBL_CHK_User = Rs("UserName")
		If CheckSupervisorUserName() = 1 Then
			GBL_CHK_TempStr = GBL_CHK_TempStr & "超级管理员不能删除！<br>" & VbCrLf
			Rs.Close
			Set Rs = Nothing
			DeleteUser = 0
			Exit Function
		End If
		Rs.Close
		Set Rs = Nothing
		CALL LDExeCute("delete from LeadBBS_SpecialUser where UserID=" & ID,1)
		CALL LDExeCute("delete from LeadBBS_User where ID=" & ID,1)
		DeleteUser = 1
	End if

End Function%>