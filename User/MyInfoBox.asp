<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="../inc/Board_Popfun.asp"-->
<!--#include file="inc/UserTopic.asp"-->
<%
DEF_BBS_HomeUrl = "../"
Dim Evol,CheckBoxValue

Main()

Sub Main

	initDatabase()
	GBL_CHK_TempStr = ""
	
	
	If GBL_UserID = 0 or GBL_CHK_User = "" Then
		GBL_CHK_TempStr = GBL_CHK_TempStr & "<div class=alert>你没有登录</div>" & VbCrLf
	End If
	
	Dim Start
	Start = Left(Trim(Request("Start")),14)
	If isNumeric(Start) = 0 or Start="" Then Start = 0
	Start = cCur(Start)
	If Start < 0 Then Start = 0
	
	BBS_SiteHead DEF_SiteNameString & " - 短消息",0,"短消息"
	UserTopicTopInfo("user")
	UpdateOnlineUserAtInfo GBL_board_ID,"我的收件箱"
	
	If GBL_CHK_TempStr <> "" Then
		Response.Write "<div class='alert redfont'>" & GBL_CHK_TempStr & "</div>"
	Else
		PersonalInfoManage()%>
		<script type="text/javascript">
			function killall(str)
			{
				//window.open('DeleteMessage.asp?kasdie=3&ClearFlag='+str,'','width=450,height=37,scrollbars=auto,status=no');
				
				//getAJAX('DeleteMessage.asp','AjaxFlag=1&ClearFlag='+str+'&DeleteSureFlag=dk9@dl9s92lw_SWxl','alert(tmp);this.location="MyInfoBox.asp";',1);
				if (confirm('删除操作将不可逆,确定继续吗?'))
				p_once("&ClearFlag="+str,1);
			}
			</script>
			<div class=value2>
			<a href="SendMessage.asp"><b>写短消息</b></a>
			<a href='javascript:killall("dkeJje5");'><img src=../images/<%=GBL_DefineImage%>clear.gif align=middle>清空我的收件箱</a>
			</div>
			<%If GBL_UserID > 0 and CheckSupervisorUserName() = 1 Then%>
			<hr class=splitline>
			<div class=title>管理员功能</div>
			<form action=MyInfoBox.asp method=Get>
			<div class=value2>查看用户 <input class='fminpt input_2' type=text name=ToUser size=14> 的收件箱
			<input type=submit value=查看 name=查看 class="fmbtn btn_2">
			</div>
			</form>
			<div class=value2><form action=MyInfoBox.asp?Evol=n method=Post>
				查看用户 <input class='fminpt input_2' type=text name=FromUser size=14> 的发件箱
				<input type=submit value=查看 name=查看 class="fmbtn btn_2"></form>
			</div>
			<%End If%>
			<div class=value2>
			<%If CheckSupervisorUserName() = 1 Then%><a href='javascript:killall("dkeJje6");'><img src=../images/<%=GBL_DefineImage%>clear.gif align=middle>清空所有人的收件箱</a><%End If%>
			<a href='PrintMessage.asp'><img src=../images/<%=GBL_DefineImage%>print.gif align=middle>打印全部短消息及清空收件箱</a>
			</div>
	<%
	End If
	UserTopicBottomInfo()
	closeDataBase()
	SiteBottom()

End Sub

