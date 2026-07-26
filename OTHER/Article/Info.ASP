<!--#include file="../../inc/BBSSetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<%

DEF_BBS_HomeUrl = "../../"
OpenDatabase()
DisplayLeadBBSInfo()
closeDataBase()

'----------------------------------------------------------------------------------------
'----- LeadBBS论坛信息调用程序(2003-09-30 by SpiderMan) for LeadBBS v2.88 v2.77 v3.14
'----- 调用举例: <script language=javascript src=http://安装目录/other/Article/Topic.asp?img=/images/del.gif></script>
'----- 参数img：指定显示在前面的修饰图片地址，不指定则不显示图片，要求大小16x16
'----- 参数exectime：是否显示执行时间，no:不显示，其它表示显示
'----------------------------------------------------------------------------------------

Function DisplayLeadBBSInfo

	Dim HomeUrl
	HomeUrl = "http://"&Request.ServerVariables("server_name")
	If Request.ServerVariables("SERVER_PORT") <> "80" Then HomeUrl = HomeUrl & ":" & Request.ServerVariables("SERVER_PORT")
	HomeUrl = Lcase(HomeUrl & Request.Servervariables("SCRIPT_NAME"))
	HomeUrl = Replace(HomeUrl,"other/article/info.asp","")

	Dim GBL_OnlineUserNum,GBL_UserCount,GBL_MaxOnline,GBL_MaxolTime,GBL_OnlineTime,GBL_PageCount,GBL_UploadNum
	Dim GBL_MaxAnnounce,GBL_MaxAncTime,GBL_YesterdayAnc
	Dim Rs,SQL
	
	Dim TmpData
	If isArray(application(DEF_MasterCookies & "StatisticData")) = False Then ReloadStatisticData
	TmpData = Application(DEF_MasterCookies & "StatisticData")
	GBL_OnlineTime = cCur(TmpData(0,0))
	GBL_UserCount = cCur(TmpData(1,0))
	GBL_MaxOnline = cCur(TmpData(2,0))
	GBL_MaxolTime = cCur(TmpData(3,0))
	GBL_PageCount = cCur(TmpData(4,0))
	GBL_UploadNum = cCur(TmpData(5,0))
	GBL_MaxAnnounce = cCur(TmpData(6,0))
	GBL_MaxAncTime = cCur(TmpData(7,0))
	GBL_YesterdayAnc = cCur(TmpData(8,0))

	Dim GBL_TodayAnnounce,GBL_GoodNum,GBL_AnnounceNum
	SQL = "select sum(TodayAnnounce_All),sum(GoodNum_All),sum(AnnounceNum_All) from LeadBBS_Boards where ParentBoard=0"
	Set Rs = LDExeCute(SQL,0)
	If Not Rs.Eof Then
		GBL_TodayAnnounce = Rs(0)
		GBL_GoodNum = Rs(1)
		GBL_AnnounceNum = Rs(2)
	Else
		GBL_TodayAnnounce = 0
		GBL_GoodNum = 0
		GBL_AnnounceNum = 0
	End If
	Rs.Close
	Set Rs = Nothing

	Dim img,Temp
	img = Replace(Replace(Left(Request.QueryString("img"),100),"\",""),"""","")
	If img <> "" Then img = "<img src=" & Replace(img,"\","\\") & " align=middle width=16 height=16>"

	Response.Write "document.write("""
	Response.Write img & "帖子总数：" & GBL_AnnounceNum & "帖"
	Response.Write "<br>" & img & "精华帖子：" & GBL_GoodNum & "帖"
	Response.Write "<br>" & img & "注册用户：" & GBL_UserCount & "人"
	Response.Write "<br>" & img & "用户在线："
	
	If isNumeric(application(DEF_MasterCookies & "SiteOlTime")) = False Then
		Application.Lock
		application(DEF_MasterCookies & "SiteOlTime") = 0
		Application.UnLock
	End If
	GBL_OnlineTime = GBL_OnlineTime + application(DEF_MasterCookies & "SiteOlTime")
	Temp = (GBL_OnlineTime)/(24*60*60)
	Response.Write Fix(Temp) & "天"
	'GBL_OnlineTime=GBL_OnlineTime-Fix(Temp)*24*60*60
	'Temp = GBL_OnlineTime/(60*60)
	'Response.Write Fix(Temp) & "时"
	'GBL_OnlineTime=GBL_OnlineTime-Fix(Temp)*60*60
	'Temp = GBL_OnlineTime/60
	'Response.Write Fix(Temp) & "分"
	
	Response.Write "<br>" & img & "页面访问：" & (GBL_PageCount+application(DEF_MasterCookies & "SitePageCount")) & "次"
	Response.Write "<br>" & img & "当前在线：" & application(DEF_MasterCookies & "ActiveUsers") & "人"
	Response.Write "<br>" & img & "最高在线：" & GBL_MaxOnline & "人"
	'Response.Write "<br>" & img & "最高日发帖：" & GBL_MaxAnnounce & "帖"
	Response.Write "<br>" & img & "今日发帖：<b><font color=Red class=redfont>" & GBL_TodayAnnounce & "</font></b>帖"
	Response.Write "<br>" & img & "上传附件：" & GBL_UploadNum & "个"

	If Request.QueryString("exectime") <> "no" Then Response.Write "<br>" & img & "执行时间：" & FormatNumber(cCur(Timer - DEF_PageExeTime1),4,True)*1000 & "毫秒"
	Response.Write """);"

End Function%>