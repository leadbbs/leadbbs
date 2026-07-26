<!--#include file="../../inc/Constellation2.asp"-->
<%
	
Sub BlockUpdate
	
	If CheckSupervisorPass() = 0 or GBL_UserID = 0 Then Exit Sub
	
	Dim BlockType
	BlockType = Left(Request("BlockType"),1)
	
	Dim titlestr
	Select Case BlockType
		Case "2":
			titlestr = "版面主题重新排序"
		Case "3":
			titlestr = "重新生成所有用户的农历生日"
		Case "4":
			titlestr = "生成SiteMap"
		Case Else
			BlockType = "1"
			titlestr = "修复所有主题帖子"
	End Select
	
	Dim ID
	ID = Left(Request("ID"),12)
	If isNumeric(ID) = 0 Then ID=0
	

	If Request("SureFlag") <> "E72ksiOkw2" Then
		%>
			<p><form action=UpdateUnderWritePrintColumn.asp method=post>
			<b><span class=redfont>此操作将<u><%=titlestr%></u>，确定此操作吗?</span></b><br>
			<br>
			<input type=hidden name=SureFlag value="E72ksiOkw2">
			<input type=hidden name=BlockType value="<%=BlockType%>">
			<input type=hidden name=ID value="<%=htmlencode(ID)%>">
			<input type=hidden name=flag value="<%=htmlencode(GBL_MANAGE_Flag)%>">
			<br>
			<input type=submit value=确定进行 class=fmbtn><br />
			</form>
			</p>
			
		<%
	Else
		If Request("executepage") = "" Then
		%>
		<p style="font-size:9pt">下面开始处理数据(<u><%=titlestr%></u>)。。。
	
		<table width="400" cellspacing="0" cellpadding="0" style="border:#006600 1px solid;margin:2px 1px 6px 1px;">
			<tr> 
				<td><img src=../pic/progressbar.gif width=0 height=16 id=img1 name=img1 align=middle>
		</td></tr></table> <span id=txt1 name=txt1 style="font-size:9pt">0</span><span style="font-size:9pt">%</span>
		<span id=tm1 name=tm1 style="font-size:9pt">正在估算需要时间...</span>
		<script src="<%=DEF_BBS_HomeUrl%>inc/js/bar.js?ver=<%=DEF_Jer%>" type="text/javascript"></script>
		<script>
			Upl_url = "Io_Info.asp?id=<%=Urlencode(GBL_CHK_User)%>";
			Upl_IOfun = window.setTimeout(Upl_IO,Upl_GetDelay);
		</script>
		<br>
		<iframe src="UpdateUnderWritePrintColumn.asp?executepage=yes&SureFlag=E72ksiOkw2&flag=<%=urlencode(GBL_MANAGE_Flag)%>&BlockType=<%=BlockType%>&id=<%=ID%>" name="infoframe" id="infoframe" hidefocus="" frameborder="no" scrolling="auto" style="margin-top:100px;width:300px;height:150px;">
		<%
			Application.Lock
			Application("Io_" & GBL_CHK_User) = "start"
			Application.UnLock
			Exit Sub
		End If
		Select Case BlockType
			Case "2":
				UpdateBoardData()
			Case "3":
				UpdateNongLi()
			Case "4":
				UpdateSiteMap()
			Case Else
				UpdateRootMaxMinAnnounceID()
		End Select
	End If

End Sub

