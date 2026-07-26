<%Class User_UserActive

	Private AttestNumber

	Private Sub Class_Initialize
	
		AttestNumber = Left(Request.Form("AttestNumber"),14)
		If isNumeric(AttestNumber) = False Then AttestNumber = 0
		AttestNumber = Fix(cCur(AttestNumber))
	
	End Sub

	Public Sub DisplayActive

		If GetBinarybit(GBL_CHK_UserLimit,1) = 0 and GBL_CHK_UserLimit <> "" and GBL_CHK_TempStr = "" and GBL_UserID > 0 Then
			Response.Write "<div class=alert>此用户已经激活，不必再进行激活操作。</div>" & VbCrLf
			Exit Sub
		End If
		If Request.Form("act") = "active" and GBL_CHK_TempStr = "" Then
			If GBL_CHK_Flag = 1 and GBL_UserID > 0 Then
				If GetBinarybit(GBL_CHK_UserLimit,1) = 0 and GBL_CHK_UserLimit <> "" Then
					Response.Write "<div class=alert>此用户已经激活，不必再进行激活操作。</div>" & VbCrLf
				Else
					Dim Rs,SQL,remark
					SQL = "Select ts.BoardID,tu.remark from LeadBBS_SpecialUser as ts left join leadbbs_user as tu on ts.userid=tu.id where ts.UserID=" & GBL_UserID
					Set Rs = LDExeCute(SQL,0)
					If Rs.Eof Then
						Rs.Close
						Set Rs = Nothing
						Response.Write "<div class=alert>此用户无法由用户进行激活，请联系管理员.</div>" & VbCrLf
						Exit Sub
					End If
					SQL = cCur(Rs(0))
					remark = rs(1) & ""
					Rs.Close
					Set Rs = Nothing
					If SQL < 1 Then
						Response.Write "<div class=alert>此用户无法由用户自行激活，请联系管理员.</div>" & VbCrLf
					Else
						If AttestNumber = SQL Then
							CALL LDExeCute("Delete from LeadBBS_SpecialUser where UserID=" & GBL_UserID,1)
							CALL LDExeCute("Update LeadBBS_User Set UserLimit=" & SetBinarybit(GBL_CHK_UserLimit,1,0) & " where ID=" & GBL_UserID,1)
							Call UpdateSessionValue(2,SetBinarybit(GBL_CHK_UserLimit,1,0),0)
							Response.Write "<div class='alert greenfont'>用户成功激活，<a href=Login.asp?User=" & urlencode(GBL_CHK_User) & "&Relogin=Yes>请重新登录访问论坛</a>.</div>" & VbCrLf
						Else
							Randomize
							CALL LDExeCute("Update LeadBBS_User Set Prevtime=" & GetTimeValue(DEF_Now) & ",Login_IP='" & Replace(GBL_IPAddress,"'","''") & "',Login_lastpass='" & Fix(rnd*99999) & "',Login_falsenum=Login_falsenum+1 Where ID=" & GBL_UserID,1)
							Call UpdateSessionValue(11,GetTimeValue(DEF_Now),0)
							Call UpdateSessionValue(7,Fix(rnd*99999),0)
							Call UpdateSessionValue(8,1,1)
							Response.Write "<div class=alert>激活码错误，注册用户激活失败！</div>"
							VierForm()
						End If
					End If
				End If
			Else
				If GBL_CHK_TempStr = "" Then
					If GBL_CHK_User = "" or GBL_CHK_Pass = "" Then GBL_CHK_TempStr = "用户名或密码资料填写错误！"
				End If
				'Response.Write "<div class=alert>" & GBL_CHK_TempStr & "</div>"
				VierForm()
			End If
		Else
			VierForm()
		End If
	
	End Sub
	
	Private Sub VierForm%>

	<div class='alert redfont'><%=GBL_CHK_TempStr%></div>
	<div class=title>请输入您要激活的账号，密码及激活码。</div>
	<form action=<%=DEF_BBS_HomeUrl%>User/UserGetPass.asp method="post" onSubmit="submit_disable(this);">
		<div class="value2">用户名： <input name=User type=text maxlength=255 size=22 value="<%
		If GBL_CHK_user = "" or isNull(GBL_CHK_user) Then
			Response.Write htmlencode(Request("user"))
		Else
			Response.Write htmlencode(GBL_CHK_user)
		End If%>" class='fminpt input_2'>　可以是邮箱地址或手机号码</div>
		<input name=act type=hidden value="active">
		<div class="value2">密　码： <input name=pass type=password maxlength=20 size=22 value="<%'=htmlencode(GBL_CHK_Pass)
%>" class='fminpt input_2'>
		</div>
		<div class="value2">
		激活码： <input name=AttestNumber type=text maxlength=10 size=22 value="<%If AttestNumber > 0 Then Response.Write AttestNumber%>" class="fminpt input_2">
		</div>
		<br /><input type=submit value="激活用户" class="fmbtn btn_3"> <input type=reset value="取消" class="fmbtn btn_2">
	</form>
	<br />
	<div class=title>说明：</div>
	<ul><li>如果您的账号需要激活，请填完整上面的三项内容，并点击激活账号按钮。</li>
	<li>激活码在注册时就已经发送到您的邮箱，输入正确的激活码才能激活您的账号。</li>
	<li>某些账号只能由管理员才能激活，利用此功能将仍然无法激活。</li>
	</ul>

	<%
	Call getpass_menu()
	
		If DEF_User_GetPassMode = 2 Then
			Response.Write "<br><a href=UserGetPass.asp><font color=red class=redfont><b>若您的邮箱未收到激活码信件，可以使用密码找回功能要求再次发送！</b></font></a>"
		End If
	
	End Sub
	
End Class%>