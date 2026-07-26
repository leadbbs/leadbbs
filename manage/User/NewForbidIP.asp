<!-- #include file=../../inc/BBSsetup.asp -->
<!-- #include file=../../inc/Board_Popfun.asp -->
<!-- #include file=../inc/bbsmanage_Fun.asp -->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo
DisplayUserNavigate("添加屏蔽ＩＰ地址")
If GBL_CHK_Flag=1 Then
	LoginAccuessFul
Else
DisplayLoginForm
End If
frame_BottomInfo
closeDataBase
Manage_Sitebottom("none")

Dim GBL_IPStart,GBL_IPEnd,GBL_WhyString,GBL_ExpiresTime,GBL_UserName,GBL_UserName_UserID
Dim GBL_AnnounceID,GBL_MessageID
GBL_ExpiresTime = -1

Function LoginAccuessFul

	GBL_UserName = Trim(Left(Request.Form("GBL_UserName"),14))
	GBL_AnnounceID = Left(Request.Form("GBL_AnnounceID"),14)
	GBL_MessageID = Left(Request.Form("GBL_MessageID"),14)
	
	If GBL_MessageID <> "" Then
	ElseIf GBL_AnnounceID <> "" Then
	ElseIf GBL_UserName <> "" Then
		'CheckUserNameExist(GBL_UserName)
	Else
		GBL_IPStart = Request.Form("GBL_IPStart")
		GBL_IPEnd = Request.Form("GBL_IPEnd")
	End If
	GBL_ExpiresTime = Left(Request.Form("GBL_ExpiresTime"),14)
	GBL_WhyString = Left(Request.Form("GBL_WhyString"),100)
	
	If isNumeric(GBL_ExpiresTime) = 0 Then GBL_ExpiresTime = -1
	GBL_ExpiresTime = fix(cCur(GBL_ExpiresTime))
	If GBL_ExpiresTime < 0 or GBL_ExpiresTime > 30 Then GBL_ExpiresTime = -1

	If Request.Form("submitflag") <> "" Then
		CheckNewIP
		If GBL_CHK_TempStr = "" Then
			SaveNewIP
			Response.Write GBL_CHK_TempStr
		Else
			DisplayNewIPForm
		End If
	Else
		DisplayNewIPForm
	End If

End Function

Function SaveNewIP

	Dim SQL,Rs,Number
	GBL_IPEnd = Right("000000000000" & cStr(GBL_IPEnd),12)
	GBL_IPStart = Right("000000000000" & cStr(GBL_IPStart),12)
	Number = (Left(GBL_IPEnd,3) * 256 * 256 * 256 + Mid(GBL_IPEnd,4,3) * 256 * 256 + Mid(GBL_IPEnd,7,3) * 256 + Mid(GBL_IPEnd,10,3))-(Left(GBL_IPStart,3) * 256 * 256 * 256 + Mid(GBL_IPStart,4,3) * 256 * 256 + Mid(GBL_IPStart,7,3) * 256 + Mid(GBL_IPStart,10,3)) + 1
	SQL = sql_select("Select ID from LeadBBS_ForbidIP where IPStart<=" & GBL_IPStart & " and IPEnd>=" & GBL_IPEnd,1)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		SQL = "Insert Into LeadBBS_ForbidIP(IPStart,IPEnd,IPNumber,ExpiresTime,WhyString) Values(" & GBL_IPStart & "," & GBL_IPEnd & "," & Number & "," & GBL_ExpiresTime & ",'" & Replace(GBL_WhyString,"'","''") & "')"
		CALL LDExeCute(SQL,1)
		GBL_CHK_TempStr = "<font color=008800 class=greenfont>成功屏蔽此IP段,共计" & Number & "个!<br>" & VbCrLf
		GBL_CHK_TempStr = GBL_CHK_TempStr & "起始IP地址：" & GBL_IPStart & "<br>" & VbCrLf
		GBL_CHK_TempStr = GBL_CHK_TempStr & "终止IP地址：" & GBL_IPEnd & "</font><br>" & VbCrLf
	Else
		Rs.Close
		Set Rs = Nothing
		GBL_CHK_TempStr = "<font color=ff0000 class=redfont>错误：此IP地址段已经在屏蔽列表中,不用重复添加!</font><br>" & VbCrLf
	End If

End Function

