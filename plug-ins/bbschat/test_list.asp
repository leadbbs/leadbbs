<!-- #include file=../../inc/BBSSetup.asp -->
<!-- #include file=Chat_Fun.asp -->
<!-- #include file=Inc/Chat_Setup.asp -->
<%
Sub Chat_GetWorldChat

	Dim N,Temp
	Temp = Application(DEF_MasterCookies & "_Chat_World")
	For n = 0 to Chat_MaxCache-1
		Response.Write n & " " & Temp(n) & "<br>" & VbCrLf
	Next

End Sub

Chat_GetWorldChat
%>