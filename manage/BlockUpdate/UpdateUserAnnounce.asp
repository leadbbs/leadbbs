<%
sub UpdateUserAnnounce()

	If CheckSupervisorUserName = 0 or GBL_UserID = 0 Then Exit sub

	Dim ReCount
	ReCount = Request("ReCount")
	If ReCount <> "1" Then ReCount = ""
	If Request("SureFlag") <> "E72ksiOkw2" Then
		%>
			<p>重新统计所有用户发帖数量(<%
			if ReCount <> "1" then response.write "不"%>重计<%=DEF_PointsName(0)%>)
			<form action=UpdateUnderWritePrintColumn.asp method=post>
			<b><font color=ff0000 class=redfont>确定此操作吗?<br>
			<br>
			<input type=hidden name=SureFlag value="E72ksiOkw2">
			<input type=hidden name=ReCount value="<%=ReCount%>">
			<input type=hidden name=flag value="<%=htmlencode(GBL_MANAGE_Flag)%>">
			
			<input type=submit value=确定进行 class=fmbtn>
			</form>
		<%
	Else
		Dim NowID,EndFlag,Temp
		NowID = 0
		EndFlag = 0
		Dim Rs,SQL
		Dim AnnounceNum,AnnounceTopic,AnnounceGood,UploadNum
		Dim GetData,N		
	
		Dim RecordCount,CountIndex
		SQL = "Select count(*) from LeadBBS_User"
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			RecordCount = 0
		Else
			RecordCount = Rs(0)
			If isNull(RecordCount) Then RecordCount = 0
			RecordCount = ccur(RecordCount)
		End If
		Rs.Close
		Set Rs = Nothing
		If RecordCount < 1 Then RecordCount = 1
		CountIndex = 0
		
		If Request("executepage") = "" Then
		%>
		<p style="font-size:9pt">下面开始重新计算用户数据，共有<%=RecordCount%>个用户待更新
	
		<table width="400" border="0" cellspacing="1" cellpadding="1">
			<tr> 
				<td bgcolor=000000>
		<table width="400" border="0" cellspacing="0" cellpadding="1">
			<tr> 
				<td bgcolor=ffffff height=9><img src=../pic/progressbar.gif width=0 height=16 id=img1 name=img1 align=middle></td></tr></table>
		</td></tr></table> <span id=txt1 name=txt1 style="font-size:9pt">0</span><span style="font-size:9pt">%</span>
		<span id=tm1 name=tm1 style="font-size:9pt">正在估算需要时间...</span>
		<script src="<%=DEF_BBS_HomeUrl%>inc/js/bar.js?ver=<%=DEF_Jer%>" type="text/javascript"></script>
		<script>
			Upl_url = "Io_Info.asp?id=<%=Urlencode(GBL_CHK_User)%>";
			Upl_IOfun = window.setTimeout(Upl_IO,Upl_GetDelay);
		</script>
		<br>
		<iframe src="UpdateUnderWritePrintColumn.asp?executepage=yes&SureFlag=E72ksiOkw2&flag=<%=urlencode(GBL_MANAGE_Flag)%>&ReCount=<%=urlencode(ReCount)%>" name="infoframe" id="infoframe" hidefocus="" frameborder="no" scrolling="auto" style="margin-top:100px;width:300px;height:150px;">
		<%
			response.Flush
			Application.Lock
			Application("Io_" & GBL_CHK_User) = "start"
			Application.UnLock
			Exit sub
		End If
		
		Dim StartTime,SpendTime,RemainTime
		StartTime = Now

		Do while EndFlag = 0
			SQL = sql_select("Select ID,birthday from LeadBBS_User where ID>" & NowID & " order by id ASC",100)
			Set Rs = LDExeCute(SQL,0)
			If Rs.Eof Then
				EndFlag = 1
				Rs.Close
				Exit do
			Else
				GetData = Rs.GetRows(-1)
			End If
			Rs.Close
			Set Rs = Nothing
			
			For N = 0 to Ubound(GetData,2)
				NowID = cCur(GetData(0,N))
				
				SQL = "select count(*) from leadbbs_Upload where UserID=" & NowID
				Set Rs = LDExeCute(SQL,0)
				If Not Rs.Eof Then
					UploadNum = Rs(0)
					If isNull(UploadNum) then UploadNum = 0
					UploadNum = ccur(UploadNum)
				Else
					UploadNum = 0
				End If
				Rs.Close
				Set Rs = Nothing
				
				SQL = "select count(*) from leadbbs_announce where UserID=" & NowID
				Set Rs = LDExeCute(SQL,0)
				If Not Rs.Eof Then
					AnnounceNum = Rs(0)
					If isNull(AnnounceNum) then AnnounceNum = 0
					AnnounceNum = ccur(AnnounceNum)
				Else
					AnnounceNum = 0
				End If
				Rs.Close
				Set Rs = Nothing
				
				select case DEF_UsedDataBase
				case 0,2:
					SQL = "select count(*) from leadbbs_announce where UserID=" & NowID & " and ParentID=0"
				case Else
					SQL = "select count(*) from leadbbs_Topic where UserID=" & NowID & " "
				End select
				Set Rs = LDExeCute(SQL,0)
				If Not Rs.Eof Then
					AnnounceTopic = Rs(0)
					If isNull(AnnounceTopic) then AnnounceTopic = 0
					AnnounceTopic = ccur(AnnounceTopic)
				Else
					AnnounceTopic = 0
				End If
				Rs.Close
				Set Rs = Nothing
				
				select case DEF_UsedDataBase
				case 0,2:
					SQL = "select count(*) from leadbbs_announce where GoodFlag=1 and UserID=" & NowID
				case Else
					SQL = "select count(*) from leadbbs_Topic where GoodFlag=1 and UserID=" & NowID
				End select
				Set Rs = LDExeCute(SQL,0)
				If Not Rs.Eof Then
					AnnounceGood = Rs(0)
					If isNull(AnnounceGood) then AnnounceGood = 0
					AnnounceGood = ccur(AnnounceGood)
				Else
					AnnounceGood = 0
				End If
				Rs.Close
				Set Rs = Nothing
				If ReCount <> "1" Then
					CALL LDExeCute("Update LeadBBS_User Set AnnounceNum=" & AnnounceNum & ",AnnounceTopic=" & AnnounceTopic & ",AnnounceGood=" & AnnounceGood & ",UploadNum=" & UploadNum & " Where ID=" & NowID,1)
				Else
					CALL LDExeCute("Update LeadBBS_User Set AnnounceNum=" & AnnounceNum & ",AnnounceTopic=" & AnnounceTopic & ",AnnounceGood=" & AnnounceGood & ",UploadNum=" & UploadNum & ",points=" & DEF_BBS_AnnouncePoints*(AnnounceNum + AnnounceTopic)+AnnounceGood*5 & " Where ID=" & NowID,1)
				End If
				'GetUserLevel(NowID)
	
				CountIndex = CountIndex + 1
				If (CountIndex mod 100) = 0 Then
					SpendTime = Datediff("s",StartTime,Now)
					RemainTime = SpendTime/CountIndex * (RecordCount-CountIndex)
					Application.Lock
					Application("Io_" & GBL_CHK_User) = Fix((CountIndex/RecordCount) * 400) & "|" & FormatNumber(CountIndex/RecordCount*100,4,-1) & "|" & SpendTime & "|" & RemainTime & "|" & CountIndex
					Application.UnLock
				End If
			Next
			If Response.IsClientConnected Then
			Else
				EndFlag = 1
				Application.Contents.Remove("Io_" & GBL_CHK_User)
			End If
		Loop
		%>
		完成
		<%Application.Contents.Remove("Io_" & GBL_CHK_User)
		application.contents.removeall
	End If

End sub

Function GetUserLevel(GBL_ID)

	Dim Temp_N,UserLevel,IP,SessionID,AnnounceNum,Online,Prevtime,OnlineTime,Points,UserLevel_Old
	Dim Rs
	Set Rs = LDExeCute(sql_select("Select UserLevel,AnnounceNum,OnlineTime from LeadBBS_User where id=" & GBL_ID,1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		Exit Function
	End If
	UserLevel = Rs(0)
	Points = cCur(Rs(1))
	OnlineTime = cCur(Rs(2))
	Rs.Close
	Set Rs = Nothing
	UserLevel_Old = UserLevel

	For Temp_N = 0 To DEF_UserLevelNum
		If Points >= DEF_UserLevelPoints(Temp_N) Then UserLevel = Temp_N
	Next

	GetUserLevel = UserLevel
	If UserLevel_Old <> UserLevel Then CALL LDExeCute("Update LeadBBS_User Set UserLevel=" & UserLevel & " Where ID=" & GBL_ID,1)

End Function
%>