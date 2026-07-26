<!-- #include file=../../inc/BBSSetup.asp -->
<!-- #include file=../../inc/Board_Popfun.asp -->
<!-- #include file=../../b/inc/cache_fun.asp -->
<!-- #include file=../inc/bbsmanage_Fun.asp -->
<%
Server.ScriptTimeOut = 6000
DEF_BBS_HomeUrl = "../../"
initDatabase
GBL_CHK_TempStr = ""
checkSupervisorPass
'Response.End

If GBL_CHK_Flag = 0 or GBL_CHK_TempStr <> "" Then
	CloseDatabase
	Response.End
End If

If Request.Form("submitflag") <> "" Then
	GBL_Form_Day = Left(Request("GBL_Form_Day"),14)
	If isNumeric(GBL_Form_Day) = 0 Then GBL_Form_Day = 0
	GBL_Form_Day = Fix(cCur(GBL_Form_Day))
	GBL_Form_BoardID = Left(Request("BoardID2"),14)
	If isNumeric(GBL_Form_BoardID) = 0 Then GBL_Form_BoardID = 0
	GBL_Form_BoardID = Fix(cCur(GBL_Form_BoardID))
	
	If GBL_Form_Day < 7 or GBL_Form_Day > 9999 Then
		GBL_CHK_TempStr = "<p>错误的天数指定，要求值至少要求为7天前．"
	Else
		If GBL_Form_BoardID < 1 Then
			GBL_CHK_TempStr = "<p>错误的论坛版面．"
		End If
	End If	
End If
	
If Request.Form("submitflag") = "" or GBL_CHK_TempStr <> "" Then
	Dim GBL_Form_Day,GBL_Form_BoardID
	Manage_sitehead DEF_SiteNameString & " - 管理员",""
	frame_TopInfo
	DisplayUserNavigate("批量删除论坛指定条件的历史数据")
	if GBL_CHK_TempStr <> "" Then
		Response.Write "<br><p align=left><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font>"
		DisplayForm
	Else%>
		<table width=100%>
		<tr>
			<td>
				<%DisplayForm%>
			</td>
		</tr>
		</table>
		<%
	End If
	frame_BottomInfo
	SiteBottom
	If GBL_ShowBottomSure = 1 Then Response.Write GBL_SiteBottomString
Else
	If GBL_CHK_Flag = 1 and GBL_UserID > 0 and CheckSupervisorUserName = 1 Then
		if GBL_CHK_TempStr <> "" Then
			Response.Write "<br><p align=center><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font>"
		Else
			DeleteExpiresAnnounceData
		End If
	End If
	closeDataBase
	SiteBottom_Spend
End If

Function DisplayForm
		%>
				<script LANGUAGE="JavaScript" TYPE="text/javascript">
				function submitonce(theform)
				{
					if (document.all||document.getElementById)
					{
						for (i=0;i<theform.length;i++)
						{
							var tempobj=theform.elements[i];
							if(tempobj.type.toLowerCase()=="submit"||tempobj.type.toLowerCase()=="reset")
							tempobj.disabled=true;
						}
					}
				}
				</script>
				<form name=LeadBBSFm action=DeleteExpiresAnnounceData.asp method=post onSubmit="submitonce(this);">
					<input type=hidden name=submitflag value="dk9@dl9s92lw_SWxl">
					<div class=alert>警告：</div>
					<div class=frameline>目前时间：<%=DEF_Now%> (最小要求７天前)</div>
					<div class=frameline>批量删除<input type=text value="<%=GBL_Form_Day%>" size=4 maxlength=4 name=GBL_Form_Day>天前的数据</div>
					<div class=frameline>
					<!-- #include file=../../inc/incHTM/BoardForMoveList.asp -->
					(一定要指定所要批量删除的版面)</div>
					<div class=alert>论坛数据删除后将无法恢复，一切操作不可逆！！</div>
					<div class=frameline>建议在删除前作好数据库备份，以防不测．确定要继续吗？</div>
					<input type=submit value=确定批量删除指定条件的论坛数据 class=fmbtn>
				</form>
	<%
End Function

