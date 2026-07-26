<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../inc/UserTopic.asp"-->
<%
DEF_BBS_HomeUrl = "../../"

Main()

Sub Main

	BBS_SiteHead DEF_SiteNameString & " - 管理团队",0,"管理团队"
	
	UserTopicTopInfo("forum")
	Main_Info()
	UserTopicBottomInfo()
	sitebottom()

End Sub

Function Main_Info%>

<p>
<!--#include file="../inc/Contact_Info.asp"-->

<%
	InitDatabase()
	DisplayBoardManageInfo()
	Closedatabase()

End Function

Function DisplayBoardManageInfo

	GBL_CHK_PWdFlag = 0
	UpdateOnlineUserAtInfo GBL_board_ID,"管理团队"
	
	Response.Write "<div class=title>论坛管理人员</div>"
	Dim N,GetData,Rs
	GetData = Split(DEF_SupervisorUserName,",")
	Rs = Ubound(GetData,1)
	'If Replace(DEF_SupervisorUserName,",","") <> "" Then Response.Write "<p><u>论坛管理员</u>"
	'For N = 0 to Rs
	'	If GetData(N) <> "" Then
	'		Response.Write " <a href=""../" & RW_User(0,"",GetData(N),"") & """>" & htmlencode(GetData(N)) & "</a>"
	'		If GBL_CHK_User <> "" Then Response.Write "<a href=""../SendMessage.asp?SdM_ToUser=" & urlencode(GetData(N)) & """ onclick=""return(sendprivatemsg(this,'" & DEF_BBS_HomeUrl & "'));"" title=发送短消息><img src=../../images/" & GBL_DefineImage & "message.GIF border=0 align=middle></a>"
	'	End If
	'Next

	Dim RequestStr
	RequestStr = Request.QueryString
	If RequestStr <> "b" and RequestStr <> "c" and RequestStr <> "z" Then RequestStr = "a"
	%>
	<p><img src=<%=DEF_BBS_HomeUrl & "images/" & GBL_DefineImage%>splt.gif align=middle width=7 height=15>
	<a href=about.asp?a><%=DEF_PointsName(6)%></a>
	<img src=<%=DEF_BBS_HomeUrl & "images/" & GBL_DefineImage%>splt.gif align=middle width=7 height=15>
	<a href=about.asp?c><%=DEF_PointsName(7)%></a>
	<img src=<%=DEF_BBS_HomeUrl & "images/" & GBL_DefineImage%>splt.gif align=middle width=7 height=15>
	<a href=about.asp?b><%=DEF_PointsName(8)%></a>
	<img src=<%=DEF_BBS_HomeUrl & "images/" & GBL_DefineImage%>splt.gif align=middle width=7 height=15>
	<a href=about.asp?z>登录监督</a>
	<img src=<%=DEF_BBS_HomeUrl & "images/" & GBL_DefineImage%>splt.gif align=middle width=7 height=15>
	<%
	If RequestStr = "a" Then
		Set Rs = LDExeCute("select UserName from LeadBBS_SpecialUser Where Assort=2",0)
		If Rs.Eof Then
			Rs.Close
			Set Rs = Nothing
			Response.Write "<p><u>" & DEF_PointsName(6) & "</b></u></p>无"
		Else
			GetData = Rs.GetRows(-1)
			Rs.Close
			Set Rs = Nothing
			Rs = Ubound(GetData,2)
			Response.Write "<p><u>" & DEF_PointsName(6) & "</b></u></p>"%>
			<table border="0" cellspacing="0" cellpadding="0" class=table_in>
			<tr class=tbinhead>
				<td width=180><div class=value>用户名</div></td>
				<td><div class=value>短消息</div></td>
			</tr>
			<%
			For N = 0 to Rs
				Response.Write "<tr><td class=tdbox><a href=""../" & RW_User(0,"",GetData(0,n),"") & """>" & htmlencode(GetData(0,n)) & "</a>"
				Response.write "<td class=tdbox><a href=""../SendMessage.asp?SdM_ToUser=" & urlencode(GetData(0,n)) & """ onclick=""return(sendprivatemsg(this,'" & DEF_BBS_HomeUrl & "'));"" title=发送短消息><img src=../../images/" & GBL_DefineImage & "message.GIF border=0 align=middle></a>"
			Next
			%>
				</td>
			</tr>
			</table>
			<%
		End If
	End If

	Dim Flag
	If RequestStr = "b" Then
		Set Rs = LDExeCute("select T1.UserID,T1.UserName,t2.BoardName,T1.BoardID from LeadBBS_SpecialUser as T1 left join LeadBBS_Boards as T2 on T1.BoardID=T2.BoardID Where Assort=1 order by T1.UserID",0)
		If Not Rs.Eof Then
			GetData = Rs.GetRows(-1)
			Rs.Close
			Set Rs = Nothing
			Rs = Ubound(GetData,2)
			Response.Write "<p><u>" & DEF_PointsName(8) & "</u></p>"
			Flag = 0
			%>
		<table border="0" cellspacing="0" cellpadding="0" class=table_in>
		<tr class=tbinhead>
			<td width=180><div class=value>用户名</div></td>
			<td width=120><div class=value>短消息</div></td>
			<td><div class=value>担任版面</div></td>
		</tr><%
			For N = 0 to Rs
				If Flag <> cCur(GetData(0,N)) Then
					Response.Write "<tr><td class=tdbox><a href=""../" & RW_User(GetData(0,n),"","","") & """>" & htmlencode(GetData(1,n)) & "</a>"
					Response.write "<td class=tdbox><a href=""../SendMessage.asp?SdM_ToUser=" & urlencode(GetData(1,n)) & """ onclick=""return(sendprivatemsg(this,'" & DEF_BBS_HomeUrl & "'));"" title=发送短消息><img src=../../images/" & GBL_DefineImage & "message.GIF border=0 align=middle></a>"
					Response.Write "<td class=tdbox><a href=../../b/" & RW_b(GetData(3,n),0,"") & ">" & GetData(2,n) & "</a>"
					Flag = cCur(GetData(0,n))
				Else
					Response.Write ",<a href=../../b/" & RW_b(GetData(3,n),0,"") & ">" & GetData(2,n) & "</a>"
				End If
			Next
			%></table><%
		Else
			Rs.Close
			Set Rs = Nothing
			Response.Write "<p><u>" & DEF_PointsName(8) & "</b></u></p>无"
		End If
	End If

	If RequestStr = "c" Then
		Set Rs = LDExeCute("select T1.UserID,T1.UserName,T2.AssortName,T1.BoardID from LeadBBS_SpecialUser as T1 left join LeadBBS_Assort as T2 on T1.BoardID=T2.AssortID Where Assort=7 order by T1.UserID",0)
		If Not Rs.Eof Then
			GetData = Rs.GetRows(-1)
			Rs.Close
			Set Rs = Nothing
			Rs = Ubound(GetData,2)
			Response.Write "<p><u>" & DEF_PointsName(7) & "</u></p>"
			Flag = 0
			%>
		<table border="0" cellspacing="0" cellpadding="0" class=table_in>
		<tr class=tbinhead>
			<td width=180><div class=value>用户名</div></td>
			<td width=120><div class=value>短消息</div></td>
			<td><div class=value>担任分区</div></td>
		</tr><%
			For N = 0 to Rs
				If Flag <> cCur(GetData(0,N)) Then
					Response.Write "<tr><td class=tdbox><a href=""../" & RW_User(GetData(0,n),"","","") & """>" & htmlencode(GetData(1,n)) & "</a>"
					Response.write "<td class=tdbox><a href=""../SendMessage.asp?SdM_ToUser=" & urlencode(GetData(1,n)) & """ onclick=""return(sendprivatemsg(this,'" & DEF_BBS_HomeUrl & "'));"" title=发送短消息><img src=../../images/" & GBL_DefineImage & "message.GIF border=0 align=middle></a>"
					Response.Write "<td class=tdbox><a href=../../Boards.asp?Assort=" & GetData(3,n) & ">" & GetData(2,n) & "</a>"
					Flag = cCur(GetData(0,n))
				Else
					Response.Write ",<a href=../../Boards.asp?Assort=" & GetData(3,n) & ">" & GetData(2,n) & "</a>"
				End If
			Next
			%></table><%
		Else
			Rs.Close
			Set Rs = Nothing
			Response.Write "<p><u>" & DEF_PointsName(7) & "</b></u></p>无"
		End If
	End If
	
	If RequestStr = "z" Then DisplayBoardManageInfo2()

