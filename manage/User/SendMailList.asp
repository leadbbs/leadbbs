<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<!--#include file="../../User/inc/Mail_fun.asp"-->
<%
server.scripttimeout=99999
DEF_BBS_HomeUrl = "../../"
initDatabase()
GBL_CHK_TempStr = ""
checkSupervisorPass()

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("邮件")

Dim Email,Topic,MailBody,MailList

If GBL_CHK_Flag = 1 and GBL_CHK_TempStr = "" Then
	' README §51: bare Request.QueryString is an Object; this comparison was always False.
	If (Request.QueryString & "") = "MailList" Then
		GetMailList()
	Else
		SendMailListForm()
		frame_BottomInfo()
	End If
Else
	DisplayLoginForm()
	frame_BottomInfo()
	
End If
closeDataBase()

Function SendMailListForm

	Dim Rs,Num
	Set Rs = LDExeCute("Select count(*) from LeadBBS_User",0)
	If Not Rs.Eof Then
		Num = Rs(0)
		If isNull(Num) Then Num = 0
		Num = cCur(Num)
	Else
		Num = 0
	End If
	Rs.Close
	Set Rs = Nothing
	
	Dim submitflag
	MailBody = Request.Form("MailBody")
	Email = Request.Form("Email")
	Topic = Request.Form("Topic")
	MailList = Request.Form("MailList")
	submitflag = Left(Request.Form("submitflag"),10)
	
	If submitflag = "1" Then
		If Email = "" or Len(Email) > 150 or inStr(Email,"@") = 0 Then
			Response.Write "<br><br><b><font color=red>邮箱地址错误，最长不能超过150个字！</font></b>" & VbCrLf
			submitflag = ""
		End If
		If Topic = "" or Len(Topic) > 250 Then
			Response.Write "<br><br><b><font color=red>邮件标题必须填写并且不能超过250个字！</font></b>" & VbCrLf
			submitflag = ""
		End If
		If MailBody = "" or Len(MailBody) > DEF_MaxTextLength Then
			Response.Write "<br><br><b><font color=red>发送邮件内容必须填写并且不能超过" & DEF_MaxTextLength & "个字！</font></b>" & VbCrLf
			submitflag = ""
		End If
	End If

	If submitflag = "1" then
		submitflag = 2
		%><form action=SendMailList.asp id=fm1 name=fm1 method=post><p style="font-size:9pt"><br>
			<b style="font-size:9pt"><font color=ff0000 class=redfont>群发邮件内容如下：点击第一个按钮立即开始发送，第二个按钮重新返回编辑</font></b><br><br>
			<p style="font-size:9pt">
			<b>接收邮箱列表：</b><%
					If MailList = "" Then
						Response.Write "所有用户"
					Else
						Response.Write htmlencode(MailList)
					End If%><br><br>
			<b>接收邮箱列表：</b><%=htmlencode(MailList)%><br><br>
			<b>发送使用邮箱：</b><%=htmlencode(Email)%><br><br>
			<b>发送邮件标题：</b><%=htmlencode(Topic)%><br><br>
			<b>发送邮件内容：</b><br><br><br><%=MailBody%><br><br>
			<input name=MailList maxlength=224 size=54 value="<%=htmlencode(MailList)%>" class=fminpt type=hidden><br>
			<input name=Email maxlength=224 size=54 value="<%=htmlencode(Email)%>" class=fminpt type=hidden><br>
			<input name=Topic maxlength=224 size=54 value="<%=htmlencode(Topic)%>" class=fminpt type=hidden><br>
			<input name=MailBody value="<%If MailBody <> "" Then Response.Write VbCrLf & htmlEncode(MailBody)%>" type=hidden>
			<input name=submitflag value="<%=submitflag%>" type=hidden><br><br>
			<input type=button value="点击这里开始发送" class=fmbtn onclick="javascript:document.all.fm1.submitflag.value=2;document.all.fm1.submit();" class=fmbtn>
			<input type=button value="点击这里返回编辑" class=fmbtn onclick="javascript:document.all.fm1.submitflag.value=0;document.all.fm1.submit();" class=fmbtn>
			</form>
		<%
		frame_BottomInfo()
		
	ElseIf submitflag = "2" then
		If DEF_BBS_EmailMode < 1 and DEF_BBS_EmailMode > 3 Then
			Response.Write "您的论坛不支持邮件发送．"
			frame_BottomInfo()
			
		Else
			If MailList = "" Then
				SendMailList()
			Else
				SendMailList2()
			End If
		End If
	Else
		submitflag = 1
		%><form action=SendMailList.asp id=fm1 name=fm1 style="font-size:9pt" method=post><br>
			<div class=alert>注意：</div>
			<ol class=listli>
			<li>请在框中填写邮件内容，邮件内容必须为HTML代码，一些图片或其它文件请使用链接．</li>
			<li>发送程序要求一次性完全执行完毕，如果出现错误联系官方人员</li>
			<li>共有<%=Num%>个客户待发送，发送时间有可能非常漫长，浏览器请不要刷新重复执行</li>
			<li>开始发送时有进度条，显示当前的发送进度</li>
			<li>提交后显示当前邮件样式，需要再次确认后才能开始发送</li>
			<li>注意邮件的标题先显示对方公司名称，再在逗号后显示你填写的标题</li>
			<li>不填写接收人表示发送给所有的用户</li>
			</ol>
			<div class=frametitle>填写邮件信息</div>
			<table border=0 cellpadding=0 cellspacing=0 width="100%" class=frame_table>
			<tr>
			<td class=tdbox width=120>接收邮箱列表：</td><td class=tdbox><input name=MailList maxlength=2224 size=44 value="<%=htmlencode(MailList)%>" class=fminpt> <span class=note>逗号分隔 不填则发给所有用户</span></td>
			<tr><td class=tdbox>发送使用邮箱：</td><td class=tdbox><input name=Email maxlength=224 size=44 value="<%=htmlencode(Email)%>" class=fminpt> <span class=note>退回或发送使用的邮箱 不一定有效</span>
			<tr><td class=tdbox>发送邮件标题：</td><td class=tdbox><input name=Topic maxlength=224 size=44 value="<%=htmlencode(Topic)%>" class=fminpt> <span class=note>在标题前自动加入用户名，用逗号分隔</span>
			<tr><td class=tdbox>发送邮件内容：<br><span class=note>必须使用HTML<br>代码</span></td><td class=tdbox>
			<textarea cols=53 name=MailBody rows=16 class=fmtxtra><%If MailBody <> "" Then Response.Write VbCrLf & Server.htmlEncode(MailBody)%></textarea>
			<input name=submitflag value="<%=submitflag%>" type=hidden><br><br>
			<input type=submit value="下一步 &lt;&lt; 点击开始预览邮件内容" onclick="javascript:document.all.fm1.submit();" class=fmbtn>
			</td></tr></table></form>
			<br />
			<div class=frameline><a href=SendMailList.asp?MailList><b><span class=bluefont>点击获取邮件列表</span></b></a></div>
			<div class=frameline>
			获取邮件列表依用户量不同，需要不同的时间。当用户量超过1000时，消耗资源很大，为维护服务器稳定运行及虚拟主机其它用户的利益，<span class=redfont>勿轻易使用此项功能</span>。
			如果用户量过大，将输出大量内容，建议使用另存为下载此网页。
			</div>
			
		<%
		frame_BottomInfo()
		
	End If

