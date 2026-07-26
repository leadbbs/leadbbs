<% @codepage=936 EnableSessionState=False%>
<%
Option Explicit
Dim id
id=Request.QueryString("id")
If Len(ID) > 20 Then
	Response.Write " "
Else
	If inStr(application("LdUpload_" & id)," ") Then
		Response.Write Application("LdUpload_" & id)
	Else
		Response.Write " "
	End If
End If
%>