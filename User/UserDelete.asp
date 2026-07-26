<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="../inc/Board_popfun.asp"-->
<!--#include file="inc/UserTopic.asp"-->
<%
DEF_BBS_HomeUrl = "../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = GBL_UserID
GBL_CHK_TempStr = ""
SiteHead(DEF_SiteNameString & " - 用户区")
UpdateOnlineUserAtInfo GBL_board_ID,"用户自我删除"

If GBL_ID=0 Then
	GBL_CHK_TempStr = GBL_CHK_TempStr & "您没有登录!<br>" & VbCrLf
End If

UserTopicTopInfo()
DisplayUserNavigate("用户自我删除")

GBL_CHK_TempStr = "<br><b>千万不要自杀!</b>"
If GBL_CHK_Flag=1 Then
	If GBL_CHK_TempStr="" Then
	Else%>
		<table width=96%>
		<tr>
			<td>
				<%Response.Write GBL_CHK_TempStr%>
			</td>
		</tr>
		</table>
	<%End If
Else%>
	<table width=96%>
	<tr>
	<td>
	<%
	If Request("submitflag")="" Then
		Response.Write "<br><b>请先登录</b>"
	Else
		Response.Write "<br><p align=left><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font>"
	End If
	DisplayLoginForm()
	Response.Write "</p>"%>
	</td>
	</tr>
	</table>
<%End If
UserTopicBottomInfo()
closeDataBase()
SiteBottom()
If GBL_ShowBottomSure = 1 Then Response.Write GBL_SiteBottomString%>