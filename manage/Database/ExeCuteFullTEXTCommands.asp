<!-- #include file=../../inc/BBSSetup.asp -->
<!-- #include file=../../inc/Board_Popfun.asp -->
<!-- #include file=../inc/bbsmanage_Fun.asp -->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass

If GBL_CHK_Flag=1 Then
	GBL_CHK_TempStr = ""
	ExeCuteFullTEXTCommands
	Response.Write GBL_CHK_TempStr
Else
	Response.Write "<span style=""FONT-FAMILY: 宋体; FONT-SIZE: 12px;""><font color=ff0000 class=redfont><b>操作失败!</b></font></span>"
End If
closeDataBase

Function ExeCuteFullTEXTCommands


	If Request.Form("SureFlag") <> "E72ksiOkw2" Then
		%>
			<p><form action=ExeCuteFullTEXTCommands.asp method=post>
			<b><font color=ff0000 class=redfont>确定此操作吗?<br>
			<br>
			<input type=hidden name=SureFlag value="E72ksiOkw2">
			<input type=hidden name=ExeFlag value="<%=Request("ExeFlag")%>">
			
			<input type=submit value=确定进行 class=fmbtn>
			</form>
		<%
	Else
		Dim Rs,SQL,DBName
		If DEF_UsedDataBase <> 0 Then
			GBL_CHK_TempStr = "<span style=""FONT-FAMILY: 宋体; FONT-SIZE: 12px;color:ff0000"">Access数据库不支持全文索引服务!</span>"
			Exit Function
		End If
	
		On Error Resume Next
		Dim ExeFlag
		ExeFlag = Left(Request("ExeFlag"),14)
		If isNumeric(ExeFlag) = 0 Then ExeFlag = 0
		ExeFlag = cCur(ExeFlag)
	
		Select Case ExeFlag
			Case 1: CALL LDExeCute("exec sp_fulltext_database N'enable'",1)
				GBL_CHK_TempStr = "成功为数据库启用全文索引!<br>" & VbCrLf
			Case 2: CALL LDExeCute("exec sp_fulltext_database N'disable'",1)
				GBL_CHK_TempStr = "成功为数据库禁用全文索引!<br>" & VbCrLf
			Case 3: CALL LDExeCute("exec sp_fulltext_table @tabname='LeadBBS_Announce',@action='start_change_tracking'",1)
				GBL_CHK_TempStr = "成功启动全文索引增量填充(更改跟踪)!<br>" & VbCrLf
			Case 4: CALL LDExeCute("exec sp_fulltext_table @tabname='LeadBBS_Announce',@action='stop_change_tracking'",1)
				GBL_CHK_TempStr = "成功停止全文索引增量填充(更改跟踪)!<br>" & VbCrLf
			Case 5: CALL LDExeCute("exec sp_fulltext_table @tabname='LeadBBS_Announce',@action='Start_background_updateindex'",1)
				GBL_CHK_TempStr = "成功启动更新后台中的索引!<br>" & VbCrLf
			Case 6: CALL LDExeCute("exec sp_fulltext_table @tabname='LeadBBS_Announce',@action='Stop_background_updateindex'",1)
				GBL_CHK_TempStr = "成功停止更新后台中的索引!<br>" & VbCrLf
			Case 7: CALL LDExeCute("exec sp_fulltext_table @tabname='LeadBBS_Announce',@action='update_index'",1)
				GBL_CHK_TempStr = "成功更新索引!<br>" & VbCrLf
			Case 8: 
					SQL = "Select DB_NAME(DB_ID())"
					Set Rs = LDExeCute(SQL,0)
					If Rs.Eof Then
						DBName = ""
					Else
						DBName = Rs(0)
					End If
					Rs.Close
					Set Rs = Nothing
					CALL LDExeCute("backup log [" & Replace(DBName,"'","''") & "] with no_log",1)
					GBL_CHK_TempStr = "成功清除系统日志!<br>" & VbCrLf
			Case 9: 
					SQL = "Select DB_NAME(DB_ID())"
					Set Rs = LDExeCute(SQL,0)
					If Rs.Eof Then
						DBName = ""
					Else
						DBName = Rs(0)
					End If
					Rs.Close
					Set Rs = Nothing
					CALL LDExeCute("DBCC SHRINKFILE ([" & Replace(DBName,"'","''") & "_log])",1)
					GBL_CHK_TempStr = "成功收缩日志文件" & Replace(DBName,"'","''") & "_log!<br>" & VbCrLf
			Case 10:
					SQL = "Select DB_NAME(DB_ID())"
					Set Rs = LDExeCute(SQL,0)
					If Rs.Eof Then
						DBName = ""
					Else
						DBName = Rs(0)
					End If
					Rs.Close
					Set Rs = Nothing
					CALL LDExeCute("DBCC SHRINKFILE ([" & Replace(DBName,"'","''") & "_Data])",1)
					GBL_CHK_TempStr = "成功收缩数据库文件" & Replace(DBName,"'","''") & "_Data!<br>" & VbCrLf
		End Select
		if err.number<>0 Then
			GBL_CHK_TempStr = "<span style=""FONT-FAMILY: 宋体; FONT-SIZE: 12px;""><font color=ff0000 class=redfont><b>数据库操作失败：</b></font>"&err.description & "</span>"
		Else
			GBL_CHK_TempStr = "<span style=""FONT-FAMILY: 宋体; FONT-SIZE: 12px;""><font color=008800 class=greenfont><b>" & GBL_CHK_TempStr & "</b></font></span>" & VbCrLf
		End If
	End If

End Function
%>