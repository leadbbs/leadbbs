<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="../inc/Board_popfun.asp"-->
<!--#include file="../inc/Limit_fun.asp"-->
<!--#include file="inc/UserTopic.asp"-->
<!--#include file="inc/Fun_SendMessage.asp"-->
<%
Const DEF_User_MaxReceiveUser = 5 '定义允许同时发送短消息给多少个用户，默认值为5
DEF_BBS_HomeUrl = "../"

Dim Sdm_FromUser,Sdm_ToUser,Sdm_Title,Sdm_Content,Sdm_ToUserID
Dim ReplyMessageID,ModifyMessageID
dim old_SDM_ToUser

Dim AjaxFlag

Main()

Sub Main

	If Request("AjaxFlag") = "1" Then
		AjaxFlag = 1
	Else
		AjaxFlag = 0
	End If
	If Request.QueryString("go") = "liling" Then
		Main_SelectFriend()
	Else
		Main_SendMessage()
	End If

End Sub

Sub Main_SendMessage

	initDatabase()
	CheckisBoardMaster()
	GBL_CHK_TempStr = ""

	Sdm_FromUser = GBL_CHK_User

	If GBL_UserID < 0 Then GBL_UserID = 0
	If GBL_UserID = 0 or Sdm_FromUser = "" Then GBL_CHK_TempStr = GBL_CHK_TempStr & "您未登录" & VbCrLf

	ReplyMessageID = Left(Request("ReplyMessageID"),14)
	If isNumeric(ReplyMessageID) = 0 or ReplyMessageID = "" or InStr(ReplyMessageID,",") Then ReplyMessageID = 0
	ReplyMessageID = Fix(cCur(ReplyMessageID))
	If ReplyMessageID < 0 Then ReplyMessageID = 0

	ModifyMessageID = Left(Request("ModifyMessageID"),14)
	If isNumeric(ModifyMessageID) = 0 or ModifyMessageID = "" or InStr(ModifyMessageID,",") Then ModifyMessageID = 0
	ModifyMessageID = Fix(cCur(ModifyMessageID))
	If ModifyMessageID < 0 Then ModifyMessageID = 0

	SdM_ToUser = Request("SdM_ToUser")
	
	Dim submitFlag
	If Request.Form("submitFlag")<>"" Then
		submitFlag = 1
	Else
		submitFlag = 0
	End If

	If AjaxFlag = 0 Then
		BBS_SiteHead DEF_SiteNameString & " - 写短消息",0,"写短消息"
		UpdateOnlineUserAtInfo GBL_board_ID,"发送短消息"
	
		UserTopicTopInfo("user")
	ElseIf submitFlag = 0 Then%>
	<div class="ajaxbox">
	<div id="sndErrString"></div>
	<%
	End If

	If GBL_CHK_Flag = 1 Then
		CheckUserAnnounceLimit()
		If GBL_CHK_OnlineTime < DEF_NeedOnlineTime and DEF_NeedOnlineTime > 0 and CheckSupervisorUserName() = 0 Then
			GBL_CHK_TempStr = "<div class=alert>论坛限制在线时间(" & DEF_PointsName(4) & ")" & Fix(DEF_NeedOnlineTime/60) & "分以上用户才能使用此功能。</div>" & VbCrLf
		End If
		If ModifyMessageID > 0 Then GetMessageValue(ModifyMessageID)
		If GBL_CHK_TempStr = "" Then
			If submitFlag <> 0 Then
				CheckSubmitFormData()
				If GBL_CHK_TempStr = "" Then
					WriteNewMessageToDatabase()
				Else
					SDM_ToUser = old_SDM_ToUser
					Message_Done GBL_CHK_TempStr,"err"
					If AjaxFlag = 0 Then NewMessageForm()
				End If
			Else
				If ReplyMessageID > 0 and ModifyMessageID = 0 Then GetMessageValue(ReplyMessageID)
				NewMessageForm()
			End If
		Else
			Message_Done GBL_CHK_TempStr,"err"
		End If
	Else
		If AjaxFlag = 0 Then
			If Request("submitflag")="" Then
				Response.Write DisplayLoginForm("请先登录")
			Else
				DisplayLoginForm(GBL_CHK_TempStr)
			End If
		Else
			Message_Done "账号验证错误.","err"
		End If
	End If
	closeDataBase()
	If AjaxFlag = 0 Then
		UserTopicBottomInfo()
		SiteBottom()
	ElseIf submitFlag = 0 Then%>
	</div>
	<%
	End If

End Sub

Sub Message_Done(Str,tp)

	If AjaxFlag = 1 and Request.Form("submitFlag")<>"" Then
		If tp = "err" Then%>
		<script>parent.document.getElementById("sndErrString").innerHTML = "<div class=alert><%=Replace(Replace(Replace(Str,"\","\\"),"""","\"""),VbCrLf,"")%></div>";
		parent.submit_disable(parent.document.getElementById("LeadBBSFm"),1)
		</script>
		<%Else%>
	<script>parent.layer_outmsg("anc_delbody","<div class=\"ajaxbox\"><%=Replace(Replace(Replace(Str,"\","\\"),"""","\"""),VbCrLf,"")%></div>","");</script>
	<%
		End If
	Else
		If tp = "err" Then
			Response.Write "<div class=alert>" & Str & "</div>"
		Else
			Response.Write "<div class=alertdone>" & Str & "</div>"
		End If
	End If

End Sub

Function NewMessageForm

	Dim TempN,Pub,SuperFlag
	
	SuperFlag = CheckSupervisorUserName()
	If Request("pub") <> "" Then
		Pub = 1
	Else
		Pub = 0
	End If

	Response.Write "<div class=title>"
	If ModifyMessageID > 0 Then
		Response.Write "编辑"
	Else
		Response.Write "编写新的"
	End If
	If SdM_ToUser = "" and Pub = 1 Then
		Response.Write "公告"
	Else
		Response.Write "短消息"
	End If
	
	Dim Url
	Url = filterUrlstr(Left(Request("dir"),100))
	If Url = "" and Request("ajaxflag") = "" Then
			Url = DEF_BBS_HomeUrl
	elseIf Request("dir") = "" Then
		If inStr(Request.ServerVariables("QUERY_STRING"),"dir=") then
			Url = ""
		Else
			Url = DEF_BBS_HomeUrl
		End If
	End If
	%></div>
	<form method="post" action="<%=Url%>User/SendMessage.asp" id="LeadBBSFm" name="LeadBBSFm"<%
	If AjaxFlag = 1 Then
		Response.Write " target=""hidden_frame"""%> onSubmit="sutmitflag=1;submit_disable(this);return true;"<%
	Else%> onSubmit="return(submitonce(this));"<%
	End If
	%>>
	<input type=hidden name=AjaxFlag value="<%=AjaxFlag%>">
	<table border=0 cellpadding=0 cellspacing=0 width=95% class=table_in>
	
	<tr> 
		<td width=150 class=tdbox>
			发送人</td>
		<td valign=top class=tdbox>
			<%=Sdm_FromUser%>
			<input name=submitFlag value="<%=Second(time)&minute(time)%>" type=hidden>
			<%If SuperFlag = 1 Then%><input name=pub value="<%If Pub = 1 Then Response.Write "1"%>" type=hidden><%End If%>
			<input name=ModifyMessageID value="<%=ModifyMessageID%>" type=hidden>
		</td>
	</tr>
	<%If DEF_EnableAttestNumber > 2 and (DEF_AttestNumberPoints = 0 or GBL_CHK_Points < DEF_AttestNumberPoints) Then%>
	<tr> 
		<td class=tdbox>验证码</td>
		<TD class=tdbox>
			<%Response.Write displayVerifycode()%>
		</td>
	</tr>
				<%End If
	If SuperFlag = 0 or Pub = 0 Then%>
	<tr>
		<td class=tdbox>
			<%If SuperFlag = 0 Then%>*<%End If%>接收人</td>
		<td valign=top class=tdbox><%If ModifyMessageID > 0 Then
				Response.Write htmlencode(SdM_ToUser)
				If SdM_ToUser = "" Then Response.Write "此为公告，无接收人"
			Else%>
			<input class='fminpt input_4' name=SdM_ToUser id=SdM_ToUser value="<%=htmlencode(SdM_ToUser)%>" size=41 maxlength=200> <%
				If AjaxFlag = 0 Then DisplayFriendList
			End If%>
		</td>
	</tr>
	<%End If%>
	<tr>
		<td class=tdbox>*标题</td>
		<td class=tdbox>
			<input class='fminpt input_4' name=SdM_Title id=SdM_Title value="<%=htmlencode(SdM_Title)%>" size=60 maxlength=100>
		</td>
	</tr>
	<tr>
		<td valign=top class=tdbox>内容<%
		If AjaxFlag = 0 Then
		%><div class=value2>支持[IMG]标签插入图片</div><%
		End If%></td>
		<td valign=top class=tdbox>
			<textarea cols=58 name="SdM_Content" id=SdM_Content rows="10"<%
			If AjaxFlag = 0 Then%> onselect="storeCaret(this);" onclick="storeCaret(this);" onkeyup="storeCaret(this);" onkeydown="if(ctlkey(event)==false)return(false);"<%
			End If%> class=fmtxtra><%If SdM_Content<>"" Then Response.Write VbCrLf & Htmlencode(SdM_Content)%></textarea>
		</td>
	</tr>
<%
If AjaxFlag = 0 Then
	If DEF_UBBiconNumber > 0 Then%>
		<tr>
			<td width="<%=DEF_BBS_LeftTDWidth%>" valign=top class=tdbox>
			插入<a href=<%=DEF_BBS_HomeUrl%>User/Help/Ubb.asp?icon target=_blank>表情</a>
			</td>
			<td class=tdbox>
				<table border="0" cellspacing="0" cellpadding="0"><tr><td>
				<div id=editor_icon>
				</div>
				</td></tr></table>
			</td>
		</tr><%
	End If
End If%>
	<tr>
		<td class=tdbox>&nbsp;</td>
		<td class=tdbox>
			<input type="submit" name="Submit" value="提交" class="fmbtn btn_2"> &nbsp;
			<input type="reset" name="reset" value="清除" class="fmbtn btn_2">
		</td>
	</tr>
	</table>
	</form>
<%If AjaxFlag = 0 Then%>
	<script type="text/javascript">
	var ValidationPassed = true,submitflag=0;
	function submitonce(theform)
	{
		submitflag = 1;
		if(theform.ForumNumber)
		{
			if(theform.ForumNumber.value=="")
			{
				alert("请输入验证码!\n");
				ValidationPassed = false;
				theform.ForumNumber.focus();
				submitflag = 0;
				return false;
			}
			else
			{ValidationPassed = true;}
		}

		submit_disable(theform);
		return true;
	}
	function ctlkey(event)
	{
		if(event.ctrlKey && event.keyCode==13){submitonce($id('LeadBBSFm'));if(ValidationPassed)$id('LeadBBSFm').submit();return(false);}
		if(event.altKey && event.keyCode==83){submitonce($id('LeadBBSFm'));if(ValidationPassed)$id('LeadBBSFm').submit();return(false);}
		return(true);
	}
	function edt_icon(s1)
	{
		var str1="[EM"+s1+"]",str2="";
		var str=str1 + str2;
		var obj=$id('SdM_Content');
		obj.focus();

		if(!isUndef(obj.selectionStart)) 
		{
			str = str1 + obj.value.substr(obj.selectionStart,obj.selectionEnd-obj.selectionStart) + str2;
			obj.value = obj.value.substr(0, obj.selectionStart) + str + obj.value.substr(obj.selectionEnd);
		}
		else if ((document.selection)&&(document.selection.type== "Text"))
		{
			var range = document.selection.createRange();
			var ch_text = range.text;
			range.text = str1 + ch_text + str2;
		} 
		else
		{
			if (obj.createTextRange && obj.caretPos)
			{
				var caretPos = obj.caretPos;
				caretPos.text = str1 + caretPos.text + str2;
				obj.focus();
			}
			else{obj.value+=str;obj.focus();}
		}
	}
	function storeCaret (textEl)
	{
		if (textEl.createTextRange) 
		try{textEl.caretPos = document.selection.createRange().duplicate(); }catch(e){}
	}

var edt_escfg = 0;

function edt_disable_esc()
{
	if(event.keyCode==27)return(false);
}
function edt_disablesc()
{
	if(edt_escfg==1)return;
	edt_escfg = 1;

	if (document.all)
            $id('body').attachEvent("onkeydown",edt_disable_esc);    
        else    
            $id('body').addEventListener("onkeydown",edt_disable_esc,false);
}
function Msg_Focus()
{
	if(!Browser.is_ie){$id("SdM_Title").focus();return;}
	var obj=$id("SdM_Title");
	var r = obj.createTextRange();
	r.collapse(false);
	r.select();
	obj.focus();
}
edt_disablesc();
setTimeout("Msg_Focus()",500);
$import("../a/edit/icon.asp?f=msg","js");
window.onbeforeunload = function(){if($id("SdM_Content").value.length>0&&submitflag==0)return("您的短消息未发表，确定取消吗？");}
	</script>
<%
	If CheckSupervisorUserName() = 1 Then%><div class=value2>- 您是管理员，不填写接收人表示发布公告</div><%
	End If
	If DEF_User_MaxReceiveUser >= 2 Then
		%><div class=value2>- 最多允许填写<%=DEF_User_MaxReceiveUser%>名接收人，用逗号分隔</div>
		<div class=value2>- 新发送的短消息最多保存<%=LMT_SendMsgExpiresDate%>天，过时系统将自动清除.</div><%
	End IF
End If

End Function

Function CheckSdM_ToUserString
	
	Do While InStr(SdM_ToUser,",,")
		SdM_ToUser = Replace(SdM_ToUser,",,",",")
	Loop
	If Left(SdM_ToUser,1) = "," Then SdM_ToUser = Mid(SdM_ToUser,2)
	If Right(SdM_ToUser,1) = "," Then SdM_ToUser = Left(SdM_ToUser,Len(SdM_ToUser) - 1)
	TmpArr = Split(SdM_ToUser,",")
	
	If Len(SdM_ToUser) - Len(Replace(SdM_ToUser,",","")) > DEF_User_MaxReceiveUser - 1 Then
		GBL_CHK_TempStr = "错误，接收人最多只能填写" & DEF_User_MaxReceiveUser & "人！"
		CheckSdM_ToUserString = 0
		Exit Function
	Else
		Dim N,M,TmpArr
		TmpArr = Split(SdM_ToUser,",")
		For N = 0 to Ubound(TmpArr,1)
			For M = N + 1 to Ubound(TmpArr,1)
				If LCase(TmpArr(N)) = LCase(TmpArr(M)) Then
					GBL_CHK_TempStr = "错误，接收人不允许重复填写(重复用户名：" & TmpArr(N) & ")"
					CheckSdM_ToUserString = 0
					Exit Function
				End If
			Next
		Next
	End If
	CheckSdM_ToUserString = 1

End Function

Function CheckSubmitFormData

	If ModifyMessageID = 0 Then SdM_ToUser = Trim(Request.Form("SdM_ToUser"))
	SdM_Title = Trim(Request.Form("SdM_Title"))
	SdM_ConTent = Request.Form("SdM_ConTent")
	
	If DEF_EnableAttestNumber > 2 and (DEF_AttestNumberPoints = 0 or GBL_CHK_Points < DEF_AttestNumberPoints) Then
		If CheckRndNumber() = 0 Then
			GBL_CHK_TempStr = "验证码填写错误!"
			GBL_CHK_Flag = 0
			Exit Function
		End If
	End If

	old_SDM_ToUser = SDM_ToUser

	If SdM_ToUser <> "" Then
		If ModifyMessageID = 0 Then
			If CheckSdM_ToUserString() = 0 Then Exit Function
			If CheckUserNameExist() = 0 Then
				Exit Function
			ElseIf CheckMessageOver(SdM_ToUser) = 1 Then
				Exit Function
			End If
		End If
	Else
		If CheckSupervisorUserName() = 0 Then
			GBL_CHK_TempStr = "错误，必须填写接收人!" & VbCrLf
			Exit Function
		Else
			If SdM_Title = "" Then
				GBL_CHK_TempStr = "你是管理员, 现在发布的是公告信息, 请填写信息标题!" & VbCrLf
				Exit Function
			End If
			If inStr(Lcase(SdM_Title),"<script") or inStr(Lcase(SdM_Title),"</script") Then
				GBL_CHK_TempStr = "你是管理员, 发布的公告标题不能使用JS代码!" & VbCrLf
				Exit Function
			End If
		End If
	End If

	If StrLength(SdM_Title) > 100 Then
		GBL_CHK_TempStr = "错误，信息标题请不要超过100个字符. " & VbCrLf
		Exit Function
	End if

	If SdM_Title = "" Then
		GBL_CHK_TempStr = "错误，信息标题必须填写. " & VbCrLf
		Exit Function
	End if

	If CheckSupervisorUserName() = 1 Then
		If Len(SdM_Content) > DEF_MaxTextLength * 2 then
			GBL_CHK_TempStr = "错误，内容不能超过" & DEF_MaxTextLength * 2 & "个字!" & VbCrLf
			Exit Function
		End If
	Else
		If Len(SdM_Content) > DEF_MaxTextLength / 2 then
			GBL_CHK_TempStr = "错误，内容不能超过" & DEF_MaxTextLength / 2 & "个字!" & VbCrLf
			Exit Function
		End If
	End If

	If ModifyMessageID = 0 Then 
		Dim Temp
		Temp = CheckIsRestSpaceTime(SdM_Title,Left(SdM_Content & "",100))
		Select Case Temp
		Case 1: If CheckSupervisorUserName() = 0 Then
				GBL_CHK_TempStr = "不能连续发太多的消息，请休息" & DEF_RestSpaceTime & "秒钟后再发短消息!"
				GBL_CHK_Flag = 0
				Exit Function
			End If
		Case 2: GBL_CHK_TempStr = "请不要发重复的消息!"
			GBL_CHK_Flag = 0
			Exit Function
		Case 3: Exit Function
		End Select
	Else
		If CheckWriteEventSpace() = 0 Then
			GBL_CHK_TempStr = "您在修改资料的过程中提交得太频，请稍候再作提交! " & VbCrLf
			GBL_CHK_Flag = 0
			Exit Function
		End If
	End If

End Function

Sub ModifyMessage(ToUser,Title,Content,ModifyID)

	Dim SQL
	Content = Replace(Content & "","\" & VbCrLf,"\\" & VbCrLf & VbCrLf)
	SQL = "Update LeadBBS_InfoBox set Title='" & Replace(Title,"'","''") & "',Content='" & Replace(Content,"'","''") & "' where ID=" & ModifyID
	CALL LDExeCute(SQL,1)

	If ToUser = "" Then ReloadPubMessageInfo

	GBL_CHK_TempStr = "<p align=left>&nbsp; &nbsp; <font color=008800 class=greenfont>成功编辑短消息"

	If CheckSupervisorUserName() = 0 Then
		CALL LDExeCute("Update LeadBBS_User Set LastWriteTime=" & GetTimeValue(DEF_Now) & " where ID=" & GBL_UserID,1)
		UpdateSessionValue 13,GetTimeValue(DEF_Now),0
	End If

End Sub

Function WriteNewMessageToDatabase

	If ModifyMessageID = 0 Then
		SendNewMessage SdM_fromUser,SdM_ToUser,SdM_Title,SdM_Content,GBL_IPAddress
	Else
		ModifyMessage SdM_ToUser,SdM_Title,SdM_Content,ModifyMessageID
	End If
	If GBL_CHK_TempStr <> "" Then Message_Done "<div class=value2>" & GBL_CHK_TempStr & "</div>",""

End Function

Function CheckMessageOver(username)

	Dim Rs,tmp

	Dim N,TmpArr
	TmpArr = Split(SdM_ToUser,",")

	For N = 0 to Ubound(TmpArr,1)
		Set Rs = LDExeCute("Select count(*) from LeadBBS_InfoBox where ToUser='" & Replace(TmpArr(N),"'","''") & "'",0)
		If Rs.Eof Then
			CheckMessageOver = 0
		Else
			tmp = Rs(0)
			If isNull(tmp) Then tmp = 0
			tmp = cCur(tmp)
			If tmp > LMT_MaxMessageNumber Then
				GBL_CHK_TempStr = "错误，接收人“<b>" & htmlencode(TmpArr(N)) & "</b>”收件箱己满，发送失败!<br>" & VbCrLf
				CheckMessageOver = 1
				Exit Function
			End If
		End if
		Rs.Close
		Set Rs = Nothing
	Next
	CheckMessageOver = 0

End Function

Function GetTrueName_UserName(username,truename,toid,fullname)

	Dim UserLimit
	Dim Rs,ToUserID,Uname
	
	if username <> "" then
		Set Rs = LDExeCute(sql_select("Select ID,UserName,UserLimit from LeadBBS_User where UserName='" & Replace(Left(username,20),"'","''") & "'",1),0)
	else
		Set Rs = LDExeCute(sql_select("Select ID,UserName,UserLimit from LeadBBS_User where truename='" & Replace(Left(truename,20),"'","''") & "' and id=" & ccur(toid),1),0)
	end if
	
	If Rs.Eof Then
		GetTrueName_UserName = array(0,"","")
		GBL_CHK_TempStr = "错误，找不到接收人“<b>" & htmlencode(fullname) & "</b>”，请确认是否存在此人!<br>" & VbCrLf
	Else
		ToUserID = Rs(0)
		Uname = rs(1)
		UserLimit = Rs(2)
		GetTrueName_UserName = array(ToUserID,Uname,UserLimit)
	End if
	Rs.Close
	Set Rs = Nothing
	If GetBinaryBit(UserLimit,13) = 1 and GBL_BoardMasterFlag < 4 Then '版主或以上权限者不受此限制
		Set Rs = LDExeCute(sql_select("Select ID from LeadBBS_FriendUser where FriendUserID=" & GBL_UserID & " and UserID=" & ToUserID,1),0)
		If Rs.Eof Then
			GetTrueName_UserName = array(0,"","")
			GBL_CHK_TempStr = htmlencode(fullname) & " 已经设置成仅允许接收好友的短消息，请勿打扰。<br>" & VbCrLf
		End If
		Rs.Close
		Set Rs = Nothing
	End If

End Function

Rem 检测某用户名ID是否存在
Function CheckUserNameExist

	Dim UserLimit,UName
	Dim Rs
	Dim N,TmpArr
	TmpArr = Split(SDM_ToUser,",")
	
	dim touser,totruename,toid,checked,ret,su
	For N = 0 to Ubound(TmpArr,1)
		touser = TmpArr(N)
		checked = 0
		UName = ""
		if inStr(touser,"#") > 0 then
			if lcase(left(touser,3)) <> "qq#" and lcase(left(touser,3)) <> "ld#" then
				su = split(touser,"#")
				totruename = su(0)
				toid = toNum(su(1),0)
				ret = GetTrueName_UserName("",totruename,toid,touser)
				Sdm_ToUserID = ret(0)
				UName = ret(1)
				UserLimit = ret(2)
				checked = 1
			end if
		else
		end if
		
		if checked = 0 then
			ret = GetTrueName_UserName(touser,"",0,touser)
			Sdm_ToUserID = ret(0)
			UName = ret(1)
			UserLimit = ret(2)
		end if
		If UName = "" Then
			CheckUserNameExist = 0
			Sdm_ToUserID = 0
			Exit Function
		Else
			Sdm_ToUserID = Sdm_ToUserID
			TmpArr(N) = UName
			UserLimit = UserLimit
		End if
	Next
	SdM_ToUser = ""
	SdM_ToUser = TmpArr(0)
	For N = 1 to Ubound(TmpArr,1)
		SdM_ToUser = SdM_ToUser + "," + TmpArr(N)
	Next
	CheckUserNameExist = 1

End Function

Function GetMessageValue(MessageID)

	Dim Rs,SQL
	SQL = sql_select("Select FromUser,SendTime,Title,Content,ToUser,ReadFlag from LeadBBS_InfoBox where ID=" & MessageID,1)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		GBL_CHK_TempStr = "错误，无法查看此消息的相关资料．"
	Else
		If SdM_FromUser <> Rs(0) and SdM_FromUser <> Rs(4) and Rs(4) <> "" Then
			GBL_CHK_TempStr = "错误，无法查看此消息的相关资料．"
			Rs.Close
			Set Rs = Nothing
			Exit Function
		End If
		If Rs(4) = "" and CheckSupervisorUserName() = 0 Then
			GBL_CHK_TempStr = "错误，无法查看此消息的相关资料．"
			Rs.Close
			Set Rs = Nothing
			Exit Function
		End If
		SdM_Title = Rs(2)
		If ModifyMessageID > 0 Then
			If GBL_CHK_User <> Rs(0) and (CheckSupervisorUserName() = 0 and Rs(4) = "") Then
				GBL_CHK_TempStr = "错误，无法查看此消息的相关资料．"
				Rs.Close
				Set Rs = Nothing
				Exit Function
			End If
			If (ccur(Rs(5)) = 1) Then
				GBL_CHK_TempStr = "此条短消息己阅，无法再编辑．"
				Rs.Close
				Set Rs = Nothing
				Exit Function
			End If
			SdM_Content = Rs(3)
			SdM_ToUser = Rs(4)
			SdM_FromUser = Rs(0)
		Else
			'SdM_Content = Replace(Rs(3) & "",VbCrLf,VbCrLf & ">")
			'If SdM_Content<>"" Then SdM_Content = ">" & SdM_Content
			'SdM_Content = VbCrLf & VbCrLf & VbCrLf & "-----------------------------------------" & VbCrLf & ">[回复" & htmlencode(Rs(0)) & " " & Mid(RestoreTime(Rs(1)),6,11) & "发送的短消息]" & VbCrLf & ">标题：" & SdM_Title & VbCrLf & VbCrLf & SdM_Content & VbCrLf
			SdM_Content = Rs(3)
			SQL = inStr(SdM_Content,"[/quote]")
			If inStr(SdM_Content,"[quote]") > 0 and SQL > 0 Then SdM_Content =  Mid(SdM_Content,SQL + 8)
			If Replace(Trim(SdM_Content),VbCrLf,"") <> "" Then SdM_Content = "[b]原内容[/b][hr]" & VbCrLf & SdM_Content & VbCrLf
			SdM_Content = "[quote][u]" & GBL_CHK_User & "[/u] 回复 [u]" & htmlencode(Rs(0)) & "[/u] 在 " & Left(RestoreTime(Rs(1)),16) & " 发送的短消息" & VbCrLf & VbCrLf & "[b]原标题：[/b][url=LookMessage.asp?MessageID=" & ReplyMessageID & "]" & SdM_Title & "[/url]" & VbCrLf & VbCrLf & SdM_Content & "[/quote]" & VbCrLf
			If Left(SdM_Title,3) <> "Re:" Then SdM_Title = Left("Re:" & SdM_Title,250)
		End If
	End If
	Rs.Close
	Set Rs = Nothing

End Function

Function CheckIsRestSpaceTime(Form_Title,Form_Content)

	If CheckWriteEventSpace() = 0 Then
		CheckIsRestSpaceTime = 3
		Exit Function
	End If
	Dim Rs,ndatetime,Temp_ID,Temp_Title,Temp_Content
	Set Rs = LDExeCute(sql_select("Select SendTime,ID,title,Content from LeadBBS_InfoBox where FromUser='" & Replace(Sdm_FromUser,"'","''") & "' Order by ID DESC",1),0)
	If Rs.Eof Then
		CheckIsRestSpaceTime = 0
		Rs.Close
		Set Rs = Nothing
		Exit Function
	Else
		ndatetime = Rs(0)
		Temp_ID = Rs(1)
		Temp_Title = Rs(2)
		Temp_Content = Left(Rs(3) & "",100)
		Rs.Close
		Set Rs = Nothing
	End if
	
	If DateDiff("s", RestoreTime(ndatetime), DEF_Now) < 0 Then
		CheckIsRestSpaceTime = 0
		Exit Function
	End If
	If DateDiff("s", RestoreTime(ndatetime), DEF_Now) < DEF_RestSpaceTime Then
		CheckIsRestSpaceTime = 1
		CALL LDExeCute("Update LeadBBS_InfoBox set SendTime=" & GetTimeValue(DEF_Now) & " where id=" & Temp_ID,1)
	Else
		If Temp_Title = Form_Title and Temp_Content = Form_Content Then
			CheckIsRestSpaceTime = 2
		Else
			CheckIsRestSpaceTime = 0
		End If
	End If

End Function

Sub DisplayFriendList

	%>
	<script type="text/javascript">
	function sendmsg_selfriend(val,obj)
	{
		var num = <%=DEF_User_MaxReceiveUser%>;
		if(val=='')
		{
			layer_view('选择接收人',$id('user_selfriend'),'','','anc_msgbody','SendMessage.asp?go=liling','',0,'AjaxFlag=1',0,0);
		}
		else
		{
			if(num <2 )
			$id('SdM_ToUser').value=val;
			else
			{
				if($id('SdM_ToUser').value=='')
				{
					$id('SdM_ToUser').value=val;
					layer_view('成功添加。',obj,'','','user_selfriend_alert','','',0,'',0,-55);
				}
				else
				{
					if((","+$id('SdM_ToUser').value+",").indexOf(","+val+",")!=-1)
					{
						layer_view('操作重复：此用户已被添加。',obj,'','','user_selfriend_alert','','',0,'',0,-55);
						return(false);
					}
					if(($id('SdM_ToUser').value.length-$replace($id('SdM_ToUser').value,",","").length) < num-1)
					{
					$id('SdM_ToUser').value += ',' + val;
					layer_view('成功添加。',obj,'','','user_selfriend_alert','','',0,'',0,-55);
					}
					else
					layer_view('添加失败：接收人最多允许填写' + num + '人。',obj,'','','user_selfriend_alert','','',0,'',0,-55);
				}
			}
		}
		return(false);
	}
	
	</script>
	<a href="javascript:;" onclick="sendmsg_selfriend('',this);" class="layerico" id="user_selfriend">选择好友</a>
	<%

End Sub


Rem -------新弹出窗口部分代码-----

Sub Main_SelectFriend

	initDatabase()
	Response.Write "<div class=ajaxbox>"
	If GBL_UserID = 0 Then
		GBL_CHK_TempStr = ""
		If GBL_UserID = 0 Then GBL_CHK_TempStr = "找不到用户，要查看资料请先登录。<br>" & VbCrLf
	Else
		GBL_CHK_TempStr = ""
	End If

	if GBL_CHK_TempStr <> "" Then
		Response.Write "<div class=alert>" & GBL_CHK_TempStr & "</div><hr class=splitline>"
	Else
		GBL_CHK_TempStr = ""
		DisplayCenter()
	End If
	closeDataBase()
	Response.Write "</div>"

End Sub

Sub DisplayCenter

	Dim Rs,SQL
	Set rs = Server.CreateObject("ADODB.Recordset")

	SQL = sql_select("Select ID,UserName from LeadBBS_User where ID=" & GBL_UserID,1)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Response.Write "<div class=alert>错误：用户验证错误！</div>"
		Rs.Close
		Set Rs = Nothing
		Exit Sub
	End if
	Rs.close
	Set Rs = Nothing
	
	SQL = sql_select("select T2.UserName,T2.TrueName,T2.ID from LeadBBS_FriendUser as T1 left join LeadBBS_User as T2 on T1.FriendUserID=T2.ID where T1.UserID=" & GBL_UserID & " Order by T1.ID ASC",1000)
	Set Rs = LDExeCute(SQL,0)
	dim GD,num
	If Not rs.Eof Then
		GD = rs.getrows(-1)
		num = ubound(GD,2)
	else
		num = -1
	end if
	Rs.close
	Set Rs = Nothing
	dim n
	if num >= 0 then
		Response.Write "<div class=u_friendlist><div class=title>请点击名字选择好友</div><ul>"
		for n = 0 to num
			if GD(0,n) & "" <> "" then
				Response.write "<li><a href=#1 class=layer_alertclick onclick="&chr(34)&"sendmsg_selfriend('"
				response.write htmlencode(GetTrueNameID(GD(0,N),GD(1,N),GD(2,N))) & "');"
				Response.Write chr(34) & ">" & htmlencode(GetTrueName(GD(0,N),GD(1,N))) & "</a></li>"
			end if
		next
		Response.Write "</ul></div>"
	end if

End Sub%>