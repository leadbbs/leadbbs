<%Rem 固顶帖子
Function CheckTopAncSure
	
	If CheckSure = 0 Then Exit Function
	
	If Form_ParentID <> 0 Then
		Processor_ErrMsg "要处理的帖子必须为主题帖子！"
		CheckTopAncSure = 0
		Exit Function
	End if

	CheckisBoardMaster
	If GBL_BoardMasterFlag < 5 or GetBinarybit(GBL_CHK_UserLimit,4) = 1 Then
		CheckTopAncSure = 0
		Processor_ErrMsg "错误，权限不足！"
		Exit Function
	End If

	CheckAllTopAnnounceFlag

	AllTopFlag = 0
	If inStr(application(DEF_MasterCookies & "TopAncList" & GBL_Board_BoardAssort),"," & LMT_AncID & ",") Then AllTopFlag = 1
	If inStr(application(DEF_MasterCookies & "TopAncList"),"," & LMT_AncID & ",") Then AllTopFlag = 2
	If GBL_BoardMasterFlag < 7 and AllTopFlag=2 Then
		CheckTopAncSure = 0
		Processor_ErrMsg "错误,权限不足，总固顶帖无权限取消！"
		Exit Function
	End If
	If GBL_BoardMasterFlag < 6 and AllTopFlag=1 Then
		CheckTopAncSure = 0
		Processor_ErrMsg "错误，权限不足，总固顶帖无权限取消！"
		Exit Function
	End If
	
	If Form_RootID < DEF_BBS_TOPMinID Then
		RootStr = "固顶"
		If CheckMakeTopAnnounceOver = 1 then
			Processor_ErrMsg "错误，置顶的帖子太多，不能再进行置顶操作！"
			CheckTopAncSure = 0
			Exit Function
		Else
			CheckTopAncSure = 1
		End If
	Else
		RootStr = "取消固顶"
		CheckTopAncSure = 1
	End If

End Function

Function CheckMakeTopAnnounceOver

	Dim Rs,SQL
	select case DEF_UsedDataBase
		case 0,2:
			SQL = "Select count(*) from LeadBBS_Announce Where ParentID = 0 and BoardID=" & GBL_board_ID & " and RootID>=" & DEF_BBS_TOPMinID
		case Else
			SQL = "Select count(*) from LeadBBS_Topic Where BoardID=" & GBL_board_ID & " and RootID>=" & DEF_BBS_TOPMinID
	End select
	Set Rs = LDExeCute(SQL,0)
	If Not Rs.Eof Then
		SQL = Rs(0)
		If isNull(SQL) Then SQL = 0
		SQL = cCur(SQL)
	Else
		SQL = 0
	End If
	Rs.Close
	Set Rs = Nothing

	If SQL > DEF_BBS_MaxTopAnnounce Then
		CheckMakeTopAnnounceOver = 1
	Else
		CheckMakeTopAnnounceOver = 0
	End If

End Function

Function CheckAllTopAnnounceFlag

	Dim Rs,SQL,Num

	SQL = sql_select("Select ID from LeadBBS_TopAnnounce where RootID=" & Form_RootIDBak,1)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		CheckAllTopAnnounceFlag = 0
	Else
		CheckAllTopAnnounceFlag = 1
	End If
	Rs.Close
	Set Rs = Nothing

End Function

Function DisplayTopAncAnnounce

	If LMT_AncID = 0 Then
		Processor_ErrMsg "错误，未选择要" & RootStr & "的帖子！" & VbCrLf
		Exit Function
	End if
	If Request.Form("SureFlag")="1" Then
		MakeTopAnc(LMT_AncID)
		Processor_Done "成功" & RootStr & "论坛帖子。"
	Else
		Processor_form "TopAnc",RootStr
	End If

End Function

Function MakeTopAnc(AnnounceID)

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
			case 0,2:
				Set Rs = LDExeCute("Select Max(RootID) from LeadBBS_Announce where ParentID=0 and BoardID=" & BoardID,0)
			case Else
				Set Rs = LDExeCute("Select Max(RootID) from LeadBBS_Topic where BoardID=" & BoardID,0)
		End select
		If Rs.Eof Then
			MaxRootID = DEF_BBS_TOPMinID
		Else
			MaxRootID = Rs(0)
			If isNull(MaxRootID) or MaxRootID="" Then
				MaxRootID=DEF_BBS_TOPMinID
			End If
			MaxRootID = cCur(MaxRootID)
		End If
		Rs.Close
		Set Rs = Nothing
		If MaxRootID < DEF_BBS_TOPMinID Then MaxRootID = DEF_BBS_TOPMinID
		select case DEF_UsedDataBase
			case 0,2:
				CALL LDExeCute("Update LeadBBS_Announce Set RootID=" & MaxRootID+1 & " where ParentID=0 and RootIDBak=" & RootIDBak,1)
			case Else
				CALL LDExeCute("Update LeadBBS_Announce Set RootID=" & MaxRootID+1 & " where ID=" & RootIDBak,1)
				CALL LDExeCute("Update LeadBBS_Topic Set RootID=" & MaxRootID+1 & " where ID=" & RootIDBak,1)
		End select
	Else
		select case DEF_UsedDataBase
			case 0,2:
				Set Rs = LDExeCute("Select Max(RootID) from LeadBBS_Announce where ParentID=0 and BoardID=" & BoardID & " and RootID<" & DEF_BBS_TOPMinID,0)
			case Else
				Set Rs = LDExeCute("Select Max(RootID) from LeadBBS_Topic where BoardID=" & BoardID & " and RootID<" & DEF_BBS_TOPMinID,0)
		End select
		If Rs.Eof Then
			MaxRootID = 0
		Else
			MaxRootID = Rs(0)
			If isNull(MaxRootID) or MaxRootID="" Then
				MaxRootID=0
			End If
			MaxRootID = cCur(MaxRootID)
		End If
		Rs.Close
		Set Rs = Nothing
		select case DEF_UsedDataBase
			case 0,2:
				CALL LDExeCute("Update LeadBBS_Announce Set RootID=" & MaxRootID+1 & " where ParentID=0 and RootIDBak=" & RootIDBak,1)
			case Else
				CALL LDExeCute("Update LeadBBS_Announce Set RootID=" & MaxRootID+1 & " where ID=" & RootIDBak,1)
				CALL LDExeCute("Update LeadBBS_Topic Set RootID=" & MaxRootID+1 & " where ID=" & RootIDBak,1)
		End select
		If AllTopFlag = 1 or AllTopFlag = 2 Then CALL LDExeCute("delete from LeadBBS_TopAnnounce where RootID=" & Form_RootIDBak,1)
	End If
	Set Rs = Nothing

	If CheckSupervisorUserName = 0 Then
		CALL LDExeCute("Update LeadBBS_User Set LastWriteTime=" & GetTimeValue(DEF_Now) & " where ID=" & GBL_UserID,1)
		UpdateSessionValue 13,GetTimeValue(DEF_Now),0
	End If
	'UpdateBoardValue(BoardID)
	If inStr(application(DEF_MasterCookies & "TopAncList"),"," & AnnounceID & ",") Then ReloadTopAnnounceInfo(0)
	If inStr(application(DEF_MasterCookies & "TopAncList" & GBL_Board_BoardAssort),"," & AnnounceID & ",") Then
		ReloadTopAnnounceInfo(GBL_Board_BoardAssort)
	End If

End Function%>