Function CheckNewIP

	If GBL_MessageID <> "" or Request.Form("submitflag") = "LKOkxk4" Then
		If CheckMessageID(GBL_MessageID) = 0 Then
			Exit Function
		End If
	ElseIf GBL_AnnounceID <> "" or Request.Form("submitflag") = "LKOkxk3" Then
		If CheckAnnounceID(GBL_AnnounceID) = 0 Then
			Exit Function
		End If
	ElseIf GBL_UserName <> "" or Request.Form("submitflag") = "LKOkxk2" Then
		If CheckUserNameExist(GBL_UserName) = 0 Then
			Exit Function
		End If
	End If
	Dim Tmp_IPStart,Tmp_IPEnd
	Tmp_IPStart = FormatIPaddress(GBL_IPStart)
	Tmp_IPEnd = FormatIPaddress(GBL_IPEnd)

	If isNumeric(GBL_ExpiresTime) = 0 Then GBL_ExpiresTime = -1
	GBL_ExpiresTime = fix(cCur(GBL_ExpiresTime))
	If GBL_ExpiresTime < 0 or GBL_ExpiresTime > 30 Then GBL_ExpiresTime = -1
	If GBL_ExpiresTime = -1 Then
		GBL_CHK_TempStr = "错误：屏蔽期限选择错误，请正确选择！"
		Exit function
	End If

	If Len(Tmp_IPStart) <> 15 Then
		GBL_CHK_TempStr = "错误：起始ＩＰ地址错误"
		Exit function
	End If

	If Len(Tmp_IPStart) <> 15 Then
		GBL_CHK_TempStr = "错误：终止ＩＰ地址错误"
		Exit function
	End If
	
	Dim NewGBL_IPStart,NewGBL_IPEnd
	NewGBL_IPStart = Left(Replace(Tmp_IPStart,".",""),14)
	NewGBL_IPEnd = Left(Replace(Tmp_IPEnd,".",""),14)
	If isNumeric(NewGBL_IPStart) = 0 Then
		GBL_CHK_TempStr = "错误：起始ＩＰ地址错误，必须是数字"
		Exit function
	End If
	
	If isNumeric(NewGBL_IPEnd) = 0 Then
		GBL_CHK_TempStr = "错误：终止ＩＰ地址错误，必须是数字"
		Exit function
	End If
	
	NewGBL_IPStart = cCur(NewGBL_IPStart)
	NewGBL_IPEnd = cCur(NewGBL_IPEnd)
	If NewGBL_IPStart > NewGBL_IPEnd Then
		GBL_CHK_TempStr = "错误：终止ＩＰ地址不能比起始ＩＰ地址小"
		Exit function
	End If
	
	If NewGBL_IPStart > 255255255255 Then
		GBL_CHK_TempStr = "错误：起始ＩＰ地址错误，最大IP地址为255.255.255.255"
		Exit function
	End If
	If NewGBL_IPEnd > 255255255255 Then
		GBL_CHK_TempStr = "错误：终止ＩＰ地址错误，最大IP地址为255.255.255.255"
		Exit function
	End If

	GBL_IPStart = NewGBL_IPStart
	GBL_IPEnd = NewGBL_IPEnd
	If GBL_ExpiresTime > 0 Then
		GBL_ExpiresTime = GetTimeValue(DateAdd("d",GBL_ExpiresTime,DEF_Now))
	Else
		GBL_ExpiresTime = 0
	End If

End Function

