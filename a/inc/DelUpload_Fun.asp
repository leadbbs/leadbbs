<%
Sub DelUpload_DelList(ID)

	If isNumeric(ID) Then
		DelUpload_DeleteUpload(id)
		Exit Sub
	End If
	
	Dim Rs,ListData,Num,N
	Set Rs = LDExeCute("Select ID,0 from LeadBBS_Announce " & ID,0)
	If Not Rs.Eof Then
		ListData = Rs.GetRows(-1)
		Num = Ubound(ListData,2) + 1
	Else
		Num = 0
	End If
	Rs.Close
	Set Rs = Nothing
	If Num = 0 Then Exit Sub
	For N = 0 To Num - 1
		DelUpload_DeleteUpload(ListData(0,N))
	Next
	
End Sub

Sub DelUpload_DeleteUpload(id)

	Dim Rs,UploadListData,UploadListNum,EditN
	Set Rs = LDExeCute("Select T1.ID,T1.UserID,T1.PhotoDir,T1.SPhotoDir,T1.ndatetime,T1.FileType,T1.FileName,T1.FileSize,T1.Info,T1.AnnounceID,T1.BoardID,T2.UserLimit from LeadBBS_Upload as T1 left join LeadBBS_User as T2 on T1.UserID=T2.ID where AnnounceID=" & id,0)
	If Not Rs.Eof Then
		UploadListData = Rs.GetRows(-1)
		UploadListNum = Ubound(UploadListData,2) + 1
	Else
		UploadListNum = 0
	End If
	Rs.Close
	Set Rs = Nothing
	If UploadListNum = 0 Then Exit Sub
	For EditN = 0 to UploadListNum - 1
		GBL_CHK_UserLimit = cCur("0" & UploadListData(11,EditN))
		CheckIsBoardMaster()
		If UploadListData(2,EditN) <> "" Then DeleteFiles(Server.MapPath(Replace(DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & UploadListData(2,EditN),"/","\")))
		If UploadListData(3,EditN) <> "" Then DeleteFiles(Server.MapPath(Replace(DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & UploadListData(3,EditN),"/","\")))
		CALL LDExeCute("Delete from LeadBBS_Upload where id=" & UploadListData(0,EditN),1)
		CALL DelUpload_ChangeUploadNum(UploadListData(1,EditN),-1,0)
	Next

End Sub

Sub DelUpload_ChangeUploadNum(UserID,Num,Flag)

	Dim Temp,SQL
	If Flag = 1 Then 'add
		Temp = DEF_UploadSpendPoints
	Else
		Temp = DEF_UploadDeletePoints
	End If

	Dim Upd_SpendFlag
	If DEF_Upd_SpendFlag = 0 and GBL_BoardMasterFlag >=4 Then
		Upd_SpendFlag = 0
	Else
		Upd_SpendFlag = 1
	End If
	If cCur(UserID) > 0 Then
		If Upd_SpendFlag = 1 and DEF_UploadSpendPoints <> 0 Then
			If Temp > 0 Then
				SQL = "Update LeadBBS_User Set UploadNum=UploadNum+" & Num & ",Points=Points-" & DEF_UploadSpendPoints*Num & " Where ID=" & UserID
			Else
				SQL = "Update LeadBBS_User Set UploadNum=UploadNum+" & Num & ",Points=Points+" & (0-DEF_UploadSpendPoints*Num) & " Where ID=" & UserID
			End If
			If UserID = GBL_UserID Then UpdateSessionValue 4,DEF_UploadSpendPoints*Num,1
		Else
			SQL = "Update LeadBBS_User Set UploadNum=UploadNum+" & Num & " Where ID=" & UserID
		End If
		CALL LDExeCute(SQL,1)
		SQL = "Update LeadBBS_SiteInfo Set UploadNum=UploadNum+" & Num
		CALL LDExeCute(SQL,1)
		UpdateStatisticDataInfo Num,5,1
	End If

End Sub

Function DeleteFiles(path)

	If DEF_FSOString = "" Then Exit Function
	'on error resume next
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