<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Const MaxLinkNum = 100
initDatabase()
GBL_CHK_TempStr = ""
CheckSupervisorPass()

Dim Form_SavePoints
Dim Form_DEF_ManageDir
Dim Form_DEF_BBS_Name
Dim Form_DEF_BBS_MaxLayer,Form_DEF_UsedDataBase,Form_DEF_BBS_SearchMode

Dim Form_DEF_BBS_AnnouncePoints,Form_DEF_BBS_PrizeAnnouncePoints,Form_DEF_BBS_MakeGoodAnnouncePoints,Form_DEF_BBS_MaxTopAnnounce,Form_DEF_BBS_MaxAllTopAnnounce
Dim Form_DEF_BBS_DisplayTopicLength,Form_DEF_BBS_ScreenWidth,Form_DEF_BBS_LeftTDWidth
Dim Form_DEF_MasterCookies,Form_DEF_SiteNameString
Dim Form_DEF_SupervisorUserName,Form_DEF_MaxTextLength

Dim Form_DEF_MaxListNum,Form_DEF_TopicContentMaxListNum
Dim Form_DEF_MaxJumpPageNum,Form_DEF_DisplayJumpPageNum
Dim Form_DEF_MaxBoardMastNum
Dim Form_DEF_EnableUserHidden,Form_DEF_VOTE_MaxNum
Dim Form_DEF_MaxLoginTimes,Form_DEF_EnableUpload,Form_DEF_EnableGFL
Dim Form_DEF_UserOnlineTimeOut,Form_DEF_faceMaxNum
Dim Form_DEF_AllDefineFace,Form_DEF_AllFaceMaxWidth
Dim Form_DEF_BBS_EmailMode,Form_DEF_EnableAttestNumber,Form_DEF_AttestNumberPoints
Dim Form_DEF_EnableUnderWrite,Form_DEF_NeedOnlineTime
Dim Form_DEF_EnableForbidIP,Form_DEF_TopAdString
Dim Form_DEF_RestSpaceTime,Form_DEF_LoginSpaceTime,Form_DEF_AccessDatabase,Form_DEF_SiteHomeUrl
Dim Form_DEF_DefaultStyle
Dim Form_DEF_EnableFlashUBB,Form_DEF_EnableImagesUBB,Form_DEF_AnnounceFontSize,Form_DEF_EditAnnounceDelay
Dim Form_DEF_DisplayOnlineUser,Form_DEF_EnableSpecialTopic,Form_DEF_UBBiconNumber,Form_DEF_EnableDelAnnounce
Dim Form_DEF_PointsName,Form_DEF_EnableMakeTopAnc,Form_DEF_EnableDatabaseCache
Dim Form_DEF_WriteEventSpace,Form_DEF_EditAnnounceExpires
Dim Form_DEF_RepeatLoginTimeOut,Form_DEF_FSOString,Form_DEF_Now
Redim Form_DEF_PointsName(Ubound(DEF_PointsName))
Dim Form_DEF_LineHeight,Form_DEF_RegisterFile,Form_DEF_LimitTitle,Form_DEF_DownKey

Dim Form_DEF_UpdateInterval,Form_DEF_BottomInfo,Form_DEF_GBL_Description

Dim DEF_PointsNameBak
DEF_PointsNameBak = Array("积分","魅力","威望","等级","经验","认证会员","总版主","区版主","论坛版主","荣誉","专业用户")

Dim DEF_Sideparameter_String,Form_DEF_Sideparameter
DEF_Sideparameter_String = Array("侧栏设置","1|侧栏-首页禁止显示","2|侧栏-首页允许显示的情况下默认关闭状态(用户可通过点击显示)","3|侧栏-版面开启显示","4|侧栏-版面开启显示的情况下默认关闭状态(用户可通过点击显示)","其它选项","5|版块-版块帖子多页回复链接显示详细页(默认仅显示尾页)","6|启用版块在线人数(禁止后将不再始终跟踪用户当前处于哪个版面)","7|启用LeadBBS.bbsCode编码转换","8|<span class=grayfont>保留项</span>","9|<span class=grayfont>保留项</span>","10|启用互联帐号功能(比如腾讯QQ互联,需要配置扩展参数)","11|<span class=grayfont>保留项</span>","12|<span class=grayfont>保留项</span>","13|<span class=grayfont>保留项</span>","14|<span class=grayfont>保留项</span>","15|<span class=grayfont>保留项</span>","16|启用Rewrite伪静态(启用此项，确保空间已正确安装并设置Rewrite)","17|启用版面侧栏的版块导航","18|启用查看帖子页面侧栏的版块导航","19|版块主题列表默认仅显示作者","20|关闭返回顶部按钮","21|开启帖子多媒体跨站解析(支持youku,56,tudou,xiami)","22|禁止用户昵称修改","23|HTTP自动转址到HTTPS访问(务必确认HTTPS网址可以正常访问)")

GetDefaultValue()

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("论坛参数设置")
If GBL_CHK_Flag=1 Then
	SiteLink()
Else
	DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

Function SiteLink

%>
<form name="pollform3sdx" method="post" action="SiteSetup.asp">
<input type="hidden" name="SubmitFlag" value=yes>
<p>
		设置：<span class=grayfont>论坛常用参数</span> <a href=UploadSetup.asp>上传参数</a>
		<a href=../User/UserSetup.asp>用户注册参数</a>
		<a href=UbbcodeSetup.asp>UBB编码参数</a>
		<br>
		<span class=grayfont>(下面为网站参数，请注意修改，错误的设置将会发生严重错误)<br><br>
		如果在设置后发现网站不能正常运行，请将LeadBBS最新版的BBSSetup.asp覆盖回去</span>
</p>
<%If Request.Form("SubmitFlag") <> "" Then
	CheckLinkValue()
