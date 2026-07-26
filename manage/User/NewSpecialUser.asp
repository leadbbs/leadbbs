<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../../inc/Limit_fun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass()

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("添加新的特殊用户")
If GBL_CHK_Flag=1 Then
	LoginAccuessFul()
Else
	DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

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
	If GBL_Assort <> 0 and GBL_Assort <> 3 and GBL_Assort <> 4 and GBL_Assort <> 5 and GBL_Assort <> 6 and GBL_Assort <> 8 Then
		GBL_Assort = -1
	End If

	If Request.Form("submitflag") <> "" Then
		CheckNewIP()
		If GBL_CHK_TempStr = "" Then
			SaveNewIP()
			Response.Write GBL_CHK_TempStr
		Else
			DisplayNewIPForm()
		End If
	Else
		DisplayNewIPForm()
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
		GBL_CHK_TempStr = "<div class=frameline><span class=greenfont>因数据库中存在一些不对应，已经成功修复！</span><div>" & VbCrLf
	End If
	
	SQL = "Insert Into LeadBBS_SpecialUser(UserID,UserName,BoardID,Assort,ndatetime,ExpiresTime,WhyString) Values(" & GBL_UserName_UserID & ",'" & Replace(GBL_UserName,"'","''") & "',0," & GBL_Assort & "," & GBL_ndatetime & "," & GBL_ExpiresTime & ",'" & Replace(GBL_WhyString,"'","''") & "')"
	CALL LDExeCute(SQL,1)
	GBL_CHK_TempStr = "<div class=frameline><span class=greenfont>操作成功完成，添加成功！</span></div>" & VbCrLf

End Function

Function CheckNewIP
	
	If GBL_Assort <> 0 and GBL_Assort <> 3 and GBL_Assort <> 4 and GBL_Assort <> 5 and GBL_Assort <> 6 and GBL_Assort <> 8 Then
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
	If GBL_CHK_TempStr <> "" Then Response.Write "<div class=alert>" & GBL_CHK_TempStr & "</div>"%>
	<div class=frametitle>请输入待操作的信息</div>
	<form action=NewSpecialUser.asp method=post id=fobform name=fobform>
		<div class=frameline>用 户 名：<input name=GBL_UserName value="<%=htmlencode(GBL_UserName)%>" class=fminpt>
		</div>
		<input name=submitflag type=hidden value="LKOkxk2">
		<div class=frameline>
		动作选择：<select name=GBL_Assort>
			<option value=-1>==请选择==</option>
			<option value=0<%If GBL_Assort = 0 Then Response.Write " selected"%>>成为<%=DEF_PointsName(5)%></option>
			<option value=3<%If GBL_Assort = 3 Then Response.Write " selected"%>>屏蔽用户已发表的内容</option>
			<option value=4<%If GBL_Assort = 4 Then Response.Write " selected"%>>禁止用户发表新言论</option>
			<option value=5<%If GBL_Assort = 5 Then Response.Write " selected"%>>禁止用户修改帖子和自我资料</option>
			<option value=6<%If GBL_Assort = 6 Then Response.Write " selected"%>>强迫用户成为未激活用户</option>
			<option value=8<%If GBL_Assort = 8 Then Response.Write " selected"%>>成为<%=DEF_PointsName(10)%></option>
		</select>
		</div>
		<div class=frameline>
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
		<div class=frameline>
		原因注明：<input name=GBL_WhyString MaxLength=100 size=30 value="<%=htmlencode(GBL_WhyString)%>" class=fminpt>
		<select onchange="document.fobform.GBL_WhyString.value=this.value;">
			<option value="">=====一些常见原因请选择=====</option>
			<option value="发表反动或色情内容">发表反动或色情内容</option>
			<option value="对论坛进行恶意攻击(黑客行为)">对论坛进行恶意攻击(黑客行为)</option>
			<option value="不停的恶意灌水或注册新用户">不停的恶意灌水或注册新用户</option>
			<option value="用户名字不符合要求">用户名字不符合要求</option>
			<option value="扰乱论坛秩序，言行不文明">扰乱论坛秩序，言行不文明</option>
		</select>
		</div>
		<div class=frameline>
		<input type=submit value="提交" class=fmbtn> <input type=reset value="取消" class=fmbtn>
		</div>
	</form>
	<br>
	<p>

<%End Function

Rem 检测某用户名是否存在
Function CheckUserNameExist(UserName)

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
	Select Case GBL_Assort
		Case 0: 
				If GetBinarybit(GBL_UserName_UserLimit,2) = 1 Then
					GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "已经是" & DEF_PointsName(5) & "，不必重复添加！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,2,1)
				End If
		Case 3:
				If GetBinarybit(GBL_UserName_UserLimit,7) = 1 Then
					GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "的发言内容及签名已经被屏蔽，不必重复添加！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,7,1)
				End If
		Case 4:
				If GetBinarybit(GBL_UserName_UserLimit,3) = 1 Then
					GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "已经被禁言及发送短消息，不必重复添加！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,3,1)
				End If
		Case 5:
				If GetBinarybit(GBL_UserName_UserLimit,4) = 1 Then
					GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "已经被禁止修改帖子及自我资料，不必重复添加！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,4,1)
				End If
		Case 6:
				If GetBinarybit(GBL_UserName_UserLimit,1) = 1 Then
					GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "已经处于未激活状态，不必重复添加！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,1,1)
				End If
		Case 8: 
				If GetBinarybit(GBL_UserName_UserLimit,15) = 1 Then
					GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "已经是" & DEF_PointsName(10) & "，不必重复添加！"
					CheckUserNameExist = 0
					Exit Function
				Else
					GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,15,1)
				End If
		Case Else:
				GBL_CHK_TempStr = "错误，用户" & htmlencode(UserName) & "已经处于未激活状态，不必重复添加！"
				CheckUserNameExist = 0
				Exit Function
	End Select
	CALL LDExeCute("Update LeadBBS_User Set UserLimit=" & GBL_UserName_UserLimit & " where ID=" & GBL_UserName_UserID,1)
	CheckUserNameExist = 1

End Function%>