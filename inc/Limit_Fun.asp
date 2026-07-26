<%
Dim LimitBoardStringData,LimitBoardStringDataNum
Rem 1.所有人,2.只针对非版主,3.只针对非版主,4.只针对非版主,5.只针对非版主,6,所有人,7.所有人,8.仅对版主,9.开放论坛-针对未登录用户,10．所有人,11.所有人,12.分类版面,13.此版面帖子发出需要认证,14.特殊帖子包括回复帖与购买帖,15.只对专业用户开放,16.默认编辑模式: 0为默认设定值(基本参数中指定). 1为与默认设定值(基本参数中指定)不同的编辑模式 17.是否回复提帖 18.直接显示专题,19.子版面简约显示.20.子版面显示在低部,21.归档是否禁止(1.禁止),22.提示审核人员审核(但前台正常显示),23.是否必须选择专题
LimitBoardStringData = Array("只有登录用户才能访问","只对" & DEF_PointsName(5) & "开放","禁止发表新主题","不允许修改论坛帖子","不允许删除论坛帖子","禁止回复帖子","只对" & DEF_PointsName(8) & "以上开放","不允许转移帖子","开放论坛","仅允许本版" & DEF_PointsName(8) & "发表主题","仅允许本版" & DEF_PointsName(8) & "回复帖子","作为分类论坛","发帖需要审核才能显示","允许发表特殊帖子","只对" & DEF_PointsName(10) & "开放","编辑模式(勾选表示与论坛参数设置中指定的默认编辑方式不同)","回复提帖(勾选表示与论坛参数设置中指定的默认设置相反)","直接显示专题区","子版面简约显示","子版面置低部显示","禁止归档","提示审核但直接显示","发帖必须选择专题","有版规","有版块LOGO")
LimitBoardStringDataNum = Ubound(LimitBoardStringData,1)

Dim LimitUserStringData,LimitUserStringDataNum
Rem 1.所有人,2.所有人,3.所有人,4.所有人,版主同时限制修改自己版面,5.仅对版主,6.只针对版主有效,7.所有人,8.是否是论坛版主,9.是否允许版主转移帖子到其它论坛,10.是否是总版主,11.仅为版主总版主,12.仅针对总版主,13所有人,14.是否区版主,15.专业用户,16.允许HTML.任何用户都有效 17.禁语音,任何用户有效 18．审核帖子（总版主以上),19.默认不同步至绑定网站
LimitUserStringData = Array("未激活用户",DEF_PointsName(5),"禁止发言和发送短消息","禁止修改个人资料和帖子内容","禁止删除帖子","禁止精华帖子","所有发言屏蔽",DEF_PointsName(8),"禁止转移帖子",DEF_PointsName(6),"删除上传附件","特殊权限","仅接收好友短消息",DEF_PointsName(7),"是否" & DEF_PointsName(10),"允许HTML及直接播放媒体","禁止语音提示新消息","专职审核员/版主任命","发帖默认不同步至绑定网站")
LimitUserStringDataNum = Ubound(LimitUserStringData,1)
Dim GBL_BoardMasterFlag
GBL_BoardMasterFlag = 0

Sub CheckisBoardMaster

	'If GBL_CheckPassDoneFlag = 0 Then CheckPass
	'6-分类版主
	If CheckSupervisorNameOnly() = 1 and GBL_UserID > 0 Then
		GBL_BoardMasterFlag = 9 '管理员
		Exit Sub
	End If
	If GetBinarybit(GBL_CHK_UserLimit,10) = 1 Then
		GBL_BoardMasterFlag = 7 '总版主
		Exit Sub
	End If
	If GetBinarybit(GBL_CHK_UserLimit,14) = 1 Then
		If GBL_Board_MasterList = "?LeadBBS?" or inStr("," & GBL_Board_AssortMaster & ",","," & GBL_CHK_User & ",") > 0 Then
			GBL_BoardMasterFlag = 6 '本区版主
			Exit Sub
		Else
			GBL_BoardMasterFlag = 4 '区版主,但非本区
		End If
	End If
	If GetBinarybit(GBL_CHK_UserLimit,8) = 1 Then
		If GBL_Board_MasterList = "?LeadBBS?" or inStr("," & GBL_Board_MasterList & ",","," & GBL_CHK_User & ",") > 0 Then
			GBL_BoardMasterFlag = 5 '本版版主
			Exit Sub
		Else
			GBL_BoardMasterFlag = 4 '版主
		End If
	End If
	If GBL_BoardMasterFlag >= 4 Then Exit Sub
	If GetBinarybit(GBL_CHK_UserLimit,2) = 1 Then
		GBL_BoardMasterFlag = 2 '认证用户
	Else
		GBL_BoardMasterFlag = 0 '非版主
	End If

