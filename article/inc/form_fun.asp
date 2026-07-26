<%

Sub FormClass_Head(title,enableuploadflag,actionurl)

	dim sTitle,sStyle,Tmp
	if inStr(title,"|") then
		Tmp = split(title,"|")
		sTitle = tmp(0)
		sStyle = tmp(1)
	else
		sTitle = title
		sStyle = ""
	end if
%>
	<script>
	var ValidationPassed = true;
	function submitonce(theform)
	{
		if(ValidationPassed == false)return;
		if(typeof edt_checkContent != "undefined")
		{
			edt_checkContent();
			lg = edt_getdoclen();
			if(lg > <%=DEF_MaxTextLength%>)
			{
				alert("发表的内容超过了<%=DEF_MaxTextLength%>文字，目前长度" + lg + "文字\n");
				ValidationPassed = false;
				submitflag = 0;
				return;
			}
		}
		submit_disable(theform);
	}
	</script>
	<%=sStyle%>
	<div class="title"><div class="titlebg"><%=sTitle%></div></div>
			<div class="itemtable">
			<%If enableuploadflag = 0 Then%>
			<form action=<%=actionurl%> method=post name=LeadBBSFm id="LeadBBSFm" onSubmit="submitonce(this);return ValidationPassed">
			<%Else%>
			<form action=<%=actionurl%><%
			if instr(actionurl,"?") then
				response.write "&dontRequestFormFlag=1"
			else
				response.write "?dontRequestFormFlag=1"
			end if%> method="post" name="LeadBBSFm" id="LeadBBSFm" enctype="multipart/form-data" onSubmit="submitonce(this);if(ValidationPassed)Upl_submit();return ValidationPassed">
			<%End If

End Sub

' Remark 项目注释,maxlength,允许最大长度 inputClass,表单框长度类,数字表示,ItemName,项名称,ItemValue,项的值,PrintType,打印的类别,SelectStr,如果是select 类别,此类项的值串,以|号分隔
Sub FormClass_ItemPring(title,PrintType,ItemName,Item_Value,inputClass,maxLength,reMark,SelectStr,moreEvent)

	dim ItemValue
	ItemValue = Item_Value
	if isnull(ItemValue) then ItemValue = ItemValue & ""
	Dim N,Tmp,Count,Tmp2
	Dim indexN,InfoText,tmpArr
	
	If title <> "single" Then
