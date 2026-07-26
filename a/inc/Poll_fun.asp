<!--#include file="MakeAnnounceTop.asp"-->
<%
Const LMT_PollNeedPoints = 100 '用户投票帖子需要达到的积分，可以为负。

Dim PollTitleID,SelectItemID

Function DisplayVoteForm(AnnounceID,VoteFlag)

	If A_TitleStyle >= 60 Then Exit Function
	Dim Rs,SQL
	
	SQL = sql_select("Select ID,AnnounceID,VoteName,VoteNum,VoteType,ExpiresTime from LeadBBS_VoteItem where AnnounceID=" & AnnounceID,DEF_VOTE_MaxNum)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		Exit Function
	End If
	
	Dim GetData
	GetData = Rs.GetRows(DEF_VOTE_MaxNum)
	Rs.Close
	Set Rs = Nothing

	If A_NotReplay = 0 Then		
		If cCur(GetData(5,0)) = 0 or cCur(GetData(5,0)) > GetTimeValue(DEF_Now) Then
			SQL = sql_select("select ID from LeadBBS_VoteUser where AnnounceID=" & AnnounceID & " and UserName='" & Replace(GBL_CHK_User,"'","''") & "'",1)
			Set Rs = LDExeCute(SQL,0)
			If Not Rs.Eof Then
				Rs.Close
				Set Rs = Nothing
				DisplayPollResult 120,AnnounceID,"你已投过票，投票结果如下",GetData
			Else
				Rs.Close
				Set Rs = Nothing
				If VoteFlag = 1 Then
					If GetData(4,0) Then
						If PollOneTicketCheckbox(GetData) = 1 Then DisplayPollResult 120,AnnounceID,"你已投过票，投票结果如下",GetData
					Else
						If PollOneTicketRadio(GetData) = 1 Then DisplayPollResult 120,AnnounceID,"你已投过票，投票结果如下",GetData
					End If
				Else
					Call DisplayPollForm(550,400,GetData)
					If CheckSupervisorUserName() = 1 and GBL_UserID > 0 Then DisplayPollResult 120,AnnounceID,"您是管理员，投票结果如下",GetData
				End If
			End If
		Else
			DisplayPollResult 120,AnnounceID,"投票已过期，投票结果如下",GetData
		End If
	Else
		DisplayPollResult 120,AnnounceID,"帖子已锁定，投票结果如下",GetData
	End If

End Function

