<!-- #include file=../../inc/BBSsetup.asp -->
<!-- #include file=../../inc/Board_popfun.asp -->
<!-- #include file=../inc/bbsmanage_Fun.asp -->
<%
DEF_BBS_HomeUrl = "../../"

Const LMT_RankNumber = 1000  '最大排名数

Dim GBL_ID
initDatabase
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo
DisplayUserNavigate("修复论坛统计清除在线用户")
If GBL_CHK_Flag=1 Then
	If Request.Form("submitflag") = "yes" then
		If Request.Form("a") = "m" Then
			'ReMakeRank
		Else
			ClearOnlineUser
		End If
	Else
		%><div class=frametitle>一、清除在线会员</div>
			<div class=frameline>注意：此功能将完成以下功能：</div>
			<ol class=listli>
				<li>清除当前在线的所有人员（包括游客）。</li>
				<li>清除后的在线人员，需要在2分钟左右的活动后才能重新成为在线会员</li>
				<li>清除每个版面(包括隐藏版面)的在线人数为零</li>
				<li>清除总在线人数为零</li>
			</ol>
			<div class=alert>确认信息： 真的要开始清除在线人员么？</div>
			
			<div class=frameline>
			<form action=ClearOnlineUser.asp method=post>
			<input type=hidden name=submitflag value="yes">
			<input type=submit value=点击开始清除在线人员 class=fmbtn>
			</form>
			</div>
			
			<div class=frameline><a href=../SiteManage/RepairSite.asp>如果仅仅是想修复每个版面的在线人数或总在线人数，请点击这里</a>
			</div>
		<!--
			<div class=frametitle>二、重新生成用户排名</div>
			
			<div class=frameline>
			用户排名依经验(在线时间)来排名。且只限前<%=LMT_RankNumber%>名用户才有排名资格。<br>
			因重排名需要消耗的时间非常之大，建议尽量少进行此项工作。
			</div>
			<div class=frameline>
			<form action=ClearOnlineUser.asp method=post>
			<input type=hidden name=submitflag value="yes">
			<input type=hidden name=a value="m">
			<input type=submit value=点击重新生成用户排名 class=fmbtn>
			</form>
			</div>
		-->	
		<%
	End If
Else
DisplayLoginForm
End If
frame_BottomInfo
closeDataBase
Manage_Sitebottom("none")

Sub ClearOnlineUser

	If DEF_UsedDataBase = 1 Then
		CALL LDExeCute("delete from LeadBBS_onlineUser",1)
	Else
		CALL LDExeCute("TRUNCATE TABLE LeadBBS_onlineUser",1)
	End If
	Application.Lock
	Application(DEF_MasterCookies & "ActiveUsers") = 0
	Application.UnLock
	
	Dim SQL,I
	If isArray(Application(DEF_MasterCookies & "BListAll")) = True Then
		SQL = Ubound(Application(DEF_MasterCookies & "BListAll"),2)
		Application.Lock
		For I = 0 To SQL
			Application(DEF_MasterCookies & "BDOL" & Application(DEF_MasterCookies & "BListAll")(0,I)) = 0
		Next
		Application.UnLock
	End If
	Response.write "<div class=frameline><span class=greenfont>成功清除所有在线用户！</span>[" & DEF_Now & "]</div>"

End Sub

Sub ReMakeRank

	exit sub
	Server.ScriptTimeOut = 6000
	Dim Rs,N,OnlineTime
	Con.CommandTimeout = 600
	Set Rs = LDExeCute(sql_select("Select ID,OnlineTime,SessionID From LeadBBS_User Order by OnlineTime DESC",LMT_RankNumber),0)
	If Not Rs.Eof Then
		For N = 1 to 1000
			If Not Rs.Eof Then
				If cCur(Rs(2)) <> N Then CALL LDExeCute("Update LeadBBS_User Set SessionID=" & N & " where ID=" & Rs(0),1)
				OnlineTime = Rs(1)
				Rs.MoveNext
			Else
				Exit For
			End If
		Next
		CALL LDExeCute("Update LeadBBS_User Set SessionID=0 where OnlineTime<" & OnlineTime & " and SessionID<>0",1)
	End If
	Rs.Close
	Set Rs = Nothing
	Response.write "<div class=frameline><span class=greenfont>成功重新生成用户排名！</span>[" & DEF_Now & "]</div>"

End Sub
%>