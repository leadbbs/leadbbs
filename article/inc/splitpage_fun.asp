<%
dim splitpage_getdata,splitpage_num,splitpage_page,splitpage_maxpage,splitpage_listNum,splitpage_orderstr
dim startid : startid = 0 '跳转限制页后参数，暂时无需求未开发
dim splitpage_MaxJumpPageNum : splitpage_MaxJumpPageNum = DEF_MaxJumpPageNum

sub splitpage_returnData(class_sql,class_idname,class_page,class_selcolumn,class_recordcount)

		dim rs,sql
		
		dim extendcount,p,listNum
		extendcount = 0
		if splitpage_listNum > 0 then 
			listNum = splitpage_listNum
		else
			listNum = 20
		end if
		
		dim class_sqlfull,class_sqlsim,tmp
		if inStr(class_sql,"---split---") > 0 then
			tmp = split(class_sql,"---split---")
			class_sqlfull = tmp(0)
			class_sqlsim = tmp(1)
		else
			class_sqlfull = class_sql
			class_sqlsim = class_sql
		end if
		If class_recordcount = 0 then
			sql = replace(class_sqlsim,"{~~~}","count(*)")
			Set rs = LDExeCute(sql,0)
			if not rs.eof then
				extendcount = rs(0)
				if isnumeric(extendcount) = false then extendcount = 0
			end if
			rs.close
			set rs = nothing
		Else
			extendcount = class_recordcount
		End If
		
		dim maxpage
		maxpage = Fix(extendcount/listNum)
		if (extendcount mod listNum) > 0 then maxpage = maxpage + 1
		p = class_page
		if p >= maxpage then p = maxpage - 1
		if p < 0 then p = 0
		if p >= splitpage_MaxJumpPageNum then p = splitpage_MaxJumpPageNum
		
		dim selpage
		selpage = p
		
		dim maxJumpPage : maxJumpPage = 5
		'if DEF_UsedDataBase <> 2 then
		if 1 = 0 and DEF_UsedDataBase <> 2 then 'move，其中mysql odbc不支持使用move
			if p > maxJumpPage then
				dim orderstr
				if splitpage_orderstr <> "" then
					orderstr = " order by " & splitpage_orderstr
				else
					orderstr = " order by " & class_idname & " desc"
				end if
				if splitpage_orderstr <> "" then
					sql = sql_select(replace(class_sqlsim,"{~~~}",class_idname) & orderstr,(p+1)*listNum)
				else
					sql = sql_select(replace(class_sqlsim,"{~~~}",class_idname) & orderstr,(p+1)*listNum)
				end if
				Set rs = LDExeCute(sql,0)
				If Not Rs.Eof Then
					sqlstring = sqlstring & "<li><span class=bluefont>" & FormatNumber(cCur(Timer - DEF_PageExeTime1),4,True) & "</span> move" & p*listNum & "条记录前</li>" & VbCrLf
					Rs.Move p*listNum
					sqlstring = sqlstring & "<li><span class=bluefont>" & FormatNumber(cCur(Timer - DEF_PageExeTime1),4,True) & "</span> move" & p*listNum & "条记录后</li>" & VbCrLf
					If Not Rs.Eof Then
						startid = ccur(Rs(0))
						selpage = 0
					end if
				end if
				rs.close
				set rs = nothing
			end if
		else
			if p > maxJumpPage then
				dim funname
				select case DEF_UsedDataBase
				case 0,1:
					if lcase(right(trim(splitpage_orderstr),4)) = "desc" then
						funname = "min(tb.id)"
					else
						funname = "max(tb.id)"
					end if
					if splitpage_orderstr <> "" then
						sql = sql_select(replace(class_sqlsim,"{~~~}",class_idname & " as id") & " order by " & splitpage_orderstr,(p)*listNum)
					else
						sql = sql_select(replace(class_sqlsim,"{~~~}",class_idname & " as id") & " order by " & class_idname & " desc",(p)*listNum)
						funname = "min(tb.id)"
					end if
					sql = "select " & funname & " from (" & sql & ") as tb"
					
					Set rs = LDExeCute(sql,0)
					If Not Rs.Eof Then
						startid = ccur(Rs(0))
						selpage = 0
					end if
					rs.close
					set rs = nothing
				case 2:
					dim limitMYSQL
					limitMYSQL = p*listNum-1
					if limitMYSQL < 1 then limitMYSQL = 1
					if splitpage_orderstr <> "" then
						sql = sql_select(replace(class_sqlsim,"{~~~}",class_idname & " as id") & " order by " & splitpage_orderstr,limitMYSQL & ",1")
					else
						sql = sql_select(replace(class_sqlsim,"{~~~}",class_idname & " as id") & " order by " & class_idname & " desc",limitMYSQL & ",1")
					end if
					Set rs = LDExeCute(sql,0)
					If Not Rs.Eof Then
						sqlstring = sqlstring & "<li><span class=bluefont>" & FormatNumber(cCur(Timer - DEF_PageExeTime1),4,True) & "</span> funname后</li>" & VbCrLf
						startid = ccur(Rs(0))
						selpage = 0
					end if
					rs.close
					set rs = nothing
				end select
			end if
		end if
		'end if
		
		'sql = replace(class_sqlfull,"{~~~}","top " & ((selpage+1)*listNum) & " " & class_selcolumn)
		'sql = replace(class_sqlfull,"{~~~}","top " & ((selpage+1)*listNum) & " " & class_selcolumn)
		sql = class_sqlfull
		If startid > 0 Then
			If inStr(lcase(splitpage_orderstr)," desc") or splitpage_orderstr = "" then
				if inStr(sql," where ") > 0 Then
					sql = sql & " and " & class_idname & "<=" & startid
				Else
					sql = sql & " where " & class_idname & "<=" & startid
				end if
			else
				if inStr(sql," where ") > 0 Then
					sql = sql & " and " & class_idname & ">=" & startid
				Else
					sql = sql & " where " & class_idname & ">=" & startid
				end if
			end if
		end if
		if splitpage_orderstr <> "" then
			sql = sql & " order by " & splitpage_orderstr
		else
			sql = sql & " order by " & class_idname & " desc"
		end if
		
		dim limit
		'if DEF_UsedDataBase <> 2 then
			limit = (selpage+1)*listNum
		'else
		'	limit = (selpage)*listNum & "," & listNum
		'end if
		sql = sql_select(replace(sql,"{~~~}"," " & class_selcolumn),limit)
		Set rs = LDExeCute(sql,0)
		if not rs.eof then
			'if DEF_UsedDataBase <> 2 then
				if p<=maxJumpPage and p>0 then
					rs.move p*listNum
					
				end if
			'end if
			if not Rs.Eof Then
				splitpage_getdata = rs.getrows(listNum)
				splitpage_num = ubound(splitpage_getdata,2)
			else
				splitpage_num = -1
			end if
		else
			splitpage_num = -1
		end if
		rs.close
		set rs = nothing
		
		splitpage_page = p
		splitpage_maxpage = maxpage

