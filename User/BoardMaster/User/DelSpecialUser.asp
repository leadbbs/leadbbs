<!--#include file="../../../inc/BBSsetup.asp"-->
<!--#include file="../../../inc/Board_Popfun.asp"-->
<!--#include file="../../../inc/Limit_fun.asp"-->
<!--#include file="../inc/BoardMaster_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../../"
initDatabase()
GBL_CHK_TempStr = ""
CheckisBoardMasterFlag()

siteHead("   解除用户")
If GBL_CHK_Flag=1 and BDM_isBoardMasterFlag = 1 and BDM_SpecialPopedomFlag = 1 Then
	If Request.Form("DeleteSureFlag")="dk9@dl9s92lw_SWxl" Then
		LoginAccuessFul()
	Else
		GBL_UserName = Left(Request("GBL_UserName"),20)
		GBL_Assort = Left(Request("GBL_Assort"),14)
		%>
		<form name=DelSpecialUser.asp action=DelSpecialUser.asp method=post>
			<input type=hidden name=DeleteSureFlag value="dk9@dl9s92lw_SWxl">
			<input type=hidden name=GBL_UserName value="<%=GBL_UserName%>">
			<input type=hidden name=GBL_Assort value="<%=GBL_Assort%>">
			<font color=Red class=redfont>您是<%=DEF_PointsName(6)%>，确定要对用户<%=htmlencode(GBL_UserName)%>进行此操作么！</font></b>
			<p><input type=submit value=确定 class=fmbtn>
			<input type=button value=不删 onclick="javascript:window.close();" class=fmbtn>
		</form>
		<%
	End If
	Response.Write "<font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font>"
Else
	Response.Write "<font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font>"
End If
closeDataBase()
Response.Write "<br>"
SiteBottom_Spend()

Dim GBL_UserName,GBL_Assort,GBL_UserName_UserLimit,GBL_UserName_UserID

Function LoginAccuessFul

	GBL_UserName = Left(Request("GBL_UserName"),20)
	GBL_Assort = Left(Request("GBL_Assort"),14)
	
	If isNumeric(GBL_Assort) = 0 Then GBL_Assort = -1
	GBL_Assort = fix(cCur(GBL_Assort))
	',0-认证会员,1-版主,2-总版主,3-屏蔽会员,4-禁言会员,5-禁修改会员,6-非正式会员
	If GBL_Assort <> 3 and GBL_Assort <> 4 and GBL_Assort <> 5 and GBL_Assort <> 6 Then
		GBL_Assort = -1
	End If

	CheckNewIP()

End Function

Function CheckNewIP

	If CheckWriteEventSpace() = 0 Then
		Response.Write "<b><font color=Red Class=redfont>您的操作过频，请稍候再作提交!</font></b> <br>" & VbCrLf
		Exit Function
	End If
	If GBL_Assort <> 3 and GBL_Assort <> 4 and GBL_Assort <> 5 and GBL_Assort <> 6 Then
		GBL_CHK_TempStr = "错误：会员类型选择错误，请正确选择！"
		Exit function
	End If

	If GBL_UserName = "" Then
		GBL_CHK_TempStr = "错误：用户不存在！"
		Exit function
	End If
		
	If CheckUserNameExist(GBL_UserName) = 0 Then
		Exit function
	End If

End Function

Rem 检测某用户名是否存在
Function CheckUserNameExist(UserName)

	If UserName <> "" and inStr(UserName,",") = 0 and inStr(Lcase(DEF_SupervisorUserName),"," & Lcase(UserName) & ",") > 0 Then
		'作这样的同样提示是为了以防管理员名字被泄漏，实际应该提示管理员不能被屏蔽
		GBL_CHK_TempStr = "错误，用户名" & htmlencode(UserName) & "不存在！"
		CheckUserNameExist = 0
		Exit Function
	End If
	Dim Rs
	Set Rs = LDExeCute(sql_select("Select ID,UserLimit,UserName from LeadBBS_User where UserName='" & Replace(UserName,"'","''") & "'",1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		CheckUserNameExist = 0
		GBL_UserName_UserLimit = 0
		GBL_CHK_TempStr = "错误，用户名" & htmlencode(UserName) & "不存在！"
		Exit Function
	Else
		GBL_UserName_UserLimit = cCur(Rs(1))
		GBL_UserName_UserID = cCur(Rs(0))
		GBL_UserName = Rs(2)
	End if
	Rs.Close
	Set Rs = Nothing
	',0-认证会员,1-版主,2-总版主,3-屏蔽会员,4-禁言会员,5-禁修改会员,6-非正式会员
	Select Case GBL_Assort
		Case 3:
				If GetBinarybit(GBL_UserName_UserLimit,7) = 0 Then
					GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "的发言内容及签名并未被屏蔽，不必解除！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,7,0)
				End If
		Case 4:
				If GetBinarybit(GBL_UserName_UserLimit,3) = 0 Then
					GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "未被禁言及发送短消息，不必解除！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,3,0)
				End If
		Case 5:
				If GetBinarybit(GBL_UserName_UserLimit,4) = 0 Then
					GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "未被禁止修改帖子及自我资料，不必解除！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,4,0)
				End If
		Case 6:
				If GetBinarybit(GBL_UserName_UserLimit,1) = 0 Then
					GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "已经激活，已经不成需要您来激活！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,1,0)
				End If
		Case Else:
				GBL_CHK_TempStr = "错误，你想作什么？"
				CheckUserNameExist = 0
				Exit Function
	End Select
	CALL LDExeCute("Update LeadBBS_User Set UserLimit=" & GBL_UserName_UserLimit & " where ID=" & GBL_UserName_UserID,1)
	CALL LDExeCute("Delete from LeadBBS_SpecialUser Where Assort=" & GBL_Assort & " and UserID=" & GBL_UserName_UserID,1)
	GBL_CHK_TempStr = "<font color=Green Class=greenfont>操作成功，请按ESC退出．</font>"
	CheckUserNameExist = 1

End Function%>