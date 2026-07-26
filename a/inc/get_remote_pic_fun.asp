<%
Const Remote_Enable = 401 '0,全部禁止 1.全部允许 2.仅允许版主及以上 3.仅允许总版主以上 4. 仅允许管理员 401-6000.仅允许声望达到(当前值-400)以上的用户
Const Remote_MaxGet = 10
Const Remote_MaxSize = 1048576

function remote_checkEnable

	dim s : s = 1
	if Remote_Enable = 0 then
		s = 0
	elseif Remote_Enable = 1 then
	elseif Remote_Enable = 2 then
		if GBL_BoardMasterFlag < 4 then s = 0
	elseif Remote_Enable = 3 then
		if GBL_BoardMasterFlag < 7 then s = 0
	elseif Remote_Enable = 4 then
		if GBL_BoardMasterFlag < 9 then s = 0
	elseif Remote_Enable >= 401 and Remote_Enable <= 6000 then
		if GBL_CHK_CachetValue < Remote_Enable-400 then s = 0
	else
		s = 0
	end if
	remote_checkEnable = s

end function

class remote_pic_save

public function get_remoteImg(content,AncID,ParentID)

	if remote_checkEnable() = 0 then exit function
	dim patrn,strng
	Dim regEx, Match, Matches
	strng = form_content
	Set regEx = New RegExp
	regEx.IgnoreCase = True
	regEx.Global = True

	patrn = "\[FLASH=([0-9]{1,4}),([0-9]{1,4})\](.+?)\[\/FLASH\]"
	patrn = "\[imga?=?([0-9]{1,2})?,?(absmiddle|left|right|top|middle|bottom|absbottom|baseline|texttop)?,?([0-9\%]{1,5})?,?([0-9\%]{1,5})?\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/imga?\]"
	regEx.Pattern = patrn
	dim a0,a1,a2,a3,a4,a5,a6
	dim s,e,ext,bin,url,u,i,headstr,bins,Index,fileName,fileName_s,SQL,YM,size,returnSave
	dim rs,extent_content
	extent_content = ""
	Index = 0
	if regEx.test(strng) then
		Set Matches = regEx.Execute(strng)
		For Each Match in Matches
			s = Match.Value
			a0 = Match.SubMatches(0)
			a1 = Match.SubMatches(1)
			a2 = Match.SubMatches(2)
			a3 = Match.SubMatches(3)
			a4 = Match.SubMatches(4)
			a5 = Match.SubMatches(5)

			url = a4 & a5

			'不超过最大获取数 并且远程非本地域名，并且仍然有相应远程图片在编码中
			if Index < Remote_MaxGet and (lcase(left(a4,3)) = "htt" or lcase(left(a4,3)) = "ftp") and inStr(a5,DEF_AbsolutHome) < 1 and instr(strng,s)>0 then
				ext = ".jpg"
				e = inStrRev(a5,".jpg")
				if e < 1 then e = inStrRev(a5,".jpeg")
				if e < 1 then e = inStrRev(a5,".jpe")
				if e < 1 then
					ext = ".gif"
					e = inStrRev(a5,".gif")
				end if
				if e < 1 then
					ext = ".png"
					e = inStrRev(a5,".png")
				end if
				if e < 1 then ext = ".jpg"
				
				u = "proxy.asp?u=" & urlencode(url) & "&bin=1"
				bin = RequestUrl(a4 & a5)
				bins = bin_readStream(bin,5)
				headstr = ""
				for i = 1 to lenb(bins)
					headstr = headstr & hex(ascb(midb(bin,i,1)))
				next
				
				if lcase(left(headstr,4)) = "ffd8" then
					ext = ".jpg"
				elseif lcase(left(headstr,8)) = "47494638" then
					ext = ".gif"
				elseif lcase(left(headstr,8)) = "49504e47" or right(lcase(left(headstr,8)),6) = "504e47" then
					ext = ".png"
				else
					ext = ""
				end if
				if ext <> "" then
					Index = Index + 1
					YM = "network/" & left(LngStr(gettimevalue(DEF_Now)),6) & "/"
					fileName = Mid(LngStr(gettimevalue(DEF_Now)),7) & "_" & Index & ext
					fileName_s = Mid(LngStr(gettimevalue(DEF_Now)),7) & "_" & Index & "s" & ".jpg"
					bin_createFolder("../" & DEF_BBS_UploadPhotoUrl & YM)
					returnSave = bin_ADODB_SaveToFile(bin,"../" & DEF_BBS_UploadPhotoUrl & YM & fileName)
					if returnSave(0) = 1 then
						size = returnSave(1)
						if DEF_EnableGFL = 1 then
							call SaveSmallPic(server.mappath("../" & DEF_BBS_UploadPhotoUrl & YM & fileName),server.mappath("../" & DEF_BBS_UploadPhotoUrl & YM & fileName_s),DEF_UploadSwidth,DEF_UploadSheight,-2)
						else
							fileName_s = ""
						end if
						SQL = "insert into leadbbs_upload (UserID,PhotoDir,SPhotoDir,ndatetime,FileType,FileName,FileSize,Info,AnnounceID,BoardID) Values(" &_
							GBL_UserID & ",'" & Replace(YM & fileName,"'","''") & "','" & Replace(YM & fileName_s,"'","''") & "'," &_
						 	GetTimeValue(DEF_Now) & ",0" &_
						 	",'" & Replace(fileName,"'","''") & "'" &_
						 	"," & toNum(size,0) &_
						 	",''," & AncID & "," & GBL_Board_ID & "" &_
						 	")"
						CALL LDExeCute(SQL,1)
						SQL = "Select max(ID) From leadbbs_upload where UserID=" & GBL_UserID
						Set Rs = LDExeCute(SQL,0)
						If Not Rs.Eof Then
							sql = ccur("0" & rs(0))
						else
							sql = 0
						end if
						rs.close
						set rs = nothing
						if sql > 0 then
							strng = replace(strng,s,"[upload=" & sql & ",0]" & fileName & "[/upload]")
							if fileName_s <> "" then
								if extent_content = "" then
									extent_content = YM & fileName_s & ":" & YM & fileName
								else
									extent_content = extent_content & "|" & YM & fileName_s & ":" & YM & fileName
								end if
							end if
						end if
					else
						response.write "<br>" & GBL_CHK_TempStr
					end if
				end if
			end if
		next
	end if
	if strng <> content then
		call ldexecute("update leadbbs_announce set content='" & replace(strng,"'","''") & "' where id=" & AncID,1)
		if ccur(ParentID) = 0 and extent_content <> "" then
			call UpdateUpload(extent_content,AncID)
		end if
	end if

