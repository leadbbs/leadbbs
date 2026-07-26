<!--#include file="../../../inc/BBSsetup.asp"-->
<%
' DEV/TEST ONLY (loopback-only): pin the session captcha to a known value (1234)
' so the E2E harness can submit forms that require the verification code.
' Delete test/ on real deployments.
Response.ContentType = "text/plain"
Dim ip : ip = Request.ServerVariables("REMOTE_ADDR") & ""
If ip <> "127.0.0.1" And ip <> "::1" And ip <> "0:0:0:0:0:0:0:1" Then
	Response.Write "FORBIDDEN": Response.End
End If
Session(DEF_MasterCookies & "RndNum") = "1234"
Response.Write "captcha set: " & DEF_MasterCookies & "RndNum=1234"
%>
