<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="../inc/User_Setup.asp"-->
<!--#include file="../inc/Board_Popfun.asp"-->
<!--#include file="inc/UserTopic.asp"-->
<!--#include file="../inc/Limit_Fun.asp"-->
<!--#include file="inc/Mail_fun.asp"-->
<!--#include file="inc/UserGetPass_Fun.asp"-->
<!--#include file="inc/UserActive_Fun.asp"-->
<%
Response.Expires = 0 
Response.ExpiresAbsolute = DEF_Now - 1
Response.AddHeader "pragma","no-cache"
Response.AddHeader "cache-control","private" 
Response.CacheControl = "no-cache"

DEF_BBS_HomeUrl = "../"

Main()

Sub Main

	initDatabase()
	GBL_CHK_TempStr = ""
	
	BBS_SiteHead DEF_SiteNameString & " - 帐号安全",0,"帐号安全"

	Boards_Body_Head("")

	%>
	<div class="alertbox user_secret">
	<%
	Main_GetPass()
	%>
	</div>
	<%
	
	Boards_Body_Bottom()
	closeDataBase()
	SiteBottom()

End Sub

sub getpass_menu
%>
<br>
<hr class=splitline>
<br>
	<div class="title">
<!--
	激活相关：
	<a href=UserGetPass.asp?act=send&gettype=1 class=bluefont>重发激活码</a>
	 - <a href=UserGetPass.asp?act=active class=bluefont>用户激活</a>
	 <br>找回密码办法：
	 <a href=UserGetPass.asp class=bluefont>使用密保找回</a>
	<%
	if DEF_User_GetPassMode = 3 then response.write " - <a href=UserGetPass.asp?act=send class=bluefont>使用邮箱找回</a>"
	if DEF_User_GetPassMode = 4 then response.write " - <a href=UserGetPass.asp?act=send class=bluefont>使用邮箱或手机号码找回</a>"
	%>
	<%if DEF_User_GetPassMode > 0 then%>
	 <%
	end if%>
	<br>若已收到重置认证码：
	 <a href=UserGetPass.asp?act=reset class=bluefont>重置密码</a>
	 <br>
<hr class=splitline>
<br>
-->
	 激活帐号流程：<a href=<%=DEF_RegisterFile%>>注册</a>
	  > 收到邮箱或手机的激活码 > 
	  <a href=UserGetPass.asp?act=active>激活帐户</a>，<a href=UserGetPass.asp?act=send&gettype=1 class=bluefont>点此重发激活码</a><br>
	 找回帐号流程：
	 <a href=UserGetPass.asp?act=send>使用邮箱或手机找回</a>
	  > 邮箱或手机收到重置码 > 
	  <a href=UserGetPass.asp?act=reset>输入重置码并更改密码</a><br>
	 <br><a href=UserGetPass.asp>你也可以使用密保来更改密码</a>
	</div>
<%
end sub

Sub Main_GetPass

	Select Case Left(Request("act"),10)
		Case "active"
			Dim UserActive
			Set UserActive = New User_UserActive
			UserActive.DisplayActive
			Set UserActive = Nothing
		Case else
			Dim UserGetPass
			Set UserGetPass = New User_GetPass
			UserGetPass.GetPass
			Set UserGetPass = Nothing
			getpass_menu()
	End Select

End Sub%>