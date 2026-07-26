<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="../inc/Upload_Setup.asp"-->
<!--#include file="../inc/Board_Popfun.asp"-->
<!--#include file="../User/inc/UserTopic.asp"-->
<!--#include file="inc/Upload_fun.asp"-->
<%
DEF_BBS_HomeUrl = "../"

Sub Main

	'GBL_CHK_PWdFlag = 0
	initDatabase()
	GBL_CHK_TempStr = ""
	BBS_SiteHead DEF_SiteNameString & " - 论坛附件",0,"论坛附件"
	UpdateOnlineUserAtInfo 0,"论坛附件"
	If GBL_UserID < 1 Then
		GBL_CHK_TempStr = "只有注册用户才能查看论坛附件。"
	Else
		If GBL_CHK_OnlineTime < DEF_NeedOnlineTime Then GBL_CHK_TempStr = "在线时间(" & DEF_PointsName(4) & ")不足，只有在线时间超过" & DEF_NeedOnlineTime & "秒的用户才能使用此功能。"
	End If
	
	'If GetBinarybit(GBL_CHK_UserLimit,11) = 1 and (GetBinarybit(GBL_CHK_UserLimit,10) = 1 or GetBinarybit(GBL_CHK_UserLimit,8) = 1) Then
	'If CheckSupervisorUserName = 1 or (GetBinarybit(GBL_CHK_UserLimit,10) = 1 or GetBinarybit(GBL_CHK_UserLimit,8) = 1) or GetBinarybit(GBL_CHK_UserLimit,14) = 1 Then
	'Else
		'GBL_CHK_TempStr = "全部附件查看已设为只允许版主查看．"
	'End If

	UserTopicTopInfo("forum")
	If GBL_CHK_TempStr = "" Then
		CALL Upload_List(0,0,"../Search/UploadList.asp?ttsID=3",1)
	Else
		Response.Write "<div class=alert>" & GBL_CHK_TempStr & "</div>"
	End If
	closeDataBase()
	UserTopicBottomInfo()
	SiteBottom()

End Sub

Main()
%>