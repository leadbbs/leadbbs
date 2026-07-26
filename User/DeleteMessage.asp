<!-- #include file=../inc/BBSsetup.asp -->
<!-- #include file=../inc/Board_Popfun.asp -->
<!-- #include file=../inc/Upload_Setup.asp -->
<!-- #include file=../inc/Limit_Fun.asp -->
<%
DEF_BBS_HomeUrl = "../"

Main

Sub Main

	InitDatabase
	Dim AjaxFlag,FriendFlag,ViewStr
	If Request.Form("AjaxFlag") = "1" Then
		AjaxFlag = 1
	Else
		AjaxFlag = 0
	End If
	
	FriendFlag = Request("FriendFlag")
	Select Case FriendFlag
	Case "1":
		FriendFlag = 1
		ViewStr = "关注"
	Case "2":
		FriendFlag = 2
		ViewStr = "收藏"
	Case "3":
		FriendFlag = 3
		ViewStr = "附件"
	Case Else
		FriendFlag = 0
		ViewStr = "消息"
	End Select
	
	Dim MessageID
	MessageID = Request("MessageID")
	If InStr(MessageID,",") > 0 Then
		Dim TmpMsg,i
		TmpMsg = Split(MessageID,",")
		If Ubound(TmpMsg,1) >= DEF_MaxListNum and Ubound(TmpMsg,1) >= DEF_TopicContentMaxListNum Then
			MessageID = 0
		Else
			MessageID = ""
			For i = 0 to Ubound(TmpMsg,1)
				If isNumeric(TmpMsg(i)) = 0 Then
					MessageID = 0
					Exit For
				Else
					If MessageID = "" Then
						MessageID = Fix(cCur(TmpMsg(i)))
					Else
						MessageID = MessageID & "," & Fix(cCur(TmpMsg(i)))
					End If
				End If
			Next
		End If
	Else
		If isNumeric(MessageID) = 0 or MessageID = "" Then MessageID = 0
		MessageID = Fix(cCur(MessageID))
	End If
	
	GBL_CHK_TempStr=""
	If GBL_UserID < 1 Then
		GBL_CHK_TempStr = GBL_CHK_TempStr & "请先登录." & VbCrLf
	End If
	
	If AjaxFlag = 0 Then
		siteHead("   删除" & ViewStr)%>
	<script language=javascript>
		window.moveTo(window.screen.width/2-225,window.screen.height/2-18);
	</script>
	<table align=center border=0 cellpadding=0 cellspacing=0>
	<tbody>
	<tr> 
		<td height=21 width="650">
		<%
	End If
		Dim Rs,SQL,SQLendString,ClearFlag
		If GBL_CHK_TempStr = "" Then
			ClearFlag = Request("ClearFlag")
			If ClearFlag = "dkeJje5" or ClearFlag = "dkeJje6" Then
				If GBL_UserID<1 or CheckSupervisorUserName = 0 or ClearFlag = "dkeJje5" Then
					Select Case FriendFlag
					Case 1:
						SQL = "delete from LeadBBS_FriendUser where UserID=" & GBL_UserID
					Case 2:
						SQL = "delete from LeadBBS_CollectAnc where UserID=" & GBL_UserID
					Case 0:
						SQL = "delete from LeadBBS_InfoBox where ToUser='" & Replace(GBL_CHK_User,"'","''") & "'"
					End Select
				Else
					Select Case FriendFlag
					Case 1:
						SQL = "delete from LeadBBS_FriendUser"
					Case 2:
						SQL = "delete from LeadBBS_CollectAnc"
					Case 0:
						SQL = "delete from LeadBBS_InfoBox"
					End Select
				End If
						
				If Request.Form("DeleteSureFlag")="dk9@dl9s92lw_SWxl" Then
					%>成功删除所有<%=ViewStr%>!<%
					CALL LDExeCute(SQL,1)
					Select case FriendFlag
						Case 0:
							CALL LDExeCute("Update LeadBBS_User Set MessageFlag=0 where ID=" & GBL_UserID,1)
							If CheckSupervisorUserName = 1 Then ReloadPubMessageInfo
					End Select
				Else
					%>
					<form name=DellClientForm action=DeleteMessage.asp method=post>
						<input type=hidden name=DeleteSureFlag value="dk9@dl9s92lw_SWxl">
						<input type=hidden name=FriendFlag value="<%=htmlencode(FriendFlag)%>">
						<input type=hidden name=ClearFlag value="<%=htmlencode(ClearFlag)%>">
						<input type=hidden name=MessageID value="<%=htmlencode(MessageID)%>">
						<b>删除操作不可逆, 确认删除所有<%=ViewStr%>吗？</b>
						<p><input type=submit value=确定 class=fmbtn>
						<input type=button value=不删 onclick="javascript:window.close();" class=fmbtn>
					</form>
					<%
				End If
			Else
				If MessageID = 0 Then
					Response.Write "操作失败,此" & ViewStr & "可能已删除." & VbCrLf
				Else
					If Request.Form("DeleteSureFlag")="dk9@dl9s92lw_SWxl" Then
						If CheckSupervisorUserName = 0 Then
							Select Case FriendFlag
								Case 0:
									Response.Write "删除成功!"
									CALL LDExeCute("Delete from LeadBBS_InfoBox where ToUser='" & Replace(GBL_CHK_User,"'","''") & "' and id in(" & MessageID & ")",1)
								Case 1:
									Response.Write "已取消关注!"
									CALL LDExeCute("Delete from LeadBBS_FriendUser where UserID=" & GBL_UserID & " and ID in(" & MessageID & ")",1)
								Case 2:
									Response.Write "删除成功!"
									CALL LDExeCute("Delete from LeadBBS_CollectAnc where UserID=" & GBL_UserID & " and ID in(" & MessageID & ")",1)
								Case 3:
									Response.Write "删除成功!"
									CheckisBoardMaster
									If (GetBinarybit(GBL_CHK_UserLimit,11) = 1 and GBL_BoardMasterFlag >=4) Then
										CALL Del_Upload("id in(" & MessageID & ")",0)
									Else
										CALL Del_Upload("UserID=" & GBL_UserID & " and id in(" & MessageID & ")",GBL_UserID)
									End If
							End Select
						Else
							Response.Write "删除成功!"
							Select Case FriendFlag
								Case 0:
									CALL LDExeCute("Delete from LeadBBS_InfoBox where id in(" & MessageID & ")",1)
									ReloadPubMessageInfo '管理员刷新公告
								Case 1:
									CALL LDExeCute("Delete from LeadBBS_FriendUser where ID in(" & MessageID & ")",1)
								Case 2:
									CALL LDExeCute("Delete from LeadBBS_CollectAnc where ID in(" & MessageID & ")",1)
								Case 3:
									CALL Del_Upload("id in(" & MessageID & ")",0)
							End Select
						End If
						
						If ccur(FriendFlag) = 0 and (ccur(GBL_CHK_MessageFlag) = 1) Then
							'提示更新
							SQL = sql_select("Select ID from LeadBBS_InfoBox where ReadFlag=0 and ToUser='" & Replace(GBL_CHK_User,"'","''") & "'",1)
							Set Rs = LDExeCute(SQL,0)
							If Rs.Eof Then
								Rs.Close
								Set Rs = Nothing
								CALL LDExeCute("Update LeadBBS_User Set MessageFlag=0 where UserName='" & Replace(GBL_CHK_User,"'","''") & "'",1)
								Free_UDT
							Else
								Rs.Close
								Set Rs = Nothing
							End If
						End If
					Else
						%>
						<form name=DellClientForm action=DeleteMessage.asp method=post>
							<input type=hidden name=DeleteSureFlag value="dk9@dl9s92lw_SWxl">
							<input type=hidden name=ClearFlag value="<%=htmlencode(ClearFlag)%>">
							<input type=hidden name=FriendFlag value="<%=htmlencode(FriendFlag)%>">
							<input type=hidden name=MessageID value="<%=htmlencode(MessageID)%>">
							<b>确认要删除编号为<font color=ff0000 class=redfont><%=MessageID%></font>的<%=ViewStr%>吗？</b>
							<br><br><input type=submit value=确定 class=fmbtn>
							<input type=button value=放弃 onclick="javascript:window.close();" class=fmbtn>
						</form>
						<%
					End If
				End If
			End If
		Else
			If AjaxFlag = 0 Then%>
			<table width=96%>
			<tr>
			<td>
				<p align=left><font color=ff0000 class=redfont><b>
			<%End If
			Response.Write GBL_CHK_TempStr
			If AjaxFlag = 0 Then%>
				</b></p>
			</td>
			</tr>
			</table>
			<%End If
		End If
	If AjaxFlag = 0 Then%>
		</td>
	</tr>
	
	</table>
	<%
	End If
	
	closeDataBase
	If AjaxFlag = 0 Then SiteBottom_Spend

