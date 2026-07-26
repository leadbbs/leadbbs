<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Upload_Setup.asp"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Const MaxLinkNum = 100
initDatabase()
GBL_CHK_TempStr = ""
CheckSupervisorPass()

Dim Form_DEF_BBS_UploadPhotoUrl,Form_DEF_EnableDotNetUpload,Form_DEF_UploadFileType
Dim Form_DEF_FileMaxBytes,Form_DEF_FaceMaxBytes
Dim Form_DEF_UploadSpendPoints,Form_DEF_UploadDeletePoints,Form_DEF_UploadOneDayMaxNum,Form_DEF_UploadFaceNeedPoints
Dim Form_DEF_UploadVersionString,Form_DEF_Upd_SpendFlag,Form_DEF_UploadOnceNum,Form_DEF_UploadSwidth,Form_DEF_UploadSheight,Form_DEF_DownSpend

GetDefaultValue()

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("论坛上传参数设置")
If GBL_CHK_Flag=1 Then
	UploadSetup()
Else
DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

Function UploadSetup

%>
<form name="pollform3sdx" method="post" action="UploadSetup.asp">
<input type="hidden" name="SubmitFlag" value=yes>
<p>
		设置：<a href=SiteSetup.asp>论坛常用参数</a> <span class=grayfont>上传参数</span>
		<a href=../User/UserSetup.asp>用户注册参数</a>
		<a href=UbbcodeSetup.asp>UBB编码参数</a>
		<br><span class=grayfont>(下面为网站参数，请注意修改，错误的设置将会发生严重错误)<br><br>
		如果在设置后发现网站不能正常运行，请将LeadBBS最新版的inc/Upload_Setup.asp覆盖回去</span>
</p>
<%If Request.Form("SubmitFlag") <> "" Then
	GetFormValue()
End If%>
<b><span class=redfont><%=GBL_CHK_TempStr%></span></b>
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
</p>
<input type=submit name=提交 value=提交 class=fmbtn>
<input type=reset name=取消 value=取消 class=fmbtn>
</form>
<%

End Function

