<%REM 转移帖子
Function CheckMoveSure

	If GetBinarybit(GBL_CHK_UserLimit,9) = 1 Then
		Processor_ErrMsg "错误，权限不足！" & VbCrLf
		CheckMoveSure = 0
		Exit Function
	End if

	If CheckSure = 0 Then Exit Function
	
	If Form_ParentID <> 0 Then
		Processor_ErrMsg "要处理的帖子必须为主题帖子！"
		CheckMoveSure = 0
		Exit Function
	End if

	If GetBinarybit(GBL_Board_BoardLimit,8) = 1 Then
		Processor_ErrMsg "此版面不允许转移或镜像帖子！"
		CheckMoveSure = 0
		Exit Function
	End If

	CheckisBoardMaster
	If GBL_UserID >= 1 and GBL_BoardMasterFlag >= 5 Then
		CheckMoveSure = 1
	Else
		CheckMoveSure = 0
		Processor_ErrMsg "错误，权限不足！"
	End If

End Function

Sub Process_MoveAnnounce(MoveID)

	Dim BoardID2
	BoardID2 = Request("BoardID3")
	'If CheckSupervisorUserName = 1 and BoardID2 <> "" Then
	If BoardID2 <> "" Then
		BoardID2 = Left(Request("BoardID3"),14)
	Else
		BoardID2 = Left(Request("BoardID2"),14)
	End If
	If isNumeric(BoardID2) = 0 or inStr(BoardID2,",") > 0 or BoardID2 = "" Then BoardID2 = 0
	BoardID2 = cCur(BoardID2)

	Dim Rs,SQL,GetData
	SQL = sql_select("Select ParentID,TopicSortID,BoardID,RootID,Layer,Title,Content,FaceIcon,ndatetime,LastTime,Length,UserName,UserID,UnderWriteFlag,htmlflag,NotReplay,IPAddress,TopicType,NeedValue,TitleStyle,RootIDBak,VisitIP,GoodAssort,PollNum,ChildNum,LastUser,Hits from LeadBBS_Announce where id=" & MoveID & " and BoardID=" & GBL_Board_ID,1)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Processor_ErrMsg "未选择要操作的帖子！" & VbCrLf
		Rs.Close
		Set Rs = Nothing
		Exit Sub
	End if
		
		Dim BoardID,ParentID,UserID,RootID,ChildNum,RootIDBak,GoodAssort,AnnounceTitle,AnnounceUser
		Dim MoveUserName
		BoardID = cCur(Rs(2))
		ParentID = cCur(Rs(0))
		UserID = cCur(Rs(12))
		MoveUserName = Rs(11)
		RootID = cCur(Rs(3))
		ChildNum = cCur(Rs(24))
		RootIDBak = cCur(Rs(20))
		GoodAssort = cCur(Rs(22))
		AnnounceTitle = KillHTMLLabel(DisplayAnnounceTitle(Rs(5),Rs(19)))
		AnnounceUser = Rs(11)
		GetData = Rs.GetRows(1)
		Rs.Close
		Set Rs = Nothing
		
	If CheckLimitNameOnly(MoveUserName) = 1 and GBL_BoardMasterFlag < 9 and (CheckSupervisorNameOnly = 0 or GBL_UserID < 1) then
		Processor_ErrMsg "编号" & MoveID & "帖子无足够权限操作。"
		Exit Sub
	end if
		
		Dim BoardName
		Dim Temp
		Temp = Application(DEF_MasterCookies & "BoardInfo" & BoardID)
		If isArray(Temp) = False Then
			ReloadBoardInfo(BoardID)
			Temp = Application(DEF_MasterCookies & "BoardInfo" & BoardID)
		End If
		If isArray(Temp) = False Then
			Processor_ErrMsg "论坛发生错误，请联系管理员！" & VbCrLf
			Set Rs = Nothing
			Exit Sub
		End If
		BoardName = Temp(0,0)
		
		If BoardID2 < 1 Then
			Processor_ErrMsg "错误，目标论坛不存在！" & VbCrLf
			Exit Sub
		End if
		
		If BoardID2 = BoardID Then
			Processor_ErrMsg "目标论坛就是主题所在论坛，操作忽略！" & VbCrLf
			Exit Sub
		End if
	
		Dim BoardName2,BoardLimit2
		
		Temp = Application(DEF_MasterCookies & "BoardInfo" & BoardID2)
		If isArray(Temp) = False Then
			ReloadBoardInfo(BoardID2)
			Temp = Application(DEF_MasterCookies & "BoardInfo" & BoardID2)
		End If
		If isArray(Temp) = False Then
			If BoardID2 = 444 Then
				Processor_ErrMsg "论坛回收站未建立，请联系管理员！" & VbCrLf
			Else
				Processor_ErrMsg "论坛发生错误，请联系管理员！" & VbCrLf
			End If
			Exit Sub
		End If
		BoardName2 = Temp(0,0)
		BoardLimit2 = Temp(9,0)
		If GetBinarybit(BoardLimit2,12) = 1 Then
			Processor_ErrMsg "目标版面<u>属于分类论坛</u>，不允许此操作。" & VbCrLf
			Exit Sub
		End If
		
		'注意,没有对下面的语句作专门的索引,当某主题回复帖子巨大时,可能速度会下降得厉害,如果有必要,在数据库中建立相应的索引,但索引多会导致数据库性能下降.
		Dim TodayAnnounce
		Set Rs = LDExeCute("select count(*) from LeadBBS_Announce where RootIDBak=" & RootIDBak  & " and ndatetime>" & Left(GetTimeValue(DEF_Now),8) & "000000",0)
		If Rs.Eof Then
			TodayAnnounce = 0
		Else
			TodayAnnounce = Rs(0)
			If isNull(TodayAnnounce) Then TodayAnnounce = 0
			TodayAnnounce = cCur(TodayAnnounce)
		End If
		Rs.Close
		Set Rs = Nothing
		
		If Action_Str = "mirror" Then
			If cCur(GetData(17,0)) = 39 Then
				Processor_ErrMsg "此帖<u>已是镜像帖子</u>，无法再次镜像。" & VbCrLf
				Exit Sub
			End If
			GetData(2,0) = BoardID2 'boardid
			GetData(3,0) = 0 'rootid
			GetData(6,0) = "" 'content
			'GetData(11,0) = "[LeadBBS]" 'username
			GetData(12,0) = 0 'userid
			'GetData(15,0) = 1 'lock
			GetData(17,0) = 39 'topictype
			GetData(18,0) = MoveID 'needvalue=id
			GetData(20,0) = 0 'rootidbak
			GetData(22,0) = 0 'goodassort
			
			SQL = " insert into LeadBBS_Announce(ParentID,TopicSortID,BoardID,RootID," & _
				    "Layer,Title,Content,FaceIcon,ndatetime,LastTime,Length," &_
				    "UserName,UserID,UnderWriteFlag,htmlflag,NotReplay,IPAddress,TopicType,NeedValue,TitleStyle,RootIDBak,VisitIP,GoodAssort,PollNum,ChildNum,LastUser,Hits,LastInfo)" &_
			" values(" & GetData(0,0) & "," & GetData(1,0) & "," & GetData(2,0) & "," & GetData(3,0) & "," &_
			GetData(4,0) & ",'" & Replace(GetData(5,0),"'","''") & "','" & GetData(6,0) & "'," &_
			GetData(7,0) & "," & GetData(8,0) & "," & GetData(9,0) & "," & GetData(10,0) & ",'" &_
			Replace(GetData(11,0),"'","''") & "'," & GetData(12,0) & "," & GetData(13,0) & "," & GetData(14,0) & "," & GetData(15,0) & ",'" & Replace(GetData(16,0),"'","''") & "'" & _
			"," & GetData(17,0) & "," & GetData(18,0) & "," & GetData(19,0) & "," & GetData(20,0) & ",'" & Replace(GetData(21,0),"'","''") & "'," & GetData(22,0) & "," & GetData(23,0) & "," & GetData(24,0) & ",'" & Replace(GetData(25,0),"'","''") & "'," & GetData(26,0) & "," & BoardID & ")"
			CALL LDExeCute(SQL,1)
			
			Dim NewAnnounceID
			select case DEF_UsedDataBase
			case 0,2:
				Set Rs = LDExeCute("select @@IDENTITY as id",0)
				NewAnnounceID = Rs(0)
				Rs.Close
				Set Rs = Nothing
				If isNull(NewAnnounceID) Then NewAnnounceID = 0
				NewAnnounceID = cCur(NewAnnounceID)
		
				If NewAnnounceID = 0 Then
					SQL = sql_select("Select ID,RootID from LeadBBS_Announce where UserID=" & Form_UserID & " order by id DESC",1)
					Set Rs = LDExeCute(SQL,0)
					If Rs.Eof Then
						GBL_CHK_TempStr = "意外错误: for mirror！<br>" & VbCrLf
						Rs.Close
						Set Rs = Nothing
						Exit Sub
					End If
					NewAnnounceID = Rs(0)
					If isNull(NewAnnounceID) Then NewAnnounceID = 0
					NewAnnounceID = cCur(NewAnnounceID)
					Rs.Close
					Set Rs = Nothing
				End If
			case Else
				SQL = "Select max(ID) from LeadBBS_Announce where UserID=" & Form_UserID
				Set Rs=LDExeCute(SQL,0)
				GBL_DBNum = GBL_DBNum + 1
				If Rs.Eof Then
					GBL_CHK_TempStr = "意外错误(mirror)！<br>" & VbCrLf
					Rs.Close
					Set Rs = Nothing
					Exit Sub
				End If
				NewAnnounceID = Rs(0)
				If isNull(NewAnnounceID) Then NewAnnounceID = 0
				NewAnnounceID = cCur(NewAnnounceID)
				Rs.Close
				Set Rs = Nothing
				
				SQL = " insert into LeadBBS_Topic(ID,BoardID,RootID," & _
					    "Title,FaceIcon,ndatetime,LastTime,Length," &_
					    "UserName,UserID,NotReplay,TopicType,NeedValue,TitleStyle,VisitIP,GoodAssort,PollNum,ChildNum,Hits,LastInfo)" &_
				" values(" & NewAnnounceID & "," & GetData(2,0) & "," & GetData(3,0) & "," &_
				"'" & Replace(GetData(5,0),"'","''") & "'," &_
				GetData(7,0) & "," & GetData(8,0) & "," & GetData(9,0) & "," & GetData(10,0) & ",'" &_
				Replace(GetData(11,0),"'","''") & "'," & GetData(12,0) & "," & GetData(15,0) & "" & _
				"," & GetData(17,0) & "," & GetData(18,0) & "," & GetData(19,0) & ",'" & Replace(GetData(21,0),"'","''") & "'," & GetData(22,0) & "," & GetData(23,0) & "," & GetData(24,0) & ",'" & Replace(GetData(25,0),"'","''") & "'," & GetData(26,0) & "," & BoardID & ")"
				CALL LDExeCute(SQL,1)
			End select
			CALL LDExeCute("Update LeadBBS_Announce Set RootMaxID=ID,RootMinID=ID,RootIDBak=ID where RootIDBak=0",1)
			If DEF_UsedDataBase = 1 Then CALL LDExeCute("Update LeadBBS_Topic Set RootMaxID=ID,RootMinID=ID where ID=" & NewAnnounceID,1)
			UpdateBoardAnnounceNum Application(DEF_MasterCookies & "BoardInfo" & BoardID2)(28,0),1,1,0,0
			CALL MakeAnnounceTop(NewAnnounceID,"")
			Processor_Done "<span class=greenfont>原主题成功镜像到" & BoardName2 & "！</span>" & VbCrLf
			Exit Sub
		End If

		'注意,没有对下面的语句作专门的索引,当某主题回复帖子巨大时,可能速度会下降得厉害,如果有必要,在数据库中建立相应的索引,但索引多会导致数据库性能下降.
		Dim GoodNum
		Set Rs = LDExeCute("select count(*) from LeadBBS_Announce where RootIDBak=" & RootIDBak & " and GoodFlag=1",0)
		If Rs.Eof Then
			GoodNum = 0
		Else
			GoodNum = Rs(0)
			If isNull(GoodNum) Then GoodNum = 0
			GoodNum = cCur(GoodNum)
		End If
		Rs.Close
		Set Rs = Nothing

		CALL LDExeCute("Update LeadBBS_Announce Set BoardID=" & BoardID2 & " where BoardID=" & BoardID & " and RootIDBak=" & RootIDBak,1)
		If DEF_UsedDataBase = 1 Then CALL LDExeCute("Update LeadBBS_Topic Set BoardID=" & BoardID2 & " where ID=" & RootIDBak,1)
		If GoodAssort > 0 Then
			CALL LDExeCute("Update LeadBBS_Announce Set GoodAssort=0 where ID=" & MoveID,1)
			If DEF_UsedDataBase = 1 Then CALL LDExeCute("Update LeadBBS_Topic Set GoodAssort=0 where ID=" & MoveID,1)
		End If
		CALL LDExeCute("Update LeadBBS_TopAnnounce Set BoardID=" & BoardID2 & " where BoardID=" & BoardID & " and RootID=" & RootIDBak,1)
		If CheckSupervisorUserName = 0 Then CALL LDExeCute("Update LeadBBS_Announce Set OtherInfo='此帖最后由" & Replace(LeftTrue(GBL_CHK_User,20),"'","''") & "在" & DEF_Now & "从 " & Replace(LeftTrue(KillHTMLLabel(BoardName),39),"'","''") & " 转移过来'" & " where ParentID=0 and RootIDBak=" & RootIDBak,1)
		'CALL LDExeCute("Update LeadBBS_Boards Set TopicNum=TopicNum-1,AnnounceNum=AnnounceNum-" & ChildNum+1 & ",TodayAnnounce=TodayAnnounce-" & TodayAnnounce & ",GoodNum=GoodNum-" & GoodNum & " where boardID=" & BoardID,1)
		UpdateBoardAnnounceNum Application(DEF_MasterCookies & "BoardInfo" & BoardID)(28,0),-1,0-ChildNum-1,0-TodayAnnounce,0-GoodNum
		'CALL LDExeCute("Update LeadBBS_Boards Set TopicNum=TopicNum+1,AnnounceNum=AnnounceNum+" & ChildNum+1 & ",TodayAnnounce=TodayAnnounce+" & TodayAnnounce & ",GoodNum=GoodNum+" & GoodNum & " where boardID=" & BoardID2,1)
		UpdateBoardAnnounceNum Application(DEF_MasterCookies & "BoardInfo" & BoardID2)(28,0),1,ChildNum+1,TodayAnnounce,GoodNum
		CALL MakeAnnounceTop(MoveID,"")
		DeleteAllTopData(MoveID)
		UpdateBoardValue(BoardID)
		UpdateBoardValue(BoardID2)
		If inStr(application(DEF_MasterCookies & "TopAncList" & GBL_Board_BoardAssort),"," & MoveID & ",") Then ReloadTopAnnounceInfo(GBL_Board_BoardAssort)
		
		If CheckSupervisorUserName = 0 Then
			CALL LDExeCute("Update LeadBBS_User Set LastWriteTime=" & GetTimeValue(DEF_Now) & " where ID=" & GBL_UserID,1)
			UpdateSessionValue 13,GetTimeValue(DEF_Now),0
		End If

		CALL LDExeCute("insert into LeadBBS_Log(LogType,LogTime,LogInfo,UserName,IP,BoardID) Values(103," & GetTimeValue(DEF_Now) & ",'" & Left("成功转移编号" & MoveID & "，原作者编号" & UserID & "的帖子．原版面编号" & BoardID & "(" & Replace(Replace(htmlencode(BoardName),"\","\\"),"'","''") & ")，目标论坛编号" & BoardID2 & "(" & Replace(Replace(htmlencode(BoardName2),"\","\\"),"'","''") & "．",255) & "','" & Replace(GBL_CHK_User,"'","''") & "','" & Replace(GBL_IPAddress,"'","''") & "'," & GBL_Board_ID & ")",1)
		
		If GoodAssort > 0 Then ChangeGoodAssort GoodAssort,0
		If LMT_Prc_MsgFlag = 2 or Request.Form("SendMessage") = "1" Then SendNewMessage Prc_User,AnnounceUser,"论坛短信：帖子转移通知","[color=blue]您所发表的帖子已被转移[/color]" & VbCrLf & VbCrLf &_
			"[b]原始版面：[/b][url=../b/" & RW_b(GBL_Board_ID,0,"") & "]" & htmlencode(KillHTMLLabel(BoardName)) & "[/url]" & VbCrLf & _
			"[b]目标版面：[/b]" & htmlencode(BoardName2) & VbCrLf & _
			"[b]操作人员：[/b]" & htmlencode(GBL_CHK_User) & VbCrLf & _
			"[b]操作原因：[/b]" & Left(Request.Form("SendWhys"),24) & VbCrLf & _
			"[b]帖子标题：[/b][url=../a/" & RW_a(GBL_Board_ID,MoveID,1,1,"") & "]" & htmlencode(AnnounceTitle) & "[/url]",GBL_IPAddress
		GBL_Board_ID = BoardID
		LMT_AncID = 0
		Processor_Done "<span class=greenfont>原主题成功转移到" & BoardName2 & "！</span>" & VbCrLf

End Sub

Function DisplayMoveAnnounce

	If cStr(LMT_AncID) = "0" Then
		Processor_ErrMsg "错误，未选择要操作的帖子！" & VbCrLf
		Exit Function
	End if

	Dim BoardID2
	BoardID2 = Request("BoardID3")
	'If CheckSupervisorUserName = 1 and BoardID2 <> "" Then
	If BoardID2 <> "" Then
		BoardID2 = Left(Request("BoardID3"),14)
	Else
		BoardID2 = Left(Request("BoardID2"),14)
	End If
	If isNumeric(BoardID2) = 0 or inStr(BoardID2,",") > 0 or BoardID2 = "" Then BoardID2 = 0
	BoardID2 = cCur(BoardID2)
		
	If Request.Form("SureFlag")="1" Then
	
		Dim Tmp,N
		Tmp = Split(LMT_AncID,",")
		For N = 0 to Ubound(Tmp,1)
			Process_MoveAnnounce(Tmp(N))
		Next
	Else
		Processor_Head
		%>
		<form name=DellClientForm action=<%=DEF_BBS_HomeUrl%>a/Processor.asp?Action=<%=Action_Str%>&b=<%=GBL_Board_ID%> onSubmit="submit_disable(this);" method="post"<%
	If AjaxFlag = 1 Then
		Response.Write " target=""hidden_frame"""
	End If
	%>>
			选择帖子：<%Response.Write "共<b>" & Len(LMT_AncID)-Len(Replace(LMT_AncID,",","")) + 1 & "</b>条记录"%>
			<input type=hidden name=SureFlag value="1">
			<input type=hidden name=JsFlag value="1">
			<input type=hidden name=AjaxFlag value="<%=AjaxFlag%>">
			<input type=hidden name=ID value="<%=LMT_AncID%>">
			<input type=hidden name=BoardID value="<%=GBL_Board_ID%>">
			<%If DEF_EnableDelAnnounce = 0 and BoardID2 = 444 and Action_Str <> "mirror" Then%>
				<div class="value2">帖子将被转移到回收版面，确认要回收此主题帖子吗？</div>
				<input type=hidden name=BoardID2 value="<%=BoardID2%>"><div class="value2">
			<%Else%>
				<div class="value2"><b>确认要<u><%
				If Action_Str = "Move" Then
					Response.Write "转移"
				Else
					Response.Write "镜像"
				End If%></u>选择的帖子吗？</b>
				</div>
				<div class="value2">
				选择目标论坛：<!-- #include file=../../inc/incHTM/BoardForMoveList.asp -->
			<%End If
			If BoardID2 <> 444 Then%>
				或填写编号：<input type=input name=BoardID3 value="" size=4 maxlength=14 class="fminpt input_1">
				</div>
			<%
			Else%>
				</div>
			<%End If%>
			<div class="value2">
			<%Processor_MsgForm%>
			</div>
			<br><input type=submit value=确定 class='fmbtn btn_2'>
		</form>
		<%Processor_Bottom
	End If

End Function%>