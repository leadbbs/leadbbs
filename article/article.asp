<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="../inc/User_Setup.ASP"-->
<!--#include file="../inc/Board_Popfun.asp"-->
<!--#include file="inc/popfun.asp"-->
<!--#include file="../inc/Upload_Fun.asp"-->
<%
DEF_BBS_homeUrl = "../"
dim Form_ActionStr,Form_ActionCommand,Form_ActionStr_txt

Sub Main

	initdatabase()
	cms_article_getAction()
	article_SiteHead(Form_ActionStr_txt)
	main_body()
	Closedatabase()

End Sub

Sub main_body
%>
<div class="body_area_out">
<%
cms_DisplayBBSNavigate("<span class=navigate_string_step>" & Form_ActionStr & "</span>")
cms_bodyhead_index("inpage")
cms_bodyBottom%>


</div>
<%
cms_SiteBottom()

End Sub

dim readid,article_title,article_content,article_classid,article_modifytime,article_ndatetime,article_author,article_fromauthor,article_htmlflag,class_liststyle,class_name
dim class_parentid

sub cms_article_getAction

	dim tmp,rs,sql,tmp2,newsclassname
	tmp = requestFormData("classid")
	
	dim parent_id,parent_name,parentstr
	parent_id = filterUrlstr(requestFormData("parentclass"))
	parent_name = filterUrlstr(requestFormData("parentname"))
	if parent_id <> "" and parent_name <> "" then
		parentstr = "<a href=""article.asp?classid=" & parent_id & """>" & parent_name & "</a></span><span class=navigate_string_step>"
	end if
	Form_ActionCommand = ""
		tmp = FormClass_CheckFormValue(tmp,"","int","0","<~~~0|>~~~10000000000",12)
		if tmp > 0 then
			sql = sql_select("select t1.id,t1.title,t2.id as id_dup2,t2.classname,t1.content,t1.modifytime,t1.ndatetime,t1.author,t1.fromauthor,t1.htmlflag,t2.liststyle,t2.parentid from article_newsarticle as t1 left join article_newsclass as t2 on t1.classid=t2.id where t1.classid=" & cms_sql(tmp),2)
			set rs = ldexecute(sql,0)
			if not rs.eof then
				readid = rs(0)
				article_title = rs(1)
				class_name = rs(3)
				article_content = rs(4)
				article_modifytime = rs(5)
				article_ndatetime = rs(6)
				article_author = rs(7)
				article_fromauthor = rs(8)
				article_htmlflag = rs(9)
				class_liststyle = rs(10)
				class_parentid = ccur(rs(11))
				if class_parentid > 0 and parentstr = "" then
					parentstr = get_parentstr(class_parentid)
				end if
				Form_ActionStr = parentstr & "<a href=""article.asp?classid=" & tmp & """>" & rs(3) & "</a>"
				Form_ActionStr_txt = KillHTMLLabel(rs(3))
				rs.movenext
				if not rs.eof then
					article_classid = tmp
					Form_ActionCommand = "listnews"
					Form_ActionStr = parentstr & "<a href=""article.asp?classid=" & tmp & """>" & rs(3) & "</a>"
					Form_ActionStr_txt = KillHTMLLabel(rs(3))
				Else
					Form_ActionCommand = "readarticle"
				End if
			end if
			rs.close
			set rs = nothing
		end if
	if Form_ActionCommand = "" then
		tmp = requestFormData("articleid")
		tmp = FormClass_CheckFormValue(tmp,"","int","0","<~~~0|>~~~10000000000",12)
		if tmp > 0 then
			sql = sql_select("select t1.id,t1.title,t2.id as id_dup2,t2.classname,t1.content,t1.modifytime,t1.ndatetime,t1.author,t1.fromauthor,t1.htmlflag,t2.liststyle,t2.parentid from article_newsarticle as t1 left join article_newsclass as t2 on t1.classid=t2.id where t1.id=" & cms_sql(tmp),1)
			set rs = ldexecute(sql,0)
			if not rs.eof then
				Form_ActionCommand = "readarticle"
				readid = rs(0)
				article_title = rs(1)
				class_name = rs(3)
				article_content = rs(4)
				article_modifytime = rs(5)
				article_ndatetime = rs(6)
				article_author = rs(7)
				article_fromauthor = rs(8)
				article_htmlflag = rs(9)
				class_liststyle = rs(10)
				class_parentid = ccur(rs(11))
				if class_parentid > 0 and parentstr = "" then
					parentstr = get_parentstr(class_parentid)
				end if
				Form_ActionStr = parentstr & "<a href=""article.asp?classid=" & rs(2) & """>" & rs(3) & "</a>"
				Form_ActionStr_txt = KillHTMLLabel(rs(3))
			end if
			rs.close
			set rs = nothing
		end if
	end if

