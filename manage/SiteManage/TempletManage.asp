<!-- #include file=../../inc/BBSsetup.asp -->
<!-- #include file=../../inc/Board_Popfun.asp -->
<!-- #include file=../inc/bbsmanage_Fun.asp -->
<%
DEF_BBS_HomeUrl = "../../"
initDatabase
GBL_CHK_TempStr = ""
checkSupervisorPass

Dim Action
Action = Left(Request("Action"),14)
If Action <> "Join" and Action <> "Modify" and Action <> "Delete" Then
	Action = "Manage"
End If

Dim LMT_TempletFlag,Form_TempletName,Form_TempletString(4),Form_MaxTempletID
LMT_TempletFlag = 0

Dim LMT_TempletFlagData,LMT_TempletFlagDataNum
LMT_TempletFlagData = Array("版面列表模板","帖子列表模板","帖子内容模板","保留")
LMT_TempletFlagDataNum = Ubound(LMT_TempletFlagData,1)

Dim LMT_ID

Manage_sitehead DEF_SiteNameString & " - 管理员",""

frame_TopInfo
DisplayUserNavigate("论坛模板管理")%>
<div class=frameline><a href=TempletManage.asp>管理论坛模板</a>
<a href=TempletManage.asp?action=Join>添加论坛模板</a>
</div><%If GBL_CHK_Flag=1 Then
	Select Case Action:
		Case "Join": Join
		Case "Modify": Join
		Case "Delete": Delete
		Case "Manage": Manage
	End Select
Else
DisplayLoginForm
End If
frame_BottomInfo
closeDataBase
Manage_Sitebottom("none")

Function Join

	If Action = "Modify" Then
		LMT_ID = Left(Trim(Request("ID")),14)
		If isNumeric(LMT_ID) = 0 Then LMT_ID = -1
		LMT_ID = Fix(cCur(LMT_ID))
		If LMT_ID < 0 or CheckTempletIDExist(LMT_ID) = 0 Then
			Response.Write "<div class=alert>编辑的模板不存在!</div>" & VbCrLf
			Exit Function
		End If
	End If
	%>
	<div class=frameline><b><%
	If Action = "Modify" Then
		Response.Write "编辑"
	Else
		Response.Write "添加"
	End If%>论坛模板</b></div><%
	GBL_CHK_TempStr = ""
	If Request("submitflag")="LKOkxk2" Then
		If CheckFormData=0 Then
			Response.Write "<div class=alert>错误信息：" & GBL_CHK_TempStr & "</div>" & VbCrLf
			DisplayJoinForm
	       	Else
			If UpdateTemplet = 0 Then
				Response.Write "<div class=alert>插入出错：" & GBL_CHK_TempStr & "</div>" & VbCrLf
				DisplayJoinForm
			Else
				Response.Write "<div class=alert>成功操作!</div>" & VbCrLf
			End If
		End If
	Else
		DisplayJoinForm
	End If

End Function

Function DisplayJoinForm

	Dim TempN
	If Action = "Modify" Then
		DisplayModifyForm
		Exit Function
	End If%>
	<form action=TempletManage.asp method=post name=form1 id=form1>
	<table border=0 cellpadding=0 cellspacing=0 width="100%" class=frame_table>
	<tr>
		<td class=tdbox width=120>模板名称:</td><td class=tdbox><input name=Form_TempletName maxlength=50 value="<%=htmlencode(Form_TempletName)%>" class=fminpt></td>
	</tr>
	<tr valign=top>
		<td class=tdbox width=80>
			模板启用：<br>不勾选则表示不启用</td>
		<td class=tdbox align=left><%
			for TempN = 0 to LMT_TempletFlagDataNum%>	 
			<input type="checkbox" class=fmchkbox name="Limit<%=TempN+1%>" value="1"<%If GetBinarybit(LMT_TempletFlag,TempN+1) = 1 Then
				Response.Write " checked>"
			Else
				Response.Write ">"
			End If%><%=LMT_TempletFlagData(tempN)%><br>
			<%Next%>
			</td>
	</tr><%
			for TempN = 0 to LMT_TempletFlagDataNum%>
	<tr>
		<td class=tdbox><%=LMT_TempletFlagData(tempN)%></td><td class=tdbox><textarea name=Form_TempletString<%=tempN%> rows=6 cols=51 class=fmtxtra><%If Form_TempletString(tempN) <> "" Then Response.Write VbCrLf & Server.htmlEncode(Form_TempletString(tempN))%></textarea></td>
	</tr><%Next%>
	<tr>
		<td class=tdbox>&nbsp;</td>
		<td class=tdbox>
			<input name=LMT_GoodNum type=hidden value="0">
			<input name=action type=hidden value="Join">
			<input name=submitflag type=hidden value="LKOkxk2">
			<input type=submit value="提交" class=fmbtn> <input type=reset value="取消" class=fmbtn>
		</td>
	</tr>
	</table></form>

