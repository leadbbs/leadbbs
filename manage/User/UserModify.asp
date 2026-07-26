<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/User_Setup.ASP"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<!--#include file="../../inc/ubbcode.asp"-->
<!--#include file="inc/User_fun.ASP"-->
<!--#include file="../../inc/Limit_Fun.asp"-->
<!--#include file="../../inc/Constellation2.asp"-->

<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
CursorLocation = 3
initDatabase()

GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass()

Manage_sitehead DEF_SiteNameString & " - 管理员",""
GBL_CHK_TempStr=""
Form_ID = Left(Request("Form_ID"),14)
If isNumeric(Form_ID) = 0 Then Form_ID = 0
Form_ID = cCur(Form_ID)
If Form_ID < 0 Then Form_ID = 0

If Form_ID=0 Then
	GBL_CHK_TempStr = GBL_CHK_TempStr & "没有选择要修改的用户<br>" & VbCrLf
End If
frame_TopInfo()
DisplayUserNavigate("用户资料修改")
If GBL_CHK_Flag=1 Then
	If GBL_CHK_TempStr = "" Then
		If Request.Form("SubmitFlag")="29d98Sasphouseasp8asphnet" Then
			GBL_CHK_TempStr = ""
			checkFormDate()

			If GBL_CHK_Flag = 0 Then
				Response.WRite "<div class=alert>" & GBL_CHK_TempStr & "</div>" & VbCrLf
				JoinForm()
			Else
				If saveFormData() = 1 Then
					displayAccessFull()
				Else
					Response.WRite "<div class=alert>" & GBL_CHK_TempStr & "</div>" & VbCrLf
					JoinForm()
				End If
			End If
		Else
			GetUserData(Form_ID)
			JoinForm()
		End If
	Else%>
		<div class=frameline>
			<%=GBL_CHK_TempStr%>
		</div>
	<%End If
Else
DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

Function GetUserData(ID)

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select * from LeadBBS_User where id=" & ID,1),0)
	If Rs.Eof Then
		GetUserData = 0
		GBL_CHK_Flag = 0
		Rs.Close
		Set Rs = Nothing
		Exit Function
	End If
	Form_UserName = Rs("UserName")
	Form_Mail = Rs("Mail")
	Form_Address = Rs("Address")
	Form_Sex = Rs("Sex")
	Form_ICQ = Rs("ICQ")
	Form_OICQ = Rs("OICQ")
	Form_MobileTel = Rs("MobileTel")
	Form_Userphoto = Rs("Userphoto")
	Form_Homepage = Rs("Homepage")
	Form_Underwrite = Rs("Underwrite")
	'Form_Password1 = Rs("Pass")
	'Form_Password2 = Form_Password1
	Form_birthday = Rs("birthday")
	If len(Form_birthday)=14 Then
		Form_birthday = RestoreTime(Rs("birthday"))
		Form_bday = day(Form_birthday)
		Form_byear = year(Form_birthday)
		Form_bmonth = month(Form_birthday)
	End If

	REM 特殊数据
	Form_ApplyTime = Rs("ApplyTime")
	Form_IP = Rs("IP")
	Form_UserLevel = Rs("UserLevel")
	Form_Officer = Rs("Officer")
	Form_Points = Rs("Points")
	Form_Sessionid = Rs("Sessionid")
	Form_Online = Rs("Online")
	Form_Prevtime = Rs("Prevtime")
	Form_ID = Rs("ID")
	Form_Login_ip = Rs("Login_ip")
	Form_Login_oknum = Rs("Login_oknum")
	Form_Login_falsenum = Rs("Login_falsenum")
	Form_Login_lastpass = Rs("Login_lastpass")
	Form_Login_RightIP = Rs("Login_RightIP")
	Form_Question = Rs("Question")
	'Form_Answer = Rs("Answer")
	Form_LockIP = Rs("LockIP")
	
	If DEF_AllDefineFace <> 0 Then
		Form_FaceUrl = Rs("FaceUrl")
		Form_FaceWidth = Rs("FaceWidth")
		Form_FaceHeight = Rs("FaceHeight")
	End If
	Form_UserLimit = Rs("UserLimit")
	Form_UserTitle = Rs("UserTitle")
	Form_CachetValue = Rs("CachetValue")
	Form_CharmPoint = Rs("CharmPoint")
	Rs.Close
	Set Rs = Nothing
	GetUserData = 1
	GBL_CHK_Flag = 1

End Function