Rem 显示某投票主题当前投票结果
Function DisplayPollResult(IMGWidth,AnnounceID,TmpStr,GetData)

	Dim ItemNum
	ItemNum = Ubound(GetData,2)
	If ItemNum >= 0 Then
		Dim Temp1,Temp2,ZPollNum,MaxNum,Temp3
		Dim TempN
		ZPollNum = 0
		MaxNum = 0
		For TempN = 0 to ItemNum
			ZPollNum = ZPollNum + Clng(GetData(3,TempN))
			If MaxNum < Clng(GetData(3,TempN)) Then
				MaxNum = Clng(GetData(3,TempN))
			End If
		Next

		%>
		<table border="0" cellpadding="0" cellspacing="0" class="blanktable">
		<tr class="tbinhead">
			<td>
			<div class="value"><%=TmpStr%>
			[<a href="#no" onclick="if($id('PollUser').style.display=='none'){$id('PollUser').style.display='block';getAJAX('a.asp','ol=2&amp;B=<%=GBL_board_ID%>&amp;ID=<%=GetData(1,0)%>','PollUser');}">投票人</a>]
			</div>
			</td>
			<td>
				<div class="value">&nbsp;</div>
		</td></tr>
		<%
		For TempN = 0 To ItemNum
			Response.Write "	<tr>" & VbCrLf
			Response.Write "		<td class=""tdbox"">" & TempN + 1 & ". " & HtmlEncode(GetData(2,TempN)) & "</td>" & VbCrLf
			If ZPollNum = 0 Then
				Temp1 = 0
				Temp3 = 0
			Else
				Temp1 = CLng(GetData(3,TempN))/ZPollNum
				Temp3 = CLng(GetData(3,TempN))/MaxNum
			End If
			Temp2 = Temp3 * IMGWidth
                        If Temp2 > 0 and Temp2 < 1 then
                        	Temp2 = 1
                        End If
                        Response.Write "		<td class=""tdbox"">"
                        Response.Write "<img height=""9"" src=""" & DEF_BBS_HomeUrl & "images/" & GBL_DefineImage & "vote.gif"" width=""" & Temp2 & """ border=""0"" class=""absmiddle"" alt=""投票结果"" /> "
			If Temp1<0.01 Then
                        	If inStr(Temp1,"0.")<1 Then
                        		If temp2 <= 0 then
                        			Response.Write "&nbsp;0"
                        		Else
                        			Response.Write "0"
                        		End If
                        	End if
                        	Response.Write formatpercent(Temp1)
                        Else
                        	Response.Write formatpercent(Temp1)
                        End If
			Response.Write " [" & GetData(3,TempN) & "]"
                        Response.Write "</td>" & VbCrLf
                        Response.Write "	</tr>" & VbCrLf
		Next
		Response.Write "</table><div id=""PollUser"" style=""display:none"">loading...</div>" & VbCrLf
	End If

End Function

Rem 显示某投票主题投票界面
Rem OpenWidth 投票结果窗口宽,OpenHeight 投票结果窗口高
Function DisplayPollForm(OpenWidth,OpenHeight,GetData)

	Dim TypeStr
	If GetData(4,0) Then
		TypeStr = "checkbox"
	Else
		TypeStr = "radio"
	End If
	Dim ItemNum
	ItemNum = Ubound(GetData,2)
	If ItemNum >= 0 Then
		Dim TempN
	%>
	<script type="text/javascript">
	<!--
		var PollForm<%=GetData(1,0)%>Value = -1;
		function CheckPollFromZwle<%=GetData(1,0)%>(obj)
		{
			var selitemstr = "";
			for (var i=0;i<$id('PollForm<%=GetData(1,0)%>').elements.length;i++)
			{
				var e = $id('PollForm<%=GetData(1,0)%>').elements[i];
				if(e.checked)selitemstr += "," + e.value
			}
			if (selitemstr=="")
			{
				alert("投票请先选择项目!");
				return false;
			}
			getAJAX("a.asp","ol=1&B=<%=GBL_board_ID%>&ID=<%=GetData(1,0)%>&SelectItemID=" + selitemstr,"PollResult");
			return true;
		}
	-->
	</script>
			<form name="PollForm<%=GetData(1,0)%>" action="" id="PollForm<%=GetData(1,0)%>" onsubmit="return CheckPollFromZwle<%=GetData(1,0)%>(this)" method="post">
			<input type="hidden" name="PollTitleID" value="<%=GetData(1,0)%>" />
			<table cellpadding="0" cellspacing="0" class="blanktable"><tr class="tbinhead"><td><div class="value">先投票才能查看结果</div></td></tr>
		<%For TempN = 0 To ItemNum
			Response.Write "	<tr><td><input type=""" & TypeStr & """ name=""radios"" value=""" & GetData(0,TempN) & """ onclick=""PollForm" & GetData(1,0) & "Value = " & GetData(0,TempN) & ";"" class=""fmchkbox"" />"
			Response.Write HtmlEncode(GetData(2,TempN)) & "</td></tr>" & VbCrLf
		Next
		%>
		</table>
		</form>
		<div id="pollbtn"><input type="button" onclick="if(CheckPollFromZwle<%=GetData(1,0)%>(this)){$id('pollbtn').style.display='none';$id('PollResult').style.display='block';CheckPollFromZwle<%=GetData(1,0)%>(this);}" value="投票" id="poll" name="poll" class="fmbtn btn_2" /></div>
		<div id="PollResult" style="display:none;">提交中...</div>
		<%
	End If

End Function

Rem 投一票
Function PollOneTicketRadio(GetData)

	If GBL_CHK_User = "" Then
		GBL_CHK_TempStr = "先登录才能投票"
		Exit Function
	End If

	If GBL_CHK_OnlineTime < DEF_NeedOnlineTime Then
		GBL_CHK_TempStr = "你的" & DEF_PointsName(4) & "(在线时间)不足,需要" & Fix(DEF_NeedOnlineTime/60) & "才能投票!"
		Exit Function
	End If

	If GBL_CHK_Points < LMT_PollNeedPoints Then
		GBL_CHK_TempStr = "你的" & DEF_PointsName(0) & "不足,需要" & LMT_PollNeedPoints & "才能投票!"
		Exit Function
	End If

	If CheckUserAnnounceLimit() = 0 Then Exit Function
	PollTitleID = Left(Request.Form("ID"),14)
	SelectItemID = Left(Request.Form("SelectItemID"),14)
	SelectItemID = Replace(SelectItemID,",","")

	If PollTitleID = "" or inStr(PollTitleID,",")>0 or isNumeric(PollTitleID) = 0 Then
		PollOneTicketRadio = 0
		Exit Function
	End If
	
	If SelectItemID = "" or inStr(SelectItemID,",")>0 or isNumeric(SelectItemID) = 0 Then
		PollOneTicketRadio = 0
		Exit Function
	End If

	PollTitleID = cCur(PollTitleID)
	SelectItemID = cCur(SelectItemID)

	CALL LDExeCute("Update LeadBBS_VoteItem Set VoteNum=VoteNum+1 where AnnounceID=" & PollTitleID & " and ID=" & SelectItemID,1)
	CALL LDExeCute("insert into LeadBBS_VoteUser(UserName,VoteItem,AnnounceID) values('" & Replace(GBL_CHK_User,"'","''") & "','" & Replace(SelectItemID,"'","''") & "'," & PollTitleID & ")",1)
	CALL LDExeCute("Update LeadBBS_Announce Set PollNum=PollNum+1 where ID=" & PollTitleID,1)
	If DEF_UsedDataBase = 1 Then CALL LDExeCute("Update LeadBBS_Topic Set PollNum=PollNum+1 where ID=" & PollTitleID,1)
	If inStr(application(DEF_MasterCookies & "TopAncList"),"," & PollTitleID & ",") Then
		UpdateAnnounceApplicationInfo PollTitleID,15,1,1,0
	Else
		If inStr(application(DEF_MasterCookies & "TopAncList" & GBL_Board_BoardAssort),"," & PollTitleID & ",") Then UpdateAnnounceApplicationInfo PollTitleID,15,1,1,GBL_Board_BoardAssort
	End If

	If DEF_EnableMakeTopAnc <> GetBinarybit(GBL_Board_BoardLimit,17) Then CALL MakeAnnounceTop(PollTitleID,"")

	Dim N
	For n = 0 to Ubound(GetData,2)
		If cCur(GetData(0,n)) = SelectItemID Then
			GetData(3,n) = cCur(GetData(3,n)) + 1
			Exit For
		End If
	Next
	PollOneTicketRadio = 1

End Function

Rem 投多票
Function PollOneTicketCheckbox(GetData)

	If GBL_CHK_User = "" Then
		GBL_CHK_TempStr = "先登录才能投票"
		Exit Function
	End If

	If GBL_CHK_OnlineTime < DEF_NeedOnlineTime Then
		GBL_CHK_TempStr = "你的" & DEF_PointsName(4) & "(在线时间)不足,需要" & Fix(DEF_NeedOnlineTime/60) & "才能投票!"
		Exit Function
	End If

	If GBL_CHK_Points < LMT_PollNeedPoints Then
		GBL_CHK_TempStr = "你的" & DEF_PointsName(0) & "不足,需要" & LMT_PollNeedPoints & "才能投票!"
		Exit Function
	End If
	
	If CheckUserAnnounceLimit() = 0 Then Exit Function
	PollTitleID = Left(Request.Form("ID"),14)
	SelectItemID = Request.Form("SelectItemID")
	If Left(SelectItemID,1) = "," Then SelectItemID = Mid(SelectItemID,2)
	
	If PollTitleID = "" or inStr(PollTitleID,",")>0 or isNumeric(PollTitleID) = 0 Then
		PollOneTicketCheckbox = 0
		Exit Function
	End If
	
	If SelectItemID = "" Then
		PollOneTicketCheckbox = 0
		Exit Function
	End If
	
	Dim TA,N
	TA = Split(SelectItemID,",")
	SelectItemID = ""
	For N = 0 to Ubound(TA,1)
		If isNumeric(TA(N)) = 0 Then
			PollOneTicketCheckbox = 0
			Exit Function
		Else
			If N = 0 Then
				SelectItemID = Left(TA(0),14)
			Else
				SelectItemID = SelectItemID & "," & Left(TA(N),14)
			End if
		End If
	Next

	PollTitleID = cCur(PollTitleID)

	CALL LDExeCute("Update LeadBBS_VoteItem Set VoteNum=VoteNum+1 where AnnounceID=" & PollTitleID & " and ID in(" & SelectItemID & ")",1)
	CALL LDExeCute("insert into LeadBBS_VoteUser(UserName,VoteItem,AnnounceID) values('" & Replace(GBL_CHK_User,"'","''") & "','" & Replace(Left(SelectItemID,255),"'","''") & "'," & PollTitleID & ")",1)
	CALL LDExeCute("Update LeadBBS_Announce Set PollNum=PollNum+1 where ID=" & PollTitleID,1)
	If DEF_UsedDataBase = 1 Then CALL LDExeCute("Update LeadBBS_Topic Set PollNum=PollNum+1 where ID=" & PollTitleID,1)
	If inStr(application(DEF_MasterCookies & "TopAncList"),"," & PollTitleID & ",") Then
		UpdateAnnounceApplicationInfo PollTitleID,15,1,1,0
	Else
		If inStr(application(DEF_MasterCookies & "TopAncList" & GBL_Board_BoardAssort),"," & PollTitleID & ",") Then UpdateAnnounceApplicationInfo PollTitleID,15,1,1,GBL_Board_BoardAssort
	End If
	If DEF_EnableMakeTopAnc = 1 Then CALL MakeAnnounceTop(PollTitleID,"")

	SelectItemID = "," & SelectItemID & ","
	For n = 0 to Ubound(GetData,2)
		If inStr(SelectItemID,cCur(GetData(0,n))) Then
			GetData(3,n) = cCur(GetData(3,n)) + 1
		End If
	Next
	PollOneTicketCheckbox = 1

End Function

Sub CheckPollTitleID

	CheckPass()
	Dim PollTitleID,SelectItemID
	A_NotReplay = 0 
	PollTitleID = Left(Request.Form("ID"),14)
	SelectItemID = Request.Form("SelectItemID")
	If isNumeric(PollTitleID) = 0 Then PollTitleID = 0
	PollTitleID = Fix(cCur(PollTitleID))
	
	CheckAccessLimit()

	Dim Rs,SQL
	SQL = sql_select("Select BoardID,NotReplay,TitleStyle from LeadBBS_Announce Where ID=" & PollTitleID,1)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		GBL_CHK_TempStr = "错误，不存在此投票。"
		Rs.Close
		Set Rs = Nothing
	Else
		If cCur(Rs(0)) <> GBL_Board_ID Then
			GBL_CHK_TempStr = "错误，不存在此投票。"
		Else
			If A_NotReplay = 0 and Rs(1) = 1 Then A_NotReplay = 1
			A_TitleStyle = cCur(Rs(2))
		End If
		Rs.Close
		Set Rs = Nothing
	End If
	
	If GBL_CHK_TempStr = "" Then DisplayVoteForm PollTitleID,1
	If GBL_CHK_TempStr <> "" Then Response.Write "<b><font color=Red class=redfont>" & GBL_CHK_TempStr & "</font></b><br /><br />"
	
End Sub

Sub PollUserList

	Dim PollTitleID
	PollTitleID = Left(Request.Form("ID"),14)
	If PollTitleID = "" or isNumeric(PollTitleID) = 0 Then PollTitleID = 0
	PollTitleID = cCur(PollTitleID)
	If PollTitleID = 0 then Exit Sub

	Dim Rs,SQL,NewNum
	GBL_CHK_TempStr=""
	Dim UpDownPageFlag
	UpDownPageFlag = Request.Form("UF")

	Dim Start,RecordCount,key
	RecordCount=0
	
	Dim SQLStr

	Start = Left(Trim(Request.Form("Start")),50)
	Start = start
	If isNumeric(Start)=0 or Start="" Then Start=999999999
	Start = cCur(Start)
	If Start = 0 Then Start=999999999

	Dim SQLCountString,whereFlag

	whereFlag = 1
	SQLStr = " where T1.AnnounceID=" & PollTitleID

	SQLCountString = SQLStr
	If UpDownPageFlag = "1" and Start>0 then
		If whereFlag = 1 Then
			SQLStr = SQLStr & " and T1.ID>" & Start
		Else
			SQLStr = SQLStr & " where T1.ID>" & Start
			whereFlag = 1
		End If
	Else
		If whereFlag = 1 Then
			SQLStr = SQLStr & " and T1.ID<" & Start
		Else
			SQLStr = SQLStr & " where T1.ID<" & Start
			whereFlag = 1
		End If
	end If

	If UpDownPageFlag = "1" then
		SQLStr = SQLStr & " Order by T1.ID ASC"
	Else
		SQLStr = SQLStr & " Order by T1.ID DESC"
	End If

	RecordCount = Request.Form("count")
	If isNumeric(RecordCount) = 0 Then RecordCount = 0
	RecordCount = Fix(cCur(RecordCount))
	If RecordCount < 0 Then RecordCount = 0

	If RecordCount = 0 Then
		SQL = "select PollNum,BoardID,TitleStyle from LeadBBS_Announce where ID=" & PollTitleID
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof then
			RecordCount=0
			Rs.Close
			Set Rs = Nothing
			Response.Write "投票不存在。"
			Exit Sub
		Else
			If cCur(Rs(1)) <> GBL_Board_ID Then
				Rs.Close
				Set Rs = Nothing
				Response.Write "投票不存在。"
				Exit Sub
			End If
			If Rs(2) >= 60 Then
				Rs.Close
				Set Rs = Nothing
				Response.Write "帖子已关闭。"
				Exit Sub
			End If
			RecordCount = Rs(0)
			If RecordCount="" or isNull(RecordCount) or len(RecordCount)<1 Then RecordCount=0
			RecordCount = cCur(RecordCount)
		End If
		Rs.Close
		Set Rs = Nothing
	End If

	Dim FirstID,LastID
	DEF_MaxListNum = Fix(DEF_MaxListNum/2)
	
	Dim MaxRecordID,MinRecordID
	MaxRecordID = Request.Form("max")
	MinRecordID = Request.Form("min")

	If isNumeric(MaxRecordID) = 0 Then MaxRecordID = 0
	MaxRecordID = Fix(cCur(MaxRecordID))
	If MaxRecordID < 0 Then MaxRecordID = 0

	If isNumeric(MinRecordID) = 0 Then MinRecordID = 0
	MinRecordID = Fix(cCur(MinRecordID))
	If MinRecordID < 0 Then MinRecordID = 0
	If RecordCount > DEF_MaxListNum or Start <> 999999999 Then
		If RecordCount > 0 and MaxRecordID = 0 Then
			SQL = "select Max(T1.id) from LeadBBS_VoteUser as T1 " & SQLCountString
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
		End If

		If RecordCount > 0 and MinRecordID = 0 Then
			SQL = "select Min(T1.id) from LeadBBS_VoteUser as T1 " & SQLCountString
			Set Rs = LDExeCute(SQL,0)
		
			If not Rs.Eof Then
				If Rs(0) <> "" Then
					MinRecordID = cCur(Rs(0))
				Else
					MinRecordID = 0
				End If
			End If
			Rs.Close
			Set Rs = Nothing
		End If
	End If

	Dim OL,ObjName,VoteType
	OL = Left(Request.Form("ol"),1)
	If isNumeric(OL) = 0 Then OL = 3
	If OL = 4 Then
		VoteType = 2
		ObjName = "BuyUser"
	Else
		ObjName = "PollUser"
		VoteType = Left(Request.Form("vt"),1)
		If VoteType <> "0" and VoteType <> "1" Then
			SQL = sql_select("select VoteType from LeadBBS_VoteItem where AnnounceID=" & PollTitleID,1)
			Set Rs = LDExeCute(SQL,0)
			If Rs.Eof Then
				Rs.Close
				Set Rs = Nothing
				Response.Write "无相关内容。"
				Exit Sub
			Else
				if Rs(0) then
					VoteType = 1
				else
					VoteType = 0
				end if
				Rs.Close
			End If
			Set Rs = Nothing
			
			If VoteType = 1 Then
				VoteType = 1
			Else
				VoteType = 0
			End If
		Else
			VoteType = cCur(VoteType)
		End If
	End If
	
	Dim ItemGetData
	If VoteType = 0 and (DEF_UsedDataBase = 0 or DEF_UsedDataBase=2) Then
		SQL = sql_select("select T1.ID,T1.UserName,T1.VoteItem,T2.VoteName from LeadBBS_VoteUser as T1 left join LeadBBS_VoteItem as T2 on T2.ID = T1.VoteItem " & SQLStr,DEF_MaxListNum)
	Else
		If OL = 2 Then
			SQL = "Select ID,VoteName from LeadBBS_VoteItem where AnnounceID=" & PollTitleID
			Set Rs = LDExeCute(SQL,0)
			If Rs.Eof Then
				ItemGetData = 0
			Else
				ItemGetData = Rs.GetRows(-1)
			End If
			Rs.Close
			Set Rs = Nothing
		End If
		SQL = sql_select("select T1.ID,T1.UserName,T1.VoteItem from LeadBBS_VoteUser as T1 " & SQLStr,DEF_MaxListNum)
	End If
	Set Rs = LDExeCute(SQL,0)
	Dim Num
	Dim GetData
	If Not rs.Eof Then
		GetData = Rs.GetRows(-1)
		Num = Ubound(GetData,2)
	Else
		Num = -1
	End If
	Rs.close
	Set Rs = Nothing
	
	
	Dim i,N
	If Num>=0 Then
		i=1
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
		If SQL >= DEF_MaxListNum-1 or Start <> 999999999 Then
			Dim UrlStr,PageStr
			UrlStr = "ol=" & OL & "&amp;ID=" & PollTitleID & "&amp;B=" & GBL_Board_ID & "&amp;max=" & MaxRecordID & "&amp;min=" & MinRecordID & "&amp;count=" & RecordCount
			If OL = 2 Then UrlStr = UrlStr & "&amp;vt=" & VoteType
		
			PageStr = PageStr & "<tr><td colspan=""2"" class=""tdbox""><div class=""j_page"">"
			If FirstID >= MaxRecordID Then
				'PageStr = PageStr & "首页" & VbCrLf
				'PageStr = PageStr & " 上页" & VbCrLf
			Else
				PageStr = PageStr & "<a href=""#no"" onclick=""getAJAX('a.asp','" & UrlStr & "&amp;Start=0','" & ObjName & "');"">首页</a> " & VbCrLf
				PageStr = PageStr & " <a href=""#no"" onclick=""getAJAX('a.asp','" & UrlStr & "&amp;Start=" & LngStr(FirstID) & "&amp;UF=1','" & ObjName & "');"">上页</a> " & VbCrLf
			End if
		
			If LastID <= MinRecordID Then
				'PageStr = PageStr & " 下页" & VbCrLf
				'PageStr = PageStr & " 尾页" & VbCrLf
			Else
				PageStr = PageStr & " <a href=#no onclick=""getAJAX('a.asp','" & UrlStr & "&amp;Start=" & LngStr(LastID) & "','" & ObjName & "');"">下页</a> " & VbCrLf
				PageStr = PageStr & " <a href=#no onclick=""getAJAX('a.asp','" & UrlStr & "&amp;Start=1&amp;UF=1','" & ObjName & "');"">尾页</a> " & VbCrLf
			End if
			
			PageStr = PageStr & "<b>共" & RecordCount & "人</b>"
			'If (RecordCount mod DEF_MaxListNum)=0 Then
			'	PageStr = PageStr & " 计<b>" & clng(RecordCount/DEF_MaxListNum) & "</b>页"
			'Else
			'	If RecordCount>=DEF_MaxListNum Then
			'		SQL = fix(RecordCount/DEF_MaxListNum)
			'		If (RecordCount mod DEF_MaxListNum) <> 0 Then SQL = SQL + 1
			'		PageStr = PageStr & " 计<b>" & SQL & "</b>页"
			'	Else
			'		PageStr = PageStr & " 计<b>1</b>页"
			'	End If
			'End If
			'PageStr = PageStr & " 每页<b>" & DEF_MaxListNum & "</b>人"
			PageStr = PageStr & "</div></td></tr>"
		End If
	End If
	%>
	<table border="0" cellpadding="0" cellspacing="0" class="blanktable">
		<tr class="tbinhead"><td colspan="2">
			<div class="value">
	  <%
	If VoteType = 2 Then
		Response.Write "<b>共<span class=""redfont"">" & RecordCount & "</span>个人购买了此帖</b>"
	Else
		Response.Write "<b>共<span class=""redfont"">" & RecordCount & "</span>个人参与投票</b>"
	End If
	%>
			</div>
		</td>
		</tr>
		<tr class="tbinhead">
		<td><div class="value"><%
		If VoteType = 2 Then
			Response.Write "购买人"
		Else
			Response.Write "投票人"
		End If
	    %></div></td>
	    <td><div class="value"><%
		If VoteType = 2 Then
			Response.Write "花费"
		Else
			Response.Write "选项"
		End If
	    %></div></td>
	  </tr>
	<%
	If Num = -1 Then
		Response.Write "<tr><td colspan=""2"">暂时无人投票!</td></tr>"
	End if
	
	Dim TempN,m
	If isArray(ItemGetData) Then
		TempN = Ubound(ItemGetData,2)
		For m = 0 to TempN
			ItemGetData(1,m) = htmlencode(ItemGetData(1,m))
		Next
	Else
		TempN = -1
	End If

	Dim TempArray
	if Num <> -1 then
		i=1
		LastID = GetData(0,ubound(getdata,2))
		For n= MinN to MaxN Step StepValue
			Response.Write "<tr><td valign=""top"" class=""tdbox"">"
			Response.Write "<a href=""../User/" & RW_User(0,"",GetData(1,n),"") & """ target=""_blank"">" & GetData(1,n) & "</a>" & VbCrLf
			Response.Write "</td>"
			If VoteType = 0 and (DEF_UsedDataBase = 0 or DEF_UsedDataBase = 2) Then
				Response.Write "<td class=""tdbox"">" & htmlencode(GetData(3,n)) & "</td>"
			Else
				If TempN >=0 Then
					TempArray = Split(GetData(2,n),",")
					GetData(2,n) = ""
					For i = 0 to Ubound(TempArray)
						For m = 0 to TempN
							If cCur(ItemGetData(0,m)) = cCur(TempArray(i)) Then
								If i = 0 Then
									GetData(2,n) = htmlencode(ItemGetData(1,m))
								Else
									GetData(2,n) = GetData(2,n) & "<br />" & htmlencode(ItemGetData(1,m))
								End If
							End If
						Next
					Next
				End If
				Response.Write "<td class=""tdbox"">" & GetData(2,n) & "</td>"
			End If
			Response.Write "</tr>" & VbCrLf
			i=i+1
		Next
		Response.Write PageStr
	End If
	%>
	      </table>
	<br /><%

