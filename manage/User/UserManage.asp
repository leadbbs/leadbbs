<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass()

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("用户管理")
If GBL_CHK_Flag=1 Then
	UserBrowser()
Else
DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

Function UserBrowser

	GBL_CHK_TempStr=""
	Dim Rs,SQL
	Dim UpDownPageFlag
	UpDownPageFlag = Request("UpDownPageFlag")

	Dim Start,recordCount,key
	recordCount=0
	
	Dim SQLendString

	Start = Left(Trim(Request("Start")),14)
	Start = start
	If isNumeric(Start)=0 or Start="" Then Start=0
	Start = cCur(Start)
	key = Request.Form("key")
	If key="" Then key = Request("key")

	Dim SQLCountString,whereFlag
	SQLendString=""
	whereFlag = 0

	Rem 下面的代码使目前暂不提供城市分类双重查询

	If key<>"" Then
		If whereFlag = 1 Then
			SQLendString = SQLendString & " and LeadBBS_User.UserName='" & Replace(key,"'","''") & "'"
		Else
			SQLendString = SQLendString & " where LeadBBS_User.UserName='" & Replace(key,"'","''") & "'"
			whereFlag = 1
		End If
	End If
	SQLCountString = SQLendString
	Dim MaxRecordID,MinRecordID
	MaxRecordID = 0
	MinRecordID = 0
	Dim FirstID,LastID	
	If key="" Then
		If UpDownPageFlag = "1" and Start>0 then
			If whereFlag = 1 Then
				SQLendString = SQLendString & " and LeadBBS_User.ID<" & Start
			Else
				SQLendString = SQLendString & " where LeadBBS_User.ID<" & Start
				whereFlag = 1
			End If
		Else
			If whereFlag = 1 Then
				SQLendString = SQLendString & " and LeadBBS_User.ID>" & Start
			Else
				SQLendString = SQLendString & " where LeadBBS_User.ID>" & Start
				whereFlag = 1
			End If
		end If
	
		If UpDownPageFlag = "1" then
			'If DEF_IDFocusFlag<> 2 Then SQLendString = SQLendString & " Order by  LeadBBS_User.ID DESC"
			SQLendString = SQLendString & " Order by  LeadBBS_User.ID DESC"
		Else
			'If DEF_IDFocusFlag<> 1 Then SQLendString = SQLendString & " Order by  LeadBBS_User.ID ASC"
			SQLendString = SQLendString & " Order by  LeadBBS_User.ID ASC"
		End If
	
		SQL = "select Max(id) from LeadBBS_User " & SQLCountString
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
		SQL = "select Min(id) from LeadBBS_User " & SQLCountString
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
		SQL = "select UserCount from LeadBBS_SiteInfo"
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof then
			recordCount=0
		Else
			recordCount=cCur(rs(0))
			If recordCount="" or isNull(recordCount) or len(recordCount)<1 Then recordCount=0
		End If
		Rs.Close
		Set Rs = Nothing
	Else
		
	End If
	
	SQL = sql_select("select LeadBBS_User.ID,LeadBBS_User.UserName,LeadBBS_User.Points,LeadBBS_User.ApplyTime,LeadBBS_User.Prevtime from LeadBBS_User " & SQLendString,DEF_MaxListNum)
	Set Rs = LDExeCute(SQL,0)
	Dim Num
	Dim GetData
	If Not rs.Eof Then
		GetData = Rs.GetRows(-1)
		Num = Ubound(GetData,2)+1
		If Num > Recordcount Then RecordCount = Num
	Else
		Num = 0
	End If
	Rs.close
	Set Rs = Nothing
	
	Dim i,N
	If Num>0 Then
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
	EndwriteQueryString = "?GBL_CTG_ID=0"
	If key<>"" Then EndwriteQueryString = EndwriteQueryString & "&key=" & urlencode(key)

	PageSplictString = PageSplictString & "<table border=0 cellspacing=0 cellpadding=0><tr><td>&nbsp;"
	if FirstID>MinRecordID and FirstID<>0 then
		PageSplictString = PageSplictString & "<a href=UserManage.asp" & EndwriteQueryString & "&Start=0&SubmitFlag=3829EwoqIaNfoG>首页</a> " & VbCrLf
	else
		PageSplictString = PageSplictString & "<span class=grayfont>首页</span> " & VbCrLf
	end if

	if FirstID > MinRecordID and FirstID<>0 then
		PageSplictString = PageSplictString & " <a href=UserManage.asp" & EndwriteQueryString & "&Start=" & LngStr(FirstID) & "&UpDownPageFlag=1&SubmitFlag=3829EwoqIaNfoG>上页</a> " & VbCrLf
	else
		PageSplictString = PageSplictString & " <span class=grayfont>上页</span> " & VbCrLf
	end if

	if LastID<MaxRecordID and LastID<>0 then
		PageSplictString = PageSplictString & " <a href=UserManage.asp" & EndwriteQueryString & "&Start=" & LngStr(LastID) & "&SubmitFlag=3829EwoqIaNfoG>下页</a> " & VbCrLf
	else
		PageSplictString = PageSplictString & " <span class=grayfont>下页</span> " & VbCrLf
	end if

	if LastID < MaxRecordID and LastID<>0 then
		PageSplictString = PageSplictString & " <a href=UserManage.asp" & EndwriteQueryString & "&Start=" & LngStr(MaxRecordID+1) & "&UpDownPageFlag=1&SubmitFlag=3829EwoqIaNfoG>尾页</a> " & VbCrLf
	else
		PageSplictString = PageSplictString & " <span class=grayfont>尾页</span> " & VbCrLf
	end if
	PageSplictString = PageSplictString & "共<b>" & recordCount & "</b>条信息"
	If (recordCount mod DEF_MaxListNum)=0 Then
		PageSplictString = PageSplictString & " 计<b>" & clng(recordCount/DEF_MaxListNum) & "</b>页"
	Else
		If recordCount>=DEF_MaxListNum Then
			PageSplictString = PageSplictString & " 计<b>" & clng(recordCount/DEF_MaxListNum)+1 & "</b>页"
		Else
			PageSplictString = PageSplictString & " 计<b>1</b>页"
		End If
	End If
	PageSplictString = PageSplictString & " 每页<b>" & DEF_MaxListNum & "</b>条"
	PageSplictString = PageSplictString & "</td><td><form action=UserManage.asp><input size=6 name=key value=" & chr(34) & htmlencode(key) & """ class=fminpt><input type=submit name=submit value=搜 class=fmbtn>[请输全名]</td></form></tr></table>"
	%>
	<script language=javascript>
	function opw(f,r,id)
	{
		document.location.href = f+'&'+r+'='+id;
	}
	</script>
	<table border=0 cellpadding=0 cellspacing=0 width="100%" class=frame_table>
	<tr class=frame_tbhead>
		<td wdith=66><div class=value>ID</div></td>
		<td width=50%><div class=value>名称</div></td>
		<td wdith=66><div class=value><%=DEF_PointsName(0)%></div></td>
		<td wdith=120><div class=value>注册时间</div></td>
		<td wdith=120><div class=value>最后登录</div></td>
	</tr>
<%
		For N = MinN to MaxN Step StepValue
			%>
	<tr class=TBBG9>
		<td class=tdbox><%=LngStr(GetData(0,n))%></td>
		<td class=tdbox>
  			<a href=<%=DEF_BBS_HomeUrl%>User/LookUserInfo.asp?id=<%=LngStr(GetData(0,n))%>><%=htmlencode(GetData(1,n))%></a>
  			<a href=UserModify.asp?Form_ID=<%=LngStr(GetData(0,n))%> title=修改用户资料及权限><span class=greenfont>修改</span></a>
  			<a href=UserDelete.asp?GBL_CTG_DELETEID=<%=LngStr(GetData(0,n))%>><span class=redfont title=仅单纯的删除用户资料>删</span></a>
  			<a href='javascript:opw("UpdateUserAnnounce2.asp?B=<%=GBL_board_ID%>","ID",<%=LngStr(GetData(0,n))%>);' title=修复用户发帖量及<%=DEF_PointsName(3)%>数据和短消息状态>修复</a>
  			<a href='javascript:opw("DelUserAllAnnounce.asp?B=<%=GBL_board_ID%>","DelUserID",<%=LngStr(GetData(0,n))%>);' title=删除此用户的好友资料，帖子收藏，发表帖子，上传附件等资料，不减<%=DEF_PointsName(0)%>>删资料</a>
  			<a href='javascript:opw("DelUserAllAnnounce.asp?B=<%=GBL_board_ID%>&dflag=onlyupload","DelUserID",<%=LngStr(GetData(0,n))%>);' title=此项同删除资料的区别在于只删除用户的上传附件>删附件</a></td>
		<td class=tdbox><%=GetData(2,n)%></td>
		<td class=tdbox><%=RestoreTime(Left(GetData(3,n),8))%></td>
		<td class=tdbox><%=RestoreTime(Left(GetData(4,n),8))%></td>
	</tr><%
			i = i+1
			If i > DEF_MaxListNum then Exit For
		next
%>
	<tr class=TBfour>
		<td class=tdbox height="30" valign="bottom" colspan=5>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td height="20">
					<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" height="3">
					<tr>
						<td></td>
					</tr>
					</table>
					<%=PageSplictString%></td>
			</tr>
			</table>
		</td>
	</tr>
	</table>
	<%
	Else
		Response.Write "<div class=alert>没有符合条件的记录。</div>" & VbCrLf
	End If

End Function
%>