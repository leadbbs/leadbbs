<%
Dim ApplyFlag
ApplyFlag = 0
Dim Form_ID,Form_UserName,Form_Pass,Form_Mail,Form_Address
Dim Form_Sex,Form_Birthday,Form_ApplyTime,Form_ICQ,Form_OICQ,Form_MobileTel,Form_Sessionid,Form_Online
Dim Form_Prevtime,Form_Userphoto,Form_IP,Form_UserLevel,Form_Homepage,Form_Underwrite,Form_PrintUnderwrite
Dim Form_Officer,Form_Points
Dim Form_Login_ip,Form_Login_oknum,Form_Login_falsenum,Form_Login_lastpass,Form_Login_RightIP
Dim Form_Password1,Form_Password2,Form_byear,Form_bday,Form_bmonth
Dim Form_FaceHeight,Form_FaceWidth,Form_FaceUrl,Form_UserLimit
Dim Form_Question,Form_Answer,Form_UserTitle,Form_CachetValue,Form_LockIP,Form_CharmPoint

Rem =====初始化变量=====
Form_Sex = 0
Form_Online = 0
Form_Officer = 0
Form_UserLevel = 0
'Form_Userphoto = "224"
Form_Points = 0
Form_ID=0
Form_ApplyTime=GetTimeValue(DEF_Now)
Form_Prevtime = Form_ApplyTime
Form_Login_oknum = 0
Form_Login_falsenum = 0
Form_CachetValue = 0
Form_CharmPoint = 0
Rem =====初始化结束=====

