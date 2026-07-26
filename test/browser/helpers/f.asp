<!--#include file="../../../inc/BBSsetup.asp"-->
<%
' DEV/TEST ONLY (loopback-gated): return the raw text of a file under the web root, so the
' browser suites can assert on artefacts the app WRITES (generated templet .JS files, rewritten
' setup includes) — there is no way to read an .asp file's source over HTTP. Delete _test/ on a
' real deployment, as README says.
Response.ContentType = "text/plain"
Dim ip : ip = Request.ServerVariables("REMOTE_ADDR") & ""
If ip <> "127.0.0.1" And ip <> "::1" And ip <> "0:0:0:0:0:0:0:1" Then Response.Write "FORBIDDEN" : Response.End
Dim rel : rel = Request.QueryString("path") & ""
If rel = "" Or InStr(rel, "..") > 0 Then Response.Write "BADPATH" : Response.End
Dim fso, f
On Error Resume Next
Set fso = Server.CreateObject("Scripting.FileSystemObject")
Set f = fso.OpenTextFile(Server.MapPath("/" & rel), 1)
If Err.Number <> 0 Then Response.Write "ERR " & Err.Number & " " & Err.Description : Response.End
Response.Write f.ReadAll
f.Close
%>
