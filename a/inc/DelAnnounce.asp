<%
Dim AncIDStr
AncIDStr = "2798569" '红包主题ID列表，逗号分隔，回复此类帖子将奖励随机声望(1-3)，并且此类帖子将禁止删除回复(但可编辑)

Function CheckDelSure

	If GetBinarybit(GBL_CHK_UserLimit,5) = 1 Then
		Processor_ErrMsg "你已经被" & LimitUserStringData(4) & "！" & VbCrLf
		CheckDelSure = 0
		Exit Function
	End If

	If CheckSure = 0 Then Exit Function

	If GetBinarybit(GBL_Board_BoardLimit,5) = 1 Then
		Processor_ErrMsg "此版面不允许删除帖子！"
		CheckDelSure = 0
		Exit Function
	End If

	CheckisBoardMaster
	If GBL_UserID >= 1 and GBL_BoardMasterFlag >= 5 Then
		CheckDelSure = 1
	Else
		CheckDelSure = 0
		Processor_ErrMsg "错误，权限不足！"
	End If

End Function

Sub Process_DelAnnounce(AncID)

	Dim AnnounceTitle
	Dim Rs,SQL
	SQL = sql_select("Select t1.BoardID,t1.ParentID,t1.UserID,t2.UserName,t1.RootID,t1.Layer,t1.TopicType,t1.ndatetime,t1.GoodFlag,t1.RootIDBak,t1.Title,t1.GoodAssort,t1.TitleStyle from LeadBBS_Announce as t1 left join leadbbs_user as t2 on t1.userid=t2.id where t1.id=" & AncID & " and t1.BoardID=" & GBL_Board_ID,1)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Processor_ErrMsg "错误，未选择要删除的帖子！" & VbCrLf
		Rs.Close
		Set Rs = Nothing
		Exit Sub
	End if

	Dim BoardID,ParentID,UserID,RootID,Layer,TopicType,ndatetime,GoodFlag,RootIDBak,GoodAssort,DelAncUser
	BoardID = cCur(Rs("BoardID"))
	ParentID = cCur(Rs("ParentID"))
	UserID = cCur(Rs("UserID"))
	RootID = cCur(Rs("RootID"))
	Layer = cCur(Rs("Layer"))
	TopicType = Rs("TopicType")
	ndatetime = RestoreTime(Rs("ndatetime"))
	If IsNull(TopicType) Then TopicType = 0
	GoodFlag = Rs("GoodFlag")
	RootIDBak = cCur(Rs("RootIDBak"))
	AnnounceTitle = KillHTMLLabel(DisplayAnnounceTitle(Rs("Title"),Rs("TitleStyle")))
	GoodAssort = cCur(Rs("GoodAssort"))
	DelAncUser = Rs("UserName")
	

	If ParentID = 0 Then
		GBL_CHK_TempStr = "<b><font color=ff0000 class=redfont>删除的帖子是主题帖,将删除主题帖和所有回复帖！</font></b><br>"
	Else
		GBL_CHK_TempStr = "将删除的帖子是个回复帖子．<br>"		
	End If
	
	Rs.Close
	Set Rs = Nothing
	
	If CheckLimitNameOnly(DelAncUser) = 1 and GBL_BoardMasterFlag < 9 and (CheckSupervisorNameOnly = 0 or GBL_UserID < 1) then
		Processor_ErrMsg "编号" & AncID & "帖子无足够删除权限。"
		Exit Sub
	end if
	
	If ParentID > 0 and inStr("," & AncIDStr & ",","," & RootIDBak & ",") and CheckSupervisorUserName = 0 Then
		Processor_ErrMsg "此主题回复帖已禁止删除！"
		Exit Sub
	End If

	Dim RootIDTopicType,TopicUserID
	TopicUserID = 0
	If ParentID > 0 Then
		select case DEF_UsedDataBase
			case 0,2:
				SQL = sql_select("Select TopicType,UserID from LeadBBS_Announce where ParentID=0 and RootIDBak=" & RootIDBak,1)
			case Else
				SQL = sql_select("Select TopicType,UserID from LeadBBS_Topic where ID=" & RootIDBak,1)
		End select
		Set Rs = LDExeCute(SQL,0)
		If Not Rs.Eof Then
			RootIDTopicType = Rs(0)
			TopicUserID = cCur(Rs(1))
			If isNull(RootIDTopicType) Then RootIDTopicType = 0
		Else
			RootIDTopicType = 0
		End If
		Rs.Close
		Set Rs = Nothing
	Else
		TopicUserID = UserID
		RootIDTopicType = 0
	End If
	
	Dim todayAnnounce,GoodNum,GoodNum2
	todayAnnounce = 0
	
	If Day(ndatetime) = Day(DEF_Now) and Year(ndatetime) = year(DEF_Now) and Month(ndatetime) = Month(DEF_Now) Then todayAnnounce = 1
	If GoodFlag = 1 Then
		GoodNum = 1
	Else
		GoodNum = 0
	End If
	GoodNum2 = 0
	
	If GBL_Board_ID <> 444 and DEF_EnableDelAnnounce = 0 and ParentID = 0 Then
		Processor_ErrMsg "系统已经禁止直接删除主题帖子，请使用回收站功能。"
		Exit Sub
	End If
	Dim DelPoints
		If ParentID > 0 Then
			DelPoints = DEF_BBS_AnnouncePoints
			If GoodFlag = 1 Then DelPoints = DelPoints + DEF_BBS_MakeGoodAnnouncePoints
			DelUpload_DelList(AncID)
			CALL LDExeCute("Delete from LeadBBS_Announce where id=" & AncID,1)
			CALL LDExeCute("Delete from LeadBBS_Opinion Where AnnounceID=" & AncID,1)

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
				UpdateBoardAnnounceNum Application(DEF_MasterCookies & "BoardInfo" & BoardID)(28,0),-1,-1,0-todayAnnounce,0-GoodNum
				UpdateStatisticDataInfo -1,9,1
				UpdateStatisticDataInfo -1,10,1
				If todayAnnounce > 0 Then UpdateStatisticDataInfo 0-todayAnnounce,11,1
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
				UpdateBoardAnnounceNum Application(DEF_MasterCookies & "BoardInfo" & BoardID)(28,0),0,-1,0-todayAnnounce,0-GoodNum
				UpdateStatisticDataInfo 0-TmpAnnounceNum,9,1
				If todayAnnounce > 0 Then UpdateStatisticDataInfo 0-todayAnnounce,11,1
				CALL LDExeCute("Update LeadBBS_Announce Set ChildNum=ChildNum-1,LastTime=" & LastTime & ",LastUser='" & Replace(LastUser,"'","''") & "',LastInfo='' where id=" & RootIDBak,1)
				If DEF_UsedDataBase = 1 Then CALL LDExeCute("Update LeadBBS_Topic Set ChildNum=ChildNum-1,LastTime=" & LastTime & ",LastUser='" & Replace(LastUser,"'","''") & "',LastInfo='' where id=" & RootIDBak,1)
			End If
			CALL LDExeCute("Update LeadBBS_User set Points=Points-" & DelPoints & ",AnnounceNum=AnnounceNum-1,AnnounceGood=AnnounceGood-" & GoodNum & " Where ID =" & UserID,1)
			LMT_AncID = RootIDBak
			Processor_Done "成功删除论坛帖子"
			UpdateBoardValue(BoardID)
			Rem 更新MaxRootID

			select case DEF_UsedDataBase
				case 0,2:
					SQL = "Update LeadBBS_Announce set RootMaxID=" & TmpMaxID & _
							",RootMinID=" & TmpMinID &_
							" where ParentID=0 and RootIDBak=" & RootIDBak
					CALL LDExeCute(SQL,1)
				case else
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
			Server.ScriptTimeOut = 65535
			Dim LoopFlag,NowID,GetData,N
			LoopFlag = 1
			NowID = 0
			
			GoodNum2 = 0
			Dim TmpTopicNum,TmpAnnounceNum,GoodNum3
			TmpAnnounceNum = 0
			TmpTopicNum = 0
			todayAnnounce = 0
			DelPoints = 0
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
							DelPoints = DEF_BBS_MakeGoodAnnouncePoints
						Else
							GoodNum3 = 0
							DelPoints = 0
						End If
						If cCur(GetData(2,N)) = 0 Then
							TmpAnnounceNum = TmpAnnounceNum + 1
							TmpTopicNum = TmpTopicNum + 1
							DelPoints = DelPoints + DEF_BBS_AnnouncePoints * 2
						Else
							TmpAnnounceNum = TmpAnnounceNum + 1
							DelPoints = DelPoints + DEF_BBS_AnnouncePoints
						End If
						GetData(4,n) = RestoreTime(GetData(4,n))
						If Day(GetData(4,n)) = Day(DEF_Now) and Year(GetData(4,n)) = year(DEF_Now) and Month(GetData(4,n)) = Month(DEF_Now) Then todayAnnounce = todayAnnounce + 1
						If GetData(6,n) & "" <> "" Then CALL LDExeCute("Delete from LeadBBS_Opinion Where AnnounceID=" & GetData(0,n),1)
						If cCur(GetData(2,N)) = 0 Then
							CALL LDExeCute("Update LeadBBS_User set Points=Points-" & DelPoints & ",AnnounceNum=AnnounceNum-1,AnnounceTopic=AnnounceTopic-1,AnnounceGood=AnnounceGood-" & GoodNum3 & " Where ID =" & GetData(3,N),1)
						Else
							CALL LDExeCute("Update LeadBBS_User set Points=Points-" & DelPoints & ",AnnounceNum=AnnounceNum-1,AnnounceGood=AnnounceGood-" & GoodNum3 & " Where ID =" & GetData(3,N),1)
						End If
						NowID = cCur(GetData(0,N))
					Next
					DelUpload_DelList(" where RootIDBak=" & RootIDBak & " and id<=" & NowID)
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
				CALL LDExeCute("Delete from LeadBBS_VoteUser Where AnnounceID=" & LMT_AncID,1)
				CALL LDExeCute("Delete from LeadBBS_Opinion Where AnnounceID=" & LMT_AncID,1)
				If TopicType = 80 Then
					CALL LDExeCute("Delete from LeadBBS_VoteItem Where AnnounceID=" & LMT_AncID,1)
				End if
			End If
			UpdateBoardAnnounceNum Application(DEF_MasterCookies & "BoardInfo" & BoardID)(28,0),0-TmpTopicNum,0-TmpAnnounceNum,0-todayAnnounce,0-GoodNum2
			UpdateStatisticDataInfo 0-TmpAnnounceNum,9,1
			UpdateStatisticDataInfo 0-TmpTopicNum,10,1
			If todayAnnounce > 0 Then UpdateStatisticDataInfo 0-todayAnnounce,11,1

			UpdateBoardValue(BoardID)
			If GoodAssort > 0 Then ChangeGoodAssort GoodAssort,0
			If TopicUserID > 0 and (LMT_Prc_MsgFlag = 2 or Request.Form("SendMessage") = "1") Then SendNewMessage Prc_User,DelAncUser,"论坛短信：帖子删除通知","[color=blue]您所发表的帖子已被删除[/color][hr]" &_
			"[b]所在版面：[/b][url=../b/" & RW_b(GBL_Board_ID,0,"") & "]" & htmlencode(KillHTMLLabel(GBL_Board_BoardName)) & "[/url]" & VbCrLf & _
			"[b]帖子作者：[/b]" & DelAncUser & VbCrLf & _
			"[b]操作人员：[/b]" & GBL_CHK_User & VbCrLf & _
			"[b]操作原因：[/b]" & htmlencode(Left(Request.Form("SendWhys"),24)) & VbCrLf & _
			"[b]帖子标题：[/b][url=../a/" & RW_a(GBL_Board_ID,LMT_AncID,1,1,"") & "]" & htmlencode(AnnounceTitle) & "[/url]",GBL_IPAddress
			LMT_AncID = 0
			Processor_Done "<br>成功删除此主题相关的回复帖子及主题帖子"
		End If
		If CheckSupervisorUserName = 0 Then
			CALL LDExeCute("Update LeadBBS_User Set LastWriteTime=" & GetTimeValue(DEF_Now) & " where ID=" & GBL_UserID,1)
			UpdateSessionValue 13,GetTimeValue(DEF_Now),0
		End If
		CALL LDExeCute("insert into LeadBBS_Log(LogType,LogTime,LogInfo,UserName,IP,BoardID) Values(101," & GetTimeValue(DEF_Now) & ",'" & Left("成功删除版面编号" & BoardID & "，帖子编号" & LMT_AncID & "，作者编号" & UserID & "的帖子．标题内容：" & Replace(AnnounceTitle,"'","''"),255) & "','" & Replace(GBL_CHK_User,"'","''") & "','" & Replace(GBL_IPAddress,"'","''") & "'," & GBL_Board_ID & ")",1)
		If inStr(application(DEF_MasterCookies & "TopAncList" & GBL_Board_BoardAssort),"," & RootIDBak & ",") Then ReloadTopAnnounceInfo(GBL_Board_BoardAssort)

	Set Rs = Nothing

