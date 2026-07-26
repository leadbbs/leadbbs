<%
Sub DeleteBlank_page

	If GBL_UserID > 0 and GBL_CHK_Flag = 1 and GBL_CHK_TempStr = "" Then
		If Request("dflag") <> "upload" Then
			DeleteBlankUser
		Else
			DeleteUploadBlock
		End If
	Else
		Response.Write ""
	End If	

End sub

sub DeleteBlankUser()

	If CheckSupervisorUserName = 0 or GBL_UserID = 0 Then Exit sub

	If Request("SureFlag") <> "E72ksiOkw2" Then
		%>
			<p><form action=UpdateUnderWritePrintColumn.asp method=post>
			<b><font color=ff0000 class=redfont>再次确认信息：确定删除无任何发帖在一个月前注册且在线时间低于100的用户<br>
			<br>
			<input type=hidden name=SureFlag value="E72ksiOkw2">
			<input type=hidden name=flag value="<%=htmlencode(GBL_MANAGE_Flag)%>">
			
			<input type=submit value=确定删除 class=fmbtn>
			</form>
		<%
	Else	
		'Response.Write "<span style='font-size:9pt;'>开始删除无实际发帖及" & DEF_PointsName(4) & "小于100的用户(灰色表示略过删除，黑色表示删除用户)："
	
		Dim RecordCount,CountIndex
		SQL = "Select count(*) from LeadBBS_User where OnlineTime<100"
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

		Application.Lock
		Application("Io_" & GBL_CHK_User) = "start"
		Application.UnLock
		If Request("executepage") = "" Then
		%>
		<p style="font-size:9pt" id="bartitle1">下面扫描允许删除的用户，共有<%=RecordCount%>个用户待扫描
	
		<table width="400" cellspacing="0" cellpadding="0" style="border:#006600 1px solid;">
			<tr> 
				<td>
				<td><img src=../pic/progressbar.gif width=0 height=16 id=img1 name=img1 align=middle>
		</td></tr></table> <span id=txt1 name=txt1 style="font-size:9pt">0</span><span style="font-size:9pt">%</span>
		<span id=tm1 name=tm1 style="font-size:9pt">正在估算需要时间...</span>
		<script src="<%=DEF_BBS_HomeUrl%>inc/js/bar.js?ver=<%=DEF_Jer%>" type="text/javascript"></script>
		<script>
			Upl_url = "Io_Info.asp?id=<%=Urlencode(GBL_CHK_User)%>";
			Upl_IOfun = window.setTimeout(Upl_IO,Upl_GetDelay);
		</script>
		<br>
		<iframe src="UpdateUnderWritePrintColumn.asp?executepage=yes&SureFlag=E72ksiOkw2&flag=<%=urlencode(GBL_MANAGE_Flag)%>" name="infoframe" id="infoframe" hidefocus="" frameborder="no" scrolling="auto" style="margin-top:100px;width:300px;height:150px;">
		<%
			Response.Flush
			Exit sub
		end if
		
		Dim StartTime,SpendTime,RemainTime
		StartTime = Now
	
		Dim EndFlag,Temp,DeleteNum
		Dim Rs,SQL
		DeleteNum = 0
		Dim NowID,GetData,N
		NowID = 0
		Do While EndFlag = 0
			SQL = sql_select("Select ID,UserName,AnnounceNum,OnlineTime,ApplyTime,UploadNum from LeadBBS_User where OnlineTime<100 and id>" & NowID & " order by id asc",100)
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
			End If
			For N = 0 to Ubound(GetData,2)
				NowID = GetData(0,N)
				Temp = RestoreTime(GetData(4,N))
				If isTrueDate(Temp) Then
					If DateDiff("d",Temp,DEF_Now) > 30 Then
						Temp = 1
					Else
						Temp = 0
					End If
				Else
					Temp = 0
				End If
				If cCur(GetData(2,N)) = 0 and Temp = 1 Then
					CALL LDExeCute("Delete from LeadBBS_FriendUser where UserID=" & NowID,1)
					CALL LDExeCute("Delete from LeadBBS_FriendUser where FriendUserID=" & NowID,1)
					CALL LDExeCute("Delete from LeadBBS_InfoBox where FromUser='" & Replace(GetData(1,N),"'","''") & "'",1)
					CALL LDExeCute("Delete from LeadBBS_InfoBox where ToUser='" & Replace(GetData(1,N),"'","''") & "'",1)

					CALL LDExeCute("Delete from LeadBBS_AppLogin where UserID=" & NowID,1)
					CALL LDExeCute("Delete from LeadBBS_Extend where classtype=500 and extent_level=" & NowID,1)
					CALL LDExeCute("Delete from LeadBBS_Extend where classtype=500 and extendid=" & NowID,1)
					If cCur(GetData(5,N)) > 0 Then DeleteUploadInfo(NowID)
					CALL LDExeCute("Delete from LeadBBS_User where ID=" & NowID,1)
					DeleteNum = DeleteNum + 1
				End If
				CountIndex = CountIndex + 1
				If (CountIndex mod 100) = 10 Then
					SpendTime = Datediff("s",StartTime,Now)
					RemainTime = SpendTime/CountIndex * (RecordCount-CountIndex)
					Application.Lock
					Application("Io_" & GBL_CHK_User) = Fix((CountIndex/RecordCount) * 400) & "|" & FormatNumber(CountIndex/RecordCount*100,4,-1) & "|" & SpendTime & "|" & RemainTime & "|" & CountIndex
					Application.UnLock
				End If
			Next
			If Response.IsClientConnected Then
			Else
				EndFlag = 1
				Application.Contents.Remove("Io_" & GBL_CHK_User)
			End If
		Loop
		ReloadStatisticData
		%>
		共有<%=DeleteNum%>个用户被删除(包括上传附件)
		<%Application.Contents.Remove("Io_" & GBL_CHK_User)
	End If

