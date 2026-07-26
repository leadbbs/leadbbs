<!-- #include file=../../inc/BBSSetup.asp -->
<!-- #include file=../../inc/Board_Popfun.asp -->
<!-- #include file=../inc/bbsmanage_Fun.asp -->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass
closeDataBase

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo
If GBL_CHK_Flag=1 Then
	select Case request("action")
		Case "blockdelete":
			DisplayUserNavigate("批量删除论坛数据")
			BlockDelete
		case else
			DisplayUserNavigate("批量整理论坛数据")
			BlockUpdate
	end select
Else
DisplayLoginForm
End If
frame_BottomInfo
Manage_Sitebottom("none")

sub BlockUpdate%>
<script language=javascript>
	function blockupdate(url,str)
	{
	   if (confirm(str))
	   {
		document.location.href=url;
	   }
	}
</script>
<table width="97%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td>
		<div class=alert>警告：</div>
		<div class=frameline>下列修复工作在正常情况下都不需要进行。如果论坛数据较多，执行时间将会非常漫长，运行下列功能将严重影响服务器性能，此服务器上的所有网站在执行期间将受到严重干扰。
			<br>
			批量更新及修复论坛数据(因操作时间漫长，操作任何一项仔细确认)
		</div>
		<div class=frametitle>
			1.<a href="javascript:blockupdate('UpdateUnderWritePrintColumn.asp?flag=1','此操作消耗时间可能会非常长久，建议先暂停论坛再进行更新！\n你确定要 批量更新帖子内容数据 吗？');"><b>批量更新帖子内容数据</b></a>
		</div>
		<div class=frameline>此功能和来批量替换更新帖子中的部分内容，比如批量<br>替换http://w.leadbbs.com/ 为 http://www.leadbbs.com/，慎用！！。
		</div>
		
		<div class=frametitle>
			2.<a href="javascript:blockupdate('UpdateUnderWritePrintColumn.asp?flag=UpdateRootMaxMinAnnounceID','此操作消耗时间可能会非常长久，建议先暂停论坛再进行更新！\n你确定要 修复表LeadBBS_Announce中主题帖子 吗？');"><b>修复表LeadBBS_Announce的主题帖子</b></a>
		</div>
		<div class=frameline>主题有可能会发生分页错误，当查看帖子内容时出现上页下页转移错误时，可以运行此程序更正论坛中一切的此类错误。执行此程序后时，最好暂时关闭论坛运行，以保证快速，完整的更新完毕。默认最长执行时间99999秒，或直到全部数据更新完毕。
		</div>

		<div class=frametitle>
			3.<a href="javascript:blockupdate('UpdateUnderWritePrintColumn.asp?flag=UpdateUserAnnounce','此操作消耗时间可能会非常长久，建议先暂停论坛再进行更新！\n你确定要 重新统计所有用户发帖数量 吗？');"><b>重新统计所有用户发帖数量(不重计<%=DEF_PointsName(0)%>)</b></a>
			<a href="javascript:blockupdate('UpdateUnderWritePrintColumn.asp?flag=UpdateUserAnnounce&ReCount=1','此操作消耗时间可能会非常长久，建议先暂停论坛再进行更新！\n你确定要 重新统计所有用户发帖数量 吗？');"><b>重新统计所有用户发帖数量(重计算<%=DEF_PointsName(0)%>)</b></a>
		</div>
		<div class=frameline>
		重新统计所有用户发表帖子数量，主题帖数量，精华帖数量，并重新计算<%=DEF_PointsName(3)%>。执行此程序后时，最好暂时关闭论坛运行，以保证快速，完整的更新完毕。默认最长执行时间99999秒，或直到全部数据更新完毕。
		</div>

		<div class=frametitle>
			4.<a href="javascript:blockupdate('UpdateUnderWritePrintColumn.asp?flag=UpdateRootMaxMinAnnounceID&BlockType=3','此操作消耗时间可能会非常长久，建议先暂停论坛再进行更新！\n你确定要 重新产生所有用户的农历生日 吗？');"><b>重新产生所有用户的农历生日</b></a>
		</div>
		<div class=frameline>
			用户填写的生日是公历生日，此程序强制再作一次转换，一般不用运行更新此项。执行此程序后时，最好暂时关闭论坛运行，以保证快速，完整的更新完毕。默认最长执行时间99999秒，或直到全部数据更新完毕。
		</div>
	</td>
</tr>
</table>

<%End sub

sub BlockDelete%>

<script language=javascript>
	function blockupdate(url,str)
	{
	   if (confirm(str))
	   {
			document.location.href=url;
	   }
	}
</script>
<table width="97%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td>
		<p><b>快速扫描并批量删除论坛数据(因操作时间漫长，操作任何一项需要再确认)</b></p>
		<div class=frametitle>
		<a href="javascript:blockupdate('UpdateUnderWritePrintColumn.asp?flag=DeleteBlankUser','此操作消耗时间可能会非常长久，建议先暂停论坛再进行更新！\n你确定要 删除无任何发帖量且低在线时间的用户 吗？');"><b>删除无任何发帖在一个月前注册且<%=DEF_PointsName(4)%>低于100的用户</b></font></a>
		</div>
		<div class=frameline>
			此操作将删除无任何发帖，在一个月前注册，且在线时间小于100分钟的用户。程序在删除用户的同时，将同时删除相关的好友资料，收藏帖子，论坛短消息，上传附件，但不删除相应的投票资料。执行此程序后时，最好暂时关闭论坛运行，以保证快速，完整的更新完毕。默认最长执行时间99999秒，或直到全部数据更新完毕。
			<span class=redfont>如果服务器不支持FSO，将不能删除上传附件．</span>
		</div>
		
		<div class=frametitle>
			<a href="DeleteExpiresAnnounceData.asp"><b>批量删除指定条件的论坛帖子</b></a>
		</div>
		<div class=frameline>
		可指定所要删除帖子(按主题并删除相应的回复)所在的版面，最后更新的日间．<br>
		注意：并不删除精华主题及精华主题的回复帖。
		</div>
		<div class=frametitle><a href="UpdateUnderWritePrintColumn.asp?flag=DeleteBlankUser&dflag=upload"><b>批量删除论坛指定条件的历史附件</b></a>
		</div>
		<div class=frameline>
		删除指定日期之间的所有上传附件(包括数据库及硬盘文件，删除文件需要FSO支持)
		</div>
	</td>
</tr>
</table>

<%End sub%>