<!--#include file="../../inc/BBSSetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass()

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("全文索引功能管理")
If GBL_CHK_Flag=1 Then
	LoginAccuessFul()
Else
DisplayLoginForm()
End If	
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

Sub LoginAccuessFul

	' Everything on this page is an MSSQL command (sp_fulltext_*, DBCC SHRINKFILE, @@TRANCOUNT).
	' Upstream computed the "unsupported" message into GBL_CHK_TempStr and never printed it, so
	' on any other backend the page rendered as a bare heading with no explanation at all.
	If DEF_UsedDataBase <> 0 Then
		Response.Write "<div class=alert>全文索引及数据库日志管理为 MSSQL 专有功能，" &_
			"当前论坛所用的数据库不支持，此页无可用操作。</div>"
		Exit Sub
	End If%>

<div class=frametitle>数据库全文索引常用控制命令</div>
<div class=frameline>
		<a href=#29 onclick="javascript:window.open('ExeCuteFullTEXTCommands.asp?ExeFlag=1','','width=300,height=20 scrollbars=yes,status=no');"><span class=greenfont>为数据库启用全文索引</span></a>
		<a href=#29 onclick="javascript:window.open('ExeCuteFullTEXTCommands.asp?ExeFlag=2','','width=300,height=20 scrollbars=yes,status=no');"><span class=redfont>为数据库禁用全文索引</span></a> (已经启动切忌不要再启用,先启用下面两项试试)
</div>
<div class=frameline>
		<a href=#29 onclick="javascript:window.open('ExeCuteFullTEXTCommands.asp?ExeFlag=3','','width=300,height=20 scrollbars=yes,status=no');"><span class=greenfont>启动全文索引增量填充</span></a>
		<a href=#29 onclick="javascript:window.open('ExeCuteFullTEXTCommands.asp?ExeFlag=4','','width=300,height=20 scrollbars=yes,status=no');"><span class=redfont>停止全文索引增量填充</span></a> (论坛有帖子但什么东西也搜不到请启用)
</div>
<div class=frameline>
		<a href=#29 onclick="javascript:window.open('ExeCuteFullTEXTCommands.asp?ExeFlag=5','','width=300,height=20 scrollbars=yes,status=no');"><span class=greenfont>启动更新后台中的索引</span></a>
		<a href=#29 onclick="javascript:window.open('ExeCuteFullTEXTCommands.asp?ExeFlag=6','','width=300,height=20 scrollbars=yes,status=no');"><span class=redfont>停止更新后台中的索引</span></a> (论坛新帖了发了半天但搜索不到请启用
</div>
<div class=frameline>
		<a href=#29 onclick="javascript:window.open('ExeCuteFullTEXTCommands.asp?ExeFlag=7','','width=300,height=20 scrollbars=yes,status=no');"><span class=bluefont>将当前一系列跟踪的变化传播到全文索引(更新索引)</span></a>
</div>
		
<div class=frametitle>其它常用命令</div>
<div class=frameline>
		<a href=#29 onclick="javascript:window.open('ExeCuteFullTEXTCommands.asp?ExeFlag=8','','width=300,height=20 scrollbars=yes,status=no');"><span class=bluefont>清除MSSQL当前使用数据库日志(删除后不可恢复日志，当日志满时请使用此命令，请注意经常清除)</span></a><br>
		<a href=#29 onclick="javascript:window.open('ExeCuteFullTEXTCommands.asp?ExeFlag=9','','width=300,height=20 scrollbars=yes,status=no');"><span class=bluefont>收缩MSSQL当前使用数据库日志文件(缩小Log文件来释放硬盘空间给系统)</span></a><br>
		<a href=#29 onclick="javascript:window.open('ExeCuteFullTEXTCommands.asp?ExeFlag=10','','width=300,height=20 scrollbars=yes,status=no');"><span class=bluefont>收缩MSSQL当前使用数据库的数据文件(<span class=redfont>请小心使用此项，使用全文索引数据库可能会产生一些不稳定</span>)</span></a>
</div>
<%
	DisplayOtherInfo()

End Sub

