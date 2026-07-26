<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="../inc/Board_popfun.asp"-->
<!--#include file="inc/UserTopic.asp"-->
<%
DEF_BBS_HomeUrl = "../"

Main_Hidden()

Sub Main_Hidden

	initDatabase()
	GBL_CHK_TempStr = ""
	
	Dim ShowFlagString
	If GBL_CHK_ShowFlag = 1 Then
		ShowFlagString = "上线"
	Else
		ShowFlagString = "隐身"
	End If
	BBS_SiteHead DEF_SiteNameString & " - " & ShowFlagString,0,"<span class=navigate_string_step>" & ShowFlagString & "</span>"
	
	If GBL_UserID=0 Then GBL_CHK_TempStr = GBL_CHK_TempStr & "您没有登录!" & VbCrLf
	
	Dim u
	u = Lcase(Request.ServerVariables("HTTP_REFERER"))
	
	Dim HomeUrl
	HomeUrl = "http://"&Request.ServerVariables("server_name")
	If Request.ServerVariables("SERVER_PORT") <> "80" Then HomeUrl = HomeUrl & ":" & Request.ServerVariables("SERVER_PORT")
	
	If Left(u,Len(HomeUrl)) <> HomeUrl Then u = ""
	If inStr(u,"/user/hidden.asp") > 0 Then u = ""
	'u = Request.QueryString("u")
	
	Boards_Body_Head("")
	%>
	<div class=alertbox>
	<%
	If DEF_EnableUserHidden = 1 Then
		If GBL_CHK_Flag=1 Then
			If ShowFlagString = "隐身" Then
				CALL LDExeCute("Update LeadBBS_User Set ShowFlag=1 where ID=" & GBL_UserID,1)
				UpdateSessionValue 3,1,0
				CALL LDExeCute("Update LeadBBS_OnlineUser Set HiddenFlag=0,UserName='隐身会员' where UserID=" & GBL_UserID,1)
			Else
				CALL LDExeCute("Update LeadBBS_User Set ShowFlag=0 where ID=" & GBL_UserID,1)
				UpdateSessionValue 3,0,0
				CALL LDExeCute("Update LeadBBS_OnlineUser Set HiddenFlag=" & GBL_CHK_UserLimit & ",UserName='" & Replace(GBL_CHK_User,"'","''") & "' where UserID=" & GBL_UserID,1)
			End If
			Response.Write "<p>您已经成功" & ShowFlagString
				
			If u <> "" Then Response.Redirect u
		Else
			If Request("submitflag")="" Then
				DisplayLoginForm("请先登录")
			Else
				DisplayLoginForm(GBL_CHK_TempStr)
			End If
		End If
	Else%>
		<div class=alert>
			论坛已经禁止使用隐身功能
		</div>
	<%End If
	%>
	</div>
	<%
	Boards_Body_Bottom()
	closeDataBase()
	SiteBottom()

End Sub
%>