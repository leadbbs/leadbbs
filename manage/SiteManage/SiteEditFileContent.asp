<!-- #include file=../../inc/BBSsetup.asp -->
<!-- #include file=../../inc/Board_popfun.asp -->
<!-- #include file=../inc/bbsmanage_Fun.asp -->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo
DisplayUserNavigate("编辑文件内容")
If GBL_CHK_Flag=1 and GBL_CHK_TempStr = "" Then
	SiteEditFileContent
Else
	DisplayLoginForm
End If
frame_BottomInfo
closeDataBase
Manage_Sitebottom("none")

Sub SiteEditFileContent

	Dim FileName,File,TmpStr
	File = Request("File")
	If isNumeric(File) = 0 Then File = 0
	File = Fix(cCur(File))
	If File < -4 or File > DEF_BoardStyleStringNum or File = -2 Then
		Response.Write "<div class=alert>错误,要编辑的文件不存在!</div>" & VbCrLf
		Exit Sub
	End If
	Select Case File
		Case -3: FileName = "../../User/inc/Contact_info.asp"
				 TmpStr = "<b>在线编辑Contact_info.asp文件（联系我们信息）</b>，HTML语法"
		Case -4: FileName = "../../../other/80bbs/test.txt"
				 TmpStr = "<b>在线编辑../../../other/80bbs/test.txt文件</b>，HTML语法"
		'Case -2: FileName = "../../inc/BBSSetup.asp"
		'		 TmpStr = "<b>在线编辑BBSSetup.asp论坛配置文件</b>，请注意，修改前最好备份BBSSetup.asp文件"
		Case -1: FileName = "../../User/inc/User_Reg.asp"
				 TmpStr = "<b>编辑新用户注册论坛协议内容</b>(html格式)"
		Case Else: FileName = "../../inc/style" & File & ".css"
				 TmpStr = "<b>编辑风格样式定义-" & DEF_BoardStyleString(File) & "</b> CSS文件格式"
	End Select
	DisplayEditFileContent FileName,TmpStr,File

End Sub

Sub DisplayEditFileContent(FileName,TmpStr,FileParNum)

	'If DEF_FSOString = "" Then
	'	Response.Write "<p><br><font color=red class=redfont>论坛已设置成不支持在线编辑文件功能!</font></p>" & VbCrLf
	'	Exit Sub
	'End If
	Dim fileContent

	If Request.Form("SubmitFlag") = "" Then
		FileContent = ADODB_LoadFile(FileName)
		If GBL_CHK_TempStr <> "" Then
			Response.Write "<p>" & GBL_CHK_TempStr
			GBL_CHK_TempStr = ""
			Exit Sub
		End If
	Else
		fileContent = Request.Form("fileContent")
		Dim TempContent
		TempContent = Lcase(fileContent)
		If inStr(TempContent,"<%") or inStr(TempContent,"include") or inStr(TempContent,"server") Then
			Response.Write "<p><br><font color=red class=redfont>内容中不能含有<%，include，Server等字符!</font></p>" & VbCrLf
			Exit Sub
		End If
		
		ADODB_SaveToFile fileContent,FileName
		
		If FileName = "../../User/inc/Contact_info.asp" Then
			CALL Update_InsertSetupRID(1051,"inc/Contact_info.ASP",5,fileContent," and ClassNum=" & 5)
		End If
		
		If FileName = "../../User/inc/User_Reg.asp" Then
			CALL Update_InsertSetupRID(1051,"inc/User_Reg.ASP",6,fileContent," and ClassNum=" & 6)
		End If
		
		If GBL_CHK_TempStr <> "" Then
			Response.Write "<p>" & GBL_CHK_TempStr
			GBL_CHK_TempStr = ""
			Exit Sub
		Else
			Response.Write "<p><font color=green class=greenfont><b>成功更新文件内容！</b></font></p>" & VbCrLf
		End If
	End If
	%>
	<div class=frameline><%=TmpStr%></div>
	<form action=SiteEditFileContent.asp method=post>
		<input type=hidden value=<%=FileParNum%> name=File>
		<input type=hidden value=yes name=SubmitFlag>
		<div class=frameline>
		<textarea name="fileContent" cols="80" rows="35" class=fmtxtra><%If fileContent <> "" Then Response.Write VbCrLf & server.htmlEncode(fileContent)%></textarea><p>
		</div>

		<div class=frameline>
		<input type="submit" name="save" value="修改" class=fmbtn>
		<input type="reset" name="Reset" value="取消" class=fmbtn>
		</div>
	</form>
	<%

End Sub
%>