<%@ Language=VBScript %>
<% Option Explicit %>
<% 
   Response.Write "在你的程序中一共使用了 " & Session.Contents.Count & _
             " 个Session变量 SessionID:" & Session.SessionID & "<p>"
   Dim strName, iLoop
   For Each strName in Session.Contents
     '判断一个Session变量是否为数组
     If IsArray(Session(strName)) then
       '如果是数组，那么罗列出所有的数组元素内容
       For iLoop = LBound(Session(strName)) to UBound(Session(strName))
          Response.Write strName & "(" & iLoop & ") - " & _
               Session(strName)(iLoop) & "<br>"
       Next
     Else
       '如果不是数组，那么直接显示
       Response.Write strName & " - " & Session.Contents(strName) & "<br>"
     End If
   Next
%>  
<%
Dim DEF_MasterCookies
DEF_MasterCookies = "as"

Dim User

User = "月光书屋"
Application.Lock
Application("as_Chat_U_" & User) = "a"
Application.UnLock
Response.Write "<br>1." & Application(DEF_MasterCookies & "_Chat_U_" & User)
'Application.Contents.Remove(DEF_MasterCookies & "_Chat_U_" & User)
'Response.Write "<br>2." & Application(DEF_MasterCookies & "_Chat_U_" & User)


User = "KFJoe8#$2_*4""38'}   [//`"
Application("as_Chat_U_" & User) = "a"
Response.Write "<br>11." & Application(DEF_MasterCookies & "_Chat_U_" & User)
'Application.Contents.Remove(DEF_MasterCookies & "_Chat_U_" & User)
'Response.Write "<br>22." & Application(DEF_MasterCookies & "_Chat_U_" & User)


%>