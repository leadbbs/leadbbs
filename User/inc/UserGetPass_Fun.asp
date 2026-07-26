<%
const DEF_SendDelay = 3600 '发送邮件或短信间隔时间(秒)

Class User_GetPass

	Private SendEmail,SendPass,Question,Answer,SendAnswer,SendUser,SendQuestion,SendPassword1,SendPassword2
	private moreact

	Public Sub GetPass
	
		dim act
		act = request("act")
		moreact = left(request("moreact"),10)
		select case act
			case "reset":
				dim UserUserReset
				set UserUserReset = new User_UserReset
				UserUserReset.DisplayReset
				set UserUserReset = nothing
			case "send":
				viewSendForm("")
			case else
				VierGetPassForm
		end select

	End Sub

	private sub sendCodeInfo(nstr,ty)
	
		dim column
		if ty = 2 then 
			column = "T1.mobileTel"
		else
			column = "T1.Mail"
		end if
		
		dim rs,sql,userid,remark
		SQL = sql_select("Select t1.id,t1.username,t1.sessionid,t1.userlimit,t1.mail,t1.mobiletel,t1.remark from LeadBBS_User as t1 where " & column & "='" & replace(nstr,"'","''") & "'",1)
		set rs = ldexecute(sql,0)
		if rs.eof then
			viewsendform("此邮件或手机号码从未注册过.")
			rs.close
			set rs = nothing
			exit sub
		end if
		GBL_CHK_UserLimit = ccur(rs(3))
		gbl_userid = ccur(rs(0))
		userid = gbl_userid
		gbl_chk_user = rs(1)
		dim Mail,MobileTel
		Mail = rs(4)
		MobileTel = rs(5)
		remark = rs(6)
		rs.close
		set rs = nothing
		
		CheckisBoardMaster
		
		'GBL_BoardMasterFlag >= 4 or 
		if CheckSupervisorNameOnly = 1 then
			viewsendform("此注册用户已被设置为禁用此功能，请联系管理员.")
			gbl_userid = 0
			exit sub
		end if
		gbl_userid = 0

		dim tmp
		tmp = markReplace(remark,1,DEF_Now)

		'发送激活码
		dim activeCode,ResetCode
		activeCode = ""
		ResetCode = ""
		dim sessionLimit
		sessionLimit = tmp(1)
		if sessionLimit <> "" then
			sessionLimit = restoretime(gettimevalue(sessionLimit))
			if datediff("s",sessionLimit,DEF_Now) < DEF_SendDelay then
				viewsendform("上次发送时隔不久，请" & fix((DEF_SendDelay-datediff("s",sessionLimit,DEF_Now))/60) & "分钟后再尝试.")
				exit sub
			end if
		end if
		
		Randomize
		'重置密码验证码14位数字
		ResetCode = Fix(Rnd*99999999)+1
		do while ResetCode < 1000000
			ResetCode = Fix(Rnd*99999999)+1
		loop
		ResetCode = ccur(right(ResetCode & "",6))
		if ResetCode < 100000 then ResetCode = ResetCode + 100000
		
		dim gettype
		gettype = request.querystring("gettype")
		if gettype = "" then gettype = request.form("gettype")
		if gettype <> "1" then
			gettype = 0
		else
			gettype = 1
		end if

		dim ActiveSendFlag : ActiveSendFlag = 0
		If GetBinarybit(GBL_CHK_UserLimit,1) = 1 Then
					SQL = "Select BoardID,ndatetime from LeadBBS_SpecialUser where UserID=" & userid
					Set Rs = LDExeCute(SQL,0)
					If Rs.Eof Then
						Rs.Close
						Set Rs = Nothing
						'Response.Write "<div class=alert>此用户无法由用户进行激活，停止发送邮件，请联系管理员.</div>" & VbCrLf
						'Exit Sub
					else
						dim ndatetime
						activeCode = cCur(Rs(0))
						ndatetime = restoretime(rs(1))
						Rs.Close
						Set Rs = Nothing
						ActiveSendFlag = 1
						'DEF_SendDelay秒才允许一次找回
						if datediff("s",ndatetime,DEF_Now) < DEF_SendDelay then
							'Response.Write "<div class=alert>上次发送时隔不久，请" & fix((DEF_SendDelay-datediff("s",ndatetime,DEF_Now))/60) & "分钟后再尝试.</div>" & VbCrLf
							'Exit Sub
						else
							'SendGetPassMail gbl_chk_user,Mail,"",activeCode,ResetCode
							'call ldexecute("update LeadBBS_SpecialUser set ndatetime=" & Gettimevalue(DEF_Now) & " where userid=" & userid,1)
							'Response.Write "<div class='alert greenfont'>新的密码及激活码已经发送到您的注册邮箱。</div>" & VbCrLf
						end if
					End If
		else
			if gettype = 1 then
				viewsendform("此用户已激活，无需再次激活.")
				exit sub
			end if
		End If
		
		if ActiveSendFlag = 0 then activeCode = ""
		
		dim objectName,send_return
		if ty = 2 then
			if gettype = 0 then
				activeCode = 0
			else
				resetcode = 0
			end if
			send_return = SendtoMobile(MobileTel,gbl_chk_user,activeCode,resetcode)
			objectName = "手机"
		else
			send_return = SendGetPassMail(gbl_chk_user,Mail,"",activeCode,ResetCode)
			objectName = "邮箱"
		end if
		if send_return > 0 then
			Response.Write "<p><b><a href=UserGetPass.asp?act=active class=greenfont>相关信息已发送至您的" & objectName & "，点此激活或重置密码．</a></b></p>"
	
			if tmp(0) = "none" then tmp(0) = remark
			dim tmp2
			tmp2 = markReplace(tmp(0),2,0)
			if tmp2(0) <> "none" then
				sql = "update leadbbs_user set remark='" & replace(tmp2(0),"'","''") & "' where id=" & userid
				call ldexecute(sql,1)
			end if
	
			if resetcode > 0 then
				sql = "update leadbbs_user set sessionid=" & resetcode & " where id=" & userid
				call ldexecute(sql,1)
			end if
		end if

	End sub
	
	private function SendtoMobile(Form_MobileTel,Form_UserName,AttestNumber,resetcode)

		dim tel,smsbody
		tel = Form_MobileTel
		smsbody = "尊敬的用户" & Form_UserName & "，"
		if AttestNumber <> "" then
			smsbody = smsbody &"您的激活码为" & AttestNumber & "，"
		end if
		if resetcode <> "" then
			smsbody = smsbody &"重置密码辨识码为" & resetcode & "，"
		end if
		if DEF_UserActivationExpiresDay > 0 and DEF_UserActivationExpiresDay < 3650 then
			smsbody = smsbody & DEF_UserActivationExpiresDay & "天内有效，"
		end if
		smsbody = smsbody & "感谢您的使用！"
		
		dim errid
		errid = SendSMS_Message(tel,smsbody,AttestNumber,resetcode)
		if errid < 0 then
			Response.Write "<p>短信发送失败，错误号：" & errid & "</p>"
		else
			'Response.Write "<p><b><a href=UserGetPass.asp?act=active class=greenfont>相关信息已发送至您的手机，点此激活或重置密码．</a></b></p>"
		end if
		SendtoMobile = errid
	
	end function
	
	private sub viewsendform(t)
	
		if moreact = "bind" then
			viewsendform_bind(t)
			exit sub
		end if

		if DEF_User_GetPassMode < 3 then
		%>
		<div class=redfont><b>系统设置不支持手机或邮箱找回!</b></div>
		<%
			exit sub
		end if
		dim SendInfo
		SendInfo = left(trim(request("SendInfo")),100)
		
		dim gettype
		gettype = request.querystring("gettype")
		if gettype = "" then gettype = request.form("gettype")
		if gettype <> "1" then gettype = "0"
		
		dim getinfo
		If SendInfo = "" or t <> "" Then%>
		<div class=redfont><b><%=t%></b></div>
	<div class=title>
	<%if gettype = "1" then
		Response.write "重新发送激活码，"
	else
		response.write "忘记了密码?　"
	end if%>请输入您的<%
		select case DEF_User_GetPassMode
			case 3:
				getinfo = "注册邮箱"
			case 4:
				getinfo = "注册邮箱或手机号码"
		end select%><%=getinfo%></div>
	<form action=<%=DEF_BBS_HomeUrl%>User/UserGetPass.asp method="post" onSubmit="submit_disable(this);">
		<%=getinfo%>: <input name=SendInfo type=text maxlength=50 size=22 value="<%
			Response.Write htmlencode(SendInfo)
		%>" class=fminpt><br><br>
		<input type=hidden value="send" name=act>
		<input type=hidden value="<%=htmlencode(request("gettype"))%>" name=gettype>
		<input type=submit value="提交" class="fmbtn btn_3">
	</form>
	<br>
	<div class=value2>注意： 部分特殊用户可能不支持找回密码
	</div>
		<%
		Else
			select case DEF_User_GetPassMode
				case 3: '仅邮箱找回
					if inStr(SendInfo,"@") < 1 then
						viewsendform("错误的邮件地址!")
						exit sub
					end if
					call sendCodeInfo(SendInfo,1)
				case 4: '手机或邮箱找回
					if inStr(SendInfo,"@") < 1 then
						SendInfo = fix(ccur(toNum(SendInfo,0)))
						if SendInfo < 10000000000 then
							viewsendform("错误的邮件地址或手机号码!")
							exit sub
						end if
						call sendCodeInfo(SendInfo,2)
					else
						call sendCodeInfo(SendInfo,1)
					end if
			end select
		end if
		
	end sub
	
	
	private sub viewsendform_bind(t)
	
		if DEF_User_GetPassMode < 3 then
		%>
		<div class=redfont><b>本站未开启手机或邮箱功能!</b></div>
		<%
			exit sub
		end if
		dim SendInfo
		SendInfo = leftTrue(trim(request("SendInfo")),60)
		
		dim gettype
		gettype = request.querystring("gettype")
		if gettype = "" then gettype = request.form("gettype")
		if gettype <> "bind" then gettype = "unbind"

		dim verifycode	
		verifycode = request.querystring("verifycode")
		if verifycode = "" then verifycode = request.form("verifycode")
		if verifycode <> "yes" then verifycode = ""

		dim specialcode
		specialcode = request.querystring("specialcode")
		if specialcode = "" then specialcode = request.form("specialcode")
		specialcode = left(specialcode,6)
		
		dim ttt,user_mail,user_mobileTel
		ttt = get_bind_mobileandMail(gbl_userid)
		user_mail = ttt(1)
		user_mobileTel = ttt(2)
		
		if gettype = "bind" then
			if ttt(0) = 0 then
				%>
				<div class=redfont><b>此操作须先登录帐号．</b></div>
				<%
				exit sub
			end if
		end if
		
		dim unbindtype
		unbindtype = request.querystring("unbindtype")
		if unbindtype = "" then unbindtype = request.form("unbindtype")
		if unbindtype <> "1" and unbindtype <> "2" then unbindtype = "0"

		dim getinfo
		dim submitflag
		submitflag = request.querystring("submitflag")
		if submitflag = "" then submitflag = request.form("submitflag")
		If (SendInfo = "" or t <> "") or submitflag = "" Then%>
		<div class=redfont><b><%=t%></b></div>
	<div class=title>
	请输入<%
		if gettype = "bind" then
			Response.write "待绑定的"
		else
			gettype = "unbind"
			response.write "待取消绑定的"
		end if
		select case DEF_User_GetPassMode
			case 3:
				getinfo = "邮箱"
			case 4:
				getinfo = "邮箱或手机号码"
		end select%><%=getinfo%></div>
	<form action=<%=DEF_BBS_HomeUrl%>User/UserGetPass.asp method="post" onSubmit="submit_disable(this);">
		<%=getinfo%>： <input name=SendInfo type=text maxlength=50 size=22 value="<%
			Response.Write htmlencode(SendInfo)
		%>" class=fminpt><br><br><%
		if verifycode = "yes" then
			%>
			认证码： <input name=specialcode type=text maxlength=50 size=22 value="<%=htmlencode(specialcode)%>" class=fminpt><br><br>
			<%
		end if%>
		<input type=hidden value="send" name=act>
		<input type=hidden value="yes" name=submitflag>
		<input type=hidden value="<%=htmlencode(verifycode)%>" name="verifycode">
		<input type=hidden value="<%=htmlencode(moreact)%>" name=moreact>
		<input type=hidden value="<%=htmlencode(request("gettype"))%>" name=gettype>
		<%if gettype = "unbind" and verifycode <> "yes" then
			%>
			
			<label>
			<input class=fmchkbox type=radio name=unbindtype value=0 <%If unbindtype = "0" Then Response.Write " checked"%>>解除当前输入的邮箱或手机
			</label>
			<label>
			<input class=fmchkbox type=radio name=unbindtype value=1 <%If unbindtype = "1" Then Response.Write " checked"%>>解除关联帐户的手机
			</label>
			
			<label>
			<input class=fmchkbox type=radio name=unbindtype value=2 <%If unbindtype = "2" Then Response.Write " checked"%>>解除关联帐户的邮箱
			</label>
			<br /><br />
			<%
		end if%>
		<input type=submit value="提交" class="fmbtn btn_3">
	</form>
	<br>
	<div class=value2>注意： 部分特殊用户可能不支持此功能
	</div>
		<%
		Else
			select case DEF_User_GetPassMode
				case 3: '仅邮箱
					if inStr(SendInfo,"@") < 1 then
						viewsendform_bind("错误的邮件地址!")
						exit sub
					end if
					if verifycode = "yes" then
						if toNum(specialcode,0) = 0 then
							viewsendform_bind("注意：请正确填写认证码!")
							exit sub
						else
							call SpecialCode_bin(SendInfo,1,gettype,unbindtype)
						end if
					else
						call sendCodeInfo_bind(SendInfo,1,gettype,unbindtype)
					end if
				case 4: '手机或邮箱		
					if verifycode = "yes" then
						if toNum(specialcode,0) = 0 then
							viewsendform_bind("请正确填写认证码!")
							exit sub
						else
							call SpecialCode_bin(SendInfo,gettype,unbindtype,specialcode)
						end if
					else
						if inStr(SendInfo,"@") < 1 then
							SendInfo = fix(ccur(toNum(SendInfo,0)))
							if SendInfo < 10000000000 then
								viewsendform_bind("错误的邮件地址或手机号码!")
								exit sub
							end if
							call sendCodeInfo_bind(SendInfo,2,gettype,unbindtype)
						else
							call sendCodeInfo_bind(SendInfo,1,gettype,unbindtype)
						end if
					end if
			end select
		end if
		
	end sub
	
	private function get_bind_mobileandMail(userid)
	
		if userid < 0 then '绑定必须先登录
			get_bind_mobileandMail = array(0,"","")
			exit function
		end if
		dim rs,sql
		sql = sql_select("select mail,mobiletel from leadbbs_user where id=" & userid,1)
		set rs = ldexecute(sql,0)
		if rs.eof then
			rs.close
			set rs = nothing
			get_bind_mobileandMail = array(0,"","")
			exit function
		else
			dim mail,mobiletel
			mail = rs(0)
			mobiletel = rs(1)
				
			get_bind_mobileandMail = array(1,mobiletel,mail)
			rs.close
			set rs = nothing
		end if
	
	end function

	private sub SpecialCode_bin(nstr,gettype,unbindtype,specialcode)
	
		dim rs,sql,assort,bindStr
		if gettype = "bind" then
			assort = 101
			bindStr = "绑定"
		else
			assort = 100
			bindStr = "解除绑定"
		end if
		
		dim UserID,UserName,errNum,ndatetime,didTime,re_code,SpecialID
		sql = sql_select("select id,UserID,UserName,BoardID,Assort,ndatetime,ExpiresTime,WhyString from leadbbs_specialuser where username='" & replace(nstr,"'","''") & "' and assort=" & assort,1)
		set rs = ldexecute(sql,0)
		if rs.eof then
				viewsendform_bind("此认证信息已完成或失效.")
				rs.close
				set rs = nothing
				exit sub
		end if
		SpecialID = rs("id")
		UserID = rs("UserID")
		UserName = rs("UserName")
		errNum = ccur(rs("boardid"))
		ndatetime = rs("ndatetime")
		didTime = restoretime(rs("ExpiresTime"))
		re_code = rs("WhyString")
		rs.close
		set rs = nothing
		
		if errNum > 30 then
			if datediff("s",didTime,DEF_Now) < DEF_SendDelay then
				Response.Write "<div class=alert>错误次数过多，请" & fix((DEF_SendDelay-datediff("s",didTime,DEF_Now))/60) & "分钟后再尝试.</div>" & VbCrLf
				Exit Sub
			else
				errNum = 0
				sql = "update leadbbs_specialuser set boardid=0 where id=" & SpecialID
				call ldexecute(sql,1)
			end if
		else
			errNum = errNum + 1
			sql = "update leadbbs_specialuser set boardid=" & errNum & ",ExpiresTime=" & getTimevalue(DEF_Now) & " where id=" & SpecialID
			call ldexecute(sql,1)
		end if
		
		dim NameType,whereNameType
		if inStr(nstr,"@") then
			NameType = "mail"
			whereNameType = "mail"
		else
			NameType = "mobiletel"
			whereNameType = "mobiletel"
		end if
		dim columnName
		if assort = 100 then '解绑，获取认证码
			dim tmp,t,code
			if inStr(re_code,"|") then
				tmp = split(re_code,"|")
				re_code = tmp(0)
				t = tmp(1)
				select case t
					case "1": 
						NameType = "mobiletel"
					case "2":
						NameType = "mail"
				end select
			end if
		end if
		
		if re_code <> specialcode then
				viewsendform_bind("认证码错误，你还有" & (31-errNum) & "次重试机会.")
				exit sub
		end if

		dim NameTypeStr
		dim cur_nstr : cur_nstr = nstr
		if assort = 100 and whereNameType = "mobiletel" then
			cur_nstr = toNum(cur_nstr,0)
			if cur_nstr = 0 then
				viewsendform_bind("手机号码错误，你还有" & (31-errNum) & "次重试机会.")
				exit sub
			end if
		end if
		if assort = 100 then 'unbind
			sql = "update leadbbs_user set " & getColumnString_bind(NameType,"") & " where " & getColumnString_bind(whereNameType,cur_nstr)
			call ldexecute(sql,1)
		else 'bind
			sql = "update leadbbs_user set " & getColumnString_bind(NameType,cur_nstr) & " where id=" & userid
			call ldexecute(sql,1)
		end if
		sql = "delete from leadbbs_specialUser where ID=" & SpecialID
		call ldexecute(sql,1)
		if assort = 100 then 'unbind
			Response.Write "<div class=bbs_ok>" & bindStr & " " & cur_nstr & "的相关绑定成功!</div>" & VbCrLf
		else
			Response.Write "<div class=bbs_ok>" & bindStr & " " & cur_nstr & "成功!</div>" & VbCrLf
		end if
	
	end sub
	
	private function getColumnString_bind(col,val)
	
		dim v : v = val
		v = toNum(v,0)
		if col = "mobiletel" then
			getColumnString_bind = " mobiletel=" & v
		else
			getColumnString_bind = " mail='" & replace(val,"'","''") & "'"
		end if
	
	end function
	
	private sub sendCodeInfo_bind(nstr,ty,gettype,unbindtype)
	
		dim rs,sql,userid,remark

		dim column
		if ty = 2 then
			column = "T1.mobileTel"
		else
			column = "T1.Mail"
		end if
		userid = 0
		SQL = sql_select("Select t1.id,t1.username,t1.sessionid,t1.userlimit,t1.mail,t1.mobiletel,t1.remark from LeadBBS_User as t1 where " & column & "='" & replace(nstr,"'","''") & "'",1)
		set rs = ldexecute(sql,0)
		if rs.eof then
			if gettype = "unbind" then
				viewsendform_bind("此邮件或手机号码不存在，取消绑定操作中止.")
				rs.close
				set rs = nothing
				exit sub
			end if
		else
			if gettype = "bind" then
				viewsendform_bind("此邮件或手机号码已被绑定，不能再次绑定.")
				rs.close
				set rs = nothing
				exit sub
			end if
		end if
		dim Mail,MobileTel
		if not rs.eof then
			'绑相关帐户为管理员则不允许此操作
			GBL_CHK_UserLimit = ccur(rs(3))
			gbl_userid = ccur(rs(0))
			userid = gbl_userid
			gbl_chk_user = rs(1)
			Mail = rs(4)
			MobileTel = rs(5)
			remark = rs(6)
			rs.close
			set rs = nothing

			if gettype = "unbind" then
				if unbindtype = "1" then
					if MobileTel & "" = "" or MobileTel & "" = "0" then
						viewsendform_bind("此用户无相关的绑定手机，无需取消.")
						exit sub
					end if
				elseif unbindtype = "2" then
					if Mail & "" = "" then
						viewsendform_bind("此用户无相关的绑定邮箱，无需取消.")
						exit sub
					end if
				end if
			end if
			
			CheckisBoardMaster
			
			'GBL_BoardMasterFlag >= 4 or 
			if CheckSupervisorNameOnly = 1 then
				viewsendform_bind("此注册用户已被设置为禁用此功能，请联系管理员.")
				gbl_userid = 0
				exit sub
			end if
		else
			rs.close
			set rs = nothing
		end if

		dim assort
		if gettype = "bind" then
			assort = 101
			userid = gbl_Userid
		else
			assort = 100
		end if
		
		dim SpecialUserID
		sql = sql_select("select id,userid,UserName,BoardID,Assort,ndatetime,ExpiresTime from leadbbs_specialuser where username='" & replace(nstr,"'","''") & "' and assort=" & assort,1)
		set rs = ldexecute(sql,0)
		
		Randomize
		'重置密码验证码14位数字
		dim ResetCode
		ResetCode = Fix(Rnd*99999999)+1
		do while ResetCode < 1000000
			ResetCode = Fix(Rnd*99999999)+1
		loop
		ResetCode = ccur(right(ResetCode & "",6))
		if ResetCode < 100000 then ResetCode = ResetCode + 100000
		
		dim lastSendTime
		if not rs.eof then
			lastSendTime = restoretime(rs("ndatetime"))
			SpecialUserID = rs(0)
		else
			lastSendTime = ""
		end if
		rs.close
		set rs = nothing

		'发送激活码
		'发送验证码有时间间隔，不能无限发送
		if lastSendTime <> "" then
			if datediff("s",lastSendTime,DEF_Now) < DEF_SendDelay then
				viewsendform_bind("上次发送时隔不久，请" & fix((DEF_SendDelay-datediff("s",lastSendTime,DEF_Now))/60) & "分钟后再尝试.")
				exit sub
			end if
		end if
	
		dim objectName,send_return
		if ty = 2 then
			send_return = SendtoMobile_bind(nstr,ResetCode)
			objectName = "手机"
		else
			send_return = SendGetPassMail_bind(nstr,ResetCode)
			objectName = "邮箱"
		end if
		if send_return > 0 then
			Response.Write "<p><b><a href=UserGetPass.asp?act=send&moreact=bind&gettype=" & gettype & "&verifycode=yes&SendInfo=" & urlencode(nstr) & " class=greenfont>相关认证码信息已发送至您的" & objectName & "，点此继续操作．</a></b></p>"
		
			dim ndatetime : ndatetime = gettimevalue(DEF_Now)
			if lastSendTime = "" then
				sql = "insert into leadbbs_specialuser(userid,UserName,BoardID,Assort,ndatetime,ExpiresTime,WhyString) values("
				if gettype = "unbind" then
					sql = sql & userid & ",'" & replace(nstr,"'","''") & "',0," & assort & "," & ndatetime & "," & ndatetime & ",'" & ResetCode & "|" & unbindtype & "')"
				else
					sql = sql & userid & ",'" & replace(nstr,"'","''") & "',0," & assort & "," & ndatetime & "," & ndatetime & ",'" & ResetCode & "')"
				end if
				call ldexecute(sql,1)
			else
				if gettype = "unbind" then
					sql = "update leadbbs_specialUser set boardid=0,ndatetime=" & ndatetime & ",whystring='" & ResetCode & "|" & unbindtype & "' where id=" & SpecialUserID
				else
					sql = "update leadbbs_specialUser set boardid=0,ndatetime=" & ndatetime & ",whystring='" & ResetCode & "' where id=" & SpecialUserID
				end if
				if ccur("0" & SpecialUserID) > 0 then call ldexecute(sql,1)
			end if
		end if


	End sub
	
	private function SendtoMobile_bind(Form_MobileTel,AttestNumber)

		dim tel,smsbody
		tel = Form_MobileTel
		smsbody = "尊敬的用户，"
		if AttestNumber <> "" then
			smsbody = smsbody &"您的认证码为" & AttestNumber & "，"
		end if
		if DEF_UserActivationExpiresDay > 0 and DEF_UserActivationExpiresDay < 3650 then
			smsbody = smsbody & DEF_UserActivationExpiresDay & "天内有效，"
		end if
		smsbody = smsbody & "感谢您的使用！"
		
		dim errid
		errid = SendSMS_Message(tel,smsbody,0,AttestNumber)
		if errid < 0 then
			Response.Write "<p>短信发送失败，错误号：" & errid & "</p>"
		else
			'成功
		end if
		SendtoMobile_bind = errid
	
	end function

	Private Sub VierGetPassForm
	
		SendUser = Trim(Request.Form("SendUser"))
		If DEF_User_GetPassMode = 0 Then
			Response.Write "<div class=alert>论坛已经关闭密码找回功能。</div>" & VbCrLf
			Exit Sub
		End If
		If DEF_BBS_EmailMode = 0 and SendUser  <> "" and DEF_User_GetPassMode >= 2 Then
			Response.Write "<div class=alert>论坛禁止发送邮件，密码找回功能不能使用。</div>" & VbCrLf
			Exit Sub
		End If
		If Request.Form("act") = "getpass" Then
			SendAnswer = Left(Request.Form("SendAnswer"),20)
			SendQuestion = Left(Request.Form("SendQuestion"),20)
			SendPassword2 = Left(Request.Form("SendPassword2"),14)
			SendPassword1 = Left(Request.Form("SendPassword1"),14)
	
			If Len(SendUser) > 30 Then
				Response.Write "<div class=alert>错误: 用户名太长.</div>" & VbCrLf
				Exit Sub
			End If

			Dim Rs,SQL,Remark,userid
			SQL = "Select mail,Pass,Question,Answer,UserLimit,Remark,id from LeadBBS_User where UserName='" & Replace(SendUser,"'","''") & "'"
			Set Rs = LDExeCute(SQL,0)
			If Rs.Eof Then
				Rs.Close
				Set Rs = Nothing
				Response.Write "<div class=alert>错误: 不存在的用户名.</div>" & VbCrLf
				Exit Sub
			End If
	
			SendEmail = Rs(0)
			SendPass = Rs(1)
			Question = Rs(2)
			Answer = Rs(3)
			GBL_CHK_UserLimit = Rs(4)
			Remark = rs(5)
			userid = ccur(rs(6))
			Rs.Close
			Set Rs = Nothing
			'If SendEmail = "" or isNull(SendEmail) Then
			'	Response.Write "<div class=alert>错误: 此用户注册时未提供Email，无法找回密码.</div>" & VbCrLf
			'	Exit Sub
			'End If
	
			SQL = GBL_CHK_User
			GBL_CHK_User = SendUser
			CheckisBoardMaster
			If Len(Answer) < 32 or GBL_BoardMasterFlag >= 4 or (GBL_CHK_User <> "" and inStr(GBL_CHK_User,",") = 0 and inStr(LCase(DEF_SupervisorUserName),"," & LCase(GBL_CHK_User) & ",") > 0) Then
				Response.Write "<div class=alert>错误: 此用户未申请密码保护，无法使用找回密码恢复功能。<br>请联系管理员设定密码保护。</div>" & VbCrLf
				Exit Sub
			End If
			GBL_CHK_User = SQL
			
			'加入猜测频率检测，防止无穷破解
			dim tmp,newTmp,saveInfo,spTmp
			tmp = markReplace(remark,3,"test")
			saveInfo = tmp(1)
			dim didTime,errNum
			Dim remainNum : remainNum = 31
			if inStr(saveInfo,"|") = 0 then
				didTime = GetTimeValue(DEF_Now)
				errNum = 0
				tmp = markReplace(remark,3,didTime & "|" & errNum)
				saveInfo = tmp(0)
				if saveInfo <> "none" then
					sql = "update leadbbs_user set remark='" & replace(saveInfo,"'","''") & "' where id=" & userid
					call ldexecute(sql,1)
				end if
			else
				spTmp = split(saveInfo,"|")
				didTime = restoreTime(spTmp(0))
				errNum = toNum(spTmp(1),0)
				if errNum > 30 then
					if datediff("s",didTime,DEF_Now) < DEF_SendDelay then
						Response.Write "<div class=alert>错误次数过多，请" & fix((DEF_SendDelay-datediff("s",didTime,DEF_Now))/60) & "分钟后再尝试.</div>" & VbCrLf
						Exit Sub
					else
						errNum = 0
						tmp = markReplace(remark,3,gettimevalue(DEF_Now) & "|" & errNum)
						saveInfo = tmp(0)
						if saveInfo <> "none" then
							sql = "update leadbbs_user set remark='" & replace(saveInfo,"'","''") & "' where id=" & userid
							call ldexecute(sql,1)
						end if
					end if
				else
					errNum = errNum + 1
					remainNum = remainNum - errNum
					tmp = markReplace(remark,3,gettimevalue(DEF_Now) & "|" & errNum)
					saveInfo = tmp(0)
					if saveInfo <> "none" then
						sql = "update leadbbs_user set remark='" & replace(saveInfo,"'","''") & "' where id=" & userid
						call ldexecute(sql,1)
					end if
				end if
			end if
	
			If SendAnswer = "" and SendQuestion = "" and SendPassword1 = "" and SendPassword2 = "" Then
				DisplaySubmitForm
			Else
				Dim NumCheck
				NumCheck = CheckRndNumber	
				Randomize
				Session(DEF_MasterCookies & "RndNum") = Fix(Rnd*9999)+1
				If NumCheck = 0 Then
					Response.Write "<div class=alert>验证码填写错误，您还有" & remainNum & "次尝试机会!</div>" & VbCrLf
					DisplaySubmitForm
					Exit Sub
				End If
	
				If Len(SendPassword2) < DEF_UserShortestPassword or Len(SendPassword1) < DEF_UserShortestPassword or SendPassword1 <> SendPassword2 Then
					Response.Write "<div class=alert>新的密码不能少于4位，并且新密码与验证密码必须相同。</div>" & VbCrLf
					SendQuestion = ""
					DisplaySubmitForm
					Exit Sub
				End If
			
				If MD5(SendAnswer) <> Answer and Mid(MD5(SendAnswer),9,16) <> Answer Then
					Response.Write "<div class=alert>密码的提示答案填写错误，您还有" & remainNum & "次尝试机会，或请联系管理员!</div>" & VbCrLf
					SendQuestion = ""
					DisplaySubmitForm
					CALL LDExeCute("Update LeadBBS_OnlineUser Set LastDoingTime=" & GetTimeValue(DEF_Now) & " where SessionID=" & Session.SessionID,1)
					UpdateSessionValue 18,GetTimeValue(DEF_Now),0
					Exit Sub
				End If
				
				Dim NewSendPass
				SendPass = MD5(SendPassword2)
				CALL LDExeCute("Update LeadBBS_User Set Pass='" & Replace(SendPass,"'","''") & "' where UserName='" & Replace(SendUser,"'","''") & "'",1)
				If Lcase(GBL_CHK_User) = Lcase(SendUser) Then UpdateSessionValue 7,SendPass,0
				Response.Write "<div class=alert>密码已经成功更改，请使用新的密码<a href=""Login.asp?R=Yes"">登录</a>您的账号!</div>" & VbCrLf
				If SendEmail <> "" and DEF_User_GetPassMode >= 2 and GetBinarybit(GBL_CHK_UserLimit,1) = 1 Then
					SQL = "Select BoardID,ndatetime from LeadBBS_SpecialUser where UserID=" & GBL_UserID
					Set Rs = LDExeCute(SQL,0)
					If Rs.Eof Then
						Rs.Close
						Set Rs = Nothing
						Response.Write "<div class=alert>此用户无法由用户进行激活，停止发送邮件，请联系管理员.</div>" & VbCrLf
						Exit Sub
					End If
					dim ndatetime
					SQL = cCur(Rs(0))
					ndatetime = restoretime(rs(1))
					Rs.Close
					Set Rs = Nothing
					'DEF_SendDelay秒才允许一次找回
					if datediff("s",ndatetime,DEF_Now) < DEF_SendDelay then
						Response.Write "<div class=alert>上次发送时隔不久，请" & fix((DEF_SendDelay-datediff("s",ndatetime,DEF_Now))/60) & "分钟后再尝试.</div>" & VbCrLf
						Exit Sub
					else
						SendGetPassMail SendUser,SendEmail,SendPassword2,SQL,""
						call ldexecute("update LeadBBS_SpecialUser set ndatetime=" & Gettimevalue(DEF_Now) & " where userid=" & GBL_UserID,1)
						Response.Write "<div class='alert greenfont'>同时，新的密码及激活码已经发送到您的注册邮箱。</div>" & VbCrLf
					end if
				End If
				CALL LDExeCute("Update LeadBBS_OnlineUser Set LastDoingTime=" & GetTimeValue(DEF_Now) & " where SessionID=" & Session.SessionID,1)
				UpdateSessionValue 18,GetTimeValue(DEF_Now),0
			End If
		Else
			DisplaySubmitForm
		End If
	
	End Sub
	
	Private Sub DisplaySubmitForm
	
		If Question = "" Then Question = SendQuestion
		If SendAnswer = "" and SendUser = "" and SendQuestion = "" Then%>
	<div class=title>使用密保找回密码，请先输入您要找回的用户名。</div>
	<form action=<%=DEF_BBS_HomeUrl%>User/UserGetPass.asp method="post" onSubmit="submit_disable(this);">
		用户名: <input name=SendUser type=text maxlength=20 size=22 value="<%
		If GBL_CHK_user = "" or isNull(GBL_CHK_user) Then
			Response.Write htmlencode(Request("user"))
		Else
			Response.Write htmlencode(GBL_CHK_user)
		End If%>" class=fminpt><br>
		<input type=hidden value="getpass" name=act><br>
		<input type=submit value="取回密码" class="fmbtn btn_3">
	</form>
	<br>
	<div class=value2>注意： 版主以上用户不支持找回密码
	</div>
		<%
		Else
			'If SendAnswer = "" and SendQuestion = "" and SendPassword1 = "" and SendPassword2 = "" Then%>
		<script language="javascript">	
		var ValidationPassed = true;
		function submitonce(theform)
		{
			if(theform.sendanswer.value=="")
			{
				alert("请输入你的提示答案!\n");
				ValidationPassed = false;
				theform.sendanswer.focus();
				return;
			}
			if(theform.sendpassword1.value=="")
			{
				alert("请输入你的密码!\n");
				ValidationPassed = false;
				theform.sendpassword1.focus();
				return;
			}
	
			if(theform.sendpassword2.value=="")
			{
				alert("请输入你的验证密码！\n");
				ValidationPassed = false;
				theform.sendpassword2.focus();
				return;
			}
	
			if(theform.sendpassword1.value!=theform.sendpassword2.value)
			{
				alert("你的两次密码输入不相同！\n");
				ValidationPassed = false;
				theform.sendpassword1.focus();
				return;
			}
			ValidationPassed = true;
			submit_disable(theform);
		}
		</script>
	<div class=title>
	请输入您的用户名及相关信息。</div>
	<form action=<%=DEF_BBS_HomeUrl%>User/UserGetPass.asp method="post" onSubmit="submitonce(this);return ValidationPassed;">
		<div class="value2">
		用户名称：<input name=SendUser type=text maxlength=20 size=22 value="<%=htmlencode(SendUser)%>" class="fminpt input_2">
		</div>
		<input type=hidden value="getpass" name=act>
		<div class="value2">
		密码提示：<input name=sendquestion value="<%=htmlencode(Question)%>" maxlength=14 size=22 readonly class="fminpt input_2">
		</div>
		<div class="value2">
		提示答案：<input name=sendanswer type=text maxlength=20 size=22 value="<%=htmlencode(SendAnswer)%>" class="fminpt input_2">
		</div>
		<div class="value2">
		新的密码：<input name=sendpassword1 type=password maxlength=14 size=22 value="<%=htmlencode(SendPassword1)%>" class="fminpt input_2">
		</div>
		<div class="value2">
		验证密码：<input name=sendpassword2 type=password maxlength=14 size=22 value="<%=htmlencode(SendPassword2)%>" class="fminpt input_2">
		</div>
		<%If DEF_EnableAttestNumber > 0 Then%>
			<div class="value2">验证码：<%
			Response.Write displayVerifycode%></div><%
		End If%>
		<br />
		<input type=submit value="取回密码" class="fmbtn btn_3">
	</form>
		<%
			'End If
		End If
	
	End Sub
	
	Private function SendGetPassMail(Form_UserName,Form_Mail,pass,ActiveCode,ResetCode)
	
		Dim HomeUrl
		HomeUrl = LD_GetUrl(1)
	
		Dim MailBody,Topic,TextBody
		Topic = "您在" & DEF_SiteNameString & "的密码找回"
		MailBody = "<html>"
		TextBody = ""
		MailBody = MailBody & "<title>账号信息</title>"
		MailBody = MailBody & "<BODY>"
		MailBody = MailBody & "<table BORDER=0 WIDTH=95% ALIGN=CENTER><TBODY><tr>"
		MailBody = MailBody & "<TD valign=MIDDLE ALIGN=TOP><HR WIDTH=100% SIZE=1>"
		TextBody = TextBody & "------------------------------------------" & VbCrLf
		MailBody = MailBody & VbCrLf & htmlencode(Form_UserName)&"，您好：<br><br>"
		TextBody = TextBody & htmlencode(Form_UserName)&"，您好：" & VbCrLf & VbCrLf
		MailBody = MailBody & "您在本论坛使用了密码找回，下面是您的账号信息！<br><br>"
		TextBody = TextBody & "您在本论坛使用了密码找回，下面是您的账号信息！" & VbCrLf & VbCrLf
		MailBody = MailBody & "用户名："&htmlencode(Form_UserName)&"<br>"
		TextBody = TextBody & "用户名："&htmlencode(Form_UserName) & VbCrLf
		if pass <> "" then
			MailBody = MailBody & "密　码：" & pass & "<br>"
			TextBody = TextBody & "密　码：" & pass & VbCrLf
		end if
		If ActiveCode <> "" Then
			MailBody = MailBody & "激活码：" & ActiveCode & "<br>"
			TextBody = TextBody & "激活码：" & ActiveCode & VbCrLf
		End If
		If ResetCode <> "" Then
			MailBody = MailBody & "重置密码验证码：" & ResetCode & "<br>"
			TextBody = TextBody & "重置密码验证码：" & ResetCode & VbCrLf
		End If
		MailBody = MailBody & "<br><br>"
		MailBody = MailBody & "<CENTER><font COLOR=RED><a href=""" & HomeUrl & """>欢迎光临论坛！</a></font>"
		MailBody = MailBody & "</td></tr></table><br><HR WIDTH=95% SIZE=1>"
		MailBody = MailBody & "<p ALIGN=CENTER>" & DEF_SiteNameString & " <a href=http://www.leadbbs.com target=_blank class=NavColor>" & DEF_Version & "</a></P>"
		TextBody = TextBody & VbCrLf & DEF_BBS_HomeUrl & VbCrLf
		TextBody = TextBody & "------------------------------------------" & VbCrLf
		MailBody = MailBody & "</body>"
		MailBody = MailBody & "</html>"
		SendGetPassMail = 0
		Select Case DEF_BBS_EmailMode
			Case 1: If SendEasyMail(Form_Mail,Topic,MailBody,TextBody) = 1 Then
						SendGetPassMail = 1
						Response.Write "<br><br>资料成功发送到您的注册邮箱！"
					Else
						Response.Write "<br><br>论坛未正确设置邮件发送，资料发送失败！"
					End If
			Case 2: If SendJmail(Form_Mail,Topic,MailBody) = 1 Then
						SendGetPassMail = 1
						Response.Write "<br><br>资料成功发送到您的注册邮箱！"
					Else
						Response.Write "<br><br>论坛未正确设置邮件发送，资料发送失败2！"
					End If
			Case 3: If SendCDOMail(Form_Mail,Topic,TextBody) = 1 Then
						SendGetPassMail = 1
						Response.Write "<br><br>资料成功发送到您的注册邮箱！"
					Else
						Response.Write "<br><br>论坛未正确设置邮件发送，资料发送失败！"
					End If
			Case Else: 
		End Select
	
	End function
	
	
	Private function SendGetPassMail_bind(Form_Mail,ActiveCode)
	
		Dim HomeUrl
		HomeUrl = LD_GetUrl(1)
	
		Dim MailBody,Topic,TextBody
		Topic = "您在" & DEF_SiteNameString & "的认证码信息"
		MailBody = "<html>"
		TextBody = ""
		MailBody = MailBody & "<title>账号信息</title>"
		MailBody = MailBody & "<BODY>"
		MailBody = MailBody & "<table BORDER=0 WIDTH=95% ALIGN=CENTER><TBODY><tr>"
		MailBody = MailBody & "<TD valign=MIDDLE ALIGN=TOP><HR WIDTH=100% SIZE=1>"
		TextBody = TextBody & "------------------------------------------" & VbCrLf
		MailBody = MailBody & "您在本论坛相关操作的认证码为：<br><br>"
		TextBody = TextBody & "您在本论坛相关操作的认证码为：" & VbCrLf & VbCrLf

		MailBody = MailBody & "认证码：" & ActiveCode & "<br>"
		TextBody = TextBody & "认证码：" & ActiveCode & VbCrLf
		MailBody = MailBody & "<br><br>"
		MailBody = MailBody & "<CENTER><font COLOR=RED><a href=""" & HomeUrl & """>欢迎光临论坛！</a></font>"
		MailBody = MailBody & "</td></tr></table><br><HR WIDTH=95% SIZE=1>"
		MailBody = MailBody & "<p ALIGN=CENTER>" & DEF_SiteNameString & " <a href=http://www.leadbbs.com target=_blank class=NavColor>" & DEF_Version & "</a></P>"
		TextBody = TextBody & VbCrLf & DEF_BBS_HomeUrl & VbCrLf
		TextBody = TextBody & "------------------------------------------" & VbCrLf
		MailBody = MailBody & "</body>"
		MailBody = MailBody & "</html>"
		SendGetPassMail_bind = 0
		Select Case DEF_BBS_EmailMode
			Case 1: If SendEasyMail(Form_Mail,Topic,MailBody,TextBody) = 1 Then
						SendGetPassMail_bind = 1
						Response.Write "<br><br>资料成功发送到您的注册邮箱！"
					Else
						Response.Write "<br><br>论坛未正确设置邮件发送，资料发送失败！"
					End If
			Case 2: If SendJmail(Form_Mail,Topic,MailBody) = 1 Then
						SendGetPassMail_bind = 1
						Response.Write "<br><br>资料成功发送到您的注册邮箱！"
					Else
						Response.Write "<br><br>论坛未正确设置邮件发送，资料发送失败2！"
					End If
			Case 3: If SendCDOMail(Form_Mail,Topic,TextBody) = 1 Then
						SendGetPassMail_bind = 1
						Response.Write "<br><br>资料成功发送到您的注册邮箱！"
					Else
						Response.Write "<br><br>论坛未正确设置邮件发送，资料发送失败！"
					End If
			Case Else: 
		End Select
	
	End function

End Class


	function markReplace(oldMark,index,value)
	
		dim olddata,splitData,headData,remainData,n
		headData = ""
		remainData = ""
		dim info
		olddata = oldMark
		info = value
		
		dim getInfo
		getInfo = ""
		
		dim ReturnStr:ReturnStr = ""
		
		dim ArrN : ArrN = 0
		if inStr(olddata,"~~~split---") then
			splitData = split(olddata,"~~~split---")
			ArrN = Ubound(splitData)
			for n = 0 to ArrN
				if n = index then
					getInfo = splitData(n)
				else
					if n < index then
						if n = 0 then
							headData = headData & splitData(n)
						else
							headData = headData & "~~~split---" & splitData(n)
						end if
					else
						remainData = remainData & "~~~split---" & splitData(n)
					end if
				end if
			next
		else
			if index > 0 then
				headData = olddata
			else
				getInfo = olddata
			end if
		end if
		
		if getInfo <> info then
			if index <= ArrN then
				if index = 0 then
					ReturnStr = Info & remainData
				else
					ReturnStr = headData & "~~~split---" & Info & remainData
				end if
			else
				ReturnStr = headData
				dim t
				t = ArrN + 1
				for n = t to index
					if n = index then
						ReturnStr = ReturnStr & "~~~split---" & info
					else
						ReturnStr = ReturnStr & "~~~split---"
					end if
				next
			end if
		else
			ReturnStr = "none"
		end if
		markReplace = array(ReturnStr,getInfo)
	
	end function

Class User_UserReset

	Private AttestNumber,username,pass1,pass2,remark

	Private Sub Class_Initialize
	
		AttestNumber = toNum(Request.Form("AttestNumber"),0)
		username = left(request.form("username"),255)
		pass1 = left(request.form("pass1"),50)
		pass2 = left(request.form("pass2"),50)
	
	End Sub

	Public Sub DisplayReset

		If Request.Form("act") = "reset" Then
			If Len(pass1) < DEF_UserShortestPassword or Len(pass1) < DEF_UserShortestPassword or pass1 <> pass2 Then
				VierForm("新的密码不能少于" & DEF_UserShortestPassword & "位，并且新密码与重复密码必须相同。")
				Exit Sub
			End If
			
			dim rs,sql,get_userid,get_sessionid,get_username,remark
			dim column
			
			if inStr(username,"@") then
				column = "T1.Mail='" & replace(username,"'","''") & "'"
			else
				if CheckMobilePhone(username) = false then
					column = "T1.username='" & replace(username,"'","''") & "'"
				else
					column = "T1.mobiletel=" & toNum(username,0)
				end if
			end if

			SQL = sql_select("Select t1.id,t1.username,t1.sessionid,t1.userlimit,t1.mail,t1.mobiletel,t1.remark from LeadBBS_User as t1 where " & column,1)
			set rs = ldexecute(sql,0)
			if rs.eof then
				VierForm("此用户名（或邮箱、手机)从未注册过.")
				rs.close
				set rs = nothing
				exit sub
			end if
			GBL_CHK_UserLimit = ccur(rs(3))
			gbl_userid = ccur(rs(0))
			get_userid = gbl_userid
			gbl_chk_user = rs(1)
			get_username = gbl_chk_user
			dim Mail,MobileTel
			Mail = rs(4)
			MobileTel = rs(5)
			remark = rs(6)
			get_sessionid = ccur("0" & rs(2))
			rs.close
			set rs = nothing
			
			CheckisBoardMaster
			
			
			
			'GBL_BoardMasterFlag >= 4 or 
			if CheckSupervisorNameOnly = 1 then
				VierForm("此用户属于管理组，无法重置密码.")
				gbl_userid = 0
				gbl_chk_user = ""
				exit sub
			end if
			gbl_userid = 0
			gbl_chk_user = ""
	
			if get_sessionid < 1000 then
				VierForm("您未获得过重置验证码，或重置验证码已无效，请重新获取.")
				exit sub
			end if
			
			dim tmp,errNum
			tmp = markReplace(remark,2,0)
			errNum = toNum(tmp(1),0)
			
			if errNum > 50 then
				VierForm("您的失败次数已超过50次，重置验证码不再有效，需要重新获取才能重置.")
				tmp = markReplace(remark,2,0)
				sql = "update leadbbs_user set sessionid=0"
				if tmp(0) <> "none" then
					sql = sql & ",remark='" & replace(tmp(0),"'","''") & "'"
				end if
				sql = sql & " where id=" & get_userid
				call ldexecute(sql,1)
				exit sub
			end if
			
			
			If get_sessionid <> AttestNumber Then
				errNum = errNum+1
				tmp = markReplace(remark,2,errNum)
				if tmp(0) <> "none" then
					sql = "update leadbbs_user set remark='" & replace(tmp(0),"'","''") & "' where id=" & get_userid
					call ldexecute(sql,1)
				end if
				VierForm("重置验证码错误，您还有" & (51-errNum) & "次尝试机会.")
				Exit Sub
			End If
	
			Dim NewPass
			NewPass = MD5(pass1)
			CALL LDExeCute("Update LeadBBS_User Set sessionid=0,Pass='" & Replace(NewPass,"'","''") & "' where id=" & get_userid,1)
			Response.Write "<div class=alert>密码已经成功更改，请使用新的密码<a href=""Login.asp?R=Yes"">登录</a>您的帐号!</div>" & VbCrLf
		Else
			VierForm("")
		End If
	
	End Sub
	
	Private Sub VierForm(str)%>

	<div class='alert redfont'><%=str%></div>
	<div class=title>请输入您要重置密码的用户名(或邮箱、手机)，重置验证码及新的密码。</div>
	<form action=<%=DEF_BBS_HomeUrl%>User/UserGetPass.asp method="post" onSubmit="submit_disable(this);">
		<div class="value2">用　 　户：　<input name=username type=text maxlength=155 size=22 value="<%=htmlencode(username)%>" class='fminpt input_2'>
		 <span class=grayfont>或者是邮箱、手机号码</span></div>
		<input name=act type=hidden value="reset">
		<div class="value2">
		重置验证码： <input name=AttestNumber type=text maxlength=30 size=22 value="<%If AttestNumber > 0 Then Response.Write AttestNumber%>" class="fminpt input_2">
		<span class=grayfont>发送至您手机或邮箱的重置验证码</span>
		</div>
		<div class="value2">新的密码：　 <input name=pass1 type=password maxlength=20 size=22 value="<%=htmlencode(pass1)%>" class='fminpt input_2'>
		</div>
		<div class="value2">重复密码：　 <input name=pass2 type=password maxlength=20 size=22 value="<%=htmlencode(pass1)%>" class='fminpt input_2'>
		<span class=grayfont>两次密码输入必须相同</span>
		</div>
		<br /><input type=submit value="提交重置" class="fmbtn btn_3">
	</form>
	<br />
	<div class=title>说明：</div>
	<ul>
	<li>若您未收到或是还没有重置验证码，<a href=usergetpass.asp?act=send>点下方的使用邮箱或手机号码找回密码</a>。</li>
	<li>某些账号只能由管理员才能重置，比如版主身份的用户。</li>
	</ul>

	<%
	
		If DEF_User_GetPassMode = 2 Then
			Response.Write "<br><a href=UserGetPass.asp><font color=red class=redfont><b>若您的邮箱未收到激活码信件，可以使用密码找回功能要求再次发送！</b></font></a>"
		End If
	
	End Sub
	
End Class%>