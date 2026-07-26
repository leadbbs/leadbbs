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

Dim LMT_OrderID,LMT_BoardID,LMT_AssortName,LMT_GoodNum
LMT_OrderID = 0
LMT_BoardID = 0
LMT_GoodNum = 0

Dim LMT_ID,Old_Board

Manage_sitehead DEF_SiteNameString & " - 管理员",""

frame_TopInfo
DisplayUserNavigate("论坛版面专区管理")%>
<p><a href=ForumBoardAssort.asp>管理版面专区</a>
<a href=ForumBoardAssort.asp?action=Join>添加版面专区</a>
</p>
<%If GBL_CHK_Flag=1 Then
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
		If isNumeric(LMT_ID) = 0 Then LMT_ID = 0
		LMT_ID = Fix(cCur(LMT_ID))
		If LMT_ID = 0 or CheckParentAssortIDExist(LMT_ID) = 0 Then
			Response.Write "<div class=alert>编辑的专区不存在!</div>" & VbCrLf
			Exit Function
		End If
	End If
	%>
	<b><%
	If Action = "Modify" Then
		Response.Write "编辑"
	Else
		Response.Write "添加"
	End If%>版面专区</b>
	<%
		GBL_CHK_TempStr = ""
		If Request.Form("submitflag")="LKOkxk2" Then
			If CheckFormData=0 Then
				Response.Write "<div class=alert>错误信息：" & GBL_CHK_TempStr & "</div>" & VbCrLf
				DisplayJoinForm
	        		Else
				If UpdateAssort = 0 Then
					Response.Write "<div class=alert>插入出错：" & GBL_CHK_TempStr & "</div>" & VbCrLf
					DisplayJoinForm
				Else
					UpdateCacheData("data_goodassort.asp")
					Response.Write "<div class=alertdone>成功操作!</div>" & VbCrLf
				End If
			End If
		Else
			DisplayJoinForm
		End If

End Function

Function DisplayJoinForm

	If Action = "Modify" Then
		DisplayModifyForm
		Exit Function
	End If%>
	<form action=ForumBoardAssort.asp method=post name=form1 id=form1>
	<table border=0 cellpadding=0 cellspacing=0 width="100%" class=frame_table>
	<tr>
		<td class=tdbox width=120>
			<input name=action type=hidden value="Join">
			<input name=submitflag type=hidden value="LKOkxk2">
			排列序号：</td>
		<td class=tdbox align=left><input name=Form_AssortID size=4 maxlength=4 value="<%=htmlencode(LMT_OrderID)%>" class=fminpt>
			显示在版面分类中的前后顺序，数字越小越靠前</td>
	</tr>
	<tr>
		<td class=tdbox width=80>
			所属版面:</td>
		<td class=tdbox>
			<!-- #include file=../../inc/incHTM/BoardForMoveList.asp -->
		<script>
			var provincebox = document.form1.BoardID2.options,i;
			for(i = 0; i < provincebox.length; i++)
			{
				if(provincebox.options[i].value=="<%=LMT_BoardID%>")
				{provincebox.selectedIndex = i;break;}
			}
		</script>不选择表示整体论坛的专题
		</td>
	</tr>
	<tr>
		<td class=tdbox width=80>
			专区名称：</td>
		<td class=tdbox align=left><input name=LMT_AssortName size=40 maxlength=255 value="<%=htmlencode(LMT_AssortName)%>" class=fminpt>
			<br>允许使用HTML，最长255字</td>
	</tr>
	<tr>
		<td class=tdbox colspan=2>
			<input name=LMT_GoodNum type=hidden value="0">
			<input type=submit value="提交" class=fmbtn> <input type=reset value="取消" class=fmbtn>
		</td>
	</tr>
	</table></form>

<%End Function