End sub

Function DeleteUploadInfo(DelUserID)

	Dim Rs,SQL
	Dim NowID,EndFlag
	NowID = 0
	EndFlag = 0

	Dim TempNum
	If DEF_FSOString = "" Then
		'Response.Write " <font color=Red class=redfont>不支持FSO，略过附件删除．</font>"
	Else
		Do while EndFlag = 0
			SQL = sql_select("Select ID,PhotoDir,SPhotoDir from LeadBBS_Upload where UserID=" & DelUserID & " and ID>" & NowID & " order by ID ASC",100)
			Set Rs = LDExeCute(SQL,0)
			If Rs.Eof Then
				EndFlag = 1
				Rs.Close
				Set Rs = Nothing
			Else
				TempNum = 0
				Do while Not Rs.Eof
					If Rs("PhotoDir") <> "" Then DeleteFiles(Server.Mappath(Replace(Replace(DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & Rs("PhotoDir"),"/","\"),"\\","\")))
					If Rs("SPhotoDir") <> "" Then DeleteFiles(Server.Mappath(Replace(Replace(DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & Rs("SPhotoDir"),"/","\"),"\\","\")))
					TempNum = TempNum + 1
					NowID = Rs(0)
					Rs.MoveNext
				Loop
				'Response.Write "■"
				Rs.Close
				Set Rs = Nothing
				CALL LDExeCute("Delete from LeadBBS_Upload where UserID=" & DelUserID & " and ID<=" & NowID,1)
				CALL LDExeCute("update LeadBBS_SiteInfo set UploadNum=UploadNum-" & TempNum,1)
				CALL LDExeCute("Update LeadBBS_User Set UploadNum=UploadNum-" & TempNum & " where id=" & DelUserID,1)
				Response.Write " <font color=Red class=redfont>删除" & TempNum & "个附件</font>"
			End If
		Loop
		
		SQL = "Select ID,PhotoDir,SPhotoDir from LeadBBS_UserFace where UserID=" & DelUserID & " order by ID ASC"
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			Rs.Close
			Set Rs = Nothing
		Else
			If Rs("PhotoDir") <> "" Then DeleteFiles(Server.Mappath(DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & "face/" & Rs("PhotoDir")))
			If Rs("SPhotoDir") <> "" Then DeleteFiles(Server.Mappath(DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & "face/" & Rs("SPhotoDir")))
			'Response.Write "■"
			Rs.Close
			Set Rs = Nothing
			CALL LDExeCute("Delete from LeadBBS_UserFace where UserID=" & DelUserID,1)
		End If
	End If

End Function

sub DeleteUploadBlock

	Dim FirstDate,LastDate
	FirstDate = Request("FirstDate")
	LastDate = Request("LastDate")
	If Request("SureFlag") = "sure" Then
		If isTrueDate(FirstDate) = 0 Then
			GBL_CHK_TempStr = "<br>起始日期错误,请正确填写,必须为日期格式!<br>"
		ElseIf isTrueDate(LastDate) = 0 Then
			GBL_CHK_TempStr = "<br>终止日期错误,请正确填写,必须为日期格式!<br>"
		End If
	End If
	If Request("SureFlag") <> "E72ksiOkw2" or GBL_CHK_TempStr <> "" Then
	%>
		<p style="font-size:9pt">删除指定时间之间的附件(现在日期<%=now%>)</p>
		<%If GBL_CHK_TempStr <> "" Then Response.Write "<b style=font-size:9pt><font color=red class=redfont>" & GBL_CHK_TempStr & "</font></b>"%>
		<form name=DellClientForm action=UpdateUnderWritePrintColumn.asp method=post style="font-size:9pt">
			<input type=hidden name=dflag value="upload">
			<input type=hidden name=SureFlag value="E72ksiOkw2">
			<input type=hidden name=flag value="<%=htmlencode(GBL_MANAGE_Flag)%>">
			删除日期<input name=firstDate value="<%=htmlencode(firstDate)%>">至日期
			<input name=LastDate value="<%=htmlencode(LastDate)%>">之间的附件
			<p><b>确认要删除指定日期之间的附件吗？</b>
			<p><input type=submit value=确定 class=fmbtn style="font-size:9pt">
			<input type=button value=不删 onclick="javascript:window.close();" class=fmbtn style="font-size:9pt">
		</form>
	<%
	Else
		FirstDate = GetTimeValue(FirstDate)
		LastDate = GetTimeValue(LastDate)

		Dim Rs,SQL
		

		Dim RecordCount,CountIndex
		SQL = "Select count(*) from LeadBBS_Upload where NDatetime >=" & FirstDate & " and NDatetime <= " & LastDate
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
		
		If Request("executepage") = "" Then
		%>
		<p style="font-size:9pt">下面扫描附合条件的附件，共有<%=RecordCount%>个附件待删除,如果服务器不支持FSO将无法删除硬盘上的文件
	
		<table width="400" border="0" cellspacing="1" cellpadding="1">
			<tr> 
				<td bgcolor=000000>
		<table width="400" border="0" cellspacing="0" cellpadding="1">
			<tr> 
				<td bgcolor=ffffff height=9><img src=../pic/progressbar.gif width=0 height=16 id=img1 name=img1 align=middle></td></tr></table>
		</td></tr></table> <span id=txt1 name=txt1 style="font-size:9pt">0</span><span style="font-size:9pt">%</span>
		<span id=tm1 name=tm1 style="font-size:9pt">正在估算需要时间...</span>
		<script src="<%=DEF_BBS_HomeUrl%>inc/js/bar.js?ver=<%=DEF_Jer%>" type="text/javascript"></script>
		<script>
			Upl_url = "Io_Info.asp?id=<%=Urlencode(GBL_CHK_User)%>";
			Upl_IOfun = window.setTimeout(Upl_IO,Upl_GetDelay);
		</script>
		<br>
		<iframe src="UpdateUnderWritePrintColumn.asp?executepage=yes&SureFlag=E72ksiOkw2&flag=<%=urlencode(GBL_MANAGE_Flag)%>&dflag=upload&firstDate=<%=urlencode(firstDate)%>&LastDate=<%=urlencode(LastDate)%>" name="infoframe" id="infoframe" hidefocus="" frameborder="no" scrolling="auto" style="margin-top:100px;width:300px;height:150px;">
		<%
			response.Flush
			Application.Lock
			Application("Io_" & GBL_CHK_User) = "start"
			Application.UnLock
			Exit sub
		End If
	
		Dim NowID,EndFlag
		NowID = 0
		EndFlag = 0

		If DEF_FSOString = "" Then
			Response.Write " <font color=Red class=redfont>不支持FSO，略过附件删除．</font>"
		Else
		
			Dim GetData,N
			Do While EndFlag = 0
				SQL = sql_select("Select ID,PhotoDir,SPhotoDir,UserID from LeadBBS_Upload where NDatetime >=" & FirstDate & " and NDatetime <= " & LastDate & " and id>" & NowID & " order by id asc",100)
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
				End If
				For N = 0 to Ubound(GetData,2)
					NowID = GetData(0,N)
					If GetData(1,N)<> "" Then DeleteFiles(Server.Mappath(Replace(Replace(DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & GetData(1,N),"/","\"),"\\","\")))
					If GetData(2,N) <> "" Then DeleteFiles(Server.Mappath(Replace(Replace(DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & GetData(2,N),"/","\"),"\\","\")))
					CALL LDExeCute("Delete from LeadBBS_Upload where id=" & NowID,1)
					CALL LDExeCute("Update LeadBBS_User Set UploadNum=UploadNum-1 where id=" & NowID,1)
					CALL LDExeCute("update LeadBBS_SiteInfo set UploadNum=UploadNum-1",1)
					CountIndex = CountIndex + 1
					If (CountIndex mod 100) = 10 Then
						SpendTime = Datediff("s",StartTime,Now)
						RemainTime = SpendTime/CountIndex * (RecordCount-CountIndex)
						Application.Lock
						Application("Io_" & GBL_CHK_User) = Fix((CountIndex/RecordCount) * 400) & "|" & FormatNumber(CountIndex/RecordCount*100,4,-1) & "|" & SpendTime & "|" & RemainTime & "|" & CountIndex
						Application.UnLock
					End If
				Next
				If Response.IsClientConnected Then
				Else
					EndFlag = 1
					Application.Contents.Remove("Io_" & GBL_CHK_User)
				End If
			Loop
		End If
		%>
		完成
		<%
		Application.Contents.Remove("Io_" & GBL_CHK_User)
	End If
	ReloadStatisticData

End sub

Function DeleteFiles(path)

	If DEF_FSOString = "" Then Exit Function
    on error resume next
    Dim fs
    Set fs = Server.CreateObject(DEF_FSOString)
	If err <> 0 Then
		Err.Clear
		'Response.Write "<br>服务器不支持FSO，硬盘文件未删除．"
		Exit Function
	End If
    If fs.FileExists(path) Then
      fs.DeleteFile path,True
      DeleteFiles = 1
    Else
      DeleteFiles = 0
    End If
    Set fs = Nothing
         
End Function
%>