end function

private Sub UpdateUpload(extent_content,id)

	if extent_content = "" then
		if extent_havefile = 0 then
			call insert_LeadBBS_extend(-1,extent_ClassType,id,"",extent_content,0,0,0)
		end if
	else
		call insert_LeadBBS_extend(0,extent_ClassType,id,"",extent_content,0,0,0)
	end if

End Sub

private sub bin_createFolder(path)

	Dim TDir,FS
	'On Error Resume Next
	Dim FSFlag
	FSFlag = 1
	If DEF_FSOString <> "" Then
		Err.Clear
		Set fs = Server.CreateObject(DEF_FSOString)
		If Err Then
			FSFlag = 0
			Err.Clear
			Set fs = Nothing
		End If
	Else
		FSFlag = 0
	End If
	
	TDir = Server.MapPath(path)
	If Not FS.FolderExists(TDir) then
		FS.CreateFolder(TDir)
	End If
	Set FS = Nothing

end sub

private Function RequestUrl(url)

		On Error Resume Next
		dim XmlObj		
		Set XmlObj = Server.CreateObject("Msxml2.ServerXMLHTTP.3.0")
		XmlObj.open "GET",url, false
		XmlObj.send
		RequestUrl = XmlObj.responseBody
		Set XmlObj = nothing

End Function

private Function bin_readStream(body,len) 

	'on error resume next
	dim objstream
	set objstream = Server.CreateObject("adodb.stream")
	with objstream
	.Type = 1
	.Mode = 3
	.Open
	.Write body 
	.Position = 0
	
	bin_readStream = .Read(len)
	.Close
	end with
	set objstream = nothing

End Function

private function bin_ADODB_SaveToFile(ByVal strBody,ByVal File)

	'On Error Resume Next
	Dim objStream

		Set objStream = Server.CreateObject("ADODB.Stream")
		If Err.Number=-2147221005 Then 
			GBL_CHK_TempStr = "您的主机不支持ADODB.Stream，无法完成图片文件保存."
			Err.Clear
			Set objStream = Nothing
			bin_ADODB_SaveToFile = array(0,0)
			Exit function
		End If
		dim size
		With objStream
			.Type = 1
			.Open
			.Position = objStream.Size
			.Write = strBody
		End With
		size = objStream.Size
		if ccur("0" & size) > Remote_MaxSize then
			objStream.Close
			Set objStream = Nothing
			bin_ADODB_SaveToFile = array(0,0)
			exit function
		end if
		objStream.SaveToFile Server.MapPath(File),2
		objStream.Close
		Set objStream = Nothing
	If Err Then
		GBL_CHK_TempStr = "错误信息：<p>" & err.description & "</p>其它可能：确定是否对此文件有写入权限."
		err.Clear
		bin_ADODB_SaveToFile = array(0,0)
		Exit function
	End If
	bin_ADODB_SaveToFile = array(1,size)

End function

end class%>