Function PersonalInfoSend

	Dim FromUser
	If CheckSupervisorUserName() = 0 Then
		FromUser = GBL_CHK_User
	Else
		FromUser = Trim(Left(Request("FromUser"),14))
		If FromUser <> "" Then
			FromUser = FromUser
		Else
			FromUser = GBL_CHK_User
		End If
	End If
	Dim Rs,SQL

	SQL = sql_select("select ID,FromUser,Title,SendTime,Readflag,ToUser,ExpiresDate from LeadBBS_InfoBox where (FromUser='" & Replace(FromUser,"'","''") & "') order by id DESC",DEF_MaxListNum)
	Set Rs = LDExeCute(SQL,0)
	Dim Num
	Dim GetData
	If Not rs.Eof Then
		GetData = Rs.GetRows(-1)
		Num = Ubound(GetData,2)
		FromUser = GetData(1,0)
	Else
		Num = -1
	End If
	Rs.close
	Set Rs = Nothing
	dim I
	MyinfoBox_NavInfo()
	If FromUser <> GBL_CHK_User Then
	%>
	<b title="你发给别人的消息"><%=htmlencode(FromUser)%>的发件箱</b>
	<%
	End If
	%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class=table_in>
	  <tr class=tbinhead>
	    <td><div class=value>主题(点※号可修改未阅读短消息)</div></td>
	    <td width=210><div class=value>发送时间和接收人</div></td>
	  </tr>
	<%
	If Num = -1 Then
		Response.Write "<tr><td colspan=2 class=tdbox>没有任何消息!</td></tr>"
	End If

	Dim TempN,n

	If Num <> -1 then
		i = 1
		For n = 0 to Num
			Response.Write "<tr><td class=tdbox>"
			If ccur(GetData(4,N)) = 0 Then
				Response.Write "<a href=""SendMessage.asp?ModifyMessageID=" & GetData(0,n) & """><span class=greenfont>※</span></a> "
			Else
				Response.Write "※ "
			End If
			Response.Write "<a href=""LookMessage.asp?MessageID=" & GetData(0,n) & """>"
			If GetData(5,N) = "" Then Response.Write "<b>"
			If StrLength(getData(2,n)) > DEF_BBS_DisplayTopicLength - 14 Then GetData(2,n) = LeftTrue(getData(2,n),DEF_BBS_DisplayTopicLength-14) & "..."

			Response.Write "<span class=word-break-all>" & Htmlencode(getData(2,n) & "") & "</span>"
			If GetData(5,N) = "" Then
				Response.Write "</b></a>"
			Else
				If ccur(GetData(6,n)) = 0 Then
					If GetData(4,N) = 0 Then
						Response.Write " <span class=greenfont>新</span></a>"
					Else
						Response.Write "</a>"
					End If
				Else
					SQL = DateDiff("d",Now,RestoreTime(GetData(6,n)))
					If GetData(4,N) = 0 Then
						If SQL > 0 Then
							Response.Write "</a> <span class=greenfont>保存" & SQL & "天</span>"
						Else
							Response.Write "</a> <span class=greenfont>到期</span>"
						End If
					Else
						If SQL > 0 Then
							Response.Write "</a> <span class=grayfont>保存" & SQL & "天</span>"
						Else
							Response.Write "</a>"
						End If
					End If
				End If
			End If	
			Response.Write "</td><td class=tdbox>"
			Response.Write Left(RestoreTime(GetData(3,n)),16) & " "
			Response.Write "<a href=""" & RW_User(0,"",GetData(5,n),"") & """>" & GetData(5,n) & "</a>" & VbCrLf
			Response.Write "</td></tr>" & VbCrLf
			i = i+1
		Next
	End If
	%>
	      </table>
	<div class=title>这是您已经发送给他人的消息，仅供查看，并无删除权限</div>
		<%

End Function

Sub PersonalInfoManage

	Evol = Request("Evol")
	If Evol = "n" Then
		PersonalInfoSend()
		Exit Sub
	End If
	Dim ToUser
	If CheckSupervisorUserName() = 0 Then
		ToUser = GBL_CHK_User
	Else
		ToUser = Trim(Left(Request.QueryString("ToUser"),14))
		If ToUser <> "" Then
			ToUser = ToUser
		Else
			ToUser = GBL_CHK_User
		End If
	End If

	Dim Rs,SQL,NewNum
	
	CheckBoxValue = Request("CheckBoxValue")
	Dim AllPrintingString
	If Request("AllPrinting")="Yesing" and CheckSupervisorUserName() = 1 Then
		sql="select count(*) from LeadBBS_InfoBox where Readflag=0"
		AllPrintingString = "&AllPrinting=Yesing"
	Else
		sql="select count(*) from LeadBBS_InfoBox where Readflag=0 and toUser='" & Replace(ToUser,"'","''") & "'"
		AllPrintingString = ""
	End If
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		NewNum = 0
	Else
		NewNum = Rs(0)
		If isNull(NewNum) or len(NewNum&"")<1 Then NewNum = 0
		NewNum = ccur(NewNum)
	End If
	Rs.close
	Set Rs = Nothing
	If GBL_CHK_MessageFlag = 1 Then GBL_CHK_MessageFlag = 1
	If NewNum = 0 and GBL_CHK_MessageFlag = 1 and AllPrintingString = "" and ToUser = GBL_CHK_User Then
		CALL LDExeCute("Update LeadBBS_User Set MessageFlag=0 where ID=" & GBL_UserID,1)
		UpdateSessionValue 6,0,0
	End If

	GBL_CHK_TempStr=""
	Dim UpDownPageFlag
	UpDownPageFlag = Request("UpDownPageFlag")

	Dim Start,RecordCount
	RecordCount=0
	
	Dim SQLendString

	Start = Left(Trim(Request("Start")),14)
	Start = start
	If isNumeric(Start)=0 or Start="" Then Start=999999999
	Start = cCur(Start)
	If Start = 0 Then Start=999999999

	Dim SQLCountString,whereFlag
	whereFlag = 0
	
	If CheckBoxValue = "yes" Then
		If WhereFlag = 1 Then
			SQLendString = SQLendString & " and Readflag=0 "
		Else
			SQLendString = SQLendString & " where Readflag=0 "
			WhereFlag = 1
		End If
	End If

	If Request("AllPrinting")="Yesing" and CheckSupervisorUserName() = 1 Then
	Else
		If WhereFlag = 0 Then
			SQLendString = " where (ToUser='" & Replace(ToUser,"'","''") & "')"
			WhereFlag = 1
		Else
			SQLendString = SQLendString & " and (ToUser='" & Replace(ToUser,"'","''") & "')"
		End If
	End If

	SQLCountString = SQLendString
	If UpDownPageFlag = "1" and Start>0 then
		If whereFlag = 1 Then
			SQLendString = SQLendString & " and ID>" & Start
		Else
			SQLendString = SQLendString & " where ID>" & Start
			whereFlag = 1
		End If
	Else
		If whereFlag = 1 Then
			SQLendString = SQLendString & " and ID<" & Start
		Else
			SQLendString = SQLendString & " where ID<" & Start
			whereFlag = 1
		End If
	End If

	If UpDownPageFlag = "1" then
		SQLendString = SQLendString & " Order by  ID ASC"
	Else
		SQLendString = SQLendString & " Order by ID DESC"
	End If

	Dim MaxRecordID,MinRecordID
	MaxRecordID = 0

	If CheckBoxValue = "yes" Then
		RecordCount = NewNum
	Else
		SQL = "select count(*) from LeadBBS_InfoBox " & SQLCountString
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof then
			RecordCount = 0
		Else
			RecordCount = Rs(0)
			If RecordCount="" or isNull(RecordCount) or len(RecordCount) < 1 Then RecordCount = 0
			RecordCount = ccur(RecordCount)
		End If
		Set Rs = Nothing
	End If

	If RecordCount > 0 Then
		SQL = "select Max(id) from LeadBBS_InfoBox " & SQLCountString
		Set Rs = LDExeCute(SQL,0)
	
		If not Rs.Eof Then
			If Rs(0) <> "" Then
				MaxRecordID = cCur(Rs(0))
			Else
				MaxRecordID = 0
			End If
		End If
		Rs.Close
		Set Rs = Nothing
		
		SQL = "select Min(id) from LeadBBS_InfoBox " & SQLCountString
		Set Rs = LDExeCute(SQL,0)
	
		If Not Rs.Eof Then
			If Rs(0) <> "" Then
				MinRecordID = cCur(Rs(0))
			Else
				MinRecordID = 0
			End If
		End If
		Rs.Close
		Set Rs = Nothing

		If RecordCount >= LMT_MaxMessageNumber and Start=999999999 and CheckSupervisorUserName() = 0 Then
			%>
			<script type="text/javascript">
				alert("你的收件箱已满，不能再接收新消息，\n收件箱最多允许存放<%=LMT_MaxMessageNumber%>条消息．");
			</script>
		<%
		End If

		SQL = sql_select("select ID,FromUser,Title,SendTime,Readflag,ToUser,ExpiresDate from LeadBBS_InfoBox " & SQLendString,DEF_TopicContentMaxListNum)
		Set Rs = LDExeCute(SQL,0)
		Dim Num
		Dim GetData
		If Not Rs.Eof Then
			GetData = Rs.GetRows(-1)
			Num = Ubound(GetData,2)
		Else
			Num = -1
		End If
		Rs.close
		Set Rs = Nothing
	Else
		MinRecordID = 0
		MaxRecordID = 0
		Num = -1
	End If

	Dim FirstID,LastID
	Dim i,N
	If Num>=0 Then
		i = 1
		Dim MinN,MaxN,StepValue
		SQL = ubound(getdata,2)
		If UpDownPageFlag = "1" then
			MinN = SQL
			MaxN = 0
			StepValue = -1
		Else
			MinN = 0
			MaxN = SQL
			StepValue = 1
		End If
		
		LastID = cCur(GetData(0,MaxN))
		FirstID = cCur(GetData(0,MinN))
	
		Dim EndwriteQueryString,PageSplictString
		EndwriteQueryString = "?Z38=0"
		If CheckSupervisorUserName() = 1 and ToUser <> GBL_CHK_User Then EndwriteQueryString = EndwriteQueryString & "&ToUser=" & urlencode(ToUser)
	
		PageSplictString = PageSplictString & "<div class=j_page>"
		If FirstID >= MaxRecordID Then
			'PageSplictString = PageSplictString & "首页" & VbCrLf
			'PageSplictString = PageSplictString & " 上页" & VbCrLf
		Else
			PageSplictString = PageSplictString & "<a href=""MyInfoBox.asp" & EndwriteQueryString & AllPrintingString & "&Start=0"">首页</a> " & VbCrLf
			PageSplictString = PageSplictString & " <a href=""MyInfoBox.asp" & EndwriteQueryString & "&Start=" & LngStr(FirstID) & AllPrintingString & "&UpDownPageFlag=1"">上页</a> " & VbCrLf
		End If

		If LastID < MaxRecordID and LastID <> 0 then
		Else
		End If
	
		If LastID <= MinRecordID Then
			'PageSplictString = PageSplictString & " 下页" & VbCrLf
			'PageSplictString = PageSplictString & " 尾页" & VbCrLf
		Else
			PageSplictString = PageSplictString & "<a href=""MyInfoBox.asp" & EndwriteQueryString & "&Start=" & LngStr(LastID) & AllPrintingString &""">下页</a>" & VbCrLf
			PageSplictString = PageSplictString & "<a href=""MyInfoBox.asp" & EndwriteQueryString & AllPrintingString & "&Start=1&UpDownPageFlag=1"">尾页</a>" & VbCrLf
		End If
		
		PageSplictString = PageSplictString & "<b>共" & RecordCount & "</b>"
		'If (RecordCount mod DEF_TopicContentMaxListNum)=0 Then
		'	PageSplictString = PageSplictString & " 计<b>" & clng(RecordCount/DEF_TopicContentMaxListNum) & "</b>页"
		'Else
		'	If RecordCount>=DEF_TopicContentMaxListNum Then
		'		PageSplictString = PageSplictString & " 计<b>" & clng(RecordCount/DEF_TopicContentMaxListNum)+1 & "</b>页"
		'	Else
		'		PageSplictString = PageSplictString & " 计<b>1</b>页"
		'	End If
		'End If
		'PageSplictString = PageSplictString & " 每页<b>" & DEF_TopicContentMaxListNum & "</b>条记录"
		PageSplictString = PageSplictString & "</div>"
	End If
	%>
	<script src="<%=DEF_BBS_HomeUrl%>inc/js/p_list.js?ver=20090601.2" type="text/javascript"></script>
	<script type="text/javascript">
	p_url = "DeleteMessage.asp";
	p_para = "AjaxFlag=1&DeleteSureFlag=dk9@dl9s92lw_SWxl&MessageID=";
	p_command = 'alert(tmp);this.location="MyInfoBox.asp";';
	p_type = 1;
	</script>
	
	<%MyinfoBox_NavInfo%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class=table_in>
	<tr class=tbinhead>
		<td><div class=value>主题</div></td>
		<td width=190><div class=value>发送时间和发送人</div></td>
		<td width=80>&nbsp;</td>
	</tr>
	<%
	If Num = -1 Then
		Response.Write "<tr><td colspan=3 class=tdbox>您的收件箱暂无消息.</td></tr>"
	End If

	Dim Index,color
	Index = 0
	if Num <> -1 then
		i=1
		LastID = GetData(0,ubound(getdata,2))
		For n= MinN to MaxN Step StepValue
			If GetData(1,n) = "[LeadBBS]" Then color = " class=bluefont"
			If GetData(5,N) = "" Then
				color = ""
			Else
				If GetData(4,N) = 0 Then
					color = ""
				Else
					color = " class=grayfont"
				End If
			End If
			Response.Write "<tr>"
			Response.Write "<td class=tdbox>"
			Response.Write "<a href=""LookMessage.asp?MessageID=" & GetData(0,n) & AllPrintingString & """ title=编号" & GetData(0,n) & color & ">"
			If GetData(5,N) = "" Then Response.Write "<b>"
			If StrLength(getData(2,n)) > DEF_BBS_DisplayTopicLength - 13 Then GetData(2,n) = LeftTrue(getData(2,n),DEF_BBS_DisplayTopicLength-13) & "..."

			Response.Write "<span class=word-break-all>" & Htmlencode(getData(2,n) & "") & "</span>"
			If GetData(5,N) = "" Then
				Response.Write "</b></a>"
			Else
				If ccur(GetData(6,n)) = 0 Then
					If GetData(4,N) = 0 Then
						Response.Write " <span class=greenfont>新</span></a>"
					Else
						Response.Write "</a>"
					End If
				Else
					SQL = DateDiff("d",Now,RestoreTime(GetData(6,n)))
					If GetData(4,N) = 0 Then
						If SQL > 0 Then
							Response.Write "</a> <span class=greenfont>保存" & SQL & "天</span>"
						Else
							Response.Write "</a> <span class=greenfont>到期</span>"
						End If
					Else
						If SQL > 0 Then
							Response.Write "</a> <span class=grayfont>保存" & SQL & "天</span>"
						Else
							Response.Write "</a>"
						End If
					End If
				End If
			End If	
			Response.Write "</td>" & VbCrLf & "<td class=tdbox><em>"
			Response.Write Mid(RestoreTime(GetData(3,n)),3,14) & "</em> "
		   	If GetData(1,n) <> "[LeadBBS]" Then
		   		Response.Write "<a href=""../User/" & RW_User(0,"",GetData(1,n),"") & """>" & htmlencode(GetData(1,n)) & "</a>"
		   	Else
		   		Response.Write "<span class=bluefont>系统</span>"
		   	End If
			Response.Write "</td><td align=center class=tdbox>"
			If (GetData(5,N) <> "" or CheckSupervisorUserName() = 1) Then
				%>
				<input class="fmchkbox" type="checkbox" name="ids" id="ids<%=Index%>" value="<%=LngStr(GetData(0,n))%>" /><%
				Response.Write "<a href='javascript:p_once(" & GetData(0,n) & ");'>删除</a>"
				Index = Index + 1
			End If
			Response.Write "</tr>" & VbCrLf
			I = I + 1
		Next
	End If
	If PageSplictString<>"" Then Response.Write "<tr><td colspan=3 class=tdbox align=right>" & PageSplictString & "</td></tr>"
	%>
	<tr><td colspan=3 class=tdbox align=right>
	<input class="fmchkbox" type="checkbox" name="selmsg" id="selmsg" value="1" onclick="achoose();" />选择所有记录
	<input type=button value="批量删除" onclick="pchoose();" class="fmbtn btn_4">
	</td></tr>
	</table>
	<%
	If RecordCount > 0 Then
		Response.Write "<div class=title>共<b>" & RecordCount & "</b>条消息"
		If NewNum = 0 Then
			Response.Write "， 所有消息您都已浏览过"
		Else
			Response.Write "， 未浏览过的消息有<b>" & NewNum & "</b>条"
		End If
		Response.Write "</div>"
	End If

