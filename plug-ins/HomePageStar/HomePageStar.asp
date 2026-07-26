<!--#include file="Inc/StarSetup.asp"-->
<%
Dim GBL_PLUG_HPS_DataOne,GBL_PLUG_HPS_DataTwo
GBL_PLUG_HPS_DataOne = Application(DEF_MasterCookies & "_PLUG_HPS_DAY")
GBL_PLUG_HPS_DataTwo = Application(DEF_MasterCookies & "_PLUG_HPS_OTHER")

Dim GBL_PLUG_HPS_Str1,GBL_PLUG_HPS_Str2
Dim GBL_PLUG_HPS_RefreshEnable
GBL_PLUG_HPS_RefreshEnable = 0

Sub FUN_PLUG_HPS_GetDayStarData

	Dim TimeM
	TimeM = Application(DEF_MasterCookies & "_PLUG_HPS_M")
	If isNull(TimeM) or isNumeric(TimeM) = False Then
		TimeM = 0
		TimeM = Minute(DEF_Now)
		Application.Lock
		Application(DEF_MasterCookies & "_PLUG_HPS_M") = TimeM
		Application.UnLock
	Else
		If (isArray(GBL_PLUG_HPS_DataTwo) = False and GBL_PLUG_HPS_Str2 <> "") or (isArray(GBL_PLUG_HPS_DataOne) = False and GBL_PLUG_HPS_Str1 <> "") or (Minute(DEF_Now) - TimeM) >= GBL_PLUG_HPS_RefreshSpace or (Minute(DEF_Now) - TimeM) < 0 Then
		Else
			If GBL_PLUG_HPS_RefreshEnable = 0 Then Exit Sub
		End If
	End If

	GBL_PLUG_HPS_RefreshEnable = 1

	Dim SQL,Rs,N
	If GBL_PLUG_HPS_Str1 <> "" Then
		Set Rs = LDExeCute(GBL_PLUG_HPS_Str1,0)
		If Not Rs.Eof Then
			GBL_PLUG_HPS_DataOne = Rs.GetRows(GBL_PLUG_HPS_TopMax)
			Rs.Close
			Set Rs = Nothing
			For N = 0 To Ubound(GBL_PLUG_HPS_DataOne,2)
				Set Rs = LDExeCute(sql_select("Select UserName from LeadBBS_User where ID=" & GBL_PLUG_HPS_DataOne(0,N),1),0)
				If Not Rs.Eof Then
					GBL_PLUG_HPS_DataOne(0,N) = Rs(0)
				Else
					GBL_PLUG_HPS_DataOne(0,N) = ""
				End If
				Rs.Close
				Set Rs = Nothing
			Next
			Application.Lock
			Application(DEF_MasterCookies & "_PLUG_HPS_DAY") = GBL_PLUG_HPS_DataOne
			Application.UnLock
		Else
			Rs.Close
			Set Rs = Nothing
		End If
	End If

	If (GBL_PLUG_HPS_Str2 <> "") Then
		Set Rs = LDExeCute(GBL_PLUG_HPS_Str2,0)
		If Not Rs.Eof Then
			GBL_PLUG_HPS_DataTwo = Rs.GetRows(GBL_PLUG_HPS_TopMax)
			Rs.Close
			Set Rs = Nothing
			For N = 0 To Ubound(GBL_PLUG_HPS_DataTwo,2)
				Set Rs = LDExeCute(sql_select("Select UserName,TrueName,ID,Userphoto,FaceUrl from LeadBBS_User where ID=" & GBL_PLUG_HPS_DataTwo(0,N),1),0)
				
				If Not Rs.Eof Then
					GBL_PLUG_HPS_DataTwo(0,N) = Rs(0)
					GBL_PLUG_HPS_DataTwo(2,N) = Rs(1)
					GBL_PLUG_HPS_DataTwo(3,N) = Rs(2)
					GBL_PLUG_HPS_DataTwo(4,N) = Rs(3)
					GBL_PLUG_HPS_DataTwo(5,N) = Rs(4)
				Else
					GBL_PLUG_HPS_DataTwo(0,N) = ""
					GBL_PLUG_HPS_DataTwo(2,N) = ""
					GBL_PLUG_HPS_DataTwo(3,N) = ""
					GBL_PLUG_HPS_DataTwo(4,N) = ""
					GBL_PLUG_HPS_DataTwo(5,N) = ""
				End If
				Rs.Close
				Set Rs = Nothing
			Next
			Application.Lock
			Application(DEF_MasterCookies & "_PLUG_HPS_OTHER") = GBL_PLUG_HPS_DataTwo
			Application.UnLock
		Else
			Rs.Close
			Set Rs = Nothing
		End If
	End If

	Application.Lock
	Application(DEF_MasterCookies & "_PLUG_HPS_M") = Minute(DEF_Now)
	Application.UnLock

