<!-- #include file=../inc/BBSsetup.asp -->
<!-- #include file=../inc/Board_Popfun.asp -->
<!-- #include file=inc/UserTopic.asp -->
<%
DEF_BBS_HomeUrl = "../"
Dim GBL_ID,GBL_Name

GBL_CHK_TempStr = ""

initDatabase

SiteHead(DEF_SiteNameString & " - 用户会员区")
UpdateOnlineUserAtInfo GBL_board_ID,"查看我的帖子收藏夹"

If GBL_ID = 0 and GBL_Name = "" Then
	If GBL_ID = 0 Then GBL_ID = GBL_UserID
	GBL_CHK_TempStr = ""
	If GBL_ID = 0 Then
		GBL_CHK_TempStr = "找不到用户，要查看自己的资料请先登录。<br>" & VbCrLf
	End If
Else
	If GBL_ID <> 0 Then GBL_Name = ""
	GBL_CHK_TempStr = ""
End If

Global_TableHead
%>
<table width="<%=DEF_BBS_ScreenWidth%>" border="0" cellspacing="1" cellpadding="0" align="center" bgcolor="<%=DEF_BBS_DarkColor%>" class=TBone>
<tr>
	<td valign="top" bgcolor=<%=DEF_BBS_LightColor%> class=TBBG1>
		<table width="100%" border="0" cellspacing="0" cellpadding="5" align="center">
		<tr> 
			<td height="20"><img src=../images/NULL.GIF height=3 width=2><br><%DisplayUserNavigate("我的帖子收藏夹")%>
			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
<img src=../images/NULL.GIF wdith=2 height=2><table width="<%=DEF_BBS_ScreenWidth%>" border="0" cellspacing="0" cellpadding="0" align="center">
<tr>
	<td valign="top">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
		<tr> 
			<td height="20">
            <%if GBL_CHK_TempStr <> "" Then
            	Response.Write "<p align=left><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font><hr size=1>"
            Else
            	GBL_CHK_TempStr = ""
            	DisplayCenter
            End If%>
			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
<%Global_TableBottom
closeDataBase
SiteBottom
If GBL_ShowBottomSure = 1 Then Response.Write GBL_SiteBottomString

