<%Function CheckAllTopAncSure

	Part = Request.QueryString("Part")
	If Part = "" Then Part = Request.Form("Part")
	If Part <> "1" Then Part = ""

	If GBL_UserID < 1 or GetBinarybit(GBL_CHK_UserLimit,4) = 1 Then
		CheckAllTopAncSure = 0
		Call Processor_ErrMsg("错误，权限不足！")
		Exit Function
	End If

	If CheckSure() = 0 Then Exit Function
	
	If Form_ParentID <> 0 Then
		Call Processor_ErrMsg("要处理的帖子必须为主题帖子！")
		CheckAllTopAncSure = 0
		Exit Function
	End if

	CheckisBoardMaster()
	If Part = "1" Then
		If GBL_UserID < 1 or GBL_BoardMasterFlag < 6 or GetBinarybit(GBL_CHK_UserLimit,4) = 1 Then
			CheckAllTopAncSure = 0
			Call Processor_ErrMsg("错误，权限不足！")
			Exit Function
		End If
		If GBL_BoardMasterFlag < 7 and inStr(application(DEF_MasterCookies & "TopAncList"),"," & Form_RootIDBak & ",") Then
			CheckAllTopAncSure = 0
			Call Processor_ErrMsg("此帖子已经是总固顶状态，您无权限操作此主题。")
			Exit Function
		End If
	Else
		If GBL_UserID < 1 or GBL_BoardMasterFlag < 7 or GetBinarybit(GBL_CHK_UserLimit,4) = 1 Then
			CheckAllTopAncSure = 0
			Call Processor_ErrMsg("错误，权限不足！")
			Exit Function
		End If
	End If
	
	If Part = "1" Then
		RootStr = "区"
		PartStr = GBL_Board_BoardAssort
	Else
		RootStr = "总"
		PartStr = ""
	End If
	If CheckMakeAllTopAnnounceOver() = 1 then
		Call Processor_ErrMsg("错误," & RootStr & "置顶的帖子太多，不能再进行置顶操作！")
		CheckAllTopAncSure = 0
		Exit Function
	End If
	If Form_RootID < DEF_BBS_TOPMinID or inStr(application(DEF_MasterCookies & "TopAncList" & PartStr),"," & Form_RootIDBak & ",") = 0 Then
		RootStr = RootStr & "固顶"
		If CheckMakeTopAnnounceOver() = 1 then
			Call Processor_ErrMsg("错误，置顶的帖子太多，不能再进行置顶操作！")
			CheckAllTopAncSure = 0
			Exit Function
		Else
			CheckAllTopAncSure = 1
		End If
	Else
		RootStr = "取消" & RootStr & "固顶"
		CheckAllTopAncSure = 1
	End If

End Function

Function CheckMakeAllTopAnnounceOver

	Dim Rs,Num
	Dim GetDataTop
	GetDataTop = application(DEF_MasterCookies & "TopAnc" & PartStr)
	If isArray(GetDataTop) = False Then
		If GetDataTop <> "yes" Then
			If PartStr = "" then
				ReloadTopAnnounceInfo(0)
			Else
				ReloadTopAnnounceInfo(PartStr)
			End If
			GetDataTop = application(DEF_MasterCookies & "TopAnc" & PartStr)
		End If
	End If

	If isArray(GetDataTop) = False Then
		Num = 0
	Else
		Num = Ubound(GetDataTop,2) + 1
	End If

	AllTopFlag = 0
	If inStr(application(DEF_MasterCookies & "TopAncList" & PartStr),"," & Form_RootIDBak & ",") Then
		AllTopFlag = 1
	Else
		AllTopFlag = 0
	End If

	If Num > DEF_BBS_MaxAllTopAnnounce and AllTopFlag = 0 Then
		CheckMakeAllTopAnnounceOver = 1
	Else
		CheckMakeAllTopAnnounceOver = 0
	End If

End Function


Function DisplayAllTopAncAnnounce

	If LMT_AncID = 0 Then
		Call Processor_ErrMsg("错误，未选择要" & RootStr & "的帖子！" & VbCrLf)
		Exit Function
	End if
	If Request.Form("SureFlag")="1" Then
		MakeAllTopAnc(LMT_AncID)
		Call Processor_Done("成功" & RootStr & "论坛帖子。")
	Else
		Call Processor_form("AllTopAnc&Part=" & Part,RootStr)
	End If

End Function

Sub MakeAllTopAnc(AnnounceID)

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
		Exit Sub
	End If
	If RootID<DEF_BBS_TOPMinID Then
		If AllTopFlag = 0 Then
			select case DEF_UsedDataBase
				case 0,2:
					SQL = "Select Max(RootID) from LeadBBS_Announce where ParentID=0 and BoardID=" & BoardID
				case Else
					SQL = "Select Max(RootID) from LeadBBS_Topic where BoardID=" & BoardID
			End select
			Set Rs = LDExeCute(SQL,0)
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
			If PartStr = "" Then
				CALL LDExeCute("insert into LeadBBS_TopAnnounce(RootID,BoardID,TopType) values(" & RootIDBak & "," & BoardID & ",0)",1)
			Else
				CALL LDExeCute("insert into LeadBBS_TopAnnounce(RootID,BoardID,TopType) values(" & RootIDBak & "," & BoardID & "," & PartStr & ")",1)
			End If
		Else
			CALL LDExeCute("delete from LeadBBS_TopAnnounce where RootID=" & RootIDBak,1)
		End If
	Else
		If AllTopFlag = 0 Then
			If PartStr = "" Then
				If inStr(application(DEF_MasterCookies & "TopAncList" & GBL_Board_BoardAssort),"," & RootIDBak & ",") = 0 Then
					CALL LDExeCute("insert into LeadBBS_TopAnnounce(RootID,BoardID,TopType) values(" & RootIDBak & "," & BoardID & ",0)",1)
				Else
					CALL LDExeCute("Update LeadBBS_TopAnnounce Set TopType=0 where RootID=" & RootIDBak,1)
				End If
			Else
				If inStr(application(DEF_MasterCookies & "TopAncList"),"," & RootIDBak & ",") = 0 Then
					CALL LDExeCute("insert into LeadBBS_TopAnnounce(RootID,BoardID,TopType) values(" & RootIDBak & "," & BoardID & "," & PartStr & ")",1)
				Else
					CALL LDExeCute("Update LeadBBS_TopAnnounce Set TopType=" & PartStr & " where RootID=" & RootIDBak,1)
				End If
			End If
		Else
			select case DEF_UsedDataBase
				case 0,2:
					SQL = "Select Max(RootID) from LeadBBS_Announce where ParentID=0 and BoardID=" & BoardID & " and RootID<" & DEF_BBS_TOPMinID
				case Else
					SQL = "Select Max(RootID) from LeadBBS_Topic where BoardID=" & BoardID & " and RootID<" & DEF_BBS_TOPMinID
			End select
			Set Rs = LDExeCute(SQL,0)
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
			CALL LDExeCute("delete from LeadBBS_TopAnnounce where RootID=" & RootIDBak,1)
		End If
	End If
	If CheckSupervisorUserName() = 0 Then
		CALL LDExeCute("Update LeadBBS_User Set LastWriteTime=" & GetTimeValue(DEF_Now) & " where ID=" & GBL_UserID,1)
		UpdateSessionValue 13,GetTimeValue(DEF_Now),0
	End If
	'UpdateBoardValue(BoardID)
	ReloadTopAnnounceInfo(0)
	ReloadTopAnnounceInfo(GBL_Board_BoardAssort)

End Sub%>