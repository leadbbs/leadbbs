<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../../inc/Limit_fun.asp"-->
<!--#include file="../../b/inc/cache_fun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
server.scriptTimeOut = 9999
initDatabase()
GBL_UserID = checkSupervisorPass()
GBL_CHK_TempStr = ""
Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
dim BoardName

If GBL_CHK_Flag=1 and GBL_CHK_TempStr = "" Then
	If CheckIsCanMoveSure() = 1 Then
		DisplayMoveAnnounce()
	End If
Else
	Response.Write "<div class=alert>" & GBL_CHK_TempStr & "</div>"
End If

closeDataBase()
frame_BottomInfo()
Manage_Sitebottom("none")

Function CheckIsCanMoveSure

	If GetBinarybit(GBL_CHK_UserLimit,9) = 1 Then
		Response.Write "错误,权限不足!<br>" & VbCrLf
		Exit Function
	End if
	Dim MoveFromBoardID
	MoveFromBoardID = Left(Request("MoveFromBoardID"),14)
	If isNumeric(MoveFromBoardID) = 0 or inStr(MoveFromBoardID,",") > 0 or MoveFromBoardID = "" Then
		Response.Write "错误,请提供要全并的原始的论坛ID!<br>" & VbCrLf
		Exit Function
	End if

	MoveFromBoardID = cCur(MoveFromBoardID)
	Dim Rs,SQL
	SQL = sql_select("Select BoardID,BoardName from LeadBBS_Boards where BoardID=" & MoveFromBoardID,1)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Response.Write "错误,要合并的原始的论坛ID不存在!<br>" & VbCrLf
		Rs.Close
		Set Rs = Nothing
		CheckIsCanMoveSure = 0
		Exit Function
	End if

	Dim BoardID
	BoardID = Rs("BoardID")
	BoardName = Rs(1)

	Rs.Close
	Set Rs = Nothing
	CheckIsCanMoveSure = 1

End Function

Function DisplayMoveAnnounce

	Dim MoveFromBoardID
	MoveFromBoardID = Left(Request("MoveFromBoardID"),14)
	If isNumeric(MoveFromBoardID) = 0 or inStr(MoveFromBoardID,",") > 0 or MoveFromBoardID = "" Then
		Response.Write "错误,请提供要转移的帖子的ID!<br>" & VbCrLf
		Exit Function
	End if

	Response.Flush
	If Request.Form("MoveSureFlag")="dk9@dl9s92lw_SWxl" Then
		
		MoveFromBoardID = cCur(MoveFromBoardID)
		Dim Rs,SQL
		SQL = sql_select("Select BoardID,BoardName,BoardAssort from LeadBBS_Boards where BoardID=" & MoveFromBoardID,1)
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			Response.Write "错误,源版面不存在!<br>" & VbCrLf
			Rs.Close
			Set Rs = Nothing
			Exit Function
		End if
		
		Dim BoardID,BoardAssort
		BoardID = cCur(Rs(0))
		BoardName = Rs(1)
		BoardAssort = cCur(Rs(2))
		Rs.Close
		Set Rs = Nothing
		
		Dim BoardID2
		BoardID2 = Left(Request("BoardID2"),14)
		If isNumeric(BoardID2) = 0 or inStr(BoardID2,",") > 0 or BoardID2 = "" Then BoardID2 = 0
		BoardID2 = cCur(BoardID2)
		If BoardID2 < 1 Then
			Response.Write "错误,目标论坛不存在!!<br>" & VbCrLf
			Set Rs = Nothing
			Exit Function
		End if
		
		If BoardID2 = BoardID Then
			Response.Write "目标论坛就是主题所在论坛,所以不需要转移!!<br>" & VbCrLf
			Set Rs = Nothing
			Exit Function
		End if
	
		Dim BoardName2,BoardAssort2
		Set Rs = LDExeCute("Select BoardName,BoardAssort from LeadBBS_Boards Where BoardID = " & BoardID2,0)
		If Not Rs.Eof Then
			BoardName2 = Rs("BoardName")
			BoardAssort2 = cCur(Rs(1))
		Else
			Response.Write "错误,目标论坛不存在!<br>" & VbCrLf
			Rs.Close
			Set Rs = Nothing
			Exit Function
		End if
		Rs.Close
		Set Rs = Nothing

		Dim NowID,EndFlag,GetData,n
		EndFlag = 0
		Response.Write "正在转移，请等待出现完成：□"
		Response.Flush
		Do while EndFlag = 0
			select case DEF_UsedDataBase
				case 0,2:
					SQL = sql_select("Select ID,RootIDBak from LeadBBS_Announce where ParentID=0 and BoardID=" & MoveFromBoardID,100)
				case Else
					SQL = sql_select("Select ID,ID as id_dup2 from LeadBBS_Topic where BoardID=" & MoveFromBoardID,100)
			End select
			Set Rs = LDExeCute(SQL,0)
			If Rs.Eof Then
				EndFlag = 1
				Rs.Close
				Set Rs = Nothing
				Exit Do
			Else
				GetData = Rs.GetRows(-1)
				Rs.Close
				Set Rs = Nothing
				SQL = Ubound(GetData,2)
				For N = 0 to SQL
					NowID = cCur(GetData(1,n))
					CALL LDExeCute("Update LeadBBS_Announce Set BoardID=" & BoardID2 & " where RootIDBak=" & NowID,1)
					If DEF_UsedDataBase = 1 Then CALL LDExeCute("Update LeadBBS_Topic Set BoardID=" & BoardID2 & " where ID=" & NowID,1)
					CALL MakeAnnounceTop(NowID,"")
				Next
				Response.Write "■"
				Response.Flush
			End If
		Loop
		CALL LDExeCute("Update LeadBBS_TopAnnounce Set BoardID=" & BoardID2 & " where BoardID=" & BoardID,1)
		UpdateBoardValue(BoardID)
		UpdateBoardValue(BoardID2)
		ReloadTopAnnounceInfo(0)
		ReloadTopAnnounceInfo(BoardAssort)
		ReloadTopAnnounceInfo(BoardAssort2)
		Response.Write "<font color=008800 class=greenfont>版面" & BoardName & "成功转移到" & BoardName2 & "!!</font>" & VbCrLf
	Else
		%>
		<form name=DellClientForm action=BoardMoveAnnounce.asp method=post>
			<input type=hidden name=MoveSureFlag value="dk9@dl9s92lw_SWxl">
			<input type=hidden name=MoveFromBoardID value="<%=MoveFromBoardID%>">
			<input type=hidden name=BoardID value="<%=GBL_Board_ID%>">
			<div class=frameline>
			<b>此操作不可逆,确认要转移版面<font color=ff0000 class=redfont><%=BoardName%></font>的帖子吗？</b>
			<br>转换时间视帖子总数而定，如果帖子巨多，建议先暂停论坛再作执行．
			</div>
			<div class=frameline>
