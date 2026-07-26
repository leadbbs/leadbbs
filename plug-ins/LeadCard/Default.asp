<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../../User/inc/UserTopic.asp"-->
<%
DEF_BBS_homeUrl="../../"
Const PLUG_LeadCard_Length = 14 '卡号长度
Const PLUG_LeadCard_ChangeValueLimit = 10000 '转账时要求的账号底线财富

Main()

Sub Main

	InitDatabase()
	BBS_SiteHead DEF_SiteNameString & " - LeadCard",0,"<span class=navigate_string_step>LeadCard</span>"
	
	UserTopicTopInfo("forum")
	
	If GBL_CHK_User = "" then
		Response.write "<div class=alert>您没有使用LeadCard的权限，请先登陆或者注册为论坛会员。</div>"
	Else
		Main_LeadCard()
	End If
	
	CloseDatabase()
	UserTopicBottomInfo()
	SiteBottom()

End Sub

Sub Main_LeadCard

	Dim SupervisorFlag
	SupervisorFlag = CheckSupervisorNameOnly()
%>
	<div class=title>LeadCard 您的状态</div>
	<div class=value2>
	<%=DEF_PointsName(1) & "：" & GBL_CHK_CharmPoint%>
	 / <%=DEF_PointsName(0) & "：" & GBL_CHK_Points%>
	 / <%=DEF_PointsName(2) & "：" & GBL_CHK_CachetValue%></div>

	<%If Request.Form("submitflag") = "1" Then
		Select Case Request("act")
			Case "0": Call LeadCard_InputValue()
			Case "1": If SupervisorFlag = 1 Then Call LeadCard_Made()
			Case "11": Call LeadCard_ChangeValue()
		End Select
	Else%>
		<br>
		<div class=title>卡片充值</div>
		<div class=value2>
		1.<a href=#none onclick="$('#CardUser2')[0].value=$('#CardUser')[0].value='<%=htmlencode(GBL_CHK_User)%>';">替自己充值</a>
		2.<a href=#none onclick="$('#CardUser2')[0].value=$('#CardUser')[0].value='';">替朋友充值</a>
		</div>
		<form method=post action=Default.asp name=cardform id=cardform onSubmit="submit_disable(this);">
		<input type=hidden value=1 name=submitflag>
		<input type=hidden value=0 name=act>
		<div class=value2>充值卡号：<input maxlength=20 id=CardID name=CardID value="<%=Left(Request("CardID"),16)%>" size="20" class='fminpt input_3'>
		<%=PLUG_LeadCard_Length%>位卡号
		</div>
		<div class=value2>充入账号：<input maxlength=20 id=CardUser name=CardUser value="<%=Left(Request("CardUser"),20)%>" size="20" class='fminpt input_2'>
		填写要充入的账号
		</div>
		<div class=value2>重复账号：<input maxlength=20 id=CardUser2 name=CardUser2 value="<%=Left(Request("CardUser2"),20)%>" size="20" class='fminpt input_2'>
		确认充值账号
		</div>
		<div class=value2>
		<input name=submit2 type=submit value="立即充值" class='fmbtn btn_3'>
		</div>
		</form>

		<br>
		<div class=title>服务：<%=DEF_PointsName(1)%>转账</div>
		
		<%If PLUG_LeadCard_ChangeValueLimit > 0 Then
			Response.Write "<div class=value2>账户保底数额：" & PLUG_LeadCard_ChangeValueLimit & " 点</div>"
		End If%>
		<div class=value2>您能转账的数额：<%
		If GBL_CHK_CharmPoint - PLUG_LeadCard_ChangeValueLimit > 0 Then
			Response.Write GBL_CHK_CharmPoint-PLUG_LeadCard_ChangeValueLimit
		Else
			Response.Write "0"
		End If%> 点
		</div>
		<form method=post action=Default.asp name=cardform id=cardform onSubmit="submit_disable(this);">
		<input type=hidden value=1 name=submitflag>
		<input type=hidden value=11 name=act>
		<div class=value2>转账数额：<input maxlength=20 name=ChangeValue value="<%=Left(Request("ChangeValue"),16)%>" size="20" class='fminpt input_2'>
		</div>
		<div class=value2>需要转入的<%=DEF_PointsName(1)%>数值，限一万以内
		</div>
		<div class=value2>转入账号：<input maxlength=20 name=CardUser value="<%=Left(Request("CardUser"),20)%>" size="20" class='fminpt input_2'>
		填写要转入的账号
		<div class=value2>
		重复账号：<input maxlength=20 name=CardUser2 value="<%=Left(Request("CardUser2"),20)%>" size="20" class='fminpt input_2'>
		确认转入账号
		</div>
		<div class=value2>
		<input name=submit2 type=submit value="立即转账" class='fmbtn btn_3'>
		</div>
		</form>
		<%
		If SupervisorFlag = 1 Then%>
		<br><div class=title>管理员：制作新充值卡</div>
		<%LeadCard_MakeForm()%>
		<br>
		<div class=title>管理员：充值卡列表</a></div><br>
		<ol>
		<li><a href=Default.asp>最近100张充值卡</a>
		<li><a href=Default.asp?T=1>最近100张<%=DEF_PointsName(0)%>卡</a>
		<li><a href=Default.asp?T=2>最近100张<%=DEF_PointsName(1)%>卡</a>
		<li><a href=Default.asp?T=3>最近100张<%=DEF_PointsName(2)%>卡</a>
		<li><a href=Default.asp?T=4>最近100张<%=DEF_PointsName(4)%>卡</a>
		<li><a href=Default.asp?T=5>最近100张邀请码</a>
		</ol><%
			LeadCard_List()
		End If
	End If%>
