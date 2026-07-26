<!--#include file="../../inc/BBSSetup.asp"-->
<!--#include file="Chat_Fun.asp"-->
<!--#include file="Inc/Chat_Setup.asp"-->
<%
Sub Chat_GetWorldChat(User)

	Dim Index,World_Index,Temp

	Index = Session(DEF_MasterCookies & "_Chat_5_Index")
	World_Index = Application(DEF_MasterCookies & "_Chat_S_Index_" & User)
	If Index <> World_Index and Index <> -1 Then
		Response.Write "1 您有新的私聊" & VbCrLf
	Else
		If isArray(Session(DEF_MasterCookies & "UDT")) = False Then
			Response.Write "9 stop"
		Else
			Temp = Session(DEF_MasterCookies & "UDT")(6)
			If ccur(Temp) = 1 Then
				Response.Write "9 mess"
			Else
				Response.Write "9 null"
			End If
		End If
	End If

End Sub

Sub Chat_GetInfo

	Dim User
	User = Left(Request.Form("User"),20)
	If isArray(Application(DEF_MasterCookies & "_Chat_S_Data_" & User)) = False Then
		Response.Write "9 guest"
		Exit Sub '游客无法请求
	Else
		If Application(DEF_MasterCookies & "_Chat_S_ID_" & User) <> cCur(Session.SessionID) Then
			Response.Write "9 stop"
			Exit Sub '非当前窗口无法请求
		End If
	End If
	Dim tmp
	tmp = Session(DEF_MasterCookies & "_Chat_GetTime")
	If Timer < tmp Then
		Session(DEF_MasterCookies & "_Chat_GetTime") = Timer
		tmp = Timer
	End If
	If Timer - tmp < 6 Then
		'防止请求聊天室信息
		Response.Write "9 none"
		Exit Sub
	End If
	Session(DEF_MasterCookies & "_Chat_GetTime") = Timer
	Chat_GetWorldChat(User)

End Sub

Chat_GetInfo()
%>