<%End Function

Function DisplayModifyForm

	Dim TempN
	%>
	<form action=TempletManage.asp method=post name=form1 id=form1>
	<table border=0 cellpadding=0 cellspacing=0 width=100% class=frame_table>
	<tr>
		<td class=tdbox width=120>模板名称:</td><td class=tdbox><input name=Form_TempletName maxlength=50 value="<%=htmlencode(Form_TempletName)%>" class=fminpt></td>
	</tr>
	<tr valign=top>
		<td class=tdbox width=80>
			模板启用：<br>不勾选则表示不启用</td>
		<td class=tdbox align=left><%
			for TempN = 0 to LMT_TempletFlagDataNum%>	 
			<input type="checkbox" class=fmchkbox name="Limit<%=TempN+1%>" value="1"<%If GetBinarybit(LMT_TempletFlag,TempN+1) = 1 Then
				Response.Write " checked>"
			Else
				Response.Write ">"
			End If%><%=LMT_TempletFlagData(tempN)%><br>
			<%Next%>
			</td>
	</tr><%
			for TempN = 0 to LMT_TempletFlagDataNum%>
	<tr>
		<td class=tdbox><%=LMT_TempletFlagData(tempN)%></td><td class=tdbox><textarea name=Form_TempletString<%=tempN%> rows=6 cols=51 class=fmtxtra><%If Form_TempletString(tempN) <> "" Then Response.Write VbCrLf & Server.htmlEncode(Form_TempletString(tempN))%></textarea></td>
	</tr><%Next%>
	<tr>
		<td class=tdbox>&nbsp;</td>
		<td class=tdbox>
			<input name=action type=hidden value="Modify">
			<input name=submitflag type=hidden value="LKOkxk2">
			<input name=ID type=hidden value="<%=LMT_ID%>">
			<input type=submit value="提交" class=fmbtn> <input type=reset value="取消" class=fmbtn>
		</td>
	</tr>
	</table></form>

<%End Function

