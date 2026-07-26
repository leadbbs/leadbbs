<%		
function checkInstalled

	dim filestr
	filestr = ADODB_LoadFile(DEF_BBS_HomeUrl & "inc/BBSSetup.asp")
	if inStr(filestr,"Response.Redirect ""install/default.asp""") < 1 then
		printline("<span style='color:white'><b>论坛安装已锁定，若要重新安装请上传替换inc/BBSSetup.asp文件.</b></span>")
		checkInstalled = true
	else
		checkInstalled = false
	end if

end function

sub install_head
%>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"  xml:lang="zh-CN" lang="zh-CN">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="description" content="LeadBBS 安装" />
	<title>
		LeadBBS 9.0 安装
	</title>
	<link rel="stylesheet" id="css" type="text/css" href="scripts/install.css" title="cssfile" />
	<script src="../inc/js/jquery.js" type="text/javascript"></script>
	
	<script type="text/JavaScript">
	$(window).resize(function(){
	 $('.area').css({
	  position:'absolute',
	  left: (($(window).width() - $('.area').outerWidth())/2)<0?0:(($(window).width() - $('.area').outerWidth())/2),
	   top: (($(window).height() - $('.area').outerHeight())/2 + $(document).scrollTop())<0?0:(($(window).height() - $('.area').outerHeight())/2 + $(document).scrollTop())
	 });
	});
	//初始化函数
	</script>
	
</head>

<body id="body">

<%end sub

sub install_bottom
%>

	<script type="text/JavaScript">
	$(window).resize();
	</script>
	</div>
	</body>
	</html>
<%
end sub

sub install_step
%>
	<div class="install_title">LeadBBS 9.0安装向导</div>
	<div class="install_step">
	<a href="javascript:;" id="step1"<%If Step >=0 then response.write " class=""on"""%>>一 开始</a>
	<a href="javascript:;" id="step2"<%If Step >=2 then response.write " class=""on"""%>>二 安装检测</a>
	<a href="javascript:;" id="step3"<%If Step >=3 then response.write " class=""on"""%>>三 配置数据库</a>
	<a href="javascript:;" id="step4"<%If Step >=4 then response.write " class=""on"""%>>四 配置管理</a>
	<a href="javascript:;" id="step5"<%If Step >=5 then response.write " class=""on"""%>>五 完成安装</a>
	</div>
<%
end sub

sub install_contenthead
%>


<div class="area">
<div id="wrap">
  <div id="subwrap">
   <div id="content"><div class="contents">

<%
end sub

sub install_contentbottom
%>

 	</div>
  </div>
 </div>
</div>
<%

end sub

Function toNum(s,default)

	if isNumeric(s) = 0 Then
		toNum = default
	else
		toNum = ccur(s)
	end if

End Function

Function CheckObjInstalled(strClassString,w)

	On Error Resume Next
	Dim Temp
	Err = 0
	Dim TmpObj
	Set TmpObj = Server.CreateObject(strClassString)
	Temp = Err
	If Temp = 0 Then
		CheckObjInstalled = True
		if w = 1 then Response.Write strClassString & "：<font color=green class=greenfont>√</font>"
	ElseIf Temp = -2147221005 Then
		Response.Write strClassString & "：<font color=red class=redfont>组件未安装</font>"
		if w = 1 then CheckObjInstalled = False
	ElseIf Temp = -2147221477 Then
		if w = 1 then Response.Write strClassString & "：<font color=green class=greenfont>√支持此组件</font>"
		CheckObjInstalled = True
	ElseIf Temp = 1 Then
		if w = 1 then Response.Write strClassString & "：<font color=red>×未知的错误，组件可能未正确安装</font>"
		CheckObjInstalled = False
	End If
	Err.Clear
	Set TmpObj = Nothing
	Err = 0

End Function

Function ADODB_LoadFile(ByVal File)

	On Error Resume Next
	Dim objStream,FSFlag,fs,WriteFile
	FSFlag = 1
	If DEF_FSOString <> "" Then
		Set fs = Server.CreateObject(DEF_FSOString)
		If Err Then
			FSFlag = 0
			Err.Clear
			Set fs = Nothing
		End If
	Else
		FSFlag = 0
	End If

	If FSFlag = 1 Then
		Set WriteFile = fs.OpenTextFile(Server.MapPath(File),1,True)
		If Err Then
			GBL_CHK_TempStr = "<br>读取文件失败：" & err.description & "<br>其它可能：确定是否对此文件有读取权限."
			err.Clear
			Set Fs = Nothing
			Exit Function
		End If
		If Not WriteFile.AtEndOfStream Then
			ADODB_LoadFile = WriteFile.ReadAll
			If Err Then
				GBL_CHK_TempStr = "读取文件失败：<p>" & err.description & "</p> 其它可能：确定是否对此文件有读取权限."
				err.Clear
				Set Fs = Nothing
				Exit Function
			End If
		End If
		WriteFile.Close
		Set Fs = Nothing
	Else
		Set objStream = Server.CreateObject("ADODB.Stream")
		If Err.Number=-2147221005 Then 
			GBL_CHK_TempStr = "您的主机不支持ADODB.Stream，无法完成操作，请手工进行"
			Err.Clear
			Set objStream = Nothing
			Exit Function
		End If
		With objStream
			.Type = 2
			.Mode = 3
			.Open
			.LoadFromFile Server.MapPath(File)
			.Charset = "utf-8"
			.Position = 2
			ADODB_LoadFile = .ReadText
			.Close
		End With
		Set objStream = Nothing
	End If
	If Err Then
		GBL_CHK_TempStr = "错误信息：<p>" & err.description & "</p>其它可能：确定是否对此文件有读取权限."
		err.Clear
		Set Fs = Nothing
		Exit Function
	End If