Function JoinForm%>
<head>
	<style type=text/css>
		.input
		{
			FONT-FAMILY: 宋体;
			border-left:0px;
			border-right:0px;
			border-top:0px;
			border-bottom:1px groove #0055ff;
			width:240px;
			font-size:9pt
		}
		.inputs
		{
			FONT-FAMILY: 宋体;
			border-left:0px;
			border-right:0px;
			border-top:0px;
			border-bottom:1px groove #0055ff;
			width:40px;
			font-size:9pt
		}
		.inputss
		{
			FONT-FAMILY: 宋体;
			border-left:0px;
			border-right:0px;
			border-top:0px;
			border-bottom:1px groove #0055ff;
			width:20px;
			font-size:9pt
		}
	</style>
	<script LANGUAGE="JavaScript" TYPE="text/javascript">
		function setface() 
		{
			window.open('facelist.asp','','width=250,height=450 scrollbars=auto,status=no');
		}
	</script>
	<script language=JavaScript>
	<!--
	ValidationPassed = true;
	function isnum(str)
	{
		rset="";
		for(i=0;i<str.length;i++)
		{
			if(str.charAt(i)>="0" && str.charAt(i)<="9")
			{
			}
			else
			{
				return 0;
			}
		}
		return 1;
	}

	function changeface()
	{
		var temp;
		temp=document.form1.Form_userphoto.value;
		if (temp!="" && isnum(temp)==1 && temp.length==4)
		{
			if (temp > 0 && temp <= <%=DEF_faceMaxNum%>)
			{
				document.faceimg.src='<%=DEF_BBS_HomeUrl%>images/face/'+temp+'.gif';
			}
			else
			{
				alert("错误!此图像代号不存在!");
				document.faceimg.src='<%=DEF_BBS_HomeUrl%>images/null.gif';
				document.form1.Form_userphoto.value='';
				ValidationPassed = false;
			}
		}
		else
		{
			alert("错误!此图像代号不存在!\n图像代号必须是4位数<%if len(Cstr(DEF_faceMaxNum))>4 then Response.Write "或以上"%>,比如 0001 ,最大为<%=DEF_faceMaxNum%>");
			document.faceimg.src='<%=DEF_BBS_HomeUrl%>images/null.gif';
			document.form1.Form_userphoto.value='';
			ValidationPassed = false;
		}
	}

	<%If DEF_AllDefineFace <> 0 Then%>
	function changeface2()
	{
		var temp,obj;
		obj=document.form1;
		if(obj.Form_FaceWidth.value!="")
		{
			if (! isnum(obj.Form_FaceWidth.value))
			{
				alert("自定义头像宽度必须是数字！\n");
				obj.Form_FaceWidth.focus();
				return;
			}
			else
			{
				if(obj.Form_FaceWidth.value<20 || obj.Form_FaceWidth.value><%=DEF_AllFaceMaxWidth%>)
				{
					alert("自定义头像宽度必须在20-<%=DEF_AllFaceMaxWidth%>之间！\n");
					obj.Form_FaceWidth.focus();
					return;
				}
			}
		}

		if(obj.Form_FaceHeight.value!="")
		{
			if (! isnum(obj.Form_FaceHeight.value))
			{
				alert("自定义头像高度必须是数字！\n");
				obj.Form_FaceHeight.focus();
				return;
			}
			else
			{
				if(obj.Form_FaceHeight.value<20 || obj.Form_FaceHeight.value><%=DEF_AllFaceMaxWidth*2%>)
				{
					alert("自定义头像高度必须在20-<%=DEF_AllFaceMaxWidth*2%>之间！\n");
					obj.Form_FaceHeight.focus();
					return;
				}
			}
		}

		temp=document.form1.Form_FaceUrl.value;
		if (temp!="")
		{
			document.faceimg.src=temp;
			document.faceimg.width=obj.Form_FaceWidth.value;
			document.faceimg.height=obj.Form_FaceHeight.value;
		}
	}
	<%End If%>
	function form_onsubmit(obj)
	{
		if(obj.Form_username.value=="")
		{
			alert("请输入你的用户名!\n");
			ValidationPassed = false;
			obj.Form_username.focus();
			return;
		}
		
		if(obj.Form_username.value.length<1)
		{
			alert("用户名长度至少需要1个字符!\n");
			ValidationPassed = false;
			obj.Form_username.focus();
			return;
		}

		//if(obj.Form_password1.value=="")
		//{
		//	alert("请输入新的密码!\n");
		//	ValidationPassed = false;
		//	obj.Form_password1.focus();
		//	return;
		//}

		//if(obj.Form_password2.value=="")
		//{
		//	alert("请输入你的验证密码！\n");
		//	ValidationPassed = false;
		//	obj.Form_password2.focus();
		//	return;
		//}

		if(obj.Form_password1.value!=obj.Form_password2.value)
		{
			alert("你的两次密码输入不相同！\n");
			ValidationPassed = false;
			obj.Form_password1.focus();
			return;
		}


		if(obj.Form_oicq.value!="")
		{
			if (! isnum(obj.Form_oicq.value))
			{
				alert("喂,你填入了OICQ框中填入了东西,但你的OICQ号码怎么不是数字?\n");
				ValidationPassed = false;
				obj.Form_oicq.focus();
				return;
			}
		}

		if(obj.Form_byear.value!="")
		{
			if (! isnum(obj.Form_byear.value))
			{
				alert("喂,你填入了你的出生年,但你的年份怎么不是数字！\n");
				ValidationPassed = false;
				obj.Form_byear.focus();
				return;
			}
		}

		if(obj.Form_bmonth.value!="")
		{
			if (! isnum(obj.Form_bmonth.value))
			{
				alert("喂,你填入了你的出生月,但你的月份怎么不是数字！\n");
				ValidationPassed = false;
				obj.Form_bmonth.focus();
				return;
			}
		}

		if(obj.Form_bday.value!="")
		{
			if (! isnum(obj.Form_bday.value))
			{
				alert("喂,你填入了你的出生日,但你的出生日怎么不是数字！\n");
				ValidationPassed = false;
				obj.Form_bday.focus();
				return;
			}
		}

		if(obj.Form_userphoto.value!="")
		{
			if (! isnum(obj.Form_bday.value))
			{
				alert("用户图像,只能是001-318之间的数字！\n");
				ValidationPassed = false;
				obj.Form_bday.focus();
				return;
			}
		}
		
		if(obj.Form_Underwrite.value.length>255)
		{
			alert("用户签名内容要小于255个字符!\n");
			ValidationPassed = false;
			obj.Form_Underwrite.focus();
			return;
		}
		//其它资料
		

		if(obj.Form_ApplyTime.value=="")
		{
			alert("申请时间可不能忘了呀!\n");
			ValidationPassed = false;
			obj.Form_ApplyTime.focus();
			return;
		}		

		if(obj.Form_ApplyTime.value!="")
		{
			if (! isnum(obj.Form_ApplyTime.value))
			{
				alert("喂,您填入了申请时间,申请时间需要是数字的噢！\n");
				ValidationPassed = false;
				obj.Form_ApplyTime.focus();
				return;
			}
			if (obj.Form_ApplyTime.value.length!=14)
			{
				alert("申请时间必须是14位的噢！\n");
				ValidationPassed = false;
				obj.Form_ApplyTime.focus();
				return;
			}
		}
		
		if(obj.Form_Online.value=="")
		{
			alert("在线状态可不能忘了呀!\n");
			ValidationPassed = false;
			obj.Form_Online.focus();
			return;
		}
		if (! isnum(obj.Form_Online.value))
		{
			alert("在线状态必须是正整数。\n");
			ValidationPassed = false;
			obj.Form_Online.focus();
			return;
		}
		if(obj.Form_Prevtime.value=="")
		{
			alert("最后登录时间可不能忘了呀!\n");
			ValidationPassed = false;
			obj.Form_Prevtime.focus();
			return;
		}		

		if(obj.Form_Prevtime.value!="")
		{
			if (! isnum(obj.Form_Prevtime.value))
			{
				alert("喂,您填入了最后登录时间,最后登录时间需要是数字的噢！\n");
				ValidationPassed = false;
				obj.Form_Prevtime.focus();
				return;
			}
			if (obj.Form_Prevtime.value.length!=14)
			{
				alert("最后登录时间必须是14位的噢！\n");
				ValidationPassed = false;
				obj.Form_Prevtime.focus();
				return;
			}
		}
		
		if(obj.Form_UserLevel.value=="")
		{
			alert("用户<%=DEF_PointsName(3)%>可不能忘了呀!\n");
			ValidationPassed = false;
			obj.Form_UserLevel.focus();
			return;
		}
		if (! isnum(obj.Form_UserLevel.value))
		{
			alert("用户<%=DEF_PointsName(3)%>必须是正整数。\n");
			ValidationPassed = false;
			obj.Form_UserLevel.focus();
			return;
		}
		if (obj.Form_UserLevel.value><%=DEF_UserLevelNum%>||obj.Form_UserLevel.value<0)
		{
			alert("用户<%=DEF_PointsName(3)%>值必须是大等于0并且小于<%=DEF_UserLevelNum%>。\n");
			ValidationPassed = false;
			obj.Form_UserLevel.focus();
			return;
		}

		if(obj.Form_Points.value=="")
		{
			alert("用户<%=DEF_PointsName(0)%>可不能忘了呀!\n");
			ValidationPassed = false;
			obj.Form_Points.focus();
			return;
		}
		if (! isnum(obj.Form_Points.value))
		{
			alert("用户<%=DEF_PointsName(0)%>必须是正整数。\n");
			ValidationPassed = false;
			obj.Form_Points.focus();
			return;
		}
		
		if(obj.Form_Officer.value=="")
		{
			alert("<%=DEF_PointsName(9)%>可不能忘了呀!\n");
			ValidationPassed = false;
			obj.Form_Officer.focus();
			return;
		}

		if (! isnum(obj.Form_Login_oknum.value))
		{
			alert("成功登次必须是正整数。\n");
			ValidationPassed = false;
			obj.Form_Login_oknum.focus();
			return;
		}
		if (! isnum(obj.Form_Login_falsenum.value))
		{
			alert("持败登次必须是正整数。\n");
			ValidationPassed = false;
			obj.Form_Login_falsenum.focus();
			return;
		}
		
		<%If DEF_AllDefineFace <> 0 Then%>
		if(obj.Form_FaceWidth.value!="")
		{
			if (! isnum(obj.Form_FaceWidth.value))
			{
				alert("自定义头像宽度必须是数字！\n");
				ValidationPassed = false;
				obj.Form_FaceWidth.focus();
				return;
			}
			else
			{
				if(obj.Form_FaceWidth.value<20 || obj.Form_FaceWidth.value><%=DEF_AllFaceMaxWidth%>)
				{
					alert("自定义头像宽度必须在20-<%=DEF_AllFaceMaxWidth%>之间！\n");
					ValidationPassed = false;
					obj.Form_FaceWidth.focus();
					return;
				}
			}
		}

		if(obj.Form_FaceHeight.value!="")
		{
			if (! isnum(obj.Form_FaceHeight.value))
			{
				alert("自定义头像高度必须是数字！\n");
				ValidationPassed = false;
				obj.Form_FaceHeight.focus();
				return;
			}
			else
			{
				if(obj.Form_FaceHeight.value<20 || obj.Form_FaceHeight.value><%=DEF_AllFaceMaxWidth*2%>)
				{
					alert("自定义头像高度必须在20-<%=DEF_AllFaceMaxWidth%>之间！\n");
					ValidationPassed = false;
					obj.Form_FaceHeight.focus();
					return;
				}
			}
		}<%End if%>
		ValidationPassed = true;
		return true;
	}
	-->
	</script>