End Sub

Function CheckBoardReAnnounceLimit

	if GBL_CHK_OnlineTime >= DEF_NeedOnlineTime or DEF_NeedOnlineTime = 0 then
	else
		GBL_CHK_TempStr = "论坛限制在线时间(" & DEF_PointsName(4) & ")" & Fix(DEF_NeedOnlineTime/60) & "分钟以上用户才能发言。<br>" & VbCrLf
	end if
	If GetBinarybit(GBL_Board_BoardLimit,12) = 1 Then
		GBL_CHK_TempStr = "此版面属于分类论坛，不允许此操作。" & VbCrLf
		CheckBoardReAnnounceLimit = 0
	ElseIf GetBinarybit(GBL_Board_BoardLimit,6) = 1 Then
		GBL_CHK_TempStr = "此版面" & LimitBoardStringData(5) & "。" & VbCrLf
		CheckBoardReAnnounceLimit = 0
	ElseIf GetBinarybit(GBL_Board_BoardLimit,11) = 1 and GBL_BoardMasterFlag < 5 Then
		GBL_CHK_TempStr = "此版面" & LimitBoardStringData(10) & "。" & VbCrLf
		CheckBoardReAnnounceLimit = 0
	End If
	CheckBoardReAnnounceLimit = 1

End Function

Function CheckBoardAnnounceLimit

	if GBL_CHK_OnlineTime >= DEF_NeedOnlineTime or DEF_NeedOnlineTime = 0 then
	else
		GBL_CHK_TempStr = "论坛限制在线时间(" & DEF_PointsName(4) & ")" & Fix(DEF_NeedOnlineTime/60) & "分钟以上用户才能发言。<br>" & VbCrLf
	end if
	If GetBinarybit(GBL_Board_BoardLimit,12) = 1 Then
		GBL_CHK_TempStr = "此版面属于分类论坛，不允许此操作。" & VbCrLf
		CheckBoardAnnounceLimit = 0
	ElseIf GetBinarybit(GBL_Board_BoardLimit,3) = 1 Then
		GBL_CHK_TempStr = "此版面" & LimitBoardStringData(2) & "。" & VbCrLf
		CheckBoardAnnounceLimit = 0
	ElseIf GetBinarybit(GBL_Board_BoardLimit,10) = 1 and GBL_BoardMasterFlag < 5 Then
		GBL_CHK_TempStr = "此版面" & LimitBoardStringData(9) & "。" & VbCrLf
		CheckBoardAnnounceLimit = 0
	End If
	CheckBoardAnnounceLimit = 1

End Function

Function CheckUserAnnounceLimit

	if GBL_CHK_OnlineTime >= DEF_NeedOnlineTime or DEF_NeedOnlineTime = 0 then
	else
		GBL_CHK_TempStr = "论坛限制在线时间(" & DEF_PointsName(4) & ")" & Fix(DEF_NeedOnlineTime/60) & "分钟以上用户才能发言。<br>" & VbCrLf
	end if
	If GetBinarybit(GBL_CHK_UserLimit,7) = 1 Then
		GBL_CHK_TempStr = "您处于" & LimitUserStringData(2) & "中，不必尝试这些操作。" & VbCrLf
		CheckUserAnnounceLimit = 0
		Exit Function
	End If
	If GetBinarybit(GBL_CHK_UserLimit,1) = 1 Then
		GBL_CHK_TempStr = "您目前处于" & LimitUserStringData(0) & "状态，请先<a href=""" & DEF_BBS_HomeUrl & "User/UserGetPass.asp?act=active"">激活</a>或等待管理人员审核。" & VbCrLf
		CheckUserAnnounceLimit = 0
		Exit Function
	End If
	If GetBinarybit(GBL_CHK_UserLimit,3) = 1 Then
		GBL_CHK_TempStr = "您已经被" & LimitUserStringData(2) & "，投票等操作。" & VbCrLf
		CheckUserAnnounceLimit = 0
		Exit Function
	End If
	CheckUserAnnounceLimit = 1

End Function

Function CheckBoardModifyLimit

	If GetBinarybit(GBL_Board_BoardLimit,4) = 1 Then
		GBL_CHK_TempStr = "此版面" & LimitBoardStringData(3) & "。" & VbCrLf
		CheckBoardModifyLimit = 0
		Exit Function
	End If
	CheckBoardModifyLimit = 1

