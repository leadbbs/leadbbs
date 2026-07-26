<!--#include file="cache/CACHE_CMS_Announcement.asp"-->
<!--#include file="cache/CACHE_CMS_HOMECONTENT.asp"-->
<!--#include file="cache/CACHE_CMS_HOMESIDE.asp"-->
<!--#include file="cache/CACHE_CMS_INSIDE.asp"-->
<!--#include file="cache/CACHE_CMS_NAVIGATECLASS.asp"-->
<%
const CMS_AnnouncementClassID = 1

class cms_cache_Class

	private forceRefresh

	Private Sub Class_Initialize
	
		Server.ScriptTimeOut = 600
		forceRefresh = 0
	
	end sub

	public sub Announcement

		Dim t
		'on error resume next
		t = DateDiff("s",CMS_Announcement_UpdateTime,DEF_Now)
		dim tmptime
		If Err Then
			tmptime = GetTimeValue(DEF_NOw)
		Else
			tmptime = GetTimeValue(CMS_Announcement_UpdateTime)
		End If
		If forceRefresh = 1 or ((t < 0 or t > DEF_UpdateInterval or Err) and Application(DEF_MasterCookies & "_CMS_Announcement") & "" <> "yes") Then
			'防止多重写入
			Application.Lock
			Application(DEF_MasterCookies & "_CMS_Announcement") = "yes"
			Application.UnLock
			Announcement_MakeFile(tmptime)
			If Err Then
				Err.clear
			End If
			Application.Contents.Remove(DEF_MasterCookies & "_CMS_Announcement")
			Call CMS_Announcement_View()
		Else
			Call CMS_Announcement_View()
		End If
	
	end sub
	
	private sub Announcement_MakeFile(tmptime)
	
		dim listnum,liststyle,classname
	
		dim sql,rs,getdata
		sql = "select id,classname,liststyle,listNum from article_newsclass where id=" & CMS_AnnouncementClassID
		set rs = ldexecute(sql,0)
		if rs.eof then
			rs.close
			set rs = nothing
			exit sub
		end if
		listnum = rs("listnum")
		classname = rs(1)
		liststyle = rs("liststyle")
		rs.close
		set rs = nothing
		
		dim str
		str = cms_listClass(CMS_AnnouncementClassID,listnum,classname,liststyle,tmptime)
		'response.Write str
		Str = "<" & "%" & VbCrLf &_
		"Dim CMS_Announcement_UpdateTime" & VbCrLf &_
		"CMS_Announcement_UpdateTime = """ & htmlencode(DEF_Now) & """" & VbCrLf &_
		"" & VbCrLf &_
		"Sub CMS_Announcement_View" & VbCrLf &_
		"" & VbCrLf &_
		"%" & ">" & VbCrLf &_
		str &_
		"<" & "%" & VbCrLf &_
		"" & VbCrLf &_
		"End Sub" & VbCrLf &_
		"%" & ">" & VbCrLf
		CALL ADODB_SaveToFile(Str,DEF_BBS_HomeUrl & "article/inc/cache/CACHE_CMS_Announcement.asp")
	
	end sub
	
	
	public sub CMS_HOMECONTENT

		Dim t
		'on error resume next
		t = DateDiff("s",CMS_HOMECONTENT_UpdateTime,DEF_Now)
		
		dim tmptime
		If Err Then
			tmptime = GetTimeValue(DEF_NOw)
		Else
			tmptime = GetTimeValue(CMS_HOMECONTENT_UpdateTime)
		End If
	
		If forceRefresh = 1 or ((t < 0 or t > DEF_UpdateInterval or Err) and Application(DEF_MasterCookies & "_CMS_HOMECONTENT") & "" <> "yes") Then
			'防止多重写入
			Application.Lock
			Application(DEF_MasterCookies & "_CMS_HOMECONTENT") = "yes"
			Application.UnLock
			CMS_HOMECONTENT_MakeFile(tmptime)
			If Err Then
				Err.clear
			End If
			Application.Contents.Remove(DEF_MasterCookies & "_CMS_HOMECONTENT")
			Call CMS_HOMECONTENT_View()
		Else
			Call CMS_HOMECONTENT_View()
		End If
	
	end sub
	
	private sub CMS_HOMECONTENT_MakeFile(tmptime)

		dim str
		dim form_content
		form_content = ADODB_LoadFile(DEF_BBS_HomeUrl & "article/inc/cache/home_channellist_0.asp")
		dim tmp,n,tmp2,existn
		dim form_type,form_title,form_listnum,form_id,form_extendflag,form_style
		tmp = SplitLines(form_content)   ' §36: the data file is LF-only, Split(...,VbCrLf) collapses it
		for n = 0 to ubound(tmp)
			tmp2 = split(tmp(n),"#~#^#")
			if ubound(tmp2) >= 4 then
				form_type = cstr(tmp2(0))
				form_title = tmp2(1)
				form_listnum = tmp2(2)
				form_id = tmp2(3)
				form_extendflag = tmp2(4)
				form_style = tmp2(5)
				select case form_type
					case "0": form_type = 0
					case "1": form_type = 1
					case "2": form_type = 2
					case "3": form_type = 3
					case "4": form_type = 4
					case "5": form_type = 5
					case else
							form_type = 999
				end select
			end if
			if form_type <> 999 then
				dim tmpurl : tmpurl = DEF_BBS_HomeUrl
				tmpurl = "<"  & "%=DEF_BBS_HomeUrl%" & ">"
				select case form_type								
					case 0:
						tmpurl = tmpurl & "b/" & RW_b(0,0,"action=list&type=1") & """ target=""_blank"
					case 1:
						tmpurl = tmpurl & "b/" & RW_b(0,0,"action=list&type=2") & """ target=""_blank"
					case 2:
						tmpurl = tmpurl & "b/" & RW_b(0,0,"E=1&EID=" & form_ID) & """ target=""_blank"
					case 3:
						if cstr(form_extendflag) = "1" then
							tmpurl = tmpurl & "b/" & RW_b(form_id,0,"E=0" & form_ID) & """ target=""_blank"
						else
							tmpurl = tmpurl & "b/" & RW_b(form_id,0,"") & """ target=""_blank"
						end if
					case 4:
						tmpurl = tmpurl & "article/article.asp?classid=" & form_id
					case 5:
						tmpurl = "javascript:;"
				End select
				str = str & "<div class=""cell"" id=""home_cell" & n & """>" & VbCrLf
						If form_title <> "" Then
							str = str & "<div class=""cms_index_channelhead"">" & VbCrLf
							str = str & "<a href=""" & tmpurl & """ class=""title"">" & form_title & "</a>" & VbCrLf
							str = str & "</div>" & VbCrLf
						End If
						str = str & "<div class=""cms_index_channelcontent"">" & VbCrLf
							select case form_type
								case 0,1,2,3:
									str = str & topic_listClass(form_id,form_listnum,"channel",form_style,form_type,form_extendflag,tmptime)
									'response.write Topic_AnnounceList(0,form_listnum,0,"yes","0","0","none")
								case 4:
									str = str & cms_listClass(form_id,form_listnum,"channel",form_style,tmptime)
								case 5:
									str = str & cms_getArticleContent(form_id)
							end select
						str = str & "</div>" & VbCrLf
					str = str & "</div>" & VbCrLf
			end if
		next
		'response.Write str
		' Upstream defect: with no channel configured, the generated cache file falls back to a
		' bare RELATIVE redirect — but that file is #included by every CMS page, not just the
		' home page. From article/center.asp it resolved to article/boards.asp and 404'd, so
		' "更新缓存" in the CMS admin answered 404 instead of a result page. Keep the bounce the
		' fallback is for (an unconfigured CMS home goes to the forum) but scope it to the home
		' page and make it root-relative.
		if str = "" then str = "<" & "%If InStr(LCase(Request.ServerVariables(""SCRIPT_NAME"")),""index.asp"") > 0 Then Response.Redirect """ & DEF_InstallDir & """ & Rw_boards(0)" & "%" & ">" & VbCrLf
		Str = "<" & "%" & VbCrLf &_
		"Dim CMS_HOMECONTENT_UpdateTime" & VbCrLf &_
		"CMS_HOMECONTENT_UpdateTime = """ & htmlencode(DEF_Now) & """" & VbCrLf &_
		"" & VbCrLf &_
		"Sub CMS_HOMECONTENT_View" & VbCrLf &_
		"" & VbCrLf &_
		"%" & ">" & VbCrLf &_
		str &_
		"<" & "%" & VbCrLf &_
		"" & VbCrLf &_
		"End Sub" & VbCrLf &_
		"%" & ">" & VbCrLf
		CALL ADODB_SaveToFile(Str,DEF_BBS_HomeUrl & "article/inc/cache/CACHE_CMS_HOMECONTENT.asp")
	
	end sub
	
	private function cms_getArticleContent(id)
	
		dim rs,sql
		sql = "select content from article_newsarticle where id=" & id
		set rs = ldexecute(sql,0)
		if not rs.eof then
			cms_getArticleContent = "<div class=""cell_article_content"">" & replace(replace(rs("content"),"<" & "%","&lt;%"),">" & "%","&gt;%") & "</div>"
		else
			cms_getArticleContent = ""
		end if
		rs.close
		set rs = nothing
	
	end function
	
	
	public sub CMS_HOMESIDE

		Dim t
		'on error resume next
		t = DateDiff("s",CMS_HOMESIDE_UpdateTime,DEF_Now)
		dim tmptime
		If Err Then
			tmptime = GetTimeValue(DEF_NOw)
		Else
			tmptime = GetTimeValue(CMS_HOMESIDE_UpdateTime)
		End If
		If forceRefresh = 1 or ((t < 0 or t > DEF_UpdateInterval or Err) and Application(DEF_MasterCookies & "_CMS_HOMESIDE") & "" <> "yes") Then
			'防止多重写入
			Application.Lock
			Application(DEF_MasterCookies & "_CMS_HOMESIDE") = "yes"
			Application.UnLock
			CMS_HOMESIDE_MakeFile(tmptime)
			If Err Then
				Err.clear
			End If
			Application.Contents.Remove(DEF_MasterCookies & "_CMS_HOMESIDE")
			Call CMS_HOMESIDE_View()
		Else
			Call CMS_HOMESIDE_View()
		End If
	
	end sub
	
	private sub CMS_HOMESIDE_MakeFile(tmptime)
	
		dim str : str = ""
		dim classdata,classdatanum
	
		dim sql,rs,getdata,haveData
		haveData = 1
		sql = "select id,classname_side,liststyle,listNum from article_newsclass where listflag=1 or listflag=3 or listflag=4 order by orderflag asc"
		set rs = ldexecute(sql,0)
		if rs.eof then
			rs.close
			set rs = nothing
			haveData = 0
		end if
		
		if haveData = 1 then
			classdata = rs.getrows(-1)
			rs.close
			set rs = nothing
			classdatanum = ubound(classdata,2)
			
			dim n
		
			for n = 0 to classdatanum
				if GetBinarybit(classdata(2,n),9) = 1 then
					str = str & "<div id=""content_side_box" & classdata(0,n) & """ class=""content_side_box content_side_box_nonetitle"">"
					str = str & cms_getClassFirstArticleContet(classdata(0,n)) & "</div>"
				else
					str = str & cms_listClass(classdata(0,n),classdata(3,n),classdata(1,n),classdata(2,n),tmptime)
				end if
			next
		else
			str = ""
		end if
		'response.Write str
		Str = "<" & "%" & VbCrLf &_
		"Dim CMS_HOMESIDE_UpdateTime" & VbCrLf &_
		"CMS_HOMESIDE_UpdateTime = """ & htmlencode(DEF_Now) & """" & VbCrLf &_
		"" & VbCrLf &_
		"Sub CMS_HOMESIDE_View" & VbCrLf &_
		"" & VbCrLf &_
		"%" & ">" & VbCrLf &_
		str &_
		"<" & "%" & VbCrLf &_
		"" & VbCrLf &_
		"End Sub" & VbCrLf &_
		"%" & ">" & VbCrLf
		CALL ADODB_SaveToFile(Str,DEF_BBS_HomeUrl & "article/inc/cache/CACHE_CMS_HOMESIDE.asp")
	
	end sub
	
	public sub CMS_INSIDE

		Dim t
		'on error resume next
		t = DateDiff("s",CMS_INSIDE_UpdateTime,DEF_Now)
		dim tmptime
		If Err Then
			tmptime = GetTimeValue(DEF_NOw)
		Else
			tmptime = GetTimeValue(CMS_INSIDE_UpdateTime)
		End If
		If forceRefresh = 1 or ((t < 0 or t > DEF_UpdateInterval or Err) and Application(DEF_MasterCookies & "_CMS_INSIDE") & "" <> "yes") Then
			'防止多重写入
			Application.Lock
			Application(DEF_MasterCookies & "_CMS_INSIDE") = "yes"
			Application.UnLock
			CMS_INSIDE_MakeFile(tmptime)
			If Err Then
				Err.clear
			End If
			Application.Contents.Remove(DEF_MasterCookies & "_CMS_INSIDE")
			Call CMS_INSIDE_View()
		Else
			Call CMS_INSIDE_View()
		End If
	
	end sub
	
	private sub CMS_INSIDE_MakeFile(tmptime)
	
		dim str : str = ""
		dim classdata,classdatanum
		dim havedata : havedata = 1
		
		dim sql,rs,getdata
		sql = "select id,classname_side,liststyle,listNum from article_newsclass where listflag=1 or listflag=3 or listflag=5 order by orderflag asc"
		set rs = ldexecute(sql,0)
		if rs.eof then
			rs.close
			set rs = nothing
			havedata = 0
		end if
		if havedata = 1 then
			classdata = rs.getrows(-1)
			rs.close
			set rs = nothing
			classdatanum = ubound(classdata,2)
			
			dim n
			for n = 0 to classdatanum
				if GetBinarybit(classdata(2,n),9) = 1 then
						str = str & "<div id=""content_side_box" & classdata(0,n) & """ class=""content_side_box content_side_box_nonetitle"">"
						str = str & cms_getClassFirstArticleContet(classdata(0,n)) & "</div>"
				else
					'call cms_listClass(classdata(0,n),5,classdata(1,n),7)
					str = str & cms_listClass(classdata(0,n),classdata(3,n),classdata(1,n),classdata(2,n),tmptime)
				end if
			next
		end if

		'response.Write str
		Str = "<" & "%" & VbCrLf &_
		"Dim CMS_INSIDE_UpdateTime" & VbCrLf &_
		"CMS_INSIDE_UpdateTime = """ & htmlencode(DEF_Now) & """" & VbCrLf &_
		"" & VbCrLf &_
		"Sub CMS_INSIDE_View" & VbCrLf &_
		"" & VbCrLf &_
		"%" & ">" & VbCrLf &_
		str &_
		"<" & "%" & VbCrLf &_
		"" & VbCrLf &_
		"End Sub" & VbCrLf &_
		"%" & ">" & VbCrLf
		
		CALL ADODB_SaveToFile(Str,DEF_BBS_HOMEUrl & "article/inc/cache/CACHE_CMS_INSIDE.asp")
	
	end sub
	
	private function cms_getClassFirstArticleContet(classid)
	
		dim rs,sql
		sql = sql_select("select content from article_newsarticle where classid=" & classid & " order by id asc",1)
		set rs = ldexecute(sql,0)
		if not rs.eof then
			cms_getClassFirstArticleContet = rs(0)
		else
			cms_getClassFirstArticleContet = ""
		end if
		rs.close
		set rs = nothing
	
	end function

	rem 生成顶部分类导航缓存	
	public sub CMS_NAVIGATECLASS

		Dim t
		'on error resume next
		t = DateDiff("s",CMS_NAVIGATECLASS_UpdateTime,DEF_Now)
		If forceRefresh = 1 or ((t < 0 or t > DEF_UpdateInterval or Err) and Application(DEF_MasterCookies & "_CMS_NAVIGATECLASS") & "" <> "yes") Then
			'防止多重写入
			Application.Lock
			Application(DEF_MasterCookies & "_CMS_NAVIGATECLASS") = "yes"
			Application.UnLock
			CMS_NAVIGATECLASS_MakeFile()
			If Err Then
				Err.clear
			End If
			Application.Contents.Remove(DEF_MasterCookies & "_CMS_NAVIGATECLASS")
		Else
			Call CMS_NAVIGATECLASS_View()
		End If
	
	end sub
	
	private sub CMS_NAVIGATECLASS_MakeFile

		Dim str : str = ""
		dim classid
		classid = tonum(request.querystring("classid"),0)
		str = article_view_newsClass("listflag=1 or listflag=2",classid)
		Call CMS_NAVIGATECLASS_View()
		Str = "<" & "%" & VbCrLf &_
		"Dim CMS_NAVIGATECLASS_UpdateTime" & VbCrLf &_
		"CMS_NAVIGATECLASS_UpdateTime = """ & htmlencode(DEF_Now) & """" & VbCrLf &_
		"" & VbCrLf &_
		"Sub CMS_NAVIGATECLASS_View" & VbCrLf &_
		"" & VbCrLf &_
		"%" & ">" & VbCrLf &_
		str &_
		"<" & "%" & VbCrLf &_
		"" & VbCrLf &_
		"End Sub" & VbCrLf &_
		"%" & ">" & VbCrLf
		
		CALL ADODB_SaveToFile(Str,DEF_BBS_HOMEUrl & "article/inc/cache/CACHE_CMS_NAVIGATECLASS.asp")
	
	end sub	

	private function article_view_newsClass(flag,classid)
	
		dim sql,rs,getdata
		dim str : str = ""
		sql = "select id,classname,liststyle from article_newsclass where " & flag & " order by orderflag asc"
		set rs = ldexecute(sql,0)
		if rs.eof then
			rs.close
			set rs = nothing
			exit function
		end if
		getdata = rs.getrows(-1)
		rs.close
		set rs = nothing
		dim n,count
		count = ubound(getdata,2)
		str = str & "<" & "%" & VbCrLf
		str = str & "dim classid" & VbCrLf
		str = str & "classid = tonum(request.querystring(""classid""),0)" & VbCrLf
		str = str & "%" & ">" & VbCrLf
		dim tmp
		dim menuflag : menuflag = 0
		dim menu_data,i,tmp_url,tmp_title,tmp_table
		
		str = str & "<div class=""munu_nav2 fire"">" & VbCrLf
		for n = 0 to count
			menuflag = 0
			if GetBinarybit(getdata(2,n),8) = 1 then
				sql = sql_select("select id,classname,liststyle from article_newsclass where parentid=" & getdata(0,n) & " order by orderflag asc",20)
				set rs = ldexecute(sql,0)
				tmp_table = "class"
				if rs.eof then
					rs.close
					set rs = nothing
					sql = sql_select("select id,title,0 from article_newsarticle where classid=" & getdata(0,n) & " order by id asc",20)
					set rs = ldexecute(sql,0)
					tmp_table = "article"
				end if
				if rs.eof then
					menuflag = 0
				else
					menuflag = 1
					menu_data = rs.getrows(-1)
				end if
				rs.close
				set rs = nothing
			End If
			if lcase(left(getdata(1,n),5)) = "http:" and instr(getdata(1,n),"|") then
				tmp = split(getdata(1,n),"|")
				tmp_url = tmp(0)
				tmp_title = tmp(1)
				'str = str & """ href=""" & tmp_url & """ id=""cmstopitem" & getdata(0,n) & """><span class=""head_item_title"">" & tmp_title & "</span></a>" & VbCrLf
			else
				tmp_url = "<" & "%=DEF_BBS_HomeUrl" & "%" & ">article/article.asp?classid=" & getdata(0,n)
				tmp_title = getdata(1,n)
				'str = str & """ href=""<" & "%=DEF_BBS_HomeUrl" & "%" & ">article/article.asp?classid=" & getdata(0,n) & """ id=""cmstopitem" & getdata(0,n) & """><span class=""head_item_title"">" & getdata(1,n) & "</span></a>" & VbCrLf
			end if
			if getbinarybit(getdata(2,n),11) = 1 then
				tmp_url = "javascript:;"
			end if
			if menuflag = 0 then
				str = str & "<div class=""layer_item3"">"
				str = str & "<a class="""
				str = str & "cms_top_item"
				str = str & """ href=""" & tmp_url & """ id=""cmstopitem" & getdata(0,n) & """><span class=""head_item_title"">" & tmp_title & "</span></a>" & VbCrLf
				str = str & "</div>"
			else
				str = str & "<div class=""menu_nav"">" & VbCrLf
				str = str & "	<div class=""layer_item2"">" & VbCrLf
				str = str & "		<div class=""title""><a id=""cmstopitem" & getdata(0,n) & """ href=""" & tmp_url & """><span class=""layer_item_title"">" & tmp_title & "</span></a></div>" & VbCrLf
				str = str & "		<div class=""layer_iteminfo2"">" & VbCrLf
				str = str & "			<ul class=""menu_list"">" & VbCrLf

				for i = 0 to ubound(menu_data,2)
					if lcase(left(menu_data(1,i),5)) = "http:" and instr(menu_data(1,i),"|") then
						tmp = split(menu_data(1,i),"|")
						tmp_url = tmp(0)
						tmp_title = tmp(1)
					else
						if tmp_table = "article" then
							tmp_url = "<" & "%=DEF_BBS_HomeUrl" & "%" & ">article/article.asp?articleid=" & menu_data(0,i)
						else
							tmp_url = "<" & "%=DEF_BBS_HomeUrl" & "%" & ">article/article.asp?classid=" & menu_data(0,i)
						end if
						tmp_title = menu_data(1,i)
					end if
					str = str & "			<li><a href=""" & tmp_url & """>" & tmp_title & "</a></li>" & VbCrLf
				next
				
				str = str & "			</ul>" & VbCrLf
				str = str & "		</div>" & VbCrLf
				str = str & "	</div>" & VbCrLf
				str = str & "</div>" & VbCrLf
			end if
		next
		str = str & "</div>" & VbCrLf
		str = str & "<" & "script>" & VbCrLf
		str = str & "$(""#cmstopitem<" & "%=classid%" & ">"").attr(""class"",""cms_top_sel"");" & VbCrLf
		str = str & "</" & "script>" & VbCrLf
		article_view_newsClass = str
	
	end function
	
	public sub updatecache
	
		forceRefresh = 1
		Announcement()
		CMS_HOMECONTENT()
		CMS_HOMESIDE()
		CMS_INSIDE()
		CMS_NAVIGATECLASS()
	
	End sub

end class
%>