</head>

<form action=UserModify.asp method=post name=form1 onSubmit="return ValidationPassed">
	<div class=frametitle>用户资料修改</div>

	<table border=0 cellpadding=0 cellspacing=0 width="100%" class=frame_table>
			<tr>
				<td class=tdbox width=120>
					<p>*用户名称： 
				</td>
				<td class=tdbox>
					<p>
					<input maxLength=20 name="Form_username" size=36 class=fminpt Value="<% If Form_username<>"" Then Response.Write Server.HtmlEncode(Form_Username)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>&nbsp;新的密码： 
				</td>
				<td class=tdbox>
					<input name=SubmitFlag type=hidden value="29d98Sasphouseasp8asphnet">
					<input name=Form_ID type=hidden value="<%=htmlencode(Form_ID)%>">
					<input maxLength=20 name="Form_password1" size=36 class=fminpt type=password Value="<% If Form_password1<>"" Then Response.Write Server.HtmlEncode(Form_password1)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>&nbsp;验证密码： 
				</td>
				<td class=tdbox>
					<input maxlength=20 name="Form_password2" size=36 class=fminpt type=password Value="<% If Form_password2<>"" Then Response.Write Server.HtmlEncode(Form_password2)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>*密码提示： 
				</td>
				<td class=tdbox>
					<input maxLength=20 name=Form_Question class=fminpt size=36 Value="<% If Form_Question<>"" Then Response.Write Server.HtmlEncode(Form_Question)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>&nbsp;提示答案：
				</td>
				<td class=tdbox>
					<input maxlength=20 name=Form_Answer class=fminpt size=36 Value="<% If Form_Answer<>"" Then Response.Write Server.HtmlEncode(Form_Answer)%>"> 不改可以不填写
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>ＩＰ锁定：
				</td>
				<td class=tdbox>
					<input maxlength=15 name=Form_LockIP class=fminpt size=36 Value="<% If Form_LockIP<>"" Then Response.Write Server.HtmlEncode(Form_LockIP)%>"> 仅允许输入一个IP地址
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>电子邮件： 
				</td>
				<td class=tdbox>
					<input maxLength=60 name=Form_mail size=36 class=fminpt Value="<% If Form_mail<>"" Then Response.Write Server.HtmlEncode(Form_mail)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>主页地址：
				</td>
				<td class=tdbox>
					<input maxlength=250 name=Form_homepage size=36 class=fminpt Value="<% If Form_homepage<>"" Then Response.Write Server.HtmlEncode(Form_homepage)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>ICQ 号码：
				</td>
				<td class=tdbox>
					<input maxlength=14 name=Form_icq size=36 class=fminpt Value="<% If Form_icq<>"" Then Response.Write Server.HtmlEncode(Form_icq)%>">
				</td>
			</tr>
			
			<tr>
				<td>
					手机：
				</td>
				<td>
					<input class='fminpt input_2' maxlength=15 name=Form_MobileTel size=14 Value="<% If Form_MobileTel<>"" and Form_MobileTel <> "0" Then Response.Write Server.HtmlEncode(Form_MobileTel)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>OICQ号码：
				</td>
				<td class=tdbox>
					<input maxlength=10 name=Form_oicq size=36 class=fminpt Value="<% If Form_oicq<>"" Then Response.Write Server.HtmlEncode(Form_oicq)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>你的地址：
				</td>
				<td class=tdbox>
					<input maxlength=150 name=Form_address size=36 class=fminpt Value="<% If Form_address<>"" Then Response.Write Server.HtmlEncode(Form_address)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>用户头衔：
				</td>
				<td class=tdbox>
					<input maxlength=14 name=Form_UserTitle size=36 class=fminpt Value="<% If Form_UserTitle<>"" Then Response.Write Server.HtmlEncode(Form_UserTitle)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>你的性别：
				</td>
				<td class=tdbox>
					<table border=0 cellpadding=0 cellspacing=0>
						<tr>
							<td><input class=fmchkbox type=radio name=Form_sex value=男 <%If Form_sex = "男" Then Response.Write " checked"%>></td><td>男</td>
							<td><input class=fmchkbox type=radio name=Form_sex value=女 <%If Form_sex = "女" Then Response.Write " checked"%>></td><td>女</td>
							<td><input class=fmchkbox type=radio name=Form_sex value=密 <%If Form_sex = "密" Then Response.Write " checked"%>></td><td>保密</td>
		 				</tr>
		  			</table>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>用户头像：
				</td>
				<td class=tdbox>
					<input onchange="javascript:changeface();" maxlength=4 name=Form_userphoto size=6 class=fminpt Value="<% If Form_userphoto<>"" Then Response.Write Server.HtmlEncode(string(4-len(cstr(Form_userphoto)),"0")&Form_userphoto)%>">
					<span style='cursor:hand' title='查看头像代号' onclick="setface();">查看头像代号</span>
					<%If DEF_AllDefineFace = 0 or Form_FaceUrl & "" = "" Then%>
						<%If Form_userphoto<>"" and isNumeric(Form_userphoto) Then%><img name=faceimg id=faceimg src=<%=DEF_BBS_HomeUrl%>images/face/<%=string(4-len(cstr(Form_userphoto)),"0")&Form_userphoto%>.gif align=middle width=62 height=62><%Else%><img name=faceimg id=faceimg src=<%=DEF_BBS_HomeUrl%>images/null.gif align=middle><%End If%>
					<%Else%>
						<img name=faceimg id=faceimg src="<%
						If Left(Lcase(Form_FaceUrl),5) <> "http:" Then Response.Write "../"
						Response.Write htmlencode(Form_FaceUrl)%>" align=middle width=<%=Form_FaceWidth%> height=<%=Form_FaceHeight%>>
					<%End If%>
				</td>
			</tr><%If DEF_AllDefineFace <> 0 Then%>
			<tr>
				<td class=tdbox>
					<p>自定头像：
				</td>
				<td class=tdbox>
					<input onchange="javascript:changeface2();" maxlength=250 name=Form_FaceUrl size=26 class=fminpt Value="<%=HtmlEncode(Form_FaceUrl)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>头像大小：
				</td>
				<td class=tdbox>
					自定头像宽: <input onchange="javascript:changeface2();" maxlength=<%=len(DEF_AllFaceMaxWidth)%> name=Form_FaceWidth size=3 class=fminpt Value="<%=HtmlEncode(Form_FaceWidth)%>">(20-<%=DEF_AllFaceMaxWidth%>)
					高: <input onchange="javascript:changeface2();" maxlength=<%=len(DEF_AllFaceMaxWidth*2)%> name=Form_FaceHeight size=3 class=fminpt Value="<%=HtmlEncode(Form_FaceHeight)%>">(20-<%=DEF_AllFaceMaxWidth%>)
				</td>
			</tr><%End If%>
			<tr>
				<td class=tdbox>
					<p>你的生日： 
				</td>
				<td class=tdbox align="left">
					<p>
					<input maxlength=4 name=Form_byear size=4 class=fminpt Value="<% If Form_byear<>"" Then
						Response.Write Server.HtmlEncode(Form_byear)
					Else
						Response.Write "19"
					End If%>"> 年 
					<input maxlength=2 name=Form_bmonth size=2 class=fminpt Value="<% If Form_bmonth<>"" Then Response.Write Server.HtmlEncode(Form_bmonth)%>">
					月 <input maxlength=2 name=Form_bday size=2 class=fminpt Value="<% If Form_bday<>"" Then Response.Write Server.HtmlEncode(Form_bday)%>">
					日</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>签名-UBB：
				</td>
				<td class=tdbox>
					<textarea name=Form_Underwrite rows=5 cols=36 class=fmtxtra><%If Form_Underwrite <> "" Then Response.Write VbCrLf & htmlEncode(Form_Underwrite)%></textarea>
				</td>
			</tr>
			<tr>
				<td class=tdbox colspan=2 bgcolor=F7F7F7 height=25 class=TBfour>
					扩展信息</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>申请时间：
				</td>
				<td class=tdbox>
					<input maxlength=14 name=Form_ApplyTime size=14 class=fminpt Value="<% If Form_ApplyTime<>"" Then Response.Write Server.HtmlEncode(Form_ApplyTime)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>SessionID 
				</td>
				<td class=tdbox>
					<input maxlength=14 name=Form_Sessionid size=14 class=fminpt Value="<% If Form_Sessionid<>"" Then Response.Write Server.HtmlEncode(Form_Sessionid)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>在线状态：
				</td>
				<td class=tdbox>
					<input maxlength=8 name=Form_Online size=8 class=fminpt Value="<% If Form_Online<>"" Then Response.Write Server.HtmlEncode(Form_Online)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>最后登录：
				</td>
				<td class=tdbox>
					<input maxlength=14 name=Form_Prevtime size=14 class=fminpt Value="<% If Form_Prevtime<>"" Then Response.Write Server.HtmlEncode(Form_Prevtime)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>用户<%=DEF_PointsName(3)%>：
				</td>
				<td class=tdbox>
					<input maxlength=8 name=Form_UserLevel size=8 class=fminpt Value="<% If Form_UserLevel<>"" Then Response.Write Server.HtmlEncode(Form_UserLevel)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>用户IP址：
				</td>
				<td class=tdbox>
					<input maxlength=50 name=Form_IP size=36 class=fminpt Value="<% If Form_UserLevel<>"" Then Response.Write HtmlEncode(Form_IP)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>用户<%=DEF_PointsName(0)%>：
				</td>
				<td class=tdbox>
					<input maxlength=14 name=Form_Points size=14 class=fminpt Value="<% If Form_Points<>"" Then Response.Write HtmlEncode(Form_Points)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>用户<%=DEF_PointsName(2)%>：
				</td>
				<td class=tdbox>
					<input maxlength=44 name=Form_CachetValue size=14 class=fminpt Value="<%If Form_CachetValue<>"" Then Response.Write HtmlEncode(Form_CachetValue)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>用户<%=DEF_PointsName(1)%>：
				</td>
				<td class=tdbox>
					<input maxlength=14 name=Form_CharmPoint size=14 class=fminpt Value="<%If Form_CharmPoint<>"" Then Response.Write HtmlEncode(Form_CharmPoint)%>">
				</td>
			</tr>			
			<tr>
				<td class=tdbox>
					<p><%=DEF_PointsName(9)%>：</span>
				</td>
				<td class=tdbox>
					<input maxlength=255 name=Form_Officer size=36 class=fminpt Value="<% If Form_Officer<>"" Then Response.Write HtmlEncode(Form_Officer)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>最后IP址：
				</td>
				<td class=tdbox>
					<input maxlength=50 name=Form_Login_ip size=36 class=fminpt Value="<% If Form_Login_ip<>"" Then Response.Write HtmlEncode(Form_Login_ip)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p title=成功登录进论坛的次数>成功登次：
				</td>
				<td class=tdbox>
					<input maxlength=17 name=Form_Login_oknum size=36 class=fminpt Value="<% If Form_Login_oknum<>"" Then Response.Write HtmlEncode(Form_Login_oknum)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p title=持续登录失败的次数>持败登次：
				</td>
				<td class=tdbox>
					<input maxlength=17 name=Form_Login_falsenum size=36 class=fminpt Value="<% If Form_Login_falsenum<>"" Then Response.Write HtmlEncode(Form_Login_falsenum)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p title=最后一次登录使用的密码，不管正确与否>末用密码：
				</td>
				<td class=tdbox>
					<input maxlength=20 type=password name=Form_Login_lastpass size=36 class=fminpt Value="<% If Form_Login_lastpass<>"" Then Response.Write HtmlEncode(Form_Login_lastpass)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p title=最后一次成功登录进论坛所登用的ＩＰ地址>正登末IP：
				</td>
				<td class=tdbox>
					<input maxlength=50 name=Form_Login_RightIP size=36 class=fminpt Value="<% If Form_Login_RightIP<>"" Then Response.Write HtmlEncode(Form_Login_RightIP)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox bgcolor=F7F7F7 height=25 class=TBBG1>
					用户权限：</td>
				<td class=tdbox><%
				Form_UserLimit = cCur(Form_UserLimit)
				Dim TempN
	for TempN = 0 to LimitUserStringDataNum%>
			<input type="checkbox" class=fmchkbox name="Limit<%=TempN+1%>" value="1"<%If GetBinarybit(Form_UserLimit,TempN+1) = 1 Then
				Response.Write " checked>"
			Else
				Response.Write ">"
			End If%><%=LimitUserStringData(tempN)%><br>
			<%Next%></td>
			</tr>
	<tr>
		<td class=tdbox>&nbsp;</td>
		<td class=tdbox>
			<input name=submit type=submit value=" 修 改 " onclick="form_onsubmit(this.form)" class=fmbtn>
			<input name=b1 type=reset value=" 重 写 " class=fmbtn>
		</td>
	</tr>
	</table>
			<div class=frametitle>注意：</div>
			<div class=frameline>
			<ol class=listli>
			<li>特殊权限，只有拥有<%=DEF_PointsName(6)%>权限的会员才有作用，包括取消所有总固，</li>
			屏蔽某个会员IP地址，屏蔽会员发言等等．</li>
			<li>禁止删除帖子 禁止精华帖子 禁止转移帖子 删除上传附件，仅对<%=DEF_PointsName(8)%>或<%=DEF_PointsName(6)%>有效</li>
			<li><%=DEF_PointsName(8)%>一项最好不要作更改，由版面修改时自动判断产生</li>
			<li>禁止修改个人资料和帖子内容，任何会员皆有效，包括修改它人的帖子及自我资料</li>
			<li>用户权限中的允许发表HTML权限,只针对<%=DEF_PointsName(5)%>或<%=DEF_PointsName(8)%>及以上权限的用户有效</li>
			</ol>
			</div>
			<div class=frameline>
			<%DisplayOfficerList()
			DisplayLevelList()%>
			</div>
