<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<!--#include file="../../b/inc/cache_fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass()

Manage_sitehead DEF_SiteNameString & " - 管理员",""

frame_TopInfo()
DisplayUserNavigate("清除总固顶状态")
If GBL_CHK_Flag=1 Then
	DeleteAllTopAnnounce()
Else
	DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

Function DeleteAllTopAnnounce

	If Request.Form("submitflag") = "yes" then
		If Request.Form("Reload") = "yes" Then
			ReloadTopAnnounceInfo(0)
			Response.Write "<b><font color=Green Class=greenfont>总固顶信息完成更新！</font></b>"
		Else
			CALL LDExeCute("delete from LeadBBS_TopAnnounce",1)
			ReloadOtherTopAnnounce()
			Application.Lock
			Set application(DEF_MasterCookies & "TopAnc") = Nothing
			application(DEF_MasterCookies & "TopAnc") = "yes"
			application(DEF_MasterCookies & "TopAncList") = ""
			Application.UnLock
		
			Response.Write "<b><font color=Green Class=greenfont>总固顶信息清除完毕并完成更新！</font></b>"
		End If
	Else%>
		<div class=frametitle>注意：点击开始清除功能将完成以下功能：</div>
		<ol class=listli>
			<li>解除所有总固顶帖子</li>
			<li>删除可能存在的冗余总固顶数据</li>
			<li>解决因论坛意外产生的冗余数据进而不能继续总固顶</li>
			<li>解除所有区固顶帖子</li>
		</ol>
		<div class=frameline>点击开始更新按钮将完成以下功能:</div>
		<ol class=listli>
			<li>不清除额外的剩余的总固顶数据</li>
			<li>重新读取总固顶数据</li>
		</ol>
		<div class=alert>确认信息： 真的要进行上述操作么？</div>
		
		<div class=frameline>
		<form action=DeleteAllTopAnnounce.asp method=post>
		<input type=hidden name=submitflag value="yes">
		<input type=submit value=点击开始清除 class=fmbtn>
		</form>
		</div>
		
		<div class=frameline>
		<form action=DeleteAllTopAnnounce.asp method=post>
		<input type=hidden name=submitflag value="yes">
		<input type=hidden name=Reload value="yes">
		<input type=submit value=点击开始更新 class=fmbtn>
		</form>
		</div>
	<%
	End If

End Function

Sub ReloadOtherTopAnnounce

	Dim Rs,SQL,GetData,N
	Set Rs = LDExeCute("Select AssortID from LeadBBS_Assort",0)
	If Not Rs.Eof Then
		GetData = Rs.GetRows(-1)
		Rs.Close
		Set Rs = Nothing
		SQL = Ubound(GetData,2)
		For N = 0 to SQL
			ReloadTopAnnounceInfo(cCur(GetData(0,n)))
		Next
	Else
		Rs.Close
		Set Rs = Nothing
	End If

End Sub

%>