End Function

Function DisplayBoardManageInfo2

	Response.Write "<p><br><b>" & DEF_SiteNameString & " - 论坛管理人员登录情况</b></p>"
	
	CALL About_ViewLogin("T1.Assort=2",DEF_PointsName(6))
	CALL About_ViewLogin("Assort=7 order by T1.UserID",DEF_PointsName(7))
	CALL About_ViewLogin("Assort=1 order by T1.UserID",DEF_PointsName(8))

End Function

Sub About_ViewLogin(SQL,title)


	Dim Flag,Rs,N,GetData

	Set Rs = LDExeCute("select T1.UserName,T2.LastDoingTime from LeadBBS_SpecialUser as T1 left join LeadBBS_User as T2 on T1.UserID=T2.ID Where " & SQL,0)
	If Not Rs.Eof Then
		GetData = Rs.GetRows(-1)
		Rs.Close
		Set Rs = Nothing
		Rs = Ubound(GetData,2)
		Response.Write "<p><u>" & title & "</u></p>"
		Flag = ""
		%>
	<table border="0" cellspacing="0" cellpadding="0" class=table_in>
	<tr class=tbinhead>
		<td width=180><div class=value>用户名</div></td>
		<td width=120><div class=value>短消息</div></td>
		<td><div class=value>登录情况</div></td>
	</tr><%
		For N = 0 to Rs
			If Flag <> GetData(0,N) Then
				Response.Write "<tr><td class=tdbox><a href=""../" & RW_User(0,"",GetData(0,n),"") & """>" & htmlencode(GetData(0,n)) & "</a>"
				Response.write "<td class=tdbox><a href=""../SendMessage.asp?SdM_ToUser=" & urlencode(GetData(0,n)) & """ onclick=""return(sendprivatemsg(this,'" & DEF_BBS_HomeUrl & "'));"" title=发送短消息><img src=../../images/" & GBL_DefineImage & "message.GIF class=""absmiddle"" alt=""短消息"" /></a>"
				Flag = GetData(0,n)					
				Response.Write "<td class=tdbox>"
				If Len(GetData(1,n)) = 14 Then
					GetData(1,n) = RestoreTime(GetData(1,n))
					GetData(1,n) = DateDiff("d",GetData(1,n),now)
					If GetData(1,n) <=0 Then
						Response.Write "<span class=bluefont>今天刚来过</span>"
					ElseIf GetData(1,n) <=1 Then
						Response.Write "<span class=greenfont>昨天曾来过</span>"
					ElseIf GetData(1,n) <=2 Then
						Response.Write "<span class=greenfont>前天曾来过</span>"
					ElseIf GetData(1,n) <=3 Then
						Response.Write "<span class=greenfont>累计三天未来过</span>"
					ElseIf GetData(1,n) <=9 Then
						Response.Write "<span class=redfont>失踪" & GetData(1,n) & "天</span>"
					ElseIf GetData(1,n) <=21 Then
						Response.Write "<span class=redfont>失踪" & GetData(1,n) & "天</span>"
					Else
						Response.Write "<span class=grayfont>失踪" & GetData(1,n) & "天</span>"
					End If
				End If
				Response.Write "</td>"
			End If
		Next
		%></table><%
	Else
		Rs.Close
		Set Rs = Nothing
		Response.Write "<p><u>" & title & "</b></u></p>无"
	End If

End Sub%>