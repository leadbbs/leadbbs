<!-- #include file=../../../inc/BBSsetup.asp -->
<!-- #include file=../../../inc/Board_Popfun.asp -->
<!-- #include file=../../../inc/Limit_fun.asp -->
<!-- #include file=../inc/BoardMaster_Fun.asp -->
<!-- #include file=../../../User/inc/Fun_SendMessage.asp -->
<%
DEF_BBS_HomeUrl = "../../../"
initDatabase
GBL_CHK_TempStr = ""

SiteHead(DEF_SiteNameString & " - " & DEF_PointsName(6) & "管理")

UserTopicTopInfo
DisplayUserNavigate("添加新的特殊用户")%>
<br><br><%If GBL_CHK_Flag=1 and BDM_isBoardMasterFlag = 1 and BDM_SpecialPopedomFlag = 1 Then
	LoginAccuessFul
Else%>
	<table width=96%>
	<tr>
	<td>
	<%
	If Request("submitflag")="" Then
		Response.Write "<br><b>请先登录</b>"
	Else
		Response.Write "<br><p align=left><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font>"
	End If
	DisplayLoginForm
	Response.Write "</p>"%>
	</td>
	</tr>
	</table>
<%End If
UserTopicBottomInfo
closeDataBase
SiteBottom
If GBL_ShowBottomSure = 1 Then Response.Write GBL_SiteBottomString

Dim GBL_UserName,GBL_Assort,GBL_ndatetime,GBL_WhyString,GBL_ExpiresTime
GBL_ExpiresTime = -1
Dim GBL_UserName_UserLimit,GBL_UserName_UserID

Function LoginAccuessFul

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
	',0-认证会员,1-版主,2-总版主,3-屏蔽会员,4-禁言会员,5-禁修改会员,6-非正式会员
	If GBL_Assort <> 3 and GBL_Assort <> 4 and GBL_Assort <> 5 and GBL_Assort <> 6 Then
		GBL_Assort = -1
	End If

	If Request.Form("submitflag") <> "" Then
		CheckNewIP
		If GBL_CHK_TempStr = "" Then
			SaveNewIP
			If CheckSupervisorUserName = 0 Then
				CALL LDExeCute("Update LeadBBS_User Set LastWriteTime=" & GetTimeValue(DEF_Now) & " where ID=" & GBL_UserID,1)
			End If
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
	GBL_CHK_TempStr = "<font color=008800 class=greenfont>操作成功完成，添加成功,并且已经通知会员！<br>" & VbCrLf

End Function

Function CheckNewIP

	If CheckWriteEventSpace = 0 Then
		Response.Write "<b><font color=Red Class=redfont>您的操作过频，请稍候再作提交!</font></b> <br>" & VbCrLf
		Exit Function
	End If
	If GBL_Assort <> 3 and GBL_Assort <> 4 and GBL_Assort <> 5 and GBL_Assort <> 6 Then
		GBL_CHK_TempStr = "错误：会员类型选择错误，请正确选择！"
		Exit function
	End If
	
	If isNumeric(GBL_ExpiresTime) = 0 Then GBL_ExpiresTime = -1
	GBL_ExpiresTime = fix(cCur(GBL_ExpiresTime))
	If GBL_ExpiresTime < 0 or GBL_ExpiresTime > 30 Then GBL_ExpiresTime = -1
	If GBL_ExpiresTime = -1 Then
		GBL_CHK_TempStr = "错误：屏蔽期限选择错误，请正确选择！"
		Exit function
	End If

	If GBL_UserName = "" Then
		GBL_CHK_TempStr = "错误：请填写用户名！"
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