%>
			<div class="itemline"<%If PrintType = "hidden" Then Response.Write " style=""display:none"""%>>
				<span class="itemtitle">
					<%=title%>
				</span>
				<span class="iteminfo">
					<%
	end if
					Select Case PrintType
						Case "verifycode":
							Response.Write displayVerifycode()
						Case "printvalue":
							Response.Write ItemValue
						Case "input_notzero":
							%><input class='fminpt input_<%=inputClass%>' maxLength=<%=maxLength%> name="<%=ItemName%>" type=input Value="<% If ItemValue<>"" and cstr(ItemValue) <> "0" Then Response.Write Server.HtmlEncode(ItemValue)%>"<%=moreEvent%>><%If reMark<>"" Then%> <span class=cms_remark><%=reMark%></span><%End If
						Case "input":
							%><input class='fminpt input_<%=inputClass%>' maxLength=<%=maxLength%> name="<%=ItemName%>" type=input Value="<% If ItemValue<>"" Then Response.Write Server.HtmlEncode(ItemValue)%>"<%=moreEvent%>><%If reMark<>"" Then%> <span class=cms_remark><%=reMark%></span><%End If%><%
						Case "hidden":
							%><input name="<%=ItemName%>" type=hidden Value="<% If ItemValue<>"" Then Response.Write Server.HtmlEncode(ItemValue)%>"<%=moreEvent%>>
							<%
						Case "password":	
							%><input class='fminpt input_<%=inputClass%>' maxLength=<%=maxLength%> name="<%=ItemName%>" type=password Value="<% If ItemValue<>"" Then Response.Write Server.HtmlEncode(ItemValue)%>"<%=moreEvent%>><%If reMark<>"" Then%> <span class=cms_remark><%=reMark%></span><%End If
						Case "select":
							if instr(moreEvent," class=""") then
								tmp = replace(moreEvent," class="""," class=""")
							else
								tmp = moreEvent & " class=""easyui-combobox"""
							end if
							Response.Write "<select data-options=""panelHeight: 'auto',editable:false"" name=""" & ItemName & """" & tmp & ">"
							Tmp = Split(SelectStr,"|")
							Count = Ubound(Tmp,1)
							For N = 0 To Count
								Tmp2 = Split(Tmp(N),"~~~")
								If cstr(ItemValue) <> cstr(Tmp2(0)) Then
									Response.Write "<option value=""" & Tmp2(0) & """>" & Tmp2(1) & "</option>"
								Else
									Response.Write "<option value=""" & Tmp2(0) & """ selected='selected'>" & Tmp2(1) & "</option>"
								End If
							Next
							Response.Write "</select>"
						Case "textarea":
							%>
							<textarea class=fmtxtra name="<%=ItemName%>" rows=<%=maxLength%> cols=34 <%If inputClass<>"" then%>style="width:<%=inputClass%>"<%End If%><%=moreEvent%>><%If ItemValue <> "" Then Response.Write VbCrLf & htmlEncode(ItemValue)%></textarea>
							<%
						Case "splitchecked":
							%>
							<ul class="splitchecked">
							<%
							for n = 0 to Ubound(SelectStr,1)
								If inStr(SelectStr(n),"|") <= 0 Then
									%>
									</ul><b><%=SelectStr(n)%></b><ul>
									<%
								Else
									tmpArr = Split(SelectStr(n),"|")
									IndexN = tmpArr(0)
									InfoText = tmpArr(1)
									If instr(InfoText,"<span") = 0 Then%>
									<li><span class="grayfont"><%
									If IndexN <= 9 Then Response.Write "0"
									Response.Write IndexN%></span><input type="checkbox" class=fmchkbox name="<%=ItemName%><%=IndexN%>" value="1"<%
									If instr(InfoText,"<span") Then Response.Write " disabled=""disabled"""
									If GetBinarybit(Item_Value,IndexN) = 1 Then
										Response.Write " checked>"
									Else
										Response.Write ">"
									End If%><%=InfoText%></li>
									<%
									End If
								End If
							Next
							%>
							</ul>
							<%
						Case "splitradio":
							%>
							<ul class="splitradio">
							<%
							for n = 0 to Ubound(SelectStr,1)
								If inStr(SelectStr(n),"|") <= 0 Then
									%>
									</ul><b><%=SelectStr(n)%></b><ul>
									<%
								Else
									tmpArr = Split(SelectStr(n),"|")
									IndexN = tmpArr(0)
									InfoText = tmpArr(1)
									If instr(InfoText,"<span") = 0 Then%>
										<li><span class="grayfont"><%
										'If IndexN <= 9 Then Response.Write "0"
										'Response.Write IndexN
%></span><input type="radio" class=fmchkbox name="<%=ItemName%>" value="<%=htmlencode(InfoText)%>"<%
										If instr(InfoText,"<span") Then Response.Write " disabled=""disabled"""
										If Item_Value = InfoText Then
											Response.Write " checked>"
										Else
											Response.Write ">"
										End If%><%=InfoText%></li>
									<%
									End If
								End If
							Next
							%>
							</ul><div class=clear></div>
							<%
						case "other":
							Response.Write ItemName
					End Select
			If title <> "single" Then%>
				</span>
			</div>
<%
			end if

End Sub

Sub FormClass_End

%>
	
			<div class="itemline">
				<span class="itemtitle">&nbsp;</span>
				<span class="iteminfo itembottom">
					<input name=submit2 type=submit value="提交" class="fmbtn btn_2">
					<input name=b1 type=reset value="重写" class="fmbtn btn_2">
				</span>
			</div>
			</div>
		</form>
<%

End Sub

