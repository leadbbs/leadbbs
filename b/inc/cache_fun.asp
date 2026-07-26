<%

Sub ReloadTopAnnounceInfo(TID)

	Dim Rs,GetDataTop,TIDStr
	If TID = 0 Then
		TIDStr = ""
	Else
		TIDStr = TID
	End If
	Set Rs = LDExeCute("Select RootID,BoardID from LeadBBS_TopAnnounce where TopType=" & TID,0)
	If Rs.Eof Then
		Application.Lock
		application(DEF_MasterCookies & "TopAnc" & TIDStr) = "yes"
		application(DEF_MasterCookies & "TopAncList" & TIDStr) = ""
		Application.UnLock
		Rs.Close
		Set Rs = Nothing
		Exit Sub
	Else
		GetDataTop = Rs.GetRows(-1)
		Rs.close
		Set Rs = Nothing
	End If
	
	Dim Temp,N
	Temp = ""
	If cCur(GetDataTop(0,0)) > 0 Then Temp = GetDataTop(0,0)
	For N = 1 to Ubound(GetDataTop,2)
		If cCur(GetDataTop(0,N)) > 0 Then Temp = Temp & "," & GetDataTop(0,N)
	Next
	If Left(Temp,1) = "," Then Temp = Mid(Temp,2)
	If cStr(Temp) <> "" Then
		select case DEF_UsedDataBase
			case 0,2:
				Set Rs = LDExeCute(sql_select("select T1.id,T1.ChildNum,T1.Title,T1.FaceIcon,T1.LastTime,T1.Hits,T1.Length,T1.UserName,T1.UserID,T1.RootID,T1.LastUser,T1.NotReplay,T1.GoodFlag,T1.BoardID,T1.TopicType,T1.PollNum,T1.TitleStyle,T1.LastInfo,T1.ndatetime,T1.GoodAssort,T1.NeedValue,T2.UserName as username_dup2,T2.ID as id_dup2,T2.TrueName,T3.extent_content,'' from (LeadBBS_Announce as T1 " & get_index("IX_LeadBBS_Announce_RootIDBak2") & " left join LeadBBS_User as T2 on T2.Id=T1.Userid) left join leadbbs_extend as T3 on (T3.ClassType=200 and T1.ID=T3.extendID) where T1.ParentID=0 and T1.RootIDBak in(" & Temp & ") order by T1.ID DESC",Ubound(GetDataTop,2)+1),0)
			case Else
				Set Rs = LDExeCute(sql_select("select T1.id,T1.ChildNum,T1.Title,T1.FaceIcon,T1.LastTime,T1.Hits,T1.Length,T1.UserName,T1.UserID,T1.RootID,T1.LastUser,T1.NotReplay,T1.GoodFlag,T1.BoardID,T1.TopicType,T1.PollNum,T1.TitleStyle,T1.LastInfo,T1.ndatetime,T1.GoodAssort,T1.NeedValue,T2.UserName as username_dup2,T2.ID as id_dup2,T2.TrueName,T3.extent_content,'' from (LeadBBS_Topic as T1 left join LeadBBS_User as T2 on T2.Id=T1.Userid) left join leadbbs_extend as T3 on (T3.ClassType=200 and T1.ID=T3.extendID) where T1.ID in(" & Temp & ") order by T1.ID DESC",Ubound(GetDataTop,2)+1),0)
		End select
		If Not Rs.Eof Then
			GetDataTop = Rs.GetRows(-1)
			Rs.Close
			Set Rs = Nothing
			Application.Lock
			application(DEF_MasterCookies & "TopAnc" & TIDStr) = GetDataTop
			Application.UnLock
			Application.Lock
			application(DEF_MasterCookies & "TopAncList" & TIDStr) = "," & Temp & ","
			Application.UnLock
		Else
			Rs.Close
			Set Rs = Nothing
			Application.Lock
			application(DEF_MasterCookies & "TopAnc" & TIDStr) = "yes"
			Application.UnLock
		End If
	Else
		Application.Lock
		application(DEF_MasterCookies & "TopAnc" & TIDStr) = "yes"
		Application.UnLock
	End If

End Sub
%>