End Sub

Sub DisplayBuyAnnounce

	CheckPass()
	If GBL_CHK_Flag <> 1 Then
		Response.Write "<div class=""alert"">" & "请先登录论坛进行购买。</div>"
		Exit Sub
	End If
	Dim AnnounceID,NeedValue,SellUserID

	AnnounceID = Left(Request.Form("AnnounceID"),14)
	If isNumeric(AnnounceID) = 0 or inStr(AnnounceID,",") > 0 or AnnounceID = "" Then
		Response.Write "<div class=""alert"">" & "错误,请提供要购买的帖子信息!</div>" & VbCrLf
		Exit Sub
	End if

	AnnounceID = cCur(AnnounceID)
	Dim Rs,SQL
	SQL = sql_select("Select BoardID,TopicType,NeedValue,UserID from LeadBBS_Announce where id=" & AnnounceID,1)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Response.Write "<div class=""alert"">" & "错误,要购买的帖子不存在!</div>" & VbCrLf
		Rs.Close
		Set Rs = Nothing
		Exit Sub
	End if

	Dim BoardID,TopicType
	BoardID = cCur(Rs("BoardID"))
	TopicType = Rs("TopicType")
	NeedValue = cCur(Rs("NeedValue"))
	SellUserID = cCur(Rs("UserID"))
	Rs.Close
	Set Rs = Nothing
	If (TopicType <> 54 and TopicType <> 114 and TopicType <> 49 and TopicType <> 109) or NeedValue < 1 Then
		Response.Write "<div class=""alert"">" & "此帖子属于免费帖子，不必购买!</div>" & VbCrLf
		Exit Sub
	End If
	
	Dim TypeStr,TypeValue,TypeCol,TypeSn
	If TopicType = 54 or TopicType = 114 Then
		TypeStr = DEF_PointsName(0) 'value name
		TypeValue = GBL_CHK_Points 'value
		TypeCol = "Points" 'table column name
		TypeSn = 4 'sesson array
	Else
		TypeStr = DEF_PointsName(1)
		TypeValue = GBL_CHK_CharmPoint
		TypeCol = "CharmPoint"
		TypeSn = 15
	End If

	If TypeValue < NeedValue Then
		Response.Write "<div class=""alert"">" & "你的" & TypeStr & "不足，目前拥有量为" & TypeValue & "，购买此帖需要" & TypeStr & "" & NeedValue & ".</div>" & VbCrLf
		Exit Sub
	End If

	If GBL_UserID = SellUserID Then
		Response.Write "<div class=""alert"">" & "自己的帖子无需购买.</div>" & VbCrLf
		Exit Sub
	End If

	Set Rs = LDExeCute(sql_select("Select ID from LeadBBS_VoteUser where AnnounceID=" & AnnounceID & " and UserName='" & Replace(GBL_CHK_User,"'","''") & "'",1),0)
	If Not Rs.Eof Then
		Response.Write "<div class=""alert"">" & "你已购买过此帖子.</div>" & VbCrLf
		Rs.Close
		Exit Sub
	End If
	Rs.Close
	Set Rs = Nothing
	CheckAccessLimit()
	If GBL_CHK_TempStr <> "" Then
		Response.Write "<div class=""alert"">" & GBL_CHK_TempStr & "</div>"
		Exit Sub
	End If
	If Request.Form("buysure")="1" Then
		CALL LDExeCute("insert into LeadBBS_VoteUser(UserName,VoteItem,AnnounceID) values('" & Replace(GBL_CHK_User,"'","''") & "','" & NeedValue & "'," & AnnounceID & ")",1)
		CALL LDExeCute("Update LeadBBS_Announce Set PollNum=PollNum+1 where ID=" & AnnounceID,1)
		If DEF_UsedDataBase = 1 Then CALL LDExeCute("Update LeadBBS_Topic Set PollNum=PollNum+1 where ID=" & AnnounceID,1)
		CALL LDExeCute("Update LeadBBS_User Set " & TypeCol & "=" & TypeCol & "+" & NeedValue & " where ID=" & SellUserID,1)
		CALL LDExeCute("Update LeadBBS_User Set " & TypeCol & "=" & TypeCol & "-" & NeedValue & " where ID=" & GBL_UserID,1)
		UpdateSessionValue TypeSn,0-NeedValue,1
		Response.Write "<span class=""greenfont""><b>成功购买论坛帖子，请刷新页面来查看帖子内容．</b></span>"
	Else
		%>
		购买此帖需要花费<span class="redfont"><%=NeedValue%></span><%=TypeStr%>，若要购买请按确定.
		<br /><input type="button" id="buyButton" value="确定购买" class="fmbtn btn_3" onclick="$id('buyButton').style.display='none';$id('BuyResult').style.display='block';getAJAX('a.asp','ol=3&amp;B=<%=BoardID%>&amp;AnnounceID=<%=AnnounceID%>&amp;buysure=1','BuyResult');" /><%
	End If

