<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="inc/BoardMaster_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
initDatabase()
GBL_CHK_TempStr = ""
CheckisBoardMasterFlag()

BBS_SiteHead DEF_SiteNameString & " - 注册新用户",0,"" & DEF_PointsName(6) & "管理"


If BDM_isBoardMasterFlag = 1 Then
	Select Case Request("action")
		Case "1"
			If Request("typeflag") = "1" Then
				UserTopicTopInfo(9)
			Else
				UserTopicTopInfo(8)
			End If
			Assessor()
		Case "2"
			UserTopicTopInfo(10)
			BoardMaster_Manage()
		Case Else
			UserTopicTopInfo(1)
			DeleteAllTopAnnounce()
	End Select
Else
	UserTopicTopInfo(0)
	If Request("submitflag")="" Then
		DisplayLoginForm("请先登录")
	Else
		DisplayLoginForm("<span class=""redfont"">" & GBL_CHK_TempStr & "</span>")
	End If
End If
UserTopicBottomInfo()
closeDataBase()
SiteBottom()
If GBL_ShowBottomSure = 1 Then Response.Write GBL_SiteBottomString

Function DeleteAllTopAnnounce

	If Request.Form("submitflag") = "yes" then
		CALL LDExeCute("delete from LeadBBS_TopAnnounce",1)
		Application.Lock
		Set application(DEF_MasterCookies & "TopAnc") = Nothing
		application(DEF_MasterCookies & "TopAnc") = "yes"
		application(DEF_MasterCookies & "TopAncList") = ""
		Application.UnLock
	
		Response.Write "<div class=""title"">总固顶信息清除完毕并完成更新！</div>"
	Else%>
		<form action=ClearTopAnc.asp method=post>
				<div class="title">注意：此功能将完成以下功能：</div>
				<ol>
				<li>解除所有总固顶帖子</li>
				<li>删除可能存在的冗余总固顶数据</li>
				<li>解决因论坛意外产生的冗余数据进而不能继续总固顶</li>
				</ol>
		<input type=hidden name=submitflag value="yes">
		<div class="value2">
		<input type=submit value="确定操作" class="fmbtn btn_4">
		</div>
		</form>
	<%
	End If

End Function