Function DisplayNewIPForm

	Dim N
	If GBL_CHK_TempStr <> "" Then Response.Write "<p><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font></p>"%>
		  请输入待操作的信息
          <form action=NewSpecialUser.asp method=post id=fobform name=fobform>
          	用 户 名：<input name=GBL_UserName value="<%=htmlencode(GBL_UserName)%>" class=fminpt><br>
          	<input name=submitflag type=hidden value="LKOkxk2">
          	动作选择：<select name=GBL_Assort>
          				<option value=-1>==请选择==</option>
          				<option value=3<%If GBL_Assort = 3 Then Response.Write " selected"%>>屏蔽用户已发表的内容</option>
          				<option value=4<%If GBL_Assort = 4 Then Response.Write " selected"%>>禁止用户发表新言论</option>
          				<option value=5<%If GBL_Assort = 5 Then Response.Write " selected"%>>禁止用户修改帖子和自我资料</option>
          				<option value=6<%If GBL_Assort = 6 Then Response.Write " selected"%>>强迫用户成为未激活用户</option>
          			</select><br>
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
          				<br>
          	原因注明：<input name=GBL_WhyString MaxLength=100 size=30 value="<%=htmlencode(GBL_WhyString)%>" class=fminpt>
          	<select onchange="document.fobform.GBL_WhyString.value=this.value;">
          		<option value="">=====一些常见原因请选择=====</option>
          		<option value="发表反动或色情内容">发表反动或色情内容</option>
          		<option value="对论坛进行恶意攻击(黑客行为)">对论坛进行恶意攻击(黑客行为)</option>
          		<option value="不停的恶意灌水或注册新用户">不停的恶意灌水或注册新用户</option>
          		<option value="用户名字不符合要求">用户名字不符合要求</option>
          		<option value="扰乱论坛秩序，言行不文明">扰乱论坛秩序，言行不文明</option>
          	</select>
          	<br><br>
          	<input type=submit value="提交" class=fmbtn> <input type=reset value="取消" class=fmbtn></form>
          	<br>
          	<p>
<%End Function

Rem 检测某用户名是否存在
Function CheckUserNameExist(UserName)

	If UserName <> "" and inStr(UserName,",") = 0 and inStr(Lcase(DEF_SupervisorUserName),"," & Lcase(UserName) & ",") > 0 Then
		'作这样的同样提示是为了以防管理员名字被泄漏，实际应该提示管理员不能被屏蔽
		GBL_CHK_TempStr = "错误，用户名" & htmlencode(UserName) & "不存在！"
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
		GBL_CHK_TempStr = "错误，用户名" & htmlencode(UserName) & "不存在！"
		Exit Function
	Else
		GBL_UserName_UserLimit = cCur(Rs(1))
		GBL_UserName_UserID = cCur(Rs(0))
		GBL_UserName = Rs(2)
	End if
	Rs.Close
	Set Rs = Nothing
	',0-认证会员,1-版主,2-总版主,3-屏蔽会员,4-禁言会员,5-禁修改会员,6-非正式会员
	Dim TmpStr
	Select Case GBL_Assort
		'Case 0: 
		'		If GetBinarybit(GBL_UserName_UserLimit,2) = 1 Then
		'			GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "已经是" & DEF_PointsName(5) & "，不必重复添加！"
		'			CheckUserNameExist = 0
		'			Exit Function
		'		Else
		'			GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,2,1)
		'		End If
		Case 3:
				If GetBinarybit(GBL_UserName_UserLimit,7) = 1 Then
					GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "的发言内容及签名已经被屏蔽，不必重复添加！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,7,1)
					TmpStr = "您的所有发言内容已经被屏蔽."
				End If
		Case 4:
				If GetBinarybit(GBL_UserName_UserLimit,3) = 1 Then
					GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "已经被禁言及发送短消息，不必重复添加！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,3,1)
					TmpStr = "您已经被禁言发言."
				End If
		Case 5:
				If GetBinarybit(GBL_UserName_UserLimit,4) = 1 Then
					GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "已经被禁止修改帖子及自我资料，不必重复添加！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,4,1)
					TmpStr = "您已经被禁言修改."
				End If
		Case 6:
				If GetBinarybit(GBL_UserName_UserLimit,1) = 1 Then
					GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "已经处于未激活状态，不必重复添加！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,1,1)
					TmpStr = "您目前处于未激活."
				End If
		Case Else:
				GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "已经处于未激活状态，不必重复添加！"
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

End Function%>