End Function

Function SendMailList

	'Response.Clear
	Dim TempAT,T
	Dim NowID,EndFlag,SQL,Rs
	NowID = 0
	EndFlag = 0

	Dim RootMaxID,RootMinID,ChildNum
	Dim N,GetData

	Dim RecordCount,CountIndex
	SQL = "Select count(*) from LeadBBS_User"
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		RecordCount = 0
	Else
		RecordCount = Rs(0)
		If isNull(RecordCount) Then RecordCount = 0
		RecordCount = ccur(RecordCount)
	End If
	Rs.Close
	Set Rs = Nothing
	If RecordCount < 1 Then RecordCount = 1
	CountIndex = 0
	%>
	<p style="font-size:9pt">下面开始群发邮件，共有<%=RecordCount%>个地址待处理

	<table width="400" border="0" cellspacing="1" cellpadding="1">
		<tr> 
			<td bgcolor=000000>
	<table width="400" border="0" cellspacing="0" cellpadding="1">
		<tr> 
			<td bgcolor=ffffff height=9><img src=../../images/vote.gif width=0 height=16 id=img1 name=img1 align=middle></td></tr></table>
	</td></tr></table> <span id=txt1 name=txt1 style="font-size:9pt">0</span><span style="font-size:9pt">%</span>
	<script>window.scroll(0,65535);</script>
	<%
	frame_BottomInfo()
	
	Response.Flush
	'on error resume next
	Do while EndFlag = 0
		SQL = sql_select("Select ID,mail,UserName from LeadBBS_User where ID>" & NowID & " order by ID ASC",1000)
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			EndFlag = 1
			Rs.Close
			Set Rs = Nothing
			Exit Do
		Else
			GetData = Rs.GetRows(-1)
			Rs.Close
			Set Rs = Nothing
		End If
		For N = 0 to Ubound(GetData,2)
			NowID = GetData(0,n)
			CountIndex = CountIndex + 1
			If (CountIndex mod 20) = 0 Then
				Response.Write "<script>img1.width=" & Fix((CountIndex/RecordCount) * 400) & ";" & VbCrLf
				Response.Write "txt1.innerHTML=""" & FormatNumber(CountIndex/RecordCount*100,4,-1) & """;" & VbCrLf
				Response.Write "img1.title=""(" & CountIndex & ")"";</script>" & VbCrLf
				Response.Flush
			End If
			If inStr(GetData(1,n) & "","@") > 0 Then
				If GetData(2,n) <> "" Then GetData(2,n) = GetData(2,n) & ","
				Call SendMail(GetData(1,n),GetData(2,n) & Topic)
			End If
		Next
	Loop
	%>
	<script>img1.width=400;
	txt1.innerHTML="100";</script>
	<%

End Function


Function SendMailList2

	'Response.Clear
	Dim TempAT,T
	Dim NowID,EndFlag,SQL,Rs
	NowID = 0
	EndFlag = 0
	
	Dim RootMaxID,RootMinID,ChildNum
	Dim N,GetData

	Dim RecordCount,CountIndex
	
	GetData = Split(MailList,",")
	RecordCount = Ubound(GetData,1) + 1
	If RecordCount < 1 Then RecordCount = 1
	CountIndex = 0
	%>
	<p style="font-size:9pt">下面开始群发邮件，共有<%=RecordCount%>个地址待处理

	<table width="400" border="0" cellspacing="1" cellpadding="1">
		<tr> 
			<td bgcolor=000000>
	<table width="400" border="0" cellspacing="0" cellpadding="1">
		<tr> 
			<td bgcolor=ffffff height=9><img src=../../images/vote.gif width=0 height=16 id=img1 name=img1 align=middle></td></tr></table>
	</td></tr></table> <span id=txt1 name=txt1 style="font-size:9pt">0</span><span style="font-size:9pt">%</span>
	<script>window.scroll(0,65535);</script>
	<%
	frame_BottomInfo()
	
	Response.Flush
	For N = 0 to RecordCount - 1
		NowID = N
		CountIndex = CountIndex + 1
		If (CountIndex mod 20) = 0 Then
			Response.Write "<script>img1.width=" & Fix((CountIndex/RecordCount) * 400) & ";" & VbCrLf
			Response.Write "txt1.innerHTML=""" & FormatNumber(CountIndex/RecordCount*100,4,-1) & """;" & VbCrLf
			Response.Write "img1.title=""(" & CountIndex & ")"";</script>" & VbCrLf
			Response.Flush
		End If
		If inStr(GetData(n) & "","@") > 0 Then
			Call SendMail(GetData(n),Topic)
		End If
	Next
	%>
	<script>img1.width=400;
	txt1.innerHTML="100";</script>
	<%

End Function

Function SendMail(RvEmail,RvTopic)

	Select Case DEF_BBS_EmailMode
		Case 1: If SendEasyMail(RvEmail,RvTopic,MailBody,MailBody) = 1 Then
					'Response.Write "<br><br>资料成功发送到您的注册邮箱！"
				Else
					'Response.Write "<br><br>论坛未正确设置邮件发送，资料发送失败！"
				End If
		Case 2: If SendJmail(RvEmail,RvTopic,MailBody) = 1 Then
					'Response.Write "<br><br>资料成功发送到您的注册邮箱！"
				Else
					'Response.Write "<br><br>论坛未正确设置邮件发送，资料发送失败2！"
				End If
		Case 3: Response.Write "<br><br>群发邮件不支持使用CDO邮件发送方式发送！"
		Case Else:  Response.Write "<br><br>论坛不支持邮件发送或未开启！"
	End Select

End Function

Sub GetMailList

	Response.Clear
	Response.ContentType = "text/plain"
	Dim Rs,LoopN
	LoopN = 0
	Set Rs = LDExeCute("select mail from LeadBBS_User where Mail <> ''",0)
	If Not Rs.Eof Then Response.Write RsGetString(Rs,"","" & VbCrLf & "","")
	Rs.Close
	Set Rs = Nothing

End Sub%>