End Sub

Sub OpinionUserList

	Dim Rs,SQL,PreID,AnnounceID,Count,Index,OldPreID
	AnnounceID = Left(Request.Form("ID"),14)
	If isNumeric(AnnounceID) = 0 Then Exit Sub
	AnnounceID = cCur(Fix(AnnounceID))

	PreID = Left(Request.Form("PreID"),14)
	If isNumeric(PreID) = 0 Then PreID = 0
	PreID = cCur(Fix(PreID))
	OldPreID = PreID

	Count = Left(Request.Form("num"),14)
	If isNumeric(Count) = 0 Then Count = 0
	Count = cCur(Fix(Count))

	Index = Left(Request.Form("Index"),14)
	If isNumeric(Index) = 0 Then Index = 0
	Index = cCur(Fix(Index))

	SQL = "Select ID,UserName,Num,NumType,Opinion,IP,Ndatetime from LeadBBS_Opinion where AnnounceID=" & AnnounceID
	If PreID > 0 Then SQL = SQL & " and ID<" & PreID
	SQL = SQL & " Order by ID DESC"
	sql = sql_select(sql,DEF_TopicContentMaxListNum)
	Set Rs = LDExeCute(SQL,0)

	Dim GetData,Num
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		Exit Sub
	End If

	GetData = Rs.GetRows(DEF_MaxListNum)
	Rs.Close
	Set Rs = Nothing
	Num = Ubound(GetData,2)
	Dim N,Tmp,SuperFlag
	SuperFlag = CheckSupervisorUserName()
	%>
	<div class="opinion_list">
	<ol start="<%=Index+1%>">
	<%
	For N = 0 to Num
		Index = Index + 1
		%>
		<li>
		<%
		If GetData(2,N) <> 0 Then
			Select Case GetData(3,N)
				Case 0
					Tmp = "<span class=""greenfont"">" & DEF_PointsName(0)
				Case 1
					Tmp = "<span class=""bluefont"">" & DEF_PointsName(2)
				Case 2
					Tmp = "<span class=""redfont"">" & DEF_PointsName(1)
			End Select
			%><%=Tmp%><%
			If GetData(2,N) > 0 Then Response.Write "+"
			If GetData(2,N) <> 0 Then Response.Write GetData(2,N)%></span>
			<%
		Else
			Response.Write "<span class=""grayfont"">无评分</span>"
		End If
		If SuperFlag = 1 Then%>
			<span><%=GetData(5,N)%></span>
		<%End If
		If GetData(1,N) = "[LeadBBS]" Then
			Response.Write "<span class=""uname"">系统评价</span>"
		Else%>
		<span><a href="<%=DEF_BBS_HomeUrl%>User/<%=RW_User(0,"",GetData(1,N),"")%>" target="_blank" class="uname"><%=htmlencode(GetData(1,N))%></a></span>
		<%
		End If
		If GetData(4,N) <> "" Then
			%><span class="grayfont"><%=htmlencode(GetData(4,N))%></span><%
		End If%>
		<span class="time"><%=ConvertTimeString(RestoreTime(GetData(6,N)))%></span>
		</li>
		<%
		PreID = GetData(0,N)
	Next
	%>
	</ol>
	<%
	If Index < Count Then
		%>
		<div class="split">
		<a href="javascript:;" onclick="getAJAX('a.asp','ol=5&B=<%=GBL_board_ID%>&ID=<%=AnnounceID%>&num=<%=Count%>&PreID=<%=PreID%>&Index=<%=Index%>','opinion<%=AnnounceID%>');">更多评价...</a>
		</div>
		<%
	ElseIf OldPreID > 0 Then%>
		<div class="split">
		<a href="javascript:;" onclick="getAJAX('a.asp','ol=5&B=<%=GBL_board_ID%>&ID=<%=AnnounceID%>&num=<%=Count%>','opinion<%=AnnounceID%>');">返回...</a>
		</div>
		<%
	End If
	%>
	</div>
	<%

End Sub%>