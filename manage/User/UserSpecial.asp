<!-- #include file=../../inc/BBSsetup.asp -->
<!-- #include file=../../inc/Board_popfun.asp -->
<!-- #include file=../inc/bbsmanage_Fun.asp -->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo
DisplayUserNavigate("特殊用户管理")%>
<div class=frameline>提示：在这里，你只能查看到某一类的特殊用户，如果要更改他们的权限或属性，请点击修改进入更改．
</div>
		<%
		If GBL_CHK_Flag=1 Then
			%>
			<div class=frameline>
			<%
			SpecialUserBrowser%>
			</div>
			<div class=frameline>
			<a href=NewSpecialUser.asp?GBL_Assort=0>添加<%=DEF_PointsName(5)%></a>
			<a href=NewSpecialUser.asp?GBL_Assort=3>添加屏蔽发言内容用户</a>
			<a href=NewSpecialUser.asp?GBL_Assort=4>添加禁言用户</a>
			<a href=NewSpecialUser.asp?GBL_Assort=5>添加禁止修改用户</a>
			<a href=NewSpecialUser.asp?GBL_Assort=6>强制用户退回未激活状态</a>
			<a href=NewSpecialUser.asp?GBL_Assort=8>添加<%=DEF_PointsName(10)%></a>
			</div>
		<%
		Else
			DisplayLoginForm
		End If
frame_BottomInfo
closeDataBase
Manage_Sitebottom("none")