Sub UpdateRootMaxMinAnnounceID

	Dim StartTime,SpendTime,RemainTime
	Dim TempAT,T
	Dim NowID,EndFlag,SQL,Rs
	NowID = 0
	EndFlag = 0
		
	Dim RootMaxID,RootMinID,ChildNum
	Dim N,GetData
	
	Dim RecordCount,CountIndex
	select case DEF_UsedDataBase
		case 0,2:
			SQL = "Select count(*) from LeadBBS_Announce where parentID=0"
		case Else
			SQL = "Select count(*) from [LeadBBS_Topic]"
	End select
	
	Con.CommandTimeout = 600
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
	
	StartTime = Now
	Dim U_MaxID,U_LastInfo,RootIDBak
	
	Application("Io_" & GBL_CHK_User) = "start"
	Do while EndFlag = 0
		select case DEF_UsedDataBase
		case 0,2:
			SQL = sql_select("Select ID,RootIDBak,BoardID,ChildNum,TopicType from LeadBBS_Announce where ParentID=0 and RootIDBak>" & NowID & " order by ID ASC",100)
		case Else
			SQL = sql_select("Select ID,ID as id_dup2,BoardID,ChildNum,TopicType from LeadBBS_Topic where ID>" & NowID & " order by ID ASC",100)
		End select
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
			If GetData(4,n) <> 39 Then '镜像无需修复
			'If cCur(GetData(3,n)) > 0 Then
				RootIDBak = cCur(GetData(1,n))
				select case DEF_UsedDataBase
				case 0:
					SQL = "select ID,Title from LeadBBS_Announce where ID=(select max(ID) from LeadBBS_Announce where RootIDBak=" & GetData(1,n) & ")"
					Set Rs = LDExeCute(SQL,0)
					If Rs.Eof Then
						U_LastInfo = ""
					Else
						U_MaxID = cCur(Rs(0))
						If RootMaxID = cCur(GetData(1,n)) Then
							U_LastInfo = ""
						Else
							U_LastInfo = LeftTrue(Rs(1),50)
						End If
						If Lcase(Left(U_LastInfo,3)) = "re:" Then U_LastInfo = Mid(U_LastInfo,4)
					End If
					Rs.Close
					Set Rs = Nothing
					CALL LDExeCute("Update LeadBBS_Announce set RootMaxID=" & U_MaxID &_
						",RootMinID=(select min(ID) from LeadBBS_Announce where RootIDBak=" & GetData(1,n) & "),LastInfo='" & Replace(U_LastInfo,"'","''") & "'" &_
						" where ID=" & GetData(0,n),1)

				case 2:
					SQL = "select ID,Title from LeadBBS_Announce where ID=(select t.id from(select max(ID) as id from LeadBBS_Announce where RootIDBak=" & GetData(1,n) & ") as t)"
					Set Rs = LDExeCute(SQL,0)
					If Rs.Eof Then
						U_LastInfo = ""
					Else
						U_MaxID = cCur(Rs(0))
						If RootMaxID = cCur(GetData(1,n)) Then
							U_LastInfo = ""
						Else
							U_LastInfo = LeftTrue(Rs(1),50)
						End If
						If Lcase(Left(U_LastInfo,3)) = "re:" Then U_LastInfo = Mid(U_LastInfo,4)
					End If
					Rs.Close
					Set Rs = Nothing
					CALL LDExeCute("Update LeadBBS_Announce set RootMaxID=" & U_MaxID &_
						",RootMinID=(select t.id from(select min(ID) as id from LeadBBS_Announce where RootIDBak=" & GetData(1,n) & ") as t),LastInfo='" & Replace(U_LastInfo,"'","''") & "'" &_
						" where ID=" & GetData(0,n),1)
				case Else
					SQL = "select max(ID) from LeadBBS_Announce where RootIDBak=" & GetData(1,n)
					Set Rs = LDExeCute(SQL,0)
					If Not Rs.Eof Then
						RootMaxID = Rs(0)
						If IsNull(RootMaxID) then RootMaxID = GetData(1,n)
					Else
						RootMaxID = GetData(1,n)
					End if
					Rs.Close
					Set Rs = Nothing
					
					SQL = "select ID,Title from LeadBBS_Announce where ID=" & RootMaxID
					Set Rs = LDExeCute(SQL,0)
					If Rs.Eof Then
						U_LastInfo = ""
					Else
						U_MaxID = cCur(Rs(0))
						If RootMaxID = RootIDBak Then
							U_LastInfo = ""
						Else
							U_LastInfo = LeftTrue(Rs(1),50)
						End If
						If Lcase(Left(U_LastInfo,3)) = "re:" Then U_LastInfo = Mid(U_LastInfo,3)
					End If
					Rs.Close
					Set Rs = Nothing
							SQL = "select Min(ID) from LeadBBS_Announce where RootIDBak=" & GetData(1,n)
					Set Rs = LDExeCute(SQL,0)
					If Not Rs.Eof Then
						RootMinID = Rs(0)
						If IsNull(RootMinID) then RootMinID = GetData(1,n)
					Else
						RootMinID = GetData(1,n)
					End if
					Rs.Close
					Set Rs = Nothing
					
					SQL = "select count(*) from LeadBBS_Announce where RootIDBak=" & GetData(1,n)
					Set Rs = LDExeCute(SQL,0)
					If Not Rs.Eof Then
						ChildNum = Rs(0)
						If IsNull(ChildNum) then ChildNum = 0
						ChildNum = ccur(ChildNum)
					Else
						ChildNum = 0
					End if
					Rs.Close
					Set Rs = Nothing
					If ChildNum > 0 Then ChildNum = ChildNum - 1
					CALL LDExeCute("Update LeadBBS_Announce set ChildNum=" & ChildNum & ",RootMaxID=" & RootMaxID &_
						",RootMinID=" & RootMinID &_
						",LastInfo='" & Replace(U_LastInfo,"'","''") & "'" &_
						" where ID=" & GetData(0,n),1)
					CALL LDExeCute("Update LeadBBS_Topic set ChildNum=" & ChildNum & ",RootMaxID=" & RootMaxID &_
						",RootMinID=" & RootMinID &_
						",LastInfo='" & Replace(U_LastInfo,"'","''") & "'" &_
						" where ID=" & GetData(0,n),1)
				End select
			'Else
			'	CALL LDExeCute("Update LeadBBS_Announce set ChildNum=0,RootMaxID=" & GetData(0,n) &_
			'			",RootMinID=" & GetData(0,n) & _
			'			" where ID=" & GetData(0,n),1)
			'End If
			End If
			NowID = GetData(1,n)
			CountIndex = CountIndex + 1
			
			If (CountIndex mod 100) = 0 or CountIndex < 2 Then
				SpendTime = Datediff("s",StartTime,Now)
				RemainTime = SpendTime/CountIndex * (RecordCount-CountIndex)
				'Response.Flush
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
	<%
	Application.Contents.Remove("Io_" & GBL_CHK_User)
	application.contents.removeall

