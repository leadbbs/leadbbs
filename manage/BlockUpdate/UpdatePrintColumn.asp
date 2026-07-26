<!-- #include file=../../inc/BBSsetup.asp -->
<!-- #include file=../../inc/Board_Popfun.asp -->
<!-- #include file=../../inc/Ubbcode.asp -->
<!-- #include file=../inc/bbsmanage_Fun.asp -->
<%
DEF_BBS_HomeUrl = "../../"
server.scripttimeout=99999
Rem 更新论坛UBB编码
Rem 当论坛采用新的UBB编号码,原来的UBB文章可以重新转换格式．
Rem -------------------------------------------------------
Rem ------------当你的UBB编码更改或过漏文字更改后----------
Rem ------------需要立即生效，请用此文件更新---------------
Rem ------------更新时间漫长，建立先到后台关闭论坛---------
Rem -------------------------------------------------------
Manage_sitehead DEF_SiteNameString & " - 管理员",""
initDatabase
UpdatePrintContentColumn
CloseDatabase
Manage_Sitebottom("none")

Function ResumeCode(Tstr)

	Dim str
	str = Tstr
	str = Replace(str,"&gt;",">")
	Str = Replace(str,"&lt;","<")
	Str = Replace(str,"&quot;","""")
	Str = Replace(str," &nbsp; &nbsp; &nbsp;",chr(9))
	Str = Replace(str,"<br>" & "&nbsp;",VbCrLf & " ")
	Str = Replace(str,"<br>" & VbCrLf,VbCrLf)
	Str = Replace(str,"&nbsp;"," ")
	ResumeCode = Str

End Function

Function UpdatePrintContentColumn()

	If CheckSupervisorUserName = 0 or GBL_UserID = 0 Then Exit Function
	If Request.Form("SureFlag") <> "E72ksiOkw2" Then
		%>
			<p><form action=UpdatePrintColumn.asp method=post>
			<b><font color=ff0000 class=RedFont>确定此操作吗?<br>
			<br>
			<input type=hidden name=SureFlag value="E72ksiOkw2">
			
			<input type=submit value=确定进行 class=fmbtn>
			</form>
		<%
	Else
		If Request("executepage") = "" Then
			%>
		<p style="font-size:9pt">下面根据新的UBB编码重新生成帖子内容，共有<%=RecordCount%>个帖子待更新
	
		<table width="400" border="0" cellspacing="1" cellpadding="1">
			<tr> 
				<td bgcolor=000000>
		<table width="400" border="0" cellspacing="0" cellpadding="1">
			<tr> 
				<td bgcolor=ffffff height=9><img src=../pic/progressbar.gif width=0 height=16 id=img1 name=img1 align=middle></td></tr></table>
		</td></tr></table> <span id=txt1 name=txt1 style="font-size:9pt">0</span><span style="font-size:9pt">%</span>
		<span id=tm1 name=tm1 style="font-size:9pt">正在估算需要时间...</span>
		<script src="<%=DEF_BBS_HomeUrl%>inc/js/bar.js?ver=<%=DEF_Jer%>" type="text/javascript"></script>
		<script>
			Upl_url = "Io_Info.asp?id=<%=Urlencode(GBL_CHK_User)%>";
			Upl_IOfun = window.setTimeout(Upl_IO,Upl_GetDelay);
		</script>
		<br>
		<iframe src="UpdatePrintColumn.asp?executepage=yes&SureFlag=E72ksiOkw2" name="infoframe" id="infoframe" hidefocus="" frameborder="no" scrolling="auto" style="margin-top:100px;width:300px;height:150px;">
		<%
			response.Flush
			Application.Lock
			Application("Io_" & GBL_CHK_User) = "start"
			Application.UnLock
			Exit Function
		End If
		Dim NowID,EndFlag
		NowID = 0
		EndFlag = 0
		Dim Rs,SQL,GetData,n
		Dim PrintContent,Content,HtmlFlag
	
		Dim RecordCount,CountIndex
		SQL = "Select count(*) from LeadBBS_Announce"
		Set Rs = Con.ExeCute(SQL)
		If Rs.Eof Then
			RecordCount = 0
		Else
			RecordCount = Rs(0)
			If isNull(RecordCount) Then RecordCount = 0
			RecordCount = ccur(RecordCount)
		End If
		Rs.Close
		Set Rs = Nothing
		If RecordCount < 1 Then RecordCount = 1
		CountIndex = 0
		
		Dim StartTime,SpendTime,RemainTime
		StartTime = Now
		Do while EndFlag = 0
			SQL = sql_select("Select ID,htmlflag,PrintContent,Content from LeadBBS_Announce where ID>" & NowID & " order by id ASC",10)
			Set Rs = Con.ExeCute(SQL)
			GBL_DBNum = GBL_DBNum + 1
			If Rs.Eof Then
				EndFlag = 1
				Rs.Close
				Set Rs = Nothing
				Exit Do
			Else
				GetData = Rs.GetRows(-1)
				Rs.Close
				Set Rs = Nothing
			End If
			For N = 0 to Ubound(GetData,2)
				NowID = GetData(0,n)
				'response.Write NowID & " "
				HtmlFlag = GetData(1,n)
				Select Case HtmlFlag
					Case 1: Content = GetData(2,n)
					Case 2: Content = GetData(3,n)
							If Content = "" and GetData(2,n) <> "" Then Content = GetData(2,n)
					Case 3: Content = ResumeCode(GetData(2,n))
							HtmlFlag = 2
					Case 0: Content = ResumeCode(GetData(2,n))
					Case Else: Content = ResumeCode(GetData(2,n))
				End Select
				
				If HtmlFlag = 2 Then
					PrintContent = Ubb_code(Content)
					If PrintContent = UBB_FiltrateBadWords(PrintTrueText(Content)) Then
						HtmlFlag = 3
						Content = ""
					End If
				ElseIf HtmlFlag = 1 and CheckSupervisorUserName = 1 and GBL_UserID > 0 Then
					PrintContent = Content
					Content = ""
				Else
					PrintContent = UBB_FiltrateBadWords(PrintTrueText(Content))
					Content = ""
				End If
				Con.ExeCute("Update LeadBBS_Announce Set HtmlFlag=" & HtmlFlag & ",Content='" & Replace(Content,"'","''") & "',PrintContent='" & Replace(PrintContent,"'","''") & "' where id=" & NowID)
	
				CountIndex = CountIndex + 1
				If (CountIndex mod 100) = 0 Then
					SpendTime = Datediff("s",StartTime,Now)
					RemainTime = SpendTime/CountIndex * (RecordCount-CountIndex)
					Application.Lock
					Application("Io_" & GBL_CHK_User) = Fix((CountIndex/RecordCount) * 400) & "|" & FormatNumber(CountIndex/RecordCount*100,4,-1) & "|" & SpendTime & "|" & RemainTime & "|" & CountIndex
					Application.UnLock
				End If
			Next
			If Response.IsClientConnected Then
			Else
				EndFlag = 1
				Application.Contents.Remove("Io_" & GBL_CHK_User)
			End If
		Loop
		%>
		完成
		<%Application.Contents.Remove("Io_" & GBL_CHK_User)
		application.contents.removeall
	End If

End Function
%>