end Sub

rem ajaxobj 组成: ajax传递返回的obj.id|传递的参数|ajax执行完成后执行的js代码
dim splitpage_cazhi : splitpage_cazhi = 0 '页数差距
Dim splitpage_notbreak : splitpage_notbreak = 0 '是否clear both强制分行
dim splitpage_mobileflag : splitpage_mobileflag = 0 '是否为移动设备
sub splitpage_viewpagelist(url,num,curp,ajaxobj)

	dim n
	dim jumpNum:jumpNum = 4
	if splitpage_mobileflag = 1 then jumpNum = 1
	if splitpage_notbreak = 0 then
	%>
	<div class=clear></div><%
	end if
	
	if splitpage_mobileflag = 0 then
	%>
	<div class="j_page">
	<%
	else%>
	<div class="pagenav textCenter">
            <div class="pg">
	<%
	end if
	
	dim rep : rep = 0
	if inStr(url,"{page}") > 0 then rep = 1
	
	dim MF : MF = "&"
	if rep = 1 and inStr(url,"?") < 1 then MF = "?"

	dim tn
	if curp < 1 then
		if splitpage_mobileflag = 1 then
		%>
		<a class="prev disabled font-icon" onclick="return false;">　</a>
		<%
		end if
	else
		%>
		<a class="prev font-icon" href="<%
		tn = curp - 1
		if rep = 0 then
			Response.Write url & "&page=" & (tn+splitpage_cazhi)
		else
			response.write replace(url,"{page}",(tn+splitpage_cazhi))
		end if%>"<%
			if ajax_item <> "" Then
				%> onclick="getAJAX(this.href+'<%=MF%>AjaxFlag=1&jsflag=1','<%=ajax_para%>','<%=ajax_item%>',0,'<%=ajax_exec%>');return(false);"<%
			end if
		%> data-ajax=false><%
		if splitpage_mobileflag = 0 then
			response.write "上页"
		else
			response.write "　"
		end if
		%></a>
		<%
	end if
	
	dim ajax_item,ajax_para,tmp,ajax_exec
	if inStr(ajaxobj,"|") > 0 then
		tmp = split(ajaxobj,"|")
		ajax_item = tmp(0)
		ajax_para = tmp(1)
		if ubound(tmp) > 1 then ajax_exec = tmp(2)
	else
		ajax_item = ajaxobj
		ajax_para = ""
		ajax_exec = ""
	end if
	
	if curp > jumpNum then
	n=0%>
	<a href="<%
	if rep = 0 then
		Response.Write url & "&page=" & (n+splitpage_cazhi)
	else
		response.write replace(url,"{page}",(n+splitpage_cazhi))
	end if%>"<%
		if ajax_item <> "" Then
			%> onclick="getAJAX(this.href+'<%=MF%>AjaxFlag=1&jsflag=1','<%=ajax_para%>','<%=ajax_item%>',0,'<%=ajax_exec%>');return(false);"<%
		end if
	%> data-ajax=false><%
	response.write n+1
	if curp-jumpNum > 1 and splitpage_mobileflag = 0 then Response.Write "..."%></a>
	<%
	end if
	
	dim start,endd
	start = curp-jumpNum
	endd = curp+jumpNum
	if start < 0 then start = 0
	if endd >= num then endd = num - 1
	dim curNum
	curNum = (jumpNum+jumpNum)-(endd - start)
	if curNum > 0 then
		if curp < 100 then
		elseif curp < 990 then
			curNum = curNum - 1
		elseif curp < 9990 then
			curNum = curNum - 2
		end if
		if curNum > 0 then
			if endd + curNum < Num then
				endd = endd + curNum
			else
				start = start - (curNum-(Num-1-endd))
				endd = Num - 1
			end if
		end if
	end if
	
	
	for n = start to endd
		if n >=0 and n < num then
			if n <> curp then
	%><a href="<%
	if rep = 0 then
		Response.Write url & "&page=" & (n+splitpage_cazhi)
	else
		response.write replace(url,"{page}",(n+splitpage_cazhi))
	end if%>"<%
		if ajaxobj <> "" Then
			%> onclick="getAJAX(this.href+'<%=MF%>AjaxFlag=1&jsflag=1','<%=ajax_para%>','<%=ajax_item%>',0,'<%=ajax_exec%>');return(false);"<%
		end if
	%> data-ajax=false><%=n+1%></a><%
			else
	%><b><strong><%=n+1%></strong></b><%
			end if
		end if
	next
	
	if curp < num-jumpNum-1 and endd+1 <> num-1+1 then
	n=num-1%>
	<a href="<%
	if rep = 0 then
		Response.Write url & "&page=" & (n+splitpage_cazhi)
	else
		response.write replace(url,"{page}",(n+splitpage_cazhi))
	end if%>"<%
		if ajaxobj <> "" Then
			%> onclick="getAJAX(this.href+'<%=MF%>AjaxFlag=1&jsflag=1','<%=ajax_para%>','<%=ajax_item%>');return(false);"<%
		end if
	%> data-ajax=false><%	
	if curp+jumpNum < num-2 and splitpage_mobileflag = 0 then Response.Write "..."
	response.write n+1%></a>
	<%
	end if
	
	if num > jumpNum * 2 then
	%>
	<input type="text" data-role="none" title="输入页数,按Enter键跳转。" size="2" onkeydown="javascript:if(event.keyCode==13){<%
	if ajaxobj <> "" Then
	%>getAJAX('<%
	
		if rep = 0 then
			Response.Write url & "&page='+parseInt(this.value)+'"
		else
			%>'+('<%=url%>'.replace(/\{page\}/i,parseInt(this.value)-1+<%=splitpage_cazhi%>))+'<%
		end if
	%><%=MF%>AjaxFlag=1&jsflag=1','<%=ajax_para%>','<%=ajax_item%>',0,'<%=ajax_exec%>');<%
	else
	%>location='<%
		if rep = 0 then
			Response.Write url & "&page='+(parseInt(this.value)-1+" & splitpage_cazhi & ")+'"
		else
			%>'+('<%=url%>'.replace(/\{page\}/i,parseInt(this.value)-1+<%=splitpage_cazhi%>))+'<%
		end if%>';<%
	end if%>return false;}">
	<%end if
	
	if curp+splitpage_cazhi+1 >= num then
		if splitpage_mobileflag = 1 then
		%>
		<a class="nxt disabled font-icon" onclick="return false;">　</a>
		<%
		end if
	else
		%>
		<a class="nxt font-icon" href="<%
		tn = curp + 1
		if rep = 0 then
			Response.Write url & "&page=" & (tn+splitpage_cazhi)
		else
			response.write replace(url,"{page}",(tn+splitpage_cazhi))
		end if%>"<%
			if ajax_item <> "" Then
				%> onclick="getAJAX(this.href+'<%=MF%>AjaxFlag=1&jsflag=1','<%=ajax_para%>','<%=ajax_item%>',0,'<%=ajax_exec%>');return(false);"<%
			end if
		%> data-ajax=false><%
		if splitpage_mobileflag = 0 then
			response.write "下页"
		else
			response.write "　"
		end if
		%></a>
		<%
	end if
	
	
	
	if splitpage_mobileflag = 0 then
	%>
	</div>
	<%
	else%>
		</div>
	</div>
	<%
	end if
	
	if splitpage_notbreak = 0 then
		%><div class=clear></div><%
	end if

end sub

%>