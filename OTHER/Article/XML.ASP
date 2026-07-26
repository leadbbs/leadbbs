<!--#include file="../../inc/BBSSetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<%
Dim HomeUrl
HomeUrl = LD_GetUrl(1)

DEF_BBS_HomeUrl = "../../"
Const LMT_MaxDisplayAnnounce = 100
OpenDatabase()
GetTopicInfo()
closeDataBase()

Function GetTopicInfo

	Dim LastTime,PostTime,GoodFlag,LMT_RootID,Content,UserName
	Dim Article_NotReplay,Form_ChildNum,LMT_TopicName,LMT_RootIDBak,LMT_TopicTitleStyle
	Dim Rs,SQL,Form_TopicType,Form_NeedValue,TParentID
	Dim BoardID
	TParentID = -1
	GBL_CHK_TempStr = ""

	Dim ac,TID,Hits
	ac = Request.QueryString("ac")
	TID = Left(Request.QueryString("TID"),14)
	If isNumeric(TID) = 0 or inStr(TID,".") then TID = 0
	TID = cCur(TID)
	
	ac = Request.QueryString("ac")

	If TID = 0 Then
		SQL = ""
	Else
		Select Case ac
			Case "pre": SQL = "Select top 1 ID,RootID,TopicType,NeedValue,ParentID,ChildNum,Title,hits,RootMaxID,RootMinID,NotReplay,RootIDBak,TitleStyle,BoardID,LastTime,NdateTime,GoodFlag,Content,UserName from LeadBBS_Announce where ParentID=0 and RootIDBak>" & rd & " order by RootIDBak ASC"
			Case "nxt": 
					SQL = "Select max(RootIDBak) from LeadBBS_Announce where ParentID=0 and RootIDBak<" & rd
					Set Rs = LDExeCute(SQL,0)
					If Not Rs.Eof Then
						SQL = Rs(0)
						If isNull(SQL) Then SQL = 0
						SQL = cCur(SQL)
						If SQL >0 Then
							SQL = "Select top 1 ID,RootID,TopicType,NeedValue,ParentID,ChildNum,Title,hits,RootMaxID,RootMinID,NotReplay,RootIDBak,TitleStyle,BoardID,LastTime,NdateTime,GoodFlag,Content,UserName from LeadBBS_Announce where ParentID=0 and RootIDBak=" & SQL
						Else
							SQL = ""
						End If
					Else
						SQL = ""
					End If
					Rs.Close
					Set Rs = Nothing
			Case Else: SQL = "Select top 1 ID,RootID,TopicType,NeedValue,ParentID,ChildNum,Title,hits,RootMaxID,RootMinID,NotReplay,RootIDBak,TitleStyle,BoardID,LastTime,NdateTime,GoodFlag,Content,UserName from LeadBBS_Announce where ParentID=0 and RootIDBak>=" & TID & " Order by RootIDBak ASC"
		End Select
	End If

	If SQL <> "" Then
		Set Rs = LDExeCute(SQL,0)
		If Not Rs.Eof Then
			'Form_ParentID = cCur(Rs(0))
			LMT_RootID = cCur(Rs(1))
			Form_TopicType = Rs(2)
			Form_NeedValue = Rs(3)
			TParentID = cCur(Rs(4))
			Form_ChildNum = cCur(Rs(5))
			LMT_TopicName = Rs(6)
			'Form_RootMaxID = cCur(Rs(8))
			'Form_RootMinID = cCur(Rs(9))
			Article_NotReplay = Rs(10)
			LMT_RootIDBak = cCur(Rs(11))
			LMT_TopicTitleStyle = Rs(12)
			BoardID = Trim(Rs(13))
			Hits = cCur(Rs(7)) + 1
			LastTime = RestoreTime(Rs(14))
			PostTime = RestoreTime(Rs(15))
			GoodFlag = Rs(16)
			Content = Rs(17)
			UserName = Rs(18)
			Rs.Close
			Set Rs = Nothing
		Else
			Rs.Close
			Set Rs = Nothing
		End If
	End If

	If TParentID <> 0 Then
		GBL_CHK_TempStr = "错误,该主题不存在!<br>" & VbCrLf
		Exit Function
	End If

	If Form_TopicType > 0 and Article_NotReplay = 0 Then
		Select case Form_TopicType
			Case 2:Article_NotReplay = 1
			Case 4:Article_NotReplay = 1
			Case 6:Article_NotReplay = 1
			Case 51:Article_NotReplay = 1
			Case 53:Article_NotReplay = 1
		End Select
	End If
	
	BoardID = cCur(BoardID)
	Dim Temp,ForumPass,BoardLimit,OtherLimit,BoardName
	Temp = Application(DEF_MasterCookies & "BoardInfo" & BoardID)
	If isArray(Temp) = False Then
		ReloadBoardInfo(BoardID)
		Temp = Application(DEF_MasterCookies & "BoardInfo" & BoardID)
	End If
	If isArray(Temp) = False Then
		'Response.Write "错误论坛发生错误,请联系管理员!<br>" & VbCrLf
		ForumPass = "a"
		BoardLimit = 0
		OtherLimit = 0
		BoardName = ""
		GBL_Board_AssortName = ""
	Else
		ForumPass = Temp(7,0)
		BoardLimit = cCur(Temp(9,0))
		OtherLimit = cCur(Temp(36,0))
		BoardName = Temp(0,0)
		GBL_Board_AssortName = Temp(14,0)
	End If

	Response.Clear
	Response.CharSet="utf-8"
	Response.ContentType = "text/xml" 
	Response.Write "<?xml version=""1.0"" encoding=""utf-8""?>" & VbCrLf
	If ForumPass <> "" or GetBinarybit(BoardLimit,7) = 1 or GetBinarybit(BoardLimit,2) = 1 or GetBinarybit(BoardLimit,15) = 1 or OtherLimit > 0 Then
	%><BBSData>
