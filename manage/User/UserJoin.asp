<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/User_Setup.ASP"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../../inc/ubbcode.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<!--#include file="inc/User_fun.asp"-->
<!--#include file="../../inc/Limit_Fun.asp"-->
<!--#include file="../../inc/Constellation2.asp"-->
<%
ApplyFlag = 1
DEF_BBS_HomeUrl = "../../"
Form_FaceWidth = DEF_AllFaceMaxWidth
Form_FaceHeight = DEF_AllFaceMaxWidth
Dim GBL_ID
CursorLocation = 3
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass()

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("添加新用户")
If GBL_CHK_Flag=1 Then
	If Request.Form("SubmitFlag")="29d98Sasphouseasp8asphnet" Then
		GBL_CHK_TempStr = ""
		checkFormDate()
		
		If GBL_CHK_Flag = 0 Then
			Response.WRite "<div class=alert>" & GBL_CHK_TempStr & "</div>" & VbCrLf
			JoinForm()
		Else
			If saveFormData() = 1 Then
				DisplayAccessFull()
			Else
				Response.WRite "<div class=alert>" & GBL_CHK_TempStr & "</div>" & VbCrLf
				JoinForm()
			End If
		End If
	Else
		JoinForm()
	End If
Else
	DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

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
		if (temp!="" && isnum(temp)==1 && temp.length==<%=len(Cstr(DEF_faceMaxNum))%>)
		{
			if (parseInt(temp) > 0 && parseInt(temp) <= <%=DEF_faceMaxNum%>)
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
			alert("错误!此图像代号不存在!\n图像代号必须是3位数<%if len(Cstr(DEF_faceMaxNum))>3 then Response.Write "或以上"%>,比如 001 ,最大为<%=DEF_faceMaxNum%>");
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
				if(obj.Form_FaceHeight.value<20 || obj.Form_FaceHeight.value><%=DEF_AllFaceMaxWidth%>)
				{
					alert("自定义头像高度必须在20-<%=DEF_AllFaceMaxWidth%>之间！\n");
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

		if(obj.Form_password1.value=="")
		{
			alert("请输入你的密码!\n");
			ValidationPassed = false;
			obj.Form_password1.focus();
			return;
		}

		if(obj.Form_password2.value=="")
		{
			alert("请输入你的验证密码！\n");
			ValidationPassed = false;
			obj.Form_password2.focus();
			return;
		}

		if(obj.Form_password1.value!=obj.Form_password2.value)
		{
			alert("你的两次密码输入不相同！\n");
			ValidationPassed = false;
			obj.Form_password1.focus();
			return;
		}


		if(obj.Form_Question.value=="")
		{
			alert("请输入密码提示!\n");
			ValidationPassed = false;
			obj.Form_Question.focus();
			return;
		}

		if(obj.Form_Answer.value=="")
		{
			alert("请输入提示答案!\n");
			ValidationPassed = false;
			obj.Form_Answer.focus();
			return;
		}
		if(obj.Form_icq.value!="")
		{
			if (! isnum(obj.Form_icq.value))
			{
				alert("喂,你填入了ICQ框中填入了东西,但你的ICQ号码怎么不是正整数！\n");
				ValidationPassed = false;
				obj.Form_icq.focus();
				return;
			}
		}

		if(obj.Form_oicq.value!="")
		{
			if (! isnum(obj.Form_oicq.value))
			{
				alert("喂,你填入了OICQ框中填入了东西,但你的OICQ号码怎么不是正整数?\n");
				ValidationPassed = false;
				obj.Form_oicq.focus();
				return;
			}
		}

		if(obj.Form_byear.value!="")
		{
			if (! isnum(obj.Form_byear.value))
			{
				alert("喂,你填入了你的出生年,但你的年份怎么不是正整数！\n");
				ValidationPassed = false;
				obj.Form_byear.focus();
				return;
			}
		}

		if(obj.Form_bmonth.value!="")
		{
			if (! isnum(obj.Form_bmonth.value))
			{
				alert("喂,你填入了你的出生月,但你的月份怎么不是正整数！\n");
				ValidationPassed = false;
				obj.Form_bmonth.focus();
				return;
			}
		}

		if(obj.Form_bday.value!="")
		{
			if (! isnum(obj.Form_bday.value))
			{
				alert("喂,你填入了你的出生日,但你的出生日怎么不是正整数！\n");
				ValidationPassed = false;
				obj.Form_bday.focus();
				return;
			}
		}

		if(obj.Form_userphoto.value!="")
		{
			if (! isnum(obj.Form_bday.value))
			{
				alert("用户图像,只能是001-318之间的正整数！\n");
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
				alert("喂,您填入了申请时间,申请时间需要是正整数的噢！\n");
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
				alert("喂,您填入了最后登录时间,最后登录时间需要是正整数的噢！\n");
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
				if(obj.Form_FaceHeight.value<20 || obj.Form_FaceHeight.value><%=DEF_AllFaceMaxWidth%>)
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

<form action=UserJoin.asp method=post name=form1 onSubmit="return ValidationPassed">
	<div class=frameline>新用户注册</div>
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
					<p>*你的密码： 
				</td>
				<td class=tdbox>
					<input name=SubmitFlag type=hidden value="29d98Sasphouseasp8asphnet">
					<input maxLength=20 name="Form_password1" size=36 class=fminpt type=password Value="<% If Form_password1<>"" Then Response.Write Server.HtmlEncode(Form_password1)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>*验证密码： 
				</td>
				<td class=tdbox>
					<input maxlength=20 name="Form_password2" size=36 class=fminpt type=password Value="<% If Form_password2<>"" Then Response.Write Server.HtmlEncode(Form_password2)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>*电子邮件： 
				</td>
				<td class=tdbox>
					<input maxLength=60 name=Form_mail size=36 class=fminpt Value="<% If Form_mail<>"" Then Response.Write Server.HtmlEncode(Form_mail)%>">
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
					<p>*提示答案：
				</td>
				<td class=tdbox>
					<input maxlength=20 name=Form_Answer class=fminpt size=36 Value="<% If Form_Answer<>"" Then Response.Write Server.HtmlEncode(Form_Answer)%>">
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
					<input maxlength=10 name=Form_icq size=36 class=fminpt Value="<% If Form_icq<>"" Then Response.Write Server.HtmlEncode(Form_icq)%>">
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
					<input onchange="javascript:changeface();" maxlength=3 name=Form_userphoto size=3 class=fminpt Value="<% If Form_userphoto<>"" Then Response.Write Server.HtmlEncode(string(4-len(cstr(Form_userphoto)),"0")&Form_userphoto)%>">
					<span style='cursor:hand' title='查看头像代号' onclick="setface();">查看头像代号</span>
					<%If Form_userphoto<>"" and isNumeric(Form_userphoto) Then%><img name=faceimg id=faceimg src=<%=DEF_BBS_HomeUrl%>images/face/<%=string(4-len(cstr(Form_userphoto)),"0")&Form_userphoto%>.gif align=middle width=62 height=62><%Else%><img name=faceimg id=faceimg src=<%=DEF_BBS_HomeUrl%>images/null.gif align=middle><%End If%>
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
					高: <input onchange="javascript:changeface2();" maxlength=<%=len(DEF_AllFaceMaxWidth)%> name=Form_FaceHeight size=3 class=fminpt Value="<%=HtmlEncode(Form_FaceHeight)%>">(20-<%=DEF_AllFaceMaxWidth%>)
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
				<td class=tdbox colspan=2 bgcolor=F7F7F7 align=center height=25 class=TBfour>
					:::::::::::特殊资料:::::::::::</td>
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
					<input maxlength=50 name=Form_IP size=36 class=fminpt Value="<% If Form_UserLevel<>"" Then Response.Write Server.HtmlEncode(Form_IP)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p>用户<%=DEF_PointsName(0)%>：
				</td>
				<td class=tdbox>
					<input maxlength=14 name=Form_Points size=14 class=fminpt Value="<% If Form_Points<>"" Then Response.Write Server.HtmlEncode(Form_Points)%>">
				</td>
			</tr>
			<tr>
				<td class=tdbox>
					<p><%=DEF_PointsName(9)%>：
				</td>
				<td class=tdbox>
					<input maxlength=255 name=Form_Officer size=36 class=fminpt Value="<% If Form_Officer<>"" Then Response.Write Server.HtmlEncode(Form_Officer)%>">
				</td>
			</tr>
	<tr>
		<td class=tdbox>&nbsp;</td>
		<td class=tdbox>
			<input name=submit type=submit value=" 申 请 " onclick="form_onsubmit(this.form)" class=fmbtn>
			<input name=b1 type=reset value=" 重 写 " class=fmbtn>
		</td>
	</tr>
	</table>
</form>
<%
End Function

Function saveFormData

	Dim Rs
	Set Rs = Server.CreateObject("ADODB.RecordSet")
	Rs.Open "Select * from LeadBBS_User Where 1=0",con,1,3
	Rs.Addnew
	Rs("UserName") = Form_UserName
	If Form_Mail<>"" Then Rs("Mail") = Form_Mail
	If Form_Address<>"" Then Rs("Address") = Form_Address
	Rs("Sex") = Form_Sex
	If Form_ICQ<>"" Then Rs("ICQ") = Form_ICQ
	If Form_OICQ<>"" Then Rs("OICQ") = Form_OICQ
	Rs("Userphoto") = Form_Userphoto
	If Form_Homepage<>"" Then Rs("Homepage") = Form_Homepage
	If Form_Underwrite<>"" Then Rs("Underwrite") = Form_Underwrite
	If Form_PrintUnderwrite<>"" Then Rs("PrintUnderwrite") = Form_PrintUnderwrite
	Rs("Pass") = MD5(Form_Password1)
	If len(Form_birthday)=14 Then
		Rs("birthday") = Form_birthday
		Dim Temp
		temp = cCur(Left(Form_birthday,4))
		If temp > 1950 and temp < 2050 Then Rs("NongLiBirth") = GetNongLiTimeValue(ConvertToNongLi(RestoreTime(Form_birthday)))
	End If

	REM 特殊数据
	Rs("ApplyTime") = Form_ApplyTime
	Rs("IP") = Form_IP
	Rs("UserLevel") = Form_UserLevel
	Rs("Officer") = Form_Officer
	Rs("Points") = Form_Points
	Rs("Sessionid") = 0
	Rs("Online") = Form_Online
	Rs("Prevtime") = Form_Prevtime
	Rs("Answer") = MD5(Form_Answer)
	Rs("Question") = Form_Question
	If DEF_AllDefineFace <> 0 Then
		Rs("FaceUrl") = Form_FaceUrl
		Rs("FaceWidth") = Form_FaceWidth
		Rs("FaceHeight") = Form_FaceHeight
	End If
	Rs("LastAnnounceID") = 0
	Rs("AnnounceNum2") = 0
	Rs.Update
	Form_ID = Rs("ID")
	Rs.Close
	Set Rs = Nothing
	CALL LDExeCute("Update LeadBBS_SiteInfo Set UserCount=UserCount+1",1)
	UpdateStatisticDataInfo 1,1,1
	saveFormData = 1

End Function

Function DisplayAccessFull%>

	<p><b>添加成功，<a href=UserModify.asp?Form_ID=<%=Form_ID%>>点击这里修改资料</a>!</b><br>
	<br>
	</p>

<%End Function%>