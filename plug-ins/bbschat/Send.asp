<!--#include file="../../inc/BBSSetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../../User/inc/UserTopic.asp"-->
<!--#include file="Chat_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = GBL_UserID

            
If GBL_CHK_Flag = 1 Then
	Chat_SendCommand()
End If
closeDataBase()

Sub Chat_SendCommand

	Dim Channel,ToUser,Msg,Delay
	Channel = Left(Request.Form("SelChannel"),2)
	Msg = Session(DEF_MasterCookies & "_Chat_SendTime")
	
	If Channel <> "98" Then
		Delay = Chat_WorldDelay
	Else
		Delay = Chat_WorldDelay/4
	End If
	

	If Timer - Msg < Delay and Timer > Msg Then
		CALL Chat_ViewError("2","<span color=red>请稍候再发送消息！</span><br>")
	Else
		Msg = Left(Request.Form("inputCommand"),Chat_MaxInput)
		If Trim(Msg) = "" Then Exit Sub
		
		Dim SpendNum
		SpendNum = 0
		If Chat_DEF_ColorSpend > 0 Then
			If inStr(LCase(Msg),"[color=") > 0 and inStr(LCase(Msg),"[/color]") > 0 Then
				If GBL_CHK_Points >= Chat_DEF_ColorSpend Then
					SpendNum = Chat_DEF_ColorSpend
				Else
					CALL Chat_ViewError("2","<span color=red>您的" & DEF_PointsName(0) & "不足，无法发送增色文字!</span><br>")
					Exit Sub
				End If
			End If
		End If
		ToUser = Left(Request.Form("ToUser"),20)

		Select Case Channel:
		Case "2":
			CALL Chat_ViewError("2","<span color=red>你未加入任何" & DEF_PointsName(9) & "!</span><br>")
		Case "3":
			CALL Chat_ViewError("2","<span color=red>你未加入任何团队!</span><br>")
		Case "98":
			Channel = 98
			If isArray(Application(DEF_MasterCookies & "_Chat_S_Data_" & ToUser)) = False Then
				Chat_ViewNotOnline(ToUser)
				Exit Sub
			End If
			ToUser = Application(DEF_MasterCookies & "_Chat_S_Name_" & ToUser)
			Session(DEF_MasterCookies & "_Chat_SendTime") = Timer '设置最后发送时间
			CALL Chat_Appand(GBL_CHK_User,Msg,5,ToUser)
			Chat_ViewWorldMsg(GBL_CHK_User)
			If SpendNum > 0 Then Chat_SetPoint(SpendNum)
		Case Else
			Channel = 1
			If isArray(Application(DEF_MasterCookies & "_Chat_S_Data_" & ToUser)) = False Then
				If inStr(Msg,"$P") Then
					Chat_ViewNotOnline(ToUser)
					Exit Sub
				End If
				ToUser = ""
			Else
				ToUser = Application(DEF_MasterCookies & "_Chat_S_Name_" & ToUser)
			End If
			Session(DEF_MasterCookies & "_Chat_SendTime") = Timer '设置最后发送时间
			CALL Chat_Appand(GBL_CHK_User,Msg,1,ToUser)
			Chat_ViewWorldMsg(GBL_CHK_User)
			If SpendNum > 0 Then Chat_SetPoint(SpendNum)
		End Select
	End If

End Sub

Sub Chat_ViewError(c,str)

	Response.write "parent.addMessage('" & c & "',""" & str & """);" & VbCrLf

End Sub

Sub Chat_ViewNotOnline(usr)

	Response.write "parent.addMessage('5',""发送失败，用户" & HtmlEncode(usr) & "不在线!<br>"");" & VbCrLf

End Sub

Sub Chat_SetPoint(n)

	CALL LDExeCute("Update LeadBBS_User set Points=Points-" & n & " Where ID = " & GBL_UserID,1)
	UpdateSessionValue 4,0-n,1

End Sub%>