<%

End Sub

Sub LeadCard_MakeForm

%>
		<form method=post action=Default.asp name=madeform id=madeform onSubmit="submit_disable(this);">
		<input type=hidden value=1 name=submitflag>
		<input type=hidden value=1 name=act>
		<div class=value2>生成数量：<input maxlength=20 name=CardNum value="<%=Left(Request("CardNum"),16)%>" size="20" class='fminpt input_2'>
		制作新充值卡数量 一次最多1000张
		</div>
		<div class=value2>充值类型：<select name=CardType class=TBBG9>
			<option value=-1>请选择
			<option value=1><%=DEF_PointsName(0)%>卡(增加<%=DEF_PointsName(0)%>)
			<option value=2><%=DEF_PointsName(1)%>卡(增加<%=DEF_PointsName(1)%>)
			<option value=3><%=DEF_PointsName(2)%>卡(增加<%=DEF_PointsName(2)%>)
			<option value=4><%=DEF_PointsName(4)%>卡(增加<%=DEF_PointsName(4)%>)
			<option value=5>邀请码卡(禁止注册时可用)
			<select> 不同类型的充值卡，对应不同充值内容
		</div>
		<div class=value2>
		充值点数：<select name=CardPoints class=TBBG9>
			<option value=-1>请选择
			<option value=1>1
			<option value=2>2
			<option value=5>5
			<option value=10>10
			<option value=25>25
			<option value=50>50
			<option value=100>100
			<option value=500>500
			<option value=1000>1000
			<option value=10000>10000
			</select> 充值卡充值后可获取点数
		</div>
		<div class=value2>
		到期时间：<select name=ExpiresDate class=TBBG9>
			<option value=-1>请选择
			<option value=1>1天
			<option value=7>1周
			<option value=30>1月
			<option value=120>3个月
			<option value=365>1年
			<option value=3650>10年
			</select> 在超过时间后未充的卡片将会失效
		</div>
		<div class=value2>
		<input name=submit2 type=submit value="立即制作" class='fmbtn btn_3'>
		</div>
		</form>
<%

End Sub

Function GBLFUN_Clng(Str)

	Dim Tmp
	Tmp = Left(Str & "",14)
	If isNumeric(Tmp) = 0 Then Tmp = 0
	Tmp = Fix(cCur(Tmp))
	GBLFUN_Clng = Tmp

End Function
	