<LastTid><%=LMT_RootIDBak+1%></LastTid>
<Version>LeadBBS v3.14</Version>
<Frequency>3</Frequency>
<Concurrent>1</Concurrent>
<BBSName><%=xmlcode(DEF_SiteNameString)%></BBSName>
<BBSURL><%=xmlcode(HomeUrl)%></BBSURL>
<ChannelInfo>
<ForumName><%=xmlcode(BoardName)%></ForumName>
<ForumUrl><%=HomeUrl%>b/b.asp?b=<%=BoardID%></ForumUrl>
<ForumType><%=xmlcode(GBL_Board_AssortName)%></ForumType>
<Language>GBK</Language>
</ChannelInfo>
<StatusElement>
<Link><%=HomeUrl%>a/a.asp?b=<%=BoardID%>&amp;id=<%=LMT_RootIDBak%></Link>
<ReplyTime><%=LastTime%></ReplyTime>
<PostTime><%=PostTime%></PostTime>
<ReplyNum><%=Form_ChildNum%></ReplyNum>
<ViewNum><%=Hits%></ViewNum> 
<Sticky><%=(LMT_RootID >= DEF_BBS_TOPMinID)%></Sticky>
<Digest><%=(GoodFlag <> 0 and GoodFlag <> False)%></Digest> 
<Deleted>False</Deleted>
<Locked><%=(Article_NotReplay = 1)%></Locked> 
<Access>True</Access> 
</StatusElement>
</BBSData>
	<%Exit Function
	End If
	%><BBSData>