Function DisplayNewIPForm

	Dim N
	If GBL_CHK_TempStr <> "" Then Response.Write "<p><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font></p>"%>
		<%If Request.Form("submitflag") = "LKOkxk1" or Request.Form("submitflag") = "" Then%>
		  <b>根据ＩＰ地址屏蔽：直接输入需要屏蔽的ＩＰ地址</b>
          <form action=NewForbidIP.asp method=post id=fobform1 name=fobform1>
			起始ＩＰ地址：<input name=GBL_IPStart value="<%=htmlencode(GBL_IPStart)%>" class=fminpt><br>
			<input name=submitflag type=hidden value="LKOkxk1">
			终止ＩＰ地址：<input name=GBL_IPEnd value="<%=htmlencode(GBL_IPEnd)%>" class=fminpt><br>
			屏蔽时间选择：<select name=GBL_ExpiresTime>
							<%For N = 1 to 30
								If N = GBL_ExpiresTime Then
									Response.Write "<option value=" & N & " selected>屏蔽" & Right("0" & N,2) & "天</option>"
								Else
									Response.Write "<option value=" & N & ">屏蔽" & Right("0" & N,2) & "天</option>"
								End If
							Next%>
							<option value=0<%If GBL_ExpiresTime = 0 Then Response.Write " Selected"%>>永久屏蔽</option>
						</select>
						<br>
			屏蔽原因注明：<input name=GBL_WhyString MaxLength=100 size=30 value="<%=htmlencode(GBL_WhyString)%>" class=fminpt>
			<select onchange="$id('fobform1').GBL_WhyString.value=this.value;">
				<option value="">===一些常见原因请选择===</option>
				<option value="发表反动或色情内容">发表反动或色情内容</option>
				<option value="对论坛进行恶意攻击(黑客行为)">对论坛进行恶意攻击(黑客行为)</option>
				<option value="不停的恶意灌水或注册新用户">不停的恶意灌水或注册新用户</option>
			</select>
			<br><br>
			<input type=submit value="提交" class=fmbtn> <input type=reset value="取消" class=fmbtn></form>
			<br>
			<br>
			举例说明：<font color=888888 class=grayfont>比如屏蔽地址211.222.222.222，请在两个框中输入211.222.222.222<br>
			　　　　　屏蔽61.211.*.*，请在起始ＩＰ地址中输入61.211.0.0，终止ＩＰ地址<br>
			　　　　　中输入61.211.255.255</font><br><%End If%>
			<%If Request.Form("submitflag") = "LKOkxk2" or Request.Form("submitflag") = "" Then%>
			<br>
		  <b>根据在线用户名来屏蔽：输入需要屏蔽ＩＰ地址的在线用户名称</b>
          <form action=NewForbidIP.asp method=post id=fobform2 name=fobform2>
			在线的用户名：<input name=GBL_UserName value="<%=htmlencode(GBL_UserName)%>" class=fminpt><br>
			<input name=submitflag type=hidden value="LKOkxk2">
			屏蔽时间选择：<select name=GBL_ExpiresTime>
							<%For N = 1 to 30
								If N = GBL_ExpiresTime Then
									Response.Write "<option value=" & N & " selected>屏蔽" & Right("0" & N,2) & "天</option>"
								Else
									Response.Write "<option value=" & N & ">屏蔽" & Right("0" & N,2) & "天</option>"
								End If
							Next%>
							<option value=0<%If GBL_ExpiresTime = 0 Then Response.Write " Selected"%>>永久屏蔽</option>
						</select>
						<br>
			屏蔽原因注明：<input name=GBL_WhyString MaxLength=100 size=30 value="<%=htmlencode(GBL_WhyString)%>" class=fminpt>
			<select onchange="$id('fobform2').GBL_WhyString.value=this.value;">
				<option value="">===一些常见原因请选择===</option>
				<option value="发表反动或色情内容">发表反动或色情内容</option>
				<option value="对论坛进行恶意攻击(黑客行为)">对论坛进行恶意攻击(黑客行为)</option>
				<option value="不停的恶意灌水或注册新用户">不停的恶意灌水或注册新用户</option>
			</select>
			<br><br>
			<input type=submit value="提交" class=fmbtn> <input type=reset value="取消" class=fmbtn></form>
			<br><%
		End If%>

			<%If Request.Form("submitflag") = "LKOkxk3" or Request.Form("submitflag") = "" Then%>
			<br>
		 	<b>根据发表帖子来屏蔽：输入某用户所发表帖子的编号</b>
          	<form action=NewForbidIP.asp method=post id=fobform3 name=fobform3>
			论坛帖子编号：<input name=GBL_AnnounceID value="<%=htmlencode(GBL_AnnounceID)%>" class=fminpt><br>
			<input name=submitflag type=hidden value="LKOkxk3">
			屏蔽时间选择：<select name=GBL_ExpiresTime>
							<%For N = 1 to 30
								If N = GBL_ExpiresTime Then
									Response.Write "<option value=" & N & " selected>屏蔽" & Right("0" & N,2) & "天</option>"
								Else
									Response.Write "<option value=" & N & ">屏蔽" & Right("0" & N,2) & "天</option>"
								End If
							Next%>
							<option value=0<%If GBL_ExpiresTime = 0 Then Response.Write " Selected"%>>永久屏蔽</option>
						</select>
						<br>
			屏蔽原因注明：<input name=GBL_WhyString MaxLength=100 size=30 value="<%=htmlencode(GBL_WhyString)%>" class=fminpt>
			<select onchange="$id('fobform3').GBL_WhyString.value=this.value;">
				<option value="">===一些常见原因请选择===</option>
				<option value="发表反动或色情内容">发表反动或色情内容</option>
				<option value="对论坛进行恶意攻击(黑客行为)">对论坛进行恶意攻击(黑客行为)</option>
				<option value="不停的恶意灌水或注册新用户">不停的恶意灌水或注册新用户</option>
			</select>
			<br><br>
			<input type=submit value="提交" class=fmbtn> <input type=reset value="取消" class=fmbtn></form>
			<br>
			<br>使用说明：<font color=888888 class=grayfont>帖子的编号，在版面列表中，将鼠标放在最前面的图标上可以显示主题帖编号<br>
			　　　　　在查看帖子内容时，将鼠标放在心情符号上，可以显示主题帖或回复帖的编号</font><br><br><%
		End If%>
			

			<%If Request.Form("submitflag") = "LKOkxk4" or Request.Form("submitflag") = "" Then%>
			<br>
			<b>根据短消息编号来屏蔽：输入某用户所发送短消息的编号</b>
			<form action=NewForbidIP.asp method=post id=fobform4 name=fobform4>
			短消息的编号：<input name=GBL_MessageID value="<%=htmlencode(GBL_MessageID)%>" class=fminpt><br>
			<input name=submitflag type=hidden value="LKOkxk4">
			屏蔽时间选择：<select name=GBL_ExpiresTime>
							<%For N = 1 to 30
								If N = GBL_ExpiresTime Then
									Response.Write "<option value=" & N & " selected>屏蔽" & Right("0" & N,2) & "天</option>"
								Else
									Response.Write "<option value=" & N & ">屏蔽" & Right("0" & N,2) & "天</option>"
								End If
							Next%>
							<option value=0<%If GBL_ExpiresTime = 0 Then Response.Write " Selected"%>>永久屏蔽</option>
						</select>
						<br>
			屏蔽原因说明：<input name=GBL_WhyString MaxLength=100 size=30 value="<%=htmlencode(GBL_WhyString)%>" class=fminpt>
			<select onchange="$id('fobform4').GBL_WhyString.value=this.value;">
				<option value="">===一些常见原因请选择===</option>
				<option value="发表反动或色情内容">发表反动或色情内容</option>
				<option value="对论坛进行恶意攻击(黑客行为)">对论坛进行恶意攻击(黑客行为)</option>
				<option value="不停的恶意灌水或注册新用户">不停的恶意灌水或注册新用户</option>
			</select>
			<br><br>
			<input type=submit value="提交" class=fmbtn> <input type=reset value="取消" class=fmbtn></form>
			<br>
			<br>使用说明：<font color=888888 class=grayfont>短消息编号可以在查看收件箱列表中显示</font><br><br><%
	End If%>

