<% @codepage=936 EnableSessionState=False%>
<%
Option Explicit
Response.Charset = "gb2312"
Dim id
id=Request.QueryString("id")
If Len(ID) > 20 Then
	Response.Write " "
Else
	If Request.QueryString("free") = "1" Then
		Application.Contents.Remove("Io_" & id)
	Else
		If len(application("Io_" & id)) > 0 Then
			Response.Write Application("Io_" & id)
		Else
			Response.Write " "
		End If
	End If
End If
%>