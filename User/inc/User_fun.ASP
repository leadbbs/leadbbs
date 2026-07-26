<%
Dim ApplyFlag
ApplyFlag = 0
Dim Form_UserName,Form_Pass,Form_Mail,Form_Address
Dim Form_Sex,Form_Birthday,Form_ApplyTime,Form_ICQ,Form_OICQ,Form_MobileTel,old_Form_MobileTel,Form_Sessionid,Form_Online
Dim Form_Prevtime,Form_Userphoto,Form_IP,Form_UserLevel,Form_Homepage,Form_Underwrite,Form_PrintUnderwrite
Dim Form_Officer,Form_Points
Dim Form_Password1,Form_Password2,Form_byear,Form_bday,Form_bmonth
Dim Form_FaceHeight,Form_FaceWidth,Form_FaceUrl,Form_ShowFlag,Form_NotSecret
Dim Form_Question,Form_Answer,Form_UserTitle,OLd_Form_Question,OLd_Form_Answer,OLd_Form_UserName
Dim Form_FaceUrl_Old,Form_FaceWidth_Old,Form_FaceHeight_Old,Form_RegVerifyAnswer
Dim Form_App_AppType,Form_App_appid,Form_App_GuestName,Form_App_Token

Rem =====初始化变量=====
Form_Sex = 0
Form_Online = 0
Form_Officer = 0
Form_UserLevel = 0
'Form_Userphoto = "224"
Form_Points = 0
Form_ApplyTime=GetTimeValue(DEF_Now)
Form_Prevtime=Form_ApplyTime
Form_IP = GBL_IPAddress
Form_Sessionid = session.sessionid
Rem =====初始化结束=====

Dim Form_UpClass,Form_UpFlag,Form_Submitflag
Form_UpFlag = 0

Function GetFormData(name)

	If Form_UpFlag = 0 Then
		GetFormData = Request.Form(name)
	Else
		GetFormData = Form_UpClass.form(name)
	End If

End Function

Sub User_GetStartValue

	If Request.QueryString("dontRequestFormFlag") = "" Then
		Form_UpFlag = 0
	Else
		Form_UpFlag = 1
		Server.ScriptTimeOut=3000
		set Form_UpClass=new upload_Class
		Form_UpClass.ProgressID = Request.QueryString("Upload_ID")
		Form_UpClass.GetUpFile
	End If

	Form_Submitflag = Request.QueryString("submitflag")
	If Form_Submitflag = "" Then Form_Submitflag = GetFormData("submitflag")

End Sub

Function checkFormData

	Dim DEF_FiltrateUserNameStringArray
	DEF_FiltrateUserNameStringArray = Split(DEF_FiltrateUserNameString,"|")

	If ApplyFlag = 1 Then
		Form_UserName = Left(Trim(GetFormData("Form_UserName")),20)
		Form_RegVerifyAnswer = GetFormData("Form_RegVerifyAnswer")
	End If

	rem 绑定网站登录修改验证
	If Old_Form_Answer = "" and inStr(GBL_CHK_User,"#") > 0 Then
		Form_UserName = Left(Trim(GetFormData("Form_UserName")),20)		
	End if
	
	Select Case Form_Action
		Case "uploadface":
		if upload_step <> "1" then
			Form_Userphoto = Left(Trim(GetFormData("Form_Userphoto")),14)
			If DEF_AllDefineFace <> 0 Then
				Form_FaceUrl = Trim(GetFormData("Form_FaceUrl"))
				Form_FaceWidth = Left(Trim(GetFormData("Form_FaceWidth")),14)
				Form_FaceHeight = Left(Trim(GetFormData("Form_FaceHeight")),14)
			End If

			If DEF_AllDefineFace <> 0 and (Form_FaceUrl <> Form_FaceUrl_OLd or Form_FaceWidth <> Form_FaceWidth_Old or Form_FaceHeight <> Form_FaceHeight_Old) Then
				If IsNumeric(Form_FaceWidth) = 0 or instr(Form_FaceWidth,",")>0 or Form_FaceWidth = "" Then
					If Form_FaceUrl <> "" Then
						Form_FaceWidth = DEF_AllFaceMaxWidth
					End If
				End If		
				If IsNumeric(Form_FaceHeight) = 0 or instr(Form_FaceHeight,",")>0 or Form_FaceHeight = "" Then
					If Form_FaceUrl <> "" Then Form_FaceHeight = DEF_AllFaceMaxWidth
				End If
				
				If Form_FaceUrl <> "" Then
					Form_FaceWidth = cCur(Form_FaceWidth)
					Form_FaceHeight = cCur(Form_FaceHeight)
					If Form_FaceWidth <20 then Form_FaceWidth = 20
					if Form_FaceWidth > DEF_AllFaceMaxWidth then Form_FaceWidth = DEF_AllFaceMaxWidth
					if Form_FaceHeight < 20 then Form_FaceHeight = 20
					if Form_FaceHeight > DEF_AllFaceMaxWidth Then Form_FaceHeight = DEF_AllFaceMaxWidth
				End If
			End If
			
			
			If Form_FaceUrl = "" Then
				If IsNumeric(Form_FaceWidth) = 0 or instr(Form_FaceWidth,",")>0 or Form_FaceWidth = "" Then
					Form_FaceWidth = 0
				Else
					Form_FaceWidth = cCur(Form_FaceWidth)
				End If
				
				If IsNumeric(Form_FaceHeight) = 0 or instr(Form_FaceHeight,",")>0 or Form_FaceHeight = "" Then
					Form_FaceHeight = 0
				Else
					Form_FaceHeight = cCur(Form_FaceHeight)
				End If
			ElseIf (Form_FaceUrl <> Form_FaceUrl_OLd or Form_FaceWidth <> Form_FaceWidth_Old or Form_FaceHeight <> Form_FaceHeight_Old) Then
				Dim MyHomeUrl
				MyHomeUrl = LCase(Request.Servervariables("SCRIPT_NAME"))
				If Right(MyHomeUrl,len("/user/" & LCase(DEF_RegisterFile))) = "/user/" & LCase(DEF_RegisterFile) or Right(MyHomeUrl,len("/user/usermodify.asp")) = "/user/usermodify.asp" Then
					MyHomeUrl = LD_GetUrl(1)
					Form_FaceUrl = Replace(Form_FaceUrl,MyHomeUrl,"../")
				Else
					MyHomeUrl = ""
				End If
		
				If Lcase(Left(Replace(Form_FaceUrl,"\","/"),7)) <> "http://" and Lcase(Left(Replace(Form_FaceUrl,"\","/"),6)) <> "ftp://" and Lcase(Left(Replace(Form_FaceUrl,"\","/"),8)) <> "https://" Then
					If DEF_AllDefineFace = 2 Then
						If inStr(LCase(Form_FaceUrl),"face") = False Then
							GBL_CHK_TempStr = "自定头像错误，不允许引用论坛头像及上传头像以外的图片作为头像."
							GBL_CHK_Flag = 0
							Exit Function
						End If
					End If
					If Left(Form_FaceUrl,1) <> "/" and Left(Form_FaceUrl,1) <> "\" and Left(Form_FaceUrl,1) <> "." and Lcase(Left(Form_FaceUrl,5)) <> "http:" and Lcase(Left(Form_FaceUrl,4)) <> "ftp:" and Lcase(Left(Form_FaceUrl,6)) <> "https:" Then
						GBL_CHK_TempStr = "自定头像错误，不存在的图片."
						GBL_CHK_Flag = 0
						Exit Function
					End If
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
							If (not fs.FileExists(Server.Mappath(Form_FaceUrl))) Then
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
							Set fs = Nothing
							If DEF_EnableGFL = 1 Then
								Dim TempW,TempH
								TempW = DEF_AllFaceMaxWidth
								TempH = DEF_AllFaceMaxWidth
								If CheckIsGoodImg(Server.Mappath(Form_FaceUrl),TempW,TempH) = 0 Then
									GBL_CHK_TempStr = "自定头像错误，原因是" & GBL_CHK_TempStr & "!<br>"
									GBL_CHK_Flag = 0
									Exit Function
								Else
									Form_FaceWidth = TempW
									Form_FaceHeight = TempH
								End If
							End If
						End If
					End If
				Else
					If DEF_AllDefineFace = 2 Then
						GBL_CHK_TempStr = "论坛已经设置为不允许引用站外图片作为头像!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
				End If
			End If
		end if
		Case else
		
			if applyflag = 1 then
				select case DEF_UserNewRegAttestMode
					case 1: '邮件认证
						Form_Mail = Trim(GetFormData("Form_Mail"))
					case 3: '手机认证
						Form_MobileTel = Left(Trim(GetFormData("Form_MobileTel")),15)
					case 4: '手机或邮箱认证
						Form_Mail = Trim(GetFormData("Form_Mail"))
						if CheckMobilePhone(Form_Mail) = true then
							Form_MobileTel = Form_Mail
							Form_Mail = ""
						end if
				end select
				
			else '用户无法直接修改邮箱或手机号码
			end if
			Form_Address = Trim(GetFormData("Form_Address"))
			Form_Sex = Trim(GetFormData("Form_Sex"))
			Form_ICQ = Left(Trim(GetFormData("Form_ICQ")),14)
			Form_OICQ = Left(Trim(GetFormData("Form_OICQ")),14)
			
			Form_Homepage = Trim(GetFormData("Form_Homepage"))
			Form_Underwrite = GetFormData("Form_Underwrite")
			Form_Password1 = Trim(GetFormData("Form_Password1"))
			Form_Password2 = Trim(GetFormData("Form_Password2"))
			Form_byear = Left(Trim(GetFormData("Form_byear")),14)
			Form_bday = Left(Trim(GetFormData("Form_bday")),14)
			Form_bmonth = Left(Trim(GetFormData("Form_bmonth")),14)
			Form_ShowFlag = Trim(GetFormData("Form_ShowFlag"))
			Form_NotSecret = Trim(GetFormData("Form_NotSecret"))
			Form_Answer = Trim(GetFormData("Form_Answer"))
			Form_Question = Trim(GetFormData("Form_Question"))
		
			If Form_ShowFlag <> "0" and Form_ShowFlag <> "1" Then Form_ShowFlag = 0
			If Form_NotSecret <> "0" and Form_NotSecret <> "1" Then Form_NotSecret = 0
			
			If DEF_UserEnableUserTitle = 1 and Form_UserLevel >= DEF_UserUserTitleNeedLevel Then
				Form_UserTitle = UBB_FiltrateBadWords(LeftTrue(Trim(GetFormData("Form_UserTitle")),18))
				For Loop_N = 0 to Ubound(DEF_FiltrateUserNameStringArray)
					If inStr(LCase(Form_UserTitle),LCase(DEF_FiltrateUserNameStringArray(Loop_N))) and DEF_FiltrateUserNameStringArray(Loop_N) <> "" Then
						GBL_CHK_TempStr = "非法的头衔! <br>" & VbCrLf
						GBL_CHK_Flag = 0
						Exit Function
					End If
				Next
			End If
		
			If CheckWriteEventSpace = 0 and ApplyFlag = 0 Then
				GBL_CHK_TempStr = "您在修改资料的过程中提交得太频，请稍候再作提交! <br>" & VbCrLf
				GBL_CHK_Flag = 0
				Exit Function
			End If
		
			Dim DateFlag
		
			DateFlag = 1
		
			If GBL_UserID > 0 Then
				If CheckUserIDExist(GBL_UserID) = 0 Then
					GBL_CHK_TempStr = "用户不存在，不能完成修改! <br>" & VbCrLf
					GBL_CHK_Flag = 0
					Exit Function
				End If
			End If
		
			Dim TempURL,Loop_N
			
				
				if Old_Form_Answer = "" then
					If ApplyFlag = 0 then
						If Form_Question="" Then
							GBL_CHK_TempStr = "请输入问题提示!<br>"
							GBL_CHK_Flag = 0
							Exit Function
						End If
					end if
					If StrLength(Form_Question) > 20 Then
						GBL_CHK_TempStr = "问题提示不能超过20个字!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
					If ApplyFlag = 0 then
						If Form_Answer="" Then
							GBL_CHK_TempStr = "请输入问题提示答案!<br>"
							GBL_CHK_Flag = 0
							Exit Function
						End If
					end if
					If Len(Form_Answer) < 4 and Form_Answer <> "" Then
						GBL_CHK_TempStr = "问题提示答案太短!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
					If Form_Answer <> "" and ((Len(Form_Answer) = 4 and isNumeric(Form_Answer)) or Replace(Form_Answer,Left(Form_Answer,1),"") = "") Then
						GBL_CHK_TempStr = "问题提示答案太简单!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
					If LCase(Form_Answer) = LCase(Form_Question) and Form_Answer <> "" Then
						GBL_CHK_TempStr = "问题提示与提示答案不能相同!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
					If len(Form_Answer)>20 Then
						GBL_CHK_TempStr = "问题提示答案不能超过20个字!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
				end if
				
			If ApplyFlag = 1 or (Old_Form_Answer = "" and inStr(GBL_CHK_User,"#") > 0) Then
				If Form_UserName="" Then
					GBL_CHK_TempStr = "请输入用户名!<br>"
					GBL_CHK_Flag = 0
					Exit Function
				Else
					if check_usernameFilter(Form_UserName,"用户名") = 0 then
						GBL_CHK_Flag = 0
						exit function
					end if
					
					ajaxflag = toNum(ajaxflag,0)
					If ApplyFlag = 1 and ajaxflag = 0 then
						If LMT_RegVerifyQuestion <> "" and LCase(Form_RegVerifyAnswer) <> LCase(LMT_RegVerifyAnswer) Then
							GBL_CHK_TempStr = "注册验证信息错误!<br>"
							GBL_CHK_Flag = 0
							Exit Function
						End If
					end if
				End If
				
				If inStr(Form_UserName," ") Then Form_UserName = Replace(Form_UserName,"  "," ")
		
				If strLength(Form_UserName) > 14 Then
					GBL_CHK_TempStr = "用户名太长!<br>"
					GBL_CHK_Flag = 0
					Exit Function
				End If
		
				If strLength(Form_UserName) < DEF_ShortestUserName Then
					GBL_CHK_TempStr = "用户名太短，最少要求" & DEF_ShortestUserName & "个字符!<br>"
					GBL_CHK_Flag = 0
					Exit Function
				End If		
		
				If CheckUserNameExist(Form_UserName) = 1 Then
					GBL_CHK_TempStr = "用户名已经存在，请用其它用户名! <br>" & VbCrLf
					GBL_CHK_Flag = 0
					Exit Function
				End If

				if CheckMobilePhone(Form_UserName) = true then
					GBL_CHK_TempStr = "禁止使用类似手机号码的名称作为用户名! <br>" & VbCrLf
					GBL_CHK_Flag = 0
					Exit Function
				End If
				
				If ApplyFlag = 1 then
					If reg_action = "bind" and reg_command = "reg" Then
						If reg_checkAppidBinded = 0 Then
							GBL_CHK_Flag = 0
							Exit Function
						End If
					End If
				end if
			End If
			If (ApplyFlag = 0) and inStr(GBL_CHK_User,"#") < 1 Then
				If Old_Form_Answer <> "" Then
				Form_Pass = GetFormData("oldpass")
					If Form_Pass <> GBL_CHK_Pass and MD5(Form_Pass) <> GBL_CHK_Pass and Mid(MD5(Form_Pass),9,16) <> GBL_CHK_Pass Then
						GBL_CHK_TempStr = "旧的密码错误，无法完成修改!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
				End If
				If GBL_BoardMasterFlag >= 4 Then
					If Len(Form_Pass) < DEF_UserShortestPasswordMaster and Len(Form_Password2) < DEF_UserShortestPasswordMaster Then
						GBL_CHK_TempStr = "你的密码已经过时，密码最短要求" & DEF_UserShortestPasswordMaster & "位!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
				Else
					If Len(Form_Pass) < DEF_UserShortestPassword and Len(Form_Password2) < DEF_UserShortestPassword Then
						GBL_CHK_TempStr = "你的密码已经过时，密码最短要求" & DEF_UserShortestPassword & "位!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
				End If
			End If
		
			If Len(Form_Mail) > 60 Then
				GBL_CHK_TempStr = "邮箱地址不能长于60个字符!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		
			If Form_Mail <> "" Then
				If IsValidEmail(Form_Mail) = false Then
					GBL_CHK_TempStr = "邮箱地址填写错误!<br>"
					GBL_CHK_Flag = 0
					Exit Function
				End If
			End If
		
			If ApplyFlag = 1 and DEF_UserNewRegAttestMode = 1 Then
				If Form_Mail = "" Then
					GBL_CHK_TempStr = "邮箱地址必须填写!<br>"
					GBL_CHK_Flag = 0
					Exit Function
				End If
			end if
		
			If inStr(Form_Mail,"@") = false and Form_Mail <> "" Then
				GBL_CHK_TempStr = "邮箱地址错误!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		
			If Form_Mail <> "" and ApplyFlag = 1 Then
				If CheckMailExist(Form_Mail) = 1 Then
					GBL_CHK_TempStr = "邮箱<b><u>" & htmlencode(Form_Mail) & "</u></b>已经有人使用，请换用邮箱地址! <br>" & VbCrLf
					GBL_CHK_Flag = 0
					Exit Function
				End If
			End If
		
			If Form_ICQ <> "" Then
				If IsNumeric(Form_ICQ) = 0 or instr(Form_ICQ,",")>0 Then
					GBL_CHK_TempStr = "ICQ号码必须是数字!<br>"
					GBL_CHK_Flag = 0
					Exit Function
				Else 
					If Form_ICQ>1999999999 Then
						GBL_CHK_TempStr = "ICQ号码错误!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
				End If
			End If
		
			If Form_OICQ <> "" Then
				If IsNumeric(Form_OICQ) = 0 or instr(Form_OICQ,",")>0 Then
					GBL_CHK_TempStr = "你的OICQ(QQ)号码必须是数字!<br>"
					GBL_CHK_Flag = 0
					Exit Function
				else
					If Form_OICQ>9999999999 Then
						GBL_CHK_TempStr = "你的OICQ(QQ)号码错误!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
				End If
			End If
			
			if ApplyFlag = 1 and DEF_UserNewRegAttestMode = 3 and Form_MobileTel = "" then			
					GBL_CHK_TempStr = "手机号码必须填写!<br>"
					GBL_CHK_Flag = 0
					Exit Function
			end if
			
			if ApplyFlag = 1 and DEF_UserNewRegAttestMode = 4 and (Form_MobileTel="" and Form_Mail = "") then
					GBL_CHK_TempStr = "手机号码或邮箱地址：必须填写其中的一项!<br>"
					GBL_CHK_Flag = 0
					Exit Function
			end if
			
			If ApplyFlag = 1 and Form_MobileTel <> "" and Form_MobileTel & "" <> "0" Then
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
				if Form_MobileTel & "" <> "" and Form_MobileTel <> "0" then
					if checkMobileTelExist(Form_MobileTel) = 1 then
						GBL_CHK_TempStr = "您填写的手机号码已被注册．<br>"
						GBL_CHK_Flag = 0
						Exit Function
					end if
				end if
			End If
		
			If Len(Form_Address) > 150 Then
				GBL_CHK_TempStr = "地址太长!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		
			If Len(Form_Underwrite) > 510 Then
				GBL_CHK_TempStr = "签名太长!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			ElseIf StrLength(Form_Underwrite) > 255 Then
				GBL_CHK_TempStr = "签名太长!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		
			For Loop_N = 0 to Ubound(DEF_FiltrateUserNameStringArray)
				'If inStr(Lcase(Form_Underwrite),DEF_FiltrateUserNameStringArray(Loop_N)) and DEF_FiltrateUserNameStringArray(Loop_N) <> "" Then
				'	GBL_CHK_TempStr = "非法的签名，请仔细确认输入的字符<br>" & VbCrLf
				'	GBL_CHK_Flag = 0
				'	Exit Function
				'End If
			Next
		
			If Form_Sex <> "密" and Form_Sex <> "男" and Form_Sex <> "女" Then Form_Sex = "密"
		
			If Form_byear <> "" and Form_byear <> "19" Then
				If IsNumeric(Form_byear) = 0 or instr(Form_byear,",")>0 Then
					GBL_CHK_TempStr = "出生年错误!<br>"
					GBL_CHK_Flag = 0
					Exit Function
				else
					Form_byear = cCur(Form_byear)
					If (Form_byear>year(DEF_Now) or Form_byear<1900) Then
						GBL_CHK_TempStr = "出生年错误!1<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
				End If
			Else
				DateFlag = 0
			End If
		
			If Form_bmonth <> "" Then
				If IsNumeric(Form_bmonth) = 0 or instr(Form_bmonth,",")>0 Then
					GBL_CHK_TempStr = "出生月份错误!<br>"
					GBL_CHK_Flag = 0
					Exit Function
				Else
					If Form_bmonth>12 or Form_bmonth<0 Then
						Form_bmonth = cCur(Form_bmonth)
						GBL_CHK_TempStr = "出生月份错误!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
				End If
			Else
				DateFlag = 0
			End If
		
			If Form_bday <> "" Then
				If IsNumeric(Form_bday) = 0 or inStr(Form_bday,",") > 0 Then
					GBL_CHK_TempStr = "出生日期错误!<br>"
					GBL_CHK_Flag = 0
					Exit Function
				Else
					If Form_bday > 31 or Form_bday < 0 Then
						Form_bday = cCur(Form_bday)
						GBL_CHK_TempStr = "出生日期错误!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
				End If
			Else
				DateFlag = 0
			End If
		
		
			If strLength(Form_Homepage) > 250 Then
				GBL_CHK_TempStr = "主页地址太长!<br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		
			Form_birthday = 0
			If DateFlag = 1 Then
				Form_birthday = dateserial(Form_byear,Form_bmonth,Form_bday)
				If isTrueDate(Form_birthday) Then
					Form_birthday = GetTimeValue(Form_birthday)
				Else
					Form_birthday = 0
				End If
			End If
		
			If isNumeric(Form_Userphoto) = 0 or instr(Form_Userphoto,",")>0 Then
				If Form_Sex = "男" Then
					Form_Userphoto = 1
				Else
					If Form_Sex = "女" Then
						Form_Userphoto = 2
					Else
						Form_Userphoto = 3
					End If
				End If
			End If
			
			
			Form_PrintUnderwrite = ""
			If Form_Password1 = "" and Form_Password2 = "" and ApplyFlag = 0 and (Old_Form_Answer <> "" or inStr(GBL_CHK_User,"#") < 1) Then
				Form_Password1 = ""
				Form_Password2 = ""
			Else
				If Form_Password1="" Then
					GBL_CHK_TempStr = "请输入密码!<br>"
					GBL_CHK_Flag = 0
					Exit Function
				End If
				If Len(Form_Password1) > 15 Then
					GBL_CHK_TempStr = "密码太长!<br>"
					GBL_CHK_Flag = 0
					Exit Function
				End If
				
				If Form_Password2="" Then
					GBL_CHK_TempStr = "请输入验证密码!<br>"
					GBL_CHK_Flag = 0
					Exit Function
				End If
				If Len(Form_Password2) > 15 Then
					GBL_CHK_TempStr = "验证密码太长!<br>"
					GBL_CHK_Flag = 0
					Exit Function
				End If
				If Form_Password1 <> Form_Password2 Then
					GBL_CHK_TempStr = "两次密码输入不相同!<br>"
					GBL_CHK_Flag = 0
					Exit Function
				End If
				If GBL_BoardMasterFlag >= 4 Then
					If Form_Password2 = Form_UserName or Len(Form_Password2) < DEF_UserShortestPasswordMaster Then
						GBL_CHK_TempStr = "密码不能和用户名相同，并且论坛管理成员密码不能小于" & DEF_UserShortestPasswordMaster & "位!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
					If (Len(Form_Password2) = DEF_UserShortestPasswordMaster and isNumeric(Form_Password2)) or Replace(Form_Password2,Left(Form_Password2,1),"") = "" Then
						GBL_CHK_TempStr = "填写的密码太简单，请使用稍复杂的密码!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
				Else
					If Form_Password2 = Form_UserName or Len(Form_Password2) < DEF_UserShortestPassword Then
						GBL_CHK_TempStr = "密码不能和用户名相同，并且不能小于" & DEF_UserShortestPassword & "位!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
					If (Len(Form_Password2) = DEF_UserShortestPassword and isNumeric(Form_Password2)) or Replace(Form_Password2,Left(Form_Password2,1),"") = "" Then
						GBL_CHK_TempStr = "填写的密码太简单，请使用稍复杂的密码!<br>"
						GBL_CHK_Flag = 0
						Exit Function
					End If
				End If
			End If
	End select


	
	Form_Userphoto = cCur(Form_Userphoto)	
	If (Form_Userphoto < 1 or Form_Userphoto > DEF_faceMaxNum) and ApplyFlag = 1 Then
		If Form_Sex = "男" Then
			Form_Userphoto = 1
		Else
			If Form_Sex = "女" Then
				Form_Userphoto = 2
			Else
				Form_Userphoto = 3
			End If
		End If
	End If
	
		
	If ApplyFlag = 1 Then
		If CheckIsRestSpaceTime = 1 Then
			If GBL_CHK_TempStr = "" Then GBL_CHK_TempStr = "不能连续申请太多的用户，请稍候!<br>"
			GBL_CHK_Flag = 0
			Exit Function
		End If
	End If

	If ApplyFlag = 1 Then
		If ShowTestNumber > 2 Then
			If CheckRndNumber = 0 Then
				GBL_CHK_TempStr = "<b><font color=ff0000>验证码填写错误!</font></b><br>"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		End If
	End If
	GBL_CHK_Flag = 1

End Function

Function check_usernameFilter(cname,itemName)


	Dim DEF_FiltrateUserNameStringArray
	DEF_FiltrateUserNameStringArray = Split(DEF_FiltrateUserNameString,"|")
					check_usernameFilter = 1
					If right(cname,2) = "QQ" or right(cname,2) = "LD" or cname = "游客" or cname = "隐身用户" Then
						GBL_CHK_TempStr = "不允许使用“" & cname & "”作为" & itemName & "!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
		
					If Len(cname) > 14 Then
						GBL_CHK_TempStr = "" & itemName & "太长!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
		
					Dim TempChar
					dim TempURL,Loop_N
					TempURL = Len(cname)
					For Loop_N = 1 to TempURL
						TempChar = ASC(Mid(cname,Loop_N,1))
						If TempChar < 0 Then TempChar = TempChar + 65535
						If LMT_UserNameEnableEnglishWords = 0 Then
							If TempChar < 33088 Then
								GBL_CHK_TempStr = "非法的" & itemName & ",不允许使用西文字符(a-z,A-Z,数字)!<br>"
								check_usernameFilter = 0
								Exit Function
							End If
						Else	
							If TempChar = 32 Then
								If TempURL > Len(Replace(cname," ","")) + 2 Then '允许最多两个空格且不同时在一起
									GBL_CHK_TempStr = "" & itemName & "最多只允许使用两个空格!<br>"
									check_usernameFilter = 0
									Exit Function
								End If
							Else
								If TempChar < 45 or (TempChar>45 and TempChar<48) or (TempChar>57 and TempChar<65) or (TempChar>90 and TempChar < 95) or TempChar = 96 or (TempChar > 122 and TempChar < 33088) Then
									GBL_CHK_TempStr = "" & itemName & "含有非法字符(请使用数字,字母,下划线)!<br>"
									check_usernameFilter = 0
									Exit Function
								End If
							End If
						End If
						
						IF LMT_UserNameEnableChineseChar = 0 Then
							If TempChar > 41214 and TempChar < 43584 Then
								GBL_CHK_TempStr = "非法的" & itemName & ",不允许使用中文全角字符!<br>"
								check_usernameFilter = 0
								Exit Function
							End If
						End If
						
						IF LMT_UserNameEnableChineseWords = 0 Then
							If (TempChar >= 33088 and TempChar < 41378) or TempChar > 43508 Then
								GBL_CHK_TempStr = "非法的" & itemName & ",不允许使用中文汉字!<br>"
								check_usernameFilter = 0
								Exit Function
							End If
						End If
						
						If TempChar > 65184 Then
							GBL_CHK_TempStr = "非法的" & itemName & ",含有非法字符,请确认!<br>"
							check_usernameFilter = 0
							Exit Function
						End If
					Next
					If Left(cname,1) = "_" or Left(cname,1) = "-" or Right(cname,1) = "-" or Right(cname,1) = "_" Then
						GBL_CHK_TempStr = "" & itemName & "不能以连接号_或减号-开始或结束!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
		
					If inStr(UBB_FiltrateBadWords(cname),"*") > 0 Then
						GBL_CHK_TempStr = "" & itemName & "含有禁用字，请更换一个" & itemName & "!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
				
					If inStr(cname,"'")>0 or inStr(cname,chr(34))>0 Then
						GBL_CHK_TempStr = "" & itemName & "不能包含'或" & chr(34) & "符号!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
		
					If inStr(cname,"`")>0 or inStr(cname,"~")>0 or inStr(cname,"&")>0 Then
						GBL_CHK_TempStr = "" & itemName & "不能包含`或&符号!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
					If inStr(cname,"!")>0 or inStr(cname,"@")>0 or inStr(cname,"^")>0 Then
						GBL_CHK_TempStr = "" & itemName & "不能包含!@^符号!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
					If inStr(cname,"#")>0 or inStr(cname,"$")>0 or inStr(cname,"%")>0 Then
						GBL_CHK_TempStr = "" & itemName & "不能包含#$%符号!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
					If inStr(cname,"*")>0 or inStr(cname,"(")>0 or inStr(cname,")")>0 Then
						GBL_CHK_TempStr = "" & itemName & "不能包含*()符号!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
					If inStr(cname,"+")>0 or inStr(cname,"=")>0 or inStr(cname,"|")>0 Then
						GBL_CHK_TempStr = "" & itemName & "不能包含+=|符号!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
					If inStr(cname,chr(10))>0 or inStr(cname,chr(13))>0 Then
						GBL_CHK_TempStr = "" & itemName & "不能包含换行等符号!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
					If inStr(cname,chr(127))>0 or inStr(cname,chr(9))>0 Then
						GBL_CHK_TempStr = "" & itemName & "不能包含制表符等符号!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
					If inStr(cname,"[")>0 or inStr(cname,"]")>0 or inStr(cname,"\")>0 Then
						GBL_CHK_TempStr = "" & itemName & "不能包含[]\等符号!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
					If inStr(cname,"{")>0 or inStr(cname,"}")>0 or inStr(cname,";")>0 Then
						GBL_CHK_TempStr = "" & itemName & "不能包含{};等符号!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
					If inStr(cname,":")>0 or inStr(cname,",")>0 or inStr(cname,".")>0 Then
						GBL_CHK_TempStr = "" & itemName & "不能包含:,.等符号!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
					If inStr(cname,"<")>0 or inStr(cname,">")>0 or inStr(cname,"/")>0 or inStr(cname,"?")>0 Then
						GBL_CHK_TempStr = "" & itemName & "不能包含<>?/等符号!<br>"
						check_usernameFilter = 0
						Exit Function
					End If
					
					For Loop_N = 0 to Ubound(DEF_FiltrateUserNameStringArray)
						If inStr(Lcase(cname),DEF_FiltrateUserNameStringArray(Loop_N)) and DEF_FiltrateUserNameStringArray(Loop_N) <> "" Then
							GBL_CHK_TempStr = "此" & itemName & "已经禁止使用，请使用其它的名字!<br>"
							check_usernameFilter = 0
							Exit Function
						End If
					Next
		
					Dim FobWords
					FobWords = Array(91,92,304,305,430,431,437,438,12460,12461,12462,12463,12464,12465,12466,12467,12468,12469,12470,12471,12472,12473,12474,12475,12476,12477,12478,12479,12480,12481,12482,12483,12485,12486,12487,12488,12489,12490,12496,12497,12498,12499,12500,12501,12502,12503,12504,12505,12506,12507,12508,12509,12510,12532,12533,65339,65340)
					TempURL = Ubound(FobWords,1)
					For Loop_N = 1 to TempURL
						If inStr(cname,ChrW(FobWords(Loop_N))) > 0 Then
							GBL_CHK_TempStr = "" & itemName & "中的字符<u>" & ChrW(FobWords(Loop_N)) & "</u>属于非法字符!<br>"
							check_usernameFilter = 0
							Exit Function
						End If
					Next

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
	Set Rs = LDExeCute(sql_select("Select ID from LeadBBS_User where UserName='" & Replace(UserName,"'","''") & "'",2),0)
	If Rs.Eof Then
		CheckUserNameExist = 0
	Else
		If  cCur(Rs(0)) <> GBL_UserID Then
			CheckUserNameExist = 1
		Else
			Rs.MoveNext
			If Not Rs.Eof Then
				CheckUserNameExist = 1
			Else
				CheckUserNameExist = 0
			End If
		End If
	End if
	Rs.Close
	Set Rs = Nothing

End Function

Rem 手机号码检测
Function checkMobileTelExist(tel)

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select ID from LeadBBS_User where MobileTel=" & Replace(tel,"'","''") & "",2),0)
	If Rs.Eof Then
		checkMobileTelExist = 0
	Else
		If  cCur(Rs(0)) <> GBL_UserID Then
			checkMobileTelExist = 1
		Else
			Rs.MoveNext
			If Not Rs.Eof Then
				checkMobileTelExist = 1
			Else
				checkMobileTelExist = 0
			End If
		End If
	End if
	Rs.Close
	Set Rs = Nothing

End Function

Rem 检测某邮箱是否存在
Function CheckMailExist(Mail)

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select ID from LeadBBS_User where Mail='" & Replace(Mail,"'","''") & "'",2),0)
	If Rs.Eof Then
		CheckMailExist = 0
	Else
		If  cCur(Rs(0)) <> GBL_UserID Then
			CheckMailExist = 1
		Else
			Rs.MoveNext
			If Not Rs.Eof Then
				CheckMailExist = 1
			Else
				CheckMailExist = 0
			End If
		End If
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

Function reg_CheckAppid(AppType,appid)

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select * from LeadBBS_AppLogin where appType=" & Replace(appType,"'","''") & " and appid='" & Replace(appid,"'","''") & "'",1),0)
	If Rs.Eof Then
		reg_CheckAppid = 0
	Else
		reg_CheckAppid = 1
	End if
	Rs.Close
	Set Rs = Nothing

End Function

Function reg_CheckAppidForUserID(AppType,userid)

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select * from LeadBBS_AppLogin where appType=" & Replace(appType,"'","''") & " and userid=" & userid,1),0)
	If Rs.Eof Then
		reg_CheckAppidForUserID = 0
	Else
		reg_CheckAppidForUserID = 1
	End if
	Rs.Close
	Set Rs = Nothing

End Function


Function CheckIsRestSpaceTime

	Dim Rs,ApplyTime,IP,Temp_ID
	Set Rs = LDExeCute(sql_select("Select ApplyTime,IP,ID from LeadBBS_User order by id desc",1),0)
	If Rs.Eof Then
		CheckIsRestSpaceTime = 0
		Rs.Close
		Set Rs = Nothing
		Exit Function
	Else
		ApplyTime = Rs(0)
		IP = Rs(1)
		Temp_ID = Rs(2)
		Rs.Close
		Set Rs = Nothing
	End if

	GBL_CHK_TempStr = ""
	If DEF_RegNewUserTotalRestTime > 0 Then
		If DateDiff("s", RestoreTime(ApplyTime), DEF_Now) < DEF_RegNewUserTotalRestTime and DateDiff("s", RestoreTime(ApplyTime), DEF_Now) > 0 Then
			CheckIsRestSpaceTime = 1
			GBL_CHK_TempStr = " 论坛限制" & DEF_RegNewUserTotalRestTime & "秒内只允许注册一名新用户，请稍候再来．<br>" & VbCrLf
			Exit Function
		End If
	End If
		
	If DateDiff("s", RestoreTime(ApplyTime), DEF_Now) < 0 or IP<>Form_IP Then
		CheckIsRestSpaceTime = 0
		Exit Function
	End If
	If DateDiff("s", RestoreTime(ApplyTime), DEF_Now) < DEF_RestSpaceTime Then
		CheckIsRestSpaceTime = 1
	Else
		CheckIsRestSpaceTime = 0
	End If

End Function

Function IsValidEmail(Email)

	Dim names, name, i, c
	IsValidEmail = true
	names = Split(Email, "@")
	If UBound(names) <> 1 Then
		IsValidEmail = false
		Exit Function
	End If

	For Each Name in Names
		If Len(name) <= 0 Then
			IsValidEmail = false
			Exit Function
		End If
		For i = 1 to Len(name)
			c = Lcase(Mid(name, i, 1))
			If InStr("abcdefghijklmnopqrstuvwxyz_-.", c) <= 0 and not IsNumeric(c) Then
				IsValidEmail = false
				Exit Function
			End If
		Next
		If Left(name, 1) = "." or Right(name, 1) = "." Then
			IsValidEmail = false
			Exit Function
		End If
	Next
	If InStr(names(1), ".") <= 0 Then
		IsValidEmail = false
		Exit Function
	End If
	i = Len(names(1)) - InStrRev(names(1), ".")
	If i <> 2 and i <> 3 and i <> 4 Then
		IsValidEmail = false
		Exit Function
	End If
	If InStr(Email, "..") > 0 Then
		IsValidEmail = false
	End If

End Function
%>