Function DeleteExpiresAnnounceData

	GBL_Form_Day = DateAdd("d",0-GBL_Form_Day,DEF_Now)
	Dim Flag2
	Dim Rs,SQL
	Dim NowID,EndFlag
	NowID = 0
	EndFlag = 0
	Response.Write "<p style=font-size:9pt>下需开始删除更新时间" & GBL_Form_Day & "前的旧论坛帖子，程序将开始扫描并删除版面编号号为<font color=blue class=bluefont>" & GBL_Form_BoardID & "</font>的符合条件的主题．．．"
	'Response.Write "<br>进度(需要时间可能会很长，请等待出现完成，■表示删除，□表示略过)："
	GBL_Form_Day = GetTimeValue(GBL_Form_Day)
	NowID = 0
	EndFlag = 0
	Dim GetData,N,DeleteNum
	DeleteNum = 0

	Dim RecordCount,CountIndex
	select case DEF_UsedDataBase
		case 0,2:
			SQL = "Select count(*) from LeadBBS_Announce where ParentID=0 and BoardID=" & GBL_Form_BoardID
		case else
			SQL = "Select count(*) from [LeadBBS_Topic] where BoardID=" & GBL_Form_BoardID
	End select
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
	%>
	<p style="font-size:9pt">下面扫描可删除的主题，共有<%=RecordCount%>个主题待扫描

	<table width="400" border="0" cellspacing="1" cellpadding="1">
		<tr> 
			<td bgcolor=000000>
	<table width="400" border="0" cellspacing="0" cellpadding="1">
		<tr> 
			<td bgcolor=ffffff height=9><img src=../../images/vote.gif width=0 height=16 id=img1 name=img1 align=middle></td></tr></table>
	</td></tr></table> <span id=txt1 name=txt1 style="font-size:9pt">0</span><span style="font-size:9pt">%</span>
	<%
	Response.Flush
	Do while EndFlag = 0
		select case DEF_UsedDataBase
			case 0,2:
				SQL = sql_select("Select RootID,LastTime,ID,GoodFlag from LeadBBS_Announce where ParentID=0 and BoardID=" & GBL_Form_BoardID & " and RootID>" & NowID & " order by RootID ASC",100)
			case Else
				SQL = sql_select("Select RootID,LastTime,ID,GoodFlag from LeadBBS_Topic where BoardID=" & GBL_Form_BoardID & " and RootID>" & NowID & " order by RootID ASC",100)
		End select
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			EndFlag = 1
			Rs.Close
			Set Rs = Nothing
		Else
			GetData = Rs.GetRows(-1)
			Rs.Close
			Set Rs = Nothing
			SQL = Ubound(GetData,2)
			Flag2 = 0
			For N = 0 to SQL
				NowID = cCur(GetData(0,n))
				If cCur(GetData(1,n)) < GBL_Form_Day and (GetData(3,n) = 0 or GetData(3,n) = False) Then
					Flag2 = 1
					DelAnnounce(GetData(2,n))
					CALL LDExeCute("delete from LeadBBS_Announce Where ID=" & GetData(2,n),1)
					If DEF_UsedDataBase = 1 Then CALL LDExeCute("delete from LeadBBS_Topic Where ID=" & GetData(2,n),1)
					Response.Flush
					DeleteNum = DeleteNum + 1
				End If
				CountIndex = CountIndex + 1
				If (CountIndex mod 20) = 0 Then
					Response.Write "<script>img1.width=" & Fix((CountIndex/RecordCount) * 400) & ";" & VbCrLf
					Response.Write "txt1.innerHTML=""" & FormatNumber(CountIndex/RecordCount*100,4,-1) & """;" & VbCrLf
					Response.Write "img1.title=""(" & CountIndex & ")"";</script>" & VbCrLf
					Response.Flush
				End If
			Next
		End If
	Loop
	UpdateBoardValue(GBL_Form_BoardID)
	ReloadTopAnnounceInfo(0)
	Borad_GetBoardIDValue(GBL_Form_BoardID)
	ReloadTopAnnounceInfo(GBL_Board_BoardAssort)
	Set Rs = Nothing
	%>
	<script>img1.width=400;
	txt1.innerHTML="100";</script>
	共计<%=DeleteNum%>个主题帖子被删除
	<%

End Function

Function DelAnnounce(DelID)

	Dim Rs,SQL
	SQL = sql_select("Select BoardID,ParentID,UserID,RootID,Layer,TopicType,ndatetime,GoodFlag,RootIDBak from LeadBBS_Announce where id=" & DelID,1)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		Exit Function
	End if
	Dim BoardID,ParentID,UserID,RootID,Layer,TopicType,ndatetime,GoodFlag,RootIDBak
	BoardID = cCur(Rs("BoardID"))
	ParentID = cCur(Rs("ParentID"))
	UserID = cCur(Rs("UserID"))
	RootID = cCur(Rs("RootID"))
	Layer = cCur(Rs("Layer"))
	TopicType = Rs("TopicType")
	ndatetime = RestoreTime(Rs("ndatetime"))
	If isTrueDate(ndatetime) = 0 Then ndatetime = DEF_Now
	If IsNull(TopicType) Then TopicType = 0
	GoodFlag = Rs("GoodFlag")
	RootIDBak = cCur(Rs("RootIDBak"))
	Rs.Close
	Set Rs = Nothing
	
	Dim RootIDTopicType
	If ParentID > 0 Then
		select case DEF_UsedDataBase
			case 0,2:
				SQL = sql_select("Select TopicType from LeadBBS_Announce where ParentID=0 and RootIDBak=" & RootIDBak,1)
			case Else
				SQL = sql_select("Select TopicType from LeadBBS_Topic where ID=" & RootIDBak,1)
		End select
		Set Rs = LDExeCute(SQL,0)
		If Not Rs.Eof Then
			RootIDTopicType = Rs(0)
			If isNull(RootIDTopicType) Then RootIDTopicType = 0
		Else
			RootIDTopicType = 0
		End If
		Rs.Close
	Else
		RootIDTopicType = 0
	End If
	Set Rs = Nothing
	
	Dim todayAnnounce,GoodNum,GoodNum2
	todayAnnounce = 0
	
	If Day(ndatetime) = Day(DEF_Now) and Year(ndatetime) = year(DEF_Now) and Month(ndatetime) = Month(DEF_Now) Then todayAnnounce = 1
	If GoodFlag = 1 Then
		GoodNum = 1
	Else
		GoodNum = 0
	End If
	GoodNum2 = 0

	If ParentID > 0 Then
		CALL LDExeCute("Delete from LeadBBS_Announce where id=" & DelID,1)
		Dim TmpMaxID,TmpMinID
		SQL = "select max(ID) from LeadBBS_Announce where RootIDBak=" & RootIDBak
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			TmpMaxID = 0
		Else
			TmpMaxID = Rs(0)
			If isNull(TmpMaxID) then TmpMaxID = 0
		End If
		Rs.Close
		Set Rs = Nothing
		SQL = "select min(ID) from LeadBBS_Announce where RootIDBak=" & RootIDBak
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			TmpMinID = 0
		Else
			TmpMinID = Rs(0)
			If isNull(TmpMinID) then TmpMinID = 0
		End If
		Rs.Close
		Set Rs = Nothing
		If ParentID = 0 Then
			CALL LDExeCute("Update LeadBBS_Boards Set TopicNum=TopicNum-1,AnnounceNum=AnnounceNum-1,todayAnnounce=todayAnnounce-" & todayAnnounce & ",GoodNum=GoodNum-" & GoodNum & " where BoardID=" & BoardID,1)
		Else
			SQL = sql_select("Select ID,ndatetime,UserName,ParentID from LeadBBS_Announce where id=" & TmpMaxID,1)
			Set Rs = LDExeCute(SQL,0)
			Dim LastTime,LastUser
			If Not Rs.Eof Then
				LastTime = Rs("ndatetime")
				If cCur(Rs("ParentID")) = 0 Then
					LastUser = ""
				Else
					LastUser = Rs("UserName")
				End If
			Else
				LastTime = GetTimeValue(DEF_Now)
			End If
			Rs.Close
			Set Rs = Nothing
			CALL LDExeCute("Update LeadBBS_Boards Set AnnounceNum=AnnounceNum-1,todayAnnounce=todayAnnounce-" & todayAnnounce & ",GoodNum=GoodNum-" & GoodNum & " where BoardID=" & BoardID,1)

			CALL LDExeCute("Update LeadBBS_Announce Set ChildNum=ChildNum-1,LastTime=" & LastTime & ",LastUser='" & Replace(LastUser,"'","''") & "' where id=" & RootIDBak,1)
			If DEF_UsedDataBase = 1 Then CALL LDExeCute("Update LeadBBS_Topic Set ChildNum=ChildNum-1,LastTime=" & LastTime & ",LastUser='" & Replace(LastUser,"'","''") & "',LastInfo='' where id=" & RootIDBak,1)
		End If
		CALL LDExeCute("Update LeadBBS_User set AnnounceNum=AnnounceNum-1,AnnounceGood=AnnounceGood-" & GoodNum & " Where ID =" & UserID,1)
		'UpdateBoardValue(BoardID)
		Rem 更新MaxRootID

		select case DEF_UsedDataBase
		case 0,2:
			SQL = "Update LeadBBS_Announce set RootMaxID=" & TmpMaxID & _
					",RootMinID=" & TmpMinID &_
					" where ParentID=0 and RootIDBak=" & RootIDBak
			CALL LDExeCute(SQL,1)
		case Else
			SQL = "Update LeadBBS_Announce set RootMaxID=" & TmpMaxID & _
					",RootMinID=" & TmpMinID &_
					" where ID=" & RootIDBak
			CALL LDExeCute(SQL,1)
			SQL = "Update LeadBBS_Topic set RootMaxID=" & TmpMaxID & _
					",RootMinID=" & TmpMinID &_
					" where ID=" & RootIDBak
			CALL LDExeCute(SQL,1)
		End select
	Else
		Dim LoopFlag,NowID,GetData,N
		LoopFlag = 1
		NowID = 0

		GoodNum2 = 0
		Dim TmpTopicNum,TmpAnnounceNum,GoodNum3
		TmpAnnounceNum = 0
		TmpTopicNum = 0
		todayAnnounce = 0
		Do While LoopFlag = 1
			Rem 主题帖留着最后删除，以免删除中央意外中止，导致主题损坏
			SQL = sql_select("Select ID,BoardID,ParentID,UserID,ndatetime,GoodFlag from LeadBBS_Announce where RootIDBak=" & RootIDBak & " and id>" & NowID & " order by ID",100)
			Set Rs = LDExeCute(SQL,0)
			If Not Rs.Eof Then
				GetData = Rs.GetRows(100)
				Rs.Close
				Set Rs = Nothing
				SQL = Ubound(GetData,2)
				For N = 0 to SQL
					If GetData(5,n) = 1 Then
						GoodNum2 = GoodNum2 + 1
						GoodNum3 = 1
					Else
						GoodNum3 = 0
					End If
					If cCur(GetData(2,N)) = 0 Then
						TmpAnnounceNum = TmpAnnounceNum + 1
						TmpTopicNum = TmpTopicNum + 1
					Else
						TmpAnnounceNum = TmpAnnounceNum + 1
					End If
					GetData(4,n) = RestoreTime(GetData(4,n))
					If isTrueDate(GetData(4,n)) = 1 Then
						If Day(GetData(4,n)) = Day(DEF_Now) and Year(GetData(4,n)) = year(DEF_Now) and Month(GetData(4,n)) = Month(DEF_Now) Then todayAnnounce = todayAnnounce + 1
					End If
					If cCur(GetData(2,N)) = 0 Then
						CALL LDExeCute("Update LeadBBS_User set AnnounceNum=AnnounceNum-1,AnnounceTopic=AnnounceTopic-1,AnnounceGood=AnnounceGood-" & GoodNum3 & " Where ID =" & GetData(3,N),1)
					Else
						CALL LDExeCute("Update LeadBBS_User set AnnounceNum=AnnounceNum-1,AnnounceGood=AnnounceGood-" & GoodNum3 & " Where ID =" & GetData(3,N),1)
					End If
					NowID = cCur(GetData(0,N))
				Next
				CALL LDExeCute("Delete from LeadBBS_Announce where RootIDBak=" & RootIDBak & " and id<=" & NowID,1)
			Else
				LoopFlag = 0
				Rs.Close
				Set Rs = Nothing
			End If
		Loop
		If DEF_UsedDataBase = 1 Then CALL LDExeCute("Delete from LeadBBS_Topic where ID=" & RootIDBak,1)
		If TopicType = 80 or TopicType = 54 or TopicType = 114 Then
			CALL LDExeCute("Delete from LeadBBS_VoteUser Where AnnounceID=" & DelID,1)
			If TopicType = 80 Then
				CALL LDExeCute("Delete from LeadBBS_VoteItem Where AnnounceID=" & DelID,1)
			End If
		End If
		CALL LDExeCute("Update LeadBBS_Boards Set TopicNum=TopicNum-" & TmpTopicNum & ",AnnounceNum=AnnounceNum-" & TmpAnnounceNum & ",todayAnnounce=todayAnnounce-" & todayAnnounce & ",GoodNum=GoodNum-" & GoodNum2 & " where BoardID=" & BoardID,1)
	End If

End Function

Function UpdateBoardValue(BoardID)

	Dim Rs,SQL
	Dim N,AllMinRootID,AllMaxRootID	
	select case DEF_UsedDataBase
		case 0,2:
			Set Rs = LDExeCute("select Min(RootID) from LeadBBS_Announce where ParentID=0 and BoardID=" & BoardID,0)
		case Else
			Set Rs = LDExeCute("select Min(RootID) from LeadBBS_Topic where BoardID=" & BoardID,0)
	End select
	If Rs.Eof Then
		AllMinRootID = 0
	Else
		AllMinRootID = Rs(0)
		If isNull(AllMinRootID) Then AllMinRootID = 0
		AllMinRootID = cCur(AllMinRootID)
	End If
	Rs.Close
	Set Rs = Nothing
	select case DEF_UsedDataBase
		case 0,2:
			Set Rs = LDExeCute("select Max(RootID) from LeadBBS_Announce where ParentID=0 and BoardID=" & BoardID,0)
		case Else
			Set Rs = LDExeCute("select Max(RootID) from LeadBBS_Topic where BoardID=" & BoardID,0)
	End select
	If Rs.Eof Then
		AllMaxRootID = 0
	Else
		AllMaxRootID = Rs(0)
		If isNull(AllMaxRootID) Then AllMaxRootID = 0
		AllMaxRootID = cCur(AllMaxRootID)
	End If
	Rs.Close
	Set Rs = Nothing
	
	Dim LastAnnounceID,LastTopicName,LastWriter
	select case DEF_UsedDataBase
		case 0,2:
			Set Rs = LDExeCute(sql_select("Select ID,title,LastUser,UserName from LeadBBS_Announce where ParentID = 0 and BoardID=" & BoardID & " and RootID<" & DEF_BBS_TOPMinID & " order By RootID DESC",1),0)
		case else
			Set Rs = LDExeCute(sql_select("Select ID,title,LastUser,UserName from LeadBBS_Topic where BoardID=" & BoardID & " and RootID<" & DEF_BBS_TOPMinID & " order By RootID DESC",1),0)
	End select
	If Rs.Eof Then
		LastAnnounceID = 0
		LastTopicName = ""
	Else
		LastAnnounceID = Rs(0)
		LastTopicName = Rs(1)
		LastWriter = Rs(2)
		If LastWriter = "" or isNull(LastWriter) Then LastWriter = Rs(3)
	End If
	Rs.Close
	Set Rs = Nothing
	CALL LDExeCute("Update LeadBBS_Boards Set AllMinRootID=" & AllMinRootID & ",AllMaxRootID=" & AllMaxRootID & ",LastAnnounceID=" & LastAnnounceID & ",LastTopicName='" & Replace(LastTopicName,"'","''") & "',LastWriter='" & Replace(LastWriter,"'","''") & "' where boardID=" & BoardID,1)
	ReloadBoardInfo(BoardID)
	ReloadTopicAssort(BoardID)

End Function

Sub ReloadTopicAssort(BoardID)

	Dim Rs
	Set Rs = LDExeCute("select ID,AssortName,0,0,0 from LeadBBS_GoodAssort where BoardID=" & BoardID & " Order by BoardID,OrderID",0)
	If Not Rs.Eof Then
		Application.Lock
		Application(DEF_MasterCookies & "BoardInfo" & BoardID & "_TI") = Rs.GetRows(-1)
		Application.UnLock
	Else
		Application.Lock
		Set Application(DEF_MasterCookies & "BoardInfo" & BoardID & "_TI") = Nothing
		Application(DEF_MasterCookies & "BoardInfo" & BoardID & "_TI") = "yes"
		Application.UnLock
	End If
	Rs.Close
	Set Rs = Nothing

End Sub
%>