</form>
<%
End Function

Function displayAccessFull%>
	<p>修改成功，资料如下：<br>
	<br>
	</p>
	<table border=0 cellpadding="0" cellspacing="0" class=frame_table>
			<tr>
				<td class=tdbox width=120>
					<p>*用户名称： 
				</td>
				<td class=tdbox>
					<%=Server.HtmlEncode(Form_Username)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>*新的密码： 
				</td>
				<td class=tdbox>
					********
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>电子邮件： 
				</td>
				<td class=tdbox>
					<%=HtmlEncode(Form_mail)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>主页地址：
				</td>
				<td class=tdbox>
					<%=HtmlEncode(Form_homepage)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>ICQ 号码：
				</td>
				<td class=tdbox>
					<%=HtmlEncode(Form_icq)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>OICQ号码：
				</td>
				<td class=tdbox>
					<%=HtmlEncode(Form_oicq)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>你的地址：
				</td>
				<td class=tdbox>
					<%=HtmlEncode(Form_address)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>用户头衔：
				</td>
				<td class=tdbox>
					<%=HtmlEncode(Form_UserTitle)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>你的性别：
				</td>
				<td class=tdbox>
					<%=Form_sex%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>用户头像：
				</td>
				<td class=tdbox>
					<%If DEF_AllDefineFace = 0 or Form_FaceUrl = "" Then%>
					<img src=<%=DEF_BBS_HomeUrl%>images/face/<%=string(4-len(cstr(Form_userphoto)),"0")&Form_userphoto%>.gif align=middle width=62 height=62>
					<%Else%>
						<img src="<%If Left(Lcase(Form_FaceUrl),5) <> "http:" Then Response.Write "../"
						Response.Write htmlencode(Form_FaceUrl)%>" align=middle width=<%=Form_FaceWidth%> height=<%=Form_FaceHeight%>>
					<%End If%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>你的生日：
				</td>
				<td class=tdbox align="left">
					<%If len(Form_birthday)=14 Then Response.Write RestoreTime(Form_birthday)%></td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>签名-UBB：
				</td>
				<td class=tdbox>
					<table style="table-layout:fixed; word-break:break-all" width=332 border="0" cellspacing="0" cellpadding="0"><tr><td class=tdbox>
					<%=Form_PrintUnderwrite%></td></tr></table></td>
				</td>
			</tr>
			<tr>
				<td class=tdbox colspan=2 bgcolor=F7F7F7 height=25 class=TBfour>
					扩展信息</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>申请时间：
				</td>
				<td class=tdbox>
					<%If len(Form_ApplyTime)=14 Then Response.Write RestoreTime(Form_ApplyTime)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>SessionID 
				</td>
				<td class=tdbox>
					<%=HtmlEncode(Form_Sessionid)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>在线状态：
				</td>
				<td class=tdbox>
					<%=HtmlEncode(Form_Online)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>最后登录：
				</td>
				<td class=tdbox>
					<%If len(Form_birthday)=14 Then Response.Write RestoreTime(Form_Prevtime)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>用户<%=DEF_PointsName(3)%>：
				</td>
				<td class=tdbox>
					<%=Form_UserLevel%>: <%=DEF_UserLevelString(Form_UserLevel)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>用户IP址：
				</td>
				<td class=tdbox>
					<%=HtmlEncode(Form_IP)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>用户<%=DEF_PointsName(0)%>：
				</td>
				<td class=tdbox>
					<%=HtmlEncode(Form_Points)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>用户<%=DEF_PointsName(2)%>：
				</td>
				<td class=tdbox>
					<%
					Response.Write HtmlEncode(Form_CachetValue)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>用户<%=DEF_PointsName(1)%>：
				</td>
				<td class=tdbox>
					<%
					Response.Write HtmlEncode(Form_CharmPoint)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p><%=DEF_PointsName(9)%>：
				</td>
				<td class=tdbox>
					<%=Form_Officer%>: <%=DisplayOfficerString(Form_Officer)%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>最后IP址：
				</td>
				<td class=tdbox>
					<%=Form_Login_ip%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>成功登次：
				</td>
				<td class=tdbox>
					<%=Form_Login_oknum%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>持败登次：
				</td>
				<td class=tdbox>
					<%=Form_Login_falsenum%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>末用密码：
				</td>
				<td class=tdbox>
					<%=Form_Login_lastpass%>
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>正登未IP：
				</td>
				<td class=tdbox>
					<%=Form_Login_RightIP%>
				</td>
			</tr>
			</table>
