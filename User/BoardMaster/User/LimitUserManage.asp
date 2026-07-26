<!-- #include file=../../../inc/BBSsetup.asp -->
<!-- #include file=../../../inc/Board_popfun.asp -->
<!-- #include file=../../../inc/Upload_Setup.asp -->
<!-- #include file=../../../inc/Limit_fun.asp -->
<!-- #include file=../inc/BoardMaster_Fun.asp -->
<!-- #include file=../../../User/inc/Fun_SendMessage.asp -->
<%
DEF_BBS_HomeUrl = "../../../"
initDatabase
GBL_CHK_TempStr = ""
CheckisBoardMasterFlag

BBS_SiteHead DEF_SiteNameString & " - 注册新用户",0,"" & DEF_PointsName(6) & "管理"

Dim LMT_Action

rem for special user
Dim GBL_UserName,GBL_Assort,GBL_ndatetime,GBL_WhyString,GBL_ExpiresTime
GBL_ExpiresTime = -1
Dim GBL_UserName_UserLimit,GBL_UserName_UserID

rem for fob ip
Dim GBL_IPStart,GBL_IPEnd
Dim GBL_AnnounceID,GBL_MessageID

rem for modifyuser
Dim GBL_ModifyMode,GBL_UserName_FaceUrl
Dim GBL_UserName_UnderWrite,GBL_UserName_UserTitle
GBL_ModifyMode = 0


If GBL_CHK_Flag=1 and BDM_isBoardMasterFlag = 1 and BDM_SpecialPopedomFlag = 1 Then
	LMT_Action = Request("action")
	Select Case LMT_Action
		Case "specialuser"
			Select Case Left(Request("GBL_Assort"),14)
				Case "4"
					UserTopicTopInfo(4)
				Case "5"
					UserTopicTopInfo(5)
				Case Else
					UserTopicTopInfo(3)
			End Select
			NewSpecialUser
		Case "fobip"
			UserTopicTopInfo(6)
			DisplayNewForbidIP
		Case "modifyuser"
			UserTopicTopInfo(7)
			DisplayModifyUser
		Case "clear"
			UserTopicTopInfo(10)
			View_ClearExpiresInfo
		Case Else
			LMT_Action = ""
			UserTopicTopInfo(2)
			SpecialUserBrowser
	End Select
Else
	UserTopicTopInfo(0)
	If Request("submitflag")="" Then
		DisplayLoginForm("请先登录")
	Else
		DisplayLoginForm("<span class=""redfont"">" & GBL_CHK_TempStr & "</span>")
	End If
End If
UserTopicBottomInfo
closeDataBase
SiteBottom
If GBL_ShowBottomSure = 1 Then Response.Write GBL_SiteBottomString

Function SpecialUserBrowser

	GBL_CHK_TempStr=""
	Dim Rs,SQL
	Dim UpDownPageFlag
	UpDownPageFlag = Request("UpDownPageFlag")
	
	Dim Assort
	Assort = Left(Request.QueryString("Assort"),14)
	If isNumeric(Assort) = 0 Then Assort = 3
	Assort = Fix(cCur(Assort))
	If Assort < 3 or Assort > 6 then Assort = 3

	Dim Start,key
	'Dim recordCount
	'recordCount=0
	
	Dim SQLendString

	Start = Left(Trim(Request("Start")),14)
	Start = start
	If isNumeric(Start)=0 or Start="" Then Start=0
	Start = cCur(Start)
	key = Request.Form("key")
	If key="" Then key = Request("key")

	Dim SQLCountString,whereFlag
	SQLendString=""
	SQLendString = " where T1.Assort=" & Assort
	whereFlag = 1

	If key<>"" Then
		If whereFlag = 1 Then
			SQLendString = SQLendString & " and T1.UserName like'" & Replace(key,"'","''") & "%'"
		Else
			SQLendString = SQLendString & " where T1.UserName like'" & Replace(key,"'","''") & "%'"
			whereFlag = 1
		End If
	End If
	SQLCountString = SQLendString
	If UpDownPageFlag = "1" and Start>0 then
		If whereFlag = 1 Then
			SQLendString = SQLendString & " and T1.ID<" & Start
		Else
			SQLendString = SQLendString & " where T1.ID<" & Start
			whereFlag = 1
		End If
	Else
		If whereFlag = 1 Then
			SQLendString = SQLendString & " and T1.ID>" & Start
		Else
			SQLendString = SQLendString & " where T1.ID>" & Start
			whereFlag = 1
		End If
	end If
	
	If UpDownPageFlag = "1" then
		'If DEF_IDFocusFlag<> 2 Then SQLendString = SQLendString & " Order by  T1.ID DESC"
		SQLendString = SQLendString & " Order by  T1.ID DESC"
	Else
		'If DEF_IDFocusFlag<> 1 Then SQLendString = SQLendString & " Order by  T1.ID ASC"
		SQLendString = SQLendString & " Order by  T1.ID ASC"
	End If
	
	Dim MaxRecordID,MinRecordID
	MaxRecordID = 0

	SQL = "select Max(T1.id) from LeadBBS_SpecialUser as T1 " & SQLCountString
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
	
	SQL = "select Min(id) from LeadBBS_SpecialUser as T1 " & SQLCountString
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

	SQL = sql_select("select T1.ID,T1.UserID,T1.UserName,T1.ndatetime,T1.Assort,t2.BoardName,T1.BoardID,T1.WhyString,T1.ExpiresTime from LeadBBS_SpecialUser as T1 left join LeadBBS_Boards as T2 on T1.BoardID=T2.BoardID" & SQLendString,DEF_MaxListNum)

	Set Rs = LDExeCute(SQL,0)
	Dim Num
	Dim GetData
	If Not rs.Eof Then
		GetData = Rs.GetRows(-1)
		Num = Ubound(GetData,2) + 1
	Else
		Num = 0
	End If
	Rs.close
	Set Rs = Nothing
	
	
	Dim i,N,DoStr

	DoStr = LimitUserManage_NavInfo(Assort)

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
		EndwriteQueryString = "?Assort=" & Assort
		If key<>"" Then EndwriteQueryString = EndwriteQueryString & "&key=" & urlencode(key)
	
		PageSplictString = PageSplictString & "<div class=j_page>"
		if FirstID>MinRecordID and FirstID<>0 then
			PageSplictString = PageSplictString & "<a href=LimitUserManage.asp" & EndwriteQueryString & "&Start=0&SubmitFlag=3829EwoqIaNfoG>首页</a> " & VbCrLf
		else
			'PageSplictString = PageSplictString & "<font color=999999 class=grayfont>首页</font> " & VbCrLf
		end if
	
		if FirstID > MinRecordID and FirstID<>0 then
			PageSplictString = PageSplictString & " <a href=LimitUserManage.asp" & EndwriteQueryString & "&Start=" & FirstID & "&UpDownPageFlag=1&SubmitFlag=3829EwoqIaNfoG>上页</a> " & VbCrLf
		else
			'PageSplictString = PageSplictString & " <font color=999999 class=grayfont>上页</font> " & VbCrLf
		end if
	
		if LastID<MaxRecordID and LastID<>0 then
			PageSplictString = PageSplictString & " <a href=LimitUserManage.asp" & EndwriteQueryString & "&Start=" & LastID & "&SubmitFlag=3829EwoqIaNfoG>下页</a> " & VbCrLf
		else
			'PageSplictString = PageSplictString & " <font color=999999 class=grayfont>下页</font> " & VbCrLf
		end if
	
		if LastID < MaxRecordID and LastID<>0 then
			PageSplictString = PageSplictString & " <a href=LimitUserManage.asp" & EndwriteQueryString & "&Start=" & MaxRecordID+1 & "&UpDownPageFlag=1&SubmitFlag=3829EwoqIaNfoG>尾页</a> " & VbCrLf
		else
			'PageSplictString = PageSplictString & " <font color=999999 class=grayfont>尾页</font> " & VbCrLf
		end if
		'PageSplictString = PageSplictString & "共<b>" & recordCount & "</b>条信息"
		'If (recordCount mod DEF_MaxListNum)=0 Then
		'	PageSplictString = PageSplictString & " 计<b>" & clng(recordCount/DEF_MaxListNum) & "</b>页"
		'Else
		'	If recordCount>=DEF_MaxListNum Then
		'		PageSplictString = PageSplictString & " 计<b>" & clng(recordCount/DEF_MaxListNum)+1 & "</b>页"
		'	Else
		'		PageSplictString = PageSplictString & " 计<b>1</b>页"
		'	End If
		'End If
		'PageSplictString = PageSplictString & " 每页<b>" & DEF_MaxListNum & "</b>条记录"
		PageSplictString = PageSplictString & "</div>"
		Dim ColN
		ColN = 6
		If Assort <> 1 and Assort <> 6 Then ColN = 5
		%>
		<script language="JavaScript" type="text/javascript">
		function kill(killID)
		{
			window.open('DelSpecialUser.asp?'+killID,'','width=450,height=37,scrollbars=auto,status=no');
		}
		</script>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class=table_in>
		<tr class=tbinhead>		
		<td width=50%>
		<form action=LimitUserManage.asp?assort=<%=assort%> method=post>
		用户名：<input size=6 name=key value="<%=htmlencode(key)%>" class="fminpt input_1"> <input type=submit name=submit value=搜索 class="fmbtn btn_1"></form>
		</td>
		<td align=right width=50%>
		<div class=value><%=PageSplictString%></div>
		</td></tr></table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class=table_in>

		<tr class=tbinhead>
			<td width=64><div class=value>ID</div></td>
			<td width=122><div class=value>名称</div></td>
			<td width=82><div class=value>更新时间</div></td>
			<td width=64><div class=value>类型</div></td><%If Assort = 1 Then%>
			<td width=104><div class=value>版面</div></td><%End If
			If Assort = 6 Then%>
			<td width=80><div class=value>激活码</div></td><%End If%>
			<td><div class=value>说明及有效时间</div></td>
		</tr>