Function CheckFormData

	Dim Temp,Rs
	Set Rs = LDExeCute("Select Max(ID) from LeadBBS_Templet",0)
	If Rs.Eof Then
		Form_MaxTempletID = -1
	Else
		Form_MaxTempletID = Rs(0)
		If isNull(Form_MaxTempletID) Then
			Form_MaxTempletID = -1
		Else
			Form_MaxTempletID = cCur(Rs(0))
		End If
	End If

	Dim Temp1,Temp2,TempN
	LMT_TempletFlag = 0
	Temp2 = 1
	For TempN = 0 to LMT_TempletFlagDataNum
		Temp1 = Request("Limit" & TempN+1)
		If Temp1 <> "1" Then Temp1 = "0"
		If Temp1 = "1" Then LMT_TempletFlag = LMT_TempletFlag + cCur(Temp2)
		Temp2 = Temp2*2
	Next

	Form_TempletName = Left(Trim(Request.Form("Form_TempletName")),50)
	For TempN = 0 to LMT_TempletFlagDataNum
		Form_TempletString(TempN) = Trim(Request.Form("Form_TempletString" & TempN))
	Next

	If Form_TempletName = "" or Len(Form_TempletName) > 50 Then
		GBL_CHK_TempStr = GBL_CHK_TempStr & "Error: 模板名称必须填写<br>" & VbCrLf
		CheckFormData = 0
		Exit Function
	End If

	If inStr(LCase(Form_TempletName),"/") or inStr(LCase(Form_TempletName),"\") or inStr(LCase(Form_TempletName),"""") or inStr(LCase(Form_TempletName),"<script") or inStr(LCase(Form_TempletName),"<\script") or inStr(LCase(Form_TempletName),"</script") Then
		GBL_CHK_TempStr = GBL_CHK_TempStr & "Error: 模板名称不能包含有/\""及JS等字符<br>" & VbCrLf
		CheckFormData = 0
		Exit Function
	End If

	For TempN = 0 to LMT_TempletFlagDataNum
		If inStr(LCase(Form_TempletString(TempN)),"<%") > 0 or inStr(LCase(Form_TempletString(TempN)),"include") > 0 or inStr(LCase(Form_TempletString(TempN)),"<script") > 0 or inStr(LCase(Form_TempletString(TempN)),"<\script") > 0 or inStr(LCase(Form_TempletString(TempN)),"</script") > 0 Then
			GBL_CHK_TempStr = GBL_CHK_TempStr & "Error: " & LMT_TempletFlagData(tempN) & "不允许插入js等其它编码！<br>" & VbCrLf
			CheckFormData = 0
			Exit Function
		End If
	Next

	CheckFormData = 1

End Function

Function UpdateTemplet

	Dim SQL,TempN
	If Action = "Join" Then
		SQL = "inSert into LeadBBS_Templet(ID,TempletName,TempletFlag"
		For TempN = 0 to LMT_TempletFlagDataNum
			SQL = SQL & ",TempletString" & TempN
		Next
		SQL = SQL & ") Values("
		SQL = SQL & Form_MaxTempletID + 1 & ",'" & Replace(Form_TempletName,"'","''") & "'," & LMT_TempletFlag

		For TempN = 0 to LMT_TempletFlagDataNum
			SQL = SQL & ",'" & Replace(Form_TempletString(TempN),"'","''") & "'"
		Next
		SQL = SQL & ")"
		CALL LDExeCute(SQL,1)
		LMT_ID = Form_MaxTempletID + 1
	Else
		SQL = "Update LeadBBS_Templet Set TempletFlag=" & LMT_TempletFlag & _
			",TempletName='" & Replace(Form_TempletName,"'","''") & "'"
		For TempN = 0 to LMT_TempletFlagDataNum
			SQL = SQL & ",TempletString" & TempN & "='" & Replace(Form_TempletString(TempN),"'","''") & "'"
		Next
		SQL = SQL & " where ID=" & LMT_ID
		CALL LDExeCute(SQL,1)
	End If
	For TempN = 0 to LMT_TempletFlagDataNum
		If Form_TempletString(TempN) <> "" Then
			WriteTempletFile LMT_ID,TempN,Form_TempletString(TempN)
		Else
			DeleteFiles(Server.Mappath("../../inc/Templet/" & LMT_ID & "_" & TempN & ".JS"))
		End If
	Next
	ReloadTempletStyle(LMT_ID)
	UpdateTemplet = 1

End Function

Sub WriteTempletFile(TempletID,TempN,TempStr)

	ADODB_SaveToFile TempStr,"../../inc/Templet/" & TempletID & "_" & TempN & ".JS"
	If GBL_CHK_TempStr = "" Then
		Response.Write "<div class=alertdone>2.成功完成设置！</div>"
	Else
		%><%=GBL_CHK_TempStr%><br>服务器不支持在线写入文件功能，请使用FTP等功能，将<span Class=redfont><%="inc/Templet/" & TempletID & "_" & TempN & ".JS"%></span>文件替换成框中内容(注意备份)<p>
		<textarea name="fileContent" cols="80" rows="30" class=fmtxtra><%=Server.htmlencode(TempStr)%></textarea><%
		GBL_CHK_TempStr = ""
	End If

End Sub

Sub ReloadTempletStyle(TempletID)

	Dim Rs,GetData,N
	Set Rs = LDExeCute("Select StyleID From LeadBBS_Skin where TempletID=" & TempletID,0)
	If Not Rs.Eof Then
		GetData = Rs.GetRows(-1)
		Rs.Close
		Set Rs = Nothing
		For N = 0 to Ubound(GetData,2)
			ReloadBoardStyleInfo(cCur(GetData(0,N)))
		Next
	Else
		Rs.Close
		Set Rs = Nothing
	End If

End Sub

Rem 检测模板编号ID是否存在
Function CheckTempletIDExist(ID)

	Dim Rs,TempN
	If ID < 0 Then
		CheckTempletIDExist = 1
		Exit Function
	End If
	Set Rs = LDExeCute(sql_select("Select * from LeadBBS_Templet where ID=" & ID,1),0)
	If Rs.Eof Then
		CheckTempletIDExist = 0
	Else
		LMT_TempletFlag = cCur(Rs("TempletFlag"))
		Form_TempletName = Rs("TempletName")
		For TempN = 0 to LMT_TempletFlagDataNum
			Form_TempletString(TempN) = Rs("TempletString" & TempN)
		Next
		CheckTempletIDExist = 1
	End if
	Rs.Close
	Set Rs = Nothing

End Function

Function Manage

	%>
	<script language=javascript>
	function s(ID,TempletName,TempletFlag)
	{
		if(ID=="")return;
		document.write("<tr><td class=tdbox>第" + ID + "模板</td>");
		document.write("<td class=tdbox><a href=TempletManage.asp?action=Modify&ID=" + ID + ">" + TempletName + "</a></td>");
		document.write("<td class=tdbox><a href=TempletManage.asp?action=Modify&ID=" + ID + ">" + TempletFlag + "</a></td>");
		document.write("<td class=tdbox><a href=TempletManage.asp?action=Delete&ID=" + ID + ">删除</a></td></tr>");
	}
	</script>
	
			<div class=frameline><b>论坛模板管理</b></div>
			<table border=0 cellpadding=0 cellspacing=0 width=100% class=frame_table>
			<tbody>
			<tr class=frame_tbhead>
				<td width=60><div class=value>编号</div></td>
				<td><div class=value>名称(修改)</div></td>
				<td><div class=value>状态</div></td>
				<td><div class=value>删除</div></td>
			</tr>
				<%
	Dim Rs,SQL
	SQL = "select ID,TempletName,TempletFlag from LeadBBS_Templet"

	Set Rs = LDExeCute(SQL,0)
	Dim Num
	Dim GetData
	If Not rs.Eof Then
		Response.Write "<script language=javascript>" & VbCrLf & "s("""
		Response.Write Rs.GetString(,,""",""",""");" & VbCrLf & "s(""","")
		%>","","","");
		</script>
		<%
	Else
		Num = -1
	End If
	Rs.close
	Set Rs = Nothing%>
			</table>
	<%

End Function

Function Delete

	Dim ID
	ID = Left(Request("ID"),14)
	If isNumeric(ID) = 0 Then ID = 0
	ID = Fix(cCur(ID))
	If Request.Form("DeleteSuer")="E72ksiOkw2" Then
		If DeleteTemplet(ID) > 0 Then
			Response.Write "<p><font color=008800 class=greenfont><b>已经成功删除编号为" & ID & "的论坛模板！</b></font></p>"
		Else
			Response.Write "<p><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font></p>"
		End If
	Else
		%>
		<form action=TempletManage.asp method=post>
		<div class=frameline>
		<div class=alert>注意：此操作将删除论坛模板</div>
		确认信息： 真的要删除此论坛模板吗？</div>
		
		<input type=hidden name=Action value="Delete">
		<input type=hidden name=ID value="<%=urlencode(ID)%>">
		<input type=hidden name=DeleteSuer value="E72ksiOkw2">
		
		<div class=frameline>
		<input type=submit value=确定删除 class=fmbtn>
		</div>
		</form>
	<%End If

End Function

Function DeleteTemplet(ID)

	GBL_CHK_TempStr = ""
	Dim Rs,BoardID
	Set Rs = LDExeCute(sql_select("select ID from LeadBBS_Templet where ID=" & ID,1),0)
	If Rs.Eof Then
		GBL_CHK_TempStr = "错误，不存在此专题区．"
		DeleteTemplet = 0
		Rs.Close
		Set Rs = Nothing
		Exit Function
	End If
	Rs.Close
	Set Rs = Nothing
	CALL LDExeCute("Delete from LeadBBS_Templet where ID=" & ID,1)
	DeleteTemplet = 1

End Function

Function DeleteFiles(path)

	If DEF_FSOString = "" Then
		Response.Write "<br>服务器不支持FSO，硬盘文件未删除．"
		Exit Function
	End If
    On error resume next
    Dim fs
    Set fs = Server.CreateObject(DEF_FSOString)
	If err <> 0 Then
		Err.Clear
		Response.Write "<br>服务器不支持FSO，硬盘文件未删除．"
		Exit Function
	End If
    If fs.FileExists(path) Then
      fs.DeleteFile path,True
      DeleteFiles = 1
    Else
      DeleteFiles = 0
    End If
    Set fs = Nothing
    Response.Write "<br>删除文件成功．"

End Function         %>