Sub LeadCard_ChangeValue

	Dim ChangeValue,CardUser,CardUser2
	ChangeValue = Left(Request.Form("ChangeValue"),14)
	CardUser = Left(Trim(Request.Form("CardUser")),20)
	CardUser2 = Left(Trim(Request.Form("CardUser2")),20)

	ChangeValue = GBLFUN_Clng(ChangeValue)
	If ChangeValue < 0 or ChangeValue > 10000 Then
		LeadCard_Err "转账错误：请输入正确的数值．"
		Exit Sub
	End If
	
	If LCase(CardUser) <> LCase(CardUser2) Then
		LeadCard_Err "转账错误：两次输入的转入用户必须相同．"
		Exit Sub
	End If
	
	If Trim(LCase(GBL_CHK_User)) = Trim(LCase(CardUser)) Then
		LeadCard_Err "转账错误：不能转账给自己．"
		Exit Sub
	End If
	
	Dim CardUserID
	CardUserID = CheckUserNameExist(CardUser)
	If CardUserID = 0 Then
		LeadCard_Err "转账错误：不存在用户 " & htmlencode(CardUser) & "．"
		Exit Sub
	End If

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select CharmPoint from LeadBBS_User Where ID=" & GBL_UserID,1),0)
	If Rs.Eof Then
		LeadCard_Err "转账错误：请先登录．"
		Rs.Close
		Set Rs = Nothing
		Exit Sub
	End If
	GBL_CHK_CharmPoint = cCur(Rs(0))
	Rs.Close
	Set Rs = Nothing

	If ChangeValue > GBL_CHK_CharmPoint Then
		LeadCard_Err "转账错误：您的" & DEF_PointsName(1) & "不足．"
		Exit Sub
	End If

	If GBL_CHK_CharmPoint <= PLUG_LeadCard_ChangeValueLimit or ChangeValue > (GBL_CHK_CharmPoint - PLUG_LeadCard_ChangeValueLimit) Then
		LeadCard_Err "转账错误：您的" & DEF_PointsName(1) & "未到允许转账的数值或超出了允许转账的数值．"
		Exit Sub
	End If

	Con.ExeCute("Update LeadBBS_User Set CharmPoint=CharmPoint-" & ChangeValue & " Where ID=" & GBL_UserID)
	Con.ExeCute("Update LeadBBS_User Set CharmPoint=CharmPoint+" & ChangeValue & " Where UserName='" & Replace(CardUser,"'","''") & "'")
	
	UpdateSessionValue 15,0-ChangeValue,1
	
	LeadCard_Done "转账成功提示：成功转入账号<u>" & htmlencode(CardUser) & "</u>，共计" & DEF_PointsName(1) & "<u>" & ChangeValue & "</u>．"

End Sub

