<%
dim Form_Content,Upd_ErrInfo
const DEF_Default_PicWidth = 997 '659 '925
const DEF_Default_PicHeight = 332 '171 '370

sub center_editfile

		dim centereditfileClass
		set centereditfileClass = new center_editfileClass_Class
		set centereditfileClass = nothing
	
End sub

class center_editfileClass_Class

	Private form_fileid,FileName,form_width,form_height
	
	Private Sub Class_Initialize
	
		form_fileid = GetFormData("form_fileid")
		form_fileid = FormClass_CheckFormValue(form_fileid,"","int",0,"",0)
		form_width = DEF_Default_PicWidth
		form_height = DEF_Default_PicHeight
		select case form_fileid
			case 0:
				FileName = "inc/home_bannerlist.asp"
				EditFlag = 1
				Form_EditAnnounceID = -100
				GetAncUploaInfo
			case 1:
				FileName = "inc/sitebottom_info.asp"
				LMT_EnableUpload = 0
			case 2:
				'if GBL_Board_BoardStyle = 0 Then
					FileName = "inc/default.css"
				'else
				'	FileName = "inc/default" & GBL_Board_BoardStyle & ".css"
				'end if
				LMT_EnableUpload = 0
			case 3:
				FileName = "inc/inpage_info.asp"
				LMT_EnableUpload = 0
			case 99:
				editlogo
				exit sub
		end select

		dim submitflag
		submitflag = GetFormData("submitflag")
		if submitflag = "" then
			private_getClassinfo
			center_Class_Form
		else
			private_getformdata
		end if
	
	End Sub
	
	private sub editlogo
	%>
	修改CMS LOGO
	<div class=frameline id="moreskinimg">
	<table class="table_in">
	<tr><td colspan="2"><hr class=splitline></td></tr>

	<tr>
		<td>
			<img src="../article/images/logo.png">
		</td>
		<td>
			<a href="../<%=DEF_ManageDir%>/SiteManage/siteInfo.asp?action=upload&p_filepath=article/images/&p_filename=logo.png&p_fileinfo=%C4%AC%C8%CF%B7%E7%B8%F1Banner%CD%BC%C6%AC%28%C0%A9%D5%B9%B7%E7%B8%F11002%29%2C%B1%D8%D0%EB%CA%C7png%B8%F1%CA%BD" target="_blank">
			点击修改 logo图片(png图片)</a>
			
			<br>
			<a href="../<%=DEF_ManageDir%>/SiteManage/siteInfo.asp?action=upload&p_filepath=article/images/&p_filename=logo.gif&p_fileinfo=%C4%AC%C8%CF%B7%E7%B8%F1Banner%CD%BC%C6%AC%28%C0%A9%D5%B9%B7%E7%B8%F11002%29%2C%B1%D8%D0%EB%CA%C7gif%B8%F1%CA%BD" target="_blank">
				点击修改 logo 图片 (GIF图片,为兼容IE6)
			</a>
			
			<br>
			<span class="grayfont">注释: 若你使用了新的CSS样式定义图片,此修改可能会失效,请参考新的css</span>
			</span>
		</td>
	</tr>
	</table>
	<%
	
	end sub
	
	
	private sub private_getformdata
	
		form_content = GetFormData("form_content")
		
		CALL FormClass_CheckFormValue(form_content,"内容","string","none","=~~~",DEF_MaxTextLength)
		
		If CheckErrorStr <> "" Then
			Response.Write "<span class=cms_error>" & CheckErrorStr & "</span>"
			center_Class_Form
		Else
			select case form_fileid
			case 0:
				If Form_UpFlag = 1 Then
					Dim Upd_FileInfo,UploadSave
					Set UploadSave = New Upload_Save
					UploadSave.Upload_File
					Upd_FileInfo = UploadSave.Upd_FileInfo
					Upd_ErrInfo = UploadSave.Upd_ErrInfo
					If Upd_ErrInfo <> "" Then
						Response.Write "<div class=cms_error>" & Upd_ErrInfo & "</div>"
					End If
					form_width = toNum(GetFormData("form_width"),DEF_Default_PicWidth)
					form_height = toNum(GetFormData("form_width"),DEF_Default_PicHeight)
					if form_width < 50 or form_width > 2000 then form_width = DEF_Default_PicWidth
					if form_height < 50 or form_height > 2000 then form_height = DEF_Default_PicHeight
				End If
				form_content = Topic_HomePicInfo(form_width,DEF_Default_PicHeight,-10)
				CALL Update_InsertSetupRID(1051,"article/" & FileName,7,form_content," and ClassNum=" & 7)
			case 1:
				CALL Update_InsertSetupRID(1051,"article/" & FileName,9,form_content," and ClassNum=" & 9)
			end select
			private_Saveformdata
		End If 
	
	End Sub
	
	private sub private_Saveformdata
	
		ADODB_SaveToFile form_content,FileName
		Response.Write "<span class=cms_ok>成功编辑信息.</span>"

	End Sub
	
	private function private_getClassinfo
	
		form_content = ADODB_LoadFile(FileName)
		if form_content = "" and form_fileid = 2 then form_content = ADODB_LoadFile("inc/default.css")
		
	end function
	
	Public Sub center_Class_Form
	
	%>
		<ul>
		<li><a href=center.asp?action=editfile&form_fileid=0>编辑首页图片新闻</a></li>
		<li><a href=center.asp?action=editfile&form_fileid=1>自定义网站底部信息</a></li>
		<li><a href=center.asp?action=editfile&form_fileid=2>CSS样式表</a></li>
		<li><a href=center.asp?action=editfile&form_fileid=3>自定义内页内容附加信息</a></li>
		</ul>
	<%
		select case form_fileid
				case 0:
					Form_ActionStr = "首页图片新闻"
					CALL FormClass_Head(Form_ActionStr,1,"center.asp?action=editfile")
				case 1:
					Form_ActionStr = "网站底部信息"
					CALL FormClass_Head(Form_ActionStr,0,"center.asp?action=editfile")
				case 2:
					Form_ActionStr = "CSS样式表"
					CALL FormClass_Head(Form_ActionStr,0,"center.asp?action=editfile")
				case 3:
					Form_ActionStr = "内页内容附加信息"
					CALL FormClass_Head(Form_ActionStr,0,"center.asp?action=editfile")
		end select
		CALL FormClass_ItemPring("","hidden","form_fileid",form_fileid,"","","","","")
		CALL FormClass_ItemPring("","hidden","submitflag","yes","","","","","")
		
		select case form_fileid
			case 0:
		%>
		<div class="itemline">
				<div class="iteminfo homeimagesfornews">
		<%
		CALL FormClass_ItemPring("图片宽度：","input","form_width",form_width,3,4,"必填","","")
		CALL FormClass_ItemPring("图片高度：","input","form_height",form_height,3,4,"必填","","")
		call DisplayLeadBBSEditor1(2,Form_Content,1,0)
		%>
			</div>
		</div>
		<%
			case else
				CALL FormClass_ItemPring("","textarea","form_content",form_content,"500px;",15,"","","")
		end select
		FormClass_End
		%>
		<br /><br />
		<hr class=splitline>
		<b>编辑首页图片新闻说明: </b>
		<ol>
		<li>注释中可以填写说明及图片网址,格式为: 链接地址|注释(以|号分隔)</li>
		</ol>
		
		<%
	
	End Sub
	
	private Function Topic_HomePicInfo(Width,Height,tNum)

		dim DEF_IMG_PlayWidth : DEF_IMG_PlayWidth = Width
		dim DEF_IMG_PlayHeight : DEF_IMG_PlayHeight = Height
	
		Dim RewriteFlag,url
		If GetBinarybit(DEF_Sideparameter,16) = 0 Then
			RewriteFlag = 0
		else
			RewriteFlag = 1
		end if
		
		Dim Num : Num = abs(tNum)
		If isNumeric(Num) = 0 Then Num = 0
		If Num < 1 or Num > 50 Then Num = 6
		
		If isNumeric(Height) = 0 Then Height = Fix(DEF_UploadSwidth * (DEF_IMG_PlayHeight/DEF_IMG_PlayWidth))
		If isNumeric(Width) = 0 Then Width = DEF_UploadSwidth
		If Height < 1 Then Height=DEF_IMG_PlayHeight
		If Width < 1 Then Width=DEF_IMG_PlayWidth
	
		Dim Rs,SQL,GetData
		
		SQL = sql_select("Select U.ID,U.PhotoDir,U.SPhotoDir,U.NdateTime,U.Info,0,0 from Article_Upload as U where U.AnnounceID=-100 Order by U.ID DESC",Num)
	
		Set Rs = Con.ExeCute(SQL)
		If Not Rs.Eof Then
			GetData = Rs.GetRows(-1)
			Rs.Close
			Set Rs = Nothing
		Else
			Rs.Close
			Set Rs = Nothing
			Exit Function
		End If
		SQL = Ubound(GetData,2)
	
		Dim Str
		Dim UrlData,UrlLink,TitleList
		
		str = "<div class=""playimages"">" &_
			"<div class=""playimages_bg""></div>" &_
			"<div class=""playimages_info""></div>" &_
			"<ul>" &_
			"<li class=""on"">●<span class=number style=""display:none;"">1</span></li>"
		For Rs = 1 To SQL
			str = str & "<li>●<span class=number style=""display:none;"">" & Rs+1 & "</span></li>"
		Next
		str = str & "</ul>"
		str = str & "<div class=""playimages_list"">"
		
		Dim udir,tmp,infotxt
		For Rs = 0 To SQL
			If cCur(GetData(5,Rs)) <> 0 Then
			
				url = RW_a(GetData(6,Rs),GetData(5,Rs),1,1,"") 
				UrlLink = DEF_BBS_HomeUrl & url
			Else
				UrlLink = DEF_BBS_HomeUrl & DEF_CMS_UploadPhotoUrl & Replace(GetData(1,Rs),"\","/")
			End If
			
			udir = DEF_BBS_HomeUrl & DEF_CMS_UploadPhotoUrl
			If GetData(2,Rs) <> "" and DEF_EnableGFL = 0 Then
				UrlData = udir & Replace(GetData(2,Rs),"\","/")
			Else
				UrlData = udir & Replace(GetData(1,Rs),"\","/")
			End If
			if DEF_EnableGFL = 1 then
					call SaveSmallPic(Server.Mappath(UrlData),Server.Mappath(DEF_BBS_HomeUrl & "images/temp/NewsPic_Home_" & Rs & ".jpg"),DEF_IMG_PlayWidth,DEF_IMG_PlayHeight,-1)
					UrlData = "images/temp/NewsPic_Home_" & Rs & ".jpg?ver=" & Timer
			end if
			TitleList = htmlencode(GetData(4,Rs) & "")
			tmp = split(TitleList,"|")
			If ubound(tmp) >= 1 then
				UrlLink = tmp(0)
				infotxt = tmp(1)
			else
				UrlLink = TitleList
				infotxt = ""
			end if
			If Left(TitleList,3) = "re:" and len(TitleList) > 4 Then TitleList = Mid(TitleList,4)
	        	str = str & "<a href=""" & UrlLink & """ target=""_blank"""
	        	If Rs = 0 Then
	        		str = str & " style='z-index:2;background: url(" & UrlData & ") center no-repeat" & "'"
	        	else
	        		str = str & " style='z-index:1;background: url(" & UrlData & ") center no-repeat" & "'"
	        	end if
	        	str = str & " title=""" & infotxt & """"
	        	'str = str & "><img src=""" & UrlData & """ title=""" & TitleList & """ alt=""" & TitleList & """ /></a>"
	        	str = str & "></a>"
	        Next
		str = str & "</div></div>"
		str = str & "<" & "script src=""" & "inc/js/img.js" & DEF_Jer & """ type=""text/javascript""></script" & ">" & VbCrLf

		Topic_HomePicInfo = Str
	
	End Function
	
End Class

%>