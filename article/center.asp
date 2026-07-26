<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="../inc/User_Setup.asp"-->
<!--#include file="../inc/Board_popfun.asp"-->
<!--#include file="../inc/Limit_fun.asp"-->
<!--#include file="inc/UserTopic.asp"-->
<!--#include file="../inc/Constellation2.asp"-->
<!--#include file="../a/inc/upload1_fun.asp"-->
<%DEF_BBS_HomeUrl = "../"%>
<!--#include file="../inc/Upload_Fun.asp"-->
<!--#include file="inc/popfun.asp"-->
<!--#include file="inc/cms_fun.asp"-->
<!--#include file="inc/center_editfile.asp"-->
<!--#include file="inc/center_setchannel.asp"-->
<!--#include file="../a/inc/Editor.asp"-->
<!--#include file="../a/inc/Editor_Fun.asp"-->
<%
Dim Form_Submitflag,Form_Action,Form_ActionStr,GBL_AjaxFlag,Form_UpClass
Dim LMT_EnableUpload
LMT_EnableUpload = 1
Dim Form_EditAnnounceID
Form_EditAnnounceID = 0
UploadTable = "article_upload"
PhotoDirectory = DEF_BBS_HomeUrl & DEF_CMS_UploadPhotoUrl
UploadPhotoUrl = DEF_BBS_HomeUrl & DEF_CMS_UploadPhotoUrl
UploadOneDayMaxNum = DEF_CMSUploadOneDayMaxNum
upload_NoteLength = 255

Main()

Sub Page_Expires

	Response.Expires = 0
	Response.ExpiresAbsolute = DEF_Now - 1
	Response.AddHeader "pragma","no-cache"
	Response.AddHeader "cache-control","private" 
	Response.CacheControl = "no-cache"

End Sub

Sub Main

	Page_Expires()
	initDatabase()
	User_GetStartValue()

	If GBL_AjaxFlag = 0 Then
		article_center_Head(Form_ActionStr)
		%><div class="body_area_out">
		<%cms_manage_Navigate("<span class=navigate_string_step>" & Form_ActionStr & "</span>")
	End If
	UpdateOnlineUserAtInfo GBL_board_ID,Form_ActionStr
	GBL_CHK_TempStr=""
	If GBL_UserID = 0 Then GBL_CHK_TempStr = GBL_CHK_TempStr & "未登录或密码错误.<br>" & VbCrLf

	If GBL_AjaxFlag = 0 Then UserTopicTopInfo("user")

	If GBL_CHK_Flag=1 Then
		If GBL_CHK_TempStr = "" Then
			Main_Action()
		Else
			cms_DisplayLoginForm(GBL_CHK_TempStr)
		End If
	Else
		If Form_Submitflag = "" Then
			cms_DisplayLoginForm("请先登录")
		Else
			cms_DisplayLoginForm("<span class=redfont>" & GBL_CHK_TempStr & "</span>")
		End If
	End If

	closeDataBase()
	If GBL_AjaxFlag = 0 Then cms_UserTopicBottomInfo
	If GBL_AjaxFlag = 0 Then cms_center_Bottom
	If Form_UpFlag = 1 Then Set Form_UpClass = Nothing

End Sub

Sub User_GetStartValue

	If Request.QueryString("dontRequestFormFlag") = "" Then
		Form_UpFlag = 0
	Else
		Form_UpFlag = 1
		init_Upload = 1
		Server.ScriptTimeOut=3000
		set Form_UpClass = new upload_Class
		Form_UpClass.ProgressID = Request.QueryString("Upload_ID")
		Form_UpClass.GetUpFile
	End If

	Form_Submitflag = Request.QueryString("submitflag")
	If Form_Submitflag = "" Then Form_Submitflag = GetFormData("submitflag")
	Form_Action = GetFormData("action")
	GBL_AjaxFlag = GetFormData("ajaxflag") 
	If GBL_AjaxFlag <> "1" Then 
		GBL_AjaxFlag = 0
	Else
		GBL_AjaxFlag = 1
	End If
	Select Case Form_Action
		case "newsclass":
			Form_ActionStr = "添加文章分类(管理员)"
			if GetFormData("form_modifyid") <> "" and GetFormData("form_modifyid") <> "0" Then Form_ActionStr = "编辑文章分类(管理员)"
		case "newsarticle":
			Form_ActionStr = "添加文章内容"
			if GetFormData("form_modifyid") <> "" and GetFormData("form_modifyid") <> "0" Then Form_ActionStr = "编辑文章内容"
		case "newsmanage":
			Form_ActionStr = "管理文章"
		case "editfile":
			Form_ActionStr = "编辑其它信息"
		case "setchannel":
			Form_ActionStr = "设置栏目内容"
		case "updatecache":
			Form_ActionStr = "更新缓存"
		Case Else
			Form_Action = "newsmanage"
			Form_ActionStr = "管理文章"
	End Select			

End Sub


Sub Main_Action

	If Check_jdsupervisor() = 0 and (CheckUserAnnounceLimit() = 0 or GBL_UserID < 1) Then
		Response.Write "<span class=cms_error>您无权进行此操作,可能此用户未认证,或已被禁用相关权限.</span>"
		Exit Sub
	End if
	Select Case Form_Action
		case "newsclass":
			center_newsclass()
		case "newsarticle":
			center_newsarticle()
		case "newsmanage":
			center_newsmanage()
		case "editfile":
			center_editfile()
		case "setchannel":
			center_setchannel()
		case "updatecache":
			center_updatecache()
	End Select

End Sub

sub center_updatecache

	Response.Write "<div class=""cms_ok"">开始更新缓存．．．</div>"
	Response.Write "<div class=""cms_ok"">开始读取缓存内容并展示．．．</div>"
	Response.Write "<div style=""zoom:0.8;max-height:600px;overflow:auto;"">"
	dim cmscacheClass
	set cmscacheClass = new cms_cache_Class
	cmscacheClass.updatecache
	set cmscacheClass = nothing
	response.Write "</div>"
	Response.Write "<div class=""clear""></div><div class=""cms_ok"" style=""width:100%;"">缓存更新完成．</div>"

End sub
%>