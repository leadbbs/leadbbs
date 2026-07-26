<%REM 修复或归入主题
Function CheckRepairSure

	If CheckSure() = 0 Then Exit Function
	
	If Form_ParentID <> 0 Then
		Call Processor_ErrMsg("要处理的帖子必须为主题帖子！")
		CheckRepairSure = 0
		Exit Function
	End if
	
	CheckisBoardMaster()
	If GBL_UserID >= 1 and (GBL_BoardMasterFlag >= 5 and GetBinarybit(GBL_CHK_UserLimit,4) = 0) Then
		CheckRepairSure = 1
	Else
		CheckRepairSure = 0
		Call Processor_ErrMsg("错误，权限不足．")
	End If

End Function

Function DisplayRepairAnnounce

	If LMT_AncID = 0 Then
		Response.Write "错误，未选择要修复的帖子！" & VbCrLf
		Exit Function
	End if
	If Request.Form("SureFlag")="1" Then
		Select Case RepairAnnounce(LMT_AncID)
			Case 0
				Call Processor_ErrMsg(GBL_CHK_TempStr)
			Case 1
				Call Processor_Done("成功修复论坛帖子。")
			Case 2
				Call Processor_Done("成功修复论坛帖子并归入相应专题。")
		End Select
	Else
		Processor_Head()
		%>
		<form name=DellClientForm action=Processor.asp?Action=Repair&b=<%=GBL_Board_ID%> onSubmit="submit_disable(this);" method="post"<%
		If AjaxFlag = 1 Then
			Response.Write " target=""hidden_frame"""
		End If
		%>>
			<input type=hidden name=SureFlag value="1">
			<input type=hidden name=JsFlag value="1">
			<input type=hidden name=AjaxFlag value="<%=AjaxFlag%>">
			<input type=hidden name=ID value="<%=LngStr(LMT_AncID)%>">
			<input type=hidden name=BoardID value="<%=GBL_Board_ID%>">
			<div class="value2"><b>确认要修复编号为<font color=ff0000 class=redfont><%=LngStr(LMT_AncID)%></font>的帖子吗？</b></div>
			<div class="value2"><%DisplayEType()%></div>
			<p><input type=submit value=确定 class="fmbtn btn_2">
		</form>
		<%Processor_Bottom
	End If

End Function

Function DisplayEType

	Dim TArray,N,Num,TArray2
	TArray = Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID & "_TI")
	TArray2 = Application(DEF_MasterCookies & "BoardInfo" & 0 & "_TI")
	If isArray(TArray) = False and isArray(TArray2) = False Then Exit Function
	%>
	修复并归入专题：<select name="GoodAssort"><%
	If isArray(TArray) Then
		Num = Ubound(TArray,2)
		Response.Write "		<option class=TBBG1 value=0>===选择版面专题区===</option>" & VbCrLf
		For N = 0 To Num
			If GoodAssort = cCur(TArray(0,N)) Then
				Response.Write "		<option class=TBBG9 value=" & TArray(0,N) & " selected>" & TArray(1,N) & "</a>" & VbCrLf
			Else
				Response.Write "		<option class=TBBG9 value=" & TArray(0,N) & ">" & TArray(1,N) & "</a>" & VbCrLf
			End If
		Next
	End If
	
	TArray = Application(DEF_MasterCookies & "BoardInfo" & 0 & "_TI")
	If isArray(TArray) Then
		Num = Ubound(TArray,2)
		Response.Write "		<option class=TBBG1 value=0>===选择总专题===</a>" & VbCrLf
		
		For N = 0 To Num
			If GoodAssort = cCur(TArray(0,N)) Then
				Response.Write "		<option class=TBBG9 value=" & TArray(0,N) & " selected>" & TArray(1,N) & "</a>" & VbCrLf
			Else
				Response.Write "		<option class=TBBG9 value=" & TArray(0,N) & ">" & TArray(1,N) & "</a>" & VbCrLf
			End If
		Next
	End If
	%>
	</Select><%If isArray(TArray) Then%><font color=Gray class=grayfont> 注:保密区帖慎入总专题</font><%End If%>
	<%

End Function

