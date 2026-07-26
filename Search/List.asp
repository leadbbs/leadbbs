<%
dim RootFlag,u
RootFlag = Left(Request.QueryString,1)
if RootFlag <> "0" and RootFlag <> "1" and RootFlag <> "2" then RootFlag = 1
response.redirect "../b/b.asp?action=list&type=" & RootFlag
%>
