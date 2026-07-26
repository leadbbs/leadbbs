<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<!--#include file="inc/ForumBoard_fun.asp"-->
<%
Server.ScriptTimeOut = 300
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass()

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("修复论坛昨日发帖量")

If GBL_CHK_Flag=1 Then
	If Request.Form("submitflag") = "yes" then
		UpdateBoardYesterdayAnnounceNum()
		Response.Write "<div class=alertdone>修复昨日发帖量成功！</div>" & VbCrLf
	Else
		%>
		<div class=frameline>注意：此功能将修复以下内容：</div>
		<ol class=listli>
			<li>统计每个版面的昨日发帖量，重新计算昨日发表的帖子</li>
			<li>2.如果服务器时间调整，仍然依发帖的时间来重新统计昨日的帖子(24小时)</li>
		</ol>
		<div class=alert>确认信息：确定开始重新统计昨日发帖吗？点击后耐心等待程序完成执行。</div>
		<div class=frameline>
			<form action=RepairYesterdayAnc.asp method=post name=LeadBBSFm id=LeadBBSFm>
			<input name=submitflag value=yes type=hidden>
			<input type=button value="点击确认开始统计昨日发帖量" onclick="javascript:LeadBBSFm.submit();this.disabled=true;" class=fmbtn>
			</form>
		</div>
		<%
	End If
Else
DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")


Function UpdateBoardYesterdayAnnounceNum

	Dim Rs,GetData,BoardNum,YesterdayAnnounceNum
	Set Rs = LDExeCute("Select BoardID,BoardName from LeadBBS_Boards",0)
	If Not Rs.Eof Then
		GetData = Rs.GetRows(-1)
		BoardNum = Ubound(GetData,2)
	Else
		BoardNum = -1
	End If
	Rs.Close
	Set Rs = Nothing

	YesterdayAnnounceNum = 0
	If BoardNum = -1 Then
		YesterdayAnnounceNum = 0
	Else
		Dim N,StartTime1,StartTime2,GoodNum
		StartTime1 = Left(LngStr(GetTimeValue(DateAdd("d",-1,DEF_Now))),8) & "000000"
		StartTime2 = Left(LngStr(GetTimeValue(DEF_Now)),8) & "000000"
		For N = 0 to BoardNum
			Set Rs = LDExeCute("select count(*) from LeadBBS_Announce where BoardID=" & getData(0,N) & " and ndatetime>=" & StartTime1 & " and ndatetime<" & StartTime2,0)
			If Rs.Eof Then
				GoodNum = 0
			Else
				GoodNum = Rs(0)
				If isNull(GoodNum) Then GoodNum = 0
				GoodNum = cCur(GoodNum)
				YesterdayAnnounceNum = YesterdayAnnounceNum + GoodNum
			End If
			Rs.Close
			Set Rs = Nothing
			Response.Write GetData(1,N) & "昨日发帖共" & GoodNum & "条<br>" & VbCrLf
		Next
	End If
	Dim MaxAnnounce
	Set Rs = LDExeCute(sql_select("Select MaxAnnounce from LeadBBS_SiteInfo",1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
	Else
		MaxAnnounce = Rs(0)
		Rs.Close
		Set Rs = Nothing
		If isNull(MaxAnnounce) Then MaxAnnounce = 0
		MaxAnnounce = cCur(MaxAnnounce)
		If MaxAnnounce < YesterdayAnnounceNum Then
			CALL LDExeCute("Update LeadBBS_SiteInfo Set MaxAnnounce=" & YesterdayAnnounceNum,1)
		End If
	End If
	CALL LDExeCute("Update LeadBBS_SiteInfo Set YesterdayAnc=" & YesterdayAnnounceNum,1)
	ReloadStatisticData()
	Response.Write "<p>完成更新，昨日发帖量共计" & YesterdayAnnounceNum & "条<br>"

End Function
%>