<%
		for n= MinN to MaxN Step StepValue
			%>
		<tr>
			<td class=tdbox width=48><%=GetData(0,n)%></td>
			<td class=tdbox>
				<a href=<%=DEF_BBS_HomeUrl%>User/<%=RW_User(GetData(1,n),"","","")%>><%=htmlencode(GetData(2,n))%></a>
				<a href='javascript:kill("GBL_UserName=<%=GetData(2,n)%>&GBL_Assort=<%=Assort%>");'><font color=008800 class=greenfont><%=DoStr%></font></a></td>
			<td class=tdbox><%=RestoreTime(Left(GetData(3,n),8))%></td>
			<td class=tdbox><%Select Case GetData(4,n)
				Case 0: Response.Write DEF_PointsName(5)
				Case 1: Response.Write "版主"
				Case 2: Response.Write DEF_PointsName(6)
				Case 3: Response.Write "屏蔽发言"
				Case 4: Response.Write "禁止发言"
				Case 5: Response.Write "禁止修改"
				Case 6: Response.Write "等待认证"
				End Select%></td><%If Assort = 1 Then%>
			<td class=tdbox><a href=../ForumBoard/ForumBoardModify.asp?GBL_ModifyID=<%=GetData(6,n)%>><%=GetData(5,n)%></a></td><%End If
			If Assort = 6 Then
				If cCur(GetData(6,n)) = 0 Then
					Response.Write "<td width=80 class=tdbox>无</td>"
				Else%>
			<td class=tdbox><a href=../../User/UserGetPass.asp?act=active&user=<%=htmlencode(GetData(2,n))%>><%=GetData(6,n)%></a></td><%
				End If
			End If%>
			<td class=tdbox><%
			If GetData(7,n) <> "" Then Response.Write htmlencode(GetData(7,n)) & "<br>"
			If cCur(GetData(8,n)) > 0 Then
				Response.Write "<font color=gray class=grayfont>到期：" & RestoreTime(GetData(8,n))
			Else
				Response.Write "<font color=gray class=grayfont>永久有效"
			End If%>	</td>
                    </tr><%
			i=i+1
			if i>DEF_MaxListNum then exit for
		next
%>
                  </table>
		<%=PageSplictString%>
	<%
	Else
		Response.Write "<br>" & GBL_CHK_TempStr & "		<p>暂无相关记录。" & VbCrLf
	End If

End Function


Function LimitUserManage_NavInfo(Assort)

	Dim DoStr
	DoStr = "操作"

	Response.Write "<div class='user_item_nav fire'><ul>"
	Response.Write "<li><div class=name>限制用户管理</div></li>"
	If Assort = 3 Then
		DoStr = "解除"
		Response.Write "	<li><div class=navactive><span>屏蔽发言</span></div></li>"
	Else
		Response.Write "	<li><a href=LimitUserManage.asp?assort=3>屏蔽发言</a></li>"
	End If

	If Assort = 4 Then
		DoStr = "解除"
		Response.Write "	<li><div class=navactive>禁止发言</div></li>"
	Else
		Response.Write "	<li><a href=LimitUserManage.asp?assort=4>禁止发言</a></li>"
	End If

	If Assort = 5 Then
		DoStr = "解除"
		Response.Write "	<li><div class=navactive>禁止修改</div></li>"
	Else
		Response.Write "	<li><a href=LimitUserManage.asp?assort=5>禁止修改</a></li>"
	End If

	If Assort = 6 Then
		DoStr = "激活"
		Response.Write "	<li><div class=navactive>未激活用户</div></li>"
	Else
		Response.Write "	<li><a href=LimitUserManage.asp?assort=6>未激活用户</a></li>"
	End If

	Response.Write "</ul></div>"
	LimitUserManage_NavInfo = DoStr

End Function


Function NewSpecialUser

	GBL_UserName = Left(Request.Form("GBL_UserName"),20)
	GBL_ndatetime = GetTimeValue(DEF_Now)
	GBL_Assort = Left(Request("GBL_Assort"),14)
	GBL_WhyString = Left(Request.Form("GBL_WhyString"),100)
	GBL_ExpiresTime = Left(Request.Form("GBL_ExpiresTime"),14)

	If isNumeric(GBL_ExpiresTime) = 0 Then GBL_ExpiresTime = -1
	GBL_ExpiresTime = fix(cCur(GBL_ExpiresTime))
	If GBL_ExpiresTime < 0 or GBL_ExpiresTime > 30 Then GBL_ExpiresTime = -1

	If isNumeric(GBL_Assort) = 0 Then GBL_Assort = -1
	GBL_Assort = fix(cCur(GBL_Assort))
	',0-认证会员,1-版主,2-总版主,3-屏蔽用户,4-禁言用户,5-禁修改用户,6-非正式用户
	If GBL_Assort <> 3 and GBL_Assort <> 4 and GBL_Assort <> 5 and GBL_Assort <> 6 Then
		GBL_Assort = -1
	End If

	If Request.Form("submitflag") <> "" Then
		CheckNewSpecialUser
		If GBL_CHK_TempStr = "" Then
			SaveNewSpecialUser
			If CheckSupervisorUserName = 0 Then
				CALL LDExeCute("Update LeadBBS_User Set LastWriteTime=" & GetTimeValue(DEF_Now) & " where ID=" & GBL_UserID,1)
			End If
			Response.Write GBL_CHK_TempStr
		Else
			DisplayNewSpecialUserForm
		End If
	Else
		DisplayNewSpecialUserForm
	End If

