<%
Class class_editboardintro

	private submitflag,bbs_ok,bbs_error,bbs_Content,bbs_BoardLimit,bbs_htmlflag

	public Sub Edit_BoardInfo
	
		bbs_ok = ""
		bbs_error = ""
		if GBL_BoardMasterFlag < 5 or GBL_Board_id < 1 then
			Global_ErrMsg "权限不足或参数错误。" & VbCrLf
			exit sub
		end if

		bbs_HTMLFlag = 2
		submitflag = GetFormData("submitflag")
		if submitflag <> "1" then
			class_getdata
			if GBL_Board_id < 1 then
				Global_ErrMsg "参数错误。" & VbCrLf
				exit sub
			end if
			class_form
		else
			class_getvalue
			if GBL_CHK_TempStr <> "" then
				class_form
				exit sub
			end if
			class_save
			class_form
		end if
	
	End Sub
	
	private sub class_getvalue
	
		bbs_HTMLFlag = GetFormData("Form_HTMLFlag")
		If bbs_HTMLFlag="2" Then
			bbs_HTMLFlag = 2
		ElseIf bbs_HTMLFlag = "1" and ((GetBinarybit(GBL_CHK_UserLimit,16) = 1 and GBL_BoardMasterFlag >= 2) or SupervisorFlag = 1) and GBL_UserID > 0 Then
			bbs_HTMLFlag = 1
		Else
			bbs_HTMLFlag = 0
		End If
		bbs_Content = GetFormData("Form_Content")
		if len(bbs_Content) > LMT_MaxTextLength then
			bbs_error = "内容过长。" & VbCrLf
		end if

	end sub
	
	private sub class_getdata

		dim sql,rs
		SQL = "Select BoardIntro2,boardlimit from LeadBBS_boards where boardID=" & GBL_Board_id
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			bbs_Content = ""
			GBL_Board_id = 0
			bbs_error = "参数错误。" & VbCrLf
		else
			bbs_Content = rs(0)
			bbs_BoardLimit = rs(1)
			dim htmltype
			htmltype = left(bbs_Content,2)
			if htmltype = "2|" then
				bbs_Content = mid(bbs_Content,3)
				htmltype = 2
			elseif htmltype = "1|" then
				bbs_Content = mid(bbs_Content,3)
				htmltype = 1
			elseif htmltype = "0|" then
				bbs_Content = mid(bbs_Content,3)
				htmltype = 0
			else
				htmltype = 2
			end if
			bbs_htmlflag = htmltype
		end if
		rs.close
		set rs = nothing

	end sub
	
	private sub class_form
	%><script src="<%=DEF_BBS_HomeUrl%>a/inc/leadcode.js?ver=<%=DEF_Jer%>"></script>
		<div class=contentbox>
		<%If bbs_error <> "" or bbs_ok <> "" then%>
		<table border=0 cellpadding=0 cellspacing=0 width="100%" class=tablebox>
		<tr class=tbhead>
			<td align=center><div class=value>
			<%if bbs_ok <>"" then%>
			<span class=bbs_ok><%=bbs_ok%></span>
			<%else%><span class=bbs_error><%=bbs_error%></span>
			<%end if
			%>
			</div>
		</td>
	</tr>
	</table>
		<%end if%>
		<form action=EditAnnounce.asp method=post id=LeadBBSFm name=LeadBBSFm onSubmit="edt_checkContent();submit_disable(this);">
		<table border=0 cellpadding=0 cellspacing=0 width="100%" class=tablebox>
		<%call DisplayLeadBBSEditor1(bbs_HTMLFlag,bbs_Content,0,1)%>
		<tr>
			<td class=tdleft>&nbsp;</td>
			<td class=tdright>
				<br />
				<input name="b" type="hidden" value="<%=gbl_board_id%>">
				<input name="id" type="hidden" value="-1">
				<input name="submitflag" type="hidden" value="1">
				<input name=submit2 type=submit value="完成编辑" class="fmbtn btn_3">
				<br /><br />
			</td>
		</tr>
		</table>
		</form>
		
		</div>
	<%
	end sub
	
	private sub class_save

		dim sql
		dim val : val = 0
		
		if checkFiles(server.mappath(DEF_BBS_HomeUrl & "images/board/b_" & GBL_Board_id & ".png")) = 1 then
			val = 1
		end if
		
		if trim(bbs_Content) <> "" then val = 1

		GBL_Board_BoardLimit = SetBinarybit(GBL_Board_BoardLimit,24,val)
		SQL = "update LeadBBS_boards set BoardIntro2='" & replace(bbs_htmlflag & "|" & bbs_Content,"'","''") & "',BoardLimit=" & GBL_Board_BoardLimit & " where boardID=" & GBL_Board_id
		call LDExeCute(SQL,1)		
		
		ReloadBoardInfo(GBL_Board_id)
		bbs_ok = "编辑成功。"
	
	end sub
	
	private Function checkFiles(path)

		If DEF_FSOString = "" Then Exit Function
		on error resume next
		Dim fs
		Set fs = Server.CreateObject(DEF_FSOString)
		If err <> 0 Then
			Err.Clear
			Response.Write "<p>服务器不支持FSO．</p>"
			Exit Function
		End If
		If fs.FileExists(path) Then
			checkFiles = 1
		Else
			checkFiles = 0
		End If
		Set fs = Nothing
	
	End Function

end class
%>