End Function

'存储内容到文件
Sub ADODB_SaveToFile(ByVal strBody,ByVal File)

	On Error Resume Next
	Dim objStream,FSFlag,fs,WriteFile
	FSFlag = 1
	If DEF_FSOString <> "" Then
		Set fs = Server.CreateObject(DEF_FSOString)
		If Err Then
			FSFlag = 0
			Err.Clear
			Set fs = Nothing
		End If
	Else
		FSFlag = 0
	End If
	If FSFlag = 1 Then
		Set WriteFile = fs.CreateTextFile(Server.MapPath(File),True)
		WriteFile.Write strBody
		WriteFile.Close
		Set Fs = Nothing
	Else
		Set objStream = Server.CreateObject("ADODB.Stream")
		If Err.Number=-2147221005 Then 
			GBL_CHK_TempStr = "您的主机不支持ADODB.Stream，无法完成操作，请手工进行"
			Err.Clear
			Set objStream = Nothing
			Exit Sub
		End If
		With objStream
			.Type = 2
			.Open
			.Charset = "utf-8"
			.Position = objStream.Size
			.WriteText = strBody
			.SaveToFile Server.MapPath(File),2
			.Close
		End With
		Set objStream = Nothing
	End If
	If Err Then
		GBL_CHK_TempStr = "错误信息：<p>" & err.description & "</p>其它可能：确定是否对此文件有写入权限."
		err.Clear
		Set Fs = Nothing
		Exit Sub
	End If

End Sub