End Function

Function CheckUserModifyLimit

	If GetBinarybit(GBL_CHK_UserLimit,4) = 1 Then
		GBL_CHK_TempStr = "您已经被" & LimitUserStringData(3) & "。" & VbCrLf
		CheckUserModifyLimit = 0
		Exit Function
	End If
	CheckUserModifyLimit = 1

End Function

Sub CheckAccessLimit_TimeLimit

	If GBL_Board_ID < 1 Then Exit Sub
	If (GBL_Board_StartTime <> "000000" or GBL_Board_EndTime <> "000000")  Then
		Dim T1,t2,t3
		t1 = int(Mid(GBL_Board_StartTime,1,2))
		t2 = int(Mid(GBL_Board_EndTime,1,2))
		If t1 <> 0 or t2 <> 0 Then
			t3 = hour(DEF_Now)
			If t2 >= t1 Then
				if t3 >= t1 and t3 <=t2 Then
					GBL_CHK_TempStr = "此版面每天 " & t1 & ":00 到 " & t2 & ":59  限时关闭,现在时间" & DEF_Now & "。" & VbCrLf
					Exit Sub
				End If
			Else
				If (t3 >= t1 and t3 <=23) or (t3 >=0 and t3 <=t2) Then
					GBL_CHK_TempStr = "此版面每天 " & t1 & ":00 到 次日" & t2 & ":59  限时关闭,现在时间" & DEF_Now & "。" & VbCrLf
					Exit Sub
				End If
			End If
		End If
		t1 = int(Mid(GBL_Board_StartTime,3,2))
		t2 = int(Mid(GBL_Board_EndTime,3,2))
		If t1 <> 0 or t2 <> 0 Then
			t3 = weekday(DEF_Now,2)
			If t2 >= t1 Then
				if t3 >= t1 and t3 <=t2 Then
					GBL_CHK_TempStr = "此版面每周 " & t1 & " - " & t2 & " 关闭中,今天是星期" & t3  & "。" & VbCrLf
					Exit Sub
				End If
			Else
				If (t3 >= t1 and t3 <=7) or (t3 >=1 and t3 <=t2) Then
					GBL_CHK_TempStr = "此版面每周" & t1 & "到周日，周一到周" & t2 & " 关闭中,今天是星期" & t3  & "。" & VbCrLf
					Exit Sub
				End If
			End If
		End If
		t1 = int(Mid(GBL_Board_StartTime,5,2))
		t2 = int(Mid(GBL_Board_EndTime,5,2))
		If t1 <> 0 or t2 <> 0 Then
			t3 = day(DEF_Now)
			If t2 >= t1 Then
				if t3 >= t1 and t3 <=t2 Then
					GBL_CHK_TempStr = "此版面每月 " & t1 & "号 - " & t2 & "号 关闭中,今天是" & t3  & "号。" & VbCrLf
					Exit Sub
				End If
			Else
				If (t3 >= t1 and t3 <=31) or (t3 >=1 and t3 <=t2) Then
					GBL_CHK_TempStr = "此版面每月 " & t1 & "号到月底，一号到" & t2 & "号 关闭中,今天是" & t3  & "号。" & VbCrLf
					Exit Sub
				End If
			End If
		End If
	End If

End Sub