<%End Function


Function FormatIPaddress(KIP)

	Dim IP
	IP = KIP
	Rem 除去两首的空点，并格式化成XXX.XXX.XXX.XXX
	Dim Temp1,Temp2,TempN,Temp
	IP = Trim(IP & "")
	If inStr(IP,".") = 0 or Len(IP) = "" Then
		FormatIPaddress = IP
		Exit Function
	End if
	
	Temp1 = Split(IP,".")
	IP = ""
	Temp2 = Ubound(Temp1,1)
	
	TempN = 0
	do while IP = ""
		If Temp1(TempN) <> "" Then
			if IsNumeric(Temp1(TempN)) Then Temp1(TempN) = cStr(cCur(Temp1(TempN)))
			If Len(Temp1(TempN)) < 3 Then
				IP = string(3-len(Temp1(TempN)),"0") & Temp1(TempN)
			else
				IP = Temp1(TempN)
			End If
			TempN = TempN + 1
			Exit Do
		Else
			TempN = TempN + 1
		End If
		If TempN > Temp2 Then Exit do
	Loop
	
	For Temp = TempN to Temp2
		If Temp1(TempN) <> "" Then
			If isNumeric(Temp1(TempN)) = 0 Then
				FormatIPaddress = ""
				Exit Function
			End If
			Temp1(TempN) = Fix(cCur(Temp1(TempN)))
			If Temp1(TempN) < 0 or Temp1(TempN) > 255 Then
				FormatIPaddress = ""
				Exit Function
			End If
			if IsNumeric(Temp1(TempN)) Then Temp1(TempN) = cStr(cCur(Temp1(TempN)))
			If Len(Temp1(TempN)) < 3 Then
				IP = IP & "." & string(3-len(Temp1(TempN)),"0") & Temp1(TempN)
			else
				IP = IP & "." & Temp1(TempN)
			End If
		End If
		TempN = TempN + 1
	Next
	FormatIPaddress = IP
	Rem 返回的IP地址刚好是15位，如果不是15个字符则是错误无效的IP地址

End Function