Sub LeadCard_InputValue

	Dim CardID,CardUser,CardUser2
	CardID = Left(Request.Form("CardID"),14)
	CardUser = Left(Trim(Request.Form("CardUser")),20)
	CardUser2 = Left(Trim(Request.Form("CardUser2")),20)

	CardID = GBLFUN_Clng(CardID)
	If Len(Cstr(CardID)) <> PLUG_LeadCard_Length Then
		LeadCard_Err "充值错误：卡号错误，无法完成充值．"
		Exit Sub
	End If
	
	If LCase(CardUser) <> LCase(CardUser2) Then
		LeadCard_Err "充值错误：两次输入的充值用户不同，无法完成充值．"
		Exit Sub
	End If
	
	Dim CardUserID
	CardUserID = CheckUserNameExist(CardUser)
	If CardUserID = 0 Then
		LeadCard_Err "充值错误：不存在用户 " & htmlencode(CardUser) & "．"
		Exit Sub
	End If

	Dim Rs
	Dim CardType,ExpiresDate,CardPoints
	Set Rs = LDExeCute(sql_select("Select CardType,ExpiresDate,CardPoints from LeadBBS_Plug_Card Where CardID=" & CardID,1),0)
	If Rs.Eof Then
		LeadCard_Err "充值错误：卡号 " & CardID & " 不存在或已被充值．"
		Rs.Close
		Set Rs = Nothing
		Exit Sub
	End If
	CardType = Rs(0)
	ExpiresDate = Rs(1)
	CardPoints = Rs(2)
	Rs.Close
	Set Rs = Nothing

	If cCur(Left(LngStr(GetTimeValue(DEF_Now)),8)) > ExpiresDate Then
		LeadCard_Err "充值错误：卡号 " & CardID & " 已到期作废．"
		Exit Sub
	End If

	Dim TypeCol,TypeStr
	Select Case CardType
	Case 1: TypeStr = DEF_PointsName(0)
		TypeCol = "Points"
	Case 2: TypeStr = DEF_PointsName(1)
		TypeCol = "CharmPoint"
	Case 3: TypeStr = DEF_PointsName(2)
		TypeCol = "CachetValue"
	Case 4: TypeStr = DEF_PointsName(4)
		TypeCol = "OnlineTime"
		CardPoints = CardPoints * 60
	case 5: TypeStr = "邀请码"
		LeadCard_Err "邀请码无法充值．"
		Exit Sub
	Case Else: 
		LeadCard_Err "充值错误：卡号 " & CardID & " 遇到不可预知的错误，请联系管理员解决．"
		Exit Sub
	End Select
	
	Con.ExeCute("Update LeadBBS_User Set " & TypeCol & "=" & TypeCol & "+" & CardPoints & " Where ID=" & CardUserID)
	Con.ExeCute("Delete from LeadBBS_Plug_Card Where CardID=" & CardID)
	If CardType = 4 Then CardPoints = CardPoints / 60
	LeadCard_Done "充值成功提示：成功为账号<u>" & htmlencode(CardUser) & "</u>充入" & TypeStr & "卡，共计点数<u>" & CardPoints & "</u>．"
	

End Sub

Sub LeadCard_Made

	Dim CardNum,CardType,CardPoints,ExpiresDate
	CardNum = Request.Form("CardNum")
	CardType = Request.Form("CardType")
	CardPoints = Request.Form("CardPoints")
	ExpiresDate = Request.Form("ExpiresDate")
	
	CardNum = GBLFUN_Clng(CardNum)
	If CardNum < 0 or CardNum > 1000 Then
		LeadCard_Err "生成新充值卡错误：数量必须限制在1-1000．"
		Exit Sub
	End If

	CardType = GBLFUN_Clng(CardType)
	If CardType < 1 or CardType > 5 Then
		LeadCard_Err "生成新充值卡错误：请选择充值卡类型．"
		Exit Sub
	End If

	CardPoints = GBLFUN_Clng(CardPoints)
	If CardPoints < 1 or CardPoints > 10000 Then
		LeadCard_Err "生成新充值卡错误：请选择正确的充值卡点数．"
		Exit Sub
	End If

	ExpiresDate = GBLFUN_Clng(ExpiresDate)
	If ExpiresDate < 1 or ExpiresDate > 3650 Then
		LeadCard_Err "生成新充值卡错误：请正确选择充值卡作废日期．"
		Exit Sub
	End If

	%>
	<br>
	<table cellpadding=0 cellspacing=0 class=table_in>
	<tr class=tbinhead>
	<td><div class=value>卡号</div></td>
	<td><div class=value>类型</div></td>
	<td><div class=value>点数</div></td>
	<td><div class=value>到期日期</div></td>
	</tr>
	<%
	Dim TypeStr
	
	Select Case CardType
	Case 1: TypeStr = DEF_PointsName(0)
	Case 2: TypeStr = DEF_PointsName(1)
	Case 3: TypeStr = DEF_PointsName(2)
	Case 4: TypeStr = DEF_PointsName(4)
	Case 5: TypeStr = "邀请码"
	End Select

	Dim ExpiresDateTmp
	ExpiresDateTmp = Left(LngStr(GetTimeValue(DateAdd("d",ExpiresDate,DEF_Now))),8)

	Dim CardID,N,Rs,Num
	Num = 0
	For N = 1 To CardNum
		Randomize
		CardID = Fix(Rnd*99999999999999)
		
		If Len(CardID) >= PLUG_LeadCard_Length Then
			Set Rs = LDExeCute(sql_select("Select CardID From LeadBBS_Plug_Card Where CardID=" & CardID,1),0)
			If Rs.Eof Then
				Rs.Close
				Set Rs = Nothing
				Num = Num + 1
				Con.ExeCute("Insert Into LeadBBS_Plug_Card(CardID,CardType,ExpiresDate,CardPoints) Values(" & CardID & "," & CardType & "," & ExpiresDateTmp & "," & CardPoints & ")")
				Response.Write "<tr><td class=tdbox>" & CardID & "</td>"
				Response.Write "<td class=tdbox>" & TypeStr & "卡</td>"
				Response.Write "<td class=tdbox>" & CardPoints & "</td>"
				Response.Write "<td class=tdbox>" & ExpiresDate & "天</td></tr>" & VbCrLf
			Else
				Rs.Close
				Set Rs = Nothing
			End If
		End If
	Next
	%>
	</table>
	<%
	LeadCard_Done "充值卡成功生成：	共计" & Num & "张．"