<!--#include file="../../inc/incHTM/BoardForMoveList.asp"-->
			</div>
			<br>
			<div class=frameline>
			<input type=submit value=确定 class=fmbtn>
			<input type=button value=取消此操作 onclick="javascript:window.close();" class=fmbtn>
			</div>
		</form>
		<%
	End If

End Function

Function UpdateBoardValue(BoardID)

	Dim Rs,GetData,BoardNum
	Dim N,TopicNum,AnnounceNum,AllMinRootID,AllMaxRootID,TodayAnnounce,GoodNum
	Dim LastAnnounceID,LastTopicName,LastWriter,LastTime
	Set Rs = LDExeCute("select count(*) from LeadBBS_Announce where GoodFlag=1 and BoardID=" & BoardID,0)
	If Rs.Eof Then
		GoodNum = 0
	Else
		GoodNum = Rs(0)
		If isNull(GoodNum) Then GoodNum = 0
		GoodNum = cCur(GoodNum)
	End If
	Rs.Close
	Set Rs = Nothing

	Set Rs = LDExeCute("select count(*) from LeadBBS_Announce where BoardID=" & BoardID & " and ndatetime>" & Left(LngStr(GetTimeValue(DEF_Now)),8) & "000000",0)
	If Rs.Eof Then
		TodayAnnounce = 0
	Else
		TodayAnnounce = Rs(0)
		If isNull(TodayAnnounce) Then TodayAnnounce = 0
		TodayAnnounce = cCur(TodayAnnounce)
	End If
	Rs.Close
	Set Rs = Nothing

	select case DEF_UsedDataBase
		case 0,2:
			Set Rs = LDExeCute("select count(*) from LeadBBS_Announce where ParentID = 0 and BoardID=" & BoardID,0)
		case Else
			Set Rs = LDExeCute("select count(*) from LeadBBS_Topic where BoardID=" & BoardID,0)
	End select
	If Rs.Eof Then
		TopicNum = 0
	Else
		TopicNum = Rs(0)
		If isNull(TopicNum) Then TopicNum = 0
		TopicNum = cCur(TopicNum)
	End If
	Rs.Close
	Set Rs = Nothing
	
	Set Rs = LDExeCute("select count(*) from LeadBBS_Announce where BoardID=" & BoardID,0)
	If Rs.Eof Then
		AnnounceNum= 0
	Else
		AnnounceNum = Rs(0)
		If isNull(TopicNum) Then AnnounceNum = 0
		AnnounceNum = cCur(AnnounceNum)
	End If
	Rs.Close
	Set Rs = Nothing
	
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

	select case DEF_UsedDataBase
		case 0,2:
			Set Rs = LDExeCute(sql_select("Select ID,title,LastUser,UserName,LastTime from LeadBBS_Announce where ParentID = 0 and BoardID=" & BoardID & " and RootID<" & DEF_BBS_TOPMinID & " order By RootID DESC",1),0)
		case Else
			Set Rs = LDExeCute(sql_select("Select ID,title,LastUser,UserName,LastTime from LeadBBS_Topic where BoardID=" & BoardID & " and RootID<" & DEF_BBS_TOPMinID & " order By RootID DESC",1),0)
	End select
	If Rs.Eof Then
		LastAnnounceID = 0
		LastTopicName = ""
		LastTime = 0
	Else
		LastAnnounceID = Rs(0)
		LastTopicName = Rs(1)
		LastWriter = Rs(2)
		If LastWriter = "" or isNull(LastWriter) Then LastWriter = Rs(3)
		LastTime = cCur(Rs(4))
		If isNull(LastTime) then LastTime = 0
	End If
	Rs.Close
	Set Rs = Nothing
	CALL LDExeCute("Update LeadBBS_Boards Set TopicNum=" & TopicNum & ",AnnounceNum=" & AnnounceNum & ",AllMinRootID=" & AllMinRootID & ",AllMaxRootID=" & AllMaxRootID & ",TodayAnnounce=" & TodayAnnounce & ",GoodNum=" & GoodNum & ",LastAnnounceID=" & LastAnnounceID & ",LastTopicName='" & Replace(LastTopicName,"'","''") & "',LastWriter='" & Replace(LastWriter,"'","''") & "',LastWriteTime=" & LastTime & " where boardID=" & BoardID,1)
	ReloadBoardInfo(BoardID)