'Formitem 要测试的值 checktype 测试类型 default 若错,设定为的默认值 inValue 允许的包含值串
Dim CheckErrorStr
Function FormClass_CheckFormValue(Formitem,ItemName,checktype,default,inValue,maxlength)

	CheckErrorStr = ""
	Dim Tmp_Formitem
	Tmp_Formitem = Formitem
	Select Case checktype	
		Case "string":
			FormClass_CheckFormValue = Tmp_Formitem
		Case "numeric":
			if isNumeric(Tmp_Formitem) = 0 Then
				Tmp_Formitem = 0
				FormClass_CheckFormValue = Tmp_Formitem
				CheckErrorStr = CheckErrorStr & "Error: " & ItemName & "错误1,请确认."
			Else
				FormClass_CheckFormValue = cCur(Tmp_Formitem)
			End If
		Case "int":
			if isNumeric(Tmp_Formitem) = 0 or inStr(Tmp_Formitem,".") > 0 Then
				Tmp_Formitem = 0
				FormClass_CheckFormValue = Tmp_Formitem
				CheckErrorStr = CheckErrorStr & "Error: " & ItemName & "错误2,请确认."
			Else
				FormClass_CheckFormValue = Fix(cCur(Tmp_Formitem))
			End If
	End Select
	
	If maxlength > 0 Then
		If strLength(Tmp_Formitem) > maxlength Then
			If checktype = "int" Then
				CheckErrorStr = CheckErrorStr & "Error: " & ItemName & "数据值过大或填写错误."
			Else
				CheckErrorStr = CheckErrorStr & "Error: " & ItemName & "过长,不能超过" & maxlength & " 字节."
			End If
		End If
	End If
	
	
	Dim Tmp,n,count,typeTmp,ValueTmp,tmp2
	If inValue <> "" and CheckErrorStr = "" Then
		If inStr(inValue,"~~~") > 0 Then
			Tmp = Split(inValue,"|")
			count = ubound(tmp)
			for n = 0 to count
				tmp2 = Split(tmp(n),"~~~")
				typeTmp = tmp2(0)
				ValueTmp = tmp2(1)
				select case typeTmp
					case ">":
						If cCur(Tmp_Formitem) > cCur(ValueTmp) Then
							CheckErrorStr = CheckErrorStr & "Error: " & ItemName & "错误,请确认."
						End If
					case "<":
						If cCur(Tmp_Formitem) < cCur(ValueTmp) Then
							CheckErrorStr = CheckErrorStr & "Error: " & ItemName & "错误,请确认."
						End If
					case "=":
						if ValueTmp = "" and Cstr(Tmp_Formitem) = Cstr(ValueTmp) Then
							CheckErrorStr = CheckErrorStr & "Error: " & ItemName & "必须填写,请确认."
						Else
							If Cstr(Tmp_Formitem) = Cstr(ValueTmp) Then
								CheckErrorStr = CheckErrorStr & "Error: " & ItemName & "错误5,请确认."
							End If
						End If
				end select
				If CheckErrorStr <> "" Then exit for
			next
		Else
			if inStr("|" & inValue & "|","|" & Tmp_Formitem & "|") = 0 Then
				CheckErrorStr = CheckErrorStr & "Error: " & ItemName & "错误6,请确认."
			End if
		End If	
	End If
	
	If default <> "none" and CheckErrorStr <> "" Then
		FormClass_CheckFormValue = default
		CheckErrorStr = ""
	End If

End Function

Function cms_SQL(str)

	cms_SQL = Replace(str,"'","''")

End Function

