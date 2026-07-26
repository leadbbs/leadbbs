<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../../inc/Ubbcode.asp"-->
<!--#include file="../../inc/Upload_Setup.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<!--#include file="UpdateRootMaxMinAnnounceID.asp"-->
<!--#include file="UpdateUserAnnounce.asp"-->
<!--#include file="DeleteBlankUser.asp"-->

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

Dim GBL_MANAGE_Flag
Manage_sitehead DEF_SiteNameString & " - 管理员",""
initDatabase()
Main()
CloseDatabase()
Manage_Sitebottom("none")

Sub Main

	GBL_MANAGE_Flag = left(Request("flag"),50)
	If CheckSupervisorPass() = 0 or GBL_UserID = 0 Then Exit Sub
	
	Select Case GBL_MANAGE_Flag
		case "underwrite":
			'UpdatePrintUnderWriteColumn
		case "UpdateUserAnnounce"
			UpdateUserAnnounce()
		case "UpdateRootMaxMinAnnounceID"
			BlockUpdate()
		case "DeleteBlankUser"
			DeleteBlank_page()
		case Else
			UpdateContentColumn()
	End select

End Sub

Sub UpdatePrintUnderWriteColumn()

	If Request.Form("SureFlag") <> "E72ksiOkw2" Then
		%>
			<p><form action=UpdateUnderWritePrintColumn.asp method=post>
			<b><font color=ff0000 class=redfont>确定此操作吗?<br>
			<br>
			<input type=hidden name=SureFlag value="E72ksiOkw2">
			<input type=hidden name=flag value="<%=htmlencode(GBL_MANAGE_Flag)%>">
			
			<input type=submit value=确定进行 class=fmbtn>
			</form>
		<%
	Else
		
		Dim NowID,EndFlag
		NowID = 0
		EndFlag = 0
		Dim Rs,SQL
		Set Rs = Server.CreateObject("ADODB.RecordSet")
		Dim WriteString
	
		Dim RecordCount,CountIndex
		SQL = "Select count(*) from LeadBBS_User"
		Set Rs = LDExeCute(SQL,0)
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
		Dim GetData,n
	
		Application.Lock
		Application("Io_" & GBL_CHK_User) = "start"
		Application.UnLock
		If Request("executepage") = "" Then
		%>
		<p style="font-size:9pt">下面开始重新生成用户签名，共有<%=RecordCount%>个用户待更新
	
		<table width="400" cellspacing="0" cellpadding="0" style="border:#006600 1px solid;">
			<tr> 
				<td>
				<td><img src=../pic/progressbar.gif width=0 height=16 id=img1 name=img1 align=middle>
		</td></tr></table> <span id=txt1 name=txt1 style="font-size:9pt">0</span><span style="font-size:9pt">%</span>
		<span id=tm1 name=tm1 style="font-size:9pt">正在估算需要时间...</span>
		<script src="<%=DEF_BBS_HomeUrl%>inc/js/bar.js?ver=<%=DEF_Jer%>" type="text/javascript"></script>
		<script>
			Upl_url = "Io_Info.asp?id=<%=Urlencode(GBL_CHK_User)%>";
			Upl_IOfun = window.setTimeout(Upl_IO,Upl_GetDelay);
		</script>
		<br>
		<iframe src="UpdateUnderWritePrintColumn.asp?executepage=yes&SureFlag=E72ksiOkw2" name="infoframe" id="infoframe" hidefocus="" frameborder="no" scrolling="auto" style="margin-top:100px;width:300px;height:150px;">
		<%
			Response.Flush
			Exit sub
		end if
		
		Dim StartTime,SpendTime,RemainTime
		StartTime = Now
		Do while EndFlag = 0
			SQL = sql_select("Select ID,UnderWrite from LeadBBS_User where ID>" & NowID & " order by id ASC",100)
			Set Rs = LDExeCute(SQL,0)
			If Rs.Eof Then
				EndFlag = 1
				Rs.Close
				Set Rs = Nothing
				Exit do
			Else
				GetData = Rs.GetRows(-1)
				Rs.Close
				Set Rs = Nothing
			End If
			For n = 0 to Ubound(GetData,2)
				NowID = GetData(0,n)
				WriteString = UBB_Code_UnderWrite(GetData(1,n))
				If StrLength(WriteString) > 1024 Then
					WriteString = ""
				End If
				CALL LDExeCute("Update LeadBBS_User Set PrintUnderWrite='" & Replace(WriteString,"'","''") & "' where id=" & GetData(0,n),1)
	
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
		%>完成
		<%Application.Contents.Remove("Io_" & GBL_CHK_User)
		
	End If

End Sub