Function RepairAnnounce(ID)

	RepairAnnounce = 1
	Dim Rs,SQL,RootID,ParentID,BoardID,RootIDBak,TopicType
	SQL = sql_select("Select RootID,ParentID,BoardID,RootIDBak,TopicType from LeadBBS_Announce where ID=" & ID,1)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		GBL_CHK_TempStr = "此帖子可能已经删除。"
		RepairAnnounce = 0
		Exit function
	Else
		RootID = cCur(Rs(0))
		ParentID = cCur(Rs(1))
		BoardID = cCur(Rs(2))
		RootIDBak = cCur(Rs(3))
		TopicType = Rs(4)
		Rs.Close
		Set Rs = Nothing
	End If

	If TopicType = 39 Then
		GBL_CHK_TempStr = "镜像帖子无需修复。"
		RepairAnnounce = 0
		Exit Function
	End If
	If ParentID <> 0 Then
		GBL_CHK_TempStr = "只有主题帖子才能进行此功能。"
		RepairAnnounce = 0
		Exit Function
	End If

	Dim GoodAssort_Old
	GoodAssort_Old = GoodAssort
	GoodAssort = Left(Request.Form("GoodAssort"),14)
	If isNumeric(GoodAssort) = 0 Then GoodAssort = 0
	GoodAssort = Fix(cCur(GoodAssort))
	If CheckGoodAssort(GoodAssort) = 0 Then GoodAssort = GoodAssort_Old
	
	Dim Count
	SQL = "select count(*) from LeadBBS_Announce where RootIDBak=" & RootIDBak
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Count = 0
	Else
		Count = Rs(0)
		If IsNull(Count) then Count = 0
		Count = cCur(Count)
		Count = Count - 1
		If Count < 0 Then Count = 0
	End If
	Rs.Close
	Set Rs = Nothing

	select case DEF_UsedDataBase
	case 0,2:
		Dim U_MaxID,U_LastInfo
		if DEF_UsedDataBase = 0 then
			SQL = "select ID,Title from LeadBBS_Announce where ID=(select max(ID) from LeadBBS_Announce where RootIDBak=" & RootIDBak & ")"
		else
			SQL = "select ID,Title from LeadBBS_Announce where ID=(select t.id from (select max(ID) as id from LeadBBS_Announce where RootIDBak=" & RootIDBak & ") as t)"
		end if
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			U_LastInfo = ""
		Else
			U_MaxID = cCur(Rs(0))
			If U_MaxID = RootIDBak Then
				U_LastInfo = ""
			Else
				U_LastInfo = LeftTrue(Rs(1),50)
			End If
			If Lcase(Left(U_LastInfo,3)) = "re:" Then U_LastInfo = Mid(U_LastInfo,4)
		End If
		Rs.Close
		Set Rs = Nothing
		if DEF_UsedDataBase = 0 then
			CALL LDExeCute("Update LeadBBS_Announce set RootMaxID=" & U_MaxID & "" &_
				",RootMinID=(select min(ID) from LeadBBS_Announce where RootIDBak=" & RootIDBak & ")" &_
				",ChildNum=" & Count & ",GoodAssort=" & GoodAssort & ",LastInfo='" & Replace(U_LastInfo,"'","''") & "' where ID=" & ID,1)
		else
		
			CALL LDExeCute("Update LeadBBS_Announce set RootMaxID=" & U_MaxID & "" &_
				",RootMinID=(select t.id from (select min(ID) as id from LeadBBS_Announce where RootIDBak=" & RootIDBak & ") as t)" &_
				",ChildNum=" & Count & ",GoodAssort=" & GoodAssort & ",LastInfo='" & Replace(U_LastInfo,"'","''") & "' where ID=" & ID,1)
		end if
	case Else
		Dim RootMaxID,RootMinID
		SQL = "select max(ID) from LeadBBS_Announce where RootIDBak=" & RootIDBak
		Set Rs = LDExeCute(SQL,0)
		If Not Rs.Eof Then
			RootMaxID = Rs(0)
			If IsNull(RootMaxID) then RootMaxID = 0
		Else
			RootMaxID = 0
		End if
		Rs.Close
		Set Rs = Nothing
		SQL = "select Min(ID) from LeadBBS_Announce where RootIDBak=" & RootIDBak
		Set Rs = LDExeCute(SQL,0)
		If Not Rs.Eof Then
			RootMinID = Rs(0)
			If IsNull(RootMinID) then RootMinID = 0
		Else
			RootMinID = 0
		End if
		Rs.Close
		Set Rs = Nothing
		CALL LDExeCute("Update LeadBBS_Announce set RootMaxID=" & RootMaxID &_
			",RootMinID=" & RootMinID &_
			",ChildNum=" & Count & ",GoodAssort=" & GoodAssort & " where ID=" & ID,1)
		CALL LDExeCute("Update LeadBBS_Topic set RootMaxID=" & RootMaxID &_
			",RootMinID=" & RootMinID &_
			",ChildNum=" & Count & ",GoodAssort=" & GoodAssort & " where ID=" & ID,1)
	End select
	If CheckSupervisorUserName() = 0 Then
		CALL LDExeCute("Update LeadBBS_User Set LastWriteTime=" & GetTimeValue(DEF_Now) & " where ID=" & GBL_UserID,1)
		UpdateSessionValue 13,GetTimeValue(DEF_Now),0
	End If
	ChangeGoodAssort GoodAssort_Old,GoodAssort
	If GoodAssort_Old <> GoodAssort Then RepairAnnounce = 2

End Function%>