End Sub

Sub DisplayDelAnnounce

	LMT_AncID = Request("ID")
	If InStr(LMT_AncID,",") > 0 Then
		Dim TmpMsg,i
		TmpMsg = Split(LMT_AncID,",")
		If Ubound(TmpMsg,1) >= DEF_MaxListNum and Ubound(TmpMsg,1) >= DEF_TopicContentMaxListNum Then
			LMT_AncID = 0
		Else
			LMT_AncID = ""
			For i = 0 to Ubound(TmpMsg,1)
				If isNumeric(TmpMsg(i)) = 0 Then
					LMT_AncID = 0
					Exit For
				Else
					If LMT_AncID = "" Then
						LMT_AncID = Fix(cCur(TmpMsg(i)))
					Else
						LMT_AncID = LMT_AncID & "," & Fix(cCur(TmpMsg(i)))
					End If
				End If
			Next
		End If
	Else
		If isNumeric(LMT_AncID) = 0 or LMT_AncID = "" Then LMT_AncID = 0
		LMT_AncID = Fix(cCur(LMT_AncID))
	End If
	
	If cStr(LMT_AncID) = "0" or LMT_AncID = "" Then
		Processor_ErrMsg "请先选择要操作的记录。" & VbCrLf
		Exit Sub
	End if
	
	If Request.Form("SureFlag")="1" Then
		Dim Tmp,N
		Tmp = Split(LMT_AncID,",")
		For N = 0 to Ubound(Tmp,1)
			Process_DelAnnounce(Tmp(N))
		Next
	Else
		Processor_form "Del","删除"
	End If

End Sub%>