Function htmlEncode(str)

	If str & "" <> "" Then
		htmlEncode=Replace(Replace(Replace(str,">","&gt;"),"<","&lt;"),"""","&quot;")
	Else
		htmlEncode=str
	End If

End Function


sub install_step1form

%>
<ol>
<li>此程序将在您的空间安装LeadBBS 9.0，确保空间拥有ASP代码执行权限。</li>
<li>安装程序仅允许成功执行一次，若要再次安装请重新上传原始文件。
<li>此程序版权限归LeadBBS官方论坛所有，个人可免费使用此程序．<br />商业用途则需要向软件开发者购买授权许可。</li>
</ol>
<a href="default.asp?step=2" class="install_submit">同意以上要求并继续安装</a>
<%

end sub

sub install_step2form

	Dim flag,f,filestr,readflag
%>
<div class="contenttitle">以下检测全部通过才能继续安装</div>
<ol>
<li><%
f = CheckObjInstalled("Scripting.FileSystemObject",1)
if f = false then Check_com = false%></li>
<li><%
f = CheckObjInstalled("adodb.connection",1)
if f = false then Check_com = false%></li>
<li><%
f = CheckObjInstalled("Scripting.Dictionary",1)
if f = false then Check_com = false%></li>
<li>读取权限检测：<%

filestr = ADODB_LoadFile(DEF_BBS_HomeUrl & "inc/BBSSetup.asp")
If GBL_CHK_TempStr <> "" Then
	Check_com = false
	readflag = false
	Response.Write "<span class=""redfont"">χ</span> <br /><span class=""grayfont"">(" & htmlEncode(GBL_CHK_TempStr) & ")</span>"
Else
	If inStr(filestr,"DEF_UsedDataBase") > 0 then
		readflag = true
		Response.Write "<font color=green class=greenfont>√</font>"
	else
		readflag = false
		Check_com = false
		Response.Write "<span class=""redfont"">χ</span> <span class=""grayfont"">(未能正确读取文件)</span>"
	end if
End If
%>
</li>
<li>写权限检测：<%
If readflag = false then
	Response.Write "<span class=""redfont"">χ</span> <span class=""grayfont"">(首先必须具备有正常的读权限)</span>"
else
	call ADODB_SaveToFile(filestr,DEF_BBS_HomeUrl & "inc/BBSSetup.asp")
	If GBL_CHK_TempStr <> "" Then
		Check_com = false
		Response.Write "<span class=""redfont"">χ</span> <br /><span class=""grayfont"">(" & htmlEncode(GBL_CHK_TempStr) & ")</span>"
	Else
		Response.Write "<font color=green class=greenfont>√</font>"
	End If
end if
%>
</li>
</ol>
<div class="contenttitle">以下检测论坛扩展需要，根据实际情况可能会调整默认配置</div>
<ol>
<li><%call CheckObjInstalled("Persits.Jpeg",1)%></li>
<li><%call CheckObjInstalled("leadbbs.bbsCode",1)%></li>
<li><%call CheckObjInstalled("JMail.SMTPMail",1)%></li>
</ol>
<%if Check_com = true then%>
<a href="default.asp?step=3" class="install_submit">继续安装</a>
<%else%>
<a href="javascript:;" onclick="alert('只有通过第一部分检测才能继续安装，请先解决相应空间配置问题.');" class="install_submit_disbale">全部通过第一部分检测才能继续</a>
<%
end if

end sub

function filterStr(str)

	str = replace(str,"""","")
	str = replace(str,"'","")
	str = replace(str,"<","")
	filterStr = str

end function

sub OpenDatabase(constr)

	on error resume next
	Set Con = Server.CreateObject("ADODB.Connection")
	Con.ConnectionString = constr
	Con.Open
	If Err Then
		GBL_CHK_TempStr = "<p>错误描述: <font color=red>" & err.description & "</font></p>"
	End If

End Sub

Sub CloseDatabase

	on error resume next
	Con.Close
	Set con = Nothing
	
End Sub

function mapFile(file)

	mapFile = Server.MapPath(file)

End function

sub install_step3form

	dim server,port,uid,pwd,databasename,mysqlversion
	dim mysql_server,mysql_port,mysql_uid,mysql_pwd,mysql_databasename
	dim submitflag
	dtype = 2
	dtype = left(request.form("dtype"),1)
	server = left(request.form("server"),32)
	port = toNum(left(request.form("port"),6),0)
	uid = left(request.form("uid"),32)
	pwd = left(request.form("pwd"),32)
	databasename = left(request.form("databasename"),32)
	mysqlversion = left(request.form("mysqlversion"),1)
	
	
	mysql_server = left(request.form("mysql_server"),32)
	mysql_port = toNum(left(request.form("mysql_port"),6),0)
	mysql_uid = left(request.form("mysql_uid"),32)
	mysql_pwd = left(request.form("mysql_pwd"),32)
	mysql_databasename = left(request.form("mysql_databasename"),32)
	
	submitflag = left(request.form("submitflag"),4)

	if dtype = "2" then
		dtype = 2
	elseif dtype = "0" then
		dtype = 0
	else
		dtype = 1
	end if

	if mysqlversion = "1" then
		mysqlversion = 1
	elseif dtype = "0" then
		mysqlversion = 0
	else
		mysqlversion = 2
	end if
	
	if submitflag = "true" then
		select case dtype
			case 0:
				setupstr = "Provider=SQLOLEDB;Data Source=" & filterStr(server)
				if port > 0 then
					setupstr = setupstr & "," & port & ";"
				else
					setupstr = setupstr & ";"
				end if
				setupstr = setupstr & "uid=" & filterStr(uid) & ";pwd=" & filterStr(pwd) & ";database=" & filterStr(databasename) & ";"
				constr = setupstr
				'GBL_CHK_TempStr = "<font class=redfont>暂不支持mssql版本安装.</font>"
			case 1:
				setupstr = "data/global.asa"
				constr = "Provider=Microsoft.Jet.OLEDB.4.0; Data Source=" & mapFile(DEF_BBS_HomeUrl & setupstr)
			case 2:
				select case mysqlversion
					case 0:
						setupstr = "Driver={Mysql ODBC 5.1 Driver};SERVER=" & filterStr(mysql_server) & ";"
					case 1:
						setupstr = "Driver={Mysql ODBC 3.51 Driver};SERVER=" & filterStr(mysql_server) & ";"
					case 2:
						setupstr = "Driver={Mysql ODBC 5.2 ANSI Driver};SERVER=" & filterStr(mysql_server) & ";"
				end select
				if mysql_port > 0 then
					setupstr = setupstr & "PORT=" & mysql_port & ";"
				end if
				setupstr = setupstr & "DATABASE=" & filterStr(mysql_databasename) & ";UID=" & filterStr(mysql_uid) & ";PWD=" & filterStr(mysql_pwd) & ";charset=utf8;"
				constr = setupstr
		end select

		If dtype = 0 or dtype = 1 or dtype = 2 Then
			GBL_CHK_TempStr = ""
			OpenDatabase(constr)
			CloseDatabase()
			If GBL_CHK_TempStr = "" Then
				install_step4form()
				exit sub
			end if
		End If
	end if
	%>
	<script type="text/JavaScript">
	$id = function(id){
	return document.getElementById(id);
	}
	function changedatabase(f)
	{
		if(f==1)
		$id("access").style.display="block";
		else
		$id("access").style.display="none";
		
		if(f==0)
		$id("mssql").style.display="block";
		else
		$id("mssql").style.display="none";
		
		if(f==2)
		$id("mysql").style.display="block";
		else
		$id("mysql").style.display="none";
	}

	var ValidationPassed = true;
	function submitonce(theform)
	{
		if(ValidationPassed == false)return;
		submit_disable(theform);
		$id('LeadBBSFm').submit();
	}
	function submit_disable(theform,tp)
	{
		ValidationPassed = false;
	}
	</script>
	<div class="contenttitle" id="databasecontenttitle">配置数据库</div>
	<%If GBL_CHK_TempStr <> "" Then
		%>
		<div class="line">
			连接数据库失败，无法继续安装，请检查错误原因．
		</div>
		<%
		Response.Write GBL_CHK_TempStr
		End If%>

	<form action="default.asp?step=3" method="post" id="LeadBBSFm" name="LeadBBSFm" onsubmit="submitonce(this);return ValidationPassed;">
	<input name="submitflag" value="true" type="hidden" />

<div id="selectdatabase">
	<div class="line">
	<span class="name">数据库类型：</span>
	<input class=fmchkbox type=radio name=dtype value=1 <%If dtype = 1 Then Response.Write " checked"%> onclick="changedatabase(1)" />Microsoft Access(mdb)
	<span>
	<input class=fmchkbox type=radio name=dtype value=0 <%If dtype = 0 Then Response.Write " checked"%> onclick="changedatabase(0)" />Microsoft SQL Server
	</span>
	<input class=fmchkbox type=radio name=dtype value=2 <%If dtype = 2 Then Response.Write " checked"%> onclick="changedatabase(2)" />MySQL
	</div>
</div>
	
	<div class="line" id="access"<%
	if dtype <> 1 then response.Write " style=""display:none;"""
	%>>
	<span class="name">文件路经：</span>
	<input maxlength=255 type="text" id=Form_Title name=accessfile size="49" value="data/global.asa" disabled="true"> <span class="info">不可更改</span>
	</div>

	<div id="mssql"<%
	if dtype <> 0 then response.Write " style=""display:none;"""
	%>>
	<div class="line">
	<span class="name">
	SERVER：
	</span><input maxlength=30 type="text" name=server size="25" value="<%=htmlEncode(server)%>"> <span class="info">数据库服务器IP地址，与WEB同机可填写localhost</span>
	</div>
	
	<div class="line">
	<span class="name">
	端口：
	</span><input maxlength=30 type="text" name=port size="25" value="<%if port > 0 then response.write htmlEncode(port)%>"> <span class="info">端口号，若为默认不用填写</span>
	</div>
	
	<div class="line">
	<span class="name">
	用户名：
	</span><input maxlength=30 type="text" name=uid size="25" value="<%=htmlEncode(uid)%>"> <span class="info">访问数据库的用户名(UID)</span>
	</div>
	
	<div class="line">
	<span class="name">
	密码：
	</span><input maxlength=30 type="password" name=pwd size="25" value="<%=htmlEncode(pwd)%>"> <span class="info">密码(PWD)</span>
	</div>
	
	<div class="line">
	<span class="name">
	数据库名称：
	</span><input maxlength=30 type="text" name=databasename size="25" value="<%=htmlEncode(databasename)%>"> <span class="info">需要指定数据库名称</span>
	</div>
	</div>
	
	

	<div id="mysql"<%
	if dtype <> 2 then response.Write " style=""display:none;"""
	%>>
	
	<div class="line">
	<span class="name">
	ODBC版本：
	</span>
	<input class=fmchkbox type=radio name=mysqlversion value=2 <%If mysqlversion = 2 Then Response.Write " checked"%> />Mysql ODBC 5.2 Driver
	<input class=fmchkbox type=radio name=mysqlversion value=0 <%If mysqlversion = 0 Then Response.Write " checked"%> />Mysql ODBC 5.1 Driver
	<input class=fmchkbox type=radio name=mysqlversion value=1 <%If mysqlversion = 1 Then Response.Write " checked"%> />Mysql ODBC 3.51 Driver
	</div>
	
	<div class="line">
	<span class="name">
	SERVER：
	</span><input maxlength=30 type="text" name=mysql_server size="25" value="<%=htmlEncode(mysql_server)%>"> <span class="info">数据库服务器IP地址，同WEB的本机可填写localhost</span>
	</div>
	
	<div class="line">
	<span class="name">
	端口：
	</span><input maxlength=30 type="text" name=mysql_port size="25" value="<%if mysql_port > 0 then response.write htmlEncode(mysql_port)%>"> <span class="info">端口号，若为默认不用填写</span>
	</div>
	
	<div class="line">
	<span class="name">
	用户名：
	</span><input maxlength=30 type="text" name=mysql_uid size="25" value="<%=htmlEncode(mysql_uid)%>"> <span class="info">访问数据库的用户名(UID)</span>
	</div>
	
	<div class="line">
	<span class="name">
	密码：
	</span><input maxlength=30 type="password" name=mysql_pwd size="25" value="<%=htmlEncode(mysql_pwd)%>"> <span class="info">密码(PWD)</span>
	</div>
	
	<div class="line">
	<span class="name">
	数据库名称：
	</span><input maxlength=30 type="text" name=mysql_databasename size="25" value="<%=htmlEncode(mysql_databasename)%>"> <span class="info">需要指定数据库名称</span>
	</div>
	
	</div>
	<a href="javascript:;" onclick="submitonce(this);" class="install_submit">提交设置</a>
	</form>
	<%

End sub


Sub install_step4form

	adminuser = left(request.form("adminuser"),20)
	adminpassword = left(request.form("adminpassword"),20)
	adminpassword2 = left(request.form("adminpassword2"),20)
	
	If constr = "" then constr = left(request.form("constr"),255)
	If dtype = "" then dtype = left(request.form("dtype"),20)
	If setupstr = "" then setupstr = left(request.form("setupstr"),255)
	
	if request.form("submitflag") = "true2" then
		if adminuser = "" then
			GBL_CHK_TempStr = "请填写管理员账号."
		else
			CheckUsername(adminuser)
		end if
		if adminpassword <> adminpassword2 then
			GBL_CHK_TempStr = GBL_CHK_TempStr & " 两次密码输入未相同."
		Else
			if adminpassword = "" or adminpassword2 = "" then
				GBL_CHK_TempStr = GBL_CHK_TempStr & " 请填写密码."
			End If
		End If
		if GBL_CHK_TempStr = "" then
			install_step5form()
			exit sub
		end if
	end if
%>
	<script type="text/JavaScript">
	$id = function(id){
	return document.getElementById(id);
	}
	var ValidationPassed = true;
	function submitonce(theform)
	{
		if(ValidationPassed == false)return;
		submit_disable(theform);
		alert("提交后，可能需要数分钟时间才能完成设置，若有错误，请替换BBSSetup.asp为原始文件，重新进行安装.");
		$id('LeadBBSFm').submit();
	}
	function submit_disable(theform,tp)
	{
		ValidationPassed = false;
	}
	$id('step4').className = "on"
	</script>
	<div class="contenttitle" id="databasecontenttitle">设置管理员</div>
	<%If GBL_CHK_TempStr <> "" Then
		%>
		<div class="line">
			相关信息填写未能通过验证．
		</div>
		<%
		Response.Write "<span class=redfont>" & GBL_CHK_TempStr & "</span>"
		End If%>

	<form action="default.asp?step=4" method="post" id="LeadBBSFm" name="LeadBBSFm" onsubmit="submitonce(this);return ValidationPassed;">
	<input name="submitflag" value="true2" type="hidden" />
	<input name="constr" value="<%=htmlencode(constr)%>" type="hidden" />
	<input name="dtype" value="<%=htmlencode(dtype)%>" type="hidden" />
	<input name="setupstr" value="<%=htmlencode(setupstr)%>" type="hidden" />
	
	<div class="line">
	<span class="name">
	管理员账号：
	</span><input maxlength=30 type="text" name=adminuser size="25" value="<%=htmlEncode(adminuser)%>"> <span class="info">此用户名将成为论坛超级管理员并注册</span>
	</div>
	
	<div class="line">
	<span class="name">
	密码：
	</span><input maxlength=20 type="password" name=adminpassword size="25" value="<%=htmlEncode(adminpassword)%>"> <span class="info">超级管理员密码</span>
	</div>
	
	<div class="line">
	<span class="name">
	再次输入密码：
	</span><input maxlength=20 type="password" name=adminpassword2 size="25" value="<%=htmlEncode(adminpassword2)%>"> <span class="info">两次密码输入必须相同</span>
	</div>
	
	<a href="javascript:;" onclick="submitonce(this);" class="install_submit">提交设置</a>
	</form>

<%

End Sub

function exesql(sql,flag)

	if replace(trim(sql),VbCrLf,"") = "" then exit function
	on error resume next
	If flag = 0 or flag = 3 Then
		Set exesql = Con.ExeCute(SQL)
	Else
		Con.ExeCute(SQL)
	End If
	If Err Then
		'printline("<p>以下SQL语句执行出错，程序意外中止，请联系官方解决：</p><p><font color=gray>" & server.htmlencode(SQL) & "</font></P>")
		printline("<p>错误描述: <font color=red>" & err.description & "</font></p>")
		Err.Clear
	End If

end function

sub install_step5form

%>

	<script type="text/JavaScript">
	$(window).resize();
	</script>
	<script type="text/JavaScript">
	$id = function(id){
	return document.getElementById(id);
	}
	$id('step5').className = "on"
	</script>
<%
	if dtype = "1" then
		dtype = 1
	elseif dtype = "2" then
		dtype = 2
	else
		dtype = 0
	end if
	
	setupstr = filterStr(setupstr)
	constr = filterStr(constr)
	
	OpenDatabase(constr)
	
	If GBL_CHK_TempStr <> "" Then
		Response.Write "<span class=err>安装失败，请返回重新安装.</span>"&GBL_CHK_TempStr
		CloseDatabase()
		exit sub
	end if
	
	printline("<b>请耐心等候完成安装....</b>")
	dim filestr,arr,n
	select case dtype
		case 2:
			filestr = ADODB_LoadFile("database/mysql.sql")
			arr = split(filestr,";")
			printline("开始初始化MYSQL数据库...")
			%>
			<div class=errstr>
			<%
			for n = 0 to ubound(arr)
				call exesql(arr(n),1)
			next
			%>
			</div>
			<%
			printline("已完成MYSQL初始化数据库.")
		case 0:
			filestr = ADODB_LoadFile("database/mssql.sql")
			arr = split(filestr,VbCrLf & "GO" & VbCrLf)
			printline("开始初始化MSSQL数据库...")
			%>
			<div class=errstr>
			<%
			for n = 0 to ubound(arr)
				call exesql(arr(n),1)
			next
			%>
			</div>
			<%
			printline("已完成初始化MSSQL数据库.")
	end select
	
	dim sql,rs
	sql = "select id from leadbbs_user where username='" & filterStr(adminuser) & "'"
	set rs = exesql(sql,0)
	if rs.eof then
		sql = "insert into leadbbs_user(username,pass,answer,applytime) values('" & filterStr(adminuser) & "','" & md5(adminpassword) & "','" & md5(adminpassword) & "'," & GetTimevalue(now) & ")"
		call exesql(sql,1)
	else
		printline("管理员账号" & htmlencode(adminuser) & "已存在，略过添加.")
	end if
	rs.close
	set rs = nothing
	
	printline("已初始化管理员.")
	
	Update_InstallDir()
	filestr = ADODB_LoadFile(DEF_BBS_HomeUrl & "inc/BBSSetup.asp")
	filestr = replace(filestr,"Const DEF_AccessDatabase = """"","Const DEF_AccessDatabase = """ & filterStr(setupstr) & """")
	filestr = replace(filestr,"Const DEF_AccessDatabase = ""data/global.asa""","Const DEF_AccessDatabase = """ & filterStr(setupstr) & """")
	filestr = replace(filestr,"const DEF_UsedDataBase = 1","const DEF_UsedDataBase = " & dtype)
	filestr = replace(filestr,"const DEF_UsedDataBase = 0","const DEF_UsedDataBase = " & dtype)
	filestr = replace(filestr,"const DEF_UsedDataBase = 2","const DEF_UsedDataBase = " & dtype)
	printline("完成数据库设置.")
	
	if CheckObjInstalled("Persits.Jpeg",0) = True then
		filestr = replace(filestr,"const DEF_EnableGFL = 0","const DEF_EnableGFL = 1")
		printline("已开启aspJpeg组件功能支持.")
	else
		filestr = replace(filestr,"const DEF_EnableGFL = 1","const DEF_EnableGFL = 0")
		printline("已禁用aspJpeg组件功能支持.")
	End If

	filestr = replace(filestr,"const DEF_SupervisorUserName = "",Admin,""","const DEF_SupervisorUserName = ""," & filterStr(adminuser) & ",""")
	

	filestr = replace(filestr,"Response.Redirect ""install/default.asp""","")
	call ADODB_SaveToFile(filestr,DEF_BBS_HomeUrl & "inc/BBSSetup.asp")
	CALL Update_InsertSetupRID(1051,"inc/BBSSetup.asp",0,filestr," and ClassNum=" & 0)
	printline("<b>完成安装.</b>")
	printline("<b>建议立即使用创建的管理员进入后台新建分类及版面信息．</b>")
	%>
	<a href="<%=DEF_BBS_HomeUrl%>manage/" class="install_submit">点击进入后台管理</a>
	<%
	CloseDatabase()
	

end sub

sub printline(str)

	%>
	<div class="line"><%=str%></div>
	<%
	response.flush

end sub

Function CheckUsername(Form_UserName)


					Dim TempChar,TempURL,Loop_N
					TempURL = Len(Form_UserName)
					For Loop_N = 1 to TempURL
						TempChar = ASC(Mid(Form_UserName,Loop_N,1))
						If TempChar < 0 Then TempChar = TempChar + 65535
							If TempChar = 32 Then
								If TempURL > Len(Replace(Form_UserName," ","")) + 2 Then '允许最多两个空格且不同时在一起
									CheckUsername = 0
									GBL_CHK_TempStr = "用户名最多只允许使用两个空格!<br>"
									Exit Function
								End If
							Else
								If TempChar < 45 or (TempChar>45 and TempChar<48) or (TempChar>57 and TempChar<65) or (TempChar>90 and TempChar < 95) or TempChar = 96 or (TempChar > 122 and TempChar < 33088) Then
									GBL_CHK_TempStr = "用户名含有非法字符(请使用数字,字母,下划线)!<br>"
									CheckUsername = 0
									Exit Function
								End If
							End If
						
						
						If TempChar > 65184 Then
							GBL_CHK_TempStr = "非法的用户名,含有非法字符,请确认!<br>"
							CheckUsername = 0
							Exit Function
						End If
					Next
					CheckUsername = 1

End function

Function GetTimeValue(DateString)

	Dim Temp,TempStr
	If isNull(DateString) or isTrueDate(DateString) = 0 Then
		GetTimeValue = 0
		Exit Function
	End If
	Temp = CsTr(Year(DateString))
	If Len(temp)<3 Then
		Temp = Left(year(DEF_Now),2) & Temp
	End If
	TempStr = Temp
	
	Temp = CsTr(month(DateString))
	If Len(temp)<2 Then Temp = "0" & Temp
	TempStr = TempStr & Temp

	Temp = CsTr(day(DateString))
	If Len(Temp) < 2 Then Temp = "0" & Temp
	TempStr = TempStr & Temp

	Temp = csTr(Hour(DateString))
	If Len(Temp) < 2 Then Temp = "0" & Temp
	TempStr = TempStr & Temp

	Temp = CsTr(Minute(DateString))
	If Len(Temp) < 2 Then Temp = "0" & Temp
	TempStr = TempStr & Temp

	Temp = CsTr(Second(DateString))
	If Len(Temp) < 2 Then Temp = "0" & Temp
	TempStr = TempStr & Temp

	GetTimeValue = cCur(TempStr)

End Function

Function isTrueDate(TStr)

	Dim T
	T = TStr
	If isNull(T) Then T = ""
	T = Replace(Replace(Replace(Replace(Replace(Replace(Replace(T,"年","-"),"月","-"),"日"," "),"上午"," "),"下午"," "),"  "," "),"  "," ")
	
	Dim N1,N2
	N1 = inStr(T,"-")
	If N1>0 Then N2 = inStrRev(T,"-")
	If N1 = N2 and N1 >0 Then
		isTrueDate = 0
		Exit Function
	End If

	N1 = inStr(T,":")
	If N1>0 Then N2 = inStrRev(T,"-")
	If N1 = N2 and N1 >0 Then
		isTrueDate = 0
		Exit Function
	End If

	If isDate(TStr) Then
		isTrueDate = 1
	Else
		isTrueDate = 0
	End If

End Function

Sub Update_InstallDir

	Dim InstallDir
	InstallDir = Lcase(Request.Servervariables("SCRIPT_NAME"))
	InstallDir = Replace(InstallDir,"\","/")
	do while inStr(InstallDir,"//")
		InstallDir = Replace(InstallDir,"//","/")
	Loop
	InstallDir = replace(InstallDir,Replace(Replace(lcase("install"),"\","/"),"//","/") & "/default.asp","")
	
	dim OldStr_start,OldStr_end,NewStr
	OldStr_start = "Const DEF_InstallDir = """
	' README §50: this searched for a quote followed by CRLF and "%>". This repository
	' normalises its sources to LF, so the needle never matched, Update_ReplaceFileStr_2
	' silently wrote nothing, and DEF_InstallDir kept the upstream default -- while the
	' installer still printed the value it MEANT to write. Match either line ending.
	OldStr_end = """" & VbLf & "%" & ">"
	If inStr(ADODB_LoadFile("inc/BBSSetup.asp"), """" & VbCrLf & "%" & ">") > 0 Then
		OldStr_end = """" & VbCrLf & "%" & ">"
	End If
	NewStr = InstallDir
	call Update_ReplaceFileStr_2("inc/BBSSetup.asp",OldStr_start,OldStr_end,NewStr)
	printline("安装目录完成检测，位置为: <u>" & InstallDir & "</u>。")

End Sub

Sub Update_ReplaceFileStr_2(FileName,OldStr_start,OldStr_end,NewStr)

	Dim fs,WriteFile,fileContent
	dim startN,endN,reStr
	dim ChangeFlag
	ChangeFlag = 0
	
	dim FSFlag : FSFlag = 1
	If DEF_FSOString <> "" Then
		Set fs = Server.CreateObject(DEF_FSOString)
		If Err Then
			FSFlag = 0
			Err.Clear
			Set fs = Nothing
		End If
	Else
		FSFlag = 0
	End If
	If FSFlag = 1 Then
		Set fs = Server.CreateObject(DEF_FSOString)
		Set WriteFile = fs.OpenTextFile(Server.MapPath(DEF_BBS_HomeUrl & FileName),1,True)
		If Not WriteFile.AtEndOfStream Then
			fileContent = WriteFile.ReadAll
		End If
		WriteFile.Close
		Set fs = Nothing

		startN = instr(fileContent,OldStr_start)
		endN = instr(fileContent,OldStr_end)
		if startN > 0 and endN > 0 and endN > startN+len(OldStr_start) then
			reStr = mid(fileContent,startN+len(OldStr_start),endN - (startN+len(OldStr_start)))
			if OldStr_start & reStr & OldStr_end <> OldStr_start & NewStr & OldStr_end then
				fileContent = Replace(fileContent,OldStr_start & reStr & OldStr_end,OldStr_start & NewStr & OldStr_end)
				Set fs = Server.CreateObject(DEF_FSOString)
				Set WriteFile = fs.CreateTextFile(Server.MapPath(DEF_BBS_HomeUrl & FileName),True)
				WriteFile.Write fileContent
				WriteFile.Close
				Set fs = Nothing
				ChangeFlag = 1
			else
			end if
		end if
	Else
		fileContent = ADODB_LoadFile(DEF_BBS_HomeUrl & FileName)
		
		startN = instr(fileContent,OldStr_start)
		endN = instr(fileContent,OldStr_end)
		if startN > 0 and endN > 0 and endN > startN+len(OldStr_start) then
			reStr = mid(fileContent,startN+len(OldStr_start),endN - (startN+len(OldStr_start)))
			if OldStr_start & reStr & OldStr_end <> OldStr_start & NewStr & OldStr_end then
				fileContent = Replace(fileContent,OldStr_start & reStr & OldStr_end,OldStr_start & NewStr & OldStr_end)
				ADODB_SaveToFile fileContent,DEF_BBS_HomeUrl & FileName
				Response.Write GBL_CHK_TempStr
				ChangeFlag = 1
			else
			end if
		end if
	End If
	if ChangeFlag = 1 then
		select case lcase(FileName)
			Case "inc\ubbcode_setup.asp":
				CALL Update_InsertSetupRID(1051,"inc/Ubbcode_Setup.asp",1,fileContent," and ClassNum=" & 1)
				CALL Update_ECHO("saved " & FileName,0)
			case "inc\upload_setup.asp":
				CALL Update_InsertSetupRID(1051,"inc/Upload_Setup.ASP",3,fileContent," and ClassNum=" & 3)
				CALL Update_ECHO("saved " & FileName,0)
			case "inc\user_setup.asp":
				CALL Update_InsertSetupRID(1051,"inc/User_Setup.ASP",2,fileContent," and ClassNum=" & 2)
				CALL Update_ECHO("saved " & FileName,0)
			case "inc\bbssetup.asp":
				CALL Update_InsertSetupRID(1051,"inc/BBSSetup.asp",0,fileContent," and ClassNum=" & 0)
				CALL Update_ECHO("saved " & FileName,0)
		end select
	end if

End Sub

Sub Update_InsertSetupRID(RID,ValueStr,ClassNum,saveData,extend)

	If ValueStr = "error" then ValueStr = "0"
	If Update_CheckSetupRIDExist(RID,extend) = 0 Then
		CALL exesql("insert into LeadBBS_Setup(RID,ValueStr,ClassNum,saveData) values(" & Rid & ",'" & Replace(ValueStr,"'","''") & "'," & ClassNum & ",'" & Replace(saveData,"'","''") & "')",1)
	Else
		CALL exesql("Update LeadBBS_Setup Set ValueStr='" & Replace(ValueStr,"'","''") & "',ClassNum=" & ClassNum & ",saveData='" & Replace(saveData,"'","''") & "' where RID=" & RID & extend,1)
	End If

End Sub

dim GBL_LeadBBS_Setup_Data
Function Update_CheckSetupRIDExist(RID,extend)

	Dim Rs
	Set Rs = exesql("Select ID,RID,ValueStr,ClassNum,SaveData from LeadBBS_Setup where RID=" & RID & extend,0)
	If Rs.Eof Then
		Update_CheckSetupRIDExist = 0
		Set GBL_LeadBBS_Setup_Data = Nothing
		GBL_LeadBBS_Setup_Data = ""
	Else
		Update_CheckSetupRIDExist = 1
		GBL_LeadBBS_Setup_Data = Rs.GetRows(-1)
		GBL_LeadBBS_Setup_Data(2,0) = Trim(GBL_LeadBBS_Setup_Data(2,0))
	End If
	Rs.Close
	Set Rs = Nothing

End Function
%>