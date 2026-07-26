<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../../inc/Upload_Setup.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<!--#include file="../../inc/Limit_Fun.asp"-->
<!--#include file="../../a/inc/DelUpload_Fun.asp"-->
<!--#include file="../../b/inc/cache_fun.asp"-->
<%
server.scriptTimeOut = 9999
DEF_BBS_HomeUrl = "../../"
InitDatabase()
Dim GBL_ID,Form_ID

Dim DelBoardID
DelBoardID = Left(Request("DelBoardID"),14)
If isNumeric(DelBoardID) = 0 or DelBoardID = "" or InStr(DelBoardID,",") > 0 Then DelBoardID = 0
DelBoardID = Fix(cCur(DelBoardID))

If DelBoardID < 0 Then DelBoardID = 0

GBL_CHK_TempStr=""
GBL_ID = checkSupervisorPass()
Form_ID = GBL_ID
Form_ID = cCur(Form_ID)
If Form_ID < 0 Then Form_ID = 0
If Form_ID = 0 or GBL_CHK_Flag = 0 Then
	GBL_CHK_TempStr = GBL_CHK_TempStr & "你没有登录<br>" & VbCrLf
End If

Dim BoardName,BoardAssort

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
	Dim Rs,SQL,SQLendString,ClearFlag
	If GBL_CHK_TempStr = "" Then
			If GBL_UserID<1 or CheckSupervisorUserName() = 0 Then
				SQL = sql_select("Select BoardID,BoardName,BoardAssort from LeadBBS_Boards where BoardID=-111",1)
			Else
				SQL = sql_select("Select BoardID,BoardName,BoardAssort from LeadBBS_Boards where BoardID=" & DelBoardID,1)
			End If
			Set Rs = LDExeCute(SQL,0)
			If Rs.Eof Then
				Response.Write "找不到版面！<br>" & VbCrLf
				Rs.Close
				Set Rs = Nothing
			Else
				If Request.Form("DeleteSureFlag")="dk9@dl9s92lw_SWxl" Then
					BoardName = Rs(1)
					BoardAssort = cCur(Rs(2))
					Rs.Close
					Set Rs = Nothing
					DeleteBoardAnnounce DelBoardID,BoardName
				Else
					BoardName = Rs(1)
					Rs.Close
					Set Rs = Nothing
					%>
					<form name=DellClientForm action=ForumBoardDeleteAnnounce.asp method=post>
						<input type=hidden name=DeleteSureFlag value="dk9@dl9s92lw_SWxl">
						<input type=hidden name=DelBoardID value="<%=htmlencode(DelBoardID)%>">
						<b>此操作不可逆，确认要删除版面<font color=ff0000 class=redfont><%=htmlencode(BoardName)%></font>的所有帖子吗？</b><br>
						如果此版面帖子过多，删除将是一个漫长的过程，强烈建议暂停论坛后再作删除<br>操作．
						如果执行超时，可以刷新来重新继续删除操作．
						<br><br><input type=submit value=确定 class=fmbtn>
						<input type=button value=不删 onclick="javascript:window.close();" class=fmbtn>
					</form>
					<%
				End If
			End If
	Else
		Response.Write "<div clas=alert>" & GBL_CHK_TempStr & "</div>"
	End If

closeDataBase()
frame_BottomInfo()
Manage_Sitebottom("none")

Function DeleteBoardAnnounce(DelBoardID,BoardName)

	Dim Rs,SQL
	Dim NowID,EndFlag
	NowID = 0
	EndFlag = 0

	Response.Write "进度(需要时间可能会很长，请等待出现完成)："
	NowID = 0
	EndFlag = 0
	Dim GetData,N

	Dim RecordCount,CountIndex
	select case DEF_UsedDataBase
		case 0,2:
			SQL = "Select count(*) from LeadBBS_Announce where ParentID=0 and BoardID=" & DelBoardID
		case Else
			SQL = "Select count(*) from LeadBBS_Topic where BoardID=" & DelBoardID
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
	<br><span style="font-size:9pt">下面开始删除版面帖子，共有<%=RecordCount%>个主题待删除

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
			SQL = sql_select("Select ID from LeadBBS_Announce where ParentID=0 and BoardID=" & DelBoardID,100)
		case Else
			SQL = sql_select("Select ID from LeadBBS_Topic where BoardID=" & DelBoardID,100)
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
			For N = 0 to SQL
				NowID = cCur(GetData(0,n))
				DelAnnounce(NowID)
				DelUpload_DelList(NowID)
				CALL LDExeCute("delete from LeadBBS_Announce Where ID=" & NowID,1)
				If DEF_UsedDataBase = 1 Then CALL LDExeCute("delete from LeadBBS_Topic Where ID=" & NowID,1)
				CountIndex = CountIndex + 1
				'If (CountIndex mod 100) = 0 Then
					Response.Write "<script>img1.width=" & Fix((CountIndex/RecordCount) * 400) & ";" & VbCrLf
					Response.Write "txt1.innerHTML=""" & FormatNumber(CountIndex/RecordCount*100,4,-1) & """;" & VbCrLf
					Response.Write "img1.title=""(" & CountIndex & ")"";</script>" & VbCrLf
					Response.Flush
				'End If
			Next
		End If
	Loop

	Rem 清除失去主题的错误帖子
	DelUpload_DelList(" where BoardID=" & DelBoardID)
	CALL LDExeCute("delete from LeadBBS_Announce where BoardID=" & DelBoardID,1)
	If DEF_UsedDataBase = 1 Then CALL LDExeCute("delete from LeadBBS_Topic where BoardID=" & DelBoardID,1)

	UpdateBoardValue(DelBoardID)
	ReloadTopAnnounceInfo(0)
	ReloadTopAnnounceInfo(BoardAssort)
	Response.Write "完成"
	Set Rs = Nothing
	%>
	<script>img1.width=400;
	txt1.innerHTML="100";</script>
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
		CALL LDExeCute("Delete from LeadBBS_Opinion Where AnnounceID=" & DelID,1)
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
			SQL = sql_select("Select ID,BoardID,ParentID,UserID,ndatetime,GoodFlag,Opinion from LeadBBS_Announce where RootIDBak=" & RootIDBak & " and id>" & NowID & " order by ID",100)
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
					If GetData(6,n) & "" <> "" Then CALL LDExeCute("Delete from LeadBBS_Opinion Where AnnounceID=" & GetData(0,n),1)
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
		CALL LDExeCute("Delete from LeadBBS_extend Where ClassType=200 and extendid=" & RootIDBak,1)
		If TopicType = 80 or TopicType = 54 or TopicType = 114 Then
			CALL LDExeCute("Delete from LeadBBS_VoteUser Where AnnounceID=" & DelID,1)
			CALL LDExeCute("Delete from LeadBBS_Opinion Where AnnounceID=" & DelID,1)
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
		case Else
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
	Set Rs = LDExeCute("select ID,AssortName,0,0 as c0_dup2,0 as c0_dup3 from LeadBBS_GoodAssort where BoardID=" & BoardID & " Order by BoardID,OrderID",0)
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