Function DisplayModifyForm

	%>
	<form action=ForumBoardAssort.asp method=post name=form1 id=form1>
	<table border=0 cellpadding=0 cellspacing=0 width="100%" class=frame_table>
	<tr>
		<td class=tdbox width=120>
			<input name=action type=hidden value="Modify">
			<input name=submitflag type=hidden value="LKOkxk2">
			<input name=ID type=hidden value="<%=LMT_ID%>">
			排列序号：</td>
		<td class=tdbox align=left><input name=LMT_OrderID size=4 maxlength=4 value="<%=htmlencode(LMT_OrderID)%>" class=fminpt>
			显示在版面分类中的前后顺序，数字越小越靠前</td>
	</tr>	
	<tr>
		<td class=tdbox width=80>
			所属版面:</td>
		<td class=tdbox>
			<!-- #include file=../../inc/incHTM/BoardForMoveList.asp -->
		<script>
			var provincebox = document.form1.BoardID2.options,i;
			for(i = 0; i < provincebox.length; i++)
			{
				if(provincebox.options[i].value=="<%=LMT_BoardID%>")
				{provincebox.selectedIndex = i;break;}
			}
		</script>不选择表示整体论坛的专题
		</td>
	</tr>
	<tr>
		<td class=tdbox width=80>
			专区名称：</td>
		<td class=tdbox align=left><input name=LMT_AssortName size=40 maxlength=255 value="<%=htmlencode(LMT_AssortName)%>" class=fminpt>
			<br>允许使用HTML，最长255字</td>
	</tr>
	<tr>
		<td class=tdbox width=80>
			重新统计：</td>
		<td class=tdbox align=left><input name=LMT_GoodNum type=checkbox value="yes" class=fmchkbox checked>重新统计此专区所拥有的帖子数量</td>
	</tr>
	<tr>
		<td class=tdbox colspan=2>
			<input type=submit value="提交" class=fmbtn> <input type=reset value="取消" class=fmbtn>
		</td>
	</tr>
	</table></form>

<%End Function

Function CheckFormData

	Dim Temp

	LMT_OrderID = Left(Trim(Request.Form("LMT_OrderID")),14)
	If Action = "Join" or Action = "Modify" Then LMT_BoardID = Left(Trim(Request.Form("BoardID2")),14)
	LMT_AssortName = Trim(Request.Form("LMT_AssortName"))

	If isNumeric(LMT_OrderID) = 0 Then LMT_OrderID = 0
	LMT_OrderID = Fix(cCur(LMT_OrderID))
	If LMT_OrderID < 0 Then LMT_OrderID = 0

	If isNumeric(LMT_BoardID) = 0 or LMT_BoardID = "" Then
		LMT_BoardID = 0
		'GBL_CHK_TempStr = "请选择正确的所属版面。<br>" & VbCrLf
		'CheckFormData = 0
		'Exit Function
	End If
	
	LMT_BoardID = Fix(cCur(LMT_BoardID))
	Temp = Application(DEF_MasterCookies & "BoardInfo" & LMT_BoardID)
	If isArray(Temp) = False Then
		ReloadBoardInfo(LMT_BoardID)
		Temp = Application(DEF_MasterCookies & "BoardInfo" & LMT_BoardID)
	End If

	If isArray(Temp) = False Then
		'GBL_CHK_TempStr = "所属版面不存在，请确定是否已经正确选择!<br>" & VbCrLf
		'CheckFormData = 0
		LMT_BoardID = 0
	End If

	If Len(LMT_AssortName) > 255 or LMT_AssortName = "" Then
		GBL_CHK_TempStr = "必须填写专区名字并且不能长于255字。<br>" & VbCrLf
		CheckFormData = 0
		Exit Function
	End If

	If inStr(LCase(LMT_AssortName),"'") > 0 or inStr(LCase(LMT_AssortName),"<script") > 0 or inStr(LCase(LMT_AssortName),"<\script") > 0 or inStr(LCase(LMT_AssortName),"</script") > 0 Then
		GBL_CHK_TempStr = GBL_CHK_TempStr & "Error: 专区名字不允许插入单引号或js等其它编码<br>" & VbCrLf
		CheckFormData = 0
		Exit Function
	End If		

	CheckFormData = 1

End Function

Function UpdateAssort

	If Action = "Join" Then
		LMT_GoodNum = 0
		CALL LDExeCute("inSert into LeadBBS_GoodAssort(OrderID,BoardID,AssortName,GoodNum) Values(" & _
				LMT_OrderID & "," & LMT_BoardID & ",'" & Replace(LMT_AssortName,"'","''") & "'," & LMT_GoodNum & ")",1)
		ReloadTopicAssort(LMT_BoardID)
	Else
		If Request.Form("LMT_GoodNum") <> "" Then
			Dim Rs
			select case DEF_UsedDataBase
			case 0,2:
				Set Rs = LDExeCute("Select count(*) from LeadBBS_Announce where GoodAssort=" & LMT_ID,0)
			case Else
				Set Rs = LDExeCute("Select count(*) from LeadBBS_Topic where GoodAssort=" & LMT_ID,0)
			End select
			If Rs.Eof Then
				LMT_GoodNum = 0
			Else
				LMT_GoodNum = Rs(0)
				If isNull(LMT_GoodNum) Then LMT_GoodNum = 0
				LMT_GoodNum = cCur(LMT_GoodNum)
			End If
			Rs.Close
			Set Rs = Nothing
		End If
		CALL LDExeCute("Update LeadBBS_GoodAssort Set OrderID=" & LMT_OrderID & _
			",AssortName='" & Replace(LMT_AssortName,"'","''") & "'" & _
			",GoodNum=" & LMT_GoodNum & _
			",BoardID=" & LMT_BoardID & _
			" where ID=" & LMT_ID,1)
		ReloadTopicAssort(LMT_BoardID)
		If Old_Board <> LMT_BoardID Then ReloadTopicAssort(Old_Board)
	End If
	UpdateAssort = 1