Function checkFormDate

	Form_ID = Left(Trim(Request("Form_ID")),14)
	Form_UserName = Trim(Request("Form_UserName"))
	Form_Mail = Trim(Request("Form_Mail"))
	Form_Address = Trim(Request("Form_Address"))
	Form_Sex = Trim(Request("Form_Sex"))
	Form_ICQ = Left(Trim(Request("Form_ICQ")),14)
	Form_OICQ = Left(Trim(Request("Form_OICQ")),14)
	Form_MobileTel = Left(Trim(Request("Form_MobileTel")),15)
	Form_Userphoto = Left(Trim(Request("Form_Userphoto")),14)
	Form_Homepage = Trim(Request("Form_Homepage"))
	Form_Underwrite = Request("Form_Underwrite")
	Form_Password1 = Trim(Request("Form_Password1"))
	Form_Password2 = Trim(Request("Form_Password2"))
	Form_byear = Left(Trim(Request("Form_byear")),14)
	Form_bday = Left(Trim(Request("Form_bday")),14)
	Form_bmonth = Left(Trim(Request("Form_bmonth")),14)
	
	Form_ApplyTime = Trim(Request("Form_ApplyTime"))
	Form_IP = Trim(Request("Form_IP"))
	Form_UserLevel = Left(Trim(Request("Form_UserLevel")),14)
	Form_Officer = Trim(Request("Form_Officer"))
	Form_Points = Left(Trim(Request("Form_Points")),14)
	Form_Sessionid = Left(Trim(Request("Form_Sessionid")),14)
	Form_Online = Trim(Request("Form_Online"))
	Form_Prevtime = Trim(Request("Form_Prevtime"))
	Form_Answer = Trim(Request("Form_Answer"))
	Form_Question = Trim(Request("Form_Question"))
	Form_LockIP = Trim(Request("Form_LockIP"))

		Form_Login_ip = Trim(Request("Form_Login_ip"))
		Form_Login_oknum = Left(Trim(Request("Form_Login_oknum")),14)
		Form_Login_falsenum = Left(Trim(Request("Form_Login_falsenum")),14)
		Form_Login_lastpass = Trim(Request("Form_Login_lastpass"))
		Form_Login_RightIP = Trim(Request("Form_Login_RightIP"))

	If DEF_AllDefineFace <> 0 Then
		Form_FaceUrl = Trim(Request("Form_FaceUrl"))
		Form_FaceWidth = Left(Trim(Request("Form_FaceWidth")),14)
		Form_FaceHeight = Left(Trim(Request("Form_FaceHeight")),14)
	End If
	Form_UserTitle = LeftTrue(Trim(Request("Form_UserTitle")),18)
	Form_CachetValue = Left(Request("Form_CachetValue"),14)
	If Form_CachetValue = "" or isNumeric(Form_CachetValue) = False Then Form_CachetValue = 0
	Form_CachetValue = Fix(cCur(Form_CachetValue))
	If Form_CachetValue < -2147483647 Then Form_CachetValue = -2147483647
	'If Form_CachetValue > 2147483647 Then Form_CachetValue = 2147483647
	
	Form_CharmPoint = Left(Request("Form_CharmPoint"),14)
	If Form_CharmPoint = "" or isNumeric(Form_CharmPoint) = False Then Form_CharmPoint = 0
	Form_CharmPoint = Fix(cCur(Form_CharmPoint))
	
	If isNumeric(Form_Sessionid) = 0 Then Form_Sessionid = 0

	Dim dateflag

	dateflag=1

	Dim Temp1,TempN,Temp2
	Form_UserLimit = 0
	Temp2 = 1
	For TempN = 0 to LimitUserStringDataNum
		Temp1 = Request("Limit" & TempN+1)
		If Temp1 <> "1" Then Temp1 = "0"
		If Temp1 = "1" Then Form_UserLimit = Form_UserLimit+cCur(Temp2)
		Temp2 = Temp2*2
	Next

	If isNumeric(Form_ID)=0 Then Form_ID = 0
	Form_ID = cCur(Form_ID)
	If Form_ID>0 Then
		If CheckUserIDExist(Form_ID) = 0 Then
			GBL_CHK_TempStr = "用户ID不存在，不能完成修改! <br>" & VbCrLf
			GBL_CHK_Flag = 0
			Exit Function
		End If
	End If

	If Form_UserName="" then
		GBL_CHK_TempStr = "请输入用户名!<br>"
		GBL_CHK_Flag = 0
		Exit Function
	else
			If Form_UserName = "游客" Then
				GBL_CHK_TempStr = "不允许使用此用户名!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		
			If inStr(Form_UserName,"'")>0 or inStr(Form_UserName,chr(34))>0 then
				GBL_CHK_TempStr = "用户名不能包含'或" & chr(34) & "符号!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
			If inStr(Form_UserName,"`")>0 or inStr(Form_UserName,"~")>0 or inStr(Form_UserName,"&")>0 then
				GBL_CHK_TempStr = "用户名不能包含`或&符号!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
			If inStr(Form_UserName,"!")>0 or inStr(Form_UserName,"@")>0 or inStr(Form_UserName,"^")>0 then
				GBL_CHK_TempStr = "用户名不能包含!@^符号!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
			If inStr(Form_UserName,"#")>0 or inStr(Form_UserName,"$")>0 or inStr(Form_UserName,"%")>0 then
				GBL_CHK_TempStr = "用户名不能包含#$%符号!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
			If inStr(Form_UserName,"*")>0 or inStr(Form_UserName,"(")>0 or inStr(Form_UserName,")")>0 then
				GBL_CHK_TempStr = "用户名不能包含*()符号!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
			If inStr(Form_UserName,"+")>0 or inStr(Form_UserName,"=")>0 or inStr(Form_UserName,"|")>0 then
				GBL_CHK_TempStr = "用户名不能包含+=|符号!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
			'If inStr(Form_UserName," ")>0 or inStr(Form_UserName,chr(10))>0 or inStr(Form_UserName,chr(13))>0 then
			'	GBL_CHK_TempStr = "用户名不能包含空格,换行等符号!<br>"
			'	GBL_CHK_Flag = 0
			'	Exit Function
			'End If
			If inStr(Form_UserName,chr(127))>0 or inStr(Form_UserName,chr(9))>0 then
				GBL_CHK_TempStr = "用户名不能包含制表符等符号!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
			If inStr(Form_UserName,"[")>0 or inStr(Form_UserName,"]")>0 or inStr(Form_UserName,"\")>0 then
				GBL_CHK_TempStr = "用户名不能包含[]\等符号!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
			If inStr(Form_UserName,"{")>0 or inStr(Form_UserName,"}")>0 or inStr(Form_UserName,";")>0 then
				GBL_CHK_TempStr = "用户名不能包含{};等符号!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
			If inStr(Form_UserName,":")>0 or inStr(Form_UserName,",")>0 or inStr(Form_UserName,".")>0 then
				GBL_CHK_TempStr = "用户名不能包含:,.等符号!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
			If inStr(Form_UserName,"<")>0 or inStr(Form_UserName,">")>0 or inStr(Form_UserName,"/")>0 or inStr(Form_UserName,"?")>0 then
				GBL_CHK_TempStr = "用户名不能包含<>?/等符号!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
	End If

	If Len(Form_UserName) > 20 then
		GBL_CHK_TempStr = "用户名太长!<br>"
		GBL_CHK_Flag = 0
		Exit Function
	End If
	
	If ApplyFlag = 1 Then
		If CheckUserNameExist(Form_UserName) = 1 Then
			GBL_CHK_TempStr = "用户名已经存在，请用其它用户名! <br>" & VbCrLf
			GBL_CHK_Flag = 0
			Exit Function
		End If
	End If
	'If Form_Answer="" then
	'	GBL_CHK_TempStr = "请输入密码提示答案!<br>"
	'	GBL_CHK_Flag = 0
	'	Exit Function
	'End If
	If len(Form_Answer)>20 then
		GBL_CHK_TempStr = "密码提示答案不能超过20个字!<br>"
		GBL_CHK_Flag = 0
		Exit Function
	End If

	If Form_LockIP <> "" Then
		If StrLength(Form_LockIP) > 15 or isNumeric(Replace(Form_LockIP,".","")) = 0 or (Replace(Form_LockIP,".","",1,3,0) = Replace(Form_LockIP,".","",1,2,0)) Then
			GBL_CHK_TempStr = "ＩＰ锁定填写错误，请输入正确的ＩＰ地址!<br>"
			GBL_CHK_Flag = 0
			Exit Function
		End If
	End If

	If Form_Password1 = "" and Form_Password2 = "" and ApplyFlag = 0 Then
		Form_Password1 = ""
		Form_Password2 = ""
	Else
		If Form_Password1="" then
			GBL_CHK_TempStr = "请输入密码!<br>"
			GBL_CHK_Flag = 0
			Exit Function
		End If
		If Len(Form_Password1) > 20 then
			GBL_CHK_TempStr = "密码太长!<br>"
			GBL_CHK_Flag = 0
			Exit Function
		End If
	
		If Form_Password2="" then
			GBL_CHK_TempStr = "请输入验证密码!<br>"
			GBL_CHK_Flag = 0
			Exit Function
		End If
		If Len(Form_Password2) > 20 then
			GBL_CHK_TempStr = "验证密码太长!<br>"
			GBL_CHK_Flag = 0
			Exit Function
		End If
		If Form_Password2 = "" then
			GBL_CHK_TempStr = "请填写密码!<br>"
			GBL_CHK_Flag = 0
			Exit Function
		End If
		If Form_Password1 <> Form_Password2 then
			GBL_CHK_TempStr = "两次密码输入不相同!<br>"
			GBL_CHK_Flag = 0
			Exit Function
		End If
		'If Form_Password2 = Form_UserName or Len(Form_Password2)<4 Then
		'	GBL_CHK_TempStr = "密码不能和用户名相同，并且不能小于四位!<br>"
		'	GBL_CHK_Flag = 0
		'	Exit Function
		'End If
		'If Len(Form_Password2) = 4 and isNumeric(Form_Password2) Then
		'	GBL_CHK_TempStr = "密码太简单!<br>"
		'	GBL_CHK_Flag = 0
		'	Exit Function
		'End If
	End If

	If Len(Form_Mail) > 60 then
		GBL_CHK_TempStr = "邮箱地址不能长于60个字符!<br>"
		GBL_CHK_Flag = 0
		Exit Function
	End If

	'If Form_Mail = "" then
	'	GBL_CHK_TempStr = "邮箱地址必须填写!<br>"
	'	GBL_CHK_Flag = 0
	'	Exit Function
	'End If

	If inStr(Form_Mail,"@") = false then
		GBL_CHK_TempStr = "邮箱地址错误!<br>"
		GBL_CHK_Flag = 0
		Exit Function
	End If

	If Form_ICQ <> "" then
		If IsNumeric(Form_ICQ) = 0 or instr(Form_ICQ,",")>0 then
			GBL_CHK_TempStr = "ICQ号码必须是数字!<br>"
			GBL_CHK_Flag = 0
			Exit Function
		else 
			If Form_ICQ>1999999999 then
				GBL_CHK_TempStr = "ICQ号码错误!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		End If
	End If

	If Form_OICQ <> "" then
		If IsNumeric(Form_OICQ) = 0 or instr(Form_OICQ,",")>0 then
			GBL_CHK_TempStr = "你的OICQ(QQ)号码必须是数字!<br>"
			GBL_CHK_Flag = 0
			Exit Function
		else
			If Form_OICQ>9999999999 then
				GBL_CHK_TempStr = "你的OICQ(QQ)号码错误!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		End If
	End If
	If Form_MobileTel <> "" Then
		If IsNumeric(Form_MobileTel) = 0 or instr(Form_MobileTel,",")>0 Then
			GBL_CHK_TempStr = "你的手机号码必须是数字!<br>"
			GBL_CHK_Flag = 0
			Exit Function
		else
			If Form_MobileTel>999999999999999 Then
				GBL_CHK_TempStr = "你的手机号码错误!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		End If
	End If

	If Len(Form_Address) > 150 then
		GBL_CHK_TempStr = "地址太长!<br>"
		GBL_CHK_Flag = 0
		Exit Function
	End If

	If Form_Sex <> "密" and Form_Sex <> "男" and Form_Sex <> "女" then
		GBL_CHK_TempStr = "性别错误!<br>"
		GBL_CHK_Flag = 0
		Exit Function
	End If

	If Form_byear <> "" and Form_byear <> "19" then
		If IsNumeric(Form_byear) = 0 or instr(Form_byear,",")>0 then
			GBL_CHK_TempStr = "出生年错误!<br>"
			GBL_CHK_Flag = 0
			Exit Function
		else
			Form_byear = cCur(Form_byear)
			If (Form_byear>year(DEF_Now) or Form_byear<1900) then
				GBL_CHK_TempStr = "出生年错误!1<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		End If
	else
		dateflag = 0
	End If

	If Form_bmonth <> "" then
		If IsNumeric(Form_bmonth) = 0 or instr(Form_bmonth,",")>0 then
			GBL_CHK_TempStr = "出生月份错误!<br>"
			GBL_CHK_Flag = 0
			Exit Function
		else
			If Form_bmonth>12 or Form_bmonth<0 then
				Form_bmonth = cCur(Form_bmonth)
				GBL_CHK_TempStr = "出生月份错误!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		End If
	else
		dateflag = 0
	End If

	If Form_bday <> "" then
		If IsNumeric(Form_bday) = 0 or instr(Form_bday,",")>0 then
			GBL_CHK_TempStr = "出生日期错误!<br>"
			GBL_CHK_Flag = 0
			Exit Function
		else
			If Form_bday>31 or Form_bday<0 then
				Form_bday = cCur(Form_bday)
				GBL_CHK_TempStr = "出生日期错误!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		End If
	else
		dateflag = 0
	End If


	If strLength(Form_Homepage) > 250 then
		GBL_CHK_TempStr = "主页地址太长!<br>"
		GBL_CHK_Flag = 0
		Exit Function
	End If

	Form_birthday = 0
	If dateflag = 1 then Form_birthday = GetTimeValue(dateserial(Form_byear,Form_bmonth,Form_bday))

	If isNumeric(Form_Userphoto) = 0 or instr(Form_Userphoto,",")>0 then
		If Form_Sex = "男" then
			Form_Userphoto = 1
		else
			If Form_Sex = "女" then
				Form_Userphoto = 2
			else
				Form_Userphoto = 3
			End If
		End If
	End If
	
	Form_Userphoto = cCur(Form_Userphoto)
	
	If Form_Userphoto < 1 or Form_Userphoto > DEF_faceMaxNum Then
		If Form_Sex = "男" then
			Form_Userphoto = 1
		else
			If Form_Sex = "女" then
				Form_Userphoto = 2
			else
				Form_Userphoto = 3
			End If
		End If
	End If
	
	Rem -----------特殊数据验证-------------
	If Len(Form_Underwrite) > 255 then
		GBL_CHK_TempStr = "用户签名太长，不能超过255字符!<br>"
		GBL_CHK_Flag = 0
		Exit Function
	End If
	
	if len(Form_ApplyTime)<14 or isDate(RestoreTime(Form_ApplyTime))=false Then
		GBL_CHK_TempStr = "申请时间错误，可能不是正常的日期格式或未填写! <br>" & VbCrLf
		GBL_CHK_Flag = 0
		Exit Function
	End If
	
	If IsNumeric(Form_UserLevel) = 0 or instr(Form_UserLevel,",")>0 then
		GBL_CHK_TempStr = "用户" & DEF_PointsName(3) & "必须是数字! <br>" & VbCrLf
		GBL_CHK_Flag = 0
		Exit Function
	End If
	Form_UserLevel = cCur(Form_UserLevel)
	If Form_UserLevel<0 or Form_UserLevel>DEF_UserLevelNum Then
		GBL_CHK_TempStr = "用户" & DEF_PointsName(3) & "必须大等于0并且小于" & DEF_UserLevelNum & "! <br>" & VbCrLf
		GBL_CHK_Flag = 0
		Exit Function
	End If

	Dim Form_Officer_Temp,Temp_N
	Form_Officer_Temp = Form_Officer
	Form_Officer_Temp = "," & Form_Officer_Temp & ","
	Form_Officer = "0"
	For Temp_N = 1 to DEF_UserOfficerNum
		if inStr(Form_Officer_Temp,"," & Temp_N & ",") Then
			Form_Officer = Form_Officer & "," & Temp_N
		End If
	Next
	If Form_Officer<>"0" Then Form_Officer = Mid(Form_Officer,3)
	If Len(Form_Officer)>255 Then
		GBL_CHK_TempStr = "所任官职太多!<br>" & VbCrLf
		GBL_CHK_Flag = 0
		Exit Function
	End If

	If IsNumeric(Form_Points) = 0 or instr(Form_Points,",")>0 then
		GBL_CHK_TempStr = "用户" & DEF_PointsName(0) & "必须是数字! <br>" & VbCrLf
		GBL_CHK_Flag = 0
		Exit Function
	End If
	Form_Points = cCur(Form_Points)

	If IsNumeric(Form_Online) = 0 or instr(Form_Online,",")>0 then
		GBL_CHK_TempStr = "用户在线状态必须是数字! <br>" & VbCrLf
		GBL_CHK_Flag = 0
		Exit Function
	End If
	Form_Online = cCur(Form_Online)
	
	if len(Form_Prevtime)<14 or isDate(RestoreTime(Form_Prevtime))=false Then
		GBL_CHK_TempStr = "最后登录时间错误，可能不是正常的日期格式或未填写! <br>" & VbCrLf
		GBL_CHK_Flag = 0
		Exit Function
	End If
	
	If IsNumeric(Form_Login_oknum) = 0 or instr(Form_Login_oknum,",")>0 then
		Form_Login_oknum = 0
		Exit Function
	End If
	If IsNumeric(Form_Login_falsenum) = 0 or instr(Form_Login_falsenum,",")>0 then
		GBL_CHK_TempStr = "持败登次必须是数字! <br>" & VbCrLf
		GBL_CHK_Flag = 0
		Exit Function
	End If
	
	If DEF_AllDefineFace <> 0 Then
		Form_FaceUrl = Trim(Request("Form_FaceUrl"))
		Form_FaceWidth = Left(Trim(Request("Form_FaceWidth")),14)
		Form_FaceHeight = Left(Trim(Request("Form_FaceHeight")),14)
		
		If IsNumeric(Form_FaceWidth) = 0 or instr(Form_FaceWidth,",")>0 or Form_FaceWidth = "" then
			If Form_FaceUrl <> "" Then
				GBL_CHK_TempStr = "自定义头像宽度填写错误!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		End If		
		If IsNumeric(Form_FaceHeight) = 0 or instr(Form_FaceHeight,",")>0 or Form_FaceHeight = "" then
			If Form_FaceUrl <> "" Then
				GBL_CHK_TempStr = "自定义头像高度填写错误!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		End If
		
		If Form_FaceUrl <> "" Then
			Form_FaceWidth = cCur(Form_FaceWidth)
			Form_FaceHeight = cCur(Form_FaceHeight)
			If Form_FaceWidth <20 or Form_FaceWidth > DEF_AllFaceMaxWidth or Form_FaceHeight < 20 or Form_FaceHeight > DEF_AllFaceMaxWidth*2 Then
				GBL_CHK_TempStr = "自定义头像高度和宽度大小只能在20-" & DEF_AllFaceMaxWidth & "之间!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		End If
	End If


	If Form_FaceUrl = "" Then
		If IsNumeric(Form_FaceWidth) = 0 or instr(Form_FaceWidth,",")>0 or Form_FaceWidth = "" then
			Form_FaceWidth = 0
		Else
			Form_FaceWidth = cCur(Form_FaceWidth)
		End If
		
		If IsNumeric(Form_FaceHeight) = 0 or instr(Form_FaceHeight,",")>0 or Form_FaceHeight = "" then
			Form_FaceHeight = 0
		Else
			Form_FaceHeight = cCur(Form_FaceHeight)
		End If
	Else
		If Lcase(Left(Replace(Form_FaceUrl,"\","/"),7)) <> "http://" and Lcase(Left(Replace(Form_FaceUrl,"\","/"),6)) <> "ftp://" and Lcase(Left(Replace(Form_FaceUrl,"\","/"),8)) <> "https://" Then
			Dim Temp
			Temp = Lcase(Right(Form_FaceUrl,4))
			If Temp <> ".gif" and Temp <> ".jpg" and Temp <> "jpeg" and Temp <> ".jpe" and Temp<>".png" Then
				GBL_CHK_TempStr = "自定头像填写错误，必须是jpg,gif,png等图像格式!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If

			on error resume next
			If DEF_FSOString <> "" Then
				Dim fs
				Set fs = CreateObject(DEF_FSOString)
				if (Err = 0) Then
					if not fs.FileExists(Server.Mappath("../" & Form_FaceUrl)) then
						if err Then
							GBL_CHK_TempStr = "自定头像填写错误，请确定是否填写正确!<br>"
							err.clear
						Else
							GBL_CHK_TempStr = "自定头像填写错误，本服务器上没有此文件!<br>"
						End If
						GBL_CHK_Flag = 0
						Set fs = Nothing
						Exit Function
					End If
				Else
					'Set fs = Nothing
					'If DEF_EnableGFL = 1 Then
					'	Dim TempW,TempH
					'	TempW = DEF_AllFaceMaxWidth
					'	TempH = DEF_AllFaceMaxWidth
					'	If CheckIsGoodImg(Server.Mappath("../" & Form_FaceUrl),TempW,TempH*2) = 0 Then
					'		GBL_CHK_TempStr = "自定头像错误，原因是" & GBL_CHK_TempStr & "!<br>"
					'		GBL_CHK_Flag = 0
					'		Exit Function
					'	Else
					'		Form_FaceWidth = TempW
					'		Form_FaceHeight = TempH
					'	End If
					'End If
				End If
			End If
		End If
	End If

	'Form_PrintUnderwrite = UBB_Code_UnderWrite(Form_Underwrite)
	If StrLength(Form_PrintUnderwrite) > 1024 Then 
		GBL_CHK_TempStr = "签名太长!<br>"
		GBL_CHK_Flag = 0
		Exit Function
	End If
	
	GBL_CHK_Flag = 1

End Function

Function CheckIsGoodImg(LoadFile,W,H)

	on error resume next

	Dim MyObj
	Set MyObj = Server.CreateObject("Persits.Jpeg")
	If err Then
		CheckIsGoodImg = 0
		GBL_CHK_TempStr = "未安装aspJpeg组件！"
		Exit Function
	End If
	'MyObj.EnableLZW = True
	MyObj.Open(LoadFile)
	if err Then
		CheckIsGoodImg = 0
		GBL_CHK_TempStr = "非图像文件！"
		Set MyObj = Nothing
		Exit Function
	End If
	
	Dim Img_Width,Img_Height
	
	Img_Height = MyObj.Height
	Img_Width = MyObj.Width
	
	Set MyObj = Nothing
	
	If Img_Height > H or Img_Height < 20 or Img_Width > W or Img_Width < 20 Then
		CheckIsGoodImg = 0
		GBL_CHK_TempStr = "图像大小不符合要求！"
		Exit Function
	End If
	
	W = Img_Width
	H = Img_Height
	
	CheckIsGoodImg = 1

End Function

Rem 检测某用户名是否存在
Function CheckUserNameExist(UserName)

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select ID from LeadBBS_User where UserName='" & Replace(UserName,"'","''") & "' and id<>" & Form_ID,1),0)
	If Rs.Eof Then
		CheckUserNameExist = 0
	Else
		CheckUserNameExist = 1
	End if
	Rs.Close
	Set Rs = Nothing

End Function

Rem 检测某用户名ID是否存在
Function CheckUserIDExist(UserID)

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select * from LeadBBS_User where ID=" & UserID,1),0)
	If Rs.Eof Then
		CheckUserIDExist = 0
	Else
		CheckUserIDExist = 1
	End if
	Rs.Close
	Set Rs = Nothing

End Function

Function DisplayOfficerString(Officer)

	Dim Officer_Temp,Temp_N,dotFlag
	dotFlag = 0
	Officer_Temp = split(Officer,",")
	For Temp_N = 0 to Ubound(Officer_Temp,1)
		If isNumeric(Officer_Temp(Temp_N)) Then
			Officer_Temp(Temp_N) = cCur(Officer_Temp(Temp_N))
			If Officer_Temp(Temp_N)>=0 and Officer_Temp(Temp_N)<=DEF_UserOfficerNum Then
				If dotFlag = 0 Then
					dotFlag = 1
					DisplayOfficerString = DisplayOfficerString & DEF_UserOfficerString(Officer_Temp(Temp_N))
				Else
					DisplayOfficerString = DisplayOfficerString & "," & DEF_UserOfficerString(Officer_Temp(Temp_N))
				End If
			End If
		End If
	Next

End Function

Function DisplayOfficerList

	Dim Temp_N
	Response.Write "<br><p><u>" & DEF_PointsName(9) & "对照表</u><br><img src=" & DEF_BBS_HomeUrl & "images/NULL.GIF height=5 width=3><br>"
	For Temp_N = 0 to DEF_UserOfficerNum
		Response.Write Temp_N & " - "
		%>
		<img src=../../images/blank.gif class="img_medal" style="width:16px;height:16px;background:url(../../images/others/medal_icons.png) no-repeat;background-position:-<%=Temp_N*39+2%>px -2px;">
		<%
		Response.write DEF_UserOfficerString(Temp_N) & "<br>" & VbCrLf
	Next

End Function

Function DisplayLevelList

	Dim Temp_N
	Response.Write "<br><p><u>" & DEF_PointsName(3) & "对照表</u><br><img src=" & DEF_BBS_HomeUrl & "images/NULL.GIF height=5 width=3><br>"
	For Temp_N = 0 to DEF_UserLevelNum
		Response.Write Temp_N & " - " & DEF_UserLevelString(Temp_N) & "<br>" & VbCrLf
	Next

End Function
%>