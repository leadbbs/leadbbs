<!-- #include file=cms_article_fun.asp -->
<%
sub center_newsclass

		dim centernewsClassClass
		set centernewsClassClass = new center_newsClass_Class
		set centernewsClassClass = nothing
	
End sub


class center_newsClass_Class

	Private form_modifyid,form_classname,form_listflag,form_orderflag,form_liststyle,form_listNum,StyleItem
	Private form_ParentID,form_classname_side
	Private GBL_LowClassString,GBL_LoopN

	Private Sub Class_Initialize
	
		StyleItem = Array("1|标题加大","2|展示内容提要","3|展示相关图片","4|有图片时隐藏标题","5|仅首条记录标题加大及展示图片","6|相关图片显示为大图片","7|记录顺序读取(旧的记录优先)","8|顶部导航以下拉菜单形式展示下级分类或文章(在导航栏显示时才有效)","9|侧栏展示为此分类下第一篇文章内容(必须为html,仅在开启侧栏调用时有效)","10|文章列表以图文形式展示","11|此分类禁止展示(不会将此分类作为有效的链接)")
		If getformdata("action2") = "delete" then
			dim tmpidlist
			tmpidlist = getformdata("idlist")
			if instr("," & tmpidlist & ",",",1,") then
				response.Write "<div class=ajaxbox><div class=cms_error>编号为1的分类禁止删除．.</div></div>"
				exit sub
			else
				if cms_checkdeleteform("article_newsclass",1) = 1 then
					exit sub
				end if
			end if
		end if
		dim submitflag
		dim list
		list = left(GetFormData("list"),1)
		If list <> "1" then
			form_modifyid = GetFormData("form_modifyid")
			form_modifyid = FormClass_CheckFormValue(form_modifyid,"","int",0,"",0)
			submitflag = GetFormData("submitflag")
			If form_modifyid > 0 Then
				if private_getnewsClassinfo(form_modifyid) = 0 Then
					response.write "<span class=cms_error>您无权进行此操作.</span>"
					exit sub
				End if
			End If
			if submitflag = "" then
				If form_modifyid > 0 Then
				Else
				End If
				center_newsClass_Form
			else
				private_getformdata
			end if
		else
			dim centermanagenewsClassClass
			set centermanagenewsClassClass = new center_managenewsClass_Class
			set centermanagenewsClassClass = nothing
		end if
	
	End Sub
	
	private function checkParentID
	
		dim checkid : checkid = form_ParentID
		dim old_checkid : old_checkid = 0
			
		dim rs,sql,loopn
		for loopn = 0 to 200
			sql = "select id,parentid from article_newsclass where id=" & checkid
			set rs = ldexecute(sql,0)
			if rs.eof then
				rs.close
				set rs = nothing
				exit function
			end if
			old_checkid = checkid
			checkid = ccur(rs("parentid"))
			rs.close
			set rs = nothing
			if checkid = form_modifyid and form_modifyid <> 0 then
				CheckErrorStr = "上级分类错误，因为此分类已经是选择分类的上级．"
				exit function
			end if
		next
			
			
	
	end function
	
	
	private sub private_getformdata
	
		form_classname = GetFormData("form_classname")
		form_listflag = GetFormData("form_listflag")
		form_orderflag = GetFormData("form_orderflag")
		form_listNum = GetFormData("form_listNum")
		form_ParentID = toNum(GetFormData("form_ParentID"),0)
		form_classname_side = lefttrue(getformdata("form_classname_side"),255)
		
		form_classname = FormClass_CheckFormValue(form_classname,"分类名称","string","none","=~~~",255)
		
		If CheckErrorStr = "" Then form_listflag = FormClass_CheckFormValue(form_listflag,"是否在相关页列出此分类：","int","none","0|1|2|3|4|5",2)
		If CheckErrorStr = "" Then form_orderflag = FormClass_CheckFormValue(form_orderflag,"排列顺序","int",0,"<~~~1|>~~~10000000",12)
		If CheckErrorStr = "" Then form_listNum = FormClass_CheckFormValue(form_listNum,"侧栏展示记录数目","int",1,"<~~~1|>~~~20",12)
		
		if CheckErrorStr = "" then
			checkParentID
		end if
		
		
		dim N,Temp2,TempN
		form_liststyle = 0
		Temp2 = 1
		For TempN = 0 to Ubound(StyleItem,1)
			N = Request("form_liststyle" & TempN+1)
			If N <> "1" Then N = "0"
			If N = "1" Then form_liststyle = form_liststyle+cCur(Temp2)
			Temp2 = Temp2*2
		Next
		
		If CheckErrorStr <> "" Then
			Response.Write "<span class=cms_error>" & CheckErrorStr & "</span>"
			center_newsClass_Form
		Else
			private_Saveformdata
		End If 
	
	End Sub
	
	private sub private_Saveformdata
	
		dim sql
		if form_modifyid > 0 then
			sql = "update article_newsclass set"&_
				" classname='" & cms_sql(form_classname) & "'"&_
				",listflag=" & cms_sql(form_listflag) & ""&_
				",orderflag=" & cms_sql(form_orderflag) & ""&_
				",liststyle=" & form_liststyle & "" &_
				",listNum=" & form_listNum & "" &_
				",ParentID=" & form_ParentID & "" &_
				",classname_side='" & cms_sql(form_classname_side) & "'"&_
				" where id=" & form_modifyid
			call ldexecute(sql,1)
			Response.Write "<span class=cms_ok>成功编辑信息.</span>"
		else
			sql = "insert into article_newsclass(classname,listflag,orderflag,liststyle,listNum,ParentID,classname_side)" &_
				" values('" & cms_sql(form_classname) & "'," & form_listflag & "" &_
				"," & form_orderflag & "" &_
				"," & form_liststyle & "" &_
				"," & form_listNum & "" &_
				"," & form_ParentID & "" &_
				",'" & cms_sql(form_classname_side) & "'" &_
				")"
			call ldexecute(sql,1)
			Response.Write "<span class=cms_ok>成功添加新信息.</span>"
		end if
		UpdateCacheData("data_artileclass.asp")

	End Sub
	
	private function private_getnewsClassinfo(UID)
	
		Dim RS,SQL,city,userid
		sql = "select * from article_newsclass where id=" & UID
		Set rs  = LDexecute(sql,0)
		If Not Rs.Eof Then
			form_classname = Rs("classname")
			form_listflag = Rs("listflag")
			form_orderflag = Rs("orderflag")
			form_liststyle = rs("liststyle")
			form_listNum = rs("listNum")
			form_ParentID = rs("ParentID")
			form_classname_side = rs("classname_side")
			private_getnewsClassinfo = 1
		else
			private_getnewsClassinfo = 0
		End If
		Rs.Close
		Set Rs = Nothing
		
	end function
	
	Public Sub center_newsClass_Form
	
	%><script>
			function formatItem(row){
			if(row.id==0)
			return('<span style="font-weight:bold" class="grayfont">' + row.text + '</span>');
			else
			return(row.text);
		}
		</script>
	<%
		CALL FormClass_Head(Form_ActionStr,0,"center.asp?action=newsclass")
		CALL FormClass_ItemPring("","hidden","form_modifyid",form_modifyid,"","","","","")
		CALL FormClass_ItemPring("","hidden","submitflag","yes","","","","","")
		CALL FormClass_ItemPring("是否在相关页列出此分类：","select","form_listflag",form_listflag,"","","","0~~~完全不显示|1~~~完全显示|2~~~只显示在顶栏(不显示在侧栏)|3~~~只显示在所有侧栏|4~~~只显示在首页侧栏|5~~~显示在内页侧栏","")
		CALL FormClass_ItemPring("显示顺序：","input","form_orderflag",form_orderflag,2,8,"数字越小排列越前","","")
		CALL FormClass_ItemPring("文章分类名称：","input","form_classname",form_classname,3,255,"必填，可另行使用链接，格式为 <u>超级链接(http:开头)|分类名称</u>","","")
		CALL FormClass_ItemPring("侧栏展示样式","splitchecked","form_liststyle",form_liststyle,"","","",StyleItem,"")
		CALL FormClass_ItemPring("侧栏展示记录数目","input","form_listNum",form_listNum,2,2,"侧栏展示此分类所允许显示的数量","","")
		CALL FormClass_ItemPring("展示在侧栏的名称：","input","form_classname_side",form_classname_side,3,255,"若指定，侧栏优先使用此名称","","")
		Dim str
		
			str = "<input class=""easyui-combobox"" id=""form_ParentID"" name=""form_ParentID"" value=""" & form_ParentID & """ data-options=""" & VbCrLf &_
					"	url: '" & DEF_BBS_HomeUrl & "inc/inchtm/data_artileclass.asp'," & VbCrLf &_
					"	valueField: 'id'," & VbCrLf &_
					"	textField: 'text'," & VbCrLf &_
					"	panelWidth: 250," & VbCrLf &_
					"	panelHeight: 'auto'," & VbCrLf &_
					"	formatter: formatItem" & VbCrLf &_
					""">" & VbCrLf
		CALL FormClass_ItemPring("上级分类","other",str,form_ParentID,2,12,"","","")
		FormClass_End
	
	End Sub

	private Function UpdateCacheData(savefile)

		Dim Rs,GetData,Num
		Set Rs = LDExeCute("Select id,classname from article_newsclass where ParentID=0 order by orderflag asc",0)
	
		If Not Rs.Eof Then
			GetData = Rs.GetRows(-1)
			Num = Ubound(GetData,2)
		Else
			Num = -1
		End If
		Rs.Close
		Set Rs = Nothing
		
		'on error resume next
		Dim TempStr
		TempStr = ""
	
		Dim N,WriteStr
		TempStr = TempStr & "["
	
		If Num = -1 Then
		Else
			For N = 0 to Num
				WriteStr = ""
				WriteStr = WriteStr & KillHTMLLabel(GetData(1,N))
				If StrLength(WriteStr) > 21 Then
					WriteStr = LeftTrue(WriteStr,18) & "..."
				End If	
				
				If N = 0 Then
					TempStr = TempStr & "{" & VbCrLf
				Else
					TempStr = TempStr & ",{" & VbCrLf
				End If
				TempStr = TempStr & "	""id"":" & GetData(0,N) & "," & VbCrLf
				TempStr = TempStr & "	""text"":""" & GetData(0,N) & "." & htmlencode(WriteStr) & """" & VbCrLf & "}"
				GBL_LowClassString = ""
				GBL_LoopN = 0
				GetLowClassString_Json GetData(0,n)
				If GBL_LowClassString <> "" Then TempStr = TempStr & GBL_LowClassString				
			Next
		End If
	
		TempStr = DEF_pageHeader & TempStr & "]"
		
		ADODB_SaveToFile TempStr,DEF_BBS_HomeUrl & "inc/IncHtm/" & savefile & ""
		If GBL_CHK_TempStr = "" Then
			Response.Write "<br><span class=cms_ok>2.成功更新文件../../inc/IncHtm/" & savefile & "！</span>"
		Else
			%><p><%=GBL_CHK_TempStr%><br>服务器不支持在线写入文件功能，请使用FTP等功能，<br>将<span Class=cms_error>inc/IncHtm/<%=savefile%></span>文件替换成下框中内容(注意备份)<p>
			<textarea name="fileContent" cols="80" rows="20" class=fmtxtra><%=Server.htmlencode(TempStr)%></textarea><%
			GBL_CHK_TempStr = ""
		End If
	
	End Function
	
	Private sub GetLowClassString_Json(classid)

		If classid = "" or isNull(classid) or GBL_LoopN > 100 Then Exit sub
		Dim Rs,GetData,Num
		
		GBL_LoopN = GBL_LoopN + 1

		Set Rs = LDExeCute("Select id,classname from article_newsclass where ParentID=" & classid & " order by orderflag asc",0)
		If Not Rs.Eof Then
			GetData = Rs.GetRows(-1)
			Num = Ubound(GetData,2)
		Else
			Num = -1
		End If
		Rs.Close
		Set Rs = Nothing
	
		Dim Temp
		Dim WriteStr,N
		For N = 0 to Num
			WriteStr = ""
			WriteStr = WriteStr & KillHTMLLabel(GetData(1,N))
			If StrLength(WriteStr) > 21 Then
				WriteStr = LeftTrue(WriteStr,18) & "..."
			End If
			GBL_LowClassString = GBL_LowClassString & ",{" & VbCrLf
			GBL_LowClassString = GBL_LowClassString & "	""id"":" & GetData(0,N) & "," & VbCrLf
			GBL_LowClassString = GBL_LowClassString & "	""text"":""" & GetData(0,N) & "." & htmlencode(WriteStr) & """" & VbCrLf & "}"
			'GetLowBoardString_Json GetData(0,N)
		Next			
		GBL_LoopN = GBL_LoopN - 1
	
	end sub
	
End Class

class center_managenewsClass_Class

	Private class_page,class_sql,class_idname,class_selcolumn
	
	Private Sub Class_Initialize
	
		Dim sql_extend
		sql_extend = ""

		class_page = GetFormData("page")
		class_page = FormClass_CheckFormValue(class_page,"","int","0","<~~~0|>~~~10000000000",12)
		
		class_sql = "select {~~~} from article_newsclass " & sql_extend
		class_idname = "id"
		class_selcolumn = "id,classname"
		CALL splitpage_returnData(class_sql,class_idname,class_page,class_selcolumn,0)
		
		private_managelist
		
		CALL splitpage_viewpagelist("center.asp?action=newsclass&list=1",splitpage_maxpage,splitpage_page,"")
			
	End sub
	
	private sub private_managelist
	
		cms_selectFormScript("center.asp?action=newsclass")
		%>
		<div class="title"><div class="titlebg">管理文章分类 <a href=center.asp?action=newsclass>点此添加新分类</a></div></div>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class=table_in>
				<tr class="tbinhead cms_tbinhead">
					<td width=60><div class=cms_value>编号</div></td>
					<td><div class=cms_value>分类名称</div></td>
					<td>编辑</td>
					<td>栏目</td>
				</tr>
				<%dim n
				for n = 0 to splitpage_num%>
				<tr>
					<td class=tdbox><%=splitpage_getdata(0,n)%></td>
					<td class=tdbox><span class="layerico"><%
					If ccur(splitpage_getdata(0,n)) <> 1 then
					%><input class="fmchkbox" type="checkbox" name="ids" id="ids<%=n%>" value="<%=splitpage_getdata(0,n)%>" onclick="delbody_view(this);" /><%
					else
						Response.Write "<span class=""grayfont"">[首页公告栏专用分类]</span>"
					end if%></span><a href=center.asp?action=newsclass&form_modifyid=<%=splitpage_getdata(0,n)%>><%=splitpage_getdata(1,n)%></a></td>
					<td class=tdbox><a href=center.asp?action=newsclass&form_modifyid=<%=splitpage_getdata(0,n)%>>编辑<a></td>
					<td class=tdbox><a href=center.asp?action=setchannel&form_fileid=<%=splitpage_getdata(0,n)%>>栏目设定<a></td>
				</tr>
				<%next%>
		</table>
		<br />
		<hr class=splitline>
		<%
	
	end sub

End Class




%>