End Sub


Sub UpdateSiteMap

	Dim StartTime,SpendTime,RemainTime
	Dim TempAT,T
	Dim NowID,EndFlag,SQL,Rs
	NowID = 0
	EndFlag = 0
		
	Dim RootMaxID,RootMinID
	Dim N,GetData
	
	Dim RecordCount,CountIndex
	select case DEF_UsedDataBase
		case 0,2:
			SQL = "Select count(*) from LeadBBS_Announce where parentID=0"
		case Else
			SQL = "Select count(*) from [LeadBBS_Topic]"
	End select
	
	Con.CommandTimeout = 600
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
	
	StartTime = Now
	Dim U_MaxID,U_LastInfo,RootIDBak
	
	Application("Io_" & GBL_CHK_User) = "start"
	
	dim fileLen : fileLen = 100
	dim fileIndex : fileIndex = 1
	dim fileName
	
	dim childNum,MaxPage,JN,url
	
	dim ForumPass,BoardLimit,OtherLimit,HiddenFlag,BoardID,A_ID
	
	dim MaxFileLen : MaxFileLen = 1024*1024*9
	
	Dim InstallDir
	' LD_GetUrl(1) already ends with DEF_InstallDir, which is "/" when the forum is served from
	' the web root (§14) — and every use below appends another "/", so every <loc> came out as
	' http://host//a/a.asp… Trim the trailing slash so the generated sitemap holds real URLs.
	InstallDir = LD_GetUrl(1)
	Do While Right(InstallDir,1) = "/"
		InstallDir = Left(InstallDir,Len(InstallDir)-1)
	Loop

	dim mapHead	
	mapHead = "<?xml version=""1.0"" encoding=""UTF-8""?>" & VbCrLf
	mapHead = mapHead & "<urlset xmlns=""http://www.sitemaps.org/schemas/sitemap/0.9"">" & VbCrLf
	
	fileLen = fileLen + len(mapHead)
	
	Dim MaxUrlIndex : MaxUrlIndex = 45000
	Dim UrlIndex : UrlIndex = 1
	
	dim MapEnd
	MapEnd = "</urlset>"
	
	Dim recordStr
	
	'On Error Resume Next
	dim fs,FSO
	Set fs =Server.CreateObject(DEF_FSOString)
	fileName = "../../sitemap_" & fileIndex & ".xml"
	Set FSO = fs.OpenTextFile(server.Mappath(fileName),2,true)
	FSO.WriteLine(mapHead) 
	FSO.close
	set fs=nothing
	if err then
		Response.Write "<br>生成SiteMap中途遇到了错误：" & err.description & "</b>"
		err.clear
		EndFlag = 1
		Exit Sub
	End If
	
	Set fs =Server.CreateObject(DEF_FSOString)
	fileName = "../../sitemap_" & fileIndex & ".xml"
	Set FSO = fs.OpenTextFile(server.Mappath(fileName),8,true)
	
	Do while EndFlag = 0
		select case DEF_UsedDataBase
		case 0,2:
			SQL = sql_select("Select t1.ID,t1.BoardID,t1.ChildNum,t1.TopicType,t2.ForumPass,t2.BoardLimit,t2.OtherLimit,t2.HiddenFlag,T1.LastTime from LeadBBS_Announce as t1 left join leadbbs_boards as t2 on t1.boardid=t2.boardid where t1.ParentID=0 and t1.rootidbak>" & NowID & " order by t1.rootidbak ASC",100)
		case Else
			SQL = sql_select("Select t1.ID,t1.BoardID,t1.ChildNum,t1.TopicType,t2.ForumPass,t2.BoardLimit,t2.OtherLimit,t2.HiddenFlag,T1.LastTime from LeadBBS_Topic as t1 left join leadbbs_boards as t2 on t1.boardid=t2.boardid where t1.ID>" & NowID & " order by t1.ID ASC",100)
		End select
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
		Dim rTime,freq,timediff
		For N = 0 to Ubound(GetData,2)
			childNum = ccur(GetData(2,N))
			ForumPass = GetData(4,N)
			BoardLimit = ccur(GetData(5,N))
			OtherLimit = ccur(GetData(6,N))
			HiddenFlag = ccur(GetData(7,N))
			BoardID = ccur(GetData(1,N))
			A_ID = LngStr(GetData(0,N))
			If GBL_CheckLimitTitle(ForumPass,BoardLimit,OtherLimit,HiddenFlag) = 1 Then
			else
				MaxPage = Fix(childNum / DEF_TopicContentMaxListNum)
				If (childNum mod DEF_TopicContentMaxListNum)<>0 Then MaxPage = MaxPage + 1
				if MaxPage < 1 then MaxPage = 1
				for JN = 1 to MaxPage
					if LMT_EnableRewrite = 1 then
						url = InstallDir & "/a/topic-" & BoardID & "-" & A_ID & "-" & JN & ".html"
					else
						url = InstallDir & "/a/a.asp?b=" & BoardID & "&amp;id=" & A_ID & "&amp;Aq=" & JN
					end if
					recordStr = " <url>" & VbCrLf
					recordStr = recordStr & "  <loc>" & url & "</loc>" & VbCrLf
					rTime = RestoreTime(GetData(8,N))
					timediff = DateDiff("d",rTime,DEF_Now)
					if timediff < 2 then
						freq = "always"
					elseif timediff < 4 then
						freq = "hourly"
					elseif timediff < 7 then
						freq = "daily"
					elseif timediff < 90 then
						freq = "weekly"
					elseif timediff < 1000 then
						freq = "monthly"
					else
						freq = "yearly"
					end if
					recordStr = recordStr & "  <lastmod>" & left(rTime,10) & "</lastmod>" & VbCrLf
					recordStr = recordStr & "  <changefreq>" & freq & "</changefreq>" & VbCrLf
					recordStr = recordStr & "  <priority>1.0</priority>" & VbCrLf
					recordStr = recordStr & " </url>" & VbCrLf
					fileLen = fileLen + len(recordStr)
					UrlIndex = UrlIndex + 1
					
					if fileLen > MaxFileLen or UrlIndex > MaxUrlIndex then
						fileLen = 100
						UrlIndex = 1
						FSO.WriteLine(mapEnd)
						FSO.close
						set fs=nothing
						
						fileIndex = fileIndex + 1
						Set fs =Server.CreateObject(DEF_FSOString)
						fileName = "../../sitemap_" & fileIndex & ".xml"
						Set FSO = fs.OpenTextFile(server.Mappath(fileName),2,true)
						FSO.WriteLine(mapHead) 
						FSO.close
						set fs=nothing
						if err then
							Response.Write "<br>生成SiteMap中途遇到了错误：" & err.description & "</b>"
							err.clear
							Exit do
						End If

						Set fs =Server.CreateObject(DEF_FSOString)
						fileName = "../../sitemap_" & fileIndex & ".xml"
						Set FSO = fs.OpenTextFile(server.Mappath(fileName),8,true)
						FSO.WriteLine(recordStr)
					else
						FSO.WriteLine(recordStr)
					end if
				Next
			end if
			
			NowID = GetData(0,n)
			CountIndex = CountIndex + 1
			
			If (CountIndex mod 100) = 0 or CountIndex < 2 Then
				SpendTime = Datediff("s",StartTime,Now)
				RemainTime = SpendTime/CountIndex * (RecordCount-CountIndex)
				'Response.Flush
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
	FSO.WriteLine(mapEnd)
	FSO.close
	set fs=nothing

	dim MD : MD = ""
	MD = "<?xml version=""1.0"" encoding=""UTF-8""?>" & VbCrLf
	MD = MD & "<sitemapindex xmlns=""http://www.sitemaps.org/schemas/sitemap/0.9"">" & VbCrLf
	for N = 1 to fileIndex
		MD = MD & " <sitemap>" & VbCrLf
      MD = MD & "  <loc>" & InstallDir & "/sitemap_" & N & ".xml</loc>" & VbCrLf
		' sitemaps.org requires a W3C date; DEF_Now renders as "7/25/2026 2:54:39 PM", which
		' makes the whole sitemap index invalid for a crawler.
		MD = MD & "  <lastmod>" & Year(DEF_Now) & "-" & Right("0" & Month(DEF_Now),2) & "-" & Right("0" & Day(DEF_Now),2) & "</lastmod>"
		MD = MD & " </sitemap>" & VbCrLf
	Next
	MD = MD & "</sitemapindex>" & VbCrLf
	Set fs =Server.CreateObject(DEF_FSOString)
	fileName = "../../sitemap.xml"
	Set FSO = fs.OpenTextFile(server.Mappath(fileName),2,true)
	FSO.WriteLine(MD) 
	FSO.close
	set fs=nothing

	%>
	完成
	<%
	Application.Contents.Remove("Io_" & GBL_CHK_User)
	application.contents.removeall

