<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Ubbcode_Setup.asp"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Const MaxLinkNum = 100
initDatabase()
GBL_CHK_TempStr = ""
CheckSupervisorPass()

Dim Form_FiltrateBadWordString,Form_DEF_MaxUBBNumber,Form_DEF_UbbUnderwriteImages,Form_DEF_UbbDefaultEdit
Dim Form_DEF_UbbIconG,Form_DEF_UbbLinkData,Form_DEF_SafeUrl

GetDefaultValue()

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("UBB编码参数设置")
If GBL_CHK_Flag = 1 Then
	UbbcodeSetup()
Else
DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

Function UbbcodeSetup

%>
<form name="pollform3sdx" method="post" action="UbbcodeSetup.asp">
<input type="hidden" name="SubmitFlag" value=yes>
<p>
		设置：<a href=SiteSetup.asp>论坛常用参数</a> <a href=UploadSetup.asp>上传参数</a>
		<a href=../User/UserSetup.asp>用户注册参数</a>
		<span class=grayfont>UBB编码参数</span>
		<br><span class=grayfont>(下面为网站参数，请注意修改，错误的设置将会发生严重错误)<br><br>
		如果在设置后发现网站不能正常运行，请将LeadBBS最新版的inc/UbbcodeSetup.asp覆盖回去</span>
</p>
<%If Request.Form("SubmitFlag") <> "" Then
	CheckLinkValue()
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

Function CheckLinkValue

	GetFormValue()

End Function

Function DisplayDatabaseLink

		%>
		<table border=0 cellpadding=0 cellspacing=0 width="100%" class=frame_table>
		<tr>
			<td class=tdbox width=120>脏字过滤</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_FiltrateBadWordString" maxlength="5024" size="50" value="<%=htmlencode(Form_FiltrateBadWordString)%>"><span class=grayfont> <br>
			使用|符号分隔，脏字符自动替换为＊号</span></td>
		</tr>
		<tr>
			<td class=tdbox>表情数量</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_MaxUBBNumber" maxlength="3" size="10" value="<%=htmlencode(Form_DEF_MaxUBBNumber)%>">
			<br><span class=grayfont>(每表情符号最多允许显示数量，多出的不再编码为表情图片)</span></td>
		</tr>
		<tr>
			<td class=tdbox>签名图片</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_UbbUnderwriteImages value=0<%If Form_DEF_UbbUnderwriteImages = 0 Then%> checked<%End If%>></td><td>关闭</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_UbbUnderwriteImages value=1<%If Form_DEF_UbbUnderwriteImages = 1 Then%> checked<%End If%>></td><td>启用</td>
          		<td>&nbsp; (<span class=grayfont>是否允许图片作为签名</span>)</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>发帖模式</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_UbbDefaultEdit value=0<%If Form_DEF_UbbDefaultEdit = 0 Then%> checked<%End If%>></td><td>普通模式</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_UbbDefaultEdit value=1<%If Form_DEF_UbbDefaultEdit = 1 Then%> checked<%End If%>></td><td>高级模式</td>
          		</tr></table>
          		&nbsp; (<span class=grayfont>指定默认的发帖模式，高级模式允许在线编辑网页</span>)</td>
		</tr>
		<tr>
			<td class=tdbox width=50>表情分类</td>
			<td class=tdbox>
			<textarea cols=80 name=Form_DEF_UbbIconG style="width: 100%;height:110px; word-break: break-all;" class=fmtxtra><%If Form_DEF_UbbIconG <> "" Then Response.Write VbCrLf & Server.htmlEncode(Form_DEF_UbbIconG)%></textarea>
			<br/>
			使用单角单空格分隔，例如 经典表情 1 25 代表经典表情分类对应编号1-25,多分类用换行区分
			最多50个分类 最大数字<%=DEF_UBBiconNumber%></td>
		</tr>
		<tr>
			<td class=tdbox width=50>内容链接</td>
			<td class=tdbox>
			<textarea cols=180 name=Form_DEF_UbbLinkData style="width: 100%;height:220px; word-break: break-all;" class=fmtxtra><%If Form_DEF_UbbLinkData <> "" Then Response.Write VbCrLf & Server.htmlEncode(Form_DEF_UbbLinkData)%></textarea>
			<br/>
			使用单角单空格分隔，例如 LeadBBS http://www.leadbbs.com/ 代表将帖子中的所有leadbbs字符添加链接到http://www.leadbbs.com/ 注意字符的选择 否则替换会有所混乱
			<br/>最多50个项目</td>
			
		</tr>
		<tr>
			<td class=tdbox width=120>安全网址</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_SafeUrl" maxlength="5024" size="50" value="<%=htmlencode(Form_DEF_SafeUrl)%>"><span class=grayfont> <br>
			使用|符号分隔，注意网址只能包含1-2点号，例：|leadbbs.com|youbute.com|sina.com.cn|
			</span></td>
		</tr>
		</table>
		<%

End Function