End Sub

Sub MyinfoBox_NavInfo

	If CheckBoxValue = "yes" Then Evol = "g"
	If Request("AllPrinting") = "Yesing" Then Evol = "e"
	Response.Write "<div class='user_item_nav fire'><ul>"
	Response.Write "<li><div class=name>" & htmlencode(GBL_CHK_User) & "</div></li>"
	If Evol = "A" or Evol = "" Then
		Response.Write "	<li><div class=navactive><span>收件箱</span></div></li>"
	Else
		Response.Write "	<li><a href=""MyInfoBox.asp?Evol=A"">收件箱</a></li>"
	End If

	If Evol = "n" Then
		Response.Write "	<li><div class=navactive>已发送</div></li>"
	Else
		Response.Write "	<li><a href=""MyInfoBox.asp?Evol=n"">已发送</a></li>"
	End If

	If Evol = "g" Then
		Response.Write "	<li><div class=navactive>新的消息</div></li>"
	Else
		Response.Write "	<li><a href=""MyInfoBox.asp?CheckBoxValue=yes"">新的消息</a></li>"
	End If

	If CheckSupervisorUserName() = 1 Then
		If Evol <> "e" Then
			Response.Write "<li><a href=""MyInfoBox.asp?AllPrinting=Yesing"">查看全部消息</a></li>"
		Else
			Response.Write "<li><div class=navactive>查看全部消息</div></li>"
		End If
	End If
	Response.Write "	<li><a href=""SendMessage.asp"">发送消息</a></li>"
	Response.Write "</ul></div>"
	

End Sub%>