<%End Function

Function saveFormData

	Dim Rs
	Set Rs = Server.CreateObject("ADODB.RecordSet")
	Rs.Open "Select * from LeadBBS_User where id=" & Form_ID,con,1,3
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		GBL_CHK_TempStr = GBL_CHK_TempStr & "发生意外错误<br>" & VbCrLf
		saveFormData = 0
		Exit Function
	End If
	Rs("UserName") = Form_UserName
	if Form_Mail <> "" then Rs("Mail") = Form_Mail
	Rs("Address") = Form_Address
	Rs("Sex") = Form_Sex
	If Form_ICQ = "" Then
		Rs("ICQ") = Null
	Else
		Rs("ICQ") = Form_ICQ
	End If
	If Form_OICQ = "" Then
		Rs("OICQ") = Null
	Else
		Rs("OICQ") = Form_OICQ
	End If
	Rs("Userphoto") = Form_Userphoto
	Rs("Homepage") = Form_Homepage
	Rs("Underwrite") = Form_Underwrite
	Rs("PrintUnderwrite") = Form_PrintUnderwrite
	If Form_Password1 <> "" Then Rs("Pass") = MD5(Form_Password1)
	If Len(Form_birthday)=14 Then
		Rs("birthday") = Form_birthday
		Dim Temp
		temp = cCur(Left(Form_birthday,4))
		If temp > 1950 and temp < 2050 Then
			Rs("NongLiBirth") = GetNongLiTimeValue(ConvertToNongLi(RestoreTime(Form_birthday)))
		Else
			'其它出生年作了略处理
			Rs("NongLiBirth") = GetTimeValue(DateAdd("m",-1,RestoreTime(Form_birthday)))
		End If
	Else
		Rs("birthday") = Null
	End If

	REM 特殊数据
	Rs("ApplyTime") = Form_ApplyTime
	Rs("IP") = Form_IP
	Rs("UserLevel") = Form_UserLevel
	Rs("Officer") = Form_Officer
	Rs("Points") = Form_Points
	Rs("Sessionid") = Form_Sessionid
	Rs("Online") = Form_Online
	Rs("Prevtime") = Form_Prevtime
	If Form_Answer <> "" Then Rs("Answer") = MD5(Form_Answer)
	Rs("Question") = Form_Question
	
	Rs("Login_ip") = Form_Login_ip
	Rs("Login_oknum") = Form_Login_oknum
	Rs("Login_falsenum") = Form_Login_falsenum
	Rs("Login_lastpass") = Form_Login_lastpass
	Rs("Login_RightIP") = Form_Login_RightIP
	if Form_MobileTel <> "" then
		Rs("MobileTel") = Form_MobileTel
	else
		Rs("MobileTel") = 0
	end if

	If DEF_AllDefineFace <> 0 Then
		Rs("FaceUrl") = Form_FaceUrl
		Rs("FaceWidth") = Form_FaceWidth
		Rs("FaceHeight") = Form_FaceHeight
	End If

	Rs("UserLimit") = Form_UserLimit
	Rs("UserTitle") = Form_UserTitle
	Rs("CachetValue") = Form_CachetValue
	Rs("CharmPoint") = Form_CharmPoint
	Rs("LockIP") = Form_LockIP

	Rs.Update
	Rs.Close
	Set Rs = Nothing
	saveFormData = 1

	Call UpdateSpecialUserTable(Form_UserLimit,Form_ID,Form_UserName)