Function ResumeCode(Tstr)

	Dim str
	str = Tstr
	Str = Replace(str," &nbsp; &nbsp; &nbsp;",chr(9))
	Str = Replace(str,"<br>" & "&nbsp;",VbCrLf & " ")
	Str = Replace(str,"<br>" & "&nbsp;",VbCrLf & " ")
	Str = Replace(str,"<br>" & VbCrLf,VbCrLf)
	Str = Replace(str,"<br>" & VbCrLf,VbCrLf)
	Str = Replace(str,"<br>",VbCrLf)
	Str = Replace(str,"<br>",VbCrLf)
	Str = Replace(str,"&nbsp;"," ")
	str = Replace(str,"&gt;",">")
	Str = Replace(str,"&lt;","<")
	Str = Replace(str,"&quot;","""")
	ResumeCode = Str

End Function

Sub UpdateContentColumn()

	Dim Str1,Str2,IndexN
	Str1 = Request("Str1")
	Str2 = Request("Str2")
	IndexN = Request("IndexN")
	If isNumeric(IndexN) = 0 Then IndexN = 0
	IndexN = Fix(cCur(IndexN))
	
	'check str1 str2
	GBL_CHK_TempStr = ""
	If Len(Str1) < 5 and Str1 <> "" Then
		GBL_CHK_TempStr = "为避免无谓的错误替换，要求被替换的字符串必须长于5个字"
	End If
	
	If Str1 = "" Then
		GBL_CHK_TempStr = GBL_CHK_TempStr & "错误，未填写 要替换的字符串."
	End If

	If Request("SureFlag") <> "E72ksiOkw2" or GBL_CHK_TempStr <> "" Then
		%>
			<p><font color=red><b><%=GBL_CHK_TempStr%></b></font></p>
			以下操作将批量替换帖子内容
			<p>
			此操作主要用来批量替换一些网址改变，或是路径变换，注意尽量将需要替换的字符串和目标字符串填写复杂，避免无关内容被替换
			<br><b>
			<font color=blue>为避免无谓的数据牺牲（比如你意外替换错误），建议先备份数据库再进行此操作</font></b>
			<p><form action=UpdateUnderWritePrintColumn.asp method=post>
			要替换的字符串：<input maxlength=255 name=Str1 value="<%=htmlencode(Str1)%>" size="40" class=fminpt><br>
			替换成的目标字符串：<input maxlength=255 name=Str2 value="<%=htmlencode(Str2)%>" size="40" class=fminpt><br>
			<br><b><font color=ff0000 class=redfont>此操作依数据量可能需要非常长的时间，确定此操作吗?<br>
			<br>
			<input type=hidden name=SureFlag value="E72ksiOkw2">
			<input type=hidden name=Flag value="content">
			
			<input type=submit value=确定进行 class=fmbtn>
			</form>
		<%
	Else
		Dim NowID,EndFlag
		NowID = 0
		EndFlag = 0
		Dim Rs,SQL,GetData,n
		Dim Content,NewContent
	
		Dim RecordCount,CountIndex
		SQL = "Select count(*) from LeadBBS_Announce"
		Set Rs = LDExeCute(SQL,0)
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
		Dim ReplaceNum
		ReplaceNum = 0

		If Request("executepage") = "" Then
		%>
		<p style="font-size:9pt">下面将替换帖子内容带有<u><%=htmlencode(Str1)%></u>的字串替换为<%=htmlencode(Str2)%>，共有<%=RecordCount%>个帖子待更新
	
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
		<iframe src="UpdateUnderWritePrintColumn.asp?executepage=yes&SureFlag=E72ksiOkw2&flag=<%=urlencode(GBL_MANAGE_Flag)%>&Str1=<%=urlencode(Str1)%>&Str2=<%=urlencode(Str2)%>" name="infoframe" id="infoframe" hidefocus="" frameborder="no" scrolling="auto" style="margin-top:100px;width:300px;height:150px;">
		<%
			response.Flush
			Application.Lock
			Application("Io_" & GBL_CHK_User) = "start"
			Application.UnLock
			Exit sub
		End If
		
		Dim StartTime,SpendTime,RemainTime
		StartTime = Now
		Do while EndFlag = 0
			SQL = sql_select("Select ID,Content from LeadBBS_Announce where ID>" & NowID & " order by id ASC",100)
			Set Rs = LDExeCute(SQL,0)
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
				Content = GetData(1,n)
				If inStr(Content,Str1) Then
					NewContent = Replace(Content,Str1,Str2)
					If NewContent <> Content Then
						CALL LDExeCute("Update LeadBBS_Announce Set Content='" & Replace(NewContent,"'","''") & "' where id=" & NowID,1)
						ReplaceNum = ReplaceNum + 1
					End If
				End If

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
		%>完成
		总共替换<%=ReplaceNum%>个
		<%Application.Contents.Remove("Io_" & GBL_CHK_User)
		
	End If

End Sub
%>