Function DisplayCenter

	Dim Rs,SQL
	
	GBL_CHK_TempStr=""
	Dim UpDownPageFlag
	UpDownPageFlag = Request("UpDownPageFlag")

	Dim Start,key
	
	Dim SQLendString
	Dim FirstID,LastID,RecordCount

	Start = Left(Trim(Request("Start")),14)
	Start = start
	If isNumeric(Start)=0 or Start="" Then Start=999999999
	Start = cCur(Start)
	If Start = 0 Then Start=999999999

	Dim SQLCountString,whereFlag
	whereFlag = 1
	SQLendString = " where T1.UserID=" & GBL_ID

	SQLCountString = SQLendString
	If UpDownPageFlag = "1" and Start>0 then
		If whereFlag = 1 Then
			SQLendString = SQLendString & " and T1.ID>" & Start
		Else
			SQLendString = SQLendString & " where T1.ID>" & Start
			whereFlag = 1
		End If
	Else
		If whereFlag = 1 Then
			SQLendString = SQLendString & " and T1.ID<" & Start
		Else
			SQLendString = SQLendString & " where T1.ID<" & Start
			whereFlag = 1
		End If
	End If

	If UpDownPageFlag = "1" then
		SQLendString = SQLendString & " Order by T1.ID ASC"
	Else
		SQLendString = SQLendString & " Order by T1.ID DESC"
	End If
	
	Dim MaxRecordID,MinRecordID
	MaxRecordID = 0

	SQL = "select count(*) from LeadBBS_CollectAnc as T1 " & SQLCountString
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof then
		RecordCount=0
	Else
		RecordCount=rs(0)
		If RecordCount="" or isNull(RecordCount) or len(RecordCount)<1 Then RecordCount=0
		RecordCount = ccur(RecordCount)
	End If
	Rs.Close
	Set Rs = Nothing

	If RecordCount > 0 Then
		SQL = "select Max(T1.id) from LeadBBS_CollectAnc as T1 " & SQLCountString
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
		
		SQL = "select Min(T1.id) from LeadBBS_CollectAnc as T1 " & SQLCountString
		Set Rs = LDExeCute(SQL,0)
	
		If not Rs.Eof Then
			If Rs(0) <> "" Then
				MinRecordID = cCur(Rs(0))
			Else
				MinRecordID = 0
			End If
		End If
		Rs.Close
		Set Rs = Nothing
	
		SQL = sql_select("select T1.ID,T2.Title,T2.Length,T2.ndatetime,T2.Hits,T2.FaceIcon,T2.ChildNum,T2.BoardID,T2.GoodFlag,T2.Username,T2.ID,T2.TitleStyle from LeadBBS_CollectAnc as T1 Left join LeadBBS_Announce as T2 on T1.AnnounceID=T2.ID " & SQLendString,DEF_MaxListNum)
		Set Rs = LDExeCute(SQL,0)
		Dim Num
		Dim GetData
		If Not rs.Eof Then
			GetData = Rs.GetRows(DEF_MaxListNum)
			Num = Ubound(GetData,2)
		Else
			Num = -1
		End If
		Rs.close
		Set Rs = Nothing
	Else
		Num = -1
		MinRecordID = 0
		MaxRecordID = 0
	End If

	Dim i,N
	If Num>=0 Then
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
		EndwriteQueryString = "?ID=" & GBL_ID
		If key<>"" Then EndwriteQueryString = EndwriteQueryString & "&key=" & urlencode(key)
	
		PageSplictString = PageSplictString & "&nbsp;"
		If FirstID >= MaxRecordID Then
			PageSplictString = PageSplictString & "<font color=999999 class=grayfont>首页</font> " & VbCrLf
			PageSplictString = PageSplictString & " <font color=999999 class=grayfont>上页</font> " & VbCrLf
		Else
			PageSplictString = PageSplictString & "<a href=UserCollect.asp" & EndwriteQueryString & "&Start=0>首页</a> " & VbCrLf
			PageSplictString = PageSplictString & " <a href=UserCollect.asp" & EndwriteQueryString & "&Start=" & FirstID & "&UpDownPageFlag=1>上页</a> " & VbCrLf
		End If
	
		If LastID<MaxRecordID and LastID<>0 then
		Else
		End If
	
		If LastID <= MinRecordID Then
			PageSplictString = PageSplictString & " <font color=999999 class=grayfont>下页</font> " & VbCrLf
			PageSplictString = PageSplictString & " <font color=999999 class=grayfont>尾页</font> " & VbCrLf
		Else
			PageSplictString = PageSplictString & " <a href=UserCollect.asp" & EndwriteQueryString & "&Start=" & LastID & ">下页</a> " & VbCrLf
			PageSplictString = PageSplictString & " <a href=UserCollect.asp" & EndwriteQueryString & "&Start=1&UpDownPageFlag=1>尾页</a> " & VbCrLf
		End If

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
		PageSplictString = PageSplictString & " 每页<b>" & DEF_MaxListNum & "</b>条收藏帖"
	
	End If
	%>
	
	<script language=javascript>
		function kill(killID)
		{
			window.open('DelCollect.asp?B=<%=GBL_board_ID%>&DelID='+killID,'','width=450,height=37,scrollbars=auto,status=no');
		}
		function killall(str)
		{
			window.open('DelCollect.asp?kasdie=3&ClearFlag='+str,'','width=450,height=37,scrollbars=auto,status=no');
		}
	</script>
	<table width="100%" border="0" cellspacing="1" cellpadding="3" bordercolor="#000000" bgcolor="<%=DEF_BBS_DarkColor%>" class=TBone>
	  <tbody> 
	  <tr height="19" bgcolor=<%=DEF_BBS_LightDarkColor%> class=TBHead2>
	    <td width=20 align=center>&nbsp;</td>
	    <td><img src=../images/null.GIF width=151 height=2><br>&nbsp;<b><font color=ffffff class=HeadFont>主题</font></b>&nbsp;</td>
	    <td width=54 align=center><img src=<%=DEF_BBS_HomeUrl%>images/null.gif width=2 height=2><br><span title="回复/点击"><font color=ffffff class=HeadFont><b>人气</b></font></span></td>
	    <td width=210 align=left><img src=../images/null.gif width=5 height=2><br><img src=../images/null.gif width=3 height=2><font color=ffffff class=HeadFont><b>　　发表时间　　| 作者</b></font></td>
	    <td width=20 align=center><font color=ffffff class=HeadFont><b>删</b></font></td>
	  </tr>
	<%
	If Num = -1 Then
		response.write "<tr bgcolor=" & DEF_BBS_LightestColor & " class=TBBG9><td colspan=5 height=30>&nbsp; 没有任何主题!</td></tr>"
	End If

	Dim TempN,Temp,Temp1
	
	If Num <> -1 then
		i=1
		LastID = GetData(0,ubound(getdata,2))
		For n= MinN to MaxN Step StepValue
			If isNull(GetData(6,N)) Then
				GetData(1,n) = "<font color=gray class=grayfont>该收藏帖已经不存在(原编号" & GetData(0,n) & ")，已经被管理员删除。</font>"
				GetData(0,n) = 0
				GetData(2,n) = 0
				GetData(3,n) = "19000101000000"
				GetData(4,n) = 0
				GetData(5,n) = 0
				GetData(6,n) = 0
				GetData(7,n) = 0
				GetData(8,n) = 0
				GetData(9,n) = "游客"
				GetData(10,n) = ""
				GetData(11,n) = 1
			Else
				GetData(0,n) = cCur(GetData(0,n))
			End If
			Response.Write "<tr height=" & DEF_LineHeight & " bgcolor=" & DEF_BBS_LightestColor & " class=TBBG9><td>"
			Response.Write "<img src=../images/bf/face" & GetData(5,N) & ".gif align=absbottom width=20> "
			Response.Write "</td><td>&nbsp;"
			If GetData(0,n) > 0 Then Response.Write "<a href=../a/a.asp?B=" & GetData(7,n) & "&ID=" & GetData(10,N) & ">"

			GetData(6,N) = cCur(GetData(6,N))
			Temp1 = Fix((GetData(6,N)+1)/DEF_TopicContentMaxListNum)
			If ((GetData(6,N)+1) mod DEF_TopicContentMaxListNum) > 0 Then Temp1 = Temp1 + 1
			If GetData(6,N)>=DEF_TopicContentMaxListNum Then
				Temp = DEF_BBS_DisplayTopicLength - (Len(Temp1) + 3)
			Else
				Temp = DEF_BBS_DisplayTopicLength
			End If
		
			If ccur(GetData(8,n)) = True Then Temp = Temp - 3
			
			If GetData(11,n) <> 1 and strLength(GetData(1,N))>Temp-1 Then GetData(1,N) = LeftTrue(GetData(1,N),Temp-4) & "..."
			Response.Write DisplayAnnounceTitle(GetData(1,n),GetData(11,n))
			If GetData(0,n) > 0 Then Response.Write "</a>"

			If GetData(6,N)>=DEF_TopicContentMaxListNum Then
				Response.Write " [<a href=../a/a.asp?B=" & GetData(7,N) & "&ID=" & GetData(10,N) & "&AUpflag=1&ANum=1 title=" & GetData(2,n) & "字节>" & Temp1 & "</b></a>]"
			End If

			If ccur(GetData(8,n)) = 1 Then
				Response.Write "<img src=../images/" & GBL_DefineImage & "jh1.GIF border=0 title=精华帖子 align=absbottom width=16 height=16>"
			End If
			Response.Write "</td><td align=center width=50>&nbsp;"
			Response.Write GetData(6,N) & "/" & GetData(4,N)
			Response.Write "</td><td width=210>&nbsp;"
			If GetData(9,n) <> "游客" then
				Response.Write Left(RestoreTime(GetData(3,n)),16) & " | <a href=LookUserInfo.asp?name=" & urlencode(GetData(9,n)) & ">" & htmlencode(GetData(9,n)) & "</a></td>"
			Else
				Response.Write Left(RestoreTime(GetData(3,n)),16) & " | " & htmlencode(GetData(9,n)) & "</td>"
			End If
			Response.Write "<td align=center><a href='javascript:kill(" & GetData(0,n) & ");'><img src=../images/" & GBL_DefineImage & "Del.GIF border=0 title=删除此帖子 align=absmiddle width=16 height=16></a></td>"
			Response.Write "</tr>" & VbCrLf
			i=i+1
		Next
	End If
	Response.Write "<tr bgcolor=" & DEF_BBS_TableHeadColor & " class=TBfour><td colspan=5>" & PageSplictString
	%>
	&nbsp;<a href='javascript:killall("dkeJje5");'><img src=../images/<%=GBL_DefineImage%>clear.gif width=16 border=0 align=absmiddle>清空我的收藏夹</a>
	<%If GBL_UserID>0 and CheckSupervisorUserName = 1 Then%><a href='javascript:killall("dkeJje6");'><img src=../images/<%=GBL_DefineImage%>clear.gif width=16 border=0 align=absmiddle>清空所有人的收藏夹</a><%End If%>
	<%Response.Write "</td></tr>"%>
	      </table><%

End Function
%>