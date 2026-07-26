<%
Function DisplayAnnouncesSplitPages

	Dim Rs,SQL,Temp,RootFlagStr,RootFlagStr1,RootFlag
	Dim ALL_FirstRootID,ALL_LastRootID

	Dim SQLEndString,WhereFlag,OrderColumn,BoardUrlString
	RootFlag = Left(Request.ServerVariables("QUERY_STRING"),1)
	If RootFlag <> "0" and RootFlag <> "1" and RootFlag <> "2" Then RootFlag = "0"
	If DEF_UsedDataBase = 1 Then
		If RootFlag = "0" Then RootFlag = "1" 'ACCESS数据库禁用查看全部帖子
	End If
	Select Case RootFlag
		Case "1":
			select case DEF_UsedDataBase
				case 0,2:
					OrderColumn = "RootIDBak"
				case Else
					OrderColumn = "ID"
			End select
			select case DEF_UsedDataBase
				case 0,2:
					WhereFlag = 1
					SQLEndString = " where ParentID=0 "
				case Else
					SQLEndString = " from LeadBBS_Topic "
			End select
			RootFlagStr = "主题"
			RootFlagStr1 = "<b>查看论坛全部主题</b>"
		Case "2":
			OrderColumn = "ID"
			WhereFlag = 1
			select case DEF_UsedDataBase
				case 0,2:
					SQLEndString = " where GoodFlag=1 "
				case Else
					SQLEndString = " from LeadBBS_Topic where GoodFlag=1 "
			End select
			RootFlagStr = "精华帖子"
			RootFlagStr1 = "查看论坛全部精华帖子"
		Case Else:
			WhereFlag = 0
			OrderColumn = "ID"
			select case DEF_UsedDataBase
				case 0,2:
				case Else
					SQLEndString = " from LeadBBS_Announce "
			End select
			RootFlagStr = "帖子"
			RootFlagStr1 = "<b>查看论坛全部帖子</b>"
	End Select
	BoardUrlString = "List.asp"
	select case DEF_UsedDataBase
		case 0,2:
			SQL = "Select Max(" & OrderColumn & ") from LeadBBS_Announce " & SQLEndString
		case Else
			SQL = "Select Max(" & OrderColumn & ") " & SQLEndString
	End select
	Set Rs = LDExeCute(SQL,0)
	If Not Rs.Eof Then
		ALL_FirstRootID = Rs(0)
		If isNull(ALL_FirstRootID) Then ALL_FirstRootID = 0
		ALL_FirstRootID = cCur(ALL_FirstRootID)
	Else
		ALL_FirstRootID = 0
	End If
	Rs.Close
	Set Rs = Nothing

	select case DEF_UsedDataBase
		case 0,2:
			SQL = "Select Min(" & OrderColumn & ") from LeadBBS_Announce " & SQLEndString
		case Else
			SQL = "Select Min(" & OrderColumn & ") " & SQLEndString
	End select
	Set Rs = LDExeCute(SQL,0)
	If Not Rs.Eof Then
		ALL_LastRootID = Rs(0)
		If isNull(ALL_LastRootID) Then ALL_LastRootID = 0
		ALL_LastRootID = cCur(ALL_LastRootID)
	Else
		ALL_LastRootID = 0
	End If
	Rs.Close
	Set Rs = Nothing
	Dim ALL_Count
	
	Rem SQL = "Select count(*) from LeadBBS_Announce " & SQLEndString
	Rem 下面的语句比上面的速度快,因为版面少,而当主题和帖子越多时,采下下面的速度就会越快
	
	If RootFlag <> "2" Then
		If RootFlag = "1" Then
			SQL = "Select sum(TopicNum) from LeadBBS_Boards"
		Else
			SQL = "Select sum(AnnounceNum) from LeadBBS_Boards"
		End If
	Else
		'SQL = "Select count(*) from LeadBBS_Announce " & SQLEndString
		SQL = "Select sum(GoodNum) from LeadBBS_Boards"
	End If
	Set Rs = LDExeCute(SQL,0)
	If Not Rs.Eof Then
		If isNull(Rs(0)) Then
			ALL_Count = 0
		Else
			ALL_Count = cCur(Rs(0))
		End If
	Else
		ALL_Count = 0
	End If
	Rs.Close
	Set Rs = Nothing
	Dim RootID,Temp1,Temp2
	Dim Upflag

	RootID = Left(Request.QueryString("RootID"),14)
	If isNumeric(RootID)=0 Then RootID=0
	RootID = cCur(RootID)

	Dim LastNum
	LastNum = 0

	Upflag = Request.QueryString("Upflag")
	If Upflag<>"1" and Upflag<>"0" Then Upflag="0"
	If Upflag = "1" Then
		LastNum = Request.QueryString("Num")
		If LastNum <> "" Then
			LastNum = (ALL_Count mod DEF_MaxListNum)
			If LastNum = 0 Then LastNum = DEF_MaxListNum
		End If
	End If	

	Dim HaveRootIDFlag
	Dim FirstRootID,LastRootID

	If Temp1+1<DEF_MaxListNum Then
		If Upflag="0" Then
			If RootID<>0 Then
				If WhereFlag = 1 Then
					SQLEndString = SQLEndString & " And " & OrderColumn & "<" & RootID
				Else
					SQLEndString = SQLEndString & " Where " & OrderColumn & "<" & RootID
					WhereFlag = 1
				End If
			End If
		Else
			If RootID>=ALL_FirstRootID Then
				RootID = ALL_FirstRootID-1
				TopicSortID = ALL_FirstRootID + 1
			
				If RootID<>0 Then
					If WhereFlag = 1 Then
						SQLEndString = SQLEndString & " And " & OrderColumn & ">" & RootID
					Else
						SQLEndString = SQLEndString & " Where " & OrderColumn & ">" & RootID
						WhereFlag = 1
					End If
				End If
			Else
				If RootID<>0 Then
					If WhereFlag = 1 Then
						SQLEndString = SQLEndString & " And " & OrderColumn & ">" & RootID
					Else
						SQLEndString = SQLEndString & " Where " & OrderColumn & ">" & RootID
						WhereFlag = 1
					End If
				End If
			End If
		End If

		If Upflag="0" Then
			SQLEndString = SQLEndString & " order by " & OrderColumn & " DESC"
		Else
			SQLEndString = SQLEndString & " order by " & OrderColumn & " ASC"
		End If

		Dim FirstRootID_2,LastRootID_2
		Dim GetData_2

		If LastNum > 0 Then
			Temp = LastNum
		Else
			Temp = DEF_MaxListNum
		End If

		select case DEF_UsedDataBase
			case 0,2:
				SQL = sql_select("select T1.id,T1.ParentID,T1.ChildNum,T1.Layer,T1.Title,T1.FaceIcon,T1.LastTime,T1.Hits,T1.Length,T1.UserName,T1.UserID,T1.RootIDBak,T1.TopicSortID,T1.LastUser,T1.NotReplay,T1.GoodFlag,T1.BoardID,T1.TopicType,T1.PollNum,T1.TitleStyle,T2.ForumPass,T2.BoardLimit,T2.OtherLimit,T2.HiddenFlag from LeadBBS_Announce as T1 left join LeadBBS_Boards as T2 on T1.BoardID=T2.BoardID " & SQLEndString,Temp)
			case Else
				If RootFlag = "1" or RootFlag = "2" Then
					SQL = sql_select("select T1.id,0,T1.ChildNum,0 as c0_dup2,T1.Title,T1.FaceIcon,T1.LastTime,T1.Hits,T1.Length,T1.UserName,T1.UserID,T1.ID as id_dup2,0 as c0_dup3,T1.LastUser,T1.NotReplay,T1.GoodFlag,T1.BoardID,T1.TopicType,T1.PollNum,T1.TitleStyle,T2.ForumPass,T2.BoardLimit,T2.OtherLimit,T2.HiddenFlag from LeadBBS_Topic as T1 left join LeadBBS_Boards as T2 on T1.BoardID=T2.BoardID " & Replace(SQLEndString," from LeadBBS_Topic",""),Temp)
				Else
					SQL = sql_select("select T1.id,T1.ParentID,T1.ChildNum,T1.Layer,T1.Title,T1.FaceIcon,T1.LastTime,T1.Hits,T1.Length,T1.UserName,T1.UserID,T1.RootIDBak,T1.TopicSortID,T1.LastUser,T1.NotReplay,T1.GoodFlag,T1.BoardID,T1.TopicType,T1.PollNum,T1.TitleStyle,T2.ForumPass,T2.BoardLimit,T2.OtherLimit,T2.HiddenFlag from LeadBBS_Announce as T1 left join LeadBBS_Boards as T2 on T1.BoardID=T2.BoardID " & Replace(SQLEndString," from LeadBBS_Announce",""),Temp)
				End If
		End select
		Set Rs = LDExeCute(SQL,0)
		If Not Rs.Eof Then
			HaveRootIDFlag = 1
			GetData_2 = Rs.GetRows(Temp)
		Else
			HaveRootIDFlag = 0
		End If
		Rs.Close
		Set Rs = Nothing

		If HaveRootIDFlag = 1 Then
			Temp2 = Ubound(GetData_2,2)
			If RootFlag = "1" Then
				FirstRootID_2 = cCur(GetData_2(11,0))
				LastRootID_2 = cCur(GetData_2(11,Temp2))
			Else
				FirstRootID_2 = cCur(GetData_2(0,0))
				LastRootID_2 = cCur(GetData_2(0,Temp2))
			End If
				
			If FirstRootID_2<LastRootID_2 Then
				SQL = FirstRootID_2
				FirstRootID_2 = LastRootID_2
				LastRootID_2 = SQL
			End If
	
			LastRootID = LastRootID_2
			FirstRootID = FirstRootID_2
		Else
			Temp2 = 0
		End If
	Else
		HaveRootIDFlag = 0
	End If

	SQL = "?" & urlencode(RootFlag) & "="
	Dim PageSplitString,PageSplitString2
	PageSplitString = "<div class=j_page>"
	If FirstRootID >= All_FirstRootID Then
		'PageSplitString = PageSplitString & "首页"
		'PageSplitString = PageSplitString & " 上页"
	Else
		PageSplitString = PageSplitString & "<a href=" & BoardUrlString & SQL & ">首页</a>"
		PageSplitString = PageSplitString & " <a href=" & BoardUrlString & SQL & "&RootID=" & FirstRootID & "&Upflag=1>上页</a>"
	End If

	If LastRootID <= All_LastRootID Then
		'PageSplitString = PageSplitString & " 下页"
		'PageSplitString = PageSplitString & " 尾页"
	Else
		PageSplitString = PageSplitString & " <a href=" & BoardUrlString & SQL & "&RootID=" & LastRootID & ">下页</a>"
		PageSplitString = PageSplitString & " <a href=" & BoardUrlString & SQL & "&Upflag=1&Num=1>尾页</a>"
	End If
	Rs = Temp1
	Rs = Temp2+Rs
	If HaveRootIDFlag = 1 Then Rs = Rs+1

	PageSplitString = PageSplitString & "<b>共" & ALL_Count &"</b>"
	' & RootFlagStr & " 此页<b>" & Rs & "</b>条 每页<b>" & DEF_MaxListNum & "</b>条<td align=right><img src=" & DEF_BBS_HomeUrl & "images/null.gif width=2 height=2><br>"
	PageSplitString = PageSplitString & "</div>"
	If Rs < DEF_MaxListNum and GBL_ShowBottomSure = 0 Then GBL_SiteBottomString = ""

	Dim For1,For2,StepValue
	List_NavInfo(RootFlag)%>
	
	<table width=100% border="0" cellspacing="0" cellpadding="0" class=table_in>
	</td></tr>
	<tr class=tbinhead>
		<!-- <td width=40><div class=value>&nbsp;</div></td> -->
		<td><div class=value>主题</div></td>
		<td width=110><div class=value>作者</div></b></td>
		<td width=70><div class=value>回复/点击</div></td>
		<td width=110><div class=value>最后更新/回复人</div></td>
	</tr><%
	If Upflag="0" Then
		If HaveRootIDFlag = 1 Then
			If Upflag="0" Then
				For1 = 0
				For2 = Temp2
				StepValue = 1
			Else
				For1 = Temp2
				For2 = 0
				StepValue = -1
			End If
			Call DisplayAnnounceData(For1,For2,StepValue,GetData_2,0)
		End If
	Else

		If HaveRootIDFlag = 1 Then
			If Upflag="0" Then
				For1 = 0
				For2 = Temp2
				StepValue = 1
			Else
				For1 = Temp2
				For2 = 0
				StepValue = -1
			End If
			Call DisplayAnnounceData(For1,For2,StepValue,GetData_2,0)
		End If
	End If
	Response.Write "<tr><td colspan=4 class=tdbox>"
	Response.Write PageSplitString
	Response.Write "</td></tr></table>"