End Function

Sub UpdateSpecialUserTable2(UserLimit,UserID,UserName,N,assort)

	Dim Rs
	Dim Flag
	
	Rem 认证会员
	Flag = GetBinarybit(UserLimit,N)
	If Flag = 0 Then
		CALL LDExeCute("Delete from LeadBBS_SpecialUser where Assort=" & assort & " and UserID=" & UserID,1)
	Else
		Set Rs = LDExeCute(sql_select("Select ID from LeadBBS_SpecialUser Where Assort=" & assort & " and UserID=" & UserID,1),0)
		If Rs.Eof Then
			Rs.Close
			Set Rs = Nothing
			CALL LDExeCute("insert into LeadBBS_SpecialUser(UserID,UserName,BoardID,Assort,ndatetime) values(" & UserID & ",'" & Replace(UserName,"'","''") & "',0," & assort & "," & GetTimeValue(DEF_Now) & ")",1)
		Else
			Rs.Close
			Set Rs = Nothing
		End If
	End If

End Sub

Function UpdateSpecialUserTable(UserLimit,UserID,UserName)

	'类型,0-认证会员,1-版主,2-总版主,3-屏蔽会员,4-禁言会员,5-禁修改会员,6-未激活,7-区版主,8-专业客户
	
	Rem 认证会员
	CALL UpdateSpecialUserTable2(UserLimit,UserID,UserName,1,6)

	Rem 非正式会员
	CALL UpdateSpecialUserTable2(UserLimit,UserID,UserName,2,0)
	
	Rem 版主
	CALL UpdateSpecialUserTable2(UserLimit,UserID,UserName,8,1)

	Rem 总版主
	CALL UpdateSpecialUserTable2(UserLimit,UserID,UserName,10,2)
	
	Rem 屏蔽会员
	CALL UpdateSpecialUserTable2(UserLimit,UserID,UserName,7,3)
	
	Rem 禁言会员
	CALL UpdateSpecialUserTable2(UserLimit,UserID,UserName,3,4)
	
	Rem 禁止修改会员
	CALL UpdateSpecialUserTable2(UserLimit,UserID,UserName,4,5)
	
	Rem 专业客户
	CALL UpdateSpecialUserTable2(UserLimit,UserID,UserName,15,8)

End Function%>