End Sub

Sub Del_Upload(str,UID)

	Dim Rs,SQL,GetData
	SQL = "Select ID,PhotoDir,SPhotoDir,UserID from LeadBBS_Upload where " & str
	
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		Exit Sub
	Else
		GetData = Rs.GetRows(-1)
		Rs.Close
		Set Rs = Nothing
	End If
	
	Dim N,UploadUserID,PhotoDir,SPhotoDir,Count
	Count = Ubound(GetData,2) + 1
	
	For N = 0 to Count - 1
		UploadUserID = GetData(3,N)
		PhotoDir = GetData(1,N)
		SPhotoDir = GetData(2,N)
		
		If PhotoDir & "" <> "" Then DeleteFiles(Server.Mappath(Replace(Replace(DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & PhotoDir,"/","\"),"\\","\")))
		If SPhotoDir & "" <> "" Then DeleteFiles(Server.Mappath(Replace(Replace(DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & SPhotoDir,"/","\"),"\\","\")))
		If UID = 0 Then CALL LDExeCute("Update LeadBBS_User Set UploadNum=UploadNum-1 where id=" & UploadUserID,1)
	Next
	CALL LDExeCute("update LeadBBS_SiteInfo set UploadNum=UploadNum-" & Count,1)
	Dim DelCount
	DelCount = 0-Count
	UpdateStatisticDataInfo DelCount,5,1
	If UID > 0 Then CALL LDExeCute("Update LeadBBS_User Set UploadNum=UploadNum-" & Count & " where id=" & UploadUserID,1)
	CALL LDExeCute("delete from LeadBBS_Upload where " & str,1)

End Sub


Function DeleteFiles(path)

	If DEF_FSOString = "" Then Exit Function
	on error resume next
	Dim fs
	Set fs = Server.CreateObject(DEF_FSOString)
	If err <> 0 Then
		Err.Clear
		'Response.Write "空间不支删除操作(FSO)．"
		Exit Function
	End If
	If fs.FileExists(path) Then
		fs.DeleteFile path,True
		DeleteFiles = 1
	Else
		DeleteFiles = 0
	End If
	Set fs = Nothing
         
End Function
%>