End Function


Sub List_NavInfo(RootFlag)

	Response.Write "<div class='user_item_nav fire'><ul>"
	Response.Write "<li><div class=name>论坛帖子</div></li>"
	select case DEF_UsedDataBase
		case 0,2:
			If RootFlag <> "2" and RootFlag <> "1" Then
				Response.Write "	<li><div class=navactive><span>全部帖子</span></div></li>"
			Else
				Response.Write "	<li><a href=List.asp?0>全部帖子</a></li>"
			End If
	End select
	If RootFlag = "1" Then
		Response.Write "	<li><div class=navactive>全部主题</div></li>"
	Else
		Response.Write "	<li><a href=List.asp?1>全部主题</a></li>"
	End If
	If RootFlag = "2" Then
		Response.Write "	<li><div class=navactive>全部精华</div></li>"
	Else
		Response.Write "	<li><a href=List.asp?2>全部精华</a></li>"
	End If
	Response.Write "</ul></div>"	

End Sub

Function DisplayAnnounceData(For1,For2,StepValue,GetData,AllFlag)
	
	Dim ReAncStr
	Dim SuperFlag
	SuperFlag = CheckSupervisorUserName()
	If SuperFlag = 1 Then
	%>	<script language=javascript>
	function opw(f,r,id)
	{
		window.open(f+'&'+r+'='+id,'delwin','width=450,height=37,scrollbars=auto,status=yes');
	}
	</script>
	<%
	End If

	Dim N,Temp,Temp1,B_Now
	B_Now = Left(LngStr(GetTimeValue(DEF_Now)),8)
	For N = For1 to For2 Step StepValue
		Response.Write "<tr>"
		'Response.Write "<td class=tdbox align=center>"

		'If cCur(GetData(11,N))>=DEF_BBS_TOPMinID And cCur(GetData(1,N))=0 Then
		'	Temp = "intop"
		'Else
		'	If GetData(17,n) = 80 Then
		'		If cCur(GetData(18,N)) >= 20 Then
		'			Temp = "vthot"
		'		Else
		'			Temp = "vt"
		'		End If
		'	Else
		'		If cCur(GetData(2,N)) >= 20 Then
		'			Temp = "hot"
		'		Else
		'			Temp = "tpc"
		'		End If
		'	End If
		'	If GetData(14,n) = 1 Then Temp = Temp & "lock"
		'End If
		'Response.Write "<img src=../images/" & GBL_DefineImage & Temp & ".gif align=absbottom title=""编号" & GetData(0,N) & """>"
		'Response.Write "</td>"
		Response.Write "<td class=tdbox>"

		Rem 不显示Layer值
		'If GetData(3,N)>DEF_BBS_MaxLayer Then GetData(3,N)=10
		'Response.Write Replace(string((GetData(3,N)-1),"-"),"-","<ul>")
		'Response.Write "<img src=../images/" & GBL_DefineImage & "bf/face" & GetData(5,N) & ".gif align=absbottom>"

		GetData(8,N) = cCur(GetData(8,N))
		If GetData(8,N) > 1024 Then
			GetData(8,N) = cLng(GetData(8,N)/1024) & " KB"
		Else
			GetData(8,N) = GetData(8,N) & " 字节"
		End If

		If cCur(GetData(1,n)) = 0 Then
			ReAncStr = ""
		Else
			ReAncStr = "&RID=" & GetData(0,N) & "#F" & GetData(0,N)
		End If
		Response.Write " <a href=../a/a.asp?B=" & GetData(16,N) & "&ID=" & GetData(11,N) & ReAncStr & " title=""" & htmlEncode(GetData(8,N)) & """"
		If AllFlag = 1 Then
			Response.Write " target=_blank>"
		Else
			Response.Write ">"
		End If

		GetData(2,N) = cCur(GetData(2,N))
		Temp1 = Fix((GetData(2,N)+1)/DEF_TopicContentMaxListNum)
		If ((GetData(2,N)+1) mod DEF_TopicContentMaxListNum) > 0 Then Temp1 = Temp1 + 1
		If GetData(2,N)>=DEF_TopicContentMaxListNum Then
			Temp = DEF_BBS_DisplayTopicLength - (Len(Temp1) + 4)
		Else
			Temp = DEF_BBS_DisplayTopicLength - 1
		End If
		
		If ccur(GetData(15,n)) = 1 Then Temp = Temp - 3

		If GBL_NoneLimitFlag = 0 and GBL_CheckLimitTitle(GetData(20,n),GetData(21,n),GetData(22,n),GetData(23,n)) = 1 Then
			GetData(4,n) = "<span calss=grayfont>此帖子标题已设置为隐藏</span>"
			GetData(19,n) = 1
		End If
		If left(GetData(4,N),3) = "re:" and GetData(4,N) <> "re:" Then GetData(4,N) = Mid(GetData(4,N),4)
		If GetData(19,n) <> 1 Then
			If strLength(GetData(4,N))>Temp-1 Then GetData(4,N) = LeftTrue(GetData(4,N),Temp-4) & "..."
		Else
			If strLength(GetData(4,N))>Temp-1 Then GetData(4,N) = LeftTrueHTML(GetData(4,N),Temp-4)
		End If
		Response.Write DisplayAnnounceTitle(GetData(4,n),GetData(19,n))
		Response.Write "</a>"

		If GetData(2,N)>=DEF_TopicContentMaxListNum Then
			Response.Write " [<a href=../a/a.asp?B=" & GetData(16,N) & "&ID=" & GetData(0,N) & "&AUpflag=1&ANum=1>" & Temp1 & "</b></a>]"
		End If

		'If ccur(GetData(15,n)) = 1 Then
		'	Response.Write "<img src=../images/" & GBL_DefineImage & "jh1.GIF border=0 title=精华帖子 align=absbottom width=15 height=16>"
		'End If

		GetData(10,N) = cCur(GetData(10,N))
		If GetData(10,N) > 0 Then
			Response.Write "</td><td class=tdbox><a href=../User/LookUserInfo.asp?ID=" & GetData(10,N) & ">" & htmlencode(GetData(9,N)) & "</a>"
		Else
			Response.Write "</td><td class=tdbox>" & htmlencode(GetData(9,N)) & ""
		End If
		
		If SuperFlag = 1 Then
			Response.Write " <a href='javascript:opw(""../" & DEF_ManageDir & "/User/DelUserAllAnnounce.asp?B=" & GBL_board_ID & """,""DelUserID""," & GetData(10,n) & ");' title=删除此用户的好友资料，帖子收藏，发表帖子，上传附件等资料，不减" & DEF_PointsName(0) & ">删资料</a>"
		End If
		Response.Write "</td><td class=tdbox>"
		

		If isNull(GetData(18,N)) Then GetData(18,N) = 0
		If GetData(17,n) = 80 Then
			Response.Write "共" & cCur(GetData(18,N)) & "票"
		Else
			Response.Write "<span class=num>" & GetData(2,N) & "/" & GetData(7,N) & "</span>"
		End If
		Response.Write "</td><td class=tdbox>"
		If Left(GetData(6,N),8) = B_Now Then
			GetData(6,N) = "<span class=redfont><em>" & Mid(GetData(6,N),1,4) & "-" & Mid(GetData(6,N),5,2) & "-" & Mid(GetData(6,N),7,2) & " " & Mid(GetData(6,N),9,2) & ":" & Mid(GetData(6,N),11,2) & "</em></span>"
		Else
			GetData(6,N) = "<em>" & Mid(GetData(6,N),1,4) & "-" & Mid(GetData(6,N),5,2) & "-" & Mid(GetData(6,N),7,2) & " " & Mid(GetData(6,N),9,2) & ":" & Mid(GetData(6,N),11,2) & "</em>"
		End If
		If GetData(13,n) = "" or isNull(GetData(13,n)) Then
			Response.Write "<a href=../User/LookUserInfo.asp?ID=" & GetData(10,N) & ">" & htmlencode(GetData(9,N)) & "</a> "
		Else
			If GetData(10,N) <> "游客" Then
				Response.Write "<a href=" & DEF_BBS_HomeUrl & "User/LookUserInfo.asp?name=" & urlencode(GetData(13,N)) & ">" & htmlencode(GetData(13,n)) & "</a>"
			Else
				Response.Write "" & htmlencode(GetData(13,n))
			End If
		End if
		Response.Write "<br>" & GetData(6,N) & "</td></tr>"
	Next

End Function
%>