End Sub

Sub LeadBBSHomePageStar()

	If GBL_PLUG_HPS_ShowType < 1 and (CheckSupervisorNameOnly = 0 or GBL_UserID <= 0) Then Exit Sub
	
	If ((GBL_PLUG_HPS_ShowType = 1 or GBL_PLUG_HPS_ShowType = 3) and (GBL_PLUG_HPS_LineSecondType > 0)) or ((GBL_PLUG_HPS_ShowType = 1 or GBL_PLUG_HPS_ShowType = 2) and (GBL_PLUG_HPS_LineFirstType > 0)) Then
	Else
		If (CheckSupervisorNameOnly = 0 or GBL_UserID <= 0) Then Exit Sub
	End If

	Dim CFlag
	If inStr(OpenAssort,",bstar,") > 0 or (GBL_PLUG_HPS_Collapse = 0 and inStr(CloseAssort,",bstar,") = 0) Then
		CFlag = 0
	Else
		CFlag = 1
	End If%>
	<div class="contentbox">
	<table border="0" cellspacing="0" cellpadding="0" width="100%" class="tablebox">
	<tr class="tbhead">
		<td><script>var bstar=<%
			If CFlag = 1 Then
				Response.Write "0"
			Else
				Response.Write "1"
			End If%>;</script>
			<div class="b_assort">
			<div class="b_assort_title"><span class="clicktext" title="关闭/展开" onclick="bstar=(bstar==0)?1:0;LD.blist.assort_click('bstar',bstar,1);"><img src="<%=DEF_BBS_HomeUrl%>images/blank.gif" id="b_assort_img_bstar" class="b_assort_close<%
			If CFlag = 1 Then Response.Write "_swap"%>" alt="关闭/展开" /></span>
				<b>社区明星</b>
			</div>
			</div>
		</td>
	</tr>
	</table>
	<div id="b_assort_bstar"<%If CFlag = 1 Then  Response.Write " style=""display:none"""%>>
	<% 
	If Request("action1") <> "HomePageStar" and (GBL_PLUG_HPS_ShowType = 1 or GBL_PLUG_HPS_ShowType = 2) and (GBL_PLUG_HPS_LineFirstType > 0) Then
		%><table border="0" cellspacing="0" cellpadding="0" width="100%" class="tablebox">
		<tr><td class="tdbox">
			<div class="b_list_box">
				<%Call FUN_PLUG_HPS_HomePageStar()%>
			</div>
		</td>
		</tr></table>
		<%
	End If
	If (GBL_PLUG_HPS_ShowType = 1 or GBL_PLUG_HPS_ShowType = 3) and (GBL_PLUG_HPS_LineSecondType > 0) Then
	%>
				<%FUN_PLUG_HPS_HomePageStarTop%>
	<%
	End If%>
	<%
	If CheckSupervisorNameOnly = 1 Then%>
		<table border="0" cellspacing="0" cellpadding="0" width="100%" class="tablebox">
		<tr>
			<td class="tdbox" align="right">
				<div class="b_list_box">
				<a href="plug-ins/HomePageStar/admin_HomePageStar.asp">显示方式设置</a>
				</div>
			</td>
		</tr>
		</table>
	<%End If%>
	</div>
	</div>
    <%

End Sub