Sub DisplayDatabaseLink

		%>
		<table border=0 cellpadding=0 cellspacing=0 width="100%" class=frame_table>
		<tr>
			<td class=tdbox width=100>上传目录</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_BBS_UploadPhotoUrl" maxlength="50" size="30" value="<%=htmlencode(Form_DEF_BBS_UploadPhotoUrl)%>"><span class=grayfont> 默认为images/upload/，相对于论坛根目录而言</span></td>
		</tr>
		<tr>
			<td class=tdbox>上传方式</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_EnableDotNetUpload value=0<%If Form_DEF_EnableDotNetUpload = 0 Then%> checked<%End If%>></td><td>FileUp组件上传</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableDotNetUpload value=1<%If Form_DEF_EnableDotNetUpload = 1 Then%> checked<%End If%>></td><td>使用.Net上传</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableDotNetUpload value=2<%If Form_DEF_EnableDotNetUpload = 2 Then%> checked<%End If%>></td><td>使用无组件</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>上传类型</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_UploadFileType" maxlength="1024" size="50" value="<%=htmlencode(Form_DEF_UploadFileType)%>"><span class=grayfont><br>定义上传所允许的文件类型，扩展名必须小写，用冒号分隔</span></td>
		</tr>
		<tr>
			<td class=tdbox>文件大小</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_FileMaxBytes" maxlength="12" size="10" value="<%=htmlencode(Form_DEF_FileMaxBytes)%>"><span class=grayfont>(自定义允许上传文件的最大值，单位字节)</span></td>
		</tr>
		<tr>
			<td class=tdbox>头像大小</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_FaceMaxBytes" maxlength="8" size="10" value="<%=htmlencode(Form_DEF_FaceMaxBytes)%>"><span class=grayfont>(自定义允许上传头像的最大值，单位字节，设为零表示禁止)</span></td>
		</tr>
		<tr>
			<td class=tdbox>上传花费<%=DEF_PointsName(0)%></td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_UploadSpendPoints" maxlength="14" size="10" value="<%=htmlencode(Form_DEF_UploadSpendPoints)%>"><span class=grayfont><br>用户每传一个附件所消耗<%=DEF_PointsName(0)%>，正数为消耗值，负数为奖励值，零为不变</span></td>
		</tr>
		<tr>
			<td class=tdbox>删除花费<%=DEF_PointsName(0)%></td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_UploadDeletePoints" maxlength="14" size="10" value="<%=htmlencode(Form_DEF_UploadDeletePoints)%>"><span class=grayfont><br>用户每删除一个自己上传的附件所消耗<%=DEF_PointsName(0)%>，正数为消耗值，负数为奖励值，零为不变(必须自己删除自己的附件才有效)</span></td>
		</tr>
		<tr>
			<td class=tdbox>花费是否影响版主</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_Upd_SpendFlag value=0<%If Form_DEF_Upd_SpendFlag = 0 Then%> checked<%End If%>></td><td>不影响</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_Upd_SpendFlag value=1<%If Form_DEF_Upd_SpendFlag = 1 Then%> checked<%End If%>></td><td>根据设定影响</td>
          		<td><span class=grayfont><br>此项设定上传及删除附件,是否影响<%=DEF_PointsName(8)%>及以上权限人员的<%=DEF_PointsName(0)%></span>
          		</tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>每日上传数量</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_UploadOneDayMaxNum" maxlength="14" size="10" value="<%=htmlencode(Form_DEF_UploadOneDayMaxNum)%>"><span class=grayfont><br>限制用户每天允许上传的最多附件个数，不能设置大于100，设置为0表示无限制</span></td>
		</tr>
		<tr>
			<td class=tdbox>上传头像需要<%=DEF_PointsName(0)%></td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_UploadFaceNeedPoints" maxlength="14" size="10" value="<%=htmlencode(Form_DEF_UploadFaceNeedPoints)%>"><span class=grayfont><br>限制用户只有<%=DEF_PointsName(0)%>值大于此值才能上传论坛头像</span></td>
		</tr>
		<tr>
			<td class=tdbox>水印生成</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_UploadVersionString" maxlength="50" size="30" value="<%=htmlencode(Form_DEF_UploadVersionString)%>"><span class=grayfont> 在上传的图片附件上面自动生成水印文字</span></td>
		</tr>
		<tr>
			<td class=tdbox>单帖最多允许附件</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_UploadOnceNum" maxlength="14" size="10" value="<%=htmlencode(Form_DEF_UploadOnceNum)%>"><span class=grayfont><br>在一次编辑或发表中,允许同时上传的最多附件数量</span></td>
		</tr>
		<tr>
			<td class=tdbox>图片附件缩略高宽</td>
			<td class=tdbox>
			最大缩图宽度 <input class=fminpt type="text" name="Form_DEF_UploadSwidth" maxlength="14" size="10" value="<%=htmlencode(Form_DEF_UploadSwidth)%>">
			最大缩图高度 <input class=fminpt type="text" name="Form_DEF_UploadSheight" maxlength="14" size="10" value="<%=htmlencode(Form_DEF_UploadSheight)%>">
			<span class=grayfont><br>需要条件: 允许图像组件. 单位: 象素<br>在上传中,将自动根本图片大小产生最符合此设定要求缩略图</span></td>
		</tr>
		</table>
		<%

End Sub

Sub GetDefaultValue

	Form_DEF_BBS_UploadPhotoUrl = DEF_BBS_UploadPhotoUrl
	Form_DEF_EnableDotNetUpload = DEF_EnableDotNetUpload
	Form_DEF_UploadFileType = DEF_UploadFileType	
	Form_DEF_FileMaxBytes = DEF_FileMaxBytes
	Form_DEF_FaceMaxBytes = DEF_FaceMaxBytes
	Form_DEF_UploadSpendPoints = DEF_UploadSpendPoints
	Form_DEF_UploadDeletePoints = DEF_UploadDeletePoints
	Form_DEF_UploadOneDayMaxNum = DEF_UploadOneDayMaxNum
	Form_DEF_UploadFaceNeedPoints = DEF_UploadFaceNeedPoints
	Form_DEF_UploadVersionString = DEF_UploadVersionString
	Form_DEF_Upd_SpendFlag = DEF_Upd_SpendFlag
	Form_DEF_UploadOnceNum = DEF_UploadOnceNum
	Form_DEF_UploadSwidth = DEF_UploadSwidth
	Form_DEF_UploadSheight = DEF_UploadSheight

