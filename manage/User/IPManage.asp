<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass()

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("屏蔽ＩＰ地址管理")
If GBL_CHK_Flag=1 Then
	LoginAccuessFul()
Else
DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

Function LoginAccuessFul

	Dim Rs,SQL,NewNum
	Set rs = Server.CreateObject("ADODB.Recordset")

	GBL_CHK_TempStr=""
	Dim UpDownPageFlag
	UpDownPageFlag = Request("UpDownPageFlag")

	Dim Start,recordCount,key
	recordCount=0
	
	Dim SQLendString

	Start = Left(Trim(Request("Start")),14)
	Start = start
	If isNumeric(Start)=0 or Start="" Then Start=999999999
	Start = cCur(Start)
	If Start = 0 Then Start=999999999

	Dim SQLCountString,whereFlag

	Rem 下面的代码使目前暂不提供城市分类双重查询
	
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
	end If

	If UpDownPageFlag = "1" then
		SQLendString = SQLendString & " Order by ID ASC"
	Else
		SQLendString = SQLendString & " Order by ID DESC"
	End If
	
	Dim MaxRecordID,MinRecordID
	MaxRecordID = 0

	SQL = "select Max(id) from LeadBBS_ForbidIP " & SQLCountString
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
	
	SQL = "select Min(id) from LeadBBS_ForbidIP " & SQLCountString
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
	SQL = "select count(*) from LeadBBS_ForbidIP " & SQLCountString
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof then
		recordCount = 0
	Else
		recordCount = Rs(0)
		If recordCount = "" or isNull(recordCount) or len(recordCount)<1 Then recordCount=0
		RecordCount = ccur(RecordCount)
	End If
	Rs.Close
	Set Rs = Nothing

	SQL = sql_select("select ID,IPStart,IPEnd,IPNumber,ExpiresTime,WhyString from LeadBBS_ForbidIP " & SQLendString,DEF_MaxListNum)
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
	
		Dim EndwriteQueryString,PageSplictString
		EndwriteQueryString = "?test=ttt"
	
		PageSplictString = PageSplictString & "<div class=frameline>"
		If FirstID >= MaxRecordID Then
			PageSplictString = PageSplictString & "<span class=grayfont>首页</span> " & VbCrLf
			PageSplictString = PageSplictString & " <span class=grayfont>上页</span> " & VbCrLf
		else
			PageSplictString = PageSplictString & "<a href=IPManage.asp" & EndwriteQueryString & "&Start=0>首页</a> " & VbCrLf
			PageSplictString = PageSplictString & " <a href=IPManage.asp" & EndwriteQueryString & "&Start=" & LngStr(FirstID) & "&UpDownPageFlag=1>上页</a> " & VbCrLf
		end if
	
		if LastID<MaxRecordID and LastID<>0 then
		else
		end if
	
		If LastID <= MinRecordID Then
			PageSplictString = PageSplictString & " <span class=grayfont>下页</span> " & VbCrLf
			PageSplictString = PageSplictString & " <span class=grayfont>尾页</span> " & VbCrLf
		else
			PageSplictString = PageSplictString & " <a href=IPManage.asp" & EndwriteQueryString & "&Start=" & LngStr(LastID) & ">下页</a> " & VbCrLf
			PageSplictString = PageSplictString & " <a href=IPManage.asp" & EndwriteQueryString & "&Start=1&UpDownPageFlag=1>尾页</a> " & VbCrLf
		end if
		
		PageSplictString = PageSplictString & "&nbsp;共<b>" & recordCount & "</b>条记录"
		If (recordCount mod DEF_MaxListNum)=0 Then
			PageSplictString = PageSplictString & " 计<b>" & clng(recordCount/DEF_MaxListNum) & "</b>页"
		Else
			If recordCount>=DEF_MaxListNum Then
				SQL = fix(recordCount/DEF_MaxListNum)
				If (recordCount mod DEF_MaxListNum) <> 0 Then SQL = SQL + 1
				PageSplictString = PageSplictString & " 计<b>" & SQL & "</b>页"
			Else
				PageSplictString = PageSplictString & " 计<b>1</b>页"
			End If
		End If
		PageSplictString = PageSplictString & " 每页<b>" & DEF_MaxListNum & "</b>条"
		PageSplictString = PageSplictString & "</div>"
	
	End If

	If DEF_EnableForbidIP = 0 Then
	%>
	<div class=alert>目前IP屏蔽功能处于关闭状态, 你可以至全局参数中开启IP屏蔽功能.</div>
	<%End If%>
	
	<script language=javascript>
		function kill(killID)
		{
			window.open('DeleteIP.asp?kasdie=3&KillID='+killID,'','width=450,height=37,scrollbars=auto,status=no');
		}
	</script>
	
	<%Response.Write "<b>共<font color=ff0000 class=redfont>" & recordCount & "</font>个屏蔽项目</b>"%> <a href=NewForbidIP.asp>点击这里添加屏蔽ＩＰ地址</a>
	<table border=0 cellpadding=0 cellspacing=0 width="100%" class=frame_table>
	<tbody> 
	<tr class=frame_tbhead>
		<td width=90><div class=value>编目</div></td>
		<td width=240><div class=value>ＩＰ范围</div></td>
		<td width=90><div class=value>数量</div></td>
		<td width=42><div class=value>解除</div></td>
		<td><div class=value>说明</div></td>
	</tr>
	<%
	If Num = -1 Then
		response.write "<tr class=TBfour><td colspan=6 height=30>&nbsp; 没有任何屏蔽ＩＰ地址，<a href=NewForbidIP.asp>点击这里添加新屏蔽ＩＰ地址</a>。</td></tr>"
	end if

	Dim TempN

	if Num <> -1 then
		i=1
		LastID = GetData(0,ubound(getdata,2))
		for n= MinN to MaxN Step StepValue
			Response.Write "<tr><td class=tdbox width=30>" & LngStr(GetData(0,n)) & "</td>"
			Response.Write "<td class=tdbox width=200>" & RestoreIPAddress(GetData(1,n)) & " - "
			Response.Write RestoreIPAddress(GetData(2,n)) & "</td>"
			Response.Write "<td class=tdbox width=30>" & GetData(3,n) & "</td>"
			Response.Write "<td class=tdbox width=25><a href='javascript:kill(" & LngStr(GetData(0,n)) & ");'>解除</a></td>"
			Response.Write "<td class=tdbox>"
			If GetData(5,n) <> "" Then Response.Write htmlencode(GetData(5,n)) & "<br>"
			If cCur(GetData(4,n)) > 0 Then
				Response.Write "<span class=grayfont>自解除时间：" & RestoreTime(GetData(4,n))
			Else
				Response.Write "<span class=grayfont>此IP永久屏蔽，不能自动解除"
			End If
			Response.Write "</span></td>"
			Response.Write "</tr>" & VbCrLf
			i=i+1
		next
	End If
	If PageSplictString<>"" Then Response.Write "<tr><td class=tdbox colspan=5>" & PageSplictString & "</td></tr>"
	%>
	</table>
	<%

End Function

Function RestoreIPAddress(NIP)

	NIP = Right("000000000000" & cStr(NIP),12)
	RestoreIPAddress = Left(NIP,3) & "." & Mid(NIP,4,3) & "." & Mid(NIP,7,3) & "." & Mid(NIP,10,3)

End Function%>