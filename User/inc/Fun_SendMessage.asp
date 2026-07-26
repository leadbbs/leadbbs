<%
Const LMT_SendMsgExpiresDate = 90 '定义新发送短消息保存天数(过期自动删除)
dim GBL_Msg_ToUser : GBL_Msg_ToUser = ","

Sub SendNewMessage(fromUser,ToUser,Title,Content,GBL_IPAddress)

	if inStr(GBL_Msg_ToUser,"," & ToUser & ",") > 0 then exit Sub
	GBL_Msg_ToUser = GBL_Msg_ToUser & ToUser & ","
	dim Expire
	If LMT_SendMsgExpiresDate > 0 Then
		Expire = CLng(Left(LngStr(GetTimeValue(DateAdd("d",LMT_SendMsgExpiresDate,Now))),8))
	Else
		Expire = 0
	End If
	If toUser = "" Then
		CALL LDExeCute("inSert into LeadBBS_InfoBox(FromUser,ToUser,Title,Content,IP,SendTime,ReadFlag,ExpiresDate)" & _
			" Values('" & Replace(fromUser,"'","''") & "','','" & Replace(Title,"'","''") & "'" & _
			",'" & Replace(Replace(Content & "","\" & VbCrLf,"\\" & VbCrLf & VbCrLf),"'","''") & "','" & GBL_IPAddress & "'," & GetTimeValue(DEF_Now) & ",0,0)",1)
		ReloadPubMessageInfo()
		GBL_CHK_TempStr = "<p align=left>&nbsp; &nbsp; <font color=008800 class=greenfont>成功发送消息给所有用户。</font><br>"
	Else
		Dim N,TmpArr
		TmpArr = Split(ToUser,",")
		GBL_CHK_TempStr = ""
		For N = 0 to Ubound(TmpArr,1)
			CALL LDExeCute("inSert into LeadBBS_InfoBox(FromUser,ToUser,Title,Content,IP,SendTime,ReadFlag,ExpiresDate)" & _
				" Values('" & Replace(fromUser,"'","''") & "','" & Replace(TmpArr(N),"'","''") & "','" & Replace(Title,"'","''") & "'" & _
				",'" & Replace(Content,"'","''") & "','" & GBL_IPAddress & "'," & GetTimeValue(DEF_Now) & ",0," & Expire & ")",1)
			GBL_CHK_TempStr = GBL_CHK_TempStr & "<font color=008800 class=greenfont>成功发送短消息。</font><br>" & VbCrLf
			CALL LDExeCute("Update LeadBBS_User Set MessageFlag=1 where UserName='" & Replace(ToUser,"'","''") & "' and MessageFlag=0",1)
			If GBL_CHK_User = ToUser Then UpdateSessionValue 6,1,0
		Next
REM *******Chat Start*******
CALL Chat_Appand_Session("<span onclick=c_sc(this.innerHTML) style=cursor:hand class=c_name>" & htmlencode(fromUser) & "</span>给你发送了一封留言：<a href=../../User/MyInfoBox.asp target=_blank>" & htmlencode(Title) & "</a>。<br>",ToUser)
REM *******Chat End*********
	End If

End Sub%>