<LastTid><%=LMT_RootIDBak+1%></LastTid>
<Version>LeadBBS v3.14</Version>
<Frequency>3</Frequency>
<Concurrent>1</Concurrent>
<BBSName><%=xmlcode(DEF_SiteNameString)%></BBSName>
<BBSURL><%=xmlcode(HomeUrl)%></BBSURL>
<ChannelInfo>
<ForumName><%=xmlcode(BoardName)%></ForumName>
<ForumUrl><%=HomeUrl%>b/b.asp?b=<%=BoardID%></ForumUrl>
<ForumType><%=xmlcode(GBL_Board_AssortName)%></ForumType>
<Language>GBK</Language>
</ChannelInfo>
<StatusElement>
<Link><%=HomeUrl%>a/a.asp?b=<%=BoardID%>&amp;id=<%=LMT_RootIDBak%></Link>
<ReplyTime><%=LastTime%></ReplyTime>
<PostTime><%=PostTime%></PostTime>
<ReplyNum><%=Form_ChildNum%></ReplyNum>
<ViewNum><%=Hits%></ViewNum> 
<Sticky><%=(LMT_RootID >= DEF_BBS_TOPMinID)%></Sticky>
<Digest><%=(GoodFlag <> 0 and GoodFlag <> False)%></Digest> 
<Deleted>False</Deleted>
<Locked><%=(Article_NotReplay = 1)%></Locked> 
<Access>True</Access> 
</StatusElement>
<PageInfo>
	<ContentElement>
		<Title><%=xmlcode(LMT_TopicName)%></Title>
		<Content><![CDATA[<%=xmlcode(Content)%>]]></Content>
		<Author><%=xmlcode(UserName)%></Author>
		<Attachment>
			<URL><%=HomeUrl%>a/a.asp?b=<%=BoardID%>&amp;id=<%=LMT_RootIDBak%></URL>
			<MIMEType>text/html</MIMEType>
			<Description>LeadBBS asp论坛</Description>
		</Attachment>
	</ContentElement>
<%
Dim EndFlag,PageN,StartN,N,Count,MaxID,Url,GetData
EndFlag = 0
PageN = 0
StartN = LMT_RootIDBak

Do While EndFlag = 0
	If PageN = 0 Then
		SQL = "Select top " & DEF_TopicContentMaxListNum - 1 & " ID,Title,Content,RootIDBak,UserName from LeadBBS_Announce Where RootIDBak=" & LMT_RootIDBak & " and ID>" & StartN
	Else
		SQL = "Select top " & DEF_TopicContentMaxListNum & " ID,Title,Content,RootIDBak,UserName from LeadBBS_Announce Where RootIDBak=" & LMT_RootIDBak & " and ID>" & StartN
	End If
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		EndFlag = 1
		Exit Do
	End If
	GetData = Rs.GetRows(-1)
	Rs.Close
	Set Rs = Nothing
	Count = Ubound(GetData,2)
	MaxID = GetData(0,Count)
	Url = HomeUrl & "a/a.asp?b=" & BoardID & "&amp;id=" & LMT_RootIDBak & "&amp;Ar=" & MaxID & "&amp;=AUpflag=0&amp;Ap=" & PageN & "&amp;Aq=0"
	For N = 0 to Count
%>
	<ReplyInfo>
		<Title><%=xmlcode(GetData(1,N))%></Title>
		<Author><%=xmlcode(GetData(4,N))%></Author>
		<Content><![CDATA[<%=xmlcode(GetData(2,N))%>]]></Content>
		<Attachment>
			<URL><%=Url%></URL>
			<MIMEType>text/html</MIMEType>
			<Description>LeadBBS asp论坛</Description>
		</Attachment>
	</ReplyInfo>
<%
		StartN = GetData(0,N)
	Next
	PageN = PageN + 1
	'If (PageN mod 3)=0 then Response.Flush
	If PageN > 20 Then EndFlag = 1
Loop
%></PageInfo>[执行时间<%=FormatNumber(cCur(Timer - DEF_PageExeTime1),4,True)*1000%>ms]
</BBSData>
	<%

End Function

Function xmlcode(Str)

	xmlcode=Replace(Replace(Replace(Replace(str,">","&gt;"),"<","&lt;"),"&","&amp;"),"""","&quot;")

End Function%>