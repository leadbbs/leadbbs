<!-- #include file=../../inc/BBSSetup.asp -->
<!-- #include file=../../inc/Board_Popfun.asp -->
<!-- #include file=../inc/bbsmanage_Fun.asp -->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass

Dim GBL_SiteDisbleWhyString,GBL_REQ_Flag

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo
DisplayUserNavigate("网站重新启动")
If GBL_CHK_Flag=1 Then
	LoginAccuessFul
Else
	DisplayLoginForm
End If
frame_BottomInfo
closeDataBase
Manage_Sitebottom("none")

Function LoginAccuessFul

	If Request.Form("submitflag")="Dieos9xsl29LO_8" Then
		Application.Lock
		If Request("Flag2") <> "" Then
			Application.Contents.RemoveAll()
			Response.Write "<div class=frameline>成功彻底释放论坛变量．</div>"
		Else
			FreeApplicationMemory
			Response.Write "<div class=frameline>成功完成论坛变量重置．</div>"
		End If
		If Request("Flag") <> "" then
			application(DEF_MasterCookies & "SiteEnableFlagzoieiu") = 0
			application(DEF_MasterCookies & "SiteDisbleWhyszoieiu") = "论坛已经关闭"
			Response.Write "<div class=frameline>论坛重启成功，并且已经正常关闭，如果想正常反安装论坛，请不要再访问任何管理员页面．</div>"
		Else
			Response.Write "<div class=frameline>论坛重启成功．</div>"
		End If
		Application.UnLock
	Else
		DisplayStringForm
	End If

End Function

Function DisplayStringForm

%>
<div class=frameline>
请确定是否需要重新启动论坛？重启后论坛一切状态将重置<br>
（相当于Web服务器重启后的结果）<br>
比如在线人数将归零，并释放一些论坛占用的内存．
</div>
<form action=SiteReset.asp method="post">
	<div class=alert>确认信息： 真的重新启动论坛么？</div>
	<div class=frameline>
	<input class=fmchkbox type="checkbox" name=Flag value="yes">选中则在重启后自动关闭网站访问,如果你需要真正的反安装这个论坛,请在此操作后,不要再进行其它的管理员操作,以保服务器内存彻底释放.
	</div>
	<div class=frameline>
	<input class=fmchkbox type="checkbox" name=Flag2 value="yes">选中则彻底释放内存占用(部分服务器不支持)
	</div>
	<div class=frameline>
	<input name=submitflag type=hidden value="Dieos9xsl29LO_8">
	<input type=submit value="重启论坛" class="fmbtn"> <input type=reset value="取消" class="fmbtn">
	</div>
</form>
<div class=frametitle><b>重启后，以下论坛数据将被释放：</b></div>
<div class=frameline>
<table>
	<%
	Dim Thing
	For Each Thing in Application.Contents
		If Left(Thing,Len(DEF_MasterCookies)) = DEF_MasterCookies Then
			Response.Write "<tr><td><font color=Gray class=grayfont>" & thing & "</font></td><td>&nbsp;"
			If isObject(Application.Contents(Thing)) Then
				Response.Write "对象"
			ElseIf isArray(Application.Contents(Thing)) Then
				Response.Write "数组"
			Else
				Response.Write Application.Contents(Thing)
			End If
			Response.Write "</td></tr>"
		End If
	Next
	Response.Write "</table></div>"

End Function

Function FreeApplicationMemory

	Response.Write "<div class=frametitle>释放论坛数据列表：</div><div class=frameline><table>" & VbCrLf
	Dim Thing
	For Each Thing in Application.Contents
		If Left(Thing,Len(DEF_MasterCookies)) = DEF_MasterCookies Then
			Response.Write "<tr><td><font color=Gray class=grayfont>" & thing & "</font></td><td>&nbsp;"
			If isObject(Application.Contents(Thing)) Then
				Application.Contents(Thing).close
				Set Application.Contents(Thing) = Nothing
				Application.Contents(Thing) = null
				Application.Contents.Remove(Thing)
				Response.Write "对象成功关闭"
			ElseIf isArray(Application.Contents(Thing)) Then
				Set Application.Contents(Thing) = Nothing
				Application.Contents(Thing) = null
				Application.Contents.Remove(Thing)
				Response.Write "数组成功释放"
			Else
				Response.Write htmlencode(Application.Contents(Thing))
				Application.Contents(Thing) = null
				Application.Contents.Remove(Thing)
			End If
			Response.Write "</td></tr>"
		End If
	Next
	Response.Write "</table></div>"

End Function%>