<script RUNAT=SERVER LANGUAGE=VBSCRIPT>
Dim GBL_FormStream,GBL_FileNum,GBL_filelist
GBL_FileNum = 0
GBL_filelist = ""

Class upload_Class

	Dim objForm,objFile,Version
	Dim mProgressID
	Public Property Get ProgressID()
		ProgressID=mProgressID
	End Property

	Public Property Let ProgressID(byVal itemValue)
		mProgressID=itemValue
	End Property
	Public Function Form(strForm)
		strForm=lcase(strForm)
		If not objForm.exists(strForm) then
			Form=""
		Else
			Form=objForm(strForm)
		End If
	End Function
	
	Public Function File(strFile)
		strFile=lcase(strFile)
		if not objFile.exists(strFile) then
			set File=new FileInfo
		Else
			set File=objFile(strFile)
		End If
	End Function
	
	
	Public Sub GetUpFile
		Dim RequestData,sStart,vbCrlf,sInfo,iInfoStart,iInfoEnd,tStream,iStart,theFile
		Dim iFileSize,sFilePath,sFileType,sFormValue,sFileName
		Dim iFindStart,iFindEnd
		Dim iFormStart,iFormEnd,sFormName
		Dim readBlock,readBlockSize,upBytes
		Dim startTime
		Version="化境HTTP上传程序 Version 2.0"
		set objForm=Server.CreateObject("Scripting.Dictionary")
		set objFile=Server.CreateObject("Scripting.Dictionary")
		if Request.TotalBytes<1 then Exit Sub
		set tStream = Server.CreateObject("adodb.stream")
		set GBL_FormStream = Server.CreateObject("adodb.stream")
		GBL_FormStream.Type = 1
		GBL_FormStream.Mode =3
		GBL_FormStream.Open
		if Request.TotalBytes>300000000 then
			GBL_CHK_TempStr = "提交的数据过大．"
			Exit Sub
		End If
		'---create applicaton--------------------
		ClearApp()
		On Error resume next
		Application.Lock
		Application("LdUpload_" & GBL_CHK_User) = "0 1 1" & " " & Timer
		Application.UnLock
		'---start to upload---------------------
		upBytes=0
		readBlockSize=1024*100
		startTime=Timer()
		readBlock=Request.BinaryRead(readBlockSize)
		'---loop to get data--------------------
		While Lenb(readBlock)>0 and (not Err) and response.IsClientConnected=true
			upBytes=upBytes+Lenb(readBlock)
			'--save value---------
			Application.Lock
			Application("LdUpload_" & GBL_CHK_User) = Cstr(upBytes) & " " & Cstr(Request.TotalBytes) & " " & Cstr(Timer()-startTime) & " " & Timer
			Application.UnLock
			'--write to Stream-----
			GBL_FormStream.Write readBlock
			readBlock=Request.BinaryRead(readBlockSize)
			If err Then
				Application.Contents.Remove("LdUpload_" & GBL_CHK_User)
				GBL_FormStream.Close
				set GBL_FormStream = nothing
				set tStream = nothing
				set objForm = nothing
				set objFile = nothing
				Exit Sub
			End If
		Wend
		Application.Contents.Remove("LdUpload_" & GBL_CHK_User)
		On Error Goto 0
	'------------------------modify end by mytju.com------------------------------
		GBL_FormStream.Position=0
		RequestData =GBL_FormStream.Read(-1) 
	
		iFormStart = 1
		iFormEnd = LenB(RequestData)
		vbCrlf = chrB(13) & chrB(10)
		
		Dim TmpN,headStr
		headStr = chrb(45)
		For TmpN = 1 to 5 'for Chrome
		'For TmpN = 1 to 6 'safari only 6 
		'For TmpN = 1 to 9 'opera only 9
		'For TmpN = 1 to 28 firefox & ie has 28
			headStr = headStr & chrb(45)
		Next
		
		TmpN = InStrB(iFormStart,RequestData,headStr)
		TmpN = InStrB(iFormStart+TmpN,RequestData,vbCrlf)-5
		If InStrB(iFormStart,RequestData,headStr) < TmpN Then TmpN = InStrB(iFormStart,RequestData,headStr)
		If TmpN > 1 Then
			sStart = MidB(RequestData,TmpN, InStrB(TmpN,RequestData,vbCrlf)-1-TmpN)
			iStart = TmpN + LenB (sStart)
		Else
			sStart = MidB(RequestData,1, InStrB(iFormStart,RequestData,vbCrlf)-1)
			iStart = LenB (sStart)
		End If
		
		'Response.AddHeader "Content-Disposition","filename=a.zip"
		'Response.ContentType = "application/gzip"
		
		'Response.Write "<p>sStart---------:"
		'Response.binarywrite sStart
		'Response.Write "<p>iStart---------:" & iStart
		
		'Response.binaryWrite LeftB(RequestData,10000)
		'Response.Write "<p>iFormStart---------:" & iFormStart
		iFormStart=iFormStart+iStart+1
		'Response.Write "<p>iStart---------:" & iStart
		while (iFormStart + 10) < iFormEnd 
			'Response.Write "<p>iFormStart---------:" & iFormStart
			'Response.binaryWrite leftb(RequestData,iFormStart)
			iInfoEnd = InStrB(iFormStart,RequestData,vbCrlf & vbCrlf)+3
			'Response.Write "<p>iFormStart:" & iFormStart
			'Response.Write "<p>iInfoEnd:" & iInfoEnd
			tStream.Type = 1
			tStream.Mode =3
			tStream.Open
			GBL_FormStream.Position = iFormStart
			GBL_FormStream.CopyTo tStream,iInfoEnd-iFormStart
			tStream.Position = 0
			tStream.Type = 2
			tStream.Charset ="utf-8"
			sInfo = tStream.ReadText
			tStream.Close
			'取得表单项目名称
			'Response.Write "<p>sInfo:" & sInfo
			iFormStart = InStrB(iInfoEnd,RequestData,sStart)
			iFindStart = InStr(1,sInfo,"name=""",1)+6
			iFindEnd = InStr(iFindStart,sInfo,"""",1)
			sFormName = lcase(Mid (sinfo,iFindStart,iFindEnd-iFindStart))
			
			'如果是文件
			if InStr (1,sInfo,"filename=""",1) > 0 then
				set theFile=new FileInfo
				'取得文件名
				iFindStart = InStr(iFindEnd,sInfo,"filename=""",1)+10
				iFindEnd = InStr(iFindStart,sInfo,"""",1)
				sFileName = Mid (sinfo,iFindStart,iFindEnd-iFindStart)
				theFile.FileName=getFileName(sFileName)
				theFile.FilePath=getFilePath(sFileName)
				'取得文件类型
				iFindStart = InStr(iFindEnd,sInfo,"Content-Type: ",1)+14
				iFindEnd = InStr(iFindStart,sInfo,vbCr)
				theFile.FileType =Mid (sinfo,iFindStart,iFindEnd-iFindStart)
				theFile.FileStart =iInfoEnd
				theFile.FileSize = iFormStart -iInfoEnd -3
				sFormName = replace(sFormName,",","")
				theFile.FormName=sFormName
				
				if not objFile.Exists(sFormName) then
					objFile.add sFormName,theFile
					if theFile.FileSize > 0 and theFile.FileName <> "" then GBL_filelist = GBL_filelist & "," & sFormName
				'下面为对重复名称的处理
				Else
					GBL_FileNum = GBL_FileNum + 1
					objFile.add sFormName & "_" & GBL_FileNum,theFile
					if theFile.FileSize > 0 and theFile.FileName <> "" then GBL_filelist = GBL_filelist & "," & sFormName & "_" & GBL_FileNum
				End If
			Else
			'如果是表单项目
				tStream.Type =1
				tStream.Mode =3
				tStream.Open
				GBL_FormStream.Position = iInfoEnd 
				GBL_FormStream.CopyTo tStream,iFormStart-iInfoEnd-3
				tStream.Position = 0
				tStream.Type = 2
				tStream.Charset ="utf-8"
				sFormValue = tStream.ReadText 
				tStream.Close
				if objForm.Exists(sFormName) then
					objForm(sFormName)=objForm(sFormName)&", "&sFormValue
				Else
					objForm.Add sFormName,sFormValue
				End If
			End If
			iFormStart=iFormStart+iStart+1
		wend
		'Response.End
		RequestData=""
		set tStream =nothing
	End Sub
	
	Private Sub Class_Terminate 
		If Request.TotalBytes>0 then
			objForm.RemoveAll
			objFile.RemoveAll
			set objForm=nothing
			set objFile=nothing
			GBL_FormStream.Close
			set GBL_FormStream =nothing
		End If
	End Sub
	 
	Private Function GetFilePath(FullPath)
		If FullPath <> "" Then
			GetFilePath = left(FullPath,InStrRev(FullPath, "\"))
		Else
			GetFilePath = ""
		End If
	End  Function
	 
	Private Function GetFileName(FullPath)
		If FullPath <> "" Then
			GetFileName = mid(FullPath,InStrRev(FullPath, "\")+1)
		Else
			GetFileName = ""
		End If
	End  Function
	
	Private Sub ClearApp
	
		'Clear Expires Application
		Dim Thing,Tmp,Tmp2
		For Each Thing in Application.Contents
			If Left(Thing,9) = "LdUpload_" Then
				Tmp = Application(Thing)
				Tmp2 = Mid(Tmp,InstrRev(Tmp, " ", -1, 1) + 1)
				If isNumeric(Tmp2) Then
					Tmp2 = cCur(Tmp2)
					If Timer < Tmp2 Then
						Tmp = Tmp2
					Else
						Tmp = Timer - Tmp2
					End If
					If Tmp > 5*60000 Then Application.Contents.Remove(Thing)
				End If
			End If
		Next
		
	End Sub

End Class
	
Class FileInfo

	Dim FormName,FileName,FilePath,FileSize,FileType,FileStart
	Private Sub Class_Initialize 
		FileName = ""
		FilePath = ""
		FileSize = 0
		FileStart= 0
		FormName = ""
		FileType = ""
	End Sub
	  
	Public Function SaveAs(FullPath)
		Dim dr,ErrorChar,i
		SaveAs=true
		'对文件名空但有内容的文件仍然作上传
		if trim(fullpath)="" or FileStart=0 or (FileName="" and FileSize < 1) or right(fullpath,1)="/" then Exit Function
		set dr=CreateObject("Adodb.Stream")
		dr.Mode=3
		dr.Type=1
		dr.Open
		GBL_FormStream.position=FileStart
		GBL_FormStream.copyto dr,FileSize
		dr.SaveToFile FullPath,2
		dr.Close
		set dr=nothing 
		SaveAs=false
	End Function

End Class
</script>