Sub DisplayOtherInfo

	Response.Write "<div class=frametitle>数据库参数参考</div>"
	Response.Write "<table border=0 cellpadding=0 cellspacing=0 width=100% class=frame_table>"
	Dim Rs,SQL
	SQL = "Select @@TRANCOUNT,@@VERSION,@@SERVERNAME,@@LANGUAGE,@@CONNECTIONS,@@CPU_BUSY,@@IDLE,@@IO_BUSY,@@LOCK_TIMEOUT,@@MAX_CONNECTIONS,@@TOTAL_READ,@@TOTAL_WRITE,CURRENT_USER,APP_NAME(),HOST_NAME(),DB_NAME(DB_ID()),DATABASEPROPERTY(DB_NAME(DB_ID()), 'IsFulltextEnabled')"
	Set Rs = LDExeCute(SQL,0)
	If Not Rs.Eof Then
		Response.Write "<tr><td class=tdbox width=200>当前连接的活动事务数</td><td class=tdbox>" & Rs(0) & "个</td>"
		Response.Write "<tr><td class=tdbox>当前安装的日期、版本和处理器类型</td><td class=tdbox>" & Rs(1) & "</td>"
		Response.Write "<tr><td class=tdbox>本地服务器名称</td><td class=tdbox>" & Rs(2) & "</td>"
		Response.Write "<tr><td class=tdbox>当前使用的语言名</td><td class=tdbox>" & Rs(3) & "</td>"
		Response.Write "<tr><td class=tdbox>自上次启动以来连接或试图连接次数</td><td class=tdbox>" & Rs(4) & "次</td>"
		Response.Write "<tr><td class=tdbox>自上次启动以来CPU的工作时间</td><td class=tdbox>" & Rs(5) & "毫秒（基于系统计时器的分辨率）</td>"
		Response.Write "<tr><td class=tdbox>自上次启动后闲置的时间</td><td class=tdbox>" & Rs(6) & "毫秒（基于系统计时器的分辨率）</td>"
		Response.Write "<tr><td class=tdbox>自上次启动后用于执行输入输出时间</td><td class=tdbox>" & Rs(7) & "毫秒（基于系统计时器的分辨率）</td>"
		
		Response.Write "<tr><td class=tdbox>返回当前会话的当前锁超时设置</td><td class=tdbox>" & Rs(8) & "毫秒</td>"
		Response.Write "<tr><td class=tdbox>允许的同时用户连接的最大数</td><td class=tdbox>" & Rs(9) & "人(32767表示未配置)</td>"
		Response.Write "<tr><td class=tdbox>自上次启动后读取磁盘的次数</td><td class=tdbox>" & Rs(10) & "次（不是读取高速缓存）</td>"
		Response.Write "<tr><td class=tdbox>自上次启动后写入磁盘的次数</td><td class=tdbox>" & Rs(11) & "次</td>"
		Response.Write "<tr><td class=tdbox>当前登录用户名</td><td class=tdbox>" & Rs(12) & "</td>"
		Response.Write "<tr><td class=tdbox>当前会话的应用程序名称</td><td class=tdbox>" & Rs(13) & "</td>"
		Response.Write "<tr><td class=tdbox>工作站名称</td><td class=tdbox>" & Rs(14) & "</td>"
		Response.Write "<tr><td class=tdbox>数据库名称</td><td class=tdbox>" & Rs(15) & "</td>"
		Response.Write "<tr><td class=tdbox>数据库是否全文启用</td><td class=tdbox>" & Replace(Replace(Rs(16) & "","0","否"),"1","是") & "</td>"

		Response.write "</tr>"
	End If
	Rs.Close
	Set Rs = Nothing
	Response.Write "</table>"
	
	Response.Write "<div class=frametitle>查看数据库表信息</div><div class=frameline><a href=TableInfo.asp?tb=LeadBBS_Announce>点击这里查看表LeadBBS_Announce信息</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_Assort>点击这里查看表LeadBBS_Assort</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_Boards>点击这里查看表LeadBBS_Boards</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_CollectAnc>点击这里查看表LeadBBS_CollectAnc</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_ForbidIP>点击这里查看表LeadBBS_ForbidIP</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_FriendUser>点击这里查看表LeadBBS_FriendUser</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_GoodAssort>点击这里查看表LeadBBS_GoodAssort</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_InfoBox>点击这里查看表LeadBBS_InfoBox</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_IPAddress>点击这里查看表LeadBBS_IPAddress</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_Link>点击这里查看表LeadBBS_Link</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_onlineUser>点击这里查看表LeadBBS_onlineUser</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_Setup>点击这里查看表LeadBBS_Setup</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_SiteInfo>点击这里查看表LeadBBS_SiteInfo</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_SpecialUser>点击这里查看表LeadBBS_SpecialUser</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_TopAnnounce>点击这里查看表LeadBBS_TopAnnounce</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_Upload>点击这里查看表LeadBBS_Upload</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_User>点击这里查看表LeadBBS_User</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_UserFace>点击这里查看表LeadBBS_UserFace</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_VoteItem>点击这里查看表LeadBBS_VoteItem</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_VoteUser>点击这里查看表LeadBBS_VoteUser</a></div>"

End Sub%>