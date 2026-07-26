<!-- #include file=../inc/BBSsetup.asp -->
<!-- #include file=../inc/Board_Popfun.asp -->
<!-- #include file=../inc/Limit_Fun.asp -->
<!-- #include file=../inc/Upload_Setup.asp -->
<!-- #include file=../article/inc/cms_setup.asp -->
<%
DEF_BBS_HomeUrl = "../"
Const LMT_RedirectFile = 1 '附件显示方式：0,读取下载，隐藏真实地址但性能稍差 1.转址下载 高性能但暴露真实地址
Const DEF_GuestEnable = 1 '是否允许游客查看附件：0,禁止，1.允许

Main

Sub Main

	Dim DownFile
	Set DownFile = New DownLoad_File
	DownFile.GetFile
	If DownFile.ErrStr <> "" Then Response.Write DownFile.ErrStr
	Set DownFile = Nothing

End Sub

Class DownLoad_File

Private ID,BoardID,VisitIP,PhotoDir,SPhotoDir,FileName,FileSize,FileType,isDown,isSmall,UserID,CheckFlag,GetType
Public ErrStr

Private Sub GetUpladInfo

	Dim Rs
	ID = Left(Request.QueryString("Lid"),40)
	If ID = "" or isNumeric(ID) = 0 Then ID = 0 
	ID = Fix(cCur(ID))
	If ID < 1 Then
		ID = 0
		Exit Sub
	End If
	
	If Request.QueryString("down") = "1" Then
		isDown = 1
	Else
		isDown = 0
	End If
	
	If Request.QueryString("small") = "1" Then
		isSmall = 1
	Else
		isSmall = 0
	End If
	
	'on error resume next
	Dim R
	R = Left(Request.QueryString("r") & "",1)
	'If R <> "1" and isTrueDate(GBL_CookieTime) = 0 Then Response.Redirect DEF_BBS_HomeUrl & "images/logo.gif"
	If isTrueDate(GBL_CookieTime) = 0 Then GBL_CookieTime = DEF_now
	'If R <> "1" and Abs(DateDiff("s",GBL_CookieTime,DEF_Now)) > 1800 Then Response.Redirect DEF_BBS_HomeUrl & "images/logo.gif"
	If Request.QueryString("s") <> DEF_DownKey Then
		Response.Redirect DEF_BBS_HomeUrl & "images/logo.gif"
	End If
	InitDatabase

	If Request.querystring("type") <> "1" then
		GetType = 0
	Else
		GetType = 1
	End If
	If GetType = 0 then
		Set Rs = LDExeCute("Select UserID,PhotoDir,SPhotoDir,FileType,FileName,FileSize,BoardID,VisitIP from LeadBBS_Upload where id=" & ID,0)
	Else
		Set Rs = LDExeCute("Select UserID,PhotoDir,SPhotoDir,FileType,FileName,FileSize,BoardID,VisitIP from article_Upload where id=" & ID,0)
	End If
	If Rs.Eof Then
		ID = 0
	Else
		UserID = cCur(Rs(0))
		PhotoDir = Rs(1)
		SPhotoDir = Rs(2)
		FileType = Rs(3)
		FileName = Rs(4)
		FileSize = Rs(5)
		BoardID = cCur(Rs(6))
		GBL_Board_ID = BoardID
		VisitIP = Rs(7)
	End If
	Rs.Close
	Set Rs = Nothing
	If ((FileType = 1 or FileType = 4 or FileType = 5) and Request.QueryString("r") = "1") Then
		CheckFlag = 0
	Else
		CheckFlag = 1
	End If

	If GBL_Board_ID > 0 and CheckFlag = 1 Then
		GBL_CHK_TempStr = ""
		Borad_GetBoardIDValue(GBL_Board_ID)
		CheckisBoardMaster
		CheckAccessLimit
		CheckAccessLimit_TimeLimit

		If GBL_CHK_TempStr <> "" Then
			ErrStr = "附件下载失败，" & GBL_CHK_TempStr
			CloseDatabase
			'Exit Sub
			Response.Redirect DEF_BBS_HomeUrl & "images/visitlimit.gif"
		End If
	End If
	
	'If PhotoDir <> "" and FileType <> 0 and VisitIP <> GBL_IPAddress Then
	'If PhotoDir <> "" and VisitIP <> GBL_IPAddress Then
	'	If DEF_DownSpend > 0 and DEF_DownSpend > GBL_CHK_Points Then
	'		ErrStr = "下载附件失败,没有足够的" & DEF_PointsName(0) & "!"
	'	Else
	'		If DEF_DownSpend > 0 and GBL_UserID <> UserID Then
	'			CALL LDExeCute("Update LeadBBS_User Set Points=Points-" & DEF_DownSpend & " where id=" & GBL_UserID,1)
	'			UpdateSessionValue 4,0-DEF_DownSpend,1
	'		End If
	if VisitIP <> GBL_IPAddress and FileType > 0 then
			CALL LDExeCute("Update LeadBBS_Upload Set Hits=Hits+1,VisitIP='" & Replace(GBL_IPAddress,"'","''") & "' where id=" & ID,1)
	end if
	'	End If
	'End If
	If DEF_GuestEnable = 0 and GBL_UserID < 1 Then
		CloseDatabase
		Response.Redirect DEF_BBS_HomeUrl & "images/guest.gif"
	End If
	CloseDatabase
	'If CheckFlag = 0 and isTrueDate(GBL_CookieTime) = 0 Then Response.Redirect DEF_BBS_HomeUrl & "images/logo.gif"
	If isTrueDate(GBL_CookieTime) = 0 Then GBL_CookieTime = DEF_now
	'If CheckFlag = 0 and Abs(DateDiff("s",GBL_CookieTime,DEF_Now)) > 1800 Then Response.Redirect DEF_BBS_HomeUrl & "images/logo.gif"