End Sub

Sub UpdateBoardData

	Dim StartTime,SpendTime,RemainTime
	Dim TempAT,T
	Dim NowID,EndFlag,SQL,Rs
	NowID = 0
	EndFlag = 0
		
	Dim RootMaxID,RootMinID,ChildNum
	Dim N,GetData
	
	Dim BoardID
	BoardID = Request("ID")
	If isNumeric(BoardID) = 0 Then BoardID = 0
	BoardID = Fix(cCur(BoardID))
	If BoardID = 0 Then
		Application.Contents.Remove("Io_" & GBL_CHK_User)
		Exit Sub
	End If
	
	Dim RecordCount,CountIndex
	select case DEF_UsedDataBase
		case 0,2:
			SQL = "Select count(*) from LeadBBS_Announce where parentID=0 and BoardID=" & BoardID
		case Else
			SQL = "Select count(*) from [LeadBBS_Topic] where BoardID=" & BoardID
	End select
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
	StartTime = Now
	Dim U_MaxID,U_LastInfo,RootIDBak
	
	Application("Io_" & GBL_CHK_User) = "start"
	
	Dim LastTime
	LastTime = 0
	Do while EndFlag = 0
		select case DEF_UsedDataBase
		case 0,2:
			SQL = sql_select("Select ID,RootID,LastTime from LeadBBS_Announce where ParentID=0 and BoardID=" & BoardID & " and LastTime>" & LastTime & " order by LastTime ASC,ID ASC",100)
		case Else
			SQL = sql_select("Select ID,RootID,LastTime from LeadBBS_Topic where BoardID=" & BoardID & " and LastTime>" & LastTime & " order by LastTime ASC,ID ASC",100)
		End select
		'Response.Write "<p>" & sql
		'Response.Flush
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
			LastTime = GetData(2,n)
			CountIndex = CountIndex + 1
			If cCur(GetData(1,n)) <> CountIndex and cCur(GetData(1,n))<DEF_BBS_TOPMinID Then
				CALL LDExeCute("Update LeadBBS_Announce Set RootID=" & CountIndex & " where id=" & NowID,1)
			End If
			If (CountIndex mod 50) = 0 or CountIndex < 2 Then
				SpendTime = Datediff("s",StartTime,Now)
				RemainTime = SpendTime/CountIndex * (RecordCount-CountIndex)
				'Response.Flush
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
	<%
	Application.Contents.Remove("Io_" & GBL_CHK_User)