sub cms_selectFormScript(url)
%>

		<span id="delinfo"></span>
		<script type="text/javascript">
		function a_command(cstr,obj,action)
		{
			layer_view(cstr,obj,'','','anc_delbody','<%=url%>','',1,'AjaxFlag=1&action2=' + action,1);return(false);
		}
		function delbody_view(obj,check)
		{
			layer_create("anc_msgbody");
			var tmp="";
			if(check==1)
			{
				tmp=" <a href=\"javascript:;\" onclick=\"a_command('批量通过审核',$id('" + obj.id + "'),'check&idlist='+p_getselected());\">批通过审核</a>";
				tmp+=" <a href=\"javascript:;\" onclick=\"a_command('批量取消审核',$id('" + obj.id + "'),'uncheck&idlist='+p_getselected());\">批取消审核</a>";
			}
				
			$id('anc_msgbody').innerHTML="<div class=ajaxbox>已选择 <b id=layer_selectnum>" + p_getnum() + "</b> 条记录：<br>请选择：<b><a href=\"javascript:;\" onclick=\"if(confirm('删除记录将无法恢复,确定继续吗?'))a_command('删除记录',$id('" + obj.id + "'),'delete&idlist='+p_getselected());\">批量删除</a>" + tmp + "</b><br><input class=\"fmchkbox\" type=\"checkbox\" name=\"selmsg\" id=\"selmsg\" value=\"1\" onclick=\"achoose();\" />选择全部</div>";
			layer_view('',obj,'','','anc_msgbody','','',0,'',0,20);
			$id("delinfo").innerHTML="<br><b><a class=redfont href=\"javascript:;\" onclick=\"if(confirm('删除记录将无法恢复,确定继续吗?'))a_command('删除已选择的记录',$id('" + obj.id + "'),'delete&idlist='+p_getselected());\">删除已选择的记录</a></b>";
		}
		</script>
		<script src="../inc/js/p_list.js?ver=20090601.2" type="text/javascript"></script>
	<%	
end sub

function cms_checkdeleteform(table,superflag)
	
		dim cityid,checkLevelsql
		checkLevelsql = ""
		
		if superflag = 1 and Check_jdsupervisor() = 0 then
			response.Write "<div class=ajaxbox><div class=cms_error>权限不足.</div></div>"
			cms_checkdeleteform = 0
			exit function
		end if

		dim action2,idlist
		action2 = getformdata("action2")
		idlist = getformdata("idlist")
		if action2 <> "delete" then
			cms_checkdeleteform = 0
			exit function
		end if
		dim listtemp
		listtemp = ""
		idlist = split(idlist,",")
		dim n,count,val,sql
		count = ubound(idlist,1)
		for n = 0 to count
			val = idlist(n)
			val = FormClass_CheckFormValue(val,"","int",0,"",0)
			if val > 0 Then
				sql  = "delete from " & table & " where id=" & cms_SQL(val) & checkLevelsql
				listtemp = listtemp & val & ","
				call ldexecute(sql,1)
			end if
		next
		if listtemp = "" then listtemp = " 无(未选择任何记录)."
		response.Write "<div class=ajaxbox><div class=cms_ok>以下记录成功删除: " & listtemp & "</div></div>"
		cms_checkdeleteform = 1

end function


function cms_changeCheckedFlag(table,superflag)
	
		dim cityid,checkLevelsql
		checkLevelsql = ""
		
		if superflag = 1 and Check_jdsupervisor() = 0 then
			response.Write "<div class=ajaxbox><div class=cms_error>权限不足.</div></div>"
			cms_changeCheckedFlag = 0
			exit function
		end if
		
		
		dim action2,idlist
		action2 = getformdata("action2")
		idlist = getformdata("idlist")
		if action2 <> "check" and action2 <> "uncheck" then
			cms_changeCheckedFlag = 0
			exit function
		end if
		if action2 = "check" Then
			action2 = 1
		else
			action2 = 0
		end if
		dim listtemp
		listtemp = ""
		idlist = split(idlist,",")
		dim n,count,val,sql
		count = ubound(idlist,1)
		for n = 0 to count
			val = idlist(n)
			val = FormClass_CheckFormValue(val,"","int",0,"",0)
			if val > 0 Then
				sql  = "update " & table & " set checkedflag=" & action2 & " where id=" & cms_SQL(val) & checkLevelsql
				listtemp = listtemp & val & ","
				call ldexecute(sql,1)
			end if
		next
		if listtemp = "" then listtemp = " 无(未选择任何记录)."
		response.Write "<div class=ajaxbox><div class=cms_ok>以下记录成功操作: " & listtemp & "</div></div>"
		cms_changeCheckedFlag = 1
	
end function
%>