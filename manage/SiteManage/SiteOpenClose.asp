<!--#include file="../../inc/BBSSetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass()

Dim GBL_SiteDisbleWhyString,GBL_REQ_Flag

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("网站暂停/开启")
If GBL_CHK_Flag=1 Then
	LoginAccuessFul()
Else
	DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

Function LoginAccuessFul

	GBL_REQ_Flag = Request("Flag")
	If GBL_REQ_Flag <> "close" and GBL_REQ_Flag<>"open" Then GBL_REQ_Flag = "open"
	If GBL_REQ_Flag = "open" Then
		If application(DEF_MasterCookies & "SiteEnableFlagzoieiu") = 1 or application(DEF_MasterCookies & "SiteDisbleWhyszoieiu") = "" Then
			Response.Write "<div class=alert>网站已经开启过了，不需要再开启!</div>" & VbCrLf
		Else
			Application.Lock
			application(DEF_MasterCookies & "SiteEnableFlagzoieiu") = 1
			Application.UnLock
			Response.Write "<div class=alert><span class=greenfont><b>网站成功开启!</b></span></div>" & VbCrLf
		End If
	Else
		If application(DEF_MasterCookies & "SiteEnableFlagzoieiu") = 0 and application(DEF_MasterCookies & "SiteDisbleWhyszoieiu") <> "" Then
			Response.Write "<div class=alert>网站已经关闭过了，不需要再关闭!</div>" & VbCrLf
		Else
			If Request.Form("submitflag")="Dieos9xsl29LO_8" Then
				GBL_SiteDisbleWhyString = Request("GBL_SiteDisbleWhyString")
				If Trim(GBL_SiteDisbleWhyString) <> "" Then
					Application.Lock
					application(DEF_MasterCookies & "SiteEnableFlagzoieiu") = 0
					application(DEF_MasterCookies & "SiteDisbleWhyszoieiu") = GBL_SiteDisbleWhyString
					Application.UnLock
					Response.Write "<div class=alert><span class=greenfont><b>网站关闭成功，下面即网站暂停访问的原因：</b></span></div><hr size=1>" & PrintTrueText(GBL_SiteDisbleWhyString) & "<hr size=1>" & VbCrLf
				Else
					Response.Write "<div class=alert>暂停用户访问原因不能为空!</div>"
				End If
				DisplayStringForm()
			Else
				GBL_SiteDisbleWhyString = DEF_Now & " 起网站暂停访问"
				DisplayStringForm()
			End If
			If DEF_UsedDataBase = 1 and DEF_EnableDatabaseCache = 1 Then
				If isObject(Application(DEF_MasterCookies & "con")) = True Then
					Application.Lock
					Application(DEF_MasterCookies & "con").Close
					Set Application(DEF_MasterCookies & "con") = Nothing
					Application(DEF_MasterCookies & "con") = ""
					Application.UnLock
				End If
				GBL_ConFlag = 0
			End If
		End If
	End If

End Function

Function DisplayStringForm

%>
<form action=SiteOpenClose.asp method="post">
	<div class=frameline>要暂停访问请写出<span class=redfont>暂停用户访问的原因</span>:
	</div>
	<div class=frameline>
	<textarea class=fmtxtra name=GBL_SiteDisbleWhyString rows=8 cols=61 ><%If GBL_SiteDisbleWhyString <> "" Then Response.Write VbCrLf & htmlEncode(GBL_SiteDisbleWhyString)%></textarea>
	</div>
	<input name=submitflag type=hidden value="Dieos9xsl29LO_8">
	<input name=Flag type=hidden value="<%=htmlencode(GBL_REQ_Flag)%>">
	
	<div class=frameline>
	<input type=submit value="暂停" class=fmbtn> <input type=reset value="取消" class=fmbtn>
	</div>
</form>

	<div class=frameline>
		请注意，暂停网站后，请不要关闭此浏览窗口，或重新登录设置为Cookie保存（不要选择无效），<span class=redfont>否则管理员将无法重新开启网站</span>(为了保证暂停后的关键数据更新安全)。
	</div>
<%

End Function

Function PrintTrueText(tempString)

	If tempString<>"" Then
		PrintTrueText=Replace(Replace(Replace(Replace(Replace(htmlEncode(tempString),VbCrLf & " ","<br>" & "&nbsp;"),VbCrLf,"<br>" & VbCrLf),"   "," &nbsp; "),"  "," &nbsp;"),chr(9)," &nbsp; &nbsp; &nbsp;")

		If Left(PrintTrueText,1) = chr(32) Then
			PrintTrueText = "&nbsp;" & Mid(PrintTrueText,2)
		End If
	Else
		PrintTrueText=""
	End If

End Function%>