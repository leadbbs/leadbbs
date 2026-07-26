<!--#include file="../../inc/BBSSetup.asp"-->
<!--#include file="Chat_Fun.asp"-->
<!--#include file="Inc/Chat_Setup.asp"-->
<%
Sub Chat_GetWorldChat(User)

	Dim Index,World_Index,Temp,n
	Index = Session(DEF_MasterCookies & "_Chat_World_Index")
	World_Index = Application(DEF_MasterCookies & "_Chat_World_Index")
	If Index <> World_Index and Index <> -1 Then
		Session(DEF_MasterCookies & "_Chat_World_Index") = Application(DEF_MasterCookies & "_Chat_World_Index")
		Temp = Application(DEF_MasterCookies & "_Chat_World")
		If Index > World_Index Then
			For n = Index to Chat_MaxCache-1
				Response.Write Temp(n) & VbCrLf
			Next
			For n = 0 to World_Index
				Response.Write Temp(n) & VbCrLf
			Next
		Else
			For n = Index + 1 to World_Index
				Response.Write Temp(n) & VbCrLf
			Next
		End If
	End If	

	Index = Session(DEF_MasterCookies & "_Chat_5_Index")
	World_Index = Application(DEF_MasterCookies & "_Chat_S_Index_" & User)
	Dim len
	If Index <> World_Index and Index <> -1 Then
		Session(DEF_MasterCookies & "_Chat_5_Index") = Application(DEF_MasterCookies & "_Chat_S_Index_" & User)
		Temp = Application(DEF_MasterCookies & "_Chat_S_Data_" & User)
		len = Ubound(Temp,1)
		If Index > World_Index Then
			For n = Index to Chat_MaxCache-1
				If n > len Then Exit for
				Response.Write Temp(n) & VbCrLf
			Next
			For n = 0 to World_Index
				If n > len Then Exit for
				Response.Write Temp(n) & VbCrLf
			Next
		Else
			For n = Index + 1 to World_Index
				If n > len Then Exit for
				Response.Write Temp(n) & VbCrLf
			Next
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
	If Timer - tmp < Chat_GetDelay/2 Then
		'Response.Write "9 busy"
		Exit Sub
	End If
	Session(DEF_MasterCookies & "_Chat_GetTime") = Timer
	Chat_GetWorldChat(User)

End Sub

Chat_GetInfo()
%>