<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/UBBicon_Setup.ASP"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Const MaxLinkNum = 100
initDatabase()
GBL_CHK_TempStr = ""
CheckSupervisorPass()

Dim Form_DEF_UBBiconNote
Redim Form_DEF_UBBiconNote(DEF_UBBiconNumber)

GetDefaultValue()

SiteHead(DEF_SiteNameString & " - 管理员")
UserTopicTopInfo()
DisplayUserNavigate("论坛表情注释参数设置")
If GBL_CHK_Flag=1 Then
	UBBiconSetup()
Else%>
	<table width=96%>
	<tr>
	<td>
	<%
	If Request("submitflag")="" Then
		Response.Write "<br><b>请先登录</b>"
	Else
		Response.Write "<br><p align=left><font color=ff0000 class=RedFont><b>" & GBL_CHK_TempStr & "</b></font>"
	End If
	DisplayLoginForm()
	Response.Write "</p>"%>
	</td>
	</tr>
	</table>
<%End If
UserTopicBottomInfo()
closeDataBase()
SiteBottom()
If GBL_ShowBottomSure = 1 Then Response.Write GBL_SiteBottomString

Function UBBiconSetup

%>
<form name="pollform3sdx" method="post" action="UBBiconSetup.asp">
<input type="hidden" name="SubmitFlag" value=yes>
<p>
		设置：<a href=SiteSetup.asp>论坛常用参数</a> <a href=UploadSetup.asp>上传参数</a>
		<a href=../User/UserSetup.asp>用户注册参数</a>
		<a href=UbbcodeSetup.asp>UBB编码参数</a>
		<font color=gray class=GrayFont>UBB表情注释</font>
		</b>
		<br><font color=8888888 class=GrayFont>(下面为网站参数，请注意修改，错误的设置将会发生严重错误)<br><br>
		如果在设置后发现网站不能正常运行，请将LeadBBS最新版的inc/UBBicon_Setup.ASP覆盖回去</font>
</p>
<%If Request.Form("SubmitFlag") <> "" Then
	GetFormValue()
End If%>
<b><font color=ff0000 class=RedFont><%=GBL_CHK_TempStr%></font></b>
<p>
<%
If Request.Form("SubmitFlag") <> "" Then
	If GBL_CHK_TempStr <> "" Then
		DisplayDatabaseLink()
	Else
		MakeDataBaseLinkFile()
		Exit Function
	End If
Else
	DisplayDatabaseLink()
End If
%>
<br>
<input type=submit name=提交 value=提交 class=fmbtn>
<input type=reset name=取消 value=取消 class=fmbtn>
</form>
<%

End Function

Function DisplayDatabaseLink

	Dim n,m
	%>
	<table border=0 cellpadding=5 cellspacing=1 width="100%" bgcolor="<%=DEF_BBS_LightColor%>" class=TBBG1>
	<tr class=TBBG9>
		<td valign=top><b>表情注释</b></td>
		<td>
			<table border=0 cellpadding=1 cellspacing=0>
			<tr>
				<td>&nbsp;编号</td>
				<td>&nbsp;表情</td>
				<td>&nbsp;注释</td>
			</tr><%
		m = Ubound(DEF_UBBiconNote)
		For n = 0 to DEF_UBBiconNumber - 1
			If n = 0 or (n mod 16) = 0 Then Response.Write "<tr><td colspan=3>&nbsp;</td></tr>"
			If n > m Then
				%>
				<tr>
					<td>&nbsp;&nbsp;<%=Right(" " & n + 1,2)%></td>
					<td>&nbsp;<img src="<%=DEF_BBS_HomeUrl%>images/UBBicon/em<%=Right("0" & n + 1,2)%>.GIF" width=20 height=20 align=absmiddle border=0></td>
					<td>&nbsp;<input class=fminpt type="text" name="Form_DEF_UBBiconNote<%=N%>" maxlength="100" size="50" value=""></td>
				</tr>
				<%
			Else
				%>
				<tr>
					<td>&nbsp;&nbsp;<%=Right(" " & n + 1,2)%></td>
					<td>&nbsp;<img src="<%=DEF_BBS_HomeUrl%>images/UBBicon/em<%=Right("0" & n + 1,2)%>.GIF" width=20 height=20 align=absmiddle border=0></td>
					<td>&nbsp;<input class=fminpt type="text" name="Form_DEF_UBBiconNote<%=N%>" maxlength="100" size="50" value="<%=htmlencode(Form_DEF_UBBiconNote(n))%>"></td>
				</tr>
				<%
			End If
		Next
		%>
			</table></td>
	</tr>
	</table>
	<%

End Function

Function GetDefaultValue

	Dim N
	For N= 0 to Ubound(DEF_UBBiconNote)
		If N > DEF_UBBiconNumber Then Exit Function
		Form_DEF_UBBiconNote(n) = DEF_UBBiconNote(N)
	Next

End Function

Function GetFormValue

	Dim n
	For n = 0 to DEF_UBBiconNumber
		Form_DEF_UBBiconNote(n) = Trim(Request.Form("Form_DEF_UBBiconNote" & N))
	Next
	
	For n = 0 to DEF_UBBiconNumber
		If inStr(Form_DEF_UBBiconNote(n),"""") or inStr(Form_DEF_UBBiconNote(n),"%") Then
			GBL_CHK_TempStr = "第" & N & "编号表情描述不能包含有引号或百分号<br>" & VbCrLf
		End If
	Next

End Function

Function MakeDataBaseLinkFile

	Dim n,TempStr
	TempStr = ""
	TempStr = TempStr & chr(60) & "%" & VbCrLf
	TempStr = TempStr & "Dim DEF_UBBiconNote" & VbCrLf	
	TempStr = TempStr & "DEF_UBBiconNote = Array("
	For n = 0 to DEF_UBBiconNumber - 1
		If n = 0 Then
			TempStr = TempStr & """" & Form_DEF_UBBiconNote(n) & """"
		Else
			TempStr = TempStr & ",""" & Form_DEF_UBBiconNote(n) & """"
		End If
	Next
	TempStr = TempStr & ")" & VbCrLf

	TempStr = TempStr & "%" & chr(62) & VbCrLf
	
	ADODB_SaveToFile TempStr,"../../inc/UBBicon_Setup.ASP"
	If GBL_CHK_TempStr = "" Then
		Response.Write "<br><font color=Green class=GreenFont>2.成功完成设置！</font>"
	Else
		%><%=GBL_CHK_TempStr%><br>服务器不支持在线写入文件功能，请使用FTP等功能，将<font color=Red Class=RedFont>../../inc/UBBicon_Setup.ASP</font>文件替换成框中内容(注意备份)<p>
		<textarea name="fileContent" cols="80" rows="30" class=fmtxtra><%=Server.htmlencode(TempStr)%></textarea><%
		GBL_CHK_TempStr = ""
	End If

End Function%>