End Function

Function SaveNewSpecialUser

	Dim SQL,Rs,Number
	SQL = sql_select("Select ID from LeadBBS_SpecialUser where Assort=" & GBL_Assort & " and UserID=" & GBL_UserName_UserID,1)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
	Else
		Rs.Close
		Set Rs = Nothing
		CALL LDExeCute("Delete from LeadBBS_SpecialUser Where Assort=" & GBL_Assort & " and UserID=" & GBL_UserName_UserID,1)
		GBL_CHK_TempStr = "<br><br><font color=008800 class=greenfont>因数据库中存在一些不对应，已经成功修复！<br>" & VbCrLf
	End If
	
	SQL = "Insert Into LeadBBS_SpecialUser(UserID,UserName,BoardID,Assort,ndatetime,ExpiresTime,WhyString) Values(" & GBL_UserName_UserID & ",'" & Replace(GBL_UserName,"'","''") & "',0," & GBL_Assort & "," & GBL_ndatetime & "," & GBL_ExpiresTime & ",'" & Replace(GBL_WhyString,"'","''") & "')"
	CALL LDExeCute(SQL,0)
	GBL_CHK_TempStr = "<font color=008800 class=greenfont>操作成功完成，添加成功,并且已经通知用户！<br>" & VbCrLf

End Function

Function CheckNewSpecialUser

	If CheckWriteEventSpace = 0 Then
		Response.Write "<b><font color=Red Class=redfont>您的操作过频，请稍候再作提交!</font></b> <br>" & VbCrLf
		Exit Function
	End If
	If GBL_Assort <> 3 and GBL_Assort <> 4 and GBL_Assort <> 5 and GBL_Assort <> 6 Then
		GBL_CHK_TempStr = "错误提示：用户类型选择错误，请正确选择！"
		Exit function
	End If
	
	If isNumeric(GBL_ExpiresTime) = 0 Then GBL_ExpiresTime = -1
	GBL_ExpiresTime = fix(cCur(GBL_ExpiresTime))
	If GBL_ExpiresTime < 0 or GBL_ExpiresTime > 30 Then GBL_ExpiresTime = -1
	If GBL_ExpiresTime = -1 Then
		GBL_CHK_TempStr = "错误提示：屏蔽期限选择错误，请正确选择！"
		Exit function
	End If

	If GBL_UserName = "" Then
		GBL_CHK_TempStr = "错误提示：请填写用户名！"
		Exit function
	End If
		
	If CheckUserNameExist(GBL_UserName) = 0 Then
		Exit function
	End If

	If GBL_ExpiresTime > 0 Then
		GBL_ExpiresTime = GetTimeValue(DateAdd("d",GBL_ExpiresTime,DEF_Now))
	Else
		GBL_ExpiresTime = 0
	End If

End Function

Function DisplayNewSpecialUserForm

	Dim N
	If GBL_CHK_TempStr <> "" Then Response.Write "<p><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font></p>"%>
	<div class="title">用户权限操作：</div>
          <form action=LimitUserManage.asp method=post id=fobform name=fobform>
          	<div class="value2">填写用户：<input name=GBL_UserName value="<%=htmlencode(GBL_UserName)%>" class=fminpt></div>
          	<input name=submitflag type=hidden value="LKOkxk2">
          	<input name=action type=hidden value="specialuser">
          	<div class="value2">
          	操作选择：<select name=GBL_Assort>
          				<option value=-1>==请选择==</option>
          				<option value=3<%If GBL_Assort = 3 Then Response.Write " selected"%>>屏蔽用户已发表的内容</option>
          				<option value=4<%If GBL_Assort = 4 Then Response.Write " selected"%>>禁止用户发表新言论</option>
          				<option value=5<%If GBL_Assort = 5 Then Response.Write " selected"%>>禁止用户修改帖子和个人资料</option>
          				<option value=6<%If GBL_Assort = 6 Then Response.Write " selected"%>>强迫用户成为未激活用户</option>
          			</select>
          	</div>
          	<div class="value2">
          	有效时间：<select name=GBL_ExpiresTime>
          					<%For N = 1 to 30
          						If N = GBL_ExpiresTime Then
          							Response.Write "<option value=" & N & " selected>有效期" & Right("0" & N,2) & "天</option>"
          						Else
          							Response.Write "<option value=" & N & ">有效期" & Right("0" & N,2) & "天</option>"
          						End If
          					Next%>
          					<option value=0<%If GBL_ExpiresTime = 0 Then Response.Write " Selected"%>>永久有效</option>
          				</select>
		</div>
		<div class="value2">
          	原因注明：<input name=GBL_WhyString MaxLength=100 size=30 value="<%=htmlencode(GBL_WhyString)%>" class=fminpt>
          	<select onchange="document.fobform.GBL_WhyString.value=this.value;">
          		<option value="">=====一些常见原因请选择=====</option>
          		<option value="内容严重违规">内容严重违规</option>
          		<option value="对论坛进行恶意攻击">对论坛进行恶意攻击</option>
          		<option value="恶意灌水">恶意灌水</option>
          		<option value="用户名字不符合要求">用户名字不符合要求</option>
          		<option value="扰乱论坛秩序">扰乱论坛秩序</option>
          	</select>
          	</div>
          	<div class="value2">
          	<input type=submit value="提交" class="fmbtn btn_2"> <input type=reset value="取消" class="fmbtn btn_2">
          	</div></form>
          	<p>
          	<div class="title">注释：</div>
          	<div class="value2">
          	<ol>
          	<li>屏蔽用户已发表的内容：此操作将屏蔽该用户所有的论坛帖子内容</li>
          	<li>禁止用户发表新议论经：此操作将禁止该用户发送短消息发帖和投票，评价帖子等功能</li>
          	<li>禁止用户修改帖子和个人资料：此操作将禁止该用户修改已经发表过的帖子及个人资料</li>
          	<li>强迫用户成为未激活用户：该用户重新成为未激活用户，且只有管理人员才能重新激活</li>
          	</ol>
          	</div>
<%End Function

