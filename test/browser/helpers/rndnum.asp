<!--#include file="../../../inc/BBSsetup.asp"-->
<%
' DEV/TEST ONLY (loopback-only): report the CURRENT session verification code so the
' browser test suite can type the real captcha into the real form. Reading it does not
' change it. Delete test/ on real deployments.
Response.ContentType = "text/plain"
Dim ip : ip = Request.ServerVariables("REMOTE_ADDR") & ""
If ip <> "127.0.0.1" And ip <> "::1" And ip <> "0:0:0:0:0:0:0:1" Then Response.Write "FORBIDDEN" : Response.End
Response.Write Session(DEF_MasterCookies & "RndNum") & ""
%>