End Sub

Sub UpdateNongLi

	Dim StartTime,SpendTime,RemainTime
	StartTime = Now
	Dim NowID,EndFlag,Temp
	NowID = 0
	EndFlag = 0
	Dim Rs,SQL,GetData,n
	
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
	Do while EndFlag = 0
		SQL = sql_select("Select ID,birthday from LeadBBS_User where ID>" & NowID & " order by id ASC",100)
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
			SQL = RestoreTime(cCur("0" & GetData(1,n)))
			If isTrueDate(SQL) Then
				Temp = cCur(Left(SQL,4))
				If Temp > 1950 and Temp < 2050 Then
					SQL = GetNongLiTimeValue(ConvertToNongLi(SQL))
					If SQL = "" Then SQL = 0
					CALL LDExeCute("Update LeadBBS_User Set NongLiBirth=" & SQL & " where ID=" & NowID,1)
				Else
					CALL LDExeCute("Update LeadBBS_User Set NongLiBirth=0 where ID=" & NowID,1)
				End If
			End If
			CountIndex = CountIndex + 1
			If (CountIndex mod 100) = 0 Then
				SpendTime = Datediff("s",StartTime,Now)
				RemainTime = SpendTime/CountIndex * (RecordCount-CountIndex)
				'Response.Flush
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
	完成3
	<%
	Application.Contents.Remove("Io_" & GBL_CHK_User)
		
End Sub
%>