End If%>
<b><span class=redfont><%=GBL_CHK_TempStr%></span></b>
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
			<td class=tdbox width=120>论坛名称</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_BBS_Name" maxlength="30" size="30" value="<%=htmlencode(Form_DEF_BBS_Name)%>"><span class=note>(最长255字)</span></td>
		</tr>
		<tr>
			<td class=tdbox>论坛奖罚<br>点数剩余</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_SavePoints" maxlength="14" size="30" value="<%=htmlencode(Form_SavePoints)%>"><br><span class=note>(所有版主以上人员对发帖者所进行的奖罚点数使用总值，不管奖罚一律减去指定点数，使用中自动减少，直到零或零下为止)</span></td>
		</tr>
		<tr>
			<td class=tdbox>管理目录</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_ManageDir" maxlength="30" size="30" value="<%=htmlencode(Form_DEF_ManageDir)%>"><span class=note>(论坛使用的目录，默认为manage，注意真实的管理目录与此保持一至)</span></td>
		</tr>
		<tr class=TBBG1>
			<td class=tdbox colspan=2>其它参数</td>
		</tr>
		<tr>
			<td class=tdbox>回复级数</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_BBS_MaxLayer" maxlength="255" size="10" value="<%=htmlencode(Form_DEF_BBS_MaxLayer)%>"><span class=note>(树状浏览时显示的最大回复级数，大于的作为最大级数处理，起美化作用)</span></td>
		</tr>
		<tr>
			<td class=tdbox>数 据 库</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_UsedDataBase value=1<%If Form_DEF_UsedDataBase = 1 Then%> checked<%End If%>></td><td>Access</td>
          		<td>
          			<input class=fmchkbox type=radio name=Form_DEF_UsedDataBase value=0<%If Form_DEF_UsedDataBase = 0 Then%> checked<%End If%>>
          		</td>
          		<td>Microsoft SQL Server</td>
          		<td>
          			<input class=fmchkbox type=radio name=Form_DEF_UsedDataBase value=2<%If Form_DEF_UsedDataBase = 2 Then%> checked<%End If%>>
          		</td>
          		<td>MySQL</td>
          		<td><span class=note>&nbsp; (支持ACCESS与MSSQL两种数据库，<span class=redfont>请小心设置</span>)</span></td></tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>搜索模式</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_BBS_SearchMode value=0<%If Form_DEF_BBS_SearchMode = 0 Then%> checked<%End If%>></td><td>不允许搜索</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_BBS_SearchMode value=1<%If Form_DEF_BBS_SearchMode = 1 Then%> checked<%End If%>></td><td>模糊查询</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_BBS_SearchMode value=2<%If Form_DEF_BBS_SearchMode = 2 Then%> checked<%End If%>></td><td>全文检索(仅MSSQL，请注意是否已经安装全文服务)</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>发帖奖励</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_BBS_AnnouncePoints" maxlength="4" size="10" value="<%=htmlencode(Form_DEF_BBS_AnnouncePoints)%>"><span class=note>(发帖奖励<%=DEF_PointsName(0)%>点数)</span></td>
		</tr>
		<tr>
			<td class=tdbox>评价惩罚</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_BBS_PrizeAnnouncePoints" maxlength="4" size="10" value="<%=htmlencode(Form_DEF_BBS_PrizeAnnouncePoints)%>"><span class=note>(最多允许评价<%=DEF_PointsName(1)%>及奖励惩罚<%=DEF_PointsName(0)%>，设为零表示禁止)</span></td>
		</tr>
		<tr>
			<td class=tdbox>精华奖励</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_BBS_MakeGoodAnnouncePoints" maxlength="4" size="10" value="<%=htmlencode(Form_DEF_BBS_MakeGoodAnnouncePoints)%>"><span class=note>(精华帖子加<%=DEF_PointsName(0)%>点数)</span></td>
		</tr>
		<tr>
			<td class=tdbox>最多顶帖</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_BBS_MaxTopAnnounce" maxlength="4" size="10" value="<%=htmlencode(Form_DEF_BBS_MaxTopAnnounce)%>"><span class=note>(每版面最多允许置顶的帖子数)</span></td>
		</tr>
		<tr>
			<td class=tdbox>最多总固</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_BBS_MaxAllTopAnnounce" maxlength="2" size="10" value="<%=htmlencode(Form_DEF_BBS_MaxAllTopAnnounce)%>"><span class=note>(论坛允许的最多总固顶帖)</span></td>
		</tr>
		<tr>
			<td class=tdbox>主题长度</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_BBS_DisplayTopicLength" maxlength="3" size="10" value="<%=htmlencode(Form_DEF_BBS_DisplayTopicLength)%>"><span class=note>(显示帖子主题的长度，比如论坛帖子列表，单位字节)</span></td>
		</tr>
		<tr>
			<td class=tdbox>论坛宽度</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_BBS_ScreenWidth" maxlength="10" size="10" value="<%=htmlencode(Form_DEF_BBS_ScreenWidth)%>"><span class=note>(ＢＢＳ的宽度，可以是百分比)</span></td>
		</tr>
		<tr>
			<td class=tdbox>左栏宽度</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_BBS_LeftTDWidth" maxlength="10" size="10" value="<%=htmlencode(Form_DEF_BBS_LeftTDWidth)%>"><span class=note>(ＢＢＳ的左栏宽度，可以是百分比)</span></td>
		</tr>
		<tr>
			<td class=tdbox>Cookies </td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_MasterCookies" maxlength="20" size="20" value="<%=htmlencode(Form_DEF_MasterCookies)%>"><span class=note>(安装Cookie主名称前辍)</span></td>
		</tr>
		<tr>
			<td class=tdbox>网站名称</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_SiteNameString" maxlength="255" size="20" value="<%=htmlencode(Form_DEF_SiteNameString)%>"><span class=note>(论坛网站的名称)</span></td>
		</tr>
		<tr>
			<td class=tdbox>管 理 员</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_SupervisorUserName" maxlength="255" size="20" value="<%=htmlencode(Form_DEF_SupervisorUserName)%>"><span class=redfont>(请注意大小写，设置后请重新登录，多管理员逗号分隔)</span></td>
		</tr>
		<tr>
			<td class=tdbox>内容长度</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_MaxTextLength" maxlength="6" size="10" value="<%=htmlencode(Form_DEF_MaxTextLength)%>"><span class=note>(比如帖子内容、短消息长度，管理员允许发表此值四倍长内容，单位字节)</span></td>
		</tr>
		<tr>
			<td class=tdbox>显示记录</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_MaxListNum" maxlength="3" size="10" value="<%=htmlencode(Form_DEF_MaxListNum)%>"><span class=note>(默认分页列出的最大记录数)</span></td>
		</tr>
		<tr>
			<td class=tdbox>显示帖子</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_TopicContentMaxListNum" maxlength="3" size="10" value="<%=htmlencode(Form_DEF_TopicContentMaxListNum)%>"><span class=note>(查看主题每页显示帖子数，相关帖子显示数)</span></td>
		</tr>
		<tr>
			<td class=tdbox>最大页数</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_MaxJumpPageNum" maxlength="5" size="10" value="<%=htmlencode(Form_DEF_MaxJumpPageNum)%>"><span class=note>(当数量比较大时，限制用户其最大可查看到的页数，建议低请求站点3000，中请求1000，高请求500)</span></td>
		</tr>
		<tr>
			<td class=tdbox>显示跳转</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_DisplayJumpPageNum" maxlength="3" size="10" value="<%=htmlencode(Form_DEF_DisplayJumpPageNum)%>"><span class=note>(显示跳转页数，注意不要大于最多允许直接跳转页数)</span></td>
		</tr>
		<tr>
			<td class=tdbox>版主限制</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_MaxBoardMastNum" maxlength="3" size="10" value="<%=htmlencode(Form_DEF_MaxBoardMastNum)%>"><span class=note>(每版版主最多允许数目)</span></td>
		</tr>
		<tr>
			<td class=tdbox>隐身设置</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr><td><input class=fmchkbox type=radio name=Form_DEF_EnableUserHidden value=1<%If Form_DEF_EnableUserHidden = 1 Then%> checked<%End If%>></td><td>允许</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableUserHidden value=0<%If Form_DEF_EnableUserHidden = 0 Then%> checked<%End If%>></td><td>禁止</td><td><span class=note>&nbsp; (是否允许在线用户隐身)</span></td></tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>投票项目</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_VOTE_MaxNum" maxlength="3" size="10" value="<%=htmlencode(Form_DEF_VOTE_MaxNum)%>"><span class=note>(最大投票项目)</span></td>
		</tr>
		<tr>
			<td class=tdbox>登录次数</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_MaxLoginTimes" maxlength="6" size="10" value="<%=htmlencode(Form_DEF_MaxLoginTimes)%>"><span class=note>(允许某一用户重复的错误登录次数)</span></td>
		</tr>
		<tr>
			<td class=tdbox>动作间隔</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_RestSpaceTime" maxlength="6" size="10" value="<%=htmlencode(Form_DEF_RestSpaceTime)%>"><span class=note>(进行某些动作需要的时间间隔，例如发帖，短信等，单位秒)</span></td>
		</tr>
		<tr>
			<td class=tdbox>登录间隔</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_LoginSpaceTime" maxlength="6" size="10" value="<%=htmlencode(Form_DEF_LoginSpaceTime)%>"><span class=note>用户登录累积错误过多后将要锁定登录的时间</span></td>
		</tr>
		<tr>
			<td class=tdbox>上传权限</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_EnableUpload value=0<%If Form_DEF_EnableUpload = 0 Then%> checked<%End If%>></td><td>不可以上传</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableUpload value=1<%If Form_DEF_EnableUpload = 1 Then%> checked<%End If%>></td><td>全部人可以上传</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableUpload value=2<%If Form_DEF_EnableUpload = 2 Then%> checked<%End If%>></td><td>仅管理员可上传</td>
          </tr>
          <tr>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableUpload value=3<%If Form_DEF_EnableUpload = 3 Then%> checked<%End If%>></td><td>仅版主及以上可上传</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableUpload value=4<%If Form_DEF_EnableUpload = 4 Then%> checked<%End If%>></td><td>仅<%=DEF_PointsName(5)%>可上传</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableUpload value=5<%If Form_DEF_EnableUpload = 5 Then%> checked<%End If%>></td><td>仅<%=DEF_PointsName(5)%>及版主以上可上传</td>
          		</tr></table><span class=note>这里仅指上传附件</span></td>
		</tr>
		<tr>
			<td class=tdbox>图像组件</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_EnableGFL value=1<%If Form_DEF_EnableGFL = 1 Then%> checked<%End If%>></td><td>允许使用AspJpeg组件</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableGFL value=0<%If Form_DEF_EnableGFL = 0 Then%> checked<%End If%>></td><td>禁止使用</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>在线超时</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_UserOnlineTimeOut" maxlength="6" size="10" value="<%=htmlencode(Form_DEF_UserOnlineTimeOut)%>"><span class=note>(在线用户在指定时间内不进行任何访问，则会离线，单位秒)</span></td>
		</tr>
		<tr>
			<td class=tdbox>头像个数</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_faceMaxNum" maxlength="6" size="10" value="<%=htmlencode(Form_DEF_faceMaxNum)%>"><span class=note>(论坛默认头像的个数)</span></td>
		</tr>
		<tr>
			<td class=tdbox>自定头像</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_AllDefineFace value=0<%If Form_DEF_AllDefineFace = 0 Then%> checked<%End If%>></td><td>禁止自定义头像</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_AllDefineFace value=1<%If Form_DEF_AllDefineFace = 1 Then%> checked<%End If%>></td><td>允许自定义任何头像</td>
          	 	</tr>
          	 	<tr>
          		<td><input class=fmchkbox type=radio name=Form_DEF_AllDefineFace value=2<%If Form_DEF_AllDefineFace = 2 Then%> checked<%End If%>></td><td>允许站内图片，但不允许引用站外图片作为头像</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_AllDefineFace value=3<%If Form_DEF_AllDefineFace = 3 Then%> checked<%End If%>></td><td>允许引用站外图片但不允许上传图片作为头像</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>头像大小</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_AllFaceMaxWidth" maxlength="3" size="10" value="<%=htmlencode(Form_DEF_AllFaceMaxWidth)%>"><span class=note>(自定义头像的最大长度和宽度，单位像素)</span></td>
		</tr>
		<tr>
			<td class=tdbox>邮件设置</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_BBS_EmailMode value=0<%If Form_DEF_BBS_EmailMode = 0 Then%> checked<%End If%>></td><td>禁止邮件发送</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_BBS_EmailMode value=1<%If Form_DEF_BBS_EmailMode = 1 Then%> checked<%End If%>></td><td>使用EasyMail发送</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_BBS_EmailMode value=2<%If Form_DEF_BBS_EmailMode = 2 Then%> checked<%End If%>></td><td>使用Jmail发送</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_BBS_EmailMode value=3<%If Form_DEF_BBS_EmailMode = 3 Then%> checked<%End If%>></td><td>使用CDO发送</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>验 证 码</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<tr><td colspan=4><b>1.全部禁用</b></td></tr>
				<td width=5><input class=fmchkbox type=radio name=Form_DEF_EnableAttestNumber value=0<%If Form_DEF_EnableAttestNumber = 0 Then%> checked<%End If%>></td><td colspan=3>禁用</td>
				</tr>
				<tr><td colspan=4><b>2.仅启用密码论坛认证码功能</b></td></tr>
				<tr>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableAttestNumber value=1<%If Form_DEF_EnableAttestNumber = 1 Then%> checked<%End If%>></td><td>使用ASPJPEG组件</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableAttestNumber value=2<%If Form_DEF_EnableAttestNumber = 2 Then%> checked<%End If%>></td><td>使用无组件生成验证码</td>
          		</tr>
				<tr><td colspan=4><b>3.启用全部认证码功能(发帖，新用户注册，登录及发帖等部分)</b></td></tr>
          		<tr>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableAttestNumber value=3<%If Form_DEF_EnableAttestNumber = 3 Then%> checked<%End If%>></td><td>使用ASPJPEG组件</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableAttestNumber value=4<%If Form_DEF_EnableAttestNumber = 4 Then%> checked<%End If%>></td><td>使用无组件生成验证码</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>验证码２</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_AttestNumberPoints" maxlength="12" size="10" value="<%=htmlencode(Form_DEF_AttestNumberPoints)%>"><span class=note>(当开通发帖需要验证码功能时，若用户<%=DEF_PointsName(0)%>大于此值时可免使用验证码．若定义为0时默认即此值无效)</span></td>
		</tr>
		<tr>
			<td class=tdbox>签名设置</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_EnableUnderWrite value=0<%If Form_DEF_EnableUnderWrite = 0 Then%> checked<%End If%>></td><td>禁止使用签名</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableUnderWrite value=1<%If Form_DEF_EnableUnderWrite = 1 Then%> checked<%End If%>></td><td>允许使用签名</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td>在线时间</td>
			<td><input class=fminpt type="text" name="Form_DEF_NeedOnlineTime" maxlength="10" size="10" value="<%=htmlencode(Form_DEF_NeedOnlineTime)%>"><span class=note>(行使某些权限所需要的总在线时间，比如发帖，设为0表示无限制，单位秒)</span></td>
		</tr>
		<tr>
			<td>ＩＰ屏蔽</td>
			<td><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_EnableForbidIP value=0<%If Form_DEF_EnableForbidIP = 0 Then%> checked<%End If%>></td><td>关闭屏蔽</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableForbidIP value=1<%If Form_DEF_EnableForbidIP = 1 Then%> checked<%End If%>></td><td>启用屏蔽</td>
          		<td>&nbsp; (<span class=note>如果没必要屏蔽ＩＰ地址，可以关闭来提高网站速度</span>)</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>顶部广告</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_TopAdString" maxlength="4096" size="50" value="<%=htmlencode(Form_DEF_TopAdString)%>"><span class=note>(使用HTML语法)</span></td>
		</tr>
		<tr>
			<td class=tdbox>数 据 库</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_AccessDatabase" maxlength="255" size="20" value="<%=htmlencode(Form_DEF_AccessDatabase)%>"><span class=note>(Access数据库的存放路径，相对于根目录，前面不用加/号)</span></td>
		</tr>
		<tr>
			<td class=tdbox>网站首页</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_SiteHomeUrl" maxlength="255" size="20" value="<%=htmlencode(Form_DEF_SiteHomeUrl)%>"><span class=note>(首页地址，请用绝对路径，不填为默认为论坛首页)</span></td>
		</tr>
		<tr>
			<td class=tdbox>默认风格</td>
			<td class=tdbox>
				<input class=fminpt type="text" id="Form_DEF_DefaultStyle" name="Form_DEF_DefaultStyle" maxlength="8" size="10" value="<%=htmlencode(Form_DEF_DefaultStyle)%>">
				<select name=local onchange="$id('Form_DEF_DefaultStyle').value=this.value;">
				<%Dim N	
				for N = 0 to DEF_BoardStyleStringNum
					Response.Write "<option value=" & N
					If N = DEF_DefaultStyle Then Response.Write " selected"
					Response.Write ">" & DEF_BoardStyleString(N) & "</option>" & VbCrLf
				Next%></select><span class=note>(进入网站时默认的显示风格,扩展风格请直接填写编号)</span></td>
		</tr>
		<tr>
			<td class=tdbox>多 媒 体</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_EnableFlashUBB value=0<%If Form_DEF_EnableFlashUBB = 0 Then%> checked<%End If%>></td><td>禁止</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableFlashUBB value=1<%If Form_DEF_EnableFlashUBB = 1 Then%> checked<%End If%>></td><td>允许</td>
          		<td>&nbsp; (<span class=note>是否允许插入Flash，Real，mp3，asf等多媒体文件UBB标签</span>)</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td>插入图片</td>
			<td><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_EnableImagesUBB value=0<%If Form_DEF_EnableImagesUBB = 0 Then%> checked<%End If%>></td><td>禁止</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableImagesUBB value=1<%If Form_DEF_EnableImagesUBB = 1 Then%> checked<%End If%>></td><td>允许</td>
          		<td>&nbsp; (<span class=note>是否允许在帖子签名中插入图片文件</span>)</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>内容字体</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_AnnounceFontSize" maxlength="100" size="20" value="<%=htmlencode(Form_DEF_AnnounceFontSize)%>">
			<span class=note>(帖子内容文字大小或其它属性(比如字体)，建议填写12px或14px，填写“14px;FONT-FAMILY:黑体;” 表示显示为14像素黑体字)</span></td>
		</tr>
		<tr>
			<td class=tdbox>编辑间隔</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_EditAnnounceDelay" maxlength="8" size="10" value="<%=htmlencode(Form_DEF_EditAnnounceDelay)%>"><span class=note>(用户在发表帖子某段时间内编辑，不印上编辑痕迹，单位秒)</span></td>
		</tr>
		<tr>
			<td class=tdbox>编辑到期</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_EditAnnounceExpires" maxlength="8" size="10" value="<%=htmlencode(Form_DEF_EditAnnounceExpires)%>"><span class=note>(用户在发表帖子某段时间后将禁止编辑，单位秒，设为0表示一直允许)</span></td>
		</tr>
		<tr>
			<td class=tdbox>在线会员</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_DisplayOnlineUser value=0<%If Form_DEF_DisplayOnlineUser = 0 Then%> checked<%End If%>></td><td>完全禁止</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_DisplayOnlineUser value=1<%If Form_DEF_DisplayOnlineUser = 1 Then%> checked<%End If%>></td><td>允许点击调用显示</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_DisplayOnlineUser value=2<%If Form_DEF_DisplayOnlineUser = 2 Then%> checked<%End If%>></td><td>直接显示在线人员</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_DisplayOnlineUser value=3<%If Form_DEF_DisplayOnlineUser = 3 Then%> checked<%End If%>></td><td>首页直接显示，版面调用显示</td>
          		</tr></table>
          		&nbsp;(<span class=note>是否允许显示在线会员调用</span>)</td>
		</tr>
		<tr>
			<td class=tdbox>特殊帖子</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_EnableSpecialTopic value=0<%If Form_DEF_EnableSpecialTopic = 0 Then%> checked<%End If%>></td><td>禁止</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableSpecialTopic value=1<%If Form_DEF_EnableSpecialTopic = 1 Then%> checked<%End If%>></td><td>允许</td>
          		<td>&nbsp; (<span class=note>是否允许发表回复可见帖和购买帖，禁止的话，则所有版面禁止发表(即使版面设成允许)</span>)</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>表情数目</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_UBBiconNumber" maxlength="8" size="2" value="<%=htmlencode(Form_DEF_UBBiconNumber)%>"><span class=note>(允许选择的表情图片的个数，设为0表示禁止使用插入表情)</span></td>
		</tr>
		<tr>
			<td class=tdbox>回 收 站</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_EnableDelAnnounce value=0<%If Form_DEF_EnableDelAnnounce = 0 Then%> checked<%End If%>></td><td>开启</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableDelAnnounce value=1<%If Form_DEF_EnableDelAnnounce = 1 Then%> checked<%End If%>></td><td>禁止</td>
          		<td>&nbsp; (<span class=note>开启回收站，将不能直接删除主题帖子(回复帖仍然可以随意删除)，而是转移到回收站版面，注意要先创建回收站版块，版面编号是444。</span>)</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>名称设定</td>
			<td class=tdbox>
				<table border=0 cellpadding=1 cellspacing=0>
				<tr>
					<td>&nbsp;序号</td>
					<td>&nbsp;名称</td>
					<td>&nbsp;默认名称</td>
				</td><%
			For n = 0 to Ubound(DEF_PointsName)
				%>
				<tr>
					<td>&nbsp;<%=Right(" " & N,2)%></td>
					<td>&nbsp;<input class=fminpt type="text" name="Form_DEF_PointsName<%=N%>" maxlength="18" size="20" value="<%=htmlencode(Form_DEF_PointsName(n))%>"></td>
					<td>&nbsp;<%=DEF_PointsNameBak(N)%></td>
				</td>
				<%
			Next
			%>
				</table></td>
		</tr>
		<tr>
			<td class=tdbox>回复提帖</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_EnableMakeTopAnc value=0<%If Form_DEF_EnableMakeTopAnc = 0 Then%> checked<%End If%>></td><td>否</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableMakeTopAnc value=1<%If Form_DEF_EnableMakeTopAnc = 1 Then%> checked<%End If%>></td><td>是</td>
          		<td>&nbsp; (<span class=note>回复或回帖时是否将主题提到版面最前位置</span>)</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>ＤＢ缓冲</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_EnableDatabaseCache value=0<%If Form_DEF_EnableDatabaseCache = 0 Then%> checked<%End If%>></td><td>否</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_EnableDatabaseCache value=1<%If Form_DEF_EnableDatabaseCache = 1 Then%> checked<%End If%>></td><td>是</td>
          		<td>&nbsp; (<span class=note>是否启用数据库连接缓存</span>)</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>写入间隔</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_WriteEventSpace" maxlength="8" size="2" value="<%=htmlencode(Form_DEF_WriteEventSpace)%>"><span class=note>(设置一些写入动作的间隔，比如修改帖，验证等，建议设成1-5秒之间，0表示无限制，设置正当的值可以有效防止恶的写入操作，从而达到保护服务器硬盘的目的)</span></td>
		</tr>
		<tr>
			<td class=tdbox>重复登录</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_RepeatLoginTimeOut" maxlength="8" size="8" value="<%=htmlencode(Form_DEF_RepeatLoginTimeOut)%>"><span class=note>(此参数用来设置防止重复登录，一账号多人用的情况．某人登录后，其它人则无法再进行登录．设成0或大于在线超时，则无效，建议设置值为300-1800[5-30]分钟，单位秒)</span></td>
		</tr>
		<tr>
			<td class=tdbox>FSO组件</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_FSOString" maxlength="50" size="25" value="<%=htmlencode(Form_DEF_FSOString)%>">
			<br><span class=note>(自定义FSO内置组件字符串，默认为Scripting.FileSystemObject，设成空表示禁用FSO)</span></td>
		</tr>
		<tr>
			<td class=tdbox>时差设置</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_Now" maxlength="50" size="25" value="<%=htmlencode(Form_DEF_Now)%>"><br><span class=note>(单位：分钟．正数为服务器时间加上指定分钟，负数为服务器时间减去指定分钟)</span></td>
		</tr>
		<tr>
			<td class=tdbox>列表高度</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_LineHeight" maxlength="8" size="8" value="<%=htmlencode(Form_DEF_LineHeight)%>"><span class=note>(显示的帖子,以及短消息等列表的列高度)</span></td>
		</tr>
		<tr>
			<td class=tdbox>注册文件</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_RegisterFile" maxlength="50" size="25" value="<%=htmlencode(Form_DEF_RegisterFile)%>">
			<br><span class=note>(自定义注册用户时使用的文件名[User目录下面]默认为NewUser.asp，如空间有改文件名权限则自动改名，必须为.asp扩展名)</span></td>
		</tr>
		<tr>
			<td class=tdbox>标题加密</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=Form_DEF_LimitTitle value=0<%If Form_DEF_LimitTitle = 0 Then%> checked<%End If%>></td><td>禁止</td>
          		<td><input class=fmchkbox type=radio name=Form_DEF_LimitTitle value=1<%If Form_DEF_LimitTitle = 1 Then%> checked<%End If%>></td><td>启用</td>
          		<td>&nbsp; (<span class=note>设置一些限制版面的帖子标题是否按正常内容显示，若设置为加密则只提示受到限制</span>)</td>
          		</tr></table></td>
		</tr>
		<tr>
			<td class=tdbox>下载附件密钥</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_DownKey" maxlength="50" size="20" value="<%=htmlencode(Form_DEF_DownKey)%>">
			<span class=note>(下载附件需要的验证字符串)</span></td>
		</tr>
		<tr>
			<td class=tdbox>网站底部信息</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_BottomInfo" maxlength="500" size="55" value="<%=htmlencode(Form_DEF_BottomInfo)%>">
			<span class=note>(网站底部信息添加,比如ICP信息 支持HTML)</span></td>
		</tr>
		<tr>
			<td class=tdbox>缓存刷新间隔</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_UpdateInterval" maxlength="8" size="8" value="<%=htmlencode(Form_DEF_UpdateInterval)%>"><span class=note>(论坛缓存文件刷新的间隔时间 单位秒)</span></td>
		</tr>
		<tr>
			<td class=tdbox>网站默认描述信息</td>
			<td class=tdbox><input class=fminpt type="text" name="Form_DEF_GBL_Description" maxlength="255" size="55" value="<%=htmlencode(Form_DEF_GBL_Description)%>">
			<span class=note>网站默认的输出于头部的Description内容</span></td>
		</tr>
		
		<tr>
			<td class=tdbox width=80>侧栏及更多设置</td>
			<td class=tdbox valign=top>
				<ul><%
				Dim indexN,InfoText,tmpArr
				for n = 0 to Ubound(DEF_Sideparameter_String,1)
					If inStr(DEF_Sideparameter_String(n),"|") <= 0 Then
						%>
						</ul><b><%=DEF_Sideparameter_String(n)%></b><ul>
						<%
					Else
						tmpArr = Split(DEF_Sideparameter_String(n),"|")
						IndexN = tmpArr(0)
						InfoText = tmpArr(1)
						If instr(InfoText,"<span") = 0 Then%>
						<li><span class="grayfont"><%
						If IndexN <= 9 Then Response.Write "0"
						Response.Write IndexN%></span><input type="checkbox" class=fmchkbox name="SideLimit<%=IndexN%>" value="1"<%
						If instr(InfoText,"<span") Then Response.Write " disabled=""disabled"""
						If GetBinarybit(Form_DEF_Sideparameter,IndexN) = 1 Then
							Response.Write " checked>"
						Else
							Response.Write ">"
						End If%><%=InfoText%></li>
						<%
						End If
					End If
				Next%></ul></td>
		</tr>
		
		<tr>
		<td class=tdbox>&nbsp;</td>
		<td class=tdbox>
			<input type=submit name=提交 value=提交 class=fmbtn>
			<input type=reset name=取消 value=取消 class=fmbtn>
		</td>
		</tr>
		</table>
		<%

