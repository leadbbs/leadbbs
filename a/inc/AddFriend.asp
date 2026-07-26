<%Const LMT_MaxFriendNum = 200 '允许添加的最多好友数目
Function CheckAddFriendSure

	If GetBinarybit(GBL_CHK_UserLimit,1) = 1 Then
		Call Processor_ErrMsg("您的权限不足，非正式用户无此功能！" & VbCrLf)
		CheckAddFriendSure = 0
		Exit Function
	End If
	CheckAddFriendSure = 1

End Function


Function DisplayAddFriend

	Dim FriendName,FriendID
	FriendName = Left(Request("FriendName"),20)
	FriendID = toNum(Left(Request("FriendNameID"),20),0)
	If Request.Form("SureFlag")="1" Then
		Dim Rs,SQL
		SQL = "Select count(*) from LeadBBS_FriendUser where UserID=" & GBL_UserID
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			SQL = 0
		Else
			SQL = Rs(0)
			If IsNull(SQL) Then SQL = 0
			SQL = cCur(SQL)
		End If
		Rs.Close
		Set Rs = Nothing

		If SQL > LMT_MaxFriendNum Then
			Call Processor_ErrMsg("错误，你光注的用户已超过" & LMT_MaxFriendNum & "人，不能再添加！" & VbCrLf)
			Set Rs = Nothing
			Exit Function
		End if

		If FriendID > 0 Then
			SQL = sql_select("Select ID,UserName,TrueName from LeadBBS_User where id=" & FriendID & "",1)
		else
			SQL = sql_select("Select ID,UserName,TrueName from LeadBBS_User where UserName='" & Replace(FriendName,"'","''") & "'",1)
		end if
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			Call Processor_ErrMsg("请正确填写要关注的用户！" & VbCrLf)
			Rs.Close
			Set Rs = Nothing
			Exit Function
		End If
		FriendID = cCur(Rs(0))
		FriendName = GetTrueName(Rs(1),Rs(2))
		Dim FriendUserName : FriendUserName = Rs(1)
		Rs.Close
		Set Rs = Nothing
		
		SQL = sql_select("Select ID from LeadBBS_FriendUser where FriendUserID=" & FriendID & " and UserID=" & GBL_UserID,1)
		Set Rs = LDExeCute(SQL,0)
		If Not Rs.Eof Then
			//Processor_ErrMsg "<b>" & htmlencode(FriendName) & "</b> 已经关注过，无法再次操作！" & VbCrLf
			Call Processor_ErrMsg("<div id=collect_msg><b>" & htmlencode(FriendName) & "</b> 已在关注列表，无法重复添加！<br /><a href=""javascript:p_url = '" & DEF_BBS_HomeUrl & "User/DeleteMessage.asp';" & VbCrLf & "p_para='AjaxFlag=1&FriendFlag=1&DeleteSureFlag=dk9@dl9s92lw_SWxl&MessageID=';" & VbCrLf & "p_command = '$id(\'collect_msg\').innerHTML=tmp';" & VbCrLf & "p_type = 1;" & VbCrLf & "p_once(" & Rs(0) & ");"">点击取消对Ta的关注。</a></div>" & VbCrLf)
			Rs.Close
			Set Rs = Nothing
			Exit Function
		End If
		Rs.Close
		Set Rs = Nothing

		CALL LDExeCute("insert into LeadBBS_FriendUser(FriendUserID,UserID) Values(" & FriendID & "," & GBL_UserID & ")",1)
		Set Rs = Nothing
		If CheckSupervisorUserName() = 0 Then
			CALL LDExeCute("Update LeadBBS_User Set LastWriteTime=" & GetTimeValue(DEF_Now) & " where ID=" & GBL_UserID,1)
			UpdateSessionValue 13,GetTimeValue(DEF_Now),0
		End If
		SendNewMessage Prc_User,FriendUserName,"论坛短信：添加关注通知","[url=../User/" & RW_User(GBL_UserID,"","","") & "]" & GetTrueName(GBL_CHK_User,GBL_CHK_TrueName) & "[/url]关注了你." & VbCrLf,GBL_IPAddress
		Call Processor_Done("成功关注" & htmlencode(FriendName) & "！")
	Else
		Processor_Head()
		
		Dim Url
		Url = filterUrlstr(htmlencode(Left(Request("dir"),100)))
		If Request("dir") = "" Then
			If inStr(Request.ServerVariables("QUERY_STRING"),"dir=") then
				Url = ""
			Else
				Url = DEF_BBS_HomeUrl
			End If
		End If
		%>
		<form name=DellClientForm action="<%=Url%>a/Processor.asp?action=AddFriend&b=<%=Request("B")%>" onSubmit="submit_disable(this);" method=post<%
	If AjaxFlag = 1 Then
		Response.Write " target=""hidden_frame"""
	End If
	%>>
			<input type=hidden name=SureFlag value="1">
			<input type=hidden name=JsFlag value="1">
			<input type=hidden name=Url value="<%=Url%>">
			<input type=hidden name=AjaxFlag value="<%=AjaxFlag%>">
			<input type=hidden name=ID value="<%=Request("ID")%>">
			<input type=hidden name=BoardID value="<%=Request("B")%>">
			<div class=value2>
			关注的名字：
			<input type=input name=FriendName value="<%=FriendName%>" class='fminpt input_2'>
			<input type=hidden name=FriendNameID value="<%=FriendID%>">
			</div>
			<div class=value2><br /><input type=submit value=关注Ta class="fmbtn btn_3"></div>
		</form>
		<%Processor_Bottom
	End If

End Function%>