Sub FUN_PLUG_HPS_HomePageStar()

	'头部文件
	%>
	<table border="0" cellspacing="0" cellpadding="0" class="blanktable" width="100%"><tr>
	<%

	Dim SQL,Rs,F_or_M,UserName,AnnounceNum,TempLineStr,UserID,UserID2,AnnounceNum2,UserName2
	Dim NTime,WTime,YTime,MTime

	'每日发帖
	NTime = cCur(Left(GetTimeValue(DEF_Now),8) & "000000")

	'每周灌水
	WTime = cCur(Left(GetTimeValue(DateAdd("d",0-WeekDay(DEF_Now,2),DEF_Now)),8) & "000000")

	'本年发帖
	YTime = cCur(Left(GetTimeValue(DEF_Now),4) & "0000000000")

	'本月发帖
	MTime = cCur(Left(GetTimeValue(DEF_Now),6) & "00000000")
	'显示第一列的头像
	Select Case GBL_PLUG_HPS_LineFirstType
		Case 1
			TempLineStr = "今日"
			SQL = sql_select("Select UserID,Count(UserID) from LeadBBS_Announce Where NDateTime>=" & NTime & " Group By UserID Order by Count(UserID) DESC",GBL_PLUG_HPS_TopMax)
		Case 2
			TempLineStr = "本周"
			SQL = sql_select("Select UserID,Count(UserID) from LeadBBS_Announce Where NDateTime>=" & WTime & " Group By UserID Order by Count(UserID) DESC",GBL_PLUG_HPS_TopMax)
		Case 3
			TempLineStr = "本月"
			SQL = sql_select("Select UserID,Count(UserID) from LeadBBS_Announce Where NDateTime>=" & MTime & " Group By UserID Order by Count(UserID) DESC",GBL_PLUG_HPS_TopMax)
		Case 4
			TempLineStr = "今年"
			SQL = sql_select("Select UserID,Count(UserID) from LeadBBS_Announce Where NDateTime>=" & YTime & " Group By UserID Order by Count(UserID) DESC",GBL_PLUG_HPS_TopMax)
		Case 5
			TempLineStr = "真正"
			SQL = sql_select("Select ID,AnnounceNum from LeadBBS_User Order By AnnounceNum DESC",GBL_PLUG_HPS_TopMax)
		'Case 6
		'	TempLineStr = "帅哥"
		'		sql_select(SQL = "Select ID,AnnounceNum ID from LeadBBS_User Where Sex='男' Order By AnnounceNum DESC",GBL_PLUG_HPS_TopMax)
		'Case 7
		'	TempLineStr = "靓妹"
		'	SQL = sql_select("Select ID,AnnounceNum from LeadBBS_User Where Sex='女' Order By AnnounceNum DESC",GBL_PLUG_HPS_TopMax)
		Case Else
			GBL_PLUG_HPS_LineFirstType = 1
			TempLineStr = "今日"
			SQL = sql_select("Select UserID,Count(UserID) from LeadBBS_Announce Where NDateTime>=" & NTime & " Group By UserID Order by Count(UserID) DESC",GBL_PLUG_HPS_TopMax)
	End Select
	GBL_PLUG_HPS_Str1 = SQL
	FUN_PLUG_HPS_GetDayStarData

	Dim GetData,GetDataUserData1,GetDataUserData2
	GetData = GBL_PLUG_HPS_DataOne

	If isArray(GetData) = False Then
		%>
			<td valign="middle" align="center" width="20%"><img src="<%=DEF_BBS_HomeUrl%>images/face/0000.gif" alt="头像" /></td>
			<td valign="top" width="30%"><strong>
			<%=TempLineStr%>灌水状元
			</strong><br /><br />
			用户姓名：<span class="bluefont">等你来改写</span><br />
			
			社区<%=DEF_PointsName(3)%>：<img src="<%=DEF_BBS_HomeUrl%>images/lvstar/level0.gif" alt="等级" />
			<br /><%=TempLineStr%>发帖：0 篇
			<br />个人<%=DEF_PointsName(0)%>：无
			<br />个人<%=DEF_PointsName(1)%>：无
	        	<br />个人<%=DEF_PointsName(2)%>：无
			<br />社区<%=DEF_PointsName(4)%>：无
			<br />E&nbsp;-&nbsp;Mail：空
			</td>
		<%
	Else
		Dim Flag,LoopN
		Flag = 0

		For LoopN = 0 to 2
			If LoopN > Ubound(GetData,2) or Flag = 2 Then Exit For
			If Flag = 1 Then
				UserName2 = GetData(0,LoopN)
				AnnounceNum2 = cCur("0" & GetData(1,LoopN))
				SQL = sql_select("Select Mail,Sex,UserPhoto,UserLevel,Points,OnlineTime,AnnounceNum,FaceWidth,FaceHeight,CharmPoint,FaceUrl,CachetValue,UserName,ID,TrueName from LeadBBS_User Where UserName='" & Replace(UserName2,"'","''") & "'",1)
				Set Rs = LDExeCute(SQL,0)
				If Not Rs.Eof Then
					GetDataUserData2 = Rs.GetRows(1)
					Flag = 2
				Else
					Flag = 1
				End If
			ElseIf Flag = 0 Then
				UserName = GetData(0,LoopN)
				AnnounceNum = cCur("0" & GetData(1,LoopN))
				SQL = sql_select("Select Mail,Sex,UserPhoto,UserLevel,Points,OnlineTime,AnnounceNum,FaceWidth,FaceHeight,CharmPoint,FaceUrl,CachetValue,UserName,ID,TrueName from LeadBBS_User Where UserName='" & Replace(UserName,"'","''") & "'",1)
				Set Rs = LDExeCute(SQL,0)
				If Not Rs.Eof Then
					GetDataUserData1 = Rs.GetRows(1)
					Flag = 1
				Else
					Flag = 0
				End If
			End If
		Next

		Dim Mail,Sex,UserPhoto,UserLevel,Points,OnlineTime,FaceWidth,FaceHeight,CharmPoint,FaceUrl,CachetValue
		Dim UID,TrueName
		If isArray(GetDataUserData1) Then
			Mail = GetDataUserData1(0,0)
			Sex = GetDataUserData1(1,0)
			UserPhoto = GetDataUserData1(2,0)
			UserLevel = GetDataUserData1(3,0)
			Points = GetDataUserData1(4,0)
			OnlineTime = GetDataUserData1(5,0)
			'AnnounceNum = GetDataUserData1(6,0)
			FaceWidth = GetDataUserData1(7,0)
			FaceHeight = GetDataUserData1(8,0)
			CharmPoint = GetDataUserData1(9,0)
			FaceUrl = GetDataUserData1(10,0)
			CachetValue = cCur(GetDataUserData1(11,0))
			UID = GetDataUserData1(13,0)
			TrueName = GetDataUserData1(14,0)
		Else
			UserName = "无"
			Mail = "无"
			Sex = "无"
			UserPhoto = ""
			UserLevel = 0
			Points = 0
			OnlineTime = 0
			AnnounceNum = 0
			FaceWidth = DEF_AllFaceMaxWidth
			FaceHeight = DEF_AllFaceMaxWidth*2
			CharmPoint = 0
			FaceUrl = ""
			CachetValue = 0
			UID = 0
			TrueName = ""
		End If

		If Sex = "男" Then
			F_or_M = DEF_BBS_HomeUrl & "images/sxmg/Male.gif"
		ElseIf Sex = "女" Then
			F_or_M = DEF_BBS_HomeUrl & "images/sxmg/FeMale.gif"
        Else
			F_or_M = DEF_BBS_HomeUrl & "images/sxmg/Male.gif"
		End If
		%>
			<td valign="middle" align="center" width="20%">
				<a href="User/<%=RW_User(UID,"","","")%>" target="_blank">
				<img src="<%
		If FaceWidth > DEF_AllFaceMaxWidth Then FaceWidth = DEF_AllFaceMaxWidth
		If FaceHeight > DEF_AllFaceMaxWidth*2 Then FaceHeight = DEF_AllFaceMaxWidth
		If DEF_AllDefineFace <> 0 and FaceUrl <> "" Then
			If Lcase(Left(FaceUrl,5)) <> "http:" Then
				FaceUrl = DEF_BBS_HomeUrl & Replace(htmlencode(FaceUrl),"../","")
			Else
				FaceUrl = htmlencode(FaceUrl)
			End If
			%><%=FaceUrl%>" width="<%=FaceWidth%>" height="<%=FaceHeight%>"<%
		Else
			%>images/face/<%=String(4-len(CStr(UserPhoto)),"0") & UserPhoto%>.gif"
		<%End If%> title="看什么看,我是明星！！" alt="头像" /></a>
			</td>
			<td valign="middle" width="30%">
				<strong>
        			<%=TempLineStr%>灌水状元
        			</strong>
        			<br /><br />
				用户姓名：<span class="bluefont"><%=GetTrueName(UserName,TrueName)%></span><br />
				社区<%=DEF_PointsName(3)%>：<img src="images/<%=GBL_DefineImage%>lvstar/level<%=UserLevel%>.gif" align="middle" alt="等级" /><br />
				<%=TempLineStr%>发帖：<%=AnnounceNum%> 篇
				<br />个人<%=DEF_PointsName(0)%>：<%=cCur(Points)%>
				<br />个人<%=DEF_PointsName(1)%>：<%=CharmPoint%>
		<%
        	If CachetValue <> 0 Then
			If CachetValue > 0 Then
				CachetValue = "<span class=""bluefont"">＋" & CachetValue & "</span>"
			End If
		Else
			CachetValue = "还需多加努力！" 
		End If
		%>
			<br />个人<%=DEF_PointsName(2)%>：<%=CachetValue%>
			<br />社区<%=DEF_PointsName(4)%>：<%=Fix(cCur(OnlineTime)/60)%>	
			
		<%
		If Trim(Mail) <> "" Then
			'Response.Write("<a href=""Mailto:" & htmlencode(Mail) & """>飞鸽传书</a>")
		End If
		%>
			</td><%
	End If

	If isArray(GetDataUserData2) = False Then
		%>
			<td valign="middle" align="center" width="20%">
				<img src="<%=DEF_BBS_HomeUrl%>images/face/0000.gif" alt="头像" />
			</td>
			<td valign="top" width="30%">
				<strong>
				<%=TempLineStr%>灌水榜眼
				</strong>
				<br /><br />
				用户姓名：<span class="bluefont">等你来改写</span> <br />
			社区<%=DEF_PointsName(3)%>：<img src="<%=DEF_BBS_HomeUrl%>images/lvstar/level0.gif" alt="等级" />
			<br /><%=TempLineStr%>发帖：0 篇
			<br />个人<%=DEF_PointsName(0)%>：无
			<br />个人<%=DEF_PointsName(1)%>：无
			<br />个人<%=DEF_PointsName(2)%>：无
			<br />社区<%=DEF_PointsName(4)%>：无
			</td>
		<%
  	Else
		AnnounceNum = AnnounceNum2
		UserName = UserName2
		If isArray(GetDataUserData2) Then
			Mail = GetDataUserData2(0,0)
			Sex = GetDataUserData2(1,0)
			UserPhoto = GetDataUserData2(2,0)
			UserLevel = GetDataUserData2(3,0)
			Points = GetDataUserData2(4,0)
			OnlineTime = GetDataUserData2(5,0)
			'AnnounceNum = GetDataUserData2(6,0)
			FaceWidth = GetDataUserData2(7,0)
			FaceHeight = GetDataUserData2(8,0)
			CharmPoint = GetDataUserData2(9,0)
			FaceUrl = GetDataUserData2(10,0)
			CachetValue = cCur(GetDataUserData2(11,0))
			UID = GetDataUserData2(13,0)
			TrueName = GetDataUserData2(14,0)
		Else
			UserName = "无"
			Mail = "无"
			Sex = "无"
			UserPhoto = ""
			UserLevel = 0
			Points = 0
			OnlineTime = 0
			AnnounceNum = 0
			FaceWidth = DEF_AllFaceMaxWidth
			FaceHeight = DEF_AllFaceMaxWidth*2
			CharmPoint = 0
			FaceUrl = ""
			CachetValue = 0
			UID = 0
			TrueName = ""
		End If

		If Sex = "男" Then
			F_or_M = DEF_BBS_HomeUrl & "images/sxmg/Male.gif"
		ElseIf Sex = "女" Then
			F_or_M = DEF_BBS_HomeUrl & "images/sxmg/FeMale.gif"
		Else
			F_or_M = DEF_BBS_HomeUrl & "images/sxmg/Male.gif"
		End If
		%>
			<td valign="middle" align="center" width="20%">
				<a href="User/<%=RW_User(UID,"","","")%>" target="_blank">
				<img src="<% 
		If FaceWidth > DEF_AllFaceMaxWidth Then FaceWidth = DEF_AllFaceMaxWidth
		If FaceHeight > DEF_AllFaceMaxWidth*2 Then FaceHeight = DEF_AllFaceMaxWidth
		If DEF_AllDefineFace <> 0 and FaceUrl <> "" Then
			If Lcase(Left(FaceUrl,5)) <> "http:" Then
				FaceUrl = DEF_BBS_HomeUrl & Replace(htmlencode(FaceUrl),"../","")
			Else
				FaceUrl = htmlencode(FaceUrl)
			End If
			Response.Write FaceUrl & Chr(34) & " width=""" & FaceWidth & """ height=""" & FaceHeight & """"
		Else
			Response.Write "images/face/" & String(4-len(CStr(UserPhoto)),"0") & UserPhoto & ".gif"""
		End If%> title="看什么看,我是明星！！" alt="头像" /></a>
			</td>
			<td valign="top" width="30%">
				<strong>
				<%=TempLineStr%>灌水榜眼
				</strong>
				<br /><br />
				用户姓名：<span class="bluefont"><%=GetTrueName(UserName,TrueName)%></span>
				<br />
				社区<%=DEF_PointsName(3)%>：<img src="images/<%=GBL_DefineImage%>lvstar/level<%=UserLevel%>.gif" align="middle" alt="等级" />
				<br />
				<%=TempLineStr%>发帖：<%=AnnounceNum%> 篇
				<br />个人<%=DEF_PointsName(0)%>：<%=Points%>
				<br />个人<%=DEF_PointsName(1)%>：<%=CharmPoint%>
		<%
		If CachetValue <> 0 Then
			If CachetValue > 0 Then
				CachetValue = "<span class=""bluefont"">＋" & CachetValue & "</span>"
			End If
		Else
			CachetValue = "还需多加努力！"
		End If%>
			<br />个人<%=DEF_PointsName(2)%>：<%=CachetValue%>
			<br />社区<%=DEF_PointsName(4)%>：<%=Fix(cCur(OnlineTime)/60)%>	
			
		<%
		If Trim(Mail) <> "" Then
	  		'Response.Write("<a href=""Mailto:" & htmlencode(Mail) & """>飞鸽传书</a>")
		End If
		%>
			</td><%
	End If

	'尾部文件
	Response.Write("</tr></table>")