Sub Assessor

	If (GetBinarybit(GBL_CHK_UserLimit,18) = 1 or CheckSupervisorUserName() = 1) Then
	Else
		Exit Sub
	End If

	Dim DelID,SQL,RS,typeflag,DN,DelStr
	DelID = Request("ID")
	
	Dim TitleStyle
	If inStr(DelID,",") = 0 Then
		If isNumeric(DelID) = 0 Then DelID = 0
		DelID = Fix(cCur(DelID))
		If DelID > 0 Then
			Set Rs = LDExeCute("Select TA.TitleStyle,TR.AnnounceID from LeadBBS_Assessor as TR left join LeadBBS_Announce as TA on TR.AnnounceID = TA.ID where TR.ID=" & DelID,0)
			If Not Rs.Eof Then
				TitleStyle = Rs(0)
				If TitleStyle & "" <> "" Then
					If TitleStyle >= 60 Then
						TitleStyle = TitleStyle - 60
						CALL LDExeCute("Update LeadBBS_Announce set TitleStyle=" & TitleStyle & " where ID=" & Rs(1),1)
					End If
				End If
				CALL LDExeCute("Delete from LeadBBS_Assessor where ID=" & DelID,1)
				'Response.Redirect DEF_BBS_HomeUrl & "a/" & RW_a(toNum(Request("pb"),0),Rs(1),1,1,"")
			Else
				Response.Write "错误，要审核的帖子并不存在！"
				Exit Sub
			End If
		End If
	Else
		DelStr = Split(DelID,",")
		Rs = Ubound(DelStr,1)
		For DN = 0 to Rs
			DelID = Trim(DelStr(DN))
			If isNumeric(DelID) = 0 Then DelID = 0
			DelID = Fix(cCur(DelID))
			If DelID > 0 Then
				Set Rs = LDExeCute("Select TA.TitleStyle,TR.AnnounceID from LeadBBS_Assessor as TR left join LeadBBS_Announce as TA on TR.AnnounceID = TA.ID where TR.ID=" & DelID,0)
				If Not Rs.Eof Then
					TitleStyle = Rs(0)
					If TitleStyle & "" <> "" Then
						If TitleStyle >= 60 Then
							TitleStyle = TitleStyle - 60
							CALL LDExeCute("Update LeadBBS_Announce set TitleStyle=" & TitleStyle & " where ID=" & Rs(1),1)
						End If
					End If
					CALL LDExeCute("Delete from LeadBBS_Assessor where ID=" & DelID,1)
					Response.Write "<br>编号为 " & DelID & " 的帖子成功通过审核!"
				Else
					Response.Write "<br>编号为 " & DelID & " 的帖子已不存在,可能已作删除！"
				End If
			End If
		Next
	End If
	Response.Write "<p>"

	typeflag = Request("typeflag")
	
	typeflag = Left(Trim(Request("typeflag")),14)
	If isNumeric(typeflag)=0 or typeflag="" Then typeflag=0
	typeflag = Fix(cCur(typeflag))
	If typeflag <> 1 Then typeflag = 0

	Dim UpDownPageFlag
	UpDownPageFlag = Request("UpDownPageFlag")

	Dim Start

	Dim SQLendString

	Start = Left(Trim(Request("Start")),14)
	If isNumeric(Start)=0 or Start="" Then Start=999999999
	Start = cCur(Start)
	If Start = 0 Then Start=999999999

	Dim SQLCountString,whereFlag
	whereFlag = 1
	SQLendString = " where typeflag=" & typeflag

	SQLCountString = SQLendString
	If UpDownPageFlag = "1" and Start>0 then
		If whereFlag = 1 Then
			SQLendString = SQLendString & " and T1.ID>" & Start
		Else
			SQLendString = SQLendString & " where T1.ID>" & Start
			whereFlag = 1
		End If
	Else
		If whereFlag = 1 Then
			SQLendString = SQLendString & " and T1.ID<" & Start
		Else
			SQLendString = SQLendString & " where T1.ID<" & Start
			whereFlag = 1
		End If
	end If

	If UpDownPageFlag = "1" then
		SQLendString = SQLendString & " Order by T1.ID ASC"
	Else
		SQLendString = SQLendString & " Order by T1.ID DESC"
	End If
	
	Dim MaxRecordID,MinRecordID
	MaxRecordID = 0

	SQL = "select Max(T1.id) from LeadBBS_Assessor as T1 " & SQLCountString
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
	
	SQL = "select Min(T1.id) from LeadBBS_Assessor as T1 " & SQLCountString
	Set Rs = LDExeCute(SQL,0)

	If not Rs.Eof Then
		If Rs(0) <> "" Then
			MinRecordID = cCur(Rs(0))
		else
			MinRecordID = 0
		end If
	End If
	Rs.Close
	Set Rs = Nothing

	Dim FirstID,LastID

	SQL = sql_select("select T1.ID,T1.UserName,T1.Title,T1.NdateTime,T1.BoardID,T2.BoardName,T1.AnnounceID,T1.Content,T1.HTMLFlag,T1.TypeFlag from LeadBBS_Assessor as T1 left join LeadBBS_Boards as T2 on T1.BoardID=T2.BoardID " & SQLendString,DEF_MaxListNum)
	Set Rs = LDExeCute(SQL,0)
	Dim Num
	Dim GetData
	If Not rs.Eof Then
		GetData = Rs.GetRows(DEF_MaxListNum)
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
		SQL = ubound(GetData,2)
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
		EndwriteQueryString = "?action=1&typeflag=" & typeflag
	
		PageSplictString = PageSplictString & "&nbsp;"
		If FirstID >= MaxRecordID Then
			PageSplictString = PageSplictString & "<span class=grayfont>首页</span> " & VbCrLf
			PageSplictString = PageSplictString & " <span class=grayfont>上页</span> " & VbCrLf
		else
			PageSplictString = PageSplictString & "<a href=ClearTopAnc.asp" & EndwriteQueryString & "&Start=0>首页</a> " & VbCrLf
			PageSplictString = PageSplictString & " <a href=ClearTopAnc.asp" & EndwriteQueryString & "&Start=" & LngStr(FirstID) & "&UpDownPageFlag=1>上页</a> " & VbCrLf
		end if
	
		if LastID<MaxRecordID and LastID<>0 then
		else
		end if
	
		If LastID <= MinRecordID Then
			PageSplictString = PageSplictString & " <span class=grayfont>下页</span> " & VbCrLf
			PageSplictString = PageSplictString & " <span class=grayfont>尾页</span> " & VbCrLf
		else
			PageSplictString = PageSplictString & " <a href=ClearTopAnc.asp" & EndwriteQueryString & "&Start=" & LngStr(LastID) & ">下页</a> " & VbCrLf
			PageSplictString = PageSplictString & " <a href=ClearTopAnc.asp" & EndwriteQueryString & "&Start=1&UpDownPageFlag=1>尾页</a> " & VbCrLf
		end if
		
		'PageSplictString = PageSplictString & "共<b>" & recordCount & "</b>帖待审核"
		'If (recordCount mod DEF_MaxListNum)=0 Then
		'	PageSplictString = PageSplictString & " 计<b>" & clng(recordCount/DEF_MaxListNum) & "</b>页"
		'Else
		'	If recordCount>=DEF_MaxListNum Then
		'		PageSplictString = PageSplictString & " 计<b>" & clng(recordCount/DEF_MaxListNum)+1 & "</b>页"
		'	Else
		'		PageSplictString = PageSplictString & " 计<b>1</b>页"
		'	End If
		'End If
		PageSplictString = PageSplictString & " 每页<b>" & DEF_MaxListNum & "</b>个"
	
	End If
	%>
	<script src="<%=DEF_BBS_HomeUrl%>a/inc/leadcode.js"></script>

