<%@ LANGUAGE=VBScript CodePage=65001%>
<%Option Explicit
Response.Charset = "utf-8"
Session.CodePage=65001
Response.Buffer = True
Const DEF_ManageDir = "manage"
Response.Redirect "install/default.asp"
If isNumeric(application(DEF_MasterCookies & "SiteEnableFlagzoieiu")) = 0 Then
	Application.Lock
	application(DEF_MasterCookies & "SiteEnableFlagzoieiu") = 1
	Application.UnLock
End If
If application(DEF_MasterCookies & "SiteEnableFlagzoieiu") = 0 and application(DEF_MasterCookies & "SiteDisbleWhyszoieiu")<>"" and inStr(Replace(Lcase(Request.ServerVariables("URL")),"\","/"),"/" & DEF_ManageDir & "/") = 0 Then
	Response.Write application(DEF_MasterCookies & "SiteDisbleWhyszoieiu")
	Response.End
End If

Dim DEF_BBS_HomeUrl,DEF_SiteHomeUrl
const DEF_BBS_Name="LeadBBS论坛"
DEF_BBS_HomeUrl = ""
DEF_SiteHomeUrl = ""
const DEF_BBS_MaxLayer = 10
const DEF_UsedDataBase = 1
const DEF_BBS_SearchMode = 1
const DEF_BBS_TOPMinID = 99999999990000
const DEF_BBS_AnnouncePoints = 1
const DEF_BBS_PrizeAnnouncePoints = 3
const DEF_BBS_MakeGoodAnnouncePoints = 5
const DEF_BBS_MaxTopAnnounce = 9
const DEF_BBS_MaxAllTopAnnounce = 3
Dim DEF_BBS_DisplayTopicLength,DEF_BBS_ScreenWidth
DEF_BBS_DisplayTopicLength = 56
DEF_BBS_ScreenWidth = "770"
const DEF_BBS_LeftTDWidth = "180"
const DEF_MasterCookies = "leadbbs"
const DEF_SiteNameString = "LeadBBS 论坛"
const DEF_SupervisorUserName = ",Admin,"
const DEF_MaxTextLength = 26384
Dim DEF_MaxListNum
DEF_MaxListNum = 32
Const DEF_TopicContentMaxListNum = 12
Const DEF_MaxJumpPageNum = 7000
Const DEF_DisplayJumpPageNum = 4
const DEF_MaxBoardMastNum = 7
const DEF_EnableUserHidden = 1
const DEF_VOTE_MaxNum = 25
const DEF_MaxLoginTimes = 5
const DEF_RestSpaceTime = 10
const DEF_LoginSpaceTime = 600
const DEF_EnableUpload = 1
const DEF_EnableGFL = 0
const DEF_UserOnlineTimeOut = 7200
const DEF_faceMaxNum = 254
const DEF_AllDefineFace = 1
const DEF_AllFaceMaxWidth = 120
const DEF_BBS_EmailMode = 0
Const DEF_EnableAttestNumber = 2
Const DEF_AttestNumberPoints = 200
Dim DEF_BoardStyleString,DEF_BoardStyleStringNum
DEF_BoardStyleString = Array("默认设置","1","2","3")
DEF_BoardStyleStringNum = Ubound(DEF_BoardStyleString,1)
Const DEF_EnableUnderWrite = 1
Const DEF_NeedOnlineTime = 0
Const DEF_EnableForbidIP = 0
Const DEF_TopAdString = "<a href=""http://ww.leadbbs.com/"" target=""_blank""><img src=""/images/temp/banner17.gif"" width=""468"" height=""60"" alt=""空间广告"" /></a>"
Const DEF_AccessDatabase = "data/global.asa"
Const DEF_DefaultStyle = 1002
Const DEF_EnableFlashUBB = 1
Const DEF_EnableImagesUBB = 1
Const DEF_AnnounceFontSize = "14px;font-family:宋体;"
Const DEF_EditAnnounceDelay = 300
Const DEF_DisplayOnlineUser = 1
Const DEF_EnableSpecialTopic = 1
Const DEF_UBBiconNumber = 99
Const DEF_EnableDelAnnounce = 0
Dim DEF_PointsName
DEF_PointsName = Array("积分","财富","声望","等级","经验","认证会员","总版主","区版主","论坛版主","徽章","特殊用户")
Const DEF_EnableMakeTopAnc = 1
Const DEF_EnableDatabaseCache = 0
Const DEF_WriteEventSpace = 2
Const DEF_EditAnnounceExpires = 0
Const DEF_RepeatLoginTimeOut = 300
Const DEF_FSOString = "Scripting.FileSystemObject"
Dim DEF_Now,DEF_Version
DEF_Now = now
DEF_Version = "LeadBBS 9.0"
Const DEF_LineHeight = 27
Const DEF_RegisterFile = "Register.asp"
Const DEF_LimitTitle = 1
Const DEF_DownKey = "sLvGA3pLXuii"
Const DEF_UpdateInterval = 300
Const DEF_BottomInfo = " "
Dim DEF_GBL_Description
DEF_GBL_Description = "LeadBBS论坛"
Const DEF_Sideparameter = 1049088
Const DEF_InstallDir = "/"
%>
