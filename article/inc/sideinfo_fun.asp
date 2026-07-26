<%
function cms_listClass(classid,listnum,title,style,prevUpdateTime)

	dim str : str = ""
	dim Zoom_IMG_WIDTH : Zoom_IMG_WIDTH = 152-50
	dim Zoom_IMG_HEIGHT : Zoom_IMG_HEIGHT = 152-50
	If GetBinarybit(style,6) = 1 then
		Zoom_IMG_WIDTH = (Zoom_IMG_WIDTH+50) * 2
		Zoom_IMG_HEIGHT = (Zoom_IMG_HEIGHT+50) * 2
	end if
	if title <> "channel" then
		Zoom_IMG_WIDTH = 128-50
		Zoom_IMG_HEIGHT = 128-50
		If GetBinarybit(style,6) = 1 then
			Zoom_IMG_WIDTH = (Zoom_IMG_WIDTH+50) * 2
			Zoom_IMG_HEIGHT = (Zoom_IMG_HEIGHT+50) * 2
		end if
	end if
	dim class_page,class_sql,class_idname,class_selcolumn
		Dim sql_extend
		sql_extend = ""

		class_page = requestFormData("page")
		class_page = FormClass_CheckFormValue(class_page,"","int","0","<~~~0|>~~~10000000000",12)

		sql_extend = " where classid=" & classid
		
		class_sql = "select {~~~} from article_newsarticle " & sql_extend
		class_idname = "id"
		class_selcolumn = "id,title,content"
		splitpage_listNum = listnum
		If GetBinarybit(style,7) = 1 Then
			splitpage_orderstr = " id asc"
		Else
			splitpage_orderstr = ""
		End If
		CALL splitpage_returnData(class_sql,class_idname,class_page,class_selcolumn,-1)
		splitpage_orderstr = ""
		if splitpage_num >= 0 Then
			dim m
		Dim tempContent
		
	dim tmpurl : tmpurl = DEF_BBS_HomeUrl
	tmpurl = "<"  & "%=DEF_BBS_HomeUrl%" & ">"
	if title <> "channel" then
		str = str & "<div id=""content_side_box" & classid & """ class=""content_side_box"
		if title = "" then str = str & " content_side_box_nonetitle"
		str = str & """>"
		If title <> "" and title <> "none" then
			str = str & "<div class=""title""><b><a href=""" & tmpurl & "article/article.asp?classid=" & classid & """>" & title & "</a></b></div>"
		end if
	end if
	str = str & "<ul"
	if GetBinarybit(style,1) = 1 or GetBinarybit(style,2) = 1 or GetBinarybit(style,3) = 1 then str = str & " class=""articles"""
	str = str & ">"
			dim specialFlag
			dim rs,sql,UrlData,wordlen
			if title <> "channel" then
				wordlen = 50
			else
				wordlen = 80
			end if
			dim picfile,pictime
			for m = 0 to splitpage_num
				tempContent = ""
				if (m = 0 or GetBinarybit(style,5) = 0) then
					specialFlag = 1
				else
					specialFlag = 0
				end if
				If GetBinarybit(style,2) = 1 and specialFlag = 1 Then
					tempContent = clearUbbcode(KillHTMLLabel(splitpage_getdata(2,m)))
					If len(tempContent) > wordlen+6 then
						tempContent = leftTrue(tempContent,wordlen) & "..."
					elseif StrLength(tempContent) > wordlen+6 then
						tempContent = leftTrue(tempContent,wordlen) & "..."
					end if
				End If
				if title <> "channel" and 1=0 then
					str = str & "<li class="""
					if instr(splitpage_getdata(1,m),"<") > 0 then
						str = str & "listhtml"
					else
						str = str & "slist"
					end if
					If (GetBinarybit(style,1) = 1 or GetBinarybit(style,2) = 1) and specialFlag = 1 Then
						str = str & " bigtitle"
					else
						str = str & " normal"
					end if
					str = str & """>"
					if instr(splitpage_getdata(1,m)," href=") = 0 then
						str = str & "<a href=""" & tmpurl & "article/article.asp?articleid=" & splitpage_getdata(0,m) & """><span class=""word-break-all""><i style=""display:none"">.</i>"
					end if
					str = str & splitpage_getdata(1,m)
					if instr(splitpage_getdata(1,m)," href=") = 0 then
						str = str & "</span></a>"
					end if
					if tempContent <> "" Then
						str = str & "<span class=""content"">" & htmlencode(tempContent) & "</span>"
					end if
					str = str & "</li>"
				else
					str = str & "<li"
					If (GetBinarybit(style,1) = 1 or GetBinarybit(style,2) = 1) and specialFlag = 1 Then
						str = str & " class=""bigtitle"""
					else
						str = str & " class=""normal"""
					end if
					str = str & ">"
					UrlData = ""
					If GetBinarybit(style,3) = 1 and specialFlag = 1 and DEF_EnableGFL = 1 then
						sql = sql_select("select id,PhotoDir,SPhotoDir,Info,ndatetime from article_upload where announceid=" & splitpage_getdata(0,m) & " and filetype=0",1)
						set rs = ldexecute(sql,0)
						if not rs.eof then
								UrlData = DEF_BBS_HomeUrl & DEF_CMS_UploadPhotoUrl & Replace(rs(1),"\","/")
								pictime = ccur(rs(4))
						end if
						rs.close
						set rs = nothing

						If UrlData <> "" Then
							picfile = Server.Mappath(DEF_BBS_HomeUrl & "images/temp/NewsPic_CMS_" & classid & "_" & splitpage_getdata(0,m) & ".jpg")
							if checkFiles(picfile) = 0 or pictime > prevUpdateTime then
								call SaveSmallPic(Server.Mappath(UrlData),picfile,Zoom_IMG_WIDTH,Zoom_IMG_HEIGHT,-1)
							end if
							UrlData = DEF_BBS_HomeUrl & "images/temp/NewsPic_CMS_" & classid & "_" & splitpage_getdata(0,m) & ".jpg?ver=" & Timer
							str = str & "<a href=""" & tmpurl & "article/article.asp?articleid=" & splitpage_getdata(0,m) & """>"
							If GetBinarybit(style,6) = 1 then
								str = str & "<img src=""" & DEF_InstallDir & "images/blank.gif"" style=""background:url('" & UrlData & "');"" class=""bigpic"">"
							else
								str = str & "<img src=""" & DEF_InstallDir & "images/blank.gif"" style=""background:url('" & UrlData & "');"" class=""smallpic"">"
							end if
							str = str & "</a>"
						end if
					end if
					
						If GetBinarybit(style,4) = 1 and UrlData <> "" Then
						else
							if instr(splitpage_getdata(1,m)," href=") = 0 then
								str = str & "<a href=""" & tmpurl & "article/article.asp?articleid=" & splitpage_getdata(0,m) & """><span class=""word-break-all"">"
							end if
							str = str & "<span class="""
							If GetBinarybit(style,1) = 1 then
								str = str & "strongtitle"
							else
								str = str & "normaltitle"
							end if
							str = str & """>"
							str = str & splitpage_getdata(1,m) & "</span>"
							if instr(splitpage_getdata(1,m)," href=") = 0 then
								str = str & "</span></a>"
							end if
						end if
					if tempContent <> "" Then
						str = str & "<span class=""content"">" & htmlencode(tempContent) & "</span>"
					end if
					str = str & "</li>"
				end if
			next
			str = str & "</ul>"
			if title <> "channel" then
				str = str & "</div>"
			end if
		end if
	cms_listClass = str

end function


function topic_listClass(classid,listnum,title,style,listtype,form_extendflag,prevUpdateTime)

	Dim str
	str = ""
	dim Zoom_IMG_WIDTH : Zoom_IMG_WIDTH = 152-50
	dim Zoom_IMG_HEIGHT : Zoom_IMG_HEIGHT = 152-50
	If GetBinarybit(style,6) = 1 then
		Zoom_IMG_WIDTH = (Zoom_IMG_WIDTH+50) * 2
		Zoom_IMG_HEIGHT = (Zoom_IMG_HEIGHT+50) * 2
	end if
	dim class_page,class_sql,class_idname,class_selcolumn
		Dim sql_extend
		sql_extend = ""

		class_page = requestFormData("page")
		class_page = FormClass_CheckFormValue(class_page,"","int","0","<~~~0|>~~~10000000000",12)

		select case listtype
			case 0:
				sql_extend = " where parentid=0"		
			case 1:
				sql_extend = " where goodflag=1"
			case 2:
				sql_extend = " where goodassort=" & classid		
			case 3:
				if cstr(form_extendflag) = "1" then
					sql_extend = " where goodflag=1 and boardid=" & classid
				else
					sql_extend = " where parentid=0 and boardid=" & classid
				end if
		end select
		class_sql = "select {~~~} from leadbbs_announce " & sql_extend
		class_idname = "id"
		class_selcolumn = "id,title,content,boardid,titlestyle,htmlflag"
		splitpage_listNum = listnum
		
		If GetBinarybit(style,7) = 1 Then
			splitpage_orderstr = " id asc"
		Else
			splitpage_orderstr = ""
		End If
		CALL splitpage_returnData(class_sql,class_idname,class_page,class_selcolumn,-1)
		splitpage_orderstr = ""
		if splitpage_num >= 0 Then
			dim m
		Dim tempContent,tempTitle

	dim tmpurl
	if title <> "channel" then
		select case form_type								
			case 0:
				tmpurl = DEF_InstallDir & "b/" & RW_b(0,0,"action=list&type=1") & """ target=""_blank"
			case 1:
				tmpurl = DEF_InstallDir & "b/" & RW_b(0,0,"action=list&type=2") & """ target=""_blank"
			case 2:
				If splitpage_num >= 0 Then
					tmpurl = DEF_InstallDir & "b/" & RW_b(splitpage_getdata(3,n),0,"E=1&EID=" & form_id)
				Else
					tmpurl = "#none"
				End If
			case 3:
				if cstr(form_extendflag) = "1" then
					tmpurl = DEF_InstallDir & "b/" & RW_b(classid,0,"E=0") & """ target=""_blank"
				else
					tmpurl = DEF_InstallDir & "b/" & RW_b(classid,0,"") & """ target=""_blank"
				end if
			case 4:
				tmpurl = DEF_InstallDir & "article/article.asp?classid=" & form_id
		End select
		str = str & "<div id=""content_side_box" & classid & """ class=""content_side_box"
		if title = "" then str = str & " content_side_box_nonetitle"
		str = str & """>"
		If title <> "" and title <> "none" then
			str = str & "<div class=""title""><b><a href=""" & tmpurl & """>" & title & "</a></b></div>"
		end if
	end if
	str = str & "<ul"
	if GetBinarybit(style,1) = 1 or GetBinarybit(style,2) = 1 or GetBinarybit(style,3) = 1 then str = str & " class=""articles"""
	str = str & ">"
			dim specialFlag
			dim rs,sql,UrlData,picfile,pictime
			for m = 0 to splitpage_num
				tempContent = ""
				if (m = 0 or GetBinarybit(style,5) = 0) then
					specialFlag = 1
				else
					specialFlag = 0
				end if
				If GetBinarybit(style,2) = 1 and specialFlag = 1 Then
					tempContent = splitpage_getdata(2,m)
					select case ccur(splitpage_getdata(5,m))
						case 1:
							tempContent = KillHTMLLabel(tempContent)
						case 2:
							tempContent = clearUbbcode(tempContent)
					end select
					tempContent = htmlencode(tempContent)
					If len(tempContent) > 86 then
						tempContent = leftTrue(tempContent,80) & "..."
					elseif StrLength(tempContent) > 86 then
						tempContent = leftTrue(tempContent,80) & "..."
					end if
				End If

				if title <> "channel" then
					str = str & "<li class="""
					if instr(splitpage_getdata(1,m),"<") > 0 then
						str = str & "listhtml"
					else
						str = str & "slist"
					end if
					If (GetBinarybit(style,1) = 1 or GetBinarybit(style,2) = 1) and specialFlag = 1 Then
						str = str & " bigtitle"
					else
						str = str & " normal"
					end if
					str = str & """>"
					if instr(splitpage_getdata(1,m)," href=") = 0 then
						str = str & "<a href=""" & tmpurl & "a/" & RW_a(splitpage_getdata(3,m),splitpage_getdata(0,m),1,1,"") & """ target=""blank""><span class=""word-break-all""><i style=""display:none"">.</i>"
					end if
					tempTitle = htmlencode(KillHTMLLabel(DisplayAnnounceTitle(splitpage_getdata(1,m),splitpage_getdata(4,m))))
					str = str & tempTitle
					if instr(splitpage_getdata(1,m)," href=") = 0 then
						str = str & "</span></a>"
					end if
					if tempContent <> "" Then
						str = str & "<span class=""content"">" & htmlencode(tempContent) & "</span>"
					end if
					str = str & "</li>"
				else
					str = str & "<li"
					If (GetBinarybit(style,1) = 1 or GetBinarybit(style,2) = 1) and specialFlag = 1 Then
						str = str & " class=""bigtitle"""
					else
						str = str & " class=""normal"""
					end if
					str = str & ">"
					
					If GetBinarybit(style,3) = 1 and specialFlag = 1 and DEF_EnableGFL = 1 then
						sql = sql_select("select id,PhotoDir,SPhotoDir,Info,ndatetime from leadbbs_upload where announceid=" & splitpage_getdata(0,m) & " and filetype=0",1)
						set rs = ldexecute(sql,0)
						UrlData = ""
						if not rs.eof then
								UrlData = DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & Replace(rs(1),"\","/")
								pictime = ccur(rs(4))
						end if
						rs.close
						set rs = nothing

						If UrlData <> "" Then
							picfile = Server.Mappath(DEF_BBS_HomeUrl & "images/temp/NewsPic_TOPIC_" & splitpage_getdata(0,m) & ".jpg")
							if checkFiles(picfile) = 0 or pictime > prevUpdateTime then
								call SaveSmallPic(Server.Mappath(UrlData),picfile,Zoom_IMG_WIDTH,Zoom_IMG_HEIGHT,-1)
							end if
							UrlData = DEF_InstallDir & "images/temp/NewsPic_TOPIC_" & splitpage_getdata(0,m) & ".jpg?ver=" & Timer
							str = str & "<a href=""" & DEF_InstallDir & "a/" & RW_a(splitpage_getdata(3,m),splitpage_getdata(0,m),1,1,"") & """ target=""blank"">"
							If GetBinarybit(style,6) = 1 then
								str = str & "<img src=""" & DEF_InstallDir & "images/blank.gif"" style=""background:url('" & UrlData & "');"" class=""bigpic"">"
							else
								str = str & "<img src=""" & DEF_InstallDir & "images/blank.gif"" style=""background:url('" & UrlData & "');"" class=""smallpic"">"
							end if
							str = str & "</a>"
						end if
					end if
					
					if instr(splitpage_getdata(1,m)," href=") = 0 then
						str = str & "<a href=""" & DEF_InstallDir & "a/" & RW_a(splitpage_getdata(3,m),splitpage_getdata(0,m),1,1,"") & """ target=""blank""><span class=""word-break-all"">"						
					end if
					str = str & "<span class="""
						If GetBinarybit(style,1) = 1 then
							str = str & "strongtitle"
						else
							str = str & "normaltitle"
						end if
						str = str & """>"
						tempTitle = htmlencode(KillHTMLLabel(DisplayAnnounceTitle(splitpage_getdata(1,m),splitpage_getdata(4,m))))
						str = str & tempTitle & "</span>"
						if instr(splitpage_getdata(1,m)," href=") = 0 then
							str = str & "</span></a>"
						end if
					if tempContent <> "" Then
						str = str & "<span class=""content"">" & htmlencode(tempContent) & "</span>"
					end if
					str = str & "</li>"
				end if
			next
			str = str & "</ul>"
			if title <> "channel" then
				str = str & "</div>"
			end if
		end if
		topic_listClass = str

end function

class center_GetnewsClass_Class

	Private class_page,class_sql,class_idname,class_selcolumn
	
	Private Sub Class_Initialize
	
		Dim sql_extend
		sql_extend = " where listflag=1 or listflag=3 order by orderflag asc"

		class_page = requestFormData("page")
		class_page = FormClass_CheckFormValue(class_page,"","int","0","<~~~0|>~~~10000000000",12)
		
		class_sql = "select {~~~} from article_newsclass " & sql_extend
		class_idname = "id"
		class_selcolumn = "id,classname"
		CALL splitpage_returnData(class_sql,class_idname,class_page,class_selcolumn,-1)
			
	End sub

End Class


class Side_newsArticle_Class

	Private class_page,class_sql,class_idname,class_selcolumn
	
	Private Sub Class_Initialize
	
		Dim sql_extend
		sql_extend = ""

		class_page = requestFormData("page")
		class_page = FormClass_CheckFormValue(class_page,"","int","0","<~~~0|>~~~10000000000",12)
		
		class_sql = "select {~~~} from article_newsarticle " & sql_extend
		class_idname = "id"
		class_selcolumn = "id,title"
		CALL splitpage_returnData(class_sql,class_idname,class_page,class_selcolumn,0)
		
		private_managelist()
		
		CALL splitpage_viewpagelist("center.asp?action=newsarticle",splitpage_maxpage,splitpage_page,"")
			
	End sub
	
	private sub private_managelist
	
		Call cms_selectFormScript("center.asp?action=newsarticle")
		%>
		<div class="title"><div class="titlebg">管理文章 <a href=center.asp?action=newsarticle>点此添加文章</a></div></div>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class=table_in>
				<tr class="tbinhead cms_tbinhead">
					<td width=60><div class=cms_value>编号</div></td>
					<td><div class=cms_value>分类名称</div></td>
				</tr>
				<%dim n
				for n = 0 to splitpage_num%>
				<tr>
					<td class=tdbox><%=splitpage_getdata(0,n)%></td>
					<td class=tdbox><span class="layerico"><input class="fmchkbox" type="checkbox" name="ids" id="ids<%=n%>" value="<%=splitpage_getdata(0,n)%>" onclick="delbody_view(this);" /></span><a href=center.asp?action=newsarticle&form_modifyid=<%=splitpage_getdata(0,n)%>><%=splitpage_getdata(1,n)%></a></td>
				</tr>
				<%next%>
		</table>
		<br />
		<hr class=splitline>
		<%
	
	end sub

End Class

%>