<%class edit_Truename_Class

	Private truename,submitflag
	
	Private Sub Class_Initialize

		truename_get
		if truename <> "" then
			'Response.Write "<div class=bbs_error>您的昵称是 <u class=bluefont>" & htmlencode(truename) & "</u>，无法再次申请更改。</div>"
			'exit sub
		end if
		submitflag = request.form("submitflag")
		truename = trim(request.form("truename"))
		if truename = "" then truename_get
		if submitflag = "" or truename = "" then
			truename_class_form
		else
			truename_class_submit
		end if
	
	End Sub
	
	private function truename_get
	
		dim rs,sql
		sql = "select truename from leadbbs_user where id=" & GBL_UserID
		set rs = ldexecute(sql,0)
		if not rs.eof then
			truename = rs(0)
		else
			truename = ""
		end if
		rs.close
		set rs = nothing

	end function
	
	private sub truename_class_form
	%>
	<br>
		<form action="UserModify.asp?action=truename" method="post" name="LeadBBSFm" id="LeadBBSFm">
		<input name=SubmitFlag type=hidden value="1">
		<table border=0 cellpadding="0" class="blanktable">
		<tr><td>
		*请输入昵称
		</td></tr>
		<tr><td>
		<input class='fminpt input_3' maxLength=20 name="truename" value="<%=htmlencode(truename)%>" size=14 type=input>
		</td></tr>
		<tr><td>
		<input name=submit id=submit type=submit value="提交" class="fmbtn btn_2">
		</td></tr>
		<tr><td>
		<hr class=splitline>
		<span class="grayfont"><b>注：</b><br />
		设置昵称可以更好的保护您的账号隐私，论坛优先使用昵称作为您的称呼来展示。<br />
		昵称允许使用重复的名称。
		</span>
		</td></tr>
		</table>
		</form>
	<%
	
	end sub
	
	private function check_username_exist(name)
	
		dim rs,sql
		sql = "select id from leadbbs_user where username='" & Replace(name,"'","''") & "' and id<>" & GBL_UserID
		set rs = ldexecute(sql,0)
		if not rs.eof then
			check_username_exist = 1
			rs.close
			set rs = nothing
			exit function
		end if
		
		rs.close
		set rs = nothing
		
		sql = "select id from leadbbs_user where truename='" & Replace(name,"'","''") & "' and id<>" & GBL_UserID
		set rs = ldexecute(sql,0)
		if not rs.eof then
			check_username_exist = 1
			rs.close
			set rs = nothing
			exit function
		end if
		
		rs.close
		set rs = nothing
		check_username_exist = 0
	
	end function
	
	private sub truename_class_submit
	
		dim sql
		if check_usernameFilter(truename,"昵称") = 0 then
			Response.Write "<div class=bbs_error>" & GBL_CHK_Tempstr & "</div>"
			truename_class_form
			exit sub
		end if
		if check_username_exist(truename) = 1 then
			Response.Write "<div class=bbs_error>此名称已有其它用户使用，请使用其它昵称。</div>"
			truename_class_form
			exit sub
		end if
		sql = "update leadbbs_user set truename='" & replace(truename,"'","''") & "' where id=" & GBL_UserID
		call ldexecute(sql,1)
		Response.Write "<div class=bbs_ok>您的昵称已成功设置为 <u>" & htmlencode(truename) & "</u>。</div>"
	
	end sub

end class
%>