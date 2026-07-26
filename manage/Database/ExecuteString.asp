<!-- #include file=../../inc/BBSSetup.asp -->
<!-- #include file=../../inc/Board_Popfun.asp -->
<!-- #include file=../inc/bbsmanage_Fun.asp -->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass
Server.ScriptTimeOut = 600

Dim GBL_EXEString

Manage_sitehead DEF_SiteNameString & " - 管理员",""

'GBL_CHK_TempStr = "论坛已经禁止此危险功能."

frame_TopInfo
DisplayUserNavigate("直接执行SQL语句")
If GBL_CHK_Flag=1 and GBL_CHK_TempStr = "" Then
	LoginAccuessFul
Else
	Response.Write "<div class=alert>" & GBL_CHK_TempStr & "</div>"
End If
frame_BottomInfo
closeDataBase
Manage_Sitebottom("none")

Function LoginAccuessFul

	If Request.Form("submitflag")="Dieos9xsl29LO_8" Then
		GBL_EXEString = Request("GBL_EXEString")
		If GBL_EXEString <> "" Then
			On Error Resume Next
			Dim RowCount,Rs
			Dim Time1,Time2
			Time1=Timer
			GBL_EXEString = Request("GBL_EXEString")
			If inStr(Lcase(GBL_EXEString),"leadbbs_log") Then
				Response.Write "<p><br>错误，不能对论坛日志进行任何操作！"
				Exit Function
			End If
			Con.CommandTimeout = 600
			if DEF_UsedDatabase = 1 then
				dim splitsql,sqln,split_DEF_access
								if trim(GBL_EXEString) <> "" then 
									splitsql = split(GBL_EXEString,VbCrLf)
									for sqln = 0 to ubound(splitsql,1)
										if inStr(splitsql(sqln),"###") then
											split_DEF_access = split(splitsql(sqln),"###")
											if ubound(split_DEF_access)>=0 then
												select case lcase(split_DEF_access(0))
													case "altertablecolumn":
														if ubound(split_DEF_access)>=4 then
															response.write AlterTableColumn(DEF_AccessDatabase,split_DEF_access(1),split_DEF_access(2),split_DEF_access(3),split_DEF_access(4))
														end if
												end select
											end if
										else
											call ldexecute(splitsql(sqln),1)
										end if
									next
								end if
			else
				CALL LDExeCute(GBL_EXEString,0)
			end if
			Time2=Timer

			select case DEF_UsedDataBase
				case 0:
					Set Rs = LDExeCute("select @@rowcount",0)
					RowCount = Rs(0)
					Rs.Close
				case 2:
					Set Rs = LDExeCute("select ROW_COUNT()",0)
					RowCount = Rs(0)
					Rs.Close
				case Else
					RowCount = "<font color=ff0000>未知</font>"
			End select
			Set Rs = Nothing
			If err.number<>0 Then
				Response.Write "<p><br><span style=""FONT-FAMILY: 宋体; FONT-SIZE: 12px;""><font color=ff0000><b>数据库命令操作失败：</b></font><p>"&err.description & "</span>"
				err.clear
			Else
				Response.Write "<p><br><span style=""FONT-FAMILY: 宋体; FONT-SIZE: 12px;""><font color=008800><b>下列数据库命令操作成功，共影响<font color=ff0000>" & RowCount & "</font>行数据，耗时" & (Time2-Time1)*1000 & "毫秒!</b></font></span><hr size=1>" & PrintTrueText(GBL_EXEString) & "<hr size=1>" & VbCrLf
			End If
		Else
			Response.Write "<p><br><font color=ff0000><b>命令不能为空!</b></font>"
		End If
		DisplayStringForm
	Else
		DisplayStringForm
	End If

End Function

