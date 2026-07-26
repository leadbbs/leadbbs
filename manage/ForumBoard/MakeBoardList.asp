<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<!--#include file="inc/ForumBoard_fun.asp"-->
<%
Server.ScriptTimeOut = 300
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase()
		Response.Write GBL_CHK_TempStr
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass()

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("修复并统计论坛所有版面数据")

If GBL_CHK_Flag=1 Then
	If Request.Form("submitflag") = "yes" then
		UpdateBoardAnnounceNum2()
		ReloadBoardListData()
		Update_boardCacheData()
		Response.Write "<div class=alertdone>重新制作论坛列表完毕！</div>" & VbCrLf
	Else
		%>
			<div class=frameline>
			注意：此功能将修复以下内容：
			</div>
			<ol class=listli>
			<li>修复所有版面(包括不可见版面)帖子总数，主题总数，精华帖子总数</li>
			<li>修复版面的上级版面列表</li>
			<li>重新制作论坛跳转下拉版面列表(需要fso支持)</li>
			<li>重新制作转帖时的下拉版面列表(需要fso支持)</li>
			</ol>
			<div class=alert>因耗时较长，建议先暂停论坛访问后再进行此操作。</div>
			<div class=frameline>确认信息： 真的要开始修复所有版面吗？点击修复后请耐心等待程序完成执行。</div>
			<div class=frameline>
			<form action=MakeBoardList.asp method=post name=LeadBBSFm id=LeadBBSFm>
			<input name=submitflag value=yes type=hidden>
			<input type=submit value="点击确认开始修复" onclick="javascript:LeadBBSFm.submit();this.disabled=true;" class=fmbtn>
			</form>
			</div>
		<%
	End If
Else
DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")