End Sub

Sub GetFormValue

	Form_DEF_BBS_UploadPhotoUrl = Trim(Request.Form("Form_DEF_BBS_UploadPhotoUrl"))
	Form_DEF_EnableDotNetUpload = Trim(Request.Form("Form_DEF_EnableDotNetUpload"))
	Form_DEF_UploadFileType = Trim(Request.Form("Form_DEF_UploadFileType"))
	Form_DEF_FileMaxBytes = Trim(Request.Form("Form_DEF_FileMaxBytes"))
	Form_DEF_FaceMaxBytes = Trim(Request.Form("Form_DEF_FaceMaxBytes"))
	Form_DEF_UploadSpendPoints = Trim(Request.Form("Form_DEF_UploadSpendPoints"))
	Form_DEF_UploadDeletePoints = Trim(Request.Form("Form_DEF_UploadDeletePoints"))
	Form_DEF_UploadOneDayMaxNum = Trim(Request.Form("Form_DEF_UploadOneDayMaxNum"))
	Form_DEF_UploadFaceNeedPoints = Trim(Request.Form("Form_DEF_UploadFaceNeedPoints"))
	Form_DEF_UploadVersionString = Trim(Request.Form("Form_DEF_UploadVersionString"))
	Form_DEF_Upd_SpendFlag = Trim(Request.Form("Form_DEF_Upd_SpendFlag"))
	
	Form_DEF_UploadOnceNum = Trim(Request.Form("Form_DEF_UploadOnceNum"))
	Form_DEF_UploadSwidth = Trim(Request.Form("Form_DEF_UploadSwidth"))
	Form_DEF_UploadSheight = Trim(Request.Form("Form_DEF_UploadSheight"))

	If inStr(Form_DEF_BBS_UploadPhotoUrl,"""") or inStr(Form_DEF_BBS_UploadPhotoUrl,"%") Then GBL_CHK_TempStr = "上传目录不能包含有引号或百分号<br>" & VbCrLf
	If isNumeric(Form_DEF_EnableDotNetUpload) = 0 Then GBL_CHK_TempStr = "上传方式必须为数字<br>" & VbCrLf
	If inStr(Form_DEF_UploadFileType,"""") or inStr(Form_DEF_UploadFileType,"%") Then GBL_CHK_TempStr = "上传类型不能包含有引号或百分号<br>" & VbCrLf
	Form_DEF_UploadFileType = Replace(Replace(Trim(LCase(Form_DEF_UploadFileType))," ",""),"?","")
	
	Dim FobType,N
	FobType = Array("htw","ida","asp","asa","idq","cer","cdx","htr","idc","shtm","shtml","stm","printer","asax","ascx","ashx","asmx","aspx","axd","vsdisco","rem","soap","config","cs","csproj","vb","vbproj","webinfo","licx","resx","resources","php","cgi")
	For N = 0 to Ubound(FobType)
		If inStr(":" & Form_DEF_UploadFileType & ":",":." & FobType(N) & ":") Then
			GBL_CHK_TempStr = "为了安全，上传类型不能使用扩展名 " & FobType(N) & " ！<br>" & VbCrLf
			Exit Sub
		End If
	Next
	If isNumeric(Form_DEF_FileMaxBytes) = 0 Then GBL_CHK_TempStr = "上传文件大小必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_FaceMaxBytes) = 0 Then GBL_CHK_TempStr = "上传头像大小必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_UploadSpendPoints) = 0 Then GBL_CHK_TempStr = "上传花费" & DEF_PointsName(0) & "值必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_UploadDeletePoints) = 0 Then GBL_CHK_TempStr = "删除花费" & DEF_PointsName(0) & "值必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_UploadOneDayMaxNum) = 0 Then GBL_CHK_TempStr = "每日上传附件数量必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_UploadFaceNeedPoints) = 0 Then GBL_CHK_TempStr = "上传头像需要" & DEF_PointsName(0) & "必须为数字<br>" & VbCrLf
	If inStr(Form_DEF_UploadVersionString,"""") or inStr(Form_DEF_UploadVersionString,"%") Then GBL_CHK_TempStr = "上传文件水印标识不能包含有引号或百分号<br>" & VbCrLf
	If isNumeric(Form_DEF_Upd_SpendFlag) = 0 Then GBL_CHK_TempStr = "花费是否影响" & DEF_PointsName(8) & "" & DEF_PointsName(0) & "必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_UploadOnceNum) = 0 Then GBL_CHK_TempStr = "单帖最多允许附件须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_UploadSwidth) = 0 Then GBL_CHK_TempStr = "图片附件缩略宽须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_UploadSheight) = 0 Then GBL_CHK_TempStr = "图片附件缩略高须为数字<br>" & VbCrLf

End Sub

Sub MakeDataBaseLinkFile

	Dim n,TempStr
	TempStr = ""
	TempStr = TempStr & chr(60) & "%" & VbCrLf
	TempStr = TempStr & "const DEF_BBS_UploadPhotoUrl=" & Chr(34) & Replace(Form_DEF_BBS_UploadPhotoUrl,Chr(34),Chr(34) & Chr(34)) & Chr(34) & VbCrLf
	TempStr = TempStr & "const DEF_EnableDotNetUpload = " & Form_DEF_EnableDotNetUpload & VbCrLf
	TempStr = TempStr & "const DEF_UploadFileType=" & Chr(34) & Replace(Form_DEF_UploadFileType,Chr(34),Chr(34) & Chr(34)) & Chr(34) & VbCrLf
	TempStr = TempStr & "Const DEF_FileMaxBytes = " & Form_DEF_FileMaxBytes & VbCrLf
	TempStr = TempStr & "Const DEF_FaceMaxBytes = " & Form_DEF_FaceMaxBytes & VbCrLf
	TempStr = TempStr & "Const DEF_UploadSpendPoints = " & Form_DEF_UploadSpendPoints & VbCrLf
	TempStr = TempStr & "Const DEF_UploadDeletePoints = " & Form_DEF_UploadDeletePoints & VbCrLf
	TempStr = TempStr & "Const DEF_UploadOneDayMaxNum = " & Form_DEF_UploadOneDayMaxNum & VbCrLf
	TempStr = TempStr & "Const DEF_UploadFaceNeedPoints = " & Form_DEF_UploadFaceNeedPoints & VbCrLf
	TempStr = TempStr & "const DEF_UploadVersionString=" & Chr(34) & Replace(Form_DEF_UploadVersionString,Chr(34),Chr(34) & Chr(34)) & Chr(34) & VbCrLf
	TempStr = TempStr & "const DEF_Upd_SpendFlag = " & Form_DEF_Upd_SpendFlag & VbCrLf
	TempStr = TempStr & "const DEF_UploadOnceNum = " & Form_DEF_UploadOnceNum & VbCrLf
	TempStr = TempStr & "const DEF_UploadSwidth = " & Form_DEF_UploadSwidth & VbCrLf
	TempStr = TempStr & "const DEF_UploadSheight = " & Form_DEF_UploadSheight & VbCrLf

	TempStr = TempStr & "%" & chr(62) & VbCrLf
	
	ADODB_SaveToFile TempStr,"../../inc/Upload_Setup.asp"
	CALL Update_InsertSetupRID(1051,"inc/Upload_Setup.ASP",3,TempStr," and ClassNum=" & 3)
	If GBL_CHK_TempStr = "" Then
		Response.Write "<br><span class=greenfont>2.成功完成设置！</span>"
	Else
		%><%=GBL_CHK_TempStr%><br>服务器不支持在线写入文件功能，请使用FTP等功能，将<span class=redfont>../../inc/Upload_Setup.asp</span>文件替换成框中内容(注意备份)<p>
		<textarea name="fileContent" cols="80" rows="30" class=fmtxtra><%=Server.htmlencode(TempStr)%></textarea><%
		GBL_CHK_TempStr = ""
	End If

End Sub%>