End Sub

Public Sub GetFile

	GetUpladInfo
	If ErrStr <> "" Then Exit Sub
	ErrStr = ""
	If ID = 0 Then
		ErrStr = "获取附件失败."
		Exit Sub
	End If
	
	Dim DefineUploadDir
	If GetType = 0 Then
		DefineUploadDir = DEF_BBS_UploadPhotoUrl
	Else
		DefineUploadDir = DEF_CMS_UploadPhotoUrl
	End If
	
	Dim Ext
	Ext = LCase(Mid(PhotoDir,inStrRev(PhotoDir,".") + 1))
	If Ext = "jpe" or Ext = "jpg" Then Ext = "jpeg"
	If LMT_RedirectFile = 1 or CheckFlag = 0 Then
		If FileName = "" Then FileName = "download." & Mid(PhotoDir,inStrRev(PhotoDir,"."))
		
		If isDown = 1 or FileType <> 0 Then
			If isDown = 1 Then
				Response.AddHeader "Content-Disposition","attachment;filename=" & FileName
			End If
			'Response.AddHeader "Content-Length",intFilelength 
			Response.ContentType = "application/octet-stream"
		Else
			Response.AddHeader "Content-Disposition","filename=" & FileName
			Response.ContentType = "image/" & Ext
		End If
		
		If isSmall = 0 or SPhotoDir = "" Then
			Response.Redirect DEF_BBS_HomeUrl & DefineUploadDir & PhotoDir
		Else
			Response.Redirect DEF_BBS_HomeUrl & DefineUploadDir & SPhotoDir
		End If
		Exit Sub
	End If
	
	Dim strFilename,S,Fso,F,intFilelength
	If isSmall = 0 or SPhotoDir = "" Then
		strFilename = Server.MapPath(Replace(DEF_BBS_HomeUrl & DefineUploadDir & PhotoDir,"/","\"))
	Else
		strFilename = Server.MapPath(Replace(DEF_BBS_HomeUrl & DefineUploadDir & SPhotoDir,"/","\"))
	End If
	
	Response.Clear
	Response.Buffer = False
	Set S = Server.CreateObject("ADODB.Stream") 
	S.Open 
	S.Type = 1 
	'On Error Resume Next 
	Set Fso = Server.CreateObject(DEF_FSOString) 
	If Not Fso.FileExists(strFilename) Then 
		ErrStr = "无此附件，可能已被删除!"
		Set FSO = Nothing
		S.Close
		Set S = Nothing
		Exit Sub
	End If
	
	Set F = Fso.GetFile(strFilename) 
	intFilelength = F.Size '获取文件大小
	
	'过大文件下载限制
	If FileType <> 0 and intFilelength > 2048000 Then
		If CheckWriteEventSpace = 0 Then
			ErrStr = "下载附件失败(操作过频)."
			Set F = Nothing
			S.Close
			Set S = Nothing
			Set FSO = Nothing
			Exit Sub
		End If
		UpdateSessionValue 13,GetTimeValue(DEF_Now),0 '大文件下载,防刷新
	End If
	S.LoadFromFile(strFilename) 
	If Err Then 
		ErrStr = "获取附件产生未知错误，请联系管理员．"
		S.Close
		Set F = Nothing
		Set S = Nothing
		Set FSO = Nothing
		Exit Sub
	End If

	'Response.Write "-----------" & urlencode(FileName)
	'Response.End

	If isDown = 1 or FileType <> 0 Then
		If isDown = 1 Then
			Response.AddHeader "Content-Disposition","attachment;filename=" & FileName
		End If
		'Response.AddHeader "Content-Length",intFilelength 
		Response.CharSet = "GB2312" 
		Response.ContentType = "application/octet-stream"
	Else
		Response.AddHeader "Content-Disposition","filename=" & FileName
		'Response.AddHeader "Content-Length",intFilelength 
		Response.CharSet = "GB2312"
		Response.ContentType = "image/" & Ext
	End If
	If intFilelength < 512 * 1024 Then
		Response.BinaryWrite S.Read
	Else
		Do while intFilelength > 0 and Response.IsClientConnected = true
			Response.BinaryWrite S.Read(512*1024)
			intFilelength = intFilelength - 512*1024
		Loop
		'Response.BinaryWrite S.Read 
	End If
	S.Close
	Set F = Nothing
	Set S = Nothing
	Set FSO = Nothing

End Sub

End Class
%>