End Sub 

Sub FUN_PLUG_HPS_HomePageStarTop

	Dim NTime,WTime,YTime,MTime,SQL

	'每日发帖
	NTime = cCur(Left(GetTimeValue(DEF_Now),8) & "000000")

	'每周灌水
	WTime = cCur(Left(GetTimeValue(DateAdd("d",0-WeekDay(DEF_Now,2),DEF_Now)),8) & "000000")

	'本年发帖
	YTime = cCur(Left(GetTimeValue(DEF_Now),4) & "0000000000")

	'本月发帖
	MTime = cCur(Left(GetTimeValue(DEF_Now),6) & "00000000")
	'显示第一列的头像
	Dim TempLineStr
	Select Case GBL_PLUG_HPS_LineSecondType
		Case 1
			TempLineStr = "今日"
			SQL = sql_select("Select UserID,Count(UserID),'',0,'','' from LeadBBS_Announce Where NDateTime>=" & NTime & " Group By UserID Order by Count(UserID) DESC",GBL_PLUG_HPS_TopMax)
		Case 2
			TempLineStr = "本周"
			SQL = sql_select("Select UserID,Count(UserID),'',0,'','' from LeadBBS_Announce Where NDateTime>=" & WTime & " Group By UserID Order by Count(UserID) DESC",GBL_PLUG_HPS_TopMax)
		Case 3
			TempLineStr = "本月"
			SQL = sql_select("Select UserID,Count(UserID),'',0,'','' from LeadBBS_Announce Where NDateTime>=" & MTime & " Group By UserID Order by Count(UserID) DESC",GBL_PLUG_HPS_TopMax)
		Case 4
			TempLineStr = "今年"
			SQL = sql_select("Select UserID,Count(UserID),'',0,'','' from LeadBBS_Announce Where NDateTime>=" & YTime & " Group By UserID Order by Count(UserID) DESC",GBL_PLUG_HPS_TopMax)
		Case 5
			TempLineStr = "真正"
			SQL = sql_select("Select ID,AnnounceNum,'',0,'','' from LeadBBS_User Order By AnnounceNum DESC",GBL_PLUG_HPS_TopMax)
		Case Else
			GBL_PLUG_HPS_LineSecondType = 1
			TempLineStr = "今日"
			SQL = sql_select("Select UserID,Count(UserID),'',0,'','' from LeadBBS_Announce Where NDateTime>=" & NTime & " Group By UserID Order by Count(UserID) DESC",GBL_PLUG_HPS_TopMax)
	End Select
	GBL_PLUG_HPS_Str2 = SQL
	FUN_PLUG_HPS_GetDayStarData

	If isArray(GBL_PLUG_HPS_DataTwo) = False Then Exit Sub
	Dim N
	%>
	<table border="0" cellspacing="0" cellpadding="0" width="100%" class="tablebox">
	<tr>
	<td class="tdbox">
		<div class="b_list_box">
			<table border="0" cellspacing="0" cellpadding="0" width="100%">
			<tr>
			<td>
