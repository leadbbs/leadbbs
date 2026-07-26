<!-- #include file=../../inc/BBSsetup.asp -->
<!-- #include file=../../inc/Board_Popfun.asp -->
<!-- #include file=../../inc/Upload_Setup.asp -->
<!-- #include file=../inc/bbsmanage_Fun.asp -->
<%
Server.ScriptTimeOut = 6000
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass

Manage_sitehead DEF_SiteNameString & " - 管理员",""

Dim Form_UploadPhotoUrl_Old,Form_UploadPhotoUrl_Now
Form_UploadPhotoUrl_Old = "images/upload/"
Form_UploadPhotoUrl_Now = DEF_BBS_UploadPhotoUrl

If GBL_CHK_Flag = 1 Then
	GBL_CHK_TempStr = ""
	If Request("Form_UploadPhotoUrl_Old") <> "" Then
		Form_UploadPhotoUrl_Old = Replace(Trim(Request("Form_UploadPhotoUrl_Old")),"\","/")
		If Right(Form_UploadPhotoUrl_Old,1) <> "/" Then GBL_CHK_TempStr = "错误，旧上传路径错误，必须使用/作为路径结尾"
		Form_UploadPhotoUrl_Now = Replace(Trim(Request("Form_UploadPhotoUrl_Now")),"\","/")
		If Form_UploadPhotoUrl_Now = "" or Right(Form_UploadPhotoUrl_Now,1) <> "/" Then GBL_CHK_TempStr = "错误，新上传路径错误"
		If Form_UploadPhotoUrl_Now = Form_UploadPhotoUrl_Old Then GBL_CHK_TempStr = "新旧路径一样，无需替换．"
		If StrLength(Form_UploadPhotoUrl_Now) > 150 or StrLength(Form_UploadPhotoUrl_Old) > 150 Then GBL_CHK_TempStr = "路径过长，不能超过150个字符．"
	End If
	If Request("submitflag") = "yes" and GBL_CHK_TempStr = "" then
		If Request("Form_UploadPhotoUrl_Old") <> "" Then
			RepairUploadFaceUrl
		Else
			RepairSite
		End If
	Else
		If Request("Form_UploadPhotoUrl_Old") = "" Then
		%><form action=RepairSite.asp method=post>
			<div class=frametitle>1.默认修复</div>
			<div class=frameline>注意：此功能将完成以下功能：</div>
			<div class=frameline>
				1.重新统计每个版面(包括隐藏版面)的在线人数<br>
				2.重新统计总在线人员<br>
				3.重新统计论坛注册用户数量<br>
				4.重新统计论坛上传附件数量<br>
				5.<span class=bluefont>修复公告内容</span><br>
				6.<span class=bluefont>修复版面专题区</span><br>
			</div>
			<input type="hidden" name="submitflag" value="yes">
			<div class=alert>确认信息： 真的要开始修复上述数据么？</div>
			<div class=frameline>
			<input class=fmchkbox type="checkbox" name="repairFlag" value="yes" checked>选中则自动修复每个版面的在线人数，否则仅作查看
			</div>
			<div class=frameline>
			<input type=submit value="点击开始修复" class=fmbtn>
			</div>
			
			<div class=frameline>
				<a href=../User/ClearOnlineUser.asp>如果需要清除所有的在线人员名单，请点击这里</a>
			</div>
			</form>
		<%End If
			If GBL_CHK_TempStr <> "" Then%>
			<div class=alert><%=GBL_CHK_TempStr%></div><%
			End If%>
			<form action=RepairSite.asp method=post>
			<div class=frametitle>2.上传路径信息修复</div>
			<div class=frameline>
			此功能将完成以下功能：修复用户表中的保存在本地网站的图片路径<br>
			当你的版本为3.14a或旧的版本升级上来，当改变了上传附件路径时，<br>可能会需要此功能进行修复<br>
			</div>
			<input type="hidden" name="submitflag" value="yes">
			<div class=frameline>
			旧上传路径：<input class=fminpt type="text" name="Form_UploadPhotoUrl_Old" maxlength="150" size="30" value="<%=htmlencode(Form_UploadPhotoUrl_Old)%>">
			</div>
			<div class=frameline>
			现上传路径：<input class=fminpt type="text" name="Form_UploadPhotoUrl_Now" maxlength="150" size="30" value="<%=htmlencode(Form_UploadPhotoUrl_Now)%>">
			</div>
			<div class=frameline><span class=note>注意路径指的是相对于论坛根目录的路径．默认存放于images/upload下面</span>
			</div>
			<div class=alert>警告：修复时间可能较长且不可逆，务必确认你填写的信息正确无误！</div>
			<div class=frameline><input class=fmchkbox type="checkbox" name="repairAnnounce" value="yes" checked>选中则额外修复发表帖子中的图片路径</div>
			<div class=frameline><input class=fmchkbox type="checkbox" name="repairUserUnderWrite" value="yes" checked>选中则额外修复用户签名中的图片路径</div>
			
			<div class=frameline>
			<input type=submit value="点击开始修复" class=fmbtn>
			</div>
			<div class=frameline>
				<a href=../User/ClearOnlineUser.asp>如果需要清除所有的在线人员名单，请点击这里</a>
			</div>
			</form>
		<%
	End If
Else
	DisplayLoginForm
End If
closeDataBase
Manage_Sitebottom("none")


Function RepairSite

	Dim repairFlag
	repairFlag = Request("repairFlag")
	If repairFlag <> "yes" Then repairFlag = ""
	Dim Rs
	Dim UploadNum,UserCount
	Response.Write "<br>"
	Set Rs = LDExeCute("select count(*) from LeadBBS_User",0)
	If Rs.Eof Then
		UserCount = 0
	Else
		UserCount = Rs(0)
		If isNull(UserCount) Then UserCount = 0
		UserCount = cCur(UserCount)
	End If
	Rs.Close
	Set Rs = Nothing

	Set Rs = LDExeCute("select count(*) from LeadBBS_Upload",0)
	If Rs.Eof Then
		UploadNum = 0
	Else
		UploadNum = Rs(0)
		If isNull(UploadNum) Then UploadNum = 0
		UploadNum = cCur(UploadNum)
	End If
	Rs.Close
	Set Rs = Nothing

	CALL LDExeCute("Update LeadBBS_SiteInfo Set UserCount=" & UserCount & ",UploadNum=" & UploadNum,1)
	ReloadStatisticData

	Response.Write "<br>注册用户数量及上传文件数量重新统计完成！"
	SetActiveUserCount
	Response.Write "<br>论坛总在线人数重新统计完成．"

	Dim GetData
	Set Rs = LDExeCute("Select BoardID from LeadBBS_Boards",0)
	If Not Rs.Eof Then
		GetData = Rs.GetRows(-1)
		Rs.Close
		Set Rs = Nothing
	Else
		Rs.Close
		Set Rs = Nothing
		Exit Function
	End If
	
	Dim N,m,i
	m = Ubound(GetData,2)
	For N = 0 to m
		Set Rs = LDExeCute("Select count(*) from LeadBBS_OnlineUser Where AtBoardID=" & GetData(0,n),0)
		If Rs.Eof Then
			i = 0
		Else
			i = Rs(0)
			If isNull(i) Then i = 0
			i = cCur(i)
		End If
		Rs.Close
		Set Rs = Nothing
		ReloadBoardInfo(GetData(0,n))
		ReloadTopicAssort(GetData(0,n))
		Response.Write "<br>版面号" & GetData(0,n) & "在线人数，原先" & Application(DEF_MasterCookies & "BDOL" & GetData(0,n)) & "人，实际在线" & i & "人"
		If repairFlag = "yes" then
			Application.Lock
			Application(DEF_MasterCookies & "BDOL" & GetData(0,n)) = i
			Application.UnLock
		End If
	Next
	Response.Write "<p>重新统计版面在线人数完成．．"
	ReloadPubMessageInfo
	Response.Write "<p>修复公告内容完成．"
	If repairFlag <> "yes" then Response.Write "<font color=Red Class=redfont>但并没有重新完成版面在线人数的更新．</font>"

End Function

Sub ReloadTopicAssort(BoardID)

	Dim Rs
	Set Rs = LDExeCute("select ID,AssortName,0,0,0 from LeadBBS_GoodAssort where BoardID=" & BoardID & " Order by BoardID,OrderID",0)
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

Sub RepairUploadFaceUrl

	Dim MyHomeUrl,ReplaceUrl1,ReplaceUrl2,Len1,Len2
	MyHomeUrl = LD_GetUrl(1)
	
	ReplaceUrl1 = MyHomeUrl & Form_UploadPhotoUrl_Old
	ReplaceUrl2 = Replace("../" & Form_UploadPhotoUrl_Old,"//","/")
	Len1 = Len(ReplaceUrl1)
	Len2 = Len(ReplaceUrl2)
	
	Form_UploadPhotoUrl_Now = Replace("../" & Form_UploadPhotoUrl_Now,"//","/")

	Dim UpdateNumber,NoneUpdateNumber
	UpdateNumber = 0
	NoneUpdateNumber = 0
	
	Dim NowID,EndFlag,Temp
	NowID = 0
	EndFlag = 0
	Dim Rs,SQL,GetData,n
	
	Dim RecordCount,CountIndex
	SQL = "Select count(*) from LeadBBS_User where id>" & NowID
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
	
	Application.Lock
	Application("Io_" & GBL_CHK_User) = "start"
	Application.UnLock
	If Request("executepage") = "" Then
	%>
	<div id="errorstr"></div>
	<p style="font-size:9pt" id="bartitle1">下面开始修复用户上传头像路径，共有<%=RecordCount%>个用户待更新

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
			Upl_url = "../BlockUpdate/Io_Info.asp?id=<%=Urlencode(GBL_CHK_User)%>";
			Upl_IOfun = window.setTimeout(Upl_IO,Upl_GetDelay);
		</script>
		<br>
		<iframe src="RepairSite.asp?executepage=yes&submitflag=yes&Form_UploadPhotoUrl_Old=<%=urlencode(Form_UploadPhotoUrl_Old)%>&Form_UploadPhotoUrl_Now=<%=urlencode(Form_UploadPhotoUrl_Now)%>&repairAnnounce=<%=urlencode(Request("repairAnnounce"))%>&repairUserUnderWrite=<%=urlencode(Request("repairUserUnderWrite"))%>" name="infoframe" id="infoframe" hidefocus="" frameborder="no" scrolling="auto" style="margin-top:100px;width:300px;height:150px;">
		<%
			response.Flush
			Exit sub
	end if
	Dim StartTime,SpendTime,RemainTime
	StartTime = Now
		
	Do while EndFlag = 0
		SQL = sql_select("Select ID,FaceUrl from LeadBBS_User where ID>" & NowID & " order by id ASC",1000)
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
			GetData(1,n) = LCase(GetData(1,n))
			If Left(GetData(1,n) & "",Len2) = ReplaceUrl2 Then
				GetData(1,n) = replace(GetData(1,n),ReplaceUrl2,Form_UploadPhotoUrl_Now,1,1,0)
				CALL LDExeCute("Update LeadBBS_User Set FaceUrl='" & Replace(GetData(1,n),"'","''") & "' where ID=" & NowID,1)
			ElseIf Left(GetData(1,n) & "",Len1) = ReplaceUrl1 Then
				GetData(1,n) = replace(GetData(1,n),ReplaceUrl1,Form_UploadPhotoUrl_Now,1,1,0)
				CALL LDExeCute("Update LeadBBS_User Set FaceUrl='" & Replace(GetData(1,n),"'","''") & "' where ID=" & NowID,1)
			Else
				NoneUpdateNumber = NoneUpdateNumber + 1
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
	共更新<%=UpdateNumber%>个用户，<%=NoneUpdateNumber%>个用户无需更新
	<%
	If Request("repairAnnounce") = "yes" Then RepairAnnounceUploadUrl
	If Request("repairUserUnderWrite") = "yes" Then RepairUserUnderWriteUploadUrl
	Application.Contents.Remove("Io_" & GBL_CHK_User)

End Sub

Sub RepairAnnounceUploadUrl

	Dim MyHomeUrl,ReplaceUrl1,ReplaceUrl2,Len1,Len2
	MyHomeUrl = LD_GetUrl(1)
	
	ReplaceUrl1 = MyHomeUrl & Form_UploadPhotoUrl_Old
	ReplaceUrl2 = Replace("../" & Form_UploadPhotoUrl_Old,"//","/")
	Len1 = Len(ReplaceUrl1)
	Len2 = Len(ReplaceUrl2)

	Dim UpdateNumber,NoneUpdateNumber
	UpdateNumber = 0
	NoneUpdateNumber = 0

	Dim NowID,EndFlag,Temp
	NowID = 0
	EndFlag = 0
	Dim Rs,SQL,GetData,n
	
	Dim RecordCount,CountIndex
	SQL = "Select count(*) from LeadBBS_Announce where id>" & NowID
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

	Dim StartTime,SpendTime,RemainTime
	StartTime = Now
	
	response.Flush
	SpendTime = Datediff("s",StartTime,Now)
	RemainTime = RecordCount
	
	dim titlestr
	titlestr = "|下面开始修复帖子中的全部上传目录下的图片路径，共有" & RecordCount & "个帖子待更新"
	Application.Lock
	Application("Io_" & GBL_CHK_User) = "1|0|正在估算时间...|start"	
	Application("Io_" & GBL_CHK_User) = "0|0|" & SpendTime & "|" & RemainTime & "|" & CountIndex & titlestr
	Application.UnLock

	Dim UpdateFlag
	Dim GetData1

	dim re
	set re = New RegExp
	re.Global = True
	re.IgnoreCase = True
	
	Do while EndFlag = 0
		SQL = sql_select("Select ID,Content,HTMLFlag from LeadBBS_Announce where ID>" & NowID & " order by id ASC",100)
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
			GetData1 = GetData(1,n)
			If GetData(2,n) <> 0 Then
				UpdateFlag = 0
				SQL = "Update LeadBBS_Announce Set"
				
				re.Pattern="(" & Replace(ReplaceUrl2,".","\.") & ")"
				GetData(1,n)=re.Replace(GetData(1,n),Form_UploadPhotoUrl_Now)
				
				re.Pattern="(" & Replace(ReplaceUrl1,".","\.") & ")"
				GetData(1,n)=re.Replace(GetData(1,n),Form_UploadPhotoUrl_Now)
				
				If GetData(1,n) <> GetData1 Then
					UpdateFlag = 1
					SQL = SQL & " Content='" & Replace(GetData(1,n),"'","''") & "'"
				End If
	
				SQL = SQL & " where ID=" & NowID
				If UpdateFlag = 1 Then
					CALL LDExeCute(SQL,0)
					UpdateNumber = UpdateNumber + 1
				Else
					NoneUpdateNumber = NoneUpdateNumber + 1
				End If
			Else
				NoneUpdateNumber = NoneUpdateNumber + 1
			End If
			CountIndex = CountIndex + 1
			If (CountIndex mod 100) = 0 Then
				SpendTime = Datediff("s",StartTime,Now)
				RemainTime = SpendTime/CountIndex * (RecordCount-CountIndex)
				Application.Lock
				Application("Io_" & GBL_CHK_User) = Fix((CountIndex/RecordCount) * 400) & "|" & FormatNumber(CountIndex/RecordCount*100,4,-1) & "|" & SpendTime & "|" & RemainTime & "|" & CountIndex & titlestr
				Application.UnLock
			End If
		Next
		If Response.IsClientConnected Then
		Else
			EndFlag = 1
			Application.Contents.Remove("Io_" & GBL_CHK_User)
		End If
	Loop
	Set Re = Nothing
	%>完成
	共更新<%=UpdateNumber%>个帖子，<%=NoneUpdateNumber%>个帖子无需更新
	<%
	

End Sub


Sub RepairUserUnderWriteUploadUrl

	Dim MyHomeUrl,ReplaceUrl1,ReplaceUrl2,Len1,Len2
	MyHomeUrl = LD_GetUrl(1)
	
	ReplaceUrl1 = MyHomeUrl & Form_UploadPhotoUrl_Old
	ReplaceUrl2 = Replace("../" & Form_UploadPhotoUrl_Old,"//","/")
	Len1 = Len(ReplaceUrl1)
	Len2 = Len(ReplaceUrl2)

	Dim UpdateNumber,NoneUpdateNumber
	UpdateNumber = 0
	NoneUpdateNumber = 0

	Dim NowID,EndFlag,Temp
	NowID = 0
	EndFlag = 0
	Dim Rs,SQL,GetData,n
	
	Dim RecordCount,CountIndex
	SQL = "Select count(*) from LeadBBS_User where id>" & NowID
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


	Dim StartTime,SpendTime,RemainTime
	StartTime = Now
	
	response.Flush
	dim titlestr: titlestr = "|下面开始修复用户签名中的全部上传目录下的图片路径，共有" & RecordCount & "个用户签名待更新"
	
	SpendTime = Datediff("s",StartTime,Now)
	RemainTime = RecordCount
	Application.Lock
	Application("Io_" & GBL_CHK_User) = "1|0|正在估算时间...|start"
	Application("Io_" & GBL_CHK_User) = "0|0|" & SpendTime & "|" & RemainTime & "|" & CountIndex & titlestr
	Application.UnLock
	
	Dim UpdateFlag,UpdateFlag2
	Dim GetData1,GetData2
	
	
	dim re
	set re = New RegExp
	re.Global = True
	re.IgnoreCase = True	
	Do while EndFlag = 0
		SQL = sql_select("Select ID,Underwrite,PrintUnderWrite from LeadBBS_User where ID>" & NowID & " order by id ASC",100)
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
			GetData1 = GetData(1,n)
			GetData2 = GetData(2,n)
			UpdateFlag = 0
			UpdateFlag2 = 0
			SQL = "Update LeadBBS_User Set"
			
			re.Pattern="(" & Replace(ReplaceUrl2,".","\.") & ")"
			GetData(1,n)=re.Replace(GetData(1,n),Form_UploadPhotoUrl_Now)
			
			re.Pattern="(" & Replace(ReplaceUrl1,".","\.") & ")"
			GetData(1,n)=re.Replace(GetData(1,n),Form_UploadPhotoUrl_Now)
			
			If GetData(1,n) <> GetData1 Then
				UpdateFlag = 1
				SQL = SQL & " UnderWrite='" & Replace(GetData(1,n),"'","''") & "'"
			End If
			
			
			re.Pattern="(" & Replace(ReplaceUrl2,".","\.") & ")"
			GetData(2,n)=re.Replace(GetData(2,n),Form_UploadPhotoUrl_Now)
			
			re.Pattern="(" & Replace(ReplaceUrl1,".","\.") & ")"
			GetData(2,n)=re.Replace(GetData(2,n),Form_UploadPhotoUrl_Now)
			
			If GetData(2,n) <> GetData2 Then UpdateFlag2 = 1
			
			If UpdateFlag2 = 1 Then
				If UpdateFlag = 0 Then
					SQL = SQL & " PrintUnderWrite='" & Replace(GetData(2,n),"'","''") & "'"
					UpdateFlag = 1
				Else
					SQL = SQL & ",PrintUnderWrite='" & Replace(GetData(2,n),"'","''") & "'"
				End If
			End If
			
			SQL = SQL & " where ID=" & NowID
			
			If StrLength(GetData(2,n)) > 1024 or StrLength(GetData(1,n)) > 255 Then
			Else
				If UpdateFlag = 1 Then
					CALL LDExeCute(SQL,1)
					UpdateNumber = UpdateNumber + 1
				Else
					NoneUpdateNumber = NoneUpdateNumber + 1
				End If
			End If
			CountIndex = CountIndex + 1
			If (CountIndex mod 100) = 0 Then
				SpendTime = Datediff("s",StartTime,Now)
				RemainTime = SpendTime/CountIndex * (RecordCount-CountIndex)
				Application.Lock
				Application("Io_" & GBL_CHK_User) = Fix((CountIndex/RecordCount) * 400) & "|" & FormatNumber(CountIndex/RecordCount*100,4,-1) & "|" & SpendTime & "|" & RemainTime & "|" & CountIndex & titlestr
				Application.UnLock
			End If
		Next
		If Response.IsClientConnected Then
		Else
			EndFlag = 1
			Application.Contents.Remove("Io_" & GBL_CHK_User)
		End If
	Loop
	Set Re = Nothing
	%>完成
	共更新<%=UpdateNumber%>个签名，<%=NoneUpdateNumber%>个用户签名无需更新
	<%
	
	

End Sub
%>