Rem 检测某用户名是否存在
Function CheckUserNameExist(UserName)

	If UserName <> "" and inStr(UserName,",") = 0 and inStr(Lcase(DEF_SupervisorUserName),"," & Lcase(UserName) & ",") > 0 Then
		'作这样的同样提示是为了以防管理员名字被泄漏，实际应该提示管理员不能被屏蔽
		GBL_CHK_TempStr = "错误，用户名" & htmlencode(UserName) & "不存在！"
		CheckUserNameExist = 0
		Exit Function
	End If

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select ID,UserName from LeadBBS_User where UserName='" & Replace(UserName,"'","''") & "'",1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		CheckUserNameExist = 0
		GBL_CHK_TempStr = "错误，用户名" & htmlencode(UserName) & "不存在！"
		Exit Function
	Else
		GBL_UserName_UserID = cCur(Rs(0))
		GBL_UserName = Rs(1)
	End if
	Rs.Close
	Set Rs = Nothing
	
	Set Rs = LDExeCute(sql_select("Select IP from LeadBBS_OnlineUser where UserID=" & GBL_UserName_UserID,1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		CheckUserNameExist = 0
		GBL_CHK_TempStr = "错误，用户名" & htmlencode(UserName) & "目前不在线，无法完成屏蔽，请使用其它的方式来屏蔽！"
		Exit Function
	Else
		GBL_IPStart = Rs(0)
		GBL_IPEnd = GBL_IPStart
		Rs.Close
		Set Rs = Nothing
	End if
		
	CheckUserNameExist = 1

End Function

Rem 检测某帖子
Function CheckAnnounceID(AnnounceID)

	If isNumeric(AnnounceID) = False Then
		GBL_CHK_TempStr = "错误，帖子并不存在或无权屏蔽！"
		CheckAnnounceID = 0
		Exit Function
	End If
	AnnounceID = Fix(cCur(AnnounceID))
	If AnnounceID < 1 Then
		GBL_CHK_TempStr = "错误，编号" & htmlencode(AnnounceID) & "的帖子并不存在或无权屏蔽！"
		CheckAnnounceID = 0
		Exit Function
	End If
	
	Dim Rs
	Set Rs = LDExeCute(sql_select("Select IPAddress,UserName from LeadBBS_Announce where ID=" & AnnounceID,1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		CheckAnnounceID = 0
		GBL_CHK_TempStr = "错误，编号" & htmlencode(AnnounceID) & "的帖子并不存在或无权屏蔽！"
		Exit Function
	Else
		GBL_IPStart = Rs(0)
		GBL_IPEnd = GBL_IPStart
		GBL_UserName = Rs(1)
	End if
	Rs.Close
	Set Rs = Nothing

	If GBL_UserName <> "" and inStr(GBL_UserName,",") = 0 and inStr(Lcase(DEF_SupervisorUserName),"," & Lcase(GBL_UserName) & ",") > 0 Then
		'作这样的同样提示是为了以防管理员名字被泄漏，实际应该提示管理员不能被屏蔽
		GBL_CHK_TempStr = "错误，编号" & htmlencode(AnnounceID) & "的帖子并不存在或无权屏蔽！"
		CheckAnnounceID = 0
		Exit Function
	End If
	CheckAnnounceID = 1

End Function


Rem 检测某帖子
Function CheckMessageID(MessageID)

	If isNumeric(MessageID) = False Then
		GBL_CHK_TempStr = "错误，短消息并不存在或无权屏蔽！"
		CheckMessageID = 0
		Exit Function
	End If
	MessageID = Fix(cCur(MessageID))
	If MessageID < 1 Then
		GBL_CHK_TempStr = "错误，编号" & htmlencode(MessageID) & "的短消息并不存在或无权屏蔽！"
		CheckMessageID = 0
		Exit Function
	End If
	
	Dim Rs
	Set Rs = LDExeCute(sql_select("Select IP,FromUser from LeadBBS_InfoBox where ID=" & MessageID,1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		CheckMessageID = 0
		GBL_CHK_TempStr = "错误，编号" & htmlencode(MessageID) & "的短消息并不存在或无权屏蔽！"
		Exit Function
	Else
		GBL_IPStart = Rs(0)
		GBL_IPEnd = GBL_IPStart
		GBL_UserName = Rs(1)
	End if
	Rs.Close
	Set Rs = Nothing

	If GBL_UserName <> "" and inStr(GBL_UserName,",") = 0 and inStr(Lcase(DEF_SupervisorUserName),"," & Lcase(GBL_UserName) & ",") > 0 Then
		'作这样的同样提示是为了以防管理员名字被泄漏，实际应该提示管理员不能被屏蔽
		GBL_CHK_TempStr = "错误，编号" & htmlencode(MessageID) & "的短消息并不存在或无权屏蔽！"
		CheckMessageID = 0
		Exit Function
	End If
	CheckMessageID = 1

End Function%>