Function SpecialUserBrowser

	GBL_CHK_TempStr=""
	Dim Rs,SQL
	Dim UpDownPageFlag
	UpDownPageFlag = Request("UpDownPageFlag")
	
	Dim Assort
	Assort = Left(Request.QueryString("Assort"),14)
	If isNumeric(Assort) = 0 Then Assort = 0
	Assort = Fix(cCur(Assort))
	If Assort < 0 or Assort > 8 then Assort = 0

	Dim Start,RecordCount,key
	RecordCount=0
	
	Dim SQLendString

	Start = Left(Trim(Request("Start")),14)
	Start = start
	If isNumeric(Start)=0 or Start="" Then Start=0
	Start = cCur(Start)
	key = Request.Form("key")
	If key="" Then key = Request("key")

	Dim SQLCountString,whereFlag
	SQLendString=""
	SQLendString = " where T1.Assort=" & Assort
	whereFlag = 1

	If key<>"" Then
		If whereFlag = 1 Then
			SQLendString = SQLendString & " and T1.UserName like'" & Replace(key,"'","''") & "%'"
		Else
			SQLendString = SQLendString & " where T1.UserName like'" & Replace(key,"'","''") & "%'"
			whereFlag = 1
		End If
	End If
	SQLCountString = SQLendString
	If UpDownPageFlag = "1" and Start>0 then
		If whereFlag = 1 Then
			SQLendString = SQLendString & " and T1.ID<" & Start
		Else
			SQLendString = SQLendString & " where T1.ID<" & Start
			whereFlag = 1
		End If
	Else
		If whereFlag = 1 Then
			SQLendString = SQLendString & " and T1.ID>" & Start
		Else
			SQLendString = SQLendString & " where T1.ID>" & Start
			whereFlag = 1
		End If
	end If
	
	If UpDownPageFlag = "1" then
		'If DEF_IDFocusFlag<> 2 Then SQLendString = SQLendString & " Order by  T1.ID DESC"
		SQLendString = SQLendString & " Order by  T1.ID DESC"
	Else
		'If DEF_IDFocusFlag<> 1 Then SQLendString = SQLendString & " Order by  T1.ID ASC"
		SQLendString = SQLendString & " Order by  T1.ID ASC"
	End If
	
	Dim MaxRecordID,MinRecordID
	MaxRecordID = 0

	SQL = "select Max(T1.id) from LeadBBS_SpecialUser as T1 " & SQLCountString
	Set Rs = LDExeCute(SQL,0)
	
	If not Rs.Eof Then
		If Rs(0) <> "" Then
			MaxRecordID = cCur(Rs(0))
		Else
			MaxRecordID = 0
		End If
	End If
	Rs.Close
	Set Rs = Nothing
	
	SQL = "select Min(id) from LeadBBS_SpecialUser as T1 " & SQLCountString
	Set Rs = LDExeCute(SQL,0)

	If not Rs.Eof Then
		If Rs(0) <> "" Then
			MinRecordID = cCur(Rs(0))
		else
			MinRecordID = 0
		end If
	End If

	Rs.Close
	Set Rs = Nothing

	Dim FirstID,LastID	
	SQL = "select count(*) from LeadBBS_SpecialUser as T1 " & SQLCountString
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof then
		RecordCount=0
	Else
		RecordCount = rs(0)
		if RecordCount="" or isNull(RecordCount) or len(RecordCount)<1 Then RecordCount=0
		RecordCount = ccur(RecordCount)
	End If
	Rs.Close
	Set Rs = Nothing

	SQL = sql_select("select T1.ID,T1.UserID,T1.UserName,T1.ndatetime,T1.Assort,t2.BoardName,T1.BoardID,T1.WhyString,T1.ExpiresTime from LeadBBS_SpecialUser as T1 left join LeadBBS_Boards as T2 on T1.BoardID=T2.BoardID" & SQLendString,DEF_MaxListNum)

	Set Rs = LDExeCute(SQL,0)
	Dim Num
	Dim GetData
	If Not rs.Eof Then
		GetData = Rs.GetRows(-1)
		Num = Ubound(GetData,2) + 1
	Else
		Num = 0
	End If
	Rs.close
	Set Rs = Nothing
	
	Dim i,N
	
	If Assort = 0 Then
		Response.Write " [" & DEF_PointsName(5) & "]"
	Else
		Response.Write " [<a href=UserSpecial.asp?assort=0>" & DEF_PointsName(5) & "</a>]"
	End If
	
	If Assort = 1 Then
		Response.Write " [版主]"
	Else
		Response.Write " [<a href=UserSpecial.asp?assort=1>版主</a>]"
	End If
	
	If Assort = 2 Then
		Response.Write " [" & DEF_PointsName(6) & "]"
	Else
		Response.Write " [<a href=UserSpecial.asp?assort=2>" & DEF_PointsName(6) & "</a>]"
	End If
	
	If Assort = 3 Then
		Response.Write " [屏蔽发言]"
	Else
		Response.Write " [<a href=UserSpecial.asp?assort=3>屏蔽发言</a>]"
	End If
	
	If Assort = 4 Then
		Response.Write " [禁止发言]"
	Else
		Response.Write " [<a href=UserSpecial.asp?assort=4>禁止发言</a>]"
	End If
	
	If Assort = 5 Then
		Response.Write " [禁止修改]"
	Else
		Response.Write " [<a href=UserSpecial.asp?assort=5>禁止修改</a>]"
	End If
	
	If Assort = 6 Then
		Response.Write " [待激活会员]"
	Else
		Response.Write " [<a href=UserSpecial.asp?assort=6>待激活会员</a>]"
	End If

	If Assort = 7 Then
		Response.Write " [" & DEF_PointsName(7) & "]"
	Else
		Response.Write " [<a href=UserSpecial.asp?assort=7>" & DEF_PointsName(7) & "</a>]"
	End If

	If Assort = 8 Then
		Response.Write " [" & DEF_PointsName(10) & "]"
	Else
		Response.Write " [<a href=UserSpecial.asp?assort=8>" & DEF_PointsName(10) & "</a>]"
	End If
	If Num>0 Then
		i=1
	Dim MinN,MaxN,StepValue
	SQL = ubound(getdata,2)
	If UpDownPageFlag = "1" then
		MinN = SQL
		MaxN = 0
		StepValue = -1
	Else
		MinN = 0
		MaxN = SQL
		StepValue = 1
	End If
	
	LastID = cCur(GetData(0,MaxN))
	FirstID = cCur(GetData(0,MinN))
	
	
	Dim EndwriteQueryString,PageSplictString
	EndwriteQueryString = "?Assort=" & Assort
	If key<>"" Then EndwriteQueryString = EndwriteQueryString & "&key=" & urlencode(key)

	PageSplictString = PageSplictString & "<table border=0 cellspacing=0 cellpadding=0><tr><td>&nbsp;"
	if FirstID>MinRecordID and FirstID<>0 then
		PageSplictString = PageSplictString & "<a href=UserSpecial.asp" & EndwriteQueryString & "&Start=0&SubmitFlag=3829EwoqIaNfoG>首页</a> " & VbCrLf
	else
		PageSplictString = PageSplictString & "<span class=grayfont>首页</span> " & VbCrLf
	end if

	if FirstID > MinRecordID and FirstID<>0 then
		PageSplictString = PageSplictString & " <a href=UserSpecial.asp" & EndwriteQueryString & "&Start=" & FirstID & "&UpDownPageFlag=1&SubmitFlag=3829EwoqIaNfoG>上页</a> " & VbCrLf
	else
		PageSplictString = PageSplictString & " <span class=grayfont>上页</span> " & VbCrLf
	end if

	if LastID<MaxRecordID and LastID<>0 then
		PageSplictString = PageSplictString & " <a href=UserSpecial.asp" & EndwriteQueryString & "&Start=" & LastID & "&SubmitFlag=3829EwoqIaNfoG>下页</a> " & VbCrLf
	else
		PageSplictString = PageSplictString & " <span class=grayfont>下页</span> " & VbCrLf
	end if

	if LastID < MaxRecordID and LastID<>0 then
		PageSplictString = PageSplictString & " <a href=UserSpecial.asp" & EndwriteQueryString & "&Start=" & MaxRecordID+1 & "&UpDownPageFlag=1&SubmitFlag=3829EwoqIaNfoG>尾页</a> " & VbCrLf
	else
		PageSplictString = PageSplictString & " <span class=grayfont>尾页</span> " & VbCrLf
	end if
	PageSplictString = PageSplictString & "共<b>" & RecordCount & "</b>条信息"
	If (RecordCount mod DEF_MaxListNum)=0 Then
		PageSplictString = PageSplictString & " 计<b>" & clng(RecordCount/DEF_MaxListNum) & "</b>页"
	Else
		If RecordCount>=DEF_MaxListNum Then
			PageSplictString = PageSplictString & " 计<b>" & clng(RecordCount/DEF_MaxListNum)+1 & "</b>页"
		Else
			PageSplictString = PageSplictString & " 计<b>1</b>页"
		End If
	End If
	PageSplictString = PageSplictString & " 每页<b>" & DEF_MaxListNum & "</b>条记录"
	PageSplictString = PageSplictString & "</td><td><form action=UserSpecial.asp?assort=" & assort & " method=post><input size=6 name=key value=" & chr(34) & htmlencode(key) & """ class=fminpt><input type=submit name=submit value=搜 class=fmbtn></td></form></tr></table>"
	%>
	<table border=0 cellpadding=0 cellspacing=0 width="100%" class=frame_table>
	<tr class=frame_tbhead>
		<td width=66><div class=value>ID</div></td>
		<td><div class=value>名称</div></td>
		<td width=120><div class=value>更新时间</div></td>
		<td width=66><div class=value>类型</div></td><%If Assort = 1 Then%>
		<td><div class=value>版面</div></td><%End If
		If Assort = 6 Then%>
		<td><div class=value>激活码</div></td><%End If%>
		<td><div class=value>说明及有效时间</div></td>
	</tr>
	<%
	for n= MinN to MaxN Step StepValue%>
	<tr height="19" class=TBBG9>
		<td class=tdbox><%=GetData(0,n)%></td>
		<td class=tdbox>
			<a href=<%=DEF_BBS_HomeUrl%>User/LookUserInfo.asp?id=<%=GetData(1,n)%>><%=htmlencode(GetData(2,n))%></a>
			<a href=UserModify.asp?Form_ID=<%=GetData(1,n)%>><font color=008800 class=greenfont>修</font></a></td>
		<td class=tdbox><%=RestoreTime(Left(GetData(3,n),8))%></td>
		<td class=tdbox><%
			Select Case GetData(4,n)
				Case 0: Response.Write DEF_PointsName(5)
				Case 1: Response.Write "版主"
				Case 2: Response.Write DEF_PointsName(6)
				Case 3: Response.Write "屏蔽发言"
				Case 4: Response.Write "禁止发言"
				Case 5: Response.Write "禁止修改"
				Case 6: Response.Write "等待认证"
				Case 7: Response.Write DEF_PointsName(7)
				Case 8: Response.Write DEF_PointsName(10)
			End Select%></td><%If Assort = 1 Then%>
		<td class=tdbox><a href=../ForumBoard/ForumBoardModify.asp?GBL_ModifyID=<%=GetData(6,n)%>><%=GetData(5,n)%></a></td><%End If
			If Assort = 6 Then
				If cCur(GetData(6,n)) = 0 Then
					Response.Write "<td width=60>无<br>(不能自启)</td>"
				Else%>
		<td class=tdbox><a href=../../User/UserGetPass.asp?act=active&user=<%=htmlencode(GetData(2,n))%>><%=GetData(6,n)%></a></td><%
				End If
			End If%>
		<td class=tdbox><%
			If GetData(7,n) <> "" Then Response.Write htmlencode(GetData(7,n)) & "<br>"
			If cCur(GetData(8,n)) > 0 Then
				Response.Write "<font color=gray class=grayfont>到期：" & RestoreTime(GetData(8,n))
			Else
				Response.Write "<font color=gray class=grayfont>永久有效"
			End If%>
		</td>
		</tr><%
			i=i+1
			if i>DEF_MaxListNum then exit for
		next
%>
		<tr>
			<td colspan=6> 
				<%=PageSplictString%>
			</td>
		</tr>
		</table>
	<%
	Else
		Response.Write "<br>" & GBL_CHK_TempStr & "		<tr><td><br><p>没有符合条件的记录。</td></tr>" & VbCrLf
	End If%>
	<%

End Function
%>