End Function

Rem 检测专区编号ID是否存在
Function CheckParentAssortIDExist(ID)

	Dim Rs
	If ID = 0 Then
		CheckParentAssortIDExist = 1
		Exit Function
	End If
	Set Rs = LDExeCute(sql_select("Select ID,OrderID,BoardID,AssortName,GoodNum from LeadBBS_GoodAssort where ID=" & ID,1),0)
	If Rs.Eof Then
		CheckParentAssortIDExist = 0
	Else
		LMT_OrderID = cCur(Rs("OrderID"))
		LMT_BoardID = cCur(Rs("BoardID"))
		Old_Board = LMT_BoardID
		LMT_AssortName = Rs("AssortName")
		LMT_GoodNum = cCur(Rs("GoodNum"))
		CheckParentAssortIDExist = 1
	End if
	Rs.Close
	Set Rs = Nothing

End Function

Function Manage

	%>
	<script language=javascript>
	var lastID=0,Count=0,oldBoardID;
	function s(ID,OrderID,BoardID,AssortName,GoodNum,BoardName,OrderID)
	{
		if(ID=="")return;
		if(oldBoardID != BoardID)
		{
			oldBoardID = BoardID;
			if(BoardID==0)BoardName="主专题区";
			document.write("<tr><td class=tdbox colspan=6><b>版面：<a href=<%=DEF_BBS_HomeUrl%>b/b.asp?B=" + BoardID + ">" + BoardName + "</a></td></tr>");
		}
		lastID=ID;
		document.write("<tr class=TBBG9><td class=tdbox>" + ID + "</td>");
		document.write("<td class=tdbox><a href=ForumBoardAssort.asp?action=Modify&ID=" + ID + ">" + AssortName + "</a></td>");
		document.write("<td class=tdbox>" + GoodNum + "</td><td class=tdbox><a href=<%=DEF_BBS_HomeUrl%>b/b.asp?B=" + BoardID + ">" + BoardName + "</a></td>");
		document.write("<td class=tdbox>" + OrderID + "</td>");
		document.write("<td class=tdbox><a href=ForumBoardAssort.asp?action=Delete&ID=" + ID + ">删除</a></td></tr>");
	}
	</script>
	<table border=0 cellpadding=0 cellspacing=0 width="100%" class=frame_table>
			<tr class=frame_tbhead>
				<td width=46><div class=value>编号</td>
				<td><div class=value>专区名称(修改)</div></td>
				<td><div class=value>帖子量</div></td>
				<td><div class=value>所属版面</div></td>
				<td><div class=value>顺序</div></td>
				<td><div class=value>删除</div></td>
			</tr>
				<%
	Dim Rs,SQL
	SQL = "select T1.ID,T1.OrderID,T1.BoardID,T1.AssortName,T1.GoodNum,T2.BoardName,T1.OrderID from LeadBBS_GoodAssort as T1 left join LeadBBS_Boards as T2 on T1.BoardID=T2.BoardID Order by T1.BoardID,T1.OrderID"

	OpenDatabase
	Set Rs = LDExeCute(SQL,0)
	Dim Num
	Dim GetData
	If Not rs.Eof Then
		Response.Write "<script language=javascript>" & VbCrLf & "s('"
		Response.Write Rs.GetString(,,"','","');" & VbCrLf & "s('","")
		%>','','','');
		</script>
		<%
	Else
		Num = -1
	End If
	Rs.close
	Set Rs = Nothing
	closeDataBase%>
	</table>
	<%

End Function