<script type="text/javascript">
var GBL_domain="<%=DEF_AbsolutHome%>";
var DEF_DownKey="<%=UrlEncode(DEF_DownKey)%>";
HU="<%=DEF_BBS_HomeUrl%>";
</script>
	<div class="title">待审核帖子信息：<%
	If typeflag = 1 Then
		Response.Write " 先看后审(发帖开放浏览,但提示审核)"
	Else
		Response.Write " 先审后看(完成审核后开放浏览)"
	End If%></div>
	
	<div class="value2 grayfont">点击审核将删除审核信息（关闭信息将同时开放显示），并进入查看具体帖子界面</div>
	<table border=0 cellpadding="0" class="table_in" width="100%">
	<form action="ClearTopAnc.asp" method="post">
	<input type="hidden" name="action" value="1">
	<input type="hidden" name="pb" value="1">
	<input type=hidden name="typeflag" value="<%=typeflag%>">
	  <tbody> 
	  <tr class=tbinhead>
	    <td width=100><div class=value>编号</div></td>
	    <td width=100><div class=value>发帖人</div></b></td>
	    <td><div class=value>版面</div></b></td>
	    <td width=140><div class=value>时间</div></td>
	    <td width=74><div class=value>审核</div></td>
	  </tr>
	<%
	If Num = -1 Then
		Response.write "<tr><td colspan=5 class=tdbox>无待审帖的帖子．</td></tr>"
	End if

	Dim TempN,Temp1
	
	if Num <> -1 then
		i=1
		LastID = GetData(0,ubound(GetData,2))
		For n = MinN to MaxN Step StepValue
			Response.Write "<tr><td class=tdbox><input class=fmchkbox type=checkbox name=id value=" & GetData(0,N) & " checked>"
			Response.Write GetData(0,N)
			Response.Write "</td><td class=tdbox>"
			
			'T1.ID,T1.UserName,T1.Title,T1.NdateTime,T1.BoardID,T2.BoardName,T1.AnnounceID
			Response.Write "<a href=" & DEF_BBS_HomeUrl & "User/" & RW_User(0,"",GetData(1,N),"") & " target=_blank>" & htmlencode(GetData(1,N)) & "</a>"
			Response.Write "</td><td class=tdbox>"
			Response.Write "<a href=" & DEF_BBS_HomeUrl & "b/" & RW_b(GetData(4,N),0,"") & " target=_blank>" & GetData(5,N) & "</a>"
			Response.Write "</td><td class=""tdbox grayfont"">"
			Response.Write RestoreTime(GetData(3,N))
			Response.Write "</td><td class=tdbox>"
			Response.Write "<a href=ClearTopAnc.asp?action=1&pb=" & GetData(4,N) & "&id=" & GetData(0,N) & "&typeflag=" & GetData(9,n) & " target=_blank><span class=bluefont>通过审核</span></a>"
			Response.Write "</td></tr>" & VbCrLf
			Response.Write "<tr><td colspan=5 class=tdbox>"
			Response.Write "<div class=value2><span class=grayfont>标题：</span><a href=" & DEF_BBS_HomeUrl & "a/" & RW_a(GetData(4,N),GetData(6,N),1,1,"") & " target=_blank><span class=bluefont>" & GetData(2,N) & "</span></a></div>"
			If (GetData(8,n) = 0 or GetData(8,n) = 2) Then GetData(7,n) = PrintTrueText(GetData(7,n))
			Response.Write "<div class=""value2 grayfont"">内容：</div><hr class=splitline><div class=value2>"
			If GetData(8,n) <> 2 Then
				Response.Write GetData(7,n)
			Else
				Response.Write "<table border=""0"" cellpadding=""0""><tr><td><span id=Content" & GetData(0,n) & ">" & GetData(7,n) & "</span></td></tr></table>"
				Response.Write "<script language=javascript>" & VbCrLf & "<!--" & VbCrLf & "leadcode('Content" & GetData(0,n) & "');" & VbCrLf & "//-->" & VbCrLf & "</script>"
			End If
			Response.Write "</div></td></tr>"
			i=i+1
		next
	End If
	If Num <> -1 Then
		Response.Write "<tr><td colspan=5 class=tdbox>"
		Response.Write PageSplictString
		Response.Write "</td></tr>"
	End If
	Response.Write "<tr><td colspan=5 class=tdbox>"
	Response.Write "<input name=submit2 type=submit value='批审选择帖' class=""fmbtn btn_4"">"	
	Response.Write "</td></tr></form>"
	Response.Write "</table>"

End Sub

Function PrintTrueText(tempString)

	If tempString<>"" Then
		PrintTrueText=Replace(Replace(Replace(Replace(Replace(htmlEncode(tempString),VbCrLf & " ","<br>" & "&nbsp;"),VbCrLf,"<br>" & VbCrLf),"   "," &nbsp; "),"  "," &nbsp;"),chr(9)," &nbsp; &nbsp; &nbsp;")

		If Left(PrintTrueText,1) = chr(32) Then
			PrintTrueText = "&nbsp;" & Mid(PrintTrueText,2)
		End If
	Else
		PrintTrueText=""
	End If

End Function

Sub BoardMaster_Manage

	

End Sub
%>