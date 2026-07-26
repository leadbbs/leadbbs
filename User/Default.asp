<!-- #include file=../inc/BBSSetup.asp -->
<!-- #include file=../inc/Board_Popfun.asp -->
<!-- #include file=inc/UserTopic.asp -->
<%
DEF_BBS_HomeUrl = "../"

Main

Sub Main

	initDatabase
	GBL_CHK_TempStr = ""
	
	BBS_SiteHead DEF_SiteNameString & " - 用户首页",0,"用户首页"
	UpdateOnlineUserAtInfo GBL_board_ID,"用户首页"

	UserTopicTopInfo("user")

	If GBL_CHK_Flag = 1 Then
		LoginAccuessFul
	Else
		If Request("submitflag")="" Then
			DisplayLoginForm("请先登录")
		Else
			DisplayLoginForm(GBL_CHK_TempStr)
		End If
	End If
	UserTopicBottomInfo
	closeDataBase
	SiteBottom

End Sub

Sub LoginAccuessFul%>

	<b>常见问题：</b>

	<div class=title>1.如何修改已经注册的资料？</div>

	<div class=value3>点击左边的<b>修改我的资料</b>就可进入修改自己的资料。</div>

	<div class=title>2.是否能修改用户名？</div>

	<div class=value3>默认功能不支持，只能另外申请新账号。</div>

	<div class=title>3.为什么要<b>退出登录</b>？</div>

	<div class=value3>登录后，你的密码资料会长期存在于未关闭的浏览器中，或是关掉后仍然保存于电脑的硬盘中，而退出登录会清除保存下来的用户信息。</div>

	<div class=title>4.登录后是否可以下次自动登录？</div>

	<div class=value3>登录后，如果不<b>退出登录</b>，并且没有清空浏览器的Cookie，以后就不需要再次登录。当然您仍可以使用<b>退出登录</b>再以其它用户身份登录。</div>

	<div class=title>5.查看我的资料</div>

	<div class=value3>查看您帐号的信息，<%=DEF_PointsName(0)%>及注册时的一切资料。</div>
    
<%End Sub%>