Function Delete

	Dim ID
	ID = Left(Request("ID"),14)
	If isNumeric(ID) = 0 Then ID = 0
	ID = Fix(cCur(ID))
	If Request.Form("DeleteSuer")="E72ksiOkw2" Then
		If DeleteTopicAssort(ID) > 0 Then
			Response.Write "<p><font color=008800 class=greenfont><b>已经成功删除编号为" & ID & "的版面专区！</b></font></p>"
		Else
			UpdateCacheData("data_goodassort.asp")
			Response.Write "<p><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font></p>"
		End If
	Else
		%><p><form action=ForumBoardAssort.asp method=post>
		注意：删除版面专区并不删除一切专区下的帖子信息<br>
		<br><b><font color=ff0000 class=redfont>确认信息： 真的要删除此专区吗？<br><br>
		
		<input type=hidden name=Action value="Delete">
		<input type=hidden name=ID value="<%=urlencode(ID)%>">
		<input type=hidden name=DeleteSuer value="E72ksiOkw2">

		<input type=submit value=确定删除 class=fmbtn>
		</form>
	<%End If

End Function

Function DeleteTopicAssort(ID)

	GBL_CHK_TempStr = ""
	Dim Rs,BoardID
	Set Rs = LDExeCute(sql_select("select ID,AssortName,BoardID from LeadBBS_GoodAssort where ID=" & ID,1),0)
	If Rs.Eof Then
		GBL_CHK_TempStr = "错误，不存在此专题区．"
		DeleteTopicAssort = 0
		Rs.Close
		Set Rs = Nothing
		Exit Function
	Else
		BoardID = cCur(Rs(2))
	End If
	Rs.Close
	Set Rs = Nothing
	CALL LDExeCute("Update LeadBBS_Announce Set GoodAssort=0 where GoodAssort=" & ID,1)
	If DEF_UsedDataBase = 1 Then CALL LDExeCute("Update LeadBBS_Topic Set GoodAssort=0 where GoodAssort=" & ID,1)
	CALL LDExeCute("Delete from LeadBBS_GoodAssort where ID=" & ID,1)
	ReloadTopicAssort(BoardID)
	DeleteTopicAssort = 1

End Function

Sub ReloadTopicAssort(BoardID)

	Dim Rs
	Set Rs = LDExeCute("select ID,AssortName,0,0,0 from LeadBBS_GoodAssort where BoardID=" & BoardID & " Order by BoardID,OrderID ASC",0)
	If Not Rs.Eof Then
		Application.Lock
		Application(DEF_MasterCookies & "BoardInfo" & BoardID & "_TI") = Rs.GetRows(-1)
		Application.UnLock
	Else
		Application.Lock
		Set Application(DEF_MasterCookies & "BoardInfo" & BoardID & "_TI") = Nothing
		Application(DEF_MasterCookies & "BoardInfo" & BoardID & "_TI") = "yes"
		Application.UnLock
	End If
	Rs.Close
	Set Rs = Nothing

End Sub


Function UpdateCacheData(savefile)

		Dim Rs,GetData,Num
		Set Rs = LDExeCute("select T1.ID,T1.BoardID,T1.AssortName,T2.BoardName from LeadBBS_GoodAssort as T1 left join LeadBBS_Boards as T2 on T1.BoardID=T2.BoardID Order by T1.BoardID,T1.OrderID",0)
	
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
			dim oldBD,boardid
			oldbd = -1
			For N = 0 to Num
				boardid = ccur(getdata(1,n))
				if oldbd <> boardid then
					oldbd = boardid
					If N = 0 Then
						TempStr = TempStr & "{" & VbCrLf
					Else
						TempStr = TempStr & ",{" & VbCrLf
					End If
					TempStr = TempStr & "	""id"":0" & "," & VbCrLf
					If boardid=0 then getdata(3,n) = "总专题"
					TempStr = TempStr & "	""text"":""所属版块:" & htmlencode(KillHTMLLabel(getdata(3,n))) & """" & VbCrLf & "}"
				end if
				WriteStr = ""
				WriteStr = WriteStr & KillHTMLLabel(GetData(2,N))
				If StrLength(WriteStr) > 21 Then
					WriteStr = LeftTrue(WriteStr,18) & "..."
				End If	
				
				TempStr = TempStr & ",{" & VbCrLf
				TempStr = TempStr & "	""id"":" & GetData(0,N) & "," & VbCrLf
				TempStr = TempStr & "	""text"":""" & GetData(0,N) & "." & htmlencode(WriteStr) & """" & VbCrLf & "}"
				'GBL_LowClassString = ""
				'GBL_LoopN = 0
				'GetLowClassString_Json GetData(0,n)
				'If GBL_LowClassString <> "" Then TempStr = TempStr & GBL_LowClassString				
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
	
End Function%>