function CheckAccessLimit

	Dim Temp
	If GBL_Board_ID < 1 Then Exit function
	CheckAccessLimit_TimeLimit()
	If GBL_CHK_TempStr <> "" Then Exit function
	If GBL_UserID > 0 and CheckSupervisorUserName() = 1 Then Exit function
	
	If GBL_Board_OtherLimit > 0 Then
		If GBL_Board_OtherLimit < 100 Then
			Temp = 0
		Else
			Temp = cCur(Left(GBL_Board_OtherLimit,Len(GBL_Board_OtherLimit)-2))
		End If
		Select Case CCur(Right(GBL_Board_OtherLimit,2))
			Case 1: If GBL_CHK_Points < Temp Then GBL_CHK_TempStr = "你的" & DEF_PointsName(0) & "值不足，访问此版面需要" & Temp & DEF_PointsName(0) & "。" & VbCrLf
			Case 2: If (GBL_CHK_OnlineTime/60) < Temp Then GBL_CHK_TempStr = "你的" & DEF_PointsName(4) & "值不足，访问此版面需要" & Temp & DEF_PointsName(4) & "值。" & VbCrLf
			Case 3: If GBL_CHK_CharmPoint < Temp Then GBL_CHK_TempStr = "你的" & DEF_PointsName(1) & "值不足，访问此版面需要" & Temp & DEF_PointsName(1) & "值。" & VbCrLf
			Case 4: If GBL_CHK_CachetValue < Temp Then GBL_CHK_TempStr = "你的" & DEF_PointsName(2) & "值不足，访问此版面需要" & Temp & DEF_PointsName(2) & "值。" & VbCrLf
			Case 5: If isArray(GBL_UDT) Then
					If inStr(GBL_UDT(19),"," & Cstr(Temp) & ",") = 0 Then
						GBL_CHK_TempStr = "此版面只允许特定" & DEF_PointsName(9) & "[编号" & Temp & "]访问。" & VbCrLf
					End If
				Else
					 GBL_CHK_TempStr = "访问此版面有" & DEF_PointsName(9) & "限制。" & VbCrLf
				End If
		End Select
		If GBL_CHK_TempStr <> "" Then Exit function
	End If

	If GetBinarybit(GBL_Board_BoardLimit,7) = 1 Then
		If GBL_BoardMasterFlag < 4 or GBL_UserID < 1 Then
			GBL_CHK_TempStr = "此版面" & LimitBoardStringData(6) & "。" & VbCrLf
			Exit function
		End If
	End If

	If GBL_CHK_GuestFlag = 1 and GetBinarybit(GBL_Board_BoardLimit,1) = 1 and GBL_CHK_Flag = 0 Then
		GBL_CHK_TempStr = "此版面" & LimitBoardStringData(0) & "，请先<a href=""" & DEF_BBS_HomeUrl & "User/Login.asp?u=" & urlencode(Request.Servervariables("SCRIPT_NAME") & "?" & Request.QueryString) & """>登录</a>或<a href=""" & DEF_BBS_HomeUrl & "User/" & DEF_RegisterFile & """>注册</a>新用户。" & VbCrLf
		Exit function
	End If

	If GetBinarybit(GBL_Board_BoardLimit,2) = 1 Then
		If GetBinarybit(GBL_CHK_UserLimit,2) = 0 or GBL_UserID < 1 Then
			GBL_CHK_TempStr = "此版面" & LimitBoardStringData(1) & "。" & VbCrLf
			Exit function
		End If
	End If

	If GetBinarybit(GBL_Board_BoardLimit,15) = 1 Then
		If GetBinarybit(GBL_CHK_UserLimit,15) = 0 or GBL_UserID < 1 Then
			GBL_CHK_TempStr = "此版面" & LimitBoardStringData(14) & "。" & VbCrLf
			Exit function
		End If
	End If

	If GBL_CHK_TempStr <> "" Then Exit function
	If GBL_Board_HiddenFlag = 2 Then
		GBL_CHK_TempStr = GBL_CHK_TempStr & "此版面已经关闭,禁止浏览。" & VbCrLf
		Exit function
	End If

	dim str : str = ""
	If GBL_Board_ForumPass <> "" Then
		If GBL_UserID < 1 Then
			GBL_CHK_TempStr = GBL_CHK_TempStr & "请先以用户身份登录!" & VbCrLf
			Exit function
		End If

		If CheckWriteEventSpace() = 0 Then
			GBL_CHK_TempStr = "您的操作过频，请稍候再试!" & VbCrLf
			Exit function
		End If
		If GBL_Board_ForumPass <> DecodeCookie(Left(Request.Cookies(DEF_MasterCookies & "_" & GBL_UserID)("Board_" & GBL_board_ID),255)) Then
			GBL_CHK_TempStr = GBL_CHK_TempStr & " " & VbCrLf
				str = str & "<div class=""alertbox"">" & VbCrLf
				Dim ForumPass
				If Request("submitflag") <> "" Then
					ForumPass = Request.form("ForumPass")
					Dim NumCheck
					NumCheck = CheckRndNumber()
					If ForumPass = GBL_Board_ForumPass and NumCheck = 1 Then
						Response.Cookies(DEF_MasterCookies & "_" & GBL_UserID)("Board_" & GBL_board_ID) = CodeCookie(ForumPass)
						Response.Cookies(DEF_MasterCookies & "_" & GBL_UserID).Expires = DEF_Now + 365
						Response.Cookies(DEF_MasterCookies & "_" & GBL_UserID).Domain = DEF_AbsolutHome
						str = str & "<span class=""title greenfont"">登录成功</span>"
						str = str & "<br /><br />-- 返回 <a href=""http://" & Request.ServerVariables("SERVER_NAME")&Request.ServerVariables("URL") & "?" & Request.QueryString & """>" & htmlencode(Request.ServerVariables("SERVER_NAME")&Request.ServerVariables("URL")) & "</a>" & VbCrLf
					Else
						If NumCheck = 0 Then
							str = str & "	<span class=""alert redfont"">验证码填写错误!</span>" & VbCrLf
						Else
							str = str & "<span class=""alert redfont"">您的密码错误!</span>" & VbCrLf
						End If
						Call LDExeCute("Update LeadBBS_User Set LastWriteTime=" & GetTimeValue(DEF_Now) & " where ID=" & GBL_UserID,1)
						str = str & DisplayPassWordLoginForm()
					End If
				Else
					str = str & "<span class=""title"">此论坛为加密论坛，请输入正确的验证信息：</span>" & VbCrLf
					str = str & DisplayPassWordLoginForm()
				End If
				CheckAccessLimit = str
				Exit function
		End If
	End If
	CheckAccessLimit = str