End Sub

Sub LeadCard_Err(str)

	Response.Write "<div class=alert>" & Str & "</div>"
	Response.Write "<a href=Default.asp>[返回主界面]</a>"

End Sub

Sub LeadCard_Done(str)

	Response.Write "<div class='alert greenfont'>" & Str & "</div>"
	Response.Write "<a href=Default.asp>[返回主界面]</a>"

End Sub

Rem 检测某用户名是否存在
Function CheckUserNameExist(UserName)

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select ID from LeadBBS_User where UserName='" & Replace(UserName,"'","''") & "'",1),0)
	If Rs.Eof Then
		CheckUserNameExist = 0
	Else
		CheckUserNameExist = cCur(Rs(0))
	End if
	Rs.Close
	Set Rs = Nothing

End Function

Sub LeadCard_List

	Dim Rs,GetData
	Dim T
	T = Left(Request("T"),14)
	T = GBLFUN_Clng(T)
	If T < 1 or T > 5 Then T = 0
	If T = 0 Then
		Set Rs = LDExeCute(sql_select("Select ID,CardID,CardType,ExpiresDate,CardPoints From LeadBBS_Plug_Card",100),0)
	Else
		Set Rs = LDExeCute(sql_select("Select ID,CardID,CardType,ExpiresDate,CardPoints From LeadBBS_Plug_Card where CardType=" & T,100),0)
	End If
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		LeadCard_Done "没有符合查询条件的冲值卡．"
		Exit Sub
	End If
	
	GetData = Rs.GetRows(100)
	Rs.Close
	Set Rs = Nothing
		
	%>
	<table cellpadding=0 cellspacing=0 class=table_in>
	<tr class=tbinhead>
	<td><div class=value>编号</div></td>
	<td><div class=value>卡号</div></td>
	<td><div class=value>类型</div></td>
	<td><div class=value>点数</div></td>
	<td><div class=value>到期</div></td>
	</tr>
	<%
	Dim TypeStr

	Dim N,CardNum
	
	CardNum = Ubound(GetData,2)
	For N = 0 To CardNum	
		Select Case GetData(2,N)
		Case 1: TypeStr = DEF_PointsName(0)
		Case 2: TypeStr = DEF_PointsName(1)
		Case 3: TypeStr = DEF_PointsName(2)
		Case 4: TypeStr = DEF_PointsName(4)
		Case 5: TypeStr = "邀请码"
		End Select

		Response.Write "<tr><td class=tdbox>" & LngStr(GetData(0,N)) & "</td>"
		Response.Write "<td class=tdbox>" & LngStr(GetData(1,N)) & "</td>"
		Response.Write "<td class=tdbox>" & TypeStr & "卡</td>"
		Response.Write "<td class=tdbox>" & GetData(4,N) & "</td>"
		Response.Write "<td class=tdbox>" & restoretime(GetData(3,N)) & "</td></tr>" & VbCrLf
	Next
	%>
	</table>
	<%

End Sub%>