Rem 检测某用户名是否存在
Function CheckUserNameExist(UserName)

	If UserName <> "" and inStr(UserName,",") = 0 and inStr(Lcase(DEF_SupervisorUserName),"," & Lcase(UserName) & ",") > 0 Then
		'作这样的同样提示是为了以防管理员名字被泄漏，实际应该提示管理员不能被屏蔽
		GBL_CHK_TempStr = "错误提示：用户名" & htmlencode(UserName) & "不存在！"
		CheckUserNameExist = 0
		Exit Function
	End If
	Dim Rs
	Set Rs = LDExeCute(sql_select("Select ID,UserLimit,UserName from LeadBBS_User where UserName='" & Replace(UserName,"'","''") & "'",1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		CheckUserNameExist = 0
		GBL_UserName_UserLimit = 0
		GBL_CHK_TempStr = "错误提示：用户名" & htmlencode(UserName) & "不存在！"
		Exit Function
	Else
		GBL_UserName_UserLimit = cCur(Rs(1))
		GBL_UserName_UserID = cCur(Rs(0))
		GBL_UserName = Rs(2)
	End if
	Rs.Close
	Set Rs = Nothing
	',0-认证会员,1-版主,2-总版主,3-屏蔽用户,4-禁言用户,5-禁修改用户,6-非正式用户
	Dim TmpStr
	Select Case GBL_Assort
		'Case 0: 
		'		If GetBinarybit(GBL_UserName_UserLimit,2) = 1 Then
		'			GBL_CHK_TempStr = "错误提示：用户" & htmlencode(UserName) & "已经是" & DEF_PointsName(5) & "，不必重复添加！"
		'			CheckUserNameExist = 0
		'			Exit Function
		'		Else
		'			GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,2,1)
		'		End If
		Case 3:
				If GetBinarybit(GBL_UserName_UserLimit,7) = 1 Then
					GBL_CHK_TempStr = "错误提示：用户" & htmlencode(UserName) & "的发言内容及签名已经被屏蔽，不必重复添加！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,7,1)
					TmpStr = "您的所有发言内容已经被屏蔽."
				End If
		Case 4:
				If GetBinarybit(GBL_UserName_UserLimit,3) = 1 Then
					GBL_CHK_TempStr = "错误提示：用户" & htmlencode(UserName) & "已经被禁言及发送短消息，不必重复添加！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,3,1)
					TmpStr = "您已经被禁言发言."
				End If
		Case 5:
				If GetBinarybit(GBL_UserName_UserLimit,4) = 1 Then
					GBL_CHK_TempStr = "错误提示：用户" & htmlencode(UserName) & "已经被禁止修改帖子及个人资料，不必重复添加！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,4,1)
					TmpStr = "您已经被禁言修改."
				End If
		Case 6:
				If GetBinarybit(GBL_UserName_UserLimit,1) = 1 Then
					GBL_CHK_TempStr = "错误提示：用户" & htmlencode(UserName) & "已经处于未激活状态，不必重复添加！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,1,1)
					TmpStr = "您目前处于未激活."
				End If
		Case Else:
				GBL_CHK_TempStr = "错误提示：用户" & htmlencode(UserName) & "已经处于未激活状态，不必重复添加！"
				CheckUserNameExist = 0
				Exit Function
	End Select
	If GBL_ExpiresTime > 0 Then
		Rs = GetTimeValue(DateAdd("d",GBL_ExpiresTime,DEF_Now))
	Else
		Rs = "永久有效"
	End If
	SendNewMessage GBL_CHK_User,UserName,"论坛短信：您的权限发生改变通知","[color=blue]您的权限因管理人员操作而产生变化[/color][hr]" & VbCrLf &_
	"[b]操作原因：[/b]" & GBL_WhyString & VbCrLf & _
	"[b]有效直到：[/b]" & Rs & VbCrLf & _
	"[b]操作结果：[/b]" & TmpStr & VbCrLf,GBL_IPAddress
	GBL_CHK_TempStr = ""
	CALL LDExeCute("Update LeadBBS_User Set UserLimit=" & GBL_UserName_UserLimit & " where ID=" & GBL_UserName_UserID,1)
	CheckUserNameExist = 1

End Function

rem fob ip
Function DisplayNewForbidIP

	If DEF_EnableForbidIP = 10 Then
		Response.Write "<div class=""title redfont"">系统已经禁止屏蔽IP功能，需要屏蔽IP地址请联系管理员开启．</div>"
		Exit Function
	End If
	GBL_UserName = Trim(Left(Request.Form("GBL_UserName"),14))
	GBL_AnnounceID = Left(Request.Form("GBL_AnnounceID"),14)
	GBL_MessageID = Left(Request.Form("GBL_MessageID"),14)
	
	If GBL_MessageID <> "" Then
	ElseIf GBL_AnnounceID <> "" Then
	ElseIf GBL_UserName <> "" Then
		'CheckUserIPInfo(GBL_UserName)
	Else
		'GBL_IPStart = Request.Form("GBL_IPStart")
		'GBL_IPEnd = Request.Form("GBL_IPEnd")
	End If
	GBL_ExpiresTime = Left(Request.Form("GBL_ExpiresTime"),14)
	GBL_WhyString = Left(Request.Form("GBL_WhyString"),100)
	
	If isNumeric(GBL_ExpiresTime) = 0 Then GBL_ExpiresTime = -1
	GBL_ExpiresTime = fix(cCur(GBL_ExpiresTime))
	If GBL_ExpiresTime < 0 or GBL_ExpiresTime > 30 Then GBL_ExpiresTime = -1

	If Request.Form("submitflag") <> "" Then
		CheckNewIP
		If GBL_CHK_TempStr = "" Then
			SaveNewIP
			Response.Write GBL_CHK_TempStr
		Else
			DisplayNewIPForm
		End If
	Else
		DisplayNewIPForm
	End If

End Function

Function SaveNewIP

	Dim SQL,Rs,Number
	GBL_IPEnd = Right("000000000000" & cStr(GBL_IPEnd),12)
	GBL_IPStart = Right("000000000000" & cStr(GBL_IPStart),12)
	Number = (Left(GBL_IPEnd,3) * 256 * 256 * 256 + Mid(GBL_IPEnd,4,3) * 256 * 256 + Mid(GBL_IPEnd,7,3) * 256 + Mid(GBL_IPEnd,10,3))-(Left(GBL_IPStart,3) * 256 * 256 * 256 + Mid(GBL_IPStart,4,3) * 256 * 256 + Mid(GBL_IPStart,7,3) * 256 + Mid(GBL_IPStart,10,3)) + 1
	SQL = sql_select("Select ID from LeadBBS_ForbidIP where IPStart<=" & GBL_IPStart & " and IPEnd>=" & GBL_IPEnd,1)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		SQL = "Insert Into LeadBBS_ForbidIP(IPStart,IPEnd,IPNumber,ExpiresTime,WhyString) Values(" & GBL_IPStart & "," & GBL_IPEnd & "," & Number & "," & GBL_ExpiresTime & ",'" & Replace(GBL_WhyString,"'","''") & "')"
		CALL LDExeCute(SQL,0)
		GBL_CHK_TempStr = "<font color=008800 class=greenfont>成功屏蔽此IP段,共计" & Number & "个!<br>" & VbCrLf
		'GBL_CHK_TempStr = GBL_CHK_TempStr & "起始IP地址：" & GBL_IPStart & "<br>" & VbCrLf
		'GBL_CHK_TempStr = GBL_CHK_TempStr & "终止IP地址：" & GBL_IPEnd & "</font><br>" & VbCrLf
	Else
		Rs.Close
		Set Rs = Nothing
		GBL_CHK_TempStr = "<font color=ff0000 class=redfont>错误提示：此IP地址段已经在屏蔽列表中,不用重复添加!</font><br>" & VbCrLf
	End If
	If CheckSupervisorUserName = 0 Then
		CALL LDExeCute("Update LeadBBS_User Set LastWriteTime=" & GetTimeValue(DEF_Now) & " where ID=" & GBL_UserID,1)
	End If

End Function

Function CheckNewIP

	If CheckWriteEventSpace = 0 Then
		Response.Write "<b><span Class=redfont>您的操作过频，请稍候再作提交!</span></b>" & VbCrLf
		Exit Function
	End If
	If GBL_MessageID <> "" or Request.Form("submitflag") = "LKOkxk4" Then
		If CheckMessageID(GBL_MessageID) = 0 Then
			Exit Function
		End If
	ElseIf GBL_AnnounceID <> "" or Request.Form("submitflag") = "LKOkxk3" Then
		If CheckAnnounceID(GBL_AnnounceID) = 0 Then
			Exit Function
		End If
	ElseIf GBL_UserName <> "" or Request.Form("submitflag") = "LKOkxk2" Then
		If CheckUserIPInfo(GBL_UserName) = 0 Then
			Exit Function
		End If
	End If
	Dim Tmp_IPStart,Tmp_IPEnd
	Tmp_IPStart = FormatIPaddress(GBL_IPStart)
	Tmp_IPEnd = FormatIPaddress(GBL_IPEnd)

	If isNumeric(GBL_ExpiresTime) = 0 Then GBL_ExpiresTime = -1
	GBL_ExpiresTime = fix(cCur(GBL_ExpiresTime))
	If GBL_ExpiresTime < 0 or GBL_ExpiresTime > 30 Then GBL_ExpiresTime = -1
	If GBL_ExpiresTime = -1 Then
		GBL_CHK_TempStr = "错误提示：屏蔽期限选择错误，请正确选择，可能是此用户IP地址不符合规划！"
		Exit function
	End If

	If Len(Tmp_IPStart) <> 15 Then
		GBL_CHK_TempStr = "错误提示：起始ＩＰ地址错误，可能是此用户IP地址不符合规划"
		Exit function
	End If

	If Len(Tmp_IPStart) <> 15 Then
		GBL_CHK_TempStr = "错误提示：终止ＩＰ地址错误，可能是此用户IP地址不符合规划"
		Exit function
	End If
	
	Dim NewGBL_IPStart,NewGBL_IPEnd
	NewGBL_IPStart = Left(Replace(Tmp_IPStart,".",""),14)
	NewGBL_IPEnd = Left(Replace(Tmp_IPEnd,".",""),14)
	If isNumeric(NewGBL_IPStart) = 0 Then
		GBL_CHK_TempStr = "错误提示：起始ＩＰ地址错误，必须是数字，可能是此用户IP地址不符合规划"
		Exit function
	End If
	
	If isNumeric(NewGBL_IPEnd) = 0 Then
		GBL_CHK_TempStr = "错误提示：终止ＩＰ地址错误，必须是数字，可能是此用户IP地址不符合规划"
		Exit function
	End If
	
	NewGBL_IPStart = cCur(NewGBL_IPStart)
	NewGBL_IPEnd = cCur(NewGBL_IPEnd)
	If NewGBL_IPStart > NewGBL_IPEnd Then
		GBL_CHK_TempStr = "错误提示：终止ＩＰ地址不能比起始ＩＰ地址小，可能是此用户IP地址不符合规划"
		Exit function
	End If
	
	If NewGBL_IPStart > 255255255255 Then
		GBL_CHK_TempStr = "错误提示：起始ＩＰ地址错误，最大IP地址为255.255.255.255，可能是此用户IP地址不符合规划"
		Exit function
	End If
	If NewGBL_IPEnd > 255255255255 Then
		GBL_CHK_TempStr = "错误提示：终止ＩＰ地址错误，最大IP地址为255.255.255.255，可能是此用户IP地址不符合规划"
		Exit function
	End If

	GBL_IPStart = NewGBL_IPStart
	GBL_IPEnd = NewGBL_IPEnd
	If GBL_ExpiresTime > 0 Then
		GBL_ExpiresTime = GetTimeValue(DateAdd("d",GBL_ExpiresTime,DEF_Now))
	Else
		GBL_ExpiresTime = 0
	End If

End Function

Function DisplayNewIPForm

	Dim N
	If GBL_CHK_TempStr <> "" Then Response.Write "<p><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font></p>"%>

			<%If Request.Form("submitflag") = "LKOkxk2" or Request.Form("submitflag") = "" Then%>
	<div class=title>
	根据在线用户名来屏蔽：输入需要屏蔽ＩＰ地址的在线用户名称
	</div>
	<form action=LimitUserManage.asp method=post id=fobform name=fobform>
		<div class="value2">
			在线的用户名：<input name=GBL_UserName value="<%=htmlencode(GBL_UserName)%>" class=fminpt><br>
			<input name=submitflag type=hidden value="LKOkxk2">
			<input name=action type=hidden value="fobip">
		</div>
		<div class="value2">
			屏蔽时间选择：<select name=GBL_ExpiresTime>
						<%For N = 1 to 30
							If N = GBL_ExpiresTime Then
								Response.Write "<option value=" & N & " selected>屏蔽" & Right("0" & N,2) & "天</option>"
							Else
								Response.Write "<option value=" & N & ">屏蔽" & Right("0" & N,2) & "天</option>"
							End If
						Next%>
						<option value=0<%If GBL_ExpiresTime = 0 Then Response.Write " Selected"%>>永久屏蔽</option>
					</select>
		</div>
		<div class="value2">
			屏蔽原因注明：<input name=GBL_WhyString MaxLength=100 size=30 value="<%=htmlencode(GBL_WhyString)%>" class=fminpt>
			<select onchange="document.fobform.GBL_WhyString.value=this.value;">
				<option value="">===一些常见原因请选择===</option>
				<option value="发表反动或色情内容">发表反动或色情内容</option>
				<option value="对论坛进行恶意攻击(黑客行为)">对论坛进行恶意攻击(黑客行为)</option>
				<option value="不停的恶意灌水或注册新用户">不停的恶意灌水或注册新用户</option>
			</select>
		</div>
		<div class="value2">
			<input type=submit value="提交" class="fmbtn btn_2"> <input type=reset value="取消" class="fmbtn btn_2">
		</div>
		</form>
		
		<div class="title">
		提示：
		</div>
		<div class="value2"><span class=grayfont>此操作只对当前在线的用户才会生效</span>
		</div>
		<%End If%>

		<%If Request.Form("submitflag") = "LKOkxk3" or Request.Form("submitflag") = "" Then%>
		<br>
		<hr class=splitline>
		<div class="title">
		根据发表帖子来屏蔽：输入某用户所发表帖子的编号
		</div>
          	<form action=LimitUserManage.asp method=post id=fobform name=fobform>
          	<div class="value2">
			论坛帖子编号：<input name=GBL_AnnounceID value="<%=htmlencode(GBL_AnnounceID)%>" class=fminpt>
		</div>
			<input name=submitflag type=hidden value="LKOkxk3">
			<input name=action type=hidden value="fobip">
		<div class="value2">
			屏蔽时间选择：<select name=GBL_ExpiresTime>
						<%For N = 1 to 30
							If N = GBL_ExpiresTime Then
								Response.Write "<option value=" & N & " selected>屏蔽" & Right("0" & N,2) & "天</option>"
							Else
								Response.Write "<option value=" & N & ">屏蔽" & Right("0" & N,2) & "天</option>"
							End If
						Next%>
						<option value=0<%If GBL_ExpiresTime = 0 Then Response.Write " Selected"%>>永久屏蔽</option>
					</select>
		</div>
		<div class="value2">
			屏蔽原因注明：<input name=GBL_WhyString MaxLength=100 size=30 value="<%=htmlencode(GBL_WhyString)%>" class=fminpt>
			<select onchange="document.fobform.GBL_WhyString.value=this.value;">
				<option value="">===一些常见原因请选择===</option>
				<option value="发表反动或色情内容">发表反动或色情内容</option>
				<option value="对论坛进行恶意攻击(黑客行为)">对论坛进行恶意攻击(黑客行为)</option>
				<option value="不停的恶意灌水或注册新用户">不停的恶意灌水或注册新用户</option>
			</select>
		</div>
		<div class="value2">
			<input type=submit value="提交" class="fmbtn btn_2"> <input type=reset value="取消" class="fmbtn btn_2">
		</div></form>
		
		<div class="title">
		提示：
		</div>
		<div class="value2"><span class=grayfont>帖子的编号，在版面列表中，将鼠标放在最前面的图标上可以显示主题帖编号在查看帖子内容时，将鼠标放在心情符号上，可以显示主题帖或回复帖的编号</span>
		</div><%End If%>
			

		<%If Request.Form("submitflag") = "LKOkxk4" or Request.Form("submitflag") = "" Then%>
		<br>
		<hr class=splitline>
		<div class="title">根据短消息编号来屏蔽：输入某用户所发送短消息的编号
		</div>
			<form action=LimitUserManage.asp method=post id=fobform name=fobform>
		<div class="value2">
			短消息的编号：<input name=GBL_MessageID value="<%=htmlencode(GBL_MessageID)%>" class=fminpt>
		</div>
			<input name=submitflag type=hidden value="LKOkxk4">
			<input name=action type=hidden value="fobip">
		<div class="value2">
			屏蔽时间选择：<select name=GBL_ExpiresTime>
						<%For N = 1 to 30
							If N = GBL_ExpiresTime Then
								Response.Write "<option value=" & N & " selected>屏蔽" & Right("0" & N,2) & "天</option>"
							Else
								Response.Write "<option value=" & N & ">屏蔽" & Right("0" & N,2) & "天</option>"
							End If
						Next%>
						<option value=0<%If GBL_ExpiresTime = 0 Then Response.Write " Selected"%>>永久屏蔽</option>
					</select>
		</div>
		<div class="value2">
			屏蔽原因说明：<input name=GBL_WhyString MaxLength=100 size=30 value="<%=htmlencode(GBL_WhyString)%>" class=fminpt>
			<select onchange="document.fobform.GBL_WhyString.value=this.value;">
				<option value="">===一些常见原因请选择===</option>
				<option value="发表反动或色情内容">发表反动或色情内容</option>
				<option value="对论坛进行恶意攻击(黑客行为)">对论坛进行恶意攻击(黑客行为)</option>
				<option value="不停的恶意灌水或注册新用户">不停的恶意灌水或注册新用户</option>
			</select>
		</div>
		<div class="value2">
			<input type=submit value="提交" class="fmbtn btn_2"> <input type=reset value="取消" class="fmbtn btn_2">
		</div></form>
		<div class="title">
		提示：
		</div>
		<div class="value2"><span class=grayfont>短消息编号可以在查看收件箱列表中显示</span>
		</div>
		<%End If%>

<%End Function


Function FormatIPaddress(KIP)

	Dim IP
	IP = KIP
	Rem 除去两首的空点，并格式化成XXX.XXX.XXX.XXX
	Dim Temp1,Temp2,TempN,Temp
	IP = Trim(IP & "")
	If inStr(IP,".") = 0 or Len(IP) = "" Then
		FormatIPaddress = IP
		Exit Function
	End if
	
	Temp1 = Split(IP,".")
	IP = ""
	Temp2 = Ubound(Temp1,1)
	
	TempN = 0
	do while IP = ""
		If Temp1(TempN) <> "" Then
			if IsNumeric(Temp1(TempN)) Then Temp1(TempN) = cStr(cCur(Temp1(TempN)))
			If Len(Temp1(TempN)) < 3 Then
				IP = string(3-len(Temp1(TempN)),"0") & Temp1(TempN)
			else
				IP = Temp1(TempN)
			End If
			TempN = TempN + 1
			Exit Do
		Else
			TempN = TempN + 1
		End If
		If TempN > Temp2 Then Exit do
	Loop
	
	For Temp = TempN to Temp2
		If Temp1(TempN) <> "" Then
			If isNumeric(Temp1(TempN)) = 0 Then
				FormatIPaddress = ""
				Exit Function
			End If
			Temp1(TempN) = Fix(cCur(Temp1(TempN)))
			If Temp1(TempN) < 0 or Temp1(TempN) > 255 Then
				FormatIPaddress = ""
				Exit Function
			End If
			if IsNumeric(Temp1(TempN)) Then Temp1(TempN) = cStr(cCur(Temp1(TempN)))
			If Len(Temp1(TempN)) < 3 Then
				IP = IP & "." & string(3-len(Temp1(TempN)),"0") & Temp1(TempN)
			else
				IP = IP & "." & Temp1(TempN)
			End If
		End If
		TempN = TempN + 1
	Next
	FormatIPaddress = IP
	Rem 返回的IP地址刚好是15位，如果不是15个字符则是错误无效的IP地址

End Function


Function CheckUserIPInfo(UserName)

	If UserName <> "" and inStr(UserName,",") = 0 and inStr(Lcase(DEF_SupervisorUserName),"," & Lcase(UserName) & ",") > 0 Then
		'作这样的同样提示是为了以防管理员名字被泄漏，实际应该提示管理员不能被屏蔽
		GBL_CHK_TempStr = "错误提示：用户名" & htmlencode(UserName) & "不存在！"
		CheckUserIPInfo = 0
		Exit Function
	End If

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select ID,UserName from LeadBBS_User where UserName='" & Replace(UserName,"'","''") & "'",1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		CheckUserIPInfo = 0
		GBL_CHK_TempStr = "错误提示：用户名" & htmlencode(UserName) & "不存在！"
		Exit Function
	Else
		GBL_UserName_UserID = cCur(Rs(0))
		GBL_UserName = Rs(1)
	End if
	Rs.Close
	Set Rs = Nothing
	
	Set Rs = LDExeCute(sql_select("Select IP from LeadBBS_OnlineUser where UserID=" & GBL_UserName_UserID,1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		CheckUserIPInfo = 0
		GBL_CHK_TempStr = "错误提示：用户名" & htmlencode(UserName) & "目前不在线，无法完成屏蔽，请使用其它的方式来屏蔽！"
		Exit Function
	Else
		GBL_IPStart = Rs(0)
		GBL_IPEnd = GBL_IPStart
		Rs.Close
		Set Rs = Nothing
	End if
		
	CheckUserIPInfo = 1

End Function

Rem 检测某帖子
Function CheckAnnounceID(AnnounceID)

	If isNumeric(AnnounceID) = False Then
		GBL_CHK_TempStr = "错误提示：帖子并不存在或无权屏蔽！"
		CheckAnnounceID = 0
		Exit Function
	End If
	AnnounceID = Fix(cCur(AnnounceID))
	If AnnounceID < 1 Then
		GBL_CHK_TempStr = "错误提示：编号" & htmlencode(AnnounceID) & "的帖子并不存在或无权屏蔽！"
		CheckAnnounceID = 0
		Exit Function
	End If
	
	Dim Rs
	Set Rs = LDExeCute(sql_select("Select IPAddress,UserName from LeadBBS_Announce where ID=" & AnnounceID,1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		CheckAnnounceID = 0
		GBL_CHK_TempStr = "错误提示：编号" & htmlencode(AnnounceID) & "的帖子并不存在或无权屏蔽！"
		Exit Function
	Else
		GBL_IPStart = Rs(0)
		GBL_IPEnd = GBL_IPStart
		GBL_UserName = Rs(1)
	End if
	Rs.Close
	Set Rs = Nothing

	If GBL_UserName <> "" and inStr(GBL_UserName,",") = 0 and inStr(Lcase(DEF_SupervisorUserName),"," & Lcase(GBL_UserName) & ",") > 0 Then
		'作这样的同样提示是为了以防管理员名字被泄漏，实际应该提示管理员不能被屏蔽
		GBL_CHK_TempStr = "错误提示：编号" & htmlencode(AnnounceID) & "的帖子并不存在或无权屏蔽！"
		CheckAnnounceID = 0
		Exit Function
	End If
	CheckAnnounceID = 1

End Function


Rem 检测某帖子
Function CheckMessageID(MessageID)

	If isNumeric(MessageID) = False Then
		GBL_CHK_TempStr = "错误提示：短消息并不存在或无权屏蔽！"
		CheckMessageID = 0
		Exit Function
	End If
	MessageID = Fix(cCur(MessageID))
	If MessageID < 1 Then
		GBL_CHK_TempStr = "错误提示：编号" & htmlencode(MessageID) & "的短消息并不存在或无权屏蔽！"
		CheckMessageID = 0
		Exit Function
	End If
	
	Dim Rs
	Set Rs = LDExeCute(sql_select("Select IP,FromUser from LeadBBS_InfoBox where ID=" & MessageID,1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		CheckMessageID = 0
		GBL_CHK_TempStr = "错误提示：编号" & htmlencode(MessageID) & "的短消息并不存在或无权屏蔽！"
		Exit Function
	Else
		GBL_IPStart = Rs(0)
		GBL_IPEnd = GBL_IPStart
		GBL_UserName = Rs(1)
	End if
	Rs.Close
	Set Rs = Nothing

	If GBL_UserName <> "" and inStr(GBL_UserName,",") = 0 and inStr(Lcase(DEF_SupervisorUserName),"," & Lcase(GBL_UserName) & ",") > 0 Then
		'作这样的同样提示是为了以防管理员名字被泄漏，实际应该提示管理员不能被屏蔽
		GBL_CHK_TempStr = "错误提示：编号" & htmlencode(MessageID) & "的短消息并不存在或无权屏蔽！"
		CheckMessageID = 0
		Exit Function
	End If
	CheckMessageID = 1

End Function

rem modifyuser

Function DisplayModifyUser

	If Request.Form("submitflag") <> "" Then
		CheckModifyUserForm
		If GBL_CHK_TempStr = "" Then
			ModifyUser
			Response.Write GBL_CHK_TempStr
			GBL_CHK_TempStr = ""
			DisplayModifyUserForm
		Else
			DisplayModifyUserForm
		End If
	Else
		DisplayModifyUserForm
	End If

End Function

Function ModifyUser

	Response.Write "<p><b>开始清除用户<u>" & htmlencode(GBL_UserName) & "</u>的下列资料：</b></p>" & VbCrLf
	If inStr(GBL_ModifyMode,",1,") Then
		If GBL_UserName_FaceUrl & "" = "" Then
			Response.Write "<p><font color=Red class=redfont>清除链接头像： 此用户头像已经是默认头像，略过操作。</font></p>"
			DeleteUploadFace(GBL_UserName_UserID)
		Else
			CALL LDExeCute("Update LeadBBS_User Set FaceUrl='' where ID=" & GBL_UserName_UserID,1)
			Response.Write "<p><font color=Green class=greenfont>清除链接头像： 成功清除。</font></p>"
			DeleteUploadFace(GBL_UserName_UserID)
		End If
	End If

	If inStr(GBL_ModifyMode,",2,") Then
		If GBL_UserName_UnderWrite & "" = "" Then
			Response.Write "<p><font color=Red class=redfont>清除用户签名： 此用户无签名内容，略过操作。</font></p>"
		Else
			CALL LDExeCute("Update LeadBBS_User Set UnderWrite='',PrintUnderWrite='' where ID=" & GBL_UserName_UserID,1)
			Response.Write "<p><font color=Green class=greenfont>清除用户签名： 成功清除。</font></p>"
		End If
	End If

	If inStr(GBL_ModifyMode,",3,") Then
		If GBL_UserName_UserTitle & "" = "" Then
			Response.Write "<p><font color=Red class=redfont>清除用户头衔： 此用户无头衔，略过操作。</font></p>"
		Else
			CALL LDExeCute("Update LeadBBS_User Set UserTitle='' where ID=" & GBL_UserName_UserID,1)
			Response.Write "<p><font color=Green class=greenfont>清除用户头衔： 成功清除。</font></p>"
		End If
	End If

	If CheckSupervisorUserName = 0 Then
		CALL LDExeCute("Update LeadBBS_User Set LastWriteTime=" & GetTimeValue(DEF_Now) & " where ID=" & GBL_UserID,1)
	End If

End Function

Function CheckModifyUserForm

	If CheckWriteEventSpace = 0 Then
		Response.Write "<b><font color=Red Class=redfont>您的操作过频，请稍候再作提交!</font></b> <br>" & VbCrLf
		Exit Function
	End If
	
	GBL_ModifyMode = Replace("," & Left(Request.Form("GBL_ModifyMode"),10) & ","," ","")
	GBL_UserName = Left(Request.Form("GBL_UserName"),20)
	If isNumeric(Replace(GBL_ModifyMode,",","")) = 0 Then
		GBL_CHK_TempStr = "错误提示：操作选项选择错误！"
		Exit Function
	End If

	If GBL_UserName = "" Then
		GBL_CHK_TempStr = "错误提示：请输入用户名！"
		Exit Function
	End If
	
	If CheckModifyUserNameExist(GBL_UserName) = 0 Then
		GBL_CHK_TempStr = "错误提示：用户名不存在！"
		Exit Function
	End If

End Function

Function DisplayModifyUserForm

	If GBL_CHK_TempStr <> "" Then Response.Write "<div class=""title redfont"">" & GBL_CHK_TempStr & "</div>"
	If Request.Form("submitflag") = "LKOkxk2" or Request.Form("submitflag") = "" Then%>
	<div class="title">清理用户资料</div>
	<form action=LimitUserManage.asp method=post id=fobform name=fobform>
	<div class="value2">
		用 户 名： <input name=GBL_UserName value="<%=htmlencode(GBL_UserName)%>" class=fminpt>
	</div>
		<input name=submitflag type=hidden value="LKOkxk2">
		<input name=action type=hidden value="modifyuser">
	<div class="value2">
		选择操作：<input name=GBL_ModifyMode value=1<%If inStr(GBL_ModifyMode,",1,") Then Response.Write " checked"%> type=checkbox>清除链接头像
		<input name=GBL_ModifyMode value=2<%If inStr(GBL_ModifyMode,",2,") Then Response.Write " checked"%> type=checkbox>清除用户签名
		<input name=GBL_ModifyMode value=3<%If inStr(GBL_ModifyMode,",3,") Then Response.Write " checked"%> type=checkbox>清除用户头衔
	</div>
	<div class="value2">
		<input type=submit value="提交" class="fmbtn btn_2"> <input type=reset value="取消" class="fmbtn btn_2">
	</div>
	</form>
	<br>
	<div class="title">提示：</div>
	<ol>
	<li>清除用户链接头像后，此用户头像恢复为论坛已有的默认头像．</li>
	<li>清除用户签名将会使指定的用户签名内容全部移除</li>
	<li>清除用户头衔将会使指定的用户头衔名取消</li>
	<li>某些特定用户资料不允许修改</li>
	</ol>
	<%End If%>

<%End Function

Rem 检测某用户名是否存在
Function CheckModifyUserNameExist(UserName)

	If UserName <> "" and inStr(UserName,",") = 0 and inStr(Lcase(DEF_SupervisorUserName),"," & Lcase(UserName) & ",") > 0 Then
		'作这样的同样提示是为了以防管理员名字被泄漏，实际应该提示管理员不能被屏蔽
		GBL_CHK_TempStr = "错误提示：用户名" & htmlencode(UserName) & "不存在！"
		CheckModifyUserNameExist = 0
		Exit Function
	End If

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select ID,UserName,FaceUrl,UnderWrite,UserTitle from LeadBBS_User where UserName='" & Replace(UserName,"'","''") & "'",1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		CheckModifyUserNameExist = 0
		GBL_CHK_TempStr = "错误提示：用户名" & htmlencode(UserName) & "不存在！"
		Exit Function
	Else
		GBL_UserName_UserID = cCur(Rs(0))
		GBL_UserName = Rs(1)
		GBL_UserName_FaceUrl = Rs(2)
		GBL_UserName_UnderWrite = Rs(3)
		GBL_UserName_UserTitle = Rs(4)
	End if
	Rs.Close
	Set Rs = Nothing
		
	CheckModifyUserNameExist = 1

End Function


Function DeleteUploadFace(DelUserID)

	If DEF_FSOString = "" Then
		Response.Write "<p><span class=redfont>论坛不支持在线删除文件，略过上传头像删除．</span>"
		Exit Function
	End If
	Dim SQL,Rs
	SQL = "Select ID,PhotoDir,SPhotoDir from LeadBBS_UserFace where UserID=" & DelUserID & " order by ID ASC"
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		Response.Write "<p><b><span class=redfont>用户无上传头像，略过删除!</span></b>"
	Else
		If Rs("PhotoDir") <> "" Then DeleteFiles(Server.Mappath(DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & "face/" & Rs("PhotoDir")))
		If Rs("SPhotoDir") <> "" Then DeleteFiles(Server.Mappath(DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & "face/" & Rs("SPhotoDir")))
		Rs.Close
		Set Rs = Nothing
		CALL LDExeCute("Delete from LeadBBS_UserFace where UserID=" & DelUserID,1)
		Response.Write "<p><b><span class=greenfont>完成用户上传头像的删除!</span></b>"
	End If

End Function

Function DeleteFiles(path)

	'on error resume next
	Dim fs
	Set fs=Server.CreateObject(DEF_FSOString)
	If fs.FileExists(path) then
		fs.DeleteFile path,True
		DeleteFiles = 1
	Else
		DeleteFiles = 0
	End If
    Set fs=nothing
         
End Function

rem clear
Sub View_ClearExpiresInfo

	If Request.Form("DeleteSure")="E72ksiOkw2" Then
		If DeleteForbidIPandUser = 1 Then
			Response.Write "<p><font color=008800 class=greenfont><b>已经成功解除所有到期的特殊用户及屏蔽的ＩＰ地址！</b></font></p>"
		else
			Response.Write "<p><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font></p>"
		End If
	Else
		%>
		<form action=LimitUserManage.asp method=post>
		<div class="title">清理到期屏蔽用户，屏蔽IP地址</div>
		<div class="value2">
		<span class=redfont>确认信息：今天是<%=year(DEF_Now)%>年<%=month(DEF_Now)%>月<%=day(DEF_Now)%>，此动作将清除今日之前已到期的信息，包括如下：<span>
		</div>
		<ol>
		<li>解除被屏蔽的IP地址</li>
		<li>解除被屏蔽发言内容的用户</li>
		<li>解除被禁言的用户</li>
		<li>解除被禁止修改的用户</li>
		<li>恢复到期了的<%=DEF_PointsName(5)%>到普通用户状态</li>
		<li>清除在激活有效期已过但仍未激活的注册用户</li>
		</ol>
		<input type=hidden name=DeleteSure value="E72ksiOkw2">
		<input type=hidden name=action value="clear">
		<div class="value2">
		<input type=submit value=开始清理 class="fmbtn btn_3">
		</div>
		</form>
	<%End If

End Sub


Function DeleteForbidIPandUser

	Server.ScriptTimeOut = 6000
	'If UserName <> "" and inStr(UserName,",") = 0 and inStr(Lcase(DEF_SupervisorUserName),"," & Lcase(UserName) & ",") > 0 Then
	'	GBL_CHK_TempStr = "错误提示：用户名" & htmlencode(UserName) & "不存在！"
	'	DeleteForbidIPandUser = 0
	'	Exit Function
	'End If
	
	Response.Write "<div class=title>更新完成：</div>"
	Dim ExpiresTime
	ExpiresTime = GetTimeValue(year(DEF_Now) & "-" & Month(DEF_Now) & "-" & Day(DEF_Now))
	Dim Rs
	Set Rs = LDExeCute("Select T2.ID,T2.UserLimit,T2.UserName,T1.Assort from LeadBBS_SpecialUser as T1 Left join LeadBBS_User As T2 on T1.UserID=T2.ID where T1.ExpiresTime>0 and T1.ExpiresTime<" & ExpiresTime,0)
	If Rs.Eof Then
		DeleteForbidIPandUser = 1
		Response.Write "<div class=value2>无任何到期的特殊用户，不需要更新．</div>"
	End If
	Dim GBL_UserName_UserID,GBL_UserName_UserLimit,GBL_UserName,GBL_Assort
	Do while Not Rs.Eof
		GBL_UserName_UserLimit = cCur(Rs(1))
		GBL_UserName_UserID = cCur(Rs(0))
		GBL_UserName = Rs(2)
		GBL_Assort = cCur(Rs(3))
		
		',0-认证会员,1-版主,2-总版主,3-屏蔽用户,4-禁言用户,5-禁修改用户,6-非正式用户
		Select Case GBL_Assort
			Case 0:
					If GetBinarybit(GBL_UserName_UserLimit,2) = 1 Then
						Response.Write "<div class=value2>用户" & htmlencode(GBL_UserName) & "已经解除" & DEF_PointsName(5) & "状态！</div>"
						GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,2,0)
						CALL LDExeCute("Update LeadBBS_User Set UserLimit=" & GBL_UserName_UserLimit & " where ID=" & GBL_UserName_UserID,1)
						CALL LDExeCute("Delete from LeadBBS_SpecialUser Where Assort=" & GBL_Assort & " and UserID=" & GBL_UserName_UserID,1)
					End If
			Case 3:
					If GetBinarybit(GBL_UserName_UserLimit,7) = 1 Then
						Response.Write "<div class=value2>用户" & htmlencode(GBL_UserName) & "已经解除屏蔽发言内容及签名！</div>"
						GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,7,0)
						CALL LDExeCute("Update LeadBBS_User Set UserLimit=" & GBL_UserName_UserLimit & " where ID=" & GBL_UserName_UserID,1)
						CALL LDExeCute("Delete from LeadBBS_SpecialUser Where Assort=" & GBL_Assort & " and UserID=" & GBL_UserName_UserID,1)
					End If
			Case 4:
					If GetBinarybit(GBL_UserName_UserLimit,3) = 1 Then
						Response.Write "<div class=value2>用户" & htmlencode(GBL_UserName) & "已经解除禁言及发送短消息！</div>"
						GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,3,0)
						CALL LDExeCute("Update LeadBBS_User Set UserLimit=" & GBL_UserName_UserLimit & " where ID=" & GBL_UserName_UserID,1)
						CALL LDExeCute("Delete from LeadBBS_SpecialUser Where Assort=" & GBL_Assort & " and UserID=" & GBL_UserName_UserID,1)
					End If
			Case 5:
					If GetBinarybit(GBL_UserName_UserLimit,4) = 1 Then
						Response.Write "<div class=value2>用户" & htmlencode(GBL_UserName) & "已经解除禁止修改帖子及自我资料！</div>"
						GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,4,0)
						CALL LDExeCute("Update LeadBBS_User Set UserLimit=" & GBL_UserName_UserLimit & " where ID=" & GBL_UserName_UserID,1)
						CALL LDExeCute("Delete from LeadBBS_SpecialUser Where Assort=" & GBL_Assort & " and UserID=" & GBL_UserName_UserID,1)
					End If
			Case 6:
					If GetBinarybit(GBL_UserName_UserLimit,1) = 1 Then
						Response.Write "<div class=value2>未激活用户" & htmlencode(GBL_UserName) & "已经被成功删除！</div>"
						GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,1,0)
						CALL LDExeCute("delete from LeadBBS_User where ID=" & GBL_UserName_UserID,1)
						CALL LDExeCute("Update LeadBBS_SiteInfo Set UserCount=UserCount-1",1)
						UpdateStatisticDataInfo -1,1,1
						CALL LDExeCute("Delete from LeadBBS_SpecialUser Where Assort=" & GBL_Assort & " and UserID=" & GBL_UserName_UserID,1)
					End If
			Case Else:
		End Select
		Rs.MoveNext
	Loop
	Rs.Close
	Set Rs = Nothing
	Response.Write "<div class=value2><span Class=greenfont>到期特殊用户更新完成．</span></div>"
	Set Rs = LDExeCute("Delete From LeadBBS_ForbidIP where ExpiresTime>0 and ExpiresTime<" & ExpiresTime,0)
	Response.Write "<div class=value2><span class=greenfont>开启到期的被屏蔽ＩＰ地址已经成功完成．</span></div>"
	DeleteForbidIPandUser = 1

End Function
%>