Function GetDefaultValue

	Form_FiltrateBadWordString = FiltrateBadWordString
	Form_DEF_MaxUBBNumber = DEF_MaxUBBNumber
	Form_DEF_UbbDefaultEdit = DEF_UbbDefaultEdit
	Form_DEF_UbbUnderwriteImages = DEF_UbbUnderwriteImages
	Form_DEF_SafeUrl = DEF_SafeUrl
	
	Dim N,I
	Form_DEF_UbbLinkData = ""
	If isArray(DEF_UbbLinkData) and isArray(DEF_UbbLinkUrl) Then
		N = UBound(DEF_UbbLinkData,1)
		If UBound(DEF_UbbLinkUrl,1) < N Then N = UBound(DEF_UbbLinkUrl,1)
		For I = 0 to N
			Form_DEF_UbbLinkData = Form_DEF_UbbLinkData & DEF_UbbLinkData(I) & " " & DEF_UbbLinkUrl(I) & VbCrLf
		Next
	End If
	
	Form_DEF_UbbIconG = ""
	If isArray(DEF_UbbIconG) and isArray(DEF_UbbIconMax) and isArray(DEF_UbbIconMin) Then
		N = UBound(DEF_UbbIconG,1)
		If UBound(DEF_UbbIconMax,1) < N Then N = UBound(DEF_UbbIconMax,1)
		If UBound(DEF_UbbIconMin,1) < N Then N = UBound(DEF_UbbIconMin,1)
		For I = 0 to N
			Form_DEF_UbbIconG = Form_DEF_UbbIconG & DEF_UbbIconG(I) & " " & DEF_UbbIconMin(I) & " " & DEF_UbbIconMax(I) & VbCrLf
		Next
	End If

End Function

