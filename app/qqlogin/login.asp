<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="oauth.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
dim cur_apptype_get : cur_apptype_get = 1

Sub Main

	If GetBinarybit(DEF_Sideparameter,10) = 0 Then
		Response.Write "Error code:0x0000ff."
		Exit Sub
	End If
	If apiKey = "" or secretKey = "" Then
		'Response.Write "Error code:0x0000fe."
		'Exit Sub
	End If
	If apiKey = "" or secretKey = "" Then
		'Response.Write "Error code:0x0000fe."
		'Exit Sub
	End If
	
	dim qc,ldqq,cur_apptype
	return_QueryString = request.querystring
	dim u,tmpQ
	u = urlencode(request.querystring("u"))
	tmpQ = return_QueryString
	if u <> "" then tmpQ = replace(replace(return_QueryString,u,""),"u=","")
	If Request("code") <> "" or len(tmpQ) > 10 or request.querystring("state") <> "" Then
		SET qc = New QqConnet
		set ldqq = new leadbbs_forQQ
		If Session("Access_Token") = "" Then
			dim CheckLogin
			CheckLogin=qc.CheckLogin()
			If CheckLogin=False Then
				Response.Write("登录失败1！")
				Response.End()
			Else
				Session("Access_Token")=qc.GetAccess_Token()
			End If
		End If
		dim UserInfo
		Session("Openid") = qc.Getopenid()
		UserInfo = qc.GetUserInfo()
		dim nickname,sex,icon,expires,getInfo
		getInfo = qc.GetUserName(UserInfo)
		nickname = LeftTrue(getInfo(0),14)
		sex = getInfo(1)
		icon = leftTrue(getInfo(2),250)
		expires = getInfo(3)
		cur_apptype_get = qc.cur_apptype
		if icon = "" and cur_apptype_get = 1 then icon = "http://qzapp.qlogo.cn/qzapp/"&qc.APP_ID&"/"&Session("Openid")&"/30"
		Set qc = Nothing

		'Response.Cookies(DEF_MasterCookies & "_AppInfo")="1," & Session("Access_Token") & "," & Session("Openid")
		'	Response.Cookies(DEF_MasterCookies&"_AppInfo").Expires = DateAdd("d",365,DEF_Now)
		'	Response.Cookies(DEF_MasterCookies&"_AppInfo").Domain = DEF_AbsolutHome
		Set qc = Nothing
		Dim UserID
		initdatabase()
		UserID = ldqq.App_CheckAppid(cur_apptype_get,Session("Openid"),Session("Access_Token"),expires)

		If UserID > 0 Then
			ldqq.App_Login(UserID)
		Else
			if ldqq.App_BindExist(nickname,icon,expires,sex) = 0 then
				'Response.Cookies(DEF_MasterCookies)("User") = CodeCookie(LeftTrue("QQ_" & nickname,20))
				'Response.Cookies(DEF_MasterCookies).Expires = DateAdd("d",365,DEF_Now)
				'Response.Cookies(DEF_MasterCookies).Domain = DEF_AbsolutHome
				'Response.Cookies(DEF_MasterCookies&"_apptype") = cur_apptype_get
				'Response.Cookies(DEF_MasterCookies&"_apptype").Expires = DateAdd("d",365,DEF_Now)
				'Response.Cookies(DEF_MasterCookies&"_apptype").Domain = DEF_AbsolutHome
			end if
		End If
		CloseDatabase()
		If request.queryString("u") <> "" then
			Response.Redirect "http://" & callback & replace(replace(filterUrlstr(left(request.queryString("u"),50)),"%2E","/"),"%2e","/")
		else
			Response.Redirect DEF_InstallDir & RW_boards(0)
		end if
	Else
		Dim url
		Session("Code") = ""
		Session("Openid") = ""
		Session("Access_Token") = ""
		SET qc = New QqConnet
		Session("State") = qc.MakeRandNum()
		url = qc.GetAuthorization_Code()
		Set qc = Nothing
		Response.Redirect(url)
	End If

End Sub

