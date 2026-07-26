<!-- #include file=../inc/Upload_Setup.ASP -->
<%
Dim PhotoDirectory,UploadPhotoUrl
PhotoDirectory = DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl
UploadPhotoUrl = DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl
Dim GBL_FileType
GBL_FileType = 2

Dim GBL_Width,GBL_Height
GBL_Width = 65
GBL_Height = 65

Const EnableLeadBBSInfo = 0

function GetPicInfo(LoadFile,typeflag)

	if checkFiles(LoadFile) = 0 then
		GetPicInfo = 0
		Exit Function
	End If
	Dim MyObj
	Set MyObj = Server.CreateObject("Persits.Jpeg")
	MyObj.Open(LoadFile)
	if err Then
		GetPicInfo = 0
	else
		if typeflag = "height" then
			GetPicInfo = MyObj.Height
		else
			GetPicInfo = MyObj.Width
		end if
	End If
	Set MyObj = Nothing

end function

Function SaveSmallPic(LoadFile,SaveFile,SaveW,SaveH,drawFlag)

	'On Error Resume Next
	Dim ResizeFlag
	Dim MaxWidth
	Dim MaxHeight
	MaxWidth = SaveW
	MaxHeight = SaveH
	Dim Img_Height,Img_Width
	ResizeFlag = 0
	if checkFiles(LoadFile) = 0 then
		GBL_FileType = 2
		SaveSmallPic = 0
		Exit Function
	End If
	
	dim saveflag:saveflag=0
	Dim MyObj
	Set MyObj = Server.CreateObject("Persits.Jpeg")
	'MyObj.EnableLZW = True
	MyObj.Interpolation = 2
	MyObj.Open(LoadFile)
	if err Then
		GBL_FileType = 2
		SaveSmallPic = 0
		Set MyObj = Nothing
		err.clear
		Exit Function
	End If
	
	Img_Height = MyObj.Height
	Img_Width = MyObj.Width

	GBL_Width = Img_Width
	GBL_Height = Img_Height
	
	dim oldWidth,OldHeight
	oldWidth = GBL_Width
	OldHeight = Img_Height

	Dim per
	dim x1,x2,y1,y2
	'and (right(SaveFile,4) <> ".gif" or (right(SaveFile,4) = ".gif" and (inStr(PhotoDirectory,"/face/") or inStr(PhotoDirectory,"\face\"))))
	If (Img_Height > MaxHeight Or Img_Width > MaxWidth) and MaxHeight <> -1 and MaxWidth <> -1 Then
		Dim t1,t2
		If 0 = 1 Then '0-缩小到预定宽或高,1,如果大于预定宽或高则成倍缩小
			If Img_Height > MaxHeight Then
				per = (Img_Height - MaxHeight)/Img_Height
			End If
	
			If Img_Width > MaxWidth Then
				If (Img_Width - MaxWidth)/Img_Width > per Then per = (Img_Width - MaxWidth)/Img_Width
			End If
			
			Img_Height = Img_Height - Img_Height * per
			Img_Width = Img_Width - Img_Width * per
			GBL_Width = Fix(Img_Width)
			GBL_Height = Fix(Img_Height)
		Else '缩小并截取
			t1 = Img_Height / MaxHeight
			t2 = Img_Width / MaxWidth
			'If t1 > Fix(t1) Then T1 = Fix(t1) + 1
			'If t2 > Fix(t2) Then T2 = Fix(t2) + 1
			'If T1 < T2 Then T1  = T2
			If T1 > T2 Then T1  = T2
			Img_Height = Img_Height / T1
			Img_Width = Img_Width / T1
			
			GBL_Width = Fix(Img_Width)
			GBL_Height = Fix(Img_Height)
			'crop
			x1 = 0
			y1=0
			x2=GBL_Width
			y2=GBL_Height
			MyObj.Height = GBL_Height
			MyObj.Width = GBL_Width
			if GBL_Width > MaxWidth or GBL_Height > MaxHeight or oldWidth > MaxWidth or oldHeight > MaxHeight then
				if GBL_Width > MaxWidth then
					t1=(GBL_Width-MaxWidth)/2
					x1 = x1 + fix(t1)
					x2 = x2 - fix(t1)
					if ((GBL_Width-MaxWidth) mod 2)>0 then x2 = x2 - 1
					GBL_Width = MaxWidth
				end if
				
				if GBL_Height > MaxHeight then
					t1=(GBL_Height-MaxHeight)/2
					y1 = y1 + fix(t1)
					y2 = y2 - fix(t1)
					if ((GBL_Height-MaxHeight) mod 2)>0 then y2 = y2 - 1
					GBL_Height = MaxHeight
				end if
				if y1>y2-1 then y2 = y1+1
				if x1>x2 then x2 = x1 + 1
				MyObj.Crop x1,y1,x2,y2
				SaveFile = Replace(Replace(SaveFile,".gif",".jpg"),".png",".jpg")
				MyObj.save(SaveFile)
				saveflag=1
			end if
		End If
		If inStr(PhotoDirectory,"/face/") = 0 and inStr(PhotoDirectory,"\face\") = 0 and DEF_UploadVersionString <> "" Then
			if drawFlag > 0 and right(LoadFile,4) <> ".gif" then call img_printText(LoadFile,LoadFile)
		End If

		'MyObj.Resize Img_Width,Img_Height
		ResizeFlag = 1
	Else
		If (DEF_UploadVersionString = "") and inStr(":.gif:.jpg:jpeg:.jpe:.png:",":" & Right(SaveFile,4) & ":") = False Then
			MyObj.Width = Img_Width
			MyObj.Height = Img_Height
			MyObj.Save(LoadFile)
			if drawFlag = -1 then
				MyObj.Save(SaveFile)
				saveflag=1
			end if
		Else
			SaveSmallPic = 2 '原文件不动
			GBL_FileType = 0
			if drawFlag = -1 then
				if ResizeFlag = 1 then SaveFile = Replace(Replace(SaveFile,".gif",".jpg"),".png",".jpg")
				MyObj.Save(SaveFile)
				saveflag=1
				MyObj.Close
			end if
			If right(SaveFile,4) = ".gif" and drawflag <> -2 Then
				Set MyObj = Nothing
				Exit Function
			End If
			If inStr(PhotoDirectory,"/face/") = 0 and inStr(PhotoDirectory,"\face\") = 0 and DEF_UploadVersionString <> "" Then
				if drawFlag > 0 and right(LoadFile,4) <> ".gif" then call img_printText(LoadFile,LoadFile)
				set MyObj = nothing
				Exit Function
			ElseIf drawFlag <> -2 then
				set MyObj = nothing
				Exit Function
			End If
		End If
	End If

	Dim m,n,TA
	TA = Array("-0---000-000-00--00--00--000-","010-0111011101100110011001110","010-0100010101010101010101000","010-0111011101010111011101110","01000100010101010101010100010","01110111010101100111011101110","-000-000-0-0-00--0000000-000-")
	If 2=2 Then
		'MyObj.SaveFormat = 1
		Rem 小的图片总是最优化存储
		If GBL_Width < 120 and GBL_Height < 120 Then
			MyObj.Quality = 100
		End If
		'MyObj.SaveJPEGProgressive = True
		If inStr(PhotoDirectory,"/face/") and GBL_Width > 32 and EnableLeadBBSInfo = 1 and drawFlag > 0 Then
			For m = 0 to Ubound(TA,1)
				For n = 1 to 29
					Select Case Mid(Ta(m),n,1)
						Case "1":
							MyObj.Canvas.Pen.Color = &H00000000
							MyObj.Canvas.Line GBL_Width-31 + n,GBL_Height - 9 + m,GBL_Width-31 + n+1,GBL_Height - 9 + m+1
						Case "0":
							MyObj.Canvas.Pen.Color = &HFFFFFFFF
							MyObj.Canvas.Line GBL_Width-31 + n,GBL_Height - 9 + m,GBL_Width-31 + n+1,GBL_Height - 9 + m+1
					End Select
				Next
			Next
			SaveFile = Replace(Replace(SaveFile,".gif",".jpg"),".png",".jpg")
			MyObj.Save(SaveFile)
			saveflag=1
		End If
		
		if ResizeFlag = 1 then SaveFile = Replace(Replace(SaveFile,".gif",".jpg"),".png",".jpg")
		If inStr(PhotoDirectory,"/face/") = 0 and inStr(PhotoDirectory,"\face\") = 0 and DEF_UploadVersionString <> "" Then
			if drawFlag > 0 and right(SaveFile,4) <> ".gif" then call img_printText(SaveFile,SaveFile)
		End If
		if drawFlag = -2 and saveflag = 0 then
			SaveFile = Replace(Replace(SaveFile,".gif",".jpg"),".png",".jpg")
			MyObj.Save(SaveFile)
		end if
		SaveSmallPic = 1 '正常转换,文件名不改变
	End If
	MyObj.Close
	Set MyObj = Nothing
	GBL_FileType = 0

End Function

Sub img_printText(LoadFile,SaveFile)

			Dim MyObjClone,x1,x2
			Set MyObjClone = Server.CreateObject("Persits.Jpeg")
			'MyObjClone.EnableLZW = True
			MyObjClone.Interpolation = 2
			MyObjClone.Open(LoadFile)
			MyObjClone.Canvas.Font.Family = "宋体"
			MyObjClone.Canvas.Font.Size = 12
			MyObjClone.Canvas.Font.Color = &HFFFFFFFF
			MyObjClone.Canvas.Font.Align = 1
			x1 = MyObjClone.Width - 12*StrLength(DEF_UploadVersionString)/2 - 6
			x2 = MyObjClone.Height - 12-6
			
			MyObjClone.Canvas.PrintText x1-1,x2-1,DEF_UploadVersionString
			MyObjClone.Canvas.PrintText x1+1,x2+1,DEF_UploadVersionString			
			MyObjClone.Canvas.PrintText x1+1,x2-1,DEF_UploadVersionString			
			MyObjClone.Canvas.PrintText x1-1,x2+1,DEF_UploadVersionString
			MyObjClone.Canvas.Font.Color = &H00000000
			MyObjClone.Canvas.PrintText x1,x2,DEF_UploadVersionString
			MyObjClone.Quality = 100
			MyObjClone.Save(SaveFile)
			Set MyObjClone = Nothing

End Sub

Sub CheckUploadDatabase(BigFile,SmallFile)

	If BigFile = "" and SmallFile = "" Then Exit Sub
	Dim NBigFile,NSmallFile,Temp,i
	NBigFile = BigFile
	NSmallFile = SmallFile

	If GBL_UserID < 1 Then
		If BigFile <> "" Then deletefiles BigFile
		If SmallFile <> "" Then deletefiles SmallFile
		Exit Sub
	End If

	Dim SQL,Rs,UserID
	UserID = Left(Request.QueryString("UserID"),14)
	If isNumeric(UserID) = 0 Then UserID = 0
	UserID = cCur(UserID)
	If GBL_UserID>0 and CheckSupervisorUserName = 1 and UserID > 0 Then
		SQL = sql_select("Select ID,PhotoDir,NdateTime from LeadBBS_UserFace Where UserID=" & UserID,1)
	Else
		UserID = GBL_UserID
		SQL = sql_select("Select ID,PhotoDir,NdateTime from LeadBBS_UserFace Where UserID=" & UserID,1)
	End If

	If Lcase(Right(NBigFile,4)) = ".swf" then GBL_FileType = 1

	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		SQL = "insert into LeadBBS_UserFace(UserID,PhotoDir,SPhotoDir,ndatetime,FileType) Values(" & UserID & ",'" & Replace(NBigFile,"'","''") & "','" & Replace(NSmallFile,"'","''") & "'," & GetTimeValue(DEF_Now) & "," & GBL_FileType & ")"
		CALL LDExeCute(SQL,1)
	Else
		SQL = Rs(0)
		If Replace(Lcase(Right(PhotoDirectory,6)),"\","/") <> "/face/" Then PhotoDirectory = PhotoDirectory & "face/"
		Dim TmpPhotoDir
		TmpPhotoDir = Replace(Rs("PhotoDir"),"\","/")
		If inStr(TmpPhotoDir,"/face/") > 0 Then TmpPhotoDir = Mid(TmpPhotoDir,inStr(TmpPhotoDir,"/face/")+6)
		If DEF_FSOString <> "" Then deletefiles Server.Mappath(Replace(PhotoDirectory & Replace(TmpPhotoDir,"\","/"),"//","/"))
		NBigFile = LCase(Replace(NBigFile,"/","\"))
		If inStr(NBigFile,Replace(LCase(DEF_BBS_UploadPhotoUrl),"/","\") & "face\") Then
			NBigFile = Replace(NBigFile,"/","\")
			NBigFile = Mid(NBigFile,inStrRev(NBigFile,Replace(LCase(DEF_BBS_UploadPhotoUrl),"/","\") & "face\")+Len(Replace(LCase(DEF_BBS_UploadPhotoUrl),"/","\") & "face\"))
		End If
		Rs.Close
		Set Rs = Nothing
		CALL LDExeCute("Update LeadBBS_UserFace Set PhotoDir='" & Replace(NBigFile,"'","''") & "',NdateTime=" & GetTimeValue(DEF_Now) & " Where ID=" & SQL,1)
	End If

End Sub

Function checkFiles(path)

	If DEF_FSOString = "" Then Exit Function
	on error resume next
	Dim fs
	Set fs = Server.CreateObject(DEF_FSOString)
	If err <> 0 Then
		Err.Clear
		Response.Write "<p>服务器不支持FSO，硬盘文件未删除．</p>"
		Exit Function
	End If
	If fs.FileExists(path) Then
		checkFiles = 1
	Else
		checkFiles = 0
	End If
	Set fs = Nothing

End Function

Function DeleteFiles(path)

	If DEF_FSOString = "" Then Exit Function
	on error resume next
	Dim fs
	Set fs = Server.CreateObject(DEF_FSOString)
	If err <> 0 Then
		Err.Clear
		Response.Write "<p>服务器不支持FSO，硬盘文件未删除．</p>"
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


Function MoveFiles(path,path2)

	If DEF_FSOString = "" Then Exit Function
	'on error resume next
	Dim fs
	Set fs = Server.CreateObject(DEF_FSOString)
	If err <> 0 Then
		Err.Clear
		Response.Write "<p>服务器不支持FSO，硬盘文件未删除．</p>"
		Exit Function
	End If
	If fs.FileExists(path) Then
		fs.MoveFile path,path2
		MoveFiles = 1
	Else
		MoveFiles = 0
	End If
	Set fs = Nothing

End Function%>