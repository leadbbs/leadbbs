<%
' DEV/TEST ONLY (loopback-only): dump the set of files the coverage probe recorded
' this server-lifetime. Pairs with test/coverage/instrument.py. Delete test/ on deploy.
Response.ContentType = "text/plain"
Dim ip : ip = Request.ServerVariables("REMOTE_ADDR") & ""
If ip <> "127.0.0.1" And ip <> "::1" And ip <> "0:0:0:0:0:0:0:1" Then Response.Write "FORBIDDEN" : Response.End
Dim k
For Each k In Application.Contents
  If Left(k,5) = "cov::" Then Response.Write Mid(k,6) & vbCrLf
Next
%>