End Function

Function MakeAnnounceTop(AnnounceID,morestr)

	Dim Rs,SQL,BoardID,RootID,MaxRootID,RootIDBak
	SQL = sql_select("Select ID,RootID,BoardID,RootIDBak from LeadBBS_Announce where ID=" & AnnounceID,1)
	Set Rs = LDExeCute(SQL,0)
	If Not Rs.Eof Then
		RootID = cCur(Rs(1))
		BoardID = cCur(Rs(2))
		RootIDBak = cCur(Rs(3))
		Rs.Close
		Set Rs = Nothing
	Else
		Rs.Close
		Set Rs = Nothing
		Exit function
	End If

	If RootID<DEF_BBS_TOPMinID Then
		select case DEF_UsedDataBase
		case 0:
	 		CALL LDExeCute("Update LeadBBS_Announce Set RootID=(Select Max(RootID) from LeadBBS_Announce where ParentID=0 and BoardID=" & BoardID & " and RootID<" & DEF_BBS_TOPMinID & ")+1 where ParentID=0 and RootIDBak=" & RootIDBak,1)
	 	case 2:
	 		CALL LDExeCute("Update LeadBBS_Announce Set RootID=(select t.rootid from (Select Max(RootID) as rootid from LeadBBS_Announce where ParentID=0 and BoardID=" & BoardID & " and RootID<" & DEF_BBS_TOPMinID & ") as t)+1 where ParentID=0 and RootIDBak=" & RootIDBak,1)
	 	case Else
			Set Rs = LDExeCute("Select Max(RootID) from LeadBBS_Topic where BoardID=" & BoardID & " and RootID<" & DEF_BBS_TOPMinID,0)
			If Rs.Eof Then
				MaxRootID = 1
			Else
				MaxRootID = Rs(0)
				If isNull(MaxRootID) or MaxRootID="" Then
					MaxRootID=1
				End If
				MaxRootID = cCur(MaxRootID)
			End If
			Rs.Close
			Set Rs = Nothing
		 	CALL LDExeCute("Update LeadBBS_Announce Set RootID=" & MaxRootID+1 & " where ID=" & RootIDBak,1)
		 	CALL LDExeCute("Update LeadBBS_Topic Set RootID=" & MaxRootID+1 & " where ID=" & RootIDBak,1)
	 	End select
	End If
	'UpdateBoardValue(BoardID)

End Function
%>