<ul style="padding:0;margin:0;">
<%
	dim Form_userphoto,Form_FaceUrl,name
	For N = 0 to Ubound(GBL_PLUG_HPS_DataTwo,2)
		'Response.Write "hps(""" & GBL_PLUG_HPS_DataTwo(0,N) & """," & GBL_PLUG_HPS_DataTwo(1,N) & ");" & VbCrLf
		If GBL_PLUG_HPS_DataTwo(0,N) = "" then GBL_PLUG_HPS_DataTwo(0,N) = "游客"
		
		name = GetTrueName(GBL_PLUG_HPS_DataTwo(0,N),GBL_PLUG_HPS_DataTwo(2,N))
		%>
		<li style="padding:0;margin:0 12px 16px 0;*margin:0 0 16px 0;*width:72px;width:60px;overflow:hidden;text-align:center;display:block;float:left;">
		<a href="User/<%=RW_User(GBL_PLUG_HPS_DataTwo(3,N),"","","")%>" target="_blank" title="<%=htmlencode(name)%> <%=TempLineStr%>灌水: <%=GBL_PLUG_HPS_DataTwo(1,N)%>">
		<span style="margin-bottom:6px;width:60px;height:60px;line-height:60px;display:block;vertical-align:bottom;text-align:center;">
		<img style="margin-bottom:6px;border-radius:5%;max-width:60px;max-height:60px;_width:60px;_height:60px;" <%
			Form_userphoto = GBL_PLUG_HPS_DataTwo(4,N)
			Form_FaceUrl = GBL_PLUG_HPS_DataTwo(5,N)
			If isNull(Form_FaceUrl) Then Form_FaceUrl = ""
			if left(Form_FaceUrl,3) = "../" then Form_FaceUrl = mid(Form_FaceUrl,4)
			If DEF_AllDefineFace = 0 or Trim(Form_FaceUrl) = "" Then%>src=<%=DEF_BBS_HomeUrl%>images/face/<%=string(4-len(cstr(Form_userphoto)),"0")&Form_userphoto%>.gif align=middle>
			<%Else%>src="<%=htmlencode(Form_FaceUrl)%>" align=middle><%End If%>
			</span>
		<span style="white-space:nowrap;word-wrap:normal;">
		<%
		if strlength(name) > 7 then name = lefttrue(name,4) & "..."
		response.write name
		%>&nbsp;<%=GBL_PLUG_HPS_DataTwo(1,N)%>
		</span>
		</a></li>
		<%
	Next%>
</ul>
				</td>
			</tr>
			</table>
			</div>
		</td>
	</tr>
	</table>
	<%

End Sub%>