Function DisplayStringForm
%>
<p>
<form action=ExecuteString.asp method="post">
	待执行SQL语句(警告：执行语句要万分小心!) <p>
	<textarea name=GBL_EXEString rows=8 cols=61 class=fmtxtra><%If GBL_EXEString <> "" Then Response.Write VbCrLf & htmlEncode(GBL_EXEString)%></textarea>
	<input name=submitflag type=hidden value="Dieos9xsl29LO_8">
	<p>
	<input type=submit value="执行" class=fmbtn> <input type=reset value="取消" class=fmbtn>
</form>
<%
End Function

Function PrintTrueText(tempString)

	If tempString<>"" Then
		PrintTrueText=Replace(Replace(Replace(Replace(Replace(htmlEncode(tempString),VbCrLf & " ","<br>" & "&nbsp;"),VbCrLf,"<br>" & VbCrLf),"   "," &nbsp; "),"  "," &nbsp;"),chr(9)," &nbsp; &nbsp; &nbsp;")

		If Left(PrintTrueText,1) = chr(32) Then
			PrintTrueText = "&nbsp;" & Mid(PrintTrueText,2)
		End If
	Else
		PrintTrueText=""
	End If

End Function

function AlterTableColumn(PathName,TableName,ColumnName,flag,val)

	'Dim strConn,Conn
	'On Error resume next
	'strConn="Provider=Microsoft.Jet.OLEDB.4.0; Data Source=" & server.mappath(DEF_BBS_HomeUrl & PathName)
	'set Conn=server.createobject("Adodb.connection")
	'Conn.open strConn
	dim mydb,mytable,myfield,Res
	set mydb=server.createobject("adox.catalog")
	set mytable=server.createobject("adox.table")
	set myfield =server.createobject("adox.column")

	MyDB.ActiveConnection =Con
	For Each MyTable In MyDB.Tables
		if lcase(MyTable.Name)=lcase(TableName) then
			For Each MyField In MyTable.Columns
				if  lcase(MyField.Name)=lcase(ColumnName) Then
					Res=1
					select case flag:
						case "rencolumnname":
							if MyField.Name <> val then
								MyField.Name = val
							end if
						case "Default":
							if cstr(MyField.Properties("Default").Value &"")<>cstr(val)  then
								MyField.Properties("Default").Value=val
							end if
						case "Description"
						  if  MyField.Properties("Description").Value<>val  then
						  	MyField.Properties("Description").Value=val
						  end if
						case "Jet OLEDB:Column Validation Rule":
						  if  MyField.Properties("Jet OLEDB:Column Validation Rule").Value<>val  then
						  MyField.Properties("Jet OLEDB:Column Validation Rule").Value=val
						  end if
						case "Jet OLEDB:Column Validation Text":
						  if  MyField.Properties("Jet OLEDB:Column Validation Text").Value<>val  then
						  MyField.Properties("Jet OLEDB:Column Validation Text").Value=val
						  end if
						case "Nullable":
						  if  MyField.Properties("Nullable").Value<>val  then
						  MyField.Properties("Nullable").Value=val
						  end if
						case "Jet OLEDB:Allow Zero Length":
						  if  MyField.Properties("Jet OLEDB:Allow Zero Length").Value<>val  then
						  MyField.Properties("Jet OLEDB:Allow Zero Length").Value=val
						  end if
						case "Jet OLEDB:Compressed UNICODE Strings":
						  if  MyField.Properties("Jet OLEDB:Compressed UNICODE Strings").Value<>ColumnUnicode  then
						  MyField.Properties("Jet OLEDB:Compressed UNICODE Strings").Value=ColumnUnicode
						  end if
					end select
					exit for 
				end if 
			Next
			if Res=1 then exit for
		end if
	if Res=1 then exit for
	Next
	set myfield = nothing
	set mytable = nothing
	set mydb = nothing

	'conn.close
	'set Conn=nothing
	AlterTableColumn = "数据表"&tablename&"表中字段 "&ColumnName&" 修改常用属性完成."

End function%>