end sub

function get_parentstr(id)

	dim rs,sql
	sql = "select id,classname,liststyle from article_newsclass where id=" & id
	set rs = ldexecute(sql,0)
	if not rs.eof then
		
		if getbinarybit(rs(2),11) = 0 then
			sql = "article.asp?classid=" & rs(0)
		else
			sql = "javascript:;"
		end if
		
		get_parentstr = "<a href=""" & sql & """>" & rs(1) & "</a></span><span class=navigate_string_step>"
	else
		get_parentstr = ""
	end if
	rs.close
	set rs = nothing

end function

sub cms_bodyhead_index(sideinfo)%>

<div class="area">
<div class="cms_body_box">
<div class="cms_body cms_body_inpage">
<div class="main">
	<div class="content_side_right" id="p_side">
		<%
		dim cmscacheClass
		select case sideinfo
			case "homepage":
				set cmscacheClass = new cms_cache_Class
				cmscacheClass.CMS_HOMESIDE
				set cmscacheClass = nothing
			case "inpage":
				set cmscacheClass = new cms_cache_Class
				cmscacheClass.CMS_INSIDE
				set cmscacheClass = nothing
		end select		
		%>
	</div>
	<div class="content_main_right">
		<div class="content_main_2_right">
		<div class="content_main_body">
		<%
		select case Form_ActionCommand
			case "listnews":
				call cms_body_listNews(article_classid)
			case "readarticle":
				cms_body_readarticle(readid)
		
		end select
		
		
		%>
		<!--#include file="inc/inpage_info.asp"-->
		<div style="height:20px;"></div>
		<%

		
End Sub

'列出下级分类
sub cms_body_listNews_ChildClass(parentid)

	dim rs,sql,getdata
	sql = "select id,classname from article_newsclass where parentid=" & parentid & " order by orderflag"
	set rs = ldexecute(sql,0)
	if rs.eof then
		rs.close
		set rs = nothing
		exit sub
	end if
	getdata = rs.getrows(-1)
	rs.close
	set rs = nothing
	
	sql = ubound(getdata,2)
	dim n
	
	dim tmp_url,tmp_title,tmp
	Response.Write "<ul class=""childclass"">"
	for n = 0 to sql
		if lcase(left(getdata(1,n),5)) = "http:" and instr(getdata(1,n),"|") then
			tmp = split(getdata(1,n),"|")
			tmp_url = tmp(0)
			tmp_title = tmp(1)
		else
			tmp_url = "article.asp?classid=" & getdata(0,n) & "&parentclass=" & parentid & "&parentname=" & urlencode(class_name)
			tmp_title = getdata(1,n)
		end if
		response.write "<li><a href=""" & tmp_url & """>" & tmp_title & "</a></li>"
	next
	Response.Write "</ul><div class=""clear""></div>"

end sub

sub cms_body_listNews(classid)

	
	dim class_sql,class_idname,class_selcolumn,class_page,sql_extend
	sql_extend = " where t1.classid=" & classid
	class_page = 0
	class_sql = "select {~~~} from article_newsarticle as t1 left join leadbbs_extend as t2 on t1.id=t2.extendID" & sql_extend
	class_idname = "t1.id"
	class_selcolumn = "t1.ID,t1.title,t1.ndatetime,t2.extent_content"
	
	class_page = requestFormData("page")
	class_page = FormClass_CheckFormValue(class_page,"","int","0","<~~~0|>~~~10000000000",12)
	
	splitpage_listNum = DEF_MaxListNum
	CALL splitpage_returnData(class_sql,class_idname,class_page,class_selcolumn,0)
%>

<div class=cms_listtop>
<div class=cms_main_info_left><div class="title cms_listtitle"><%=KillHTMLLabel(Form_ActionStr)%></div>
<%cms_body_listNews_ChildClass(classid)%>
	<ul class=cms_listnews>
		<%dim n
		
		for n = 0 to splitpage_num
			if getbinarybit(class_liststyle,10) = 0 then
		%>
					<li class="topiclist">
					<span class="topic"><a href="article.asp?articleid=<%=splitpage_getdata(0,n)%>&parentclass=<%=classid%>&parentname=<%=urlencode(class_name)%>"><%=splitpage_getdata(1,n)%></a>
					</span>
					<span class="time"><%if ccur(splitpage_getdata(2,n)) <> 0 then response.write left(restoretime(splitpage_getdata(2,n)),10)%></span>
					</li>
		<%
			else
			%>
			<li class="piclist">
			<a href="article.asp?articleid=<%=splitpage_getdata(0,n)%>&parentclass=<%=classid%>&parentname=<%=urlencode(class_name)%>">
			<span class="pic"><%'=splitpage_getdata(3,n)
%><%
			if instr(splitpage_getdata(3,n),"|") then
				dim tmp,tmp2,bigpic,smallpic,tmpvalue
				tmp = split(splitpage_getdata(3,n),"|")
				tmpvalue = tmp(0)
				if tmpvalue & "" = "" then tmpvalue = tmp(1)
				if instr(tmpvalue,":") then
					tmp2 = split(tmpvalue,":")
					bigpic = tmp2(1)
					smallpic = tmp2(0)
				else
					bigpic = tmpvalue
					smallpic = tmpvalue
				end if
				response.write "<img class=""cutimg"" src=""" & DEF_InstallDir & DEF_CMS_UploadPhotoUrl & smallpic & """ fullfile=""" & DEF_InstallDir & DEF_CMS_UploadPhotoUrl & bigpic & """ />"
			else
				response.write splitpage_getdata(3,n)
			end if%></span>
			<span class="pictitle"><%=splitpage_getdata(1,n)%></span>
			</a>
			</li>
			<%
			end if
		next%>
		</ul>
		<div class=clear></div>
<%

		dim extendurl
		extendurl = ""
		CALL splitpage_viewpagelist("article.asp?classid=" & classid & extendurl,splitpage_maxpage,splitpage_page,"")
		%>
</div>
</div>
<div class=clear></div>
		<%

end sub


Function PrintTrueText(tempString)

	If tempString<>"" Then
		PrintTrueText=Replace(Replace(Replace(Replace(Replace(Replace(htmlEncode(tempString),VbCrLf & " ","<br />" & "&nbsp;"),"[P] ","[P]&nbsp;"),VbCrLf,"<br />" & VbCrLf),"   "," &nbsp; "),"  "," &nbsp;"),chr(9)," &nbsp; &nbsp; &nbsp;")
		If Left(PrintTrueText,1) = chr(32) Then
			PrintTrueText = "&nbsp;" & Mid(PrintTrueText,2)
		End If
	Else
		PrintTrueText=""
	End If

End Function

sub cms_body_readarticle(classid)

dim LMTDEF_ConvetType : LMTDEF_ConvetType = GetBinarybit(DEF_Sideparameter,7)
%>

<div class=cms_listtop>
<div class=cms_main_info_left>
	<div class=cms_listnews>
<%
if lcase(left(article_content,8)) = "getplug:" then
	'server.execute(trim(replace(article_content,"getplug:","")))
	session(DEF_MasterCookies & "_extend_action") = trim(replace(article_content,"getplug:",""))
	server.execute("../wzyoyo/plug.asp")
	'Dim MyProxy
	'Set MyProxy = New Proxy_Class
	'MyProxy.GetBody(trim(replace(article_content,"getplug:","")))
	'Set MyProxy = Nothing
%>
	</div><%
else
%>

<div class="title cms_articletitle"><%=article_title%></div>

<div class="cms_article_note"><%if ccur(article_ndatetime) <> 0 then response.write restoretime(article_ndatetime)%><%
	If article_author <> "" Then
	%>，作者：<%=article_author%>
	<%End If
	If article_fromauthor <> "" Then
	%>，来自：<%=article_fromauthor%><%
	End If%></div>
	<script src="<%=DEF_BBS_HomeUrl%>a/inc/leadcode.js<%=DEF_Jer%>" type="text/javascript"></script>
	<div class=cms_listnews>
					<div>
					<%
	select case article_htmlflag
		case 1:
			Response.Write article_content
		case 0:
			article_content = PrintTrueText(article_content)
			response.write article_content
		case else
			if LMTDEF_ConvetType = 1 then
				dim bbsObj,outstr
				Set bbsObj = CreateObject("leadbbs.bbsCode")
				
				if inStr(lcase(Request.ServerVariables("HTTP_USER_AGENT")),"msie") then
					Response.Write bbsObj.convertcode(article_content,DEF_BBS_HomeUrl,DEF_DownKey & "&type=1","|all|",outstr,"msie")
				else
					Response.Write bbsObj.convertcode(article_content,DEF_BBS_HomeUrl,DEF_DownKey & "&type=1","|all|",outstr,"other")
				end if
				set bbsObj = nothing
			else%>
				<script type="text/javascript">
				var GBL_domain="|all|";
				var DEF_DownKey="<%=UrlEncode(DEF_DownKey)%>&type=1";
				HU="<%=DEF_BBS_HomeUrl%>";
				</script>
			<%
				Response.Write "<div id=""articlecontent"">" & VbCrLf
				Response.Write article_content
				Response.Write "</div>"
				%>
				<script type="text/javascript">
				<!--
				leadcode('articlecontent');
				-->
				</script>
				<%
			End If
	end select
					%>
					</div>
		</div>
<%end if%>
</div>
</div>
<div class=clear></div>
		<%

end sub

Main()
%>