Function UpdateBoardAnnounceNum2

	Dim Rs,GetData,BoardNum
	Con.CommandTimeout = 240
	Set Rs = LDExeCute("Select BoardID,BoardName,LowerBoard,BoardLimit from LeadBBS_Boards order by BoardLevel DESC",0)
	If Not Rs.Eof Then
		GetData = Rs.GetRows(-1)
		BoardNum = Ubound(GetData,2)
	Else
		BoardNum = -1
	End If
	Rs.Close
	Set Rs = Nothing

	If BoardNum = -1 Then
	Else
		Dim N,TopicNum,AnnounceNum,AllMinRootID,AllMaxRootID,TodayAnnounce,GoodNum
		Dim TopicNum_All,AnnounceNum_All,TodayAnnounce_All,GoodNum_All,ParentBoardStr
		Dim LastAnnounceID,LastTopicName,LastWriter,LastTime
		For N = 0 to BoardNum
			Set Rs = LDExeCute("select count(*) from LeadBBS_Announce where GoodFlag=1 and BoardID=" & getData(0,N),0)
			If Rs.Eof Then
				GoodNum = 0
			Else
				GoodNum = Rs(0)
				If isNull(GoodNum) Then GoodNum = 0
				GoodNum = cCur(GoodNum)
			End If
			Rs.Close
			Set Rs = Nothing

			Set Rs = LDExeCute("select count(*) from LeadBBS_Announce where BoardID=" & getData(0,N) & " and ndatetime>" & Left(LngStr(GetTimeValue(DEF_Now)),8) & "000000",0)
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
					Set Rs = LDExeCute("select count(*) from LeadBBS_Announce where ParentID = 0 and BoardID=" & GetData(0,N),0)
				case Else
					Set Rs = LDExeCute("select count(*) from LeadBBS_Topic where BoardID=" & GetData(0,N),0)
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
			
			Set Rs = LDExeCute("select count(*) from LeadBBS_Announce where BoardID=" & GetData(0,N),0)
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
					Set Rs = LDExeCute("select Min(RootID) from LeadBBS_Announce where ParentID = 0 and BoardID=" & GetData(0,N),0)
				case Else
					Set Rs = LDExeCute("select Min(RootID) from LeadBBS_Topic where BoardID=" & GetData(0,N),0)
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
					Set Rs = LDExeCute("select Max(RootID) from LeadBBS_Announce where ParentID = 0 and BoardID=" & GetData(0,N),0)
				case Else
					Set Rs = LDExeCute("select Max(RootID) from LeadBBS_Topic where BoardID=" & GetData(0,N),0)
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
					Set Rs = LDExeCute(sql_select("Select ID,title,LastUser,UserName,LastTime,TitleStyle from LeadBBS_Announce where ParentID = 0 and BoardID=" & GetData(0,N) & " and RootID<" & DEF_BBS_TOPMinID & " order By RootID DESC",1),0)
				case Else
					Set Rs = LDExeCute(sql_select("Select ID,title,LastUser,UserName,LastTime,TitleStyle from LeadBBS_Topic where BoardID=" & GetData(0,N) & " and RootID<" & DEF_BBS_TOPMinID & " order By RootID DESC",1),0)
			End select
			If Rs.Eof Then
				LastAnnounceID = 0
				LastTopicName = ""
				LastTime = 0
				LastWriter = ""
			Else
				LastAnnounceID = Rs(0)
				LastTopicName = Rs(1)
				LastWriter = Rs(2)
				If LastWriter = "" or isNull(LastWriter) Then LastWriter = Rs(3)
				LastTime = cCur(Rs(4))
				If isNull(LastTime) then LastTime = 0
				If Rs(5) = 1 Then LastTopicName = KillHTMLLabel(LastTopicName)
			End If
			Rs.Close
			Set Rs = Nothing
			
			TopicNum_All = TopicNum
			AnnounceNum_All = AnnounceNum
			TodayAnnounce_All = TodayAnnounce
			GoodNum_All = GoodNum
			If GetData(2,N) & "" <> "" Then
				Set Rs = LDExeCute("Select sum(TopicNum_All),Sum(AnnounceNum_All),Sum(TodayAnnounce_All),Sum(GoodNum_All) from LeadBBS_Boards where BoardID in(" & GetData(2,N) & ")",0)
				If Not Rs.Eof Then
					If Not isNull(Rs(0)) Then TopicNum_All = TopicNum_All + cCur(Rs(0))
					If Not isNull(Rs(1)) Then AnnounceNum_All = AnnounceNum_All + cCur(Rs(1))
					If Not isNull(Rs(2)) Then TodayAnnounce_All = TodayAnnounce_All + cCur(Rs(2))
					If Not isNull(Rs(3)) Then GoodNum_All = GoodNum + cCur(Rs(3))
				End If
				Rs.Close
				Set Rs = Nothing
			End If

			ParentBoardStr = GetParentBoardStr(cCur(GetData(0,N)))
			If GetBinarybit(GetData(3,N),12) = 1 Then
				CALL LDExeCute("Update LeadBBS_Boards Set ParentBoardStr='" & Replace(ParentBoardStr,"'","''") & "',TopicNum=" & TopicNum & ",TopicNum_All=" & TopicNum_All & ",AnnounceNum=" & AnnounceNum & ",AnnounceNum_All=" & AnnounceNum_All & ",AllMinRootID=" & AllMinRootID & ",AllMaxRootID=" & AllMaxRootID & ",TodayAnnounce=" & TodayAnnounce & ",TodayAnnounce_All=" & TodayAnnounce_All & ",GoodNum=" & GoodNum & ",GoodNum_All=" & GoodNum_All & " where boardID=" & GetData(0,N),1)
			Else
				CALL LDExeCute("Update LeadBBS_Boards Set ParentBoardStr='" & Replace(ParentBoardStr,"'","''") & "',TopicNum=" & TopicNum & ",TopicNum_All=" & TopicNum_All & ",AnnounceNum=" & AnnounceNum & ",AnnounceNum_All=" & AnnounceNum_All & ",AllMinRootID=" & AllMinRootID & ",AllMaxRootID=" & AllMaxRootID & ",TodayAnnounce=" & TodayAnnounce & ",TodayAnnounce_All=" & TodayAnnounce_All & ",GoodNum=" & GoodNum & ",GoodNum_All=" & GoodNum_All & ",LastAnnounceID=" & LastAnnounceID & ",LastTopicName='" & Replace(LastTopicName,"'","''") & "',LastWriter='" & Replace(LastWriter,"'","''") & "',LastWriteTime=" & LastTime & " where boardID=" & GetData(0,N),1)
			End If
			ReloadBoardInfo(GetData(0,N))
			ReloadTopicAssort(GetData(0,N))
			Response.Write GetData(1,N) & "完成更新<br>" & VbCrLf
		Next
	End If

End Function

Function GetParentBoardStr(BoardID)

	Dim Temp,TempStr,N
	If isArray(Application(DEF_MasterCookies & "BoardInfo" & BoardID)) = False Then ReloadBoardInfo(BoardID)
	If isArray(Application(DEF_MasterCookies & "BoardInfo" & BoardID)) = False Then
		GetParentBoardStr = BoardID
		Exit Function
	End If
	Temp = cCur(Application(DEF_MasterCookies & "BoardInfo" & BoardID)(26,0))
	TempStr = BoardID
	Do While Temp > 0
		If isArray(Application(DEF_MasterCookies & "BoardInfo" & Temp)) = False Then
			ReloadBoardInfo(Temp)
			If isArray(Application(DEF_MasterCookies & "BoardInfo" & Temp)) = False Then Exit Do
		End If
		TempStr = Temp & "," & TempStr
		Temp = cCur(Application(DEF_MasterCookies & "BoardInfo" & Temp)(26,0))
		N = N + 1
		If N > 10 Then Exit Do
	Loop
	GetParentBoardStr = TempStr

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

End Sub%>