End function

Function CheckRndNumber
	If DEF_EnableAttestNumber = 0 Then
		CheckRndNumber = 1
		Exit Function
	End If

	Dim RndNumber
	RndNumber = Left(Session(DEF_MasterCookies & "RndNum") & "",4)
	If RndNumber = "" Then
		Randomize
		RndNumber = Fix(Rnd*9999)+1
		Session(DEF_MasterCookies & "RndNum") = RndNumber
	End If

	Dim ForumNumber
	If dontRequestFormFlag = "" Then
		ForumNumber = Left(Request.form("ForumNumber"),4)
	Else
		ForumNumber = Left(GetFormData("ForumNumber"),4)
	End If
	If LCase(RndNumber) = LCase(ForumNumber) Then
		CheckRndNumber = 1
	Else
		CheckRndNumber = 0
	End If

End Function

function DisplayPassWordLoginForm

	Dim Temp
	dim str : str = ""
	Temp = Request.ServerVariables("URL")
	Temp = StrReverse(Temp)
	Temp = Replace(Temp,"\","/")
	if Instr(Temp,"/") > 0 Then Temp = Left(Temp,Instr(Temp,"/")-1)
	Temp = StrReverse(Temp)
	str = "<form action=""" & Temp & "?" & Request.QueryString & """ method=""post"">" & VbCrLf
	str = str & "	<div class=value2>密　码： <input name=""ForumPass"" type=""password"" maxlength=""20"" size=""20"" value=""" & htmlencode(Request("ForumPass")) & """ class=""fminpt input_2"" />" & VbCrLf
	str = str & "	</div>"
	If DEF_EnableAttestNumber > 0 Then
		str = str & "	<div class=value2>验证码： " & VbCrLf
		str = str & displayVerifycode()
	End If
	str = str & "	</div>" & VbCrLf
	str = str & "	<input name=""submitflag"" type=""hidden"" value=""ddddls-+++"" />" & VbCrLf
	str = str & "	<div class=value2>" & VbCrLf
	str = str & "	<input type=""submit"" value=""登录"" class=""fmbtn btn_2"">" & VbCrLf
	str = str & "	</div></form>" & VbCrLf
	DisplayPassWordLoginForm = str

End function%>

<%
function displayVerifycode

	Dim Str : Str = ""
	str = str & "<input name=""ForumNumber"" id=""ForumNumber"" style=""display:inline-block;"" maxlength=""4"" value=""" & htmlencode(Session(DEF_MasterCookies & "RndNum_par") & "") & """ onfocus=""verify_load(0,'" & DEF_InstallDir & "');"" class=""fminpt input_1"" />" & VbCrLf
	str = str & "	<img src=""" & DEF_InstallDir & "images/blank.gif"" id=""verifycode"" align=""middle"" onclick=""verify_load(1,'" & DEF_Installdir & "');"" />" & VbCrLf
	str = str & "	<a href=""javascript:;"" id=verify_click onclick=""this.style.display='none';verify_load(1,'" & DEF_InstallDir & "');return false;"">点此显示验证码</a>" & VbCrLf
	str = str & "	<noscript>" & VbCrLf
	str = str & "	<div class=""verifycode""><img src=""" & DEF_InstallDir & "User/number.asp?r=1"" id=""verifycode"" class=""verifycode"" align=""middle"" onclick=""verify_load(1,'" & DEF_Installdir & "');"" /></div>" & VbCrLf
	str = str & "	</noscript>" & VbCRLf
	displayVerifycode = str

End function%>