Function GetFormValue

	Form_FiltrateBadWordString = Trim(Request.Form("Form_FiltrateBadWordString"))
	Form_DEF_MaxUBBNumber = Trim(Request.Form("Form_DEF_MaxUBBNumber"))
	Form_DEF_UbbUnderwriteImages = Trim(Request.Form("Form_DEF_UbbUnderwriteImages"))
	Form_DEF_UbbDefaultEdit = Trim(Request.Form("Form_DEF_UbbDefaultEdit"))
	Form_DEF_UbbIconG = Trim(Request.Form("Form_DEF_UbbIconG"))
	Form_DEF_UbbLinkData = Trim(Request.Form("Form_DEF_UbbLinkData"))
	Form_DEF_SafeUrl = Trim(Request.Form("Form_DEF_SafeUrl"))

	If inStr(Form_FiltrateBadWordString,"""") or inStr(Form_FiltrateBadWordString,"%") Then GBL_CHK_TempStr = "脏字过滤不能包含有引号或百分号<br>" & VbCrLf
	If isNumeric(Form_DEF_MaxUBBNumber) = 0 Then GBL_CHK_TempStr = "表情数量必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_UbbUnderwriteImages) = 0 Then GBL_CHK_TempStr = "是否允许签名图片必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_UbbDefaultEdit) = 0 Then GBL_CHK_TempStr = "发帖模式必须为数字<br>" & VbCrLf
	If inStr(Form_DEF_SafeUrl,"""") or inStr(Form_DEF_SafeUrl,"%") Then GBL_CHK_TempStr = "安全网址列表不能包含有引号或百分号<br>" & VbCrLf
	
	Dim TempA,TempB,a,b,c,Num,N,aa,bb,cc,Counter
	' Upstream drops a well-formed 表情分类 line whose range exceeds DEF_UBBiconNumber without
	' saying so, and the shipped default is one of those (蘑菇点点 62 280 against a limit of 99,
	' with images only up to em100). Opening this page and pressing 提交 therefore deleted an
	' emoticon group silently. The line is still dropped — it points at images that do not
	' exist — but the admin is now told which one and why.
	Dim DroppedStr : DroppedStr = ""
	TempA = SplitLines(Form_DEF_UbbIconG)
	aa = ""
	bb = ""
	cc = ""
	Counter = 0
	If isArray(TempA) Then
		Num = Ubound(TempA,1)
		For N = 0 to Num
			TempB = Split(Trim(TempA(N))," ")
			If Ubound(TempB,1) = 2 Then
				a = TempB(0)
				b = TempB(1)
				c = TempB(2)
				If isNumeric(b) and isNumeric(c) Then
					b = Fix(cCur(b))
					c = Fix(cCur(c))
					If Not (c >= b and c <= DEF_UBBiconNumber and b <= DEF_UBBiconNumber) Then
						DroppedStr = DroppedStr & "<br>表情分类 <b>" & htmlencode(Trim(TempA(N))) &_
							"</b> 已忽略：编号必须在 1-" & DEF_UBBiconNumber & " 之间。"
					End If
					If c >= b and c <= DEF_UBBiconNumber and b <= DEF_UBBiconNumber Then
						a = Replace(a,"server","")
						a = Replace(a,"<" & "%","")
						a = Replace(a,"%" & ">","")
						If aa = "" Then
							aa = """" & Replace(a,"""","""""") & """"
						Else
							aa = aa & ",""" & Replace(a,"""","""""") & """"
						End If
						If bb = "" Then
							bb = b
						Else
							bb = bb & "," & b
						End If
						If cc = "" Then
							cc = c
						Else
							cc = cc & "," & c
						End If
						Counter = Counter + 1
					End If
				End If
			End If
		Next
		If aa <> "" Then
			aa = "DEF_UbbIconG = Array(" & aa & ")"
			bb = "DEF_UbbIconMin = Array(" & bb & ")"
			cc = "DEF_UbbIconMax = Array(" & cc & ")"
		End if
		Form_DEF_UbbIconG = "DEF_UbbIconGNum = " & Counter
		Form_DEF_UbbIconG = Form_DEF_UbbIconG & VbCrLf & aa & VbCrLf & bb & VbCrLf & cc
	Else
		Form_DEF_UbbIconG = "DEF_UbbIconGNum = 0"
	End If
	Form_DEF_UbbIconG = "Dim DEF_UbbIconG,DEF_UbbIconMax,DEF_UbbIconMin,DEF_UbbIconGNum" & VbCrLf & Form_DEF_UbbIconG
	
	
	TempA = Split(Form_DEF_UbbLinkData,VbCrLf)
	aa = ""
	bb = ""
	Counter = 0
	If isArray(TempA) Then
		Num = Ubound(TempA,1)
		For N = 0 to Num
			TempB = Split(Trim(TempA(N))," ")
			If Ubound(TempB,1) = 1 Then
				a = TempB(0)
				b = TempB(1)
				If a <> "" and b <> "" Then
						a = Replace(a,"<" & "%","")
						a = Replace(a,"%" & ">","")
						b = Replace(b,"server","")
						b = Replace(b,"<" & "%","")
						b = Replace(b,"%" & ">","")
						If aa = "" Then
							aa = """" & Replace(a,"""","""""") & """"
						Else
							aa = aa & ",""" & Replace(a,"""","""""") & """"
						End If
						If bb = "" Then
							bb = """" & Replace(b,"""","""""") & """"
						Else
							bb = bb & ",""" & Replace(b,"""","""""") & """"
						End If
						Counter = Counter + 1
				End If
			End If
		Next
		If aa <> "" Then
			aa = "DEF_UbbLinkData = Array(" & aa & ")"
			bb = "DEF_UbbLinkUrl = Array(" & bb & ")"
		End if
		Form_DEF_UbbLinkData = "DEF_UbbLinkNum = " & Counter
		Form_DEF_UbbLinkData = Form_DEF_UbbLinkData & VbCrLf & aa & VbCrLf & bb
	Else
		Form_DEF_UbbLinkData = "DEF_UbbLinkNum = 0"
	End If
	Form_DEF_UbbLinkData = "Dim DEF_UbbLinkData,DEF_UbbLinkUrl,DEF_UbbLinkNum" & VbCrLf & Form_DEF_UbbLinkData

End Function

Function MakeDataBaseLinkFile

	Dim n,TempStr
	TempStr = ""
	TempStr = TempStr & chr(60) & "%" & VbCrLf
	TempStr = TempStr & "const FiltrateBadWordString=" & Chr(34) & Replace(Form_FiltrateBadWordString,Chr(34),Chr(34) & Chr(34)) & Chr(34) & VbCrLf
	TempStr = TempStr & "const DEF_MaxUBBNumber = " & Form_DEF_MaxUBBNumber & VbCrLf
	TempStr = TempStr & "const DEF_UbbUnderwriteImages = " & Form_DEF_UbbUnderwriteImages & VbCrLf
	TempStr = TempStr & "const DEF_UbbDefaultEdit = " & Form_DEF_UbbDefaultEdit & VbCrLf
	
	TempStr = TempStr & Form_DEF_UbbIconG & VbCrLf
	TempStr = TempStr & Form_DEF_UbbLinkData & VbCrLf
	
	TempStr = TempStr & "const DEF_SafeUrl=" & Chr(34) & Replace(Form_DEF_SafeUrl,Chr(34),Chr(34) & Chr(34)) & Chr(34) & VbCrLf

	TempStr = TempStr & "%" & chr(62) & VbCrLf

	If DroppedStr <> "" Then Response.Write "<div class=alert>" & DroppedStr & "</div>"
	ADODB_SaveToFile TempStr,"../../inc/Ubbcode_Setup.asp"
	CALL Update_InsertSetupRID(1051,"inc/Ubbcode_Setup.asp",1,TempStr," and ClassNum=" & 1)
	
	If GBL_CHK_TempStr = "" Then
		Response.Write "<br><span class=greenfont>2.成功完成设置！</span>"
	Else
		%><%=GBL_CHK_TempStr%><br>服务器不支持在线写入文件功能，请使用FTP等功能，将<span class=redfont>../../inc/Ubbcode_Setup.asp</span>文件替换成框中内容(注意备份)<p>
		<textarea name="fileContent" cols="80" rows="30" class=fmtxtra><%=Server.htmlencode(TempStr)%></textarea><%
		GBL_CHK_TempStr = ""
	End If

End Function%>