Class leadbbs_forQQ

	Private Token,ExpiresTime,Retention1,OpenID

	Private Sub Class_Initialize

		Token = ""
		ExpiresTime = 0
		Retention1 = ""
		OpenID = ""

	End Sub

	Public Function App_CheckAppid(AppType,appid,myToken,expires)

		Dim Rs
		Set Rs = LDExeCute(sql_select("Select UserID,Token,ExpiresTime,Retention1 from LeadBBS_AppLogin where appType=" & Replace(appType,"'","''") & " and appid='" & Replace(appid,"'","''") & "'",1),0)
		If Rs.Eof Then
			App_CheckAppid = 0
			OpenID = Session("Openid")
			Token = Session("Access_Token")
		Else
			App_CheckAppid = cCur(Rs(0))
			Token = Rs(1)
			ExpiresTime = Rs(2)
			Retention1 = Rs(3)
			OpenID = appid
			if Token <> myToken or (getTimeValue(expires) > 0 and getTimeValue(expires) <> ccur(ExpiresTime)) then
				call LDExeCute("Update LeadBBS_AppLogin set ExpiresTime=" & GetTimeValue(expires) & ",Token='" & Replace(myToken,"'","''") & "' where appType=" & Replace(appType,"'","''") & " and appid='" & Replace(appid,"'","''") & "'",1)
				Token = myToken
			end if
		End if
		Rs.Close
		Set Rs = Nothing

	End Function

	Public Sub App_Login(UID)

		Dim Rs
		Set Rs = LDExeCute(sql_select("Select ID,UserName,Pass from LeadBBS_User where ID=" & UID,1),0)
		If Rs.Eof Then
			Rs.Close
			Set Rs = Nothing
			Exit Sub
		End If
		GBL_CHK_User = Rs(1)
		GBL_CHK_Pass = Rs(2)
		dontRequestFormFlag = "AppLogin"
		GBL_CheckPassDoneFlag = 0
		GBL_CHK_Flag = 1
		Call checkPass()

	End Sub
	
	Public function App_BindExist(nickname,icon,expires,sexx)

		dim sex
		if sexx = "男" then
			sex = "男"
		elseif sexx = "女" then
			sex = "女"
		else
			sex = "密"
		end if
		If GBL_UserID > 0 Then
			App_BindExist = 1
			CALL LDExeCute("insert into LeadBBS_AppLogin(UserID,appid,GuestName,appType,ndatetime,IPAddress,Token,ExpiresTime) values(" & GBL_UserID & ",'" & Replace(OpenID,"'","''") & "','" & Replace(nickname,"'","''") & "'," & cur_apptype_get & "," & GetTimeValue(DEF_Now) & ",'" & Replace(GBL_IPAddress,"'","''") & "','" & Replace(Token,"'","''") & "'," & GetTimeValue(expires) & ")",1)
		Else
			dim sql,userName,N,ExistFlag
			ExistFlag = 1
			App_BindExist = 0
			For N = 0 to 1000
				Randomize
				select case cur_apptype_get
					case 1:
						userName = "QQ#"
					case else
						userName = "LD#"
				end select
				userName = userName & Mid(LngStr(GetTimeValue(DEF_Now)),3,6) & (Fix(Rnd*99999)+1)
				If CheckUserNameExist(userName) = 0 then
					ExistFlag = 0
					exit for
				End If
			Next
			
			If ExistFlag = 0 Then
				Dim width
				width = 100
				If right(icon,3) = "/30" then
					icon = mid(icon,1,len(icon)-3) & "/100"
					width = 100
				end if
				Randomize
				sql = "insert into leadbbs_User(UserName,Mail,Address,Sex,ICQ,OICQ,Userphoto,Homepage,Underwrite," &_
					"PrintUnderwrite,Pass,birthday,NongLiBirth,ApplyTime,IP,UserLevel,Officer,Points,Sessionid,Online," &_
					"Prevtime,Answer,Question,LastDoingTime,LastWriteTime,UserLimit,FaceUrl,FaceWidth,FaceHeight,LastAnnounceID,TrueName) values(" &_
					"'" & userName & "','','" & Replace(GBL_IPAddress,"'","''") & "','" & replace(left(sex,1),"'","''") & "',0,0,0,'',''," &_
					"'','" & md5(rnd*99999999999+Timer) & "',0,0," & GetTimeValue(DEF_Now) & ",'',0,'',0,0,0," &_
					"" & GetTimeValue(DEF_Now) & ",'',''," & GetTimeValue(DEF_Now) & "," & GetTimeValue(DEF_Now) & ",0,'" & Replace(icon,"'","''") & "'," & width & "," & width & ",0" &_
					",'" & Replace(check_nameFilter(nickname),"'","''") & "'" &_
					")"
				CALL LDExeCute(sql,1)
				Dim uid
				uid = GetUserID(userName)
				if uid > 0 then
					CALL LDExeCute("insert into LeadBBS_AppLogin(UserID,appid,GuestName,appType,ndatetime,IPAddress,Token,ExpiresTime) values(" & uid & ",'" & Replace(OpenID,"'","''") & "','" & Replace(nickname,"'","''") & "'," & cur_apptype_get & "," & GetTimeValue(DEF_Now) & ",'" & Replace(GBL_IPAddress,"'","''") & "','" & Replace(Token,"'","''") & "'," & GetTimeValue(expires) & ")",1)
				end if
				App_BindExist = 1
				
				CALL LDExeCute("Update LeadBBS_SiteInfo Set UserCount=UserCount+1",1)
				Call UpdateStatisticDataInfo(1,1,1)
				Call UpdateStatisticDataInfo(userName,12,0)
				
				dim UserID
				UserID = App_CheckAppid(cur_apptype_get,Session("Openid"),Session("Access_Token"),expires)

				If UserID > 0 Then
					App_Login(UserID)
				end if
			End If
		End If
	
	End function
	
	Private function check_nameFilter(str)
	
		dim name
		name = trim(str)
		dim filter : filter = "~~@#$%^&*()+`=-[]{};':"",./<>??"
		dim n
		for n = 0 to 31
			name = replace(name,chr(n),"")
		next
		for n = 127 to 255
			name = replace(name,chr(n),"")
		next
		
		for n = 1 to len(filter)
			name = replace(name,mid(filter,n,1),"")
		next
		name = leftTrue(name,14)
		check_nameFilter = name
	
	end function
	
	Private Function CheckUserNameExist(n)

		Dim Rs
		Set Rs = LDExeCute(sql_select("Select ID from LeadBBS_User where UserName='" & Replace(n,"'","''") & "'",1),0)
		If Rs.Eof Then
			CheckUserNameExist = 0
		Else
			CheckUserNameExist = 1
		End if
		Rs.Close
		Set Rs = Nothing

	End Function
	
	Private Function GetUserID(UserName)

		Dim Rs
		Set Rs = LDExeCute(sql_select("Select ID from LeadBBS_User where UserName='" & Replace(UserName,"'","''") & "'",1),0)
		If Rs.Eof Then
			GetUserID = 0
		Else
			GetUserID = ccur(Rs(0))
		End if
		Rs.Close
		Set Rs = Nothing

	End Function

End Class

Main()
%>