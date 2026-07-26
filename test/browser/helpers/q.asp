<!--#include file="../../../inc/BBSsetup.asp"-->
<!--#include file="../../../inc/Board_Popfun.asp"-->
<%
On Error Resume Next
Response.ContentType="text/plain"
Dim ip : ip = Request.ServerVariables("REMOTE_ADDR") & ""
If ip<>"127.0.0.1" And ip<>"::1" And ip<>"0:0:0:0:0:0:0:1" Then Response.Write "FORBIDDEN":Response.End
initDatabase()
Dim sql : sql = Request.QueryString("sql")
If sql = "" Then Response.Write "usage: q.asp?sql=SELECT...":Response.End
' read-only guard
Dim lc : lc = LCase(Trim(sql))
If Left(lc,6)<>"select" And Left(lc,4)<>"show" And Left(lc,8)<>"describe" Then Response.Write "READ-ONLY ONLY":Response.End
Dim Rs : Set Rs = LDExeCute(sql,0)
Dim i
If Not Rs.Eof Then
  For i=0 to Rs.Fields.Count-1 : Response.Write Rs.Fields(i).Name & vbTab : Next
  Response.Write vbCrLf
End If
Dim r : r=0
Do While Not Rs.Eof And r<50
  For i=0 to Rs.Fields.Count-1 : Response.Write Rs(i) & "" & vbTab : Next
  Response.Write vbCrLf
  r=r+1 : Rs.MoveNext
Loop
If Err.Number<>0 Then Response.Write "ERR: " & Err.Description
%>
