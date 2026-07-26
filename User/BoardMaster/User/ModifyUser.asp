<!--#include file="../../../inc/BBSsetup.asp"-->
<!--#include file="../../../inc/Upload_Setup.asp"-->
<!--#include file="../../../inc/Board_Popfun.asp"-->
<!--#include file="../inc/BoardMaster_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../../"
initDatabase()
GBL_CHK_TempStr = ""

SiteHead(DEF_SiteNameString & " - " & DEF_PointsName(6) & "管理")

UserTopicTopInfo()
DisplayUserNavigate("强制修改用户资料")%>
<br><br><%
If GBL_CHK_Flag=1 and BDM_isBoardMasterFlag = 1 and BDM_SpecialPopedomFlag = 1 Then
	LoginAccuessFul()
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
</table><%
End If

UserTopicBottomInfo()
closeDataBase()
SiteBottom()
If GBL_ShowBottomSure = 1 Then Response.Write GBL_SiteBottomString

Dim GBL_ModifyMode,GBL_UserName,GBL_UserName_UserID,GBL_UserName_FaceUrl
Dim GBL_UserName_UnderWrite,GBL_UserName_UserTitle
GBL_ModifyMode = 0

Function LoginAccuessFul

	If Request.Form("submitflag") <> "" Then
		CheckForm()
		If GBL_CHK_TempStr = "" Then
			ModifyUser()
			Response.Write GBL_CHK_TempStr
			GBL_CHK_TempStr = ""
			DisplayForm()
		Else
			DisplayForm()
		End If
	Else
		DisplayForm()
	End If

End Function

Function ModifyUser

	Response.Write "<p><b>开始清除用户<u>" & htmlencode(GBL_UserName) & "</u>的下列资料：</b></p>" & VbCrLf
	If inStr(GBL_ModifyMode,",1,") Then
		If GBL_UserName_FaceUrl & "" = "" Then
			Response.Write "<p><font color=Red class=redfont>清除链接头像： 此用户头像已经是默认头像，略过操作。</font></p>"
			DeleteUploadFace(GBL_UserName_UserID)
		Else
			CALL LDExeCute("Update LeadBBS_User Set FaceUrl='' where ID=" & GBL_UserName_UserID,1)
			Response.Write "<p><font color=Green class=greenfont>清除链接头像： 成功清除。</font></p>"
			DeleteUploadFace(GBL_UserName_UserID)
		End If
	End If

	If inStr(GBL_ModifyMode,",2,") Then
		If GBL_UserName_UnderWrite & "" = "" Then
			Response.Write "<p><font color=Red class=redfont>清除用户签名： 此用户无签名内容，略过操作。</font></p>"
		Else
			CALL LDExeCute("Update LeadBBS_User Set UnderWrite='',PrintUnderWrite='' where ID=" & GBL_UserName_UserID,1)
			Response.Write "<p><font color=Green class=greenfont>清除用户签名： 成功清除。</font></p>"
		End If
	End If

	If inStr(GBL_ModifyMode,",3,") Then
		If GBL_UserName_UserTitle & "" = "" Then
			Response.Write "<p><font color=Red class=redfont>清除用户头衔： 此用户无头衔，略过操作。</font></p>"
		Else
			CALL LDExeCute("Update LeadBBS_User Set UserTitle='' where ID=" & GBL_UserName_UserID,1)
			Response.Write "<p><font color=Green class=greenfont>清除用户头衔： 成功清除。</font></p>"
		End If
	End If

	If CheckSupervisorUserName() = 0 Then
		CALL LDExeCute("Update LeadBBS_User Set LastWriteTime=" & GetTimeValue(DEF_Now) & " where ID=" & GBL_UserID,1)
	End If

End Function

Function CheckForm

	If CheckWriteEventSpace() = 0 Then
		Response.Write "<b><font color=Red Class=redfont>您的操作过频，请稍候再作提交!</font></b> <br>" & VbCrLf
		Exit Function
	End If
	
	GBL_ModifyMode = Replace("," & Left(Request.Form("GBL_ModifyMode"),10) & ","," ","")
	GBL_UserName = Left(Request.Form("GBL_UserName"),20)
	If isNumeric(Replace(GBL_ModifyMode,",","")) = 0 Then
		GBL_CHK_TempStr = "错误，操作选项选择错误！"
		Exit Function
	End If

	If GBL_UserName = "" Then
		GBL_CHK_TempStr = "错误，请输入用户名！"
		Exit Function
	End If
	
	If CheckUserNameExist(GBL_UserName) = 0 Then
		GBL_CHK_TempStr = "错误，用户名不存在！"
		Exit Function
	End If

End Function

Function DisplayForm

	If GBL_CHK_TempStr <> "" Then Response.Write "<p><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font></p>"%>

			<%If Request.Form("submitflag") = "LKOkxk2" or Request.Form("submitflag") = "" Then%>
			<p>
		  <b>输入用户名称</b>
          <form action=ModifyUser.asp method=post id=fobform name=fobform>
			用 户 名： <input name=GBL_UserName value="<%=htmlencode(GBL_UserName)%>" class=fminpt><br>
			<input name=submitflag type=hidden value="LKOkxk2">
			选择操作：<input name=GBL_ModifyMode value=1<%If inStr(GBL_ModifyMode,",1,") Then Response.Write " checked"%> type=checkbox>清除链接头像
			<input name=GBL_ModifyMode value=2<%If inStr(GBL_ModifyMode,",2,") Then Response.Write " checked"%> type=checkbox>清除用户签名
			<input name=GBL_ModifyMode value=3<%If inStr(GBL_ModifyMode,",3,") Then Response.Write " checked"%> type=checkbox>清除用户头衔
			<br><br>
			<input type=submit value="提交" class=fmbtn> <input type=reset value="取消" class=fmbtn></form>
			<br>
			<b>说明：</b><br><br>
			1.清除用户链接头像后，此用户头像恢复为论坛已有的头像，<br>
			&nbsp; 男性编号为1，女性编号为2，无性别为0．<br>
			2.清除用户签名将会仍指定的用户签名内容全部擦除<br>
			3.清除用户头衔将会仍指定的用户头取消<br>
			4.某些特定用户资料不允许修改
			<%End If%>

<%End Function

Rem 检测某用户名是否存在
Function CheckUserNameExist(UserName)

	If UserName <> "" and inStr(UserName,",") = 0 and inStr(Lcase(DEF_SupervisorUserName),"," & Lcase(UserName) & ",") > 0 Then
		'作这样的同样提示是为了以防管理员名字被泄漏，实际应该提示管理员不能被屏蔽
		GBL_CHK_TempStr = "错误，用户名" & htmlencode(UserName) & "不存在！"
		CheckUserNameExist = 0
		Exit Function
	End If

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select ID,UserName,FaceUrl,UnderWrite,UserTitle from LeadBBS_User where UserName='" & Replace(UserName,"'","''") & "'",1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		CheckUserNameExist = 0
		GBL_CHK_TempStr = "错误，用户名" & htmlencode(UserName) & "不存在！"
		Exit Function
	Else
		GBL_UserName_UserID = cCur(Rs(0))
		GBL_UserName = Rs(1)
		GBL_UserName_FaceUrl = Rs(2)
		GBL_UserName_UnderWrite = Rs(3)
		GBL_UserName_UserTitle = Rs(4)
	End if
	Rs.Close
	Set Rs = Nothing
		
	CheckUserNameExist = 1

End Function


Function DeleteUploadFace(DelUserID)

	If DEF_FSOString = "" Then
		Response.Write "<p><font color=Red class=redfont>论坛不支持在线删除文件，略过上传头像删除．</font>"
		Exit Function
	End If
	Dim SQL,Rs
	SQL = "Select ID,PhotoDir,SPhotoDir from LeadBBS_UserFace where UserID=" & DelUserID & " order by ID ASC"
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		Response.Write "<p><b><font color=Red class=redfont>用户无上传头像，略过删除!</font></b>"
	Else
		If Rs("PhotoDir") <> "" Then DeleteFiles(Server.Mappath(DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & "face/" & Rs("PhotoDir")))
		If Rs("SPhotoDir") <> "" Then DeleteFiles(Server.Mappath(DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & "face/" & Rs("SPhotoDir")))
		Rs.Close
		Set Rs = Nothing
		CALL LDExeCute("Delete from LeadBBS_UserFace where UserID=" & DelUserID,1)
		Response.Write "<p><b><font color=green class=greenfont>完成用户上传头像的删除!</font></b>"
	End If

End Function

Function DeleteFiles(path)

	'on error resume next
	Dim fs
	Set fs=Server.CreateObject(DEF_FSOString)
	If fs.FileExists(path) then
		fs.DeleteFile path,True
		DeleteFiles = 1
	Else
		DeleteFiles = 0
	End If
    Set fs=nothing
         
End Function
%>