End Function

Function GetDefaultValue

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select SavePoints from LeadBBS_SiteInfo",1),0)
	If Rs.Eof Then
		Form_SavePoints = 0
	Else
		Form_SavePoints = cCur(Rs(0))
	End If
	Form_DEF_BBS_Name = DEF_BBS_Name
	Form_DEF_ManageDir = DEF_ManageDir

	Form_DEF_BBS_MaxLayer = DEF_BBS_MaxLayer
	Form_DEF_UsedDataBase = DEF_UsedDataBase
	Form_DEF_BBS_SearchMode = DEF_BBS_SearchMode

	Form_DEF_BBS_AnnouncePoints = DEF_BBS_AnnouncePoints
	Form_DEF_BBS_PrizeAnnouncePoints = DEF_BBS_PrizeAnnouncePoints
	Form_DEF_BBS_MakeGoodAnnouncePoints = DEF_BBS_MakeGoodAnnouncePoints
	Form_DEF_BBS_MaxTopAnnounce = DEF_BBS_MaxTopAnnounce
	Form_DEF_BBS_MaxAllTopAnnounce = DEF_BBS_MaxAllTopAnnounce
	Form_DEF_BBS_DisplayTopicLength = DEF_BBS_DisplayTopicLength
	Form_DEF_BBS_ScreenWidth = DEF_BBS_ScreenWidth
	Form_DEF_BBS_LeftTDWidth = DEF_BBS_LeftTDWidth
	Form_DEF_MasterCookies = DEF_MasterCookies
	Form_DEF_SiteNameString = DEF_SiteNameString
	Form_DEF_SupervisorUserName = DEF_SupervisorUserName
	Form_DEF_MaxTextLength = DEF_MaxTextLength

	Form_DEF_MaxListNum = DEF_MaxListNum
	Form_DEF_TopicContentMaxListNum = DEF_TopicContentMaxListNum
	Form_DEF_MaxJumpPageNum = DEF_MaxJumpPageNum
	Form_DEF_DisplayJumpPageNum = DEF_DisplayJumpPageNum
	Form_DEF_MaxBoardMastNum = DEF_MaxBoardMastNum
	Form_DEF_EnableUserHidden = DEF_EnableUserHidden
	Form_DEF_VOTE_MaxNum = DEF_VOTE_MaxNum
	Form_DEF_MaxLoginTimes = DEF_MaxLoginTimes
	Form_DEF_EnableUpload = DEF_EnableUpload
	Form_DEF_EnableGFL = DEF_EnableGFL
	Form_DEF_UserOnlineTimeOut = DEF_UserOnlineTimeOut
	Form_DEF_faceMaxNum = DEF_faceMaxNum
	Form_DEF_AllDefineFace = DEF_AllDefineFace
	Form_DEF_AllFaceMaxWidth = DEF_AllFaceMaxWidth
	Form_DEF_BBS_EmailMode = DEF_BBS_EmailMode
	Form_DEF_EnableAttestNumber = DEF_EnableAttestNumber
	Form_DEF_AttestNumberPoints = DEF_AttestNumberPoints
	Form_DEF_EnableUnderWrite = DEF_EnableUnderWrite
	Form_DEF_NeedOnlineTime = DEF_NeedOnlineTime
	Form_DEF_EnableForbidIP = DEF_EnableForbidIP
	Form_DEF_TopAdString = DEF_TopAdString
	Form_DEF_RestSpaceTime = DEF_RestSpaceTime
	Form_DEF_LoginSpaceTime = DEF_LoginSpaceTime
	Form_DEF_AccessDatabase = DEF_AccessDatabase
	Form_DEF_SiteHomeUrl = DEF_SiteHomeUrl
	Form_DEF_DefaultStyle = DEF_DefaultStyle
	Form_DEF_EnableFlashUBB = DEF_EnableFlashUBB
	Form_DEF_EnableImagesUBB = DEF_EnableImagesUBB
	Form_DEF_AnnounceFontSize = DEF_AnnounceFontSize
	Form_DEF_EditAnnounceDelay = DEF_EditAnnounceDelay
	Form_DEF_DisplayOnlineUser = DEF_DisplayOnlineUser
	Form_DEF_EnableSpecialTopic = DEF_EnableSpecialTopic
	Form_DEF_UBBiconNumber = DEF_UBBiconNumber
	Form_DEF_EnableDelAnnounce = DEF_EnableDelAnnounce
	Form_DEF_LimitTitle = DEF_LimitTitle
	Form_DEF_DownKey = DEF_DownKey	
	Form_DEF_UpdateInterval = DEF_UpdateInterval
	Form_DEF_BottomInfo = DEF_BottomInfo
	Form_DEF_GBL_Description = DEF_GBL_Description
	Form_DEF_Sideparameter = DEF_Sideparameter
	
	Dim N
	For n = 0 to Ubound(Form_DEF_PointsName)
		Form_DEF_PointsName(n) = DEF_PointsName(n)
	Next

	Form_DEF_EnableMakeTopAnc = DEF_EnableMakeTopAnc
	Form_DEF_EnableDatabaseCache = DEF_EnableDatabaseCache
	Form_DEF_WriteEventSpace = DEF_WriteEventSpace
	Form_DEF_EditAnnounceExpires = DEF_EditAnnounceExpires
	Form_DEF_RepeatLoginTimeOut = DEF_RepeatLoginTimeOut
	Form_DEF_FSOString = DEF_FSOString
	Form_DEF_Now = DateDiff("n",now,DEF_Now)
	Form_DEF_LineHeight = DEF_LineHeight
	Form_DEF_RegisterFile = DEF_RegisterFile

End Function

Function GetFormValue

	Form_DEF_ManageDir = Trim(Request.Form("Form_DEF_ManageDir"))
	Form_DEF_BBS_Name = Trim(Request.Form("Form_DEF_BBS_Name"))

	Form_DEF_BBS_MaxLayer = Trim(Request.Form("Form_DEF_BBS_MaxLayer"))
	Form_DEF_UsedDataBase = Trim(Request.Form("Form_DEF_UsedDataBase"))
	Form_DEF_BBS_SearchMode = Trim(Request.Form("Form_DEF_BBS_SearchMode"))

	Form_DEF_BBS_AnnouncePoints = Trim(Request.Form("Form_DEF_BBS_AnnouncePoints"))
	Form_DEF_BBS_PrizeAnnouncePoints = Trim(Request.Form("Form_DEF_BBS_PrizeAnnouncePoints"))
	Form_DEF_BBS_MakeGoodAnnouncePoints = Trim(Request.Form("Form_DEF_BBS_MakeGoodAnnouncePoints"))
	Form_DEF_BBS_MaxTopAnnounce = Trim(Request.Form("Form_DEF_BBS_MaxTopAnnounce"))
	Form_DEF_BBS_MaxAllTopAnnounce = Trim(Request.Form("Form_DEF_BBS_MaxAllTopAnnounce"))
	Form_DEF_BBS_DisplayTopicLength = Trim(Request.Form("Form_DEF_BBS_DisplayTopicLength"))
	Form_DEF_BBS_ScreenWidth = Trim(Request.Form("Form_DEF_BBS_ScreenWidth"))
	Form_DEF_BBS_LeftTDWidth = Trim(Request.Form("Form_DEF_BBS_LeftTDWidth"))
	Form_DEF_MasterCookies = Trim(Request.Form("Form_DEF_MasterCookies"))
	Form_DEF_SiteNameString = Trim(Request.Form("Form_DEF_SiteNameString"))
	Form_DEF_SupervisorUserName = Trim(Request.Form("Form_DEF_SupervisorUserName"))
	Form_DEF_MaxTextLength = Trim(Request.Form("Form_DEF_MaxTextLength"))

	Form_DEF_MaxListNum = Trim(Request.Form("Form_DEF_MaxListNum"))
	Form_DEF_TopicContentMaxListNum = Trim(Request.Form("Form_DEF_TopicContentMaxListNum"))
	Form_DEF_MaxJumpPageNum = Trim(Request.Form("Form_DEF_MaxJumpPageNum"))
	Form_DEF_DisplayJumpPageNum = Trim(Request.Form("Form_DEF_DisplayJumpPageNum"))
	Form_DEF_MaxBoardMastNum = Trim(Request.Form("Form_DEF_MaxBoardMastNum"))
	Form_DEF_EnableUserHidden = Trim(Request.Form("Form_DEF_EnableUserHidden"))
	Form_DEF_VOTE_MaxNum = Trim(Request.Form("Form_DEF_VOTE_MaxNum"))
	Form_DEF_MaxLoginTimes = Trim(Request.Form("Form_DEF_MaxLoginTimes"))
	Form_DEF_EnableUpload = Trim(Request.Form("Form_DEF_EnableUpload"))
	Form_DEF_EnableGFL = Trim(Request.Form("Form_DEF_EnableGFL"))
	Form_DEF_UserOnlineTimeOut = Trim(Request.Form("Form_DEF_UserOnlineTimeOut"))
	Form_DEF_faceMaxNum = Trim(Request.Form("Form_DEF_faceMaxNum"))
	Form_DEF_AllDefineFace = Trim(Request.Form("Form_DEF_AllDefineFace"))
	Form_DEF_AllFaceMaxWidth = Trim(Request.Form("Form_DEF_AllFaceMaxWidth"))
	Form_DEF_BBS_EmailMode = Trim(Request.Form("Form_DEF_BBS_EmailMode"))
	Form_DEF_EnableAttestNumber = Trim(Request.Form("Form_DEF_EnableAttestNumber"))
	Form_DEF_AttestNumberPoints = Trim(Request.Form("Form_DEF_AttestNumberPoints"))
	Form_DEF_EnableUnderWrite = Trim(Request.Form("Form_DEF_EnableUnderWrite"))
	Form_DEF_NeedOnlineTime = Trim(Request.Form("Form_DEF_NeedOnlineTime"))
	Form_DEF_EnableForbidIP = Trim(Request.Form("Form_DEF_EnableForbidIP"))
	Form_DEF_TopAdString = Trim(Request.Form("Form_DEF_TopAdString"))
	Form_DEF_RestSpaceTime = Trim(Request.Form("Form_DEF_RestSpaceTime"))
	Form_DEF_LoginSpaceTime = Trim(Request.Form("Form_DEF_LoginSpaceTime"))
	Form_DEF_AccessDatabase = Trim(Request.Form("Form_DEF_AccessDatabase"))
	Form_DEF_SiteHomeUrl = Trim(Request.Form("Form_DEF_SiteHomeUrl"))
	Form_DEF_DefaultStyle = Trim(Request.Form("Form_DEF_DefaultStyle"))	
	Form_DEF_EnableFlashUBB = Trim(Request.Form("Form_DEF_EnableFlashUBB"))	
	Form_DEF_EnableImagesUBB = Trim(Request.Form("Form_DEF_EnableImagesUBB"))
	Form_DEF_AnnounceFontSize = Trim(Request.Form("Form_DEF_AnnounceFontSize"))
	Form_DEF_EditAnnounceDelay = Trim(Request.Form("Form_DEF_EditAnnounceDelay"))
	Form_DEF_DisplayOnlineUser = Trim(Request.Form("Form_DEF_DisplayOnlineUser"))
	Form_DEF_EnableSpecialTopic = Trim(Request.Form("Form_DEF_EnableSpecialTopic"))
	Form_DEF_UBBiconNumber = Trim(Request.Form("Form_DEF_UBBiconNumber"))
	Form_DEF_EnableDelAnnounce = Trim(Request.Form("Form_DEF_EnableDelAnnounce"))
	Form_DEF_LimitTitle = Trim(Request.Form("Form_DEF_LimitTitle"))
	Form_DEF_DownKey = Left(Trim(Request.Form("Form_DEF_DownKey")),50)	
	Form_DEF_UpdateInterval = Left(Trim(Request.Form("Form_DEF_UpdateInterval")),50)
	Form_DEF_BottomInfo = Left(Request.Form("Form_DEF_BottomInfo"),500)
	Form_DEF_GBL_Description = Left(Trim(Request.Form("Form_DEF_GBL_Description")),255)
	
	Dim N
	For n = 0 to Ubound(DEF_PointsName)
		Form_DEF_PointsName(n) = Trim(Request.Form("Form_DEF_PointsName" & N))
	Next
	
	
	Dim Temp2,TempN
	Form_DEF_Sideparameter = 0
	Temp2 = 1
	For TempN = 0 to Ubound(DEF_Sideparameter_String,1)
		N = Request("SideLimit" & TempN+1)
		If N <> "1" Then N = "0"
		If N = "1" Then Form_DEF_Sideparameter = Form_DEF_Sideparameter+cCur(Temp2)
		Temp2 = Temp2*2
	Next

	Form_DEF_EnableMakeTopAnc = Trim(Request.Form("Form_DEF_EnableMakeTopAnc"))
	Form_DEF_EnableDatabaseCache = Trim(Request.Form("Form_DEF_EnableDatabaseCache"))
	Form_DEF_WriteEventSpace = Trim(Request.Form("Form_DEF_WriteEventSpace"))
	Form_DEF_EditAnnounceExpires = Trim(Request.Form("Form_DEF_EditAnnounceExpires"))
	Form_DEF_RepeatLoginTimeOut = Trim(Request.Form("Form_DEF_RepeatLoginTimeOut"))
	Form_DEF_FSOString = Trim(Request.Form("Form_DEF_FSOString"))
	Form_DEF_Now = Trim(Request.Form("Form_DEF_Now"))
	Form_SavePoints = Left(Trim(Request.Form("Form_SavePoints")),14)
	Form_DEF_LineHeight = Trim(Request.Form("Form_DEF_LineHeight"))
	Form_DEF_RegisterFile = Trim(Request.Form("Form_DEF_RegisterFile"))

	If isNumeric(Form_SavePoints) = 0 Then Form_SavePoints = 0
	Form_SavePoints = Fix(cCur(Form_SavePoints))
	If Form_SavePoints < 0 Then Form_SavePoints = 0

	If inStr(Form_DEF_ManageDir,"%") Then GBL_CHK_TempStr = "管理目录不能包含百分号<br>" & VbCrLf
	If inStr(Form_DEF_BBS_Name,"%") Then GBL_CHK_TempStr = "论坛名称不能包含百分号<br>" & VbCrLf
	If inStr(Form_DEF_SiteHomeUrl,"%") Then GBL_CHK_TempStr = "网站首页不能包含百分号<br>" & VbCrLf
	If isNumeric(Form_DEF_BBS_MaxLayer) = 0 Then GBL_CHK_TempStr = "回复级数必须为数字<br>" & VbCrLf

	If isNumeric(Form_DEF_UsedDataBase) = 0 Then GBL_CHK_TempStr = "数 据 库必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_BBS_SearchMode) = 0 Then GBL_CHK_TempStr = "搜索模式必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_BBS_AnnouncePoints) = 0 Then GBL_CHK_TempStr = "发帖奖励必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_BBS_PrizeAnnouncePoints) = 0 Then GBL_CHK_TempStr = "删除惩罚必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_BBS_MakeGoodAnnouncePoints) = 0 Then GBL_CHK_TempStr = "精华奖励必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_BBS_MaxTopAnnounce) = 0 Then GBL_CHK_TempStr = "最多顶帖必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_BBS_MaxAllTopAnnounce) = 0 Then GBL_CHK_TempStr = "最多总固必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_BBS_DisplayTopicLength) = 0 Then GBL_CHK_TempStr = "主题长度必须为数字<br>" & VbCrLf
	If inStr(Form_DEF_BBS_LeftTDWidth,"%") Then GBL_CHK_TempStr = "论坛宽度不能包含百分号<br>" & VbCrLf
	If inStr(Form_DEF_MasterCookies,"%") Then GBL_CHK_TempStr = "Cookies不能包含百分号<br>" & VbCrLf
	If inStr(Form_DEF_SiteNameString,"%") Then GBL_CHK_TempStr = "网站名称不能包含百分号<br>" & VbCrLf
	If inStr(Form_DEF_SupervisorUserName,"""") or inStr(Form_DEF_SupervisorUserName,"%") Then GBL_CHK_TempStr = "管 理 员不能包含有引号或百分号<br>" & VbCrLf
	If isNumeric(Form_DEF_MaxTextLength) = 0 Then GBL_CHK_TempStr = "内容长度必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_MaxListNum) = 0 Then GBL_CHK_TempStr = "显示记录数量必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_TopicContentMaxListNum) = 0 Then GBL_CHK_TempStr = "显示帖子数量必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_MaxJumpPageNum) = 0 Then GBL_CHK_TempStr = "跳转页数数量必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_DisplayJumpPageNum) = 0 Then GBL_CHK_TempStr = "显示跳转数量必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_MaxBoardMastNum) = 0 Then GBL_CHK_TempStr = "版主限制数量必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_EnableUserHidden) = 0 Then GBL_CHK_TempStr = "隐身设置必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_VOTE_MaxNum) = 0 Then GBL_CHK_TempStr = "投票项目必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_MaxLoginTimes) = 0 Then GBL_CHK_TempStr = "登录次数必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_RestSpaceTime) = 0 Then GBL_CHK_TempStr = "动作间隔必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_LoginSpaceTime) = 0 Then GBL_CHK_TempStr = "登录间隔必须为数字<br>" & VbCrLf

	If isNumeric(Form_DEF_EnableUpload) = 0 Then GBL_CHK_TempStr = "上传权限必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_EnableGFL) = 0 Then GBL_CHK_TempStr = "图像组件是否允许必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_UserOnlineTimeOut) = 0 Then GBL_CHK_TempStr = "在线超时必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_faceMaxNum) = 0 Then GBL_CHK_TempStr = "头像个数必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_AllDefineFace) = 0 Then GBL_CHK_TempStr = "自定头像必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_AllFaceMaxWidth) = 0 Then GBL_CHK_TempStr = "头像大小必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_BBS_EmailMode) = 0 Then GBL_CHK_TempStr = "邮件设置必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_EnableAttestNumber) = 0 Then GBL_CHK_TempStr = "验 证 码显示方式必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_AttestNumberPoints) = 0 Then GBL_CHK_TempStr = "验证码２必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_EnableUnderWrite) = 0 Then GBL_CHK_TempStr = "签名设置显示方式必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_NeedOnlineTime) = 0 Then GBL_CHK_TempStr = "在线时间必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_EnableForbidIP) = 0 Then GBL_CHK_TempStr = "ＩＰ屏蔽必须为数字<br>" & VbCrLf
	If inStr(Form_DEF_TopAdString,"%") Then GBL_CHK_TempStr = "顶部广告不能包含百分号<br>" & VbCrLf
	If inStr(Form_DEF_AccessDatabase,"%") Then GBL_CHK_TempStr = "数 据 库连接不能包含百分号<br>" & VbCrLf
	If isNumeric(Form_DEF_DefaultStyle) = 0 Then GBL_CHK_TempStr = "默认风格必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_EnableFlashUBB) = 0 Then GBL_CHK_TempStr = "多 媒 体必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_EnableImagesUBB) = 0 Then GBL_CHK_TempStr = "插入图片必须为数字<br>" & VbCrLf
	If inStr(Form_DEF_AnnounceFontSize,"%") Then GBL_CHK_TempStr = "内容字体不能包含百分号<br>" & VbCrLf
	If isNumeric(Form_DEF_EditAnnounceDelay) = 0 Then GBL_CHK_TempStr = "编辑间隔必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_DisplayOnlineUser) = 0 Then GBL_CHK_TempStr = "在线会员显示方式必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_EnableSpecialTopic) = 0 Then GBL_CHK_TempStr = "特殊帖子必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_UBBiconNumber) = 0 Then GBL_CHK_TempStr = "插入表情个数必须为数字<br>" & VbCrLf
	Form_DEF_UBBiconNumber = Fix(cCur(Form_DEF_UBBiconNumber))
	If Form_DEF_UBBiconNumber > 9999 Then Form_DEF_UBBiconNumber = 9999
	If isNumeric(Form_DEF_EnableDelAnnounce) = 0 Then GBL_CHK_TempStr = "回 收 站是否允许必须为数字<br>" & VbCrLf
	For n = 0 to Ubound(DEF_PointsName)
		If inStr(Form_DEF_PointsName(n),"%") Then
			GBL_CHK_TempStr = "第" & N & "个名称定义里不能包含百分号<br>" & VbCrLf
		End If
	Next
	If isNumeric(Form_DEF_EnableMakeTopAnc) = 0 Then GBL_CHK_TempStr = "回复提帖必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_EnableDatabaseCache) = 0 Then GBL_CHK_TempStr = "ＤＢ缓冲必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_WriteEventSpace) = 0 Then GBL_CHK_TempStr = "写入间隔必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_EditAnnounceExpires) = 0 Then GBL_CHK_TempStr = "编辑到期必须为数字<br>" & VbCrLf
	If isNumeric(Form_DEF_RepeatLoginTimeOut) = 0 Then GBL_CHK_TempStr = "重复登录时间必须为数字<br>" & VbCrLf
	If inStr(Form_DEF_FSOString,"%") Then GBL_CHK_TempStr = "FSO组件名称不能包含百分号<br>" & VbCrLf
	If isNumeric(Form_DEF_Now) = 0 Then GBL_CHK_TempStr = "时间设置必须为数字<br>" & VbCrLf	
	If isNumeric(Form_DEF_LineHeight) = 0 Then GBL_CHK_TempStr = "列表高度必须为数字<br>" & VbCrLf
	If isNumeric(DEF_UpdateInterval) = 0 Then GBL_CHK_TempStr = "缓存刷新间隔必须为数字<br>" & VbCrLf

	Form_DEF_RegisterFile = Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Form_DEF_RegisterFile,"""",""),"?",""),"/",""),"\",""),"*",""),":",""),"<",""),">",""),"|","")
	If LCase(Right(Form_DEF_RegisterFile,4)) <> ".asp" Then GBL_CHK_TempStr = "注册文件名称错误，必须是.asp作为扩展名!<br>" & VbCrLf
	If isNumeric(Form_DEF_LimitTitle) = 0 Then GBL_CHK_TempStr = "标题加密必须为数字<br>" & VbCrLf
	If inStr(DEF_DownKey,"""") or inStr(DEF_DownKey,"%") Then GBL_CHK_TempStr = "下载附件密钥不能包含百分号<br>" & VbCrLf
	If isNumeric(DEF_UpdateInterval) = 0 Then GBL_CHK_TempStr = "缓存刷新间隔必须为数字<br>" & VbCrLf
	If inStr(Form_DEF_BottomInfo,"%") Then GBL_CHK_TempStr = "底部信息不能包含百分号<br>" & VbCrLf
	If inStr(Form_DEF_GBL_Description,"%") Then GBL_CHK_TempStr = "头部Description信息不能包含百分号<br>" & VbCrLf

End Function

Function ReplaceStr(str)

	ReplaceStr = Replace(Str,"""","""""")

End Function

Function MakeDataBaseLinkFile

	Dim n,TempStr
	TempStr = ""
	TempStr = TempStr & chr(60) & "%@ LANGUAGE=VBScript CodePage=65001%" & chr(62) & VbCrLf
	TempStr = TempStr & chr(60) & "%Option Explicit" & VbCrLf
	TempStr = TempStr & "Response.Charset = ""utf-8""" & VbCrLf
	TempStr = TempStr & "Session.CodePage=65001" & VbCrLf
	TempStr = TempStr & "Response.Buffer = True" & VbCrLf
	TempStr = TempStr & "Const DEF_ManageDir = """ & Form_DEF_ManageDir & """" & VbCrLf
	TempStr = TempStr & VbCrLf

	TempStr = TempStr & "If isNumeric(application(DEF_MasterCookies & " & chr(34) & "SiteEnableFlagzoieiu" & chr(34) & ")) = 0 Then" & VbCrLf
	TempStr = TempStr & "	Application.Lock" & VbCrLf
	TempStr = TempStr & "	application(DEF_MasterCookies & " & chr(34) & "SiteEnableFlagzoieiu" & chr(34) & ") = 1" & VbCrLf
	TempStr = TempStr & "	Application.UnLock" & VbCrLf
	TempStr = TempStr & "End If"  &VbCrLf

	TempStr = TempStr & "If application(DEF_MasterCookies & " & chr(34) & "SiteEnableFlagzoieiu" & chr(34) & ") = 0 and application(DEF_MasterCookies & " & chr(34) & "SiteDisbleWhyszoieiu" & chr(34) & ")<>" & chr(34) & chr(34) & " and inStr(Replace(Lcase(Request.ServerVariables(" & chr(34) & "URL" & chr(34) & "))," & chr(34) & "\" & chr(34) & "," & chr(34) & "/" & chr(34) & ")," & chr(34) & "/"" & DEF_ManageDir & ""/" & chr(34) & ") = 0 Then" & VbCrLf
	TempStr = TempStr & "	Response.Write application(DEF_MasterCookies & " & chr(34) & "SiteDisbleWhyszoieiu" & chr(34) & ")" & VbCrLf
	TempStr = TempStr & "	Response.End" & VbCrLf
	TempStr = TempStr & "End If" & VbCrLf
	TempStr = TempStr & VbCrLf
	TempStr = TempStr & "Dim DEF_BBS_HomeUrl,DEF_SiteHomeUrl" & VbCrLf
	TempStr = TempStr & "const DEF_BBS_Name=" & Chr(34) & ReplaceStr(Form_DEF_BBS_Name) & Chr(34) & VbCrLf

	TempStr = TempStr & "DEF_BBS_HomeUrl = " & Chr(34) & Chr(34) & VbCrLf
	TempStr = TempStr & "DEF_SiteHomeUrl = " & Chr(34) & ReplaceStr(Form_DEF_SiteHomeUrl) & Chr(34) & VbCrLf
	TempStr = TempStr & "const DEF_BBS_MaxLayer = " & Form_DEF_BBS_MaxLayer & VbCrLf
	TempStr = TempStr & "const DEF_UsedDataBase = " & Form_DEF_UsedDataBase & VbCrLf
	TempStr = TempStr & "const DEF_BBS_SearchMode = " & Form_DEF_BBS_SearchMode & VbCrLf

	TempStr = TempStr & "const DEF_BBS_TOPMinID = 99999999990000" & VbCrLf
	TempStr = TempStr & "const DEF_BBS_AnnouncePoints = " & Form_DEF_BBS_AnnouncePoints & VbCrLf
	TempStr = TempStr & "const DEF_BBS_PrizeAnnouncePoints = " & Form_DEF_BBS_PrizeAnnouncePoints & VbCrLf
	TempStr = TempStr & "const DEF_BBS_MakeGoodAnnouncePoints = " & Form_DEF_BBS_MakeGoodAnnouncePoints & VbCrLf
	TempStr = TempStr & "const DEF_BBS_MaxTopAnnounce = " & Form_DEF_BBS_MaxTopAnnounce & VbCrLf
	TempStr = TempStr & "const DEF_BBS_MaxAllTopAnnounce = " & Form_DEF_BBS_MaxAllTopAnnounce & VbCrLf

	TempStr = TempStr & "Dim DEF_BBS_DisplayTopicLength,DEF_BBS_ScreenWidth" & VbCrLf
	TempStr = TempStr & "DEF_BBS_DisplayTopicLength = " & Form_DEF_BBS_DisplayTopicLength & VbCrLf

	TempStr = TempStr & "DEF_BBS_ScreenWidth = " & Chr(34) & ReplaceStr(Form_DEF_BBS_ScreenWidth) & Chr(34) & VbCrLf
	TempStr = TempStr & "const DEF_BBS_LeftTDWidth = " & Chr(34) & ReplaceStr(Form_DEF_BBS_LeftTDWidth) & Chr(34) & VbCrLf

	TempStr = TempStr & "const DEF_MasterCookies = " & Chr(34) & ReplaceStr(Form_DEF_MasterCookies) & Chr(34) & VbCrLf
	TempStr = TempStr & "const DEF_SiteNameString = " & Chr(34) & ReplaceStr(Form_DEF_SiteNameString) & Chr(34) & VbCrLf
	TempStr = TempStr & "const DEF_SupervisorUserName = " & Chr(34) & ReplaceStr(Form_DEF_SupervisorUserName) & Chr(34) & VbCrLf
	TempStr = TempStr & "const DEF_MaxTextLength = " & Form_DEF_MaxTextLength & VbCrLf

	TempStr = TempStr & "Dim DEF_MaxListNum" & VbCrLf
	TempStr = TempStr & "DEF_MaxListNum = " & Form_DEF_MaxListNum & VbCrLf
	TempStr = TempStr & "Const DEF_TopicContentMaxListNum = " & Form_DEF_TopicContentMaxListNum & VbCrLf
	TempStr = TempStr & "Const DEF_MaxJumpPageNum = " & Form_DEF_MaxJumpPageNum & VbCrLf
	TempStr = TempStr & "Const DEF_DisplayJumpPageNum = " & Form_DEF_DisplayJumpPageNum & VbCrLf

	TempStr = TempStr & "const DEF_MaxBoardMastNum = " & Form_DEF_MaxBoardMastNum & VbCrLf

	TempStr = TempStr & "const DEF_EnableUserHidden = " & Form_DEF_EnableUserHidden & VbCrLf
	TempStr = TempStr & "const DEF_VOTE_MaxNum = " & Form_DEF_VOTE_MaxNum & VbCrLf

	TempStr = TempStr & "const DEF_MaxLoginTimes = " & Form_DEF_MaxLoginTimes & VbCrLf
	TempStr = TempStr & "const DEF_RestSpaceTime = " & Form_DEF_RestSpaceTime & VbCrLf
	TempStr = TempStr & "const DEF_LoginSpaceTime = " & Form_DEF_LoginSpaceTime & VbCrLf

	TempStr = TempStr & "const DEF_EnableUpload = " & Form_DEF_EnableUpload & VbCrLf
	TempStr = TempStr & "const DEF_EnableGFL = " & Form_DEF_EnableGFL & VbCrLf
	TempStr = TempStr & "const DEF_UserOnlineTimeOut = " & Form_DEF_UserOnlineTimeOut & VbCrLf
	TempStr = TempStr & "const DEF_faceMaxNum = " & Form_DEF_faceMaxNum & VbCrLf
	TempStr = TempStr & "const DEF_AllDefineFace = " & Form_DEF_AllDefineFace & VbCrLf
	TempStr = TempStr & "const DEF_AllFaceMaxWidth = " & Form_DEF_AllFaceMaxWidth & VbCrLf

	TempStr = TempStr & "const DEF_BBS_EmailMode = " & Form_DEF_BBS_EmailMode & VbCrLf
	TempStr = TempStr & "Const DEF_EnableAttestNumber = " & Form_DEF_EnableAttestNumber & VbCrLf
	TempStr = TempStr & "Const DEF_AttestNumberPoints = " & Form_DEF_AttestNumberPoints & VbCrLf

	TempStr = TempStr & "Dim DEF_BoardStyleString,DEF_BoardStyleStringNum" & VbCrLf

	TempStr = TempStr & "DEF_BoardStyleString = Array("
	For n = 0 to DEF_BoardStyleStringNum
		If n = 0 Then
			TempStr = TempStr & """" & DEF_BoardStyleString(n) & """"
		Else
			TempStr = TempStr & ",""" & DEF_BoardStyleString(n) & """"
		End If
	Next
	TempStr = TempStr & ")" & VbCrLf
	TempStr = TempStr & "DEF_BoardStyleStringNum = Ubound(DEF_BoardStyleString,1)" & VbCrLf

	TempStr = TempStr & "Const DEF_EnableUnderWrite = " & Form_DEF_EnableUnderWrite & VbCrLf
	TempStr = TempStr & "Const DEF_NeedOnlineTime = " & Form_DEF_NeedOnlineTime & VbCrLf
	TempStr = TempStr & "Const DEF_EnableForbidIP = " & Form_DEF_EnableForbidIP & VbCrLf

	TempStr = TempStr & "Const DEF_TopAdString = " & Chr(34) & ReplaceStr(Form_DEF_TopAdString) & Chr(34) & VbCrLf
	TempStr = TempStr & "Const DEF_AccessDatabase = " & Chr(34) & ReplaceStr(Form_DEF_AccessDatabase) & Chr(34) & VbCrLf

	TempStr = TempStr & "Const DEF_DefaultStyle = " & Form_DEF_DefaultStyle & VbCrLf
	TempStr = TempStr & "Const DEF_EnableFlashUBB = " & Form_DEF_EnableFlashUBB & VbCrLf
	TempStr = TempStr & "Const DEF_EnableImagesUBB = " & Form_DEF_EnableImagesUBB & VbCrLf
	TempStr = TempStr & "Const DEF_AnnounceFontSize = " & Chr(34) & ReplaceStr(Form_DEF_AnnounceFontSize) & Chr(34) & VbCrLf
	TempStr = TempStr & "Const DEF_EditAnnounceDelay = " & Form_DEF_EditAnnounceDelay & VbCrLf
	TempStr = TempStr & "Const DEF_DisplayOnlineUser = " & Form_DEF_DisplayOnlineUser & VbCrLf
	TempStr = TempStr & "Const DEF_EnableSpecialTopic = " & Form_DEF_EnableSpecialTopic & VbCrLf
	TempStr = TempStr & "Const DEF_UBBiconNumber = " & Form_DEF_UBBiconNumber & VbCrLf
	TempStr = TempStr & "Const DEF_EnableDelAnnounce = " & Form_DEF_EnableDelAnnounce & VbCrLf
	TempStr = TempStr & "Dim DEF_PointsName" & VbCrLf
	TempStr = TempStr & "DEF_PointsName = Array("
	For n = 0 to Ubound(DEF_PointsName)
		If n = 0 Then
			TempStr = TempStr & """" & Form_DEF_PointsName(n) & """"
		Else
			TempStr = TempStr & ",""" & Form_DEF_PointsName(n) & """"
		End If
	Next
	TempStr = TempStr & ")" & VbCrLf
	TempStr = TempStr & "Const DEF_EnableMakeTopAnc = " & Form_DEF_EnableMakeTopAnc & VbCrLf
	TempStr = TempStr & "Const DEF_EnableDatabaseCache = " & Form_DEF_EnableDatabaseCache & VbCrLf
	TempStr = TempStr & "Const DEF_WriteEventSpace = " & Form_DEF_WriteEventSpace & VbCrLf
	TempStr = TempStr & "Const DEF_EditAnnounceExpires = " & Form_DEF_EditAnnounceExpires & VbCrLf
	TempStr = TempStr & "Const DEF_RepeatLoginTimeOut = " & Form_DEF_RepeatLoginTimeOut & VbCrLf
	TempStr = TempStr & "Const DEF_FSOString = " & Chr(34) & ReplaceStr(Form_DEF_FSOString) & Chr(34) & VbCrLf
	TempStr = TempStr & "Dim DEF_Now,DEF_Version" & VbCrLf
	If Form_DEF_Now = 0 Then
		TempStr = TempStr & "DEF_Now = now" & VbCrLf
	Else
		TempStr = TempStr & "DEF_Now = DateAdd(""n""," & Form_DEF_Now & ",now)" & VbCrLf
	End If
	TempStr = TempStr & "DEF_Version = " & Chr(34) & ReplaceStr(DEF_Version) & chr(34) & VbCrLf
	TempStr = TempStr & "Const DEF_LineHeight = " & Form_DEF_LineHeight & VbCrLf
	TempStr = TempStr & "Const DEF_RegisterFile = " & Chr(34) & ReplaceStr(Form_DEF_RegisterFile) & Chr(34) & VbCrLf
	TempStr = TempStr & "Const DEF_LimitTitle = " & Form_DEF_LimitTitle & VbCrLf

	TempStr = TempStr & "Const DEF_DownKey = " & Chr(34) & ReplaceStr(Form_DEF_DownKey) & Chr(34) & VbCrLf
	TempStr = TempStr & "Const DEF_UpdateInterval = " & Form_DEF_UpdateInterval & VbCrLf
	TempStr = TempStr & "Const DEF_BottomInfo = " & Chr(34) & ReplaceStr(Form_DEF_BottomInfo) & Chr(34) & VbCrLf
	TempStr = TempStr & "Dim DEF_GBL_Description" & VbCrLf
	TempStr = TempStr & "DEF_GBL_Description = " & Chr(34) & ReplaceStr(Form_DEF_GBL_Description) & Chr(34) & VbCrLf
	TempStr = TempStr & "Const DEF_Sideparameter = " & ReplaceStr(Form_DEF_Sideparameter) & VbCrLf
	TempStr = TempStr & "Const DEF_InstallDir = """ & ReplaceStr(DEF_InstallDir) & """" & VbCrLf

	TempStr = TempStr & "%" & chr(62) & VbCrLf

	ADODB_SaveToFile TempStr,"../../inc/BBSSetup.asp"

	CALL Update_InsertSetupRID(1051,"inc/BBSSetup.asp",0,TempStr," and ClassNum=" & 0)
	
	If GBL_CHK_TempStr = "" Then
		Response.Write "<br><span class=greenfont>2.成功完成设置！</span>"
	Else
		%><%=GBL_CHK_TempStr%><br>服务器不支持在线写入文件功能，请使用FTP等功能，将<span Class=redfont>inc/BBSSetup.asp</span>文件替换成框中内容(注意备份)<p>
		<textarea name="fileContent" cols="80" rows="30" class=fmtxtra><%=Server.htmlencode(TempStr)%></textarea><%
		GBL_CHK_TempStr = ""
	End If
	CALL LDExeCute("Update LeadBBS_SiteInfo Set SavePoints=" & Form_SavePoints,1)
	Call RennameRegisterFile(DEF_RegisterFile,Form_DEF_RegisterFile)

End Function

Function RennameRegisterFile(path,NewPath)

	If DEF_FSOString = "" or path = NewPath Then Exit Function
	on error resume next
	Dim fs
	Set fs = Server.CreateObject(DEF_FSOString)
	If err <> 0 Then
		Err.Clear
		Set fs = Nothing
		Response.Write "<p>服务器不支持FSO，硬盘上的注册文件名未更改．"
		RennameRegisterFile = 0
		Exit Function
	End If

	If Not fs.FileExists(Server.Mappath(DEF_BBS_HomeUrl & "User/" & path)) Then
		Set fs = Nothing
		Response.Write "<p>硬盘上的原来文件" & path & "不存在，重命名注册文件名失败，请登录ftp检查！"
		RennameRegisterFile = 0
		Exit Function
	End If

	If fs.FileExists(Server.Mappath(DEF_BBS_HomeUrl & "User/" & NewPath)) Then
		Set fs = Nothing
		Response.Write "<p>硬盘上的目标命名文件" & NewPath & "已经存在，重命名注册文件名失败，请登录ftp检查，或选择其它文件名！"
		RennameRegisterFile = 0
		Exit Function
	End If
	
	fs.MoveFile Server.Mappath(DEF_BBS_HomeUrl & "User/" & path),Server.Mappath(DEF_BBS_HomeUrl & "User/" & NewPath)
	If err <> 0 Then
		Err.Clear
		Set fs = Nothing
		Response.Write "<p>硬盘上的注册文件名重命名失败，请登录ftp手动更改．"
		RennameRegisterFile = 0
		Exit Function
	End If
	Set fs = Nothing
         
End Function%>