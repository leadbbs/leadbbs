<%
sub center_newsarticle

		dim centernewsarticleClass
		set centernewsarticleClass = new center_newsarticle_Class
		set centernewsarticleClass = nothing
	
End sub

sub center_newsmanage

		dim centermanagenewsArticleClass
		set centermanagenewsArticleClass = new center_managenewsArticle_Class
		set centermanagenewsArticleClass = nothing
	
End sub

class center_newsArticle_Class

	Private form_modifyid,form_title,form_classid,form_fromauthor,form_author,form_ndatetime
	Private form_htmlflag

	
	Private Sub Class_Initialize
	
		if cms_checkdeleteform("article_newsarticle",1) = 1 then
			exit sub
		end if
		form_ndatetime = DEF_Now
		dim submitflag
		form_modifyid = GetFormData("form_modifyid")
		form_modifyid = FormClass_CheckFormValue(form_modifyid,"","int",0,"",0)
		submitflag = GetFormData("submitflag")
		form_author = GBL_CHK_User
		form_htmlflag = 2

		If form_modifyid > 0 Then
			if private_getarticleclassinfo(form_modifyid) = 0 Then
				response.write "<span class=cms_error>此记录不存在,或者是您无权进行此操作.</span>"
				exit sub
			End if
		End If
		If form_modifyid > 0 Then
			EditFlag = 1
		Else
			EditFlag = 0
		End If
		Form_EditAnnounceID = form_modifyid
		Call GetAncUploaInfo()

		if submitflag = "" then
			If form_modifyid > 0 Then
			Else
			End If
			center_articleclass_Form()
		else
			private_getformdata()
		end if
	
	End Sub
	
	private sub private_getformdata
	
		form_title = GetFormData("form_title")
		form_content = Getformdata("form_content")
		form_classid = getformdata("form_classid")
		form_fromauthor = left(getformdata("form_fromauthor"),50)		
		form_ndatetime = left(getformdata("form_ndatetime"),50)
		form_author = left(getformdata("form_author"),50)		
		form_htmlflag = toNum(GetFormData("form_htmlflag"),2)
		
		form_title = FormClass_CheckFormValue(form_title,"文章标题","string","none","=~~~",255)
		If CheckErrorStr = "" Then form_content = FormClass_CheckFormValue(form_content,"文章内容","string","none","=~~~",DEF_MaxTextLength)
		If CheckErrorStr = "" Then form_classid = FormClass_CheckFormValue(form_classid,"文章分类","int","none","<~~~1|>~~~10000000",12)
		
		if form_ndatetime = "" then
			form_ndatetime = 0
		else
			if isTrueDate(form_ndatetime) = 0 then form_ndatetime = DEF_Now
		end if
		
		If CheckErrorStr <> "" Then
			Response.Write "<span class=cms_error>" & CheckErrorStr & "</span>"
			center_articleclass_Form()
		Else
			If Form_UpFlag = 1 Then
				if form_modifyid > 0 then
					Form_EditAnnounceID = form_modifyid
				Else
					Form_EditAnnounceID = 0
				End If
				Dim Upd_FileInfo,UploadSave
				Set UploadSave = New Upload_Save
				UploadSave.Upload_File
				Upd_FileInfo = UploadSave.Upd_FileInfo
				Upd_ErrInfo = UploadSave.Upd_ErrInfo
			End If
			
			private_Saveformdata()

			If Form_UpFlag = 1 Then
				if EditFlag = 0 then
					Form_EditAnnounceID = private_getMaxArticlID
				End If
				call UploadSave.UpdateUpload(Form_EditAnnounceID,1)
				Set UploadSave = Nothing
			End If
		End If 
	
	End Sub
	
	private function private_getMaxArticlID
	
		dim sql,rs
		sql = "select max(id) from article_newsarticle"
		set rs = ldexecute(sql,0)
		if rs.eof then
			private_getMaxArticlID = 0
		else
			private_getMaxArticlID = ccur(rs(0))
		end if
		rs.close
		set rs = nothing
	
	End function
	
	private sub private_Saveformdata
	
		dim sql
		if form_modifyid > 0 then
			sql = "update article_newsarticle set"&_
				" classid=" & cms_sql(form_classid) & ""&_
				",title='" & cms_sql(form_title) & "'"&_
				",content='" & cms_sql(form_content) & "'"&_
				",modifytime=" & gettimevalue(DEF_Now) & ""&_
				",author='" & cms_sql(form_author) & "'" &_
				",htmlflag=" & form_htmlflag & ""&_
				",fromauthor='" & cms_sql(form_fromauthor) & "'" &_
				",ndatetime='" & cms_sql(getTimeValue(form_ndatetime)) & "'" &_
				" where id=" & form_modifyid
			call ldexecute(sql,1)
			Response.Write "<span class=""cms_ok"">成功编辑信息 - <a href=""center.asp?action=newsarticle&form_modifyid=" & form_modifyid & """>点此重新编辑</a> - <a href=""center.asp?center.asp?action=newsmanage&classid=" & form_classid & """>返回分类</a></span>"
		else
			sql = "insert into article_newsarticle(title,content,classid,ndatetime,modifytime,author,fromauthor,htmlflag)" &_
				" values('" & cms_sql(form_title) & "'" &_
				",'" & cms_sql(form_content) & "'" &_
				"," & cms_sql(form_classid) & "" &_
				"," & gettimevalue(DEF_Now) & "" &_
				"," & cms_sql(getTimeValue(form_ndatetime)) & "" &_
				",'" & cms_sql(form_author) & "'" &_
				",'" & cms_sql(form_fromauthor) & "'" &_
				"," & form_htmlflag & "" &_
				")"
			call ldexecute(sql,1)
			Response.Write "<span class=cms_ok>成功添加新信息.</span>"
		end if	

	End Sub
	
	private function private_getarticleclassinfo(UID)
	
		Dim RS,SQL,userid
		sql = "select title,content,classid,fromauthor,author,ndatetime,htmlflag from article_newsarticle where id=" & UID
		Set rs  = LDexecute(sql,0)
		If Not Rs.Eof Then
			form_title = Rs("title")
			form_classid = rs("classid")
			form_content = rs("content")
			form_fromauthor = rs("fromauthor")
			form_author = rs("author")
			form_ndatetime = restoretime(rs("ndatetime"))
			form_htmlflag = rs("htmlflag")
			private_getarticleclassinfo = 1
		else
			private_getarticleclassinfo = 0
		End If
		Rs.Close
		Set Rs = Nothing
		
	end function
	
	Public Sub center_articleclass_Form
	
		CALL FormClass_Head(Form_ActionStr,1,"center.asp?action=newsarticle")
		CALL FormClass_ItemPring("","hidden","form_modifyid",form_modifyid,"","","","","")
		CALL FormClass_ItemPring("","hidden","submitflag","yes","","","","","")
		CALL FormClass_ItemPring("文章标题：","input","form_title",form_title,4,255,"必填","","")
		CALL FormClass_ItemPring("作者：","input","form_author",form_author,3,50,"","","")
		CALL FormClass_ItemPring("来自：","input","form_fromauthor",form_fromauthor,3,50,"","","")
		CALL FormClass_ItemPring("时间：","input","form_ndatetime",form_ndatetime,3,30,"","","")
		call cms_selectnewsclass()
		%>
				<div class="itemline">
				<div class="iteminfo cms_article">
		<%
				if form_modifyid > 0 then
					EditFlag = 1
					Form_EditAnnounceID = form_modifyid
				Else
					EditFlag = 0
				End If
		call DisplayLeadBBSEditor1(form_htmlflag,Form_Content,1,0)
		%>
			</div>
		</div>
		<%
		'CALL FormClass_ItemPring("文章内容：","textarea","form_content",form_content,"500px;",15,"","","")
		Call FormClass_End()
	
	End Sub
	
	

	private sub cms_selectnewsclass
	
	
			dim sql,rs,getdata
			sql = "select id,classname from article_newsclass order by orderflag asc"
			set rs = ldexecute(sql,0)
			if rs.eof then
				rs.close
				set rs = nothing
				exit sub
			end if
			getdata = rs.getrows(-1)
			rs.close
			set rs = nothing
			dim n,count
			count = ubound(getdata,2)
			
			dim str
			str = "0~~~选择分类"
			for n = 0 to count
				str = str & "|" & getdata(0,n) & "~~~" & replace(htmlencode(getdata(1,n)),"|","｜")
			next		
			CALL FormClass_ItemPring("文章分类","select","form_classid",form_classid,"","","",str,"")
	
	end sub
	
End Class

class center_managenewsArticle_Class

	Private class_page,class_sql,class_idname,class_selcolumn,classid,key
	
	Private Sub Class_Initialize
	
		Dim sql_extend
		sql_extend = ""

		class_page = GetFormData("page")
		class_page = FormClass_CheckFormValue(class_page,"","int","0","<~~~0|>~~~10000000000",12)
		classid = GetFormData("classid")
		classid = FormClass_CheckFormValue(classid,"","int",0,"<~~~0|>~~~10000000000",12)
		
		key = left(GetFormData("key"),30)
		
		if classid <> "0" and classid > 0 then
			sql_extend = " where classid=" & classid
			if key <> "" then
				sql_extend = sql_extend & " and title like '%" & cms_sql(key) & "%'"
			end if
		end if
		
		class_sql = "select {~~~} from article_newsarticle " & sql_extend
		class_idname = "id"
		class_selcolumn = "id,title"
		CALL splitpage_returnData(class_sql,class_idname,class_page,class_selcolumn,0)
		
		
		dim paraextend
		if classid>0 then paraextend = "&classid=" & classid
		if key<>"" then paraextend = "&key=" & urlencode(key)
		
		dim sql,rs,getdata
		sql = "select id,classname from article_newsclass order by orderflag asc"
		set rs = ldexecute(sql,0)
		if rs.eof then
			rs.close
			set rs = nothing
			exit sub
		end if
		getdata = rs.getrows(-1)
		rs.close
		set rs = nothing
		dim n,count
		count = ubound(getdata,2)
		Response.Write "<div class=""article_manage_classlist""><a href=""javascript:;"" class=grayfont>可选择分类: </a>"
		%>
		<a href="center.asp?action=newsmanage"<%if classid=0 then response.write " style='font-weight:bold'"%>>全部</a>
		<%
		for n = 0 to count
			%>
			<a href="center.asp?action=newsmanage&classid=<%=getdata(0,n)%>"<%if classid=ccur(getdata(0,n)) then response.write " style='font-weight:bold'"%>><%=getdata(1,n)%></a>
			<%
		next
		%>
		</div>
		<div class=clear></div>
		<%
		
		private_managelist()
		
		CALL splitpage_viewpagelist("center.asp?action=newsmanage" & paraextend,splitpage_maxpage,splitpage_page,"")
			
	End sub
	
	private sub private_managelist
	
		Call cms_selectFormScript("center.asp?action=newsarticle")
		%>
		<div class="title"><div class="titlebg">管理文章 - <a href="center.asp?action=newsarticle">点此添加文章</a>
		 - <span>
		<a href="javascript:;">输入文章编号直接编辑: </a><input type="text" title="输入编号,按Enter键跳转。" size="2" onkeydown="javascript:if(event.keyCode==13){location='center.asp?action=newsarticle&form_modifyid='+parseInt(this.value);return false;}">
		</span>
		<%if classid>0 then%>
		 - <span>
		<a href="javascript:;">按标题搜索: </a><input type="text" value="<%=htmlencode(key)%>" title="输入搜索内容。" size="5" onkeydown="javascript:if(event.keyCode==13){location='center.asp?action=newsmanage&classid=<%=classid%>&key='+escape(this.value);return false;}">
		</span>
		<%end if%>
		</div></div>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class=table_in>
				<tr class="tbinhead cms_tbinhead">
					<td width=60><div class=cms_value>编号</div></td>
					<td><div class=cms_value>分类名称</div></td>
					<td width=60><div class=cms_value>编辑</div></td>
					
				</tr>
				<%dim n
				for n = 0 to splitpage_num%>
				<tr>
					<td class=tdbox><%=splitpage_getdata(0,n)%></td>
					<td class=tdbox><span class="layerico"><input class="fmchkbox" type="checkbox" name="ids" id="ids<%=n%>" value="<%=splitpage_getdata(0,n)%>" onclick="delbody_view(this);" /></span><a href="center.asp?action=newsarticle&form_modifyid=<%=splitpage_getdata(0,n)%>"><%=splitpage_getdata(1,n)%></a></td>
					<td class=tdbox><a href="center.asp?action=newsarticle&form_modifyid=<%=splitpage_getdata(0,n)%>">编辑</a></td>
				</tr>
				<%next%>
		</table>
		<br />
		<hr class=splitline>
		<%

	end sub

End Class
%>