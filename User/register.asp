<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="../inc/User_Setup.asp"-->
<!--#include file="../inc/Board_popfun.asp"-->
<!--#include file="../inc/ubbcode.asp"-->
<!--#include file="../inc/Limit_fun.asp"-->
<!--#include file="inc/User_fun.asp"-->
<!--#include file="inc/UserTopic.asp"-->
<!--#include file="inc/Mail_fun.asp"-->
<!--#include file="../inc/Constellation2.asp"-->
<!--#include file="inc/Fun_SendMessage.asp"-->
<%
Const LMT_RegVerifyQuestion = "" '注册验证提示信息，可以是HTML格式，比如使用图片，若不填写表示不开启注册验证信息。
Const LMT_RegVerifyAnswer = "" '注册验证需要填写的答案。
Const LMT_EnableInvitedRegCode = 1 '是否允许邀请码注册 在禁止注册的情况下，开启这个表示 仍然可以用邀请码注册
Const enable_showRegCode = 0 '是否允许显示已经生成的邀请码给注册人 1。允许  0不允许 
DEF_BBS_HomeUrl = "../"

dim def_sim_flag : def_sim_flag = ""
dim def_sim_flag_str : def_sim_flag_str = "?sim="

dim invitedRegCode : invitedRegCode = 0

Form_FaceWidth = DEF_AllFaceMaxWidth
Form_FaceHeight = DEF_AllFaceMaxWidth
GBL_CHK_PWdFlag = 0
CursorLocation = 3
initDatabase()

If Request.Form("checkflag") = "1" Then
	Reg_CheckInfo()
	CloseDatabase()
	Response.End
End If

GBL_CHK_TempStr = ""

Dim AttestNumber,Form_Action
AttestNumber = 0
Dim Form_ID,ShowTestNumber

If Def_UserTestNumber = 2 Then
	ShowTestNumber = 0
ElseIf Def_UserTestNumber = 1 Then
	If DEF_EnableAttestNumber = 1 Then
		ShowTestNumber = 3
	Else
		ShowTestNumber = 4
	End If
Else
	ShowTestNumber = DEF_EnableAttestNumber
End If

Dim reg_action,reg_command
reg_action = Left(Request("action"),30)
reg_command = Left(Request("command"),30)

'互联关闭状态不允许绑定或完善资料
If GetBinarybit(DEF_Sideparameter,10) = 0 Then
	reg_action = ""
	reg_command = ""
End If

dim ajaxflag
if Left(Request("ajaxflag"),30) = "1" then
	ajaxflag = 1
else
	ajaxflag = 0
end if

def_sim_flag = request.querystring("sim")
dim isSimFlagStr : isSimFlagStr = ""
if def_sim_flag <> "1" then
		def_sim_flag_str = "?sim=0"
else
		def_sim_flag_str = "?sim=1"
		isSimFlagStr = "       "
end if

If reg_action <> "bind" Then
	if ajaxflag = 0 then BBS_SiteHead isSimFlagStr & DEF_SiteNameString & " - 注册新用户",0,"注册新用户"
	UpdateOnlineUserAtInfo GBL_board_ID,"注册新用户"
Else	
	if ajaxflag = 0 then BBS_SiteHead isSimFlagStr & DEF_SiteNameString & " - 完善/绑定帐号",0,"完善/绑定帐号"
	UpdateOnlineUserAtInfo GBL_board_ID,"完善/绑定帐号"
End If
if ajaxflag = 0 then UserTopicTopInfo("")

checkinvitedRegCode()

If reg_action <> "bind" or (reg_action = "bind" and reg_command = "reg") Then
	If Request("JoinFlag") <> "" Then
		If LMT_EnableRegNewUsers = 1 or LMT_EnableInvitedRegCode = 1 Then
			If Request.Form("SubmitFlag")="29d98Sasphouseasp8asphnet" Then
				GBL_CHK_TempStr = ""
				ApplyFlag = 1
				checkFormData()
				
				'邀请码验证
				If LMT_EnableRegNewUsers = 0 and LMT_EnableInvitedRegCode = 1 Then '表示只允许邀请码注册
					if invitedRegCode <= 0 then '邀请码是否有效
							GBL_CHK_TempStr = GBL_CHK_TempStr & "邀请码未填写或无效或已经过期<br>"
							GBL_CHK_Flag = 0
					end if
				end if
				
				If GBL_CHK_Flag = 0 Then
					Response.WRite "<div class=alert>" & GBL_CHK_TempStr & "</div>" & VbCrLf
					JoinForm()
				Else
					If saveFormData() = 1 Then
						displayAccessFull()
					Else
						Response.Write "<div class=alert>" & GBL_CHK_TempStr & "</div>" & VbCrLf
						JoinForm()
					End If
				End If
				If Form_UpFlag = 1 Then Set Form_UpClass = Nothing
			Else
				JoinForm()
			End If
		Else
			Response.Write "<div class=alert>停止新用户注册中，请联系QQ1834644216．</div>"
		End If
	Else
		DisplayUserAgreement()
	End If
Else
	Reg_Bind()
End If
if ajaxflag = 0 then UserTopicBottomInfo
closeDataBase()
if ajaxflag = 0 then SiteBottom
	
sub checkinvitedRegCode

	dim rs,sql
	invitedRegCode = request("invitedRegCode")
	if len(invitedRegCode) = 14 and isNumeric(invitedRegCode) then
		invitedRegCode = toNum(invitedRegCode,0)
		Set Rs = Con.ExeCute(sql_select("Select ID,CardID,CardType,ExpiresDate,CardPoints From LeadBBS_Plug_Card where CardID="&invitedRegCode,1),0)
		
		if rs.eof then
			invitedRegCode = 0
		else
			dim ExpiresDate
			ExpiresDate = toNum(rs("ExpiresDate"),0)
			if(ExpiresDate < toNum(left(cstr(getTimeValue(DEF_Now)),8),0)) then invitedRegCode = 0
		end if
		rs.close
		set rs = nothing
	else
		invitedRegCode = 0
	end if

end sub

Sub Reg_CheckInfo
	
	Dim checkitem,checkvalue
	checkitem = Left(Request("checkitem"),30)
	checkvalue = Left(Request("checkvalue"),30)
	Select Case checkitem
		Case "username":
			if check_usernameFilter(checkvalue,"用户名") = 0 then
				Response.Write "<span class=redfont>" & GBL_CHK_Tempstr & "</span>"
			else
				If CheckUserNameExist(checkvalue) = 1 Then
					Response.Write "<span class=redfont>用户名已被他人注册</span>"
				Else
					Response.Write "<span class=greenfont>恭喜，此用户未被注册</span>"
				End If
			end if
		Case "email":
			if DEF_UserNewRegAttestMode <> 4 then
				If IsValidEmail(checkvalue) = false Then
					Response.Write "<span class=redfont>无效的邮箱地址。</span>"
				Else
					If CheckMailExist(checkvalue) = 1 Then
						Response.Write "<span class=redfont>此邮箱已被其它用户使用</span>"
					Else
						Response.Write "<span class=greenfont>验证通过</span>"
					End If
				End If
			else
				If IsValidEmail(checkvalue) = false and CheckMobilePhone(checkvalue) = false Then
					Response.Write "<span class=redfont>无效的手机号码或邮箱地址。</span>"
				Else
					dim ttt
					if inStr(checkvalue,"@") > 0 then
						ttt = CheckMailExist(checkvalue)
					else
						ttt = checkMobileTelExist(toNum(checkvalue,0))
					end if
					If ttt = 1 Then
						Response.Write "<span class=redfont>此邮箱或手机号码已被注册．</span>"
					Else
						Response.Write "<span class=greenfont>验证通过</span>"
					End If
				End If
			end if
	End Select

End Sub

Sub DisplayUserAgreement

	%><p><form action=<%=DEF_RegisterFile%>?ajaxflag=<%=ajaxflag%> method=post>
	<input name="JoinFlag" type="hidden" value="dkls">
	<input name="action" type="hidden" value="<%=htmlencode(reg_action)%>">
	<input name="command" type="hidden" value="<%=htmlencode(reg_command)%>">
	<input type="hidden" value="<%
	If Request("u") <> "" Then
		Response.Write htmlencode(Request("u"))
	Else
		Response.Write reg_getrefer()
	End If
	%>" name=u>
<!--#include file="inc/User_Reg.asp"-->
<input type="submit" value="我同意" class="fmbtn btn_3">
<input type="button" value="不同意" class="fmbtn btn_3" onclick="location.href='../Boards.asp';"></form>
<br /><br />
<div class=splitline></div>
<div class=title>如果您拥有帐号：</div>
<div class=value2><a href="login.asp">用论坛帐号登录</a> <span class=grayfont style="margin:0 6px;">或</span> <%

	dim qc,Temp
	SET qc = New QqConnet
	set qc = nothing
	If GetBinarybit(DEF_Sideparameter,10) = 1 Then
		for Temp = 0 to ubound(connect_list)
			if connect_allow(Temp) = 1 then%>
<span class=grayfont></span><a href="<%=DEF_BBS_HomeUrl%>app/qqlogin/login.asp?apptype=<%=connect_apptype(Temp)%>"><img style="margin-right:6px;" src="<%=DEF_BBS_HomeUrl%>images/app/<%=Temp+1%>.png" border="0" class="absmiddle" title="使用<%=connect_list(Temp)%>登录"/></span></a><%
			end if
		next
	end if
%></div>
	<%

End Sub

Function JoinForm

	if Request.Form("SubmitFlag")="29d98Sasphouseasp8asphnet" and ajaxflag = 1 then exit function
	%>

	<div class="alert" id="return"></div>
	<script type="text/javascript">
	<!--
	var user_DEF_BBS_HomeUrl = "<%=DEF_BBS_HomeUrl%>";
	var user_DEF_faceMaxNum = <%=DEF_faceMaxNum%>;
	var user_DEF_AllDefineFace = <%=DEF_AllDefineFace%>;
	var user_ShowTestNumber = <%=ShowTestNumber%>;
	var user_DEF_RegisterFile = "<%=replace(replace(DEF_RegisterFile,"\","\\"),"""","\""")%>";
	var user_DEF_AllFaceMaxWidth = <%=DEF_AllFaceMaxWidth%>;
	var user_DEF_ShortestUserName = <%=DEF_ShortestUserName%>;
	-->
	</script>
	<script src="inc/register.js" type="text/javascript"></script>

<form action=<%=DEF_RegisterFile%> method=post name=LeadBBSFm id="LeadBBSFm">
	<input type=hidden value="<%Response.Write htmlencode(Request("u"))%>" name=u>
	<input name="action" type="hidden" value="<%=htmlencode(reg_action)%>">
	<input name="command" type="hidden" value="<%=htmlencode(reg_command)%>">
	<div class=title><%If reg_action <> "bind" then %>用户注册<%
			Else%>完善资料<%
			End If%></div>
	<br>
	
	<%
	select case DEF_UserNewRegAttestMode
		case 1:
			%>
			<span class=bluefont>注意：新注册的用户需要至邮箱获取认证码激活，请仔<br>细填写您的有效邮箱地址！</span>
			<table border=0  cellpadding="0" cellspacing="0" class="blanktable">
			<tr>
				<td>
					电子邮件： 
				</td>
				<td>
					<input class='fminpt input_3' maxlength=60 name=Form_mail size=36 onchange="reg_checkinfo('email',this.value);" value="<% If Form_mail<>"" Then Response.Write Server.HtmlEncode(Form_mail)%>">
					<span id="reg_check_email"></span>
				</td>
			</tr>
			<%
		case 3:
			%>
			<span class=bluefont>请填写手机号码，注册成功后将向您的手机发送激活码．</span>
			<table border=0  cellpadding="0" cellspacing="0" class="blanktable">
			<tr>
				<td>
					手机：
				</td>
				<td>
					<input class=fminpt maxlength=15 name=Form_MobileTel size=14 value="<% If Form_MobileTel<>"" Then Response.Write Server.HtmlEncode(Form_MobileTel)%>">
				</td>
			</tr>
			<%
		case 4:
			%>
			<span class=bluefont>请填写正确的手机号码或邮箱地址，注册成功后将向您的手机或邮箱发送激活码．</span>
			<table border=0  cellpadding="0" cellspacing="0" class="blanktable">
			<!--
			<tr>
				<td>
					手机：
				</td>
				<td>
					<input class=fminpt maxlength=15 name=Form_MobileTel size=14 value="<% If Form_MobileTel<>"" Then Response.Write Server.HtmlEncode(Form_MobileTel)%>">
				</td>
			</tr>
			-->
			<tr>
				<td>
					手机或邮箱： 
				</td>
				<td>
					<input class='fminpt input_3' maxlength=60 name=Form_mail size=36 onchange="reg_checkinfo('email',this.value);" value="<% If Form_mail<>"" Then Response.Write Server.HtmlEncode(Form_mail)%>">
					<span id="reg_check_email"></span>
				</td>
			</tr>
			<%
		case else
			%>
			
			
			<table border=0  cellpadding="0" cellspacing="0" class="blanktable">
			<%
	end select
	%>
			<tr>
				<td>
					用 户 名： 
				</td>
				<td>
					<input class='fminpt input_3' maxlength=14 name="Form_username" size="14" onchange="reg_checkinfo('username',this.value);" value="<% If Form_username<>"" Then Response.Write Server.HtmlEncode(Form_Username)%>">
					<span id="reg_check_username"></span>
				</td>
			</tr>
	
			<tr>
				<td>
					登录密码： 
				</td>
				<td>
					<input class=fminpt name=SubmitFlag type=hidden value="29d98Sasphouseasp8asphnet">
					<input class=fminpt name=JoinFlag type=hidden value="3kkdk">
					<input class='fminpt input_3' maxlength=20 name="Form_password1" size=14 type=password value="<% If Form_password1<>"" Then Response.Write Server.HtmlEncode(Form_password1)%>">
				</td>
			</tr>
			<tr>
				<td>
					确认密码： 
				</td>
				<td>
					<input class='fminpt input_3' maxlength=20 name="Form_password2" size=14 type=password value="<% If Form_password2<>"" Then Response.Write Server.HtmlEncode(Form_password2)%>">
				</td>
			</tr>
			<%If LMT_EnableRegNewUsers = 0 and LMT_EnableInvitedRegCode = 1 Then '表示只允许邀请码注册
				dim tmpinvitedRegCode
				tmpinvitedRegCode = request("invitedRegCode")
				%><tr>
				<td>
				<b><span class="greenfont">邀请码： </span></b>
				</td>
				<td>
					<input class='fminpt input_3' maxlength=14 name="invitedRegCode" size="14" value="<% If tmpinvitedRegCode<>"" Then Response.Write htmlencode(tmpinvitedRegCode)%>">
					<span class="greenfont">需要邀请码才能完成注册</span>
				</td>
			</tr>
			
				<%if enable_showRegCode = 1 then%>
				<tr><td></td><td>
					<%
					dim rs,sql,regcode
					sql = sql_select("select * from leadbbs_plug_card where cardtype=5",1)
					set rs = ldexecute(sql,0)
					if not rs.eof then
						regcode = rs("cardid")
						response.write "请填写邀请码：  <u>"&regcode&"</u>"
					end if
					rs.close
					set rs = nothing
					%>
					</td></tr>
				<%end if%>
			<%end if%>
			
			</table>
			<%if ajaxflag = 0 then%>
			<table border=0  cellpadding="0" cellspacing="0" class="blanktable">
			<tr>
			<td>
				<label><input class="fmchkbox" type="checkbox" name="moreinfo" value="1" onclick="if(this.checked){$id('reg_more_info').style.display='block';}else{$id('reg_more_info').style.display='none';}" />填写更多资料
				</label>
			</td></tr></table>
			<table border=0  cellpadding="0" cellspacing="0" class="blanktable" id="reg_more_info" style="display:none">
			
	<%
	if DEF_UserNewRegAttestMode = 1 or DEF_UserNewRegAttestMode = 3 or DEF_UserNewRegAttestMode = 4 then
	
	%>
			<!--
			<tr>
				<td>
					用 户 名： 
				</td>
				<td>
					<input class='fminpt input_3' maxlength=14 name="Form_username" size="14" onchange="reg_checkinfo('username',this.value);" value="<% If Form_username<>"" Then Response.Write Server.HtmlEncode(Form_Username)%>">
					<span id="reg_check_username"></span>
				</td>
			</tr>
			//-->
	<%end if%>
			
			
			<tr>
				<td>
					问题提示： 
				</td>
				<td>
	<script type="text/javascript">
	function sel_question(list)
	{
		alert('a');
		//if(list.value!='0'&&list.value!='99')$id('Form_Question').value=list.value;if(this.value=='99')$id('Form_Question').type='text';
	}
	</script>
					<select name="sel_question" onchange="if(this.value!=''&&this.value!='99')$id('Form_Question').value=this.value;if(this.value=='99'){this.style.display='none';$id('Form_Question').style.display='block';}else{$id('Form_Question').style.display='none';}">
						<option value="" selected>--选择问题--</option>
						<option value="我的家乡是？">我的家乡是？</option>
						<option value="我妈妈的名字？">我妈妈的名字？</option>
						<option value="最喜欢吃的食品？">最喜欢吃的食品？</option>
						<option value="99">自定义...</option>
					</select>
					<div class=value2><input class='fminpt input_3' type="text" style="display:none;float:right;" maxlength=20 id=Form_Question name=Form_Question size=36 value="<% If Form_Question<>"" Then Response.Write Server.HtmlEncode(Form_Question)%>">
					<div>
				</td>
			</tr>
			<tr>
				<td>
					问题答案：
				</td>
				<td>
					<input class='fminpt input_3' maxlength=20 name=Form_Answer size=36 value="<% If Form_Answer<>"" Then Response.Write Server.HtmlEncode(Form_Answer)%>">
					忘记密码可凭此信息找回
				</td>
			</tr>
			
			<tr>
				<td>
					个人主页：
				</td>
				<td>
					<input class=fminpt maxlength=250 name=Form_homepage size=36 value="<% If Form_homepage<>"" Then Response.Write Server.HtmlEncode(Form_homepage)%>">
				</td>
			</tr>
			<tr>
				<td>
					联系地址：
				</td>
				<td>
					<input class=fminpt maxlength=150 name=Form_address size=36 value="<% If Form_address<>"" Then Response.Write Server.HtmlEncode(Form_address)%>">
				</td>
			</tr><!--
			<tr>
				<td>
					ICQ号码：
				</td>
				<td>
					<input class=fminpt maxlength=12 name=Form_icq size=14 value="<% If Form_icq<>"" Then Response.Write Server.HtmlEncode(Form_icq)%>">
				</td>
				<td rowspan="4" valign=bottom>&nbsp;<%If Form_userphoto<>"" and isNumeric(Form_userphoto) Then%><img name=faceimg id=faceimg src=<%=DEF_BBS_HomeUrl%>images/face/<%=string(4-len(cstr(Form_userphoto)),"0")&Form_userphoto%>.gif align=middle width=62 height=62><%Else%><img name=faceimg id=faceimg src=<%=DEF_BBS_HomeUrl%>images/blank.gif align=middle><%End If%></td>
			</tr>-->
			<tr>
				<td>
					QQ号码：
				</td>
				<td>
					<input class=fminpt maxlength=14 name=Form_oicq size=14 value="<% If Form_oicq<>"" Then Response.Write Server.HtmlEncode(Form_oicq)%>">
				</td>
			</tr>
			<tr>
				<td>
					性别：
				</td>
				<td>
					<label>
						<input class=fmchkbox type=radio name=Form_sex value=男 <%If Form_sex = "男" Then Response.Write " checked"%>>男</label>
					<label>
						<input class=fmchkbox type=radio name=Form_sex value=女 <%If Form_sex = "女" Then Response.Write " checked"%>>女</label>
					<label>
						<input class=fmchkbox type=radio name=Form_sex value=密 <%If Form_sex = "密" Then Response.Write " checked"%>>保密</label>
				</td>
			</tr>
			<tr>
				<td>
					用户头像：
				</td>
				<td>
					<input class=fminpt onchange="javascript:changeface();" maxlength=4 name=Form_userphoto size=4 value="<% If Form_userphoto<>"" Then Response.Write Server.HtmlEncode(string(4-len(cstr(Form_userphoto)),"0")&Form_userphoto)%>">
					<a href="UserModify.asp?action=face" target=_blank onclick="return(pub_command('选择头像',this,'anc_delbody',''));">头像一览表</a>
				</td>
			</tr><%If DEF_AllDefineFace <> 0 and DEF_AllDefineFace <> 2 Then%>
			<tr>
				<td>
					自定头像：
				</td>
				<td>
					<input class=fminpt onchange="javascript:changeface2();" maxlength=250 name=Form_FaceUrl size=36 value="<%=HtmlEncode(Form_FaceUrl)%>">
				</td>
			</tr>
			<tr>
				<td>
					头像大小：
				</td>
				<td>
					宽: <input class=fminpt onchange="javascript:changeface2();" maxlength=<%=len(DEF_AllFaceMaxWidth)%> name=Form_FaceWidth size=3 value="<%=HtmlEncode(Form_FaceWidth)%>">(20-<%=DEF_AllFaceMaxWidth%>)
					高: <input class=fminpt onchange="javascript:changeface2();" maxlength=<%=len(DEF_AllFaceMaxWidth)%> name=Form_FaceHeight size=3 value="<%=HtmlEncode(Form_FaceHeight)%>">(20-<%=DEF_AllFaceMaxWidth%>)
				</td>
			</tr><%End If%>
			<tr>
				<td>
					生日
				</td>
				<td>
					
					<input class=fminpt maxlength=4 name=Form_byear size=4 value="<% If Form_byear<>"" Then
						Response.Write Server.HtmlEncode(Form_byear)
					Else
						Response.Write "19"
					End If%>"> 年 
					<input class=fminpt maxlength=2 name=Form_bmonth size=2 value="<% If Form_bmonth<>"" Then Response.Write Server.HtmlEncode(Form_bmonth)%>">
					月 <input class=fminpt maxlength=2 name=Form_bday size=2 value="<% If Form_bday<>"" Then Response.Write Server.HtmlEncode(Form_bday)%>">
					日</td>
			</tr>
			<tr>
				<td>
					个人签名：
				</td>
				<td>
					<textarea class=fmtxtra name=Form_Underwrite rows=5 cols=34><%If Form_Underwrite <> "" Then Response.Write VbCrLf & htmlEncode(Form_Underwrite)%></textarea>
				</td>
			</tr>
			</table>
			<%End If%>
			<table border=0  cellpadding="0" cellspacing="0" class="blanktable">
			<%If LMT_RegVerifyQuestion <> "" Then%>
			<tr>
				<td>
					注册验证：<br />
					<span class="grayfont">按提示填写</span>
				</td>
				<td>
						<p>
						<%=LMT_RegVerifyQuestion%>
						</p>
						<input class='fminpt input_2' maxlength=100 name="Form_RegVerifyAnswer" size="14" value="<% If Form_RegVerifyAnswer<>"" Then Response.Write Server.HtmlEncode(Form_RegVerifyAnswer)%>">
				</td>
			</tr>
			<%End If%>
			<%If ShowTestNumber > 2 Then%>
			<tr>
				<td>
					验 证 码：
				</td>
				<td>
						<%Response.Write displayVerifycode()%>
				</td>
			</tr><%End If%>
			<tr>
				<td>&nbsp;</td>
				<td>
					<input name=submit type=submit value="申请" class="fmbtn btn_2">
					<input name=b1 type=reset value="重写" class="fmbtn btn_2">
				</td>
			</tr>
			</table>
</form>
<%if DEF_User_GetPassMode = 3 or DEF_User_GetPassMode = 4 then%>
<br />
<hr class="splitline">
<br />
<b>
<a href="usergetpass.asp?act=send&moreact=bind&gettype=unbind">若你的邮箱或手机已被注册，需要解除，请点这里．</a>
</b>
<%end if%>
<%
End Function

function get_temp_username

			dim sql,userName,N,ExistFlag
			ExistFlag = 1
			For N = 0 to 1000
				Randomize
				userName = "LD#"
				userName = userName & Mid(LngStr(GetTimeValue(DEF_Now)),3,6) & (Fix(Rnd*99999)+1)
				If CheckUserNameExist(userName) = 0 then
					ExistFlag = 0
					exit for
				End If
			Next
			get_temp_username = userName

end function

Function saveFormData

	If Form_UserName = "" Then
		Form_UserName = get_temp_username()
		'Randomize
		'Form_Password1 = rnd*99999999999+Timer
	End if
	Dim Rs
	Set Rs = Server.CreateObject("ADODB.RecordSet")
	Rs.Open "Select * from LeadBBS_User Where 1=0",con,2,2
	Rs.Addnew
	Rs("UserName") = Form_UserName
	Rs("Mail") = Trim(Form_Mail)
	Rs("Address") = Trim(Form_Address)
	Rs("Sex") = Form_Sex
	If Form_ICQ<>"" Then Rs("ICQ") = Form_ICQ
	If Form_OICQ<>"" Then Rs("OICQ") = Form_OICQ
	If Form_MobileTel<>"" Then Rs("MobileTel") = Form_MobileTel
	
	Rs("Userphoto") = Form_Userphoto
	Rs("Homepage") = Trim(Form_Homepage)
	Rs("Underwrite") = Form_Underwrite
	Rs("PrintUnderwrite") = Form_PrintUnderwrite
	Rs("Pass") = MD5(Form_Password1)
	If Len(Form_birthday) = 14 Then
		Rs("birthday") = Form_birthday
		Dim Temp
		temp = cCur(Left(Form_birthday,4))
		If temp > 1950 and temp < 2050 Then Rs("NongLiBirth") = GetNongLiTimeValue(ConvertToNongLi(RestoreTime(Form_birthday)))
	End If

	REM 特殊数据
	Rs("ApplyTime") = Form_ApplyTime
	Rs("IP") = Form_IP
	Rs("UserLevel") = Form_UserLevel
	Rs("Officer") = Form_Officer
	Rs("Points") = DEF_User_RegPoints
	Rs("Sessionid") = 0
	Rs("Online") = Form_Online
	Rs("Prevtime") = Form_Prevtime
	if Form_Answer = "" or Form_Question = "" then
		Rs("Answer") = ""
		Form_Question = ""
	else
		Rs("Answer") = MD5(Form_Answer)
	end if
	Rs("Question") = Form_Question

	Rs("LastDoingTime") = Form_ApplyTime
	Rs("LastWriteTime") = Form_ApplyTime
	If DEF_UserNewRegAttestMode > 0 Then
		Rs("UserLimit") = 1
	Else
		Rs("UserLimit") = 0
	End If

	If Form_FaceWidth < 20 Then Form_FaceWidth = 20
	If Form_FaceHeight < 20 Then Form_FaceHeight = 20
	If DEF_AllDefineFace <> 0 Then
		Rs("FaceUrl") = Form_FaceUrl & ""
		Rs("FaceWidth") = Form_FaceWidth
		Rs("FaceHeight") = Form_FaceHeight
	Else
		Rs("FaceWidth") = 20
		Rs("FaceHeight") = 20
	End If
	Rs("LastAnnounceID") = 0
	Rs.Update

	Rs.Close
	Set Rs = Nothing
	
	Set Session(DEF_MasterCookies & "UDT") = Nothing
	Session(DEF_MasterCookies & "UDT") = ""
	
	Set Rs = LDExeCute(sql_select("Select ID from LeadBBS_User Where UserName='" & Replace(Form_UserName,"'","''") & "'",1),0)
	If Not Rs.Eof Then
		Form_ID = LngStr(Rs(0))
	Else
		Form_ID = 0
	End If
	Rs.Close
	Set Rs = Nothing
	saveFormData = 1

	Dim Form_ExpiresTime
	If DEF_UserActivationExpiresDay > 0 and DEF_UserActivationExpiresDay < 3650 Then
		Form_ExpiresTime = GetTimeValue(DateAdd("d",DEF_UserActivationExpiresDay,DEF_Now))
	Else
		Form_ExpiresTime = 0
	End If
	If DEF_UserNewRegAttestMode > 0 Then
		If DEF_UserNewRegAttestMode = 1 or DEF_UserNewRegAttestMode = 3 or DEF_UserNewRegAttestMode = 4 Then
			Randomize
			AttestNumber = Right(Fix(Rnd*Timer)+Fix(Rnd*cCur(GetTimeValue(DEF_Now))) + 10000,6)
			if AttestNumber < 100000 then AttestNumber = AttestNumber + 100000
		End If
		CALL LDExeCute("insert into LeadBBS_SpecialUser(UserID,UserName,BoardID,Assort,ndatetime,ExpiresTime) values(" & Form_ID & ",'" & Replace(Form_UserName,"'","''") & "'," & AttestNumber & ",6," & GetTimeValue(DEF_Now) & "," & Form_ExpiresTime & ")",1)
	End If

	BindRegUser()

	CALL LDExeCute("Update LeadBBS_SiteInfo Set UserCount=UserCount+1",1)
	UpdateStatisticDataInfo 1,1,1
	UpdateStatisticDataInfo Form_UserName,12,0

	SendNewMessage "[LeadBBS]",Form_UserName,"欢迎光临论坛！","您在论坛已经注册成功，欢迎成为我们的一员！",GBL_IPAddress
	select case DEF_UserNewRegAttestMode
		case 1:
			SendRegMail()
		case 3:
			SendRegMobile()
		case 4:
			if Form_Mail <> "" then SendRegMail
			if Form_MobileTel & "" <> "" then SendRegMobile
		case else
			SendRegMail()
	end select
	
	if session("invited") & "" <> "" then
		dim sql
		dim invitedExist
		invitedExist = 0
		sql = sql_select("select id from leadbbs_user where id=" & toNum(session("invited"),0),1)
		set rs = ldexecute(sql,0)
		if not rs.eof then
			invitedExist = 1
		end if
		rs.close
		set rs = nothing
		
		sql = "insert into LeadBBS_invite(invited,beinvited,bepayment,getreward,ndatetime,invitedcode,activeflag) values(" & toNum(session("invited"),0) & "," & Form_ID & ",0,0," & GetTimeValue(DEF_Now) & ",'" & replace(toNum(session("invited"),0),"'","''") & "',1)"
		call ldexecute(sql,1)
		'sql = "update LeadBBS_invite set beinvited=" & Form_ID & ",activeflag=1,ndatetime=" & GetTimeValue(DEF_Now) & " where invitedcode='" & replace(replace(session("invited"),"'",""),"-","") & "' and beinvited=0"
		'call ldexecute(sql,1)
		session("invited") = ""
	end if
	
	'注册成功删除邀请码
	If LMT_EnableRegNewUsers = 0 and LMT_EnableInvitedRegCode = 1 Then '表示只允许邀请码注册
		if invitedRegCode > 0 then
			Con.ExeCute("Delete from LeadBBS_Plug_Card Where CardID=" & invitedRegCode)
		end if
	end if

End Function

Sub SendRegMobile

	dim tel,smsbody
	tel = Form_MobileTel
	smsbody = "尊敬的用户" & Form_UserName & "，您的激活码为" & AttestNumber & "，"
	if DEF_UserActivationExpiresDay > 0 and DEF_UserActivationExpiresDay < 3650 then
		smsbody = smsbody & DEF_UserActivationExpiresDay & "天内有效，"
	end if
	smsbody = smsbody & "感谢您的使用！"
	
	dim back
	back = SendSMS_Message(tel,smsbody,AttestNumber,0)
	if back < 0 then
		Response.Write "<p>短信发送失败，错误号：" & back & "</p>"
	else
		Response.Write "<p><b><a href=UserGetPass.asp?act=active class=greenfont>激活码已发送至您的手机，点此激活．</a></b></p>"
	end if

end Sub

Sub SendRegMail

	Dim HomeUrl
	HomeUrl = LD_GetUrl(1)

	Dim MailBody,Topic,TextBody
	Topic = "您成功注册" & DEF_SiteNameString & "的通知"
	MailBody = "<html>"
	TextBody = ""
	MailBody = MailBody & "<title>注册信息</title>"
	MailBody = MailBody & "<BODY>"
	MailBody = MailBody & "<table BORDER=0 WIDTH=95% ALIGN=CENTER><TBODY><tr>"
	MailBody = MailBody & "<TD valign=MIDDLE ALIGN=TOP><HR WIDTH=100% SIZE=1>"
	TextBody = TextBody & "------------------------------------------" & VbCrLf
	MailBody = MailBody & VbCrLf & "<b>" & htmlencode(Form_UserName)&"，您好</b>：<br><br>"
	TextBody = TextBody & htmlencode(Form_UserName)&"，您好：" & VbCrLf & VbCrLf
	MailBody = MailBody & "谢谢您注册本论坛，下面是您的注册信息！<br><br>"
	TextBody = TextBody & "谢谢您注册本论坛，下面是您的注册信息！" & VbCrLf & VbCrLf
	MailBody = MailBody & "用户名："&htmlencode(Form_UserName)&"<br>"
	TextBody = TextBody & "用户名："&htmlencode(Form_UserName) & VbCrLf
	'MailBody = MailBody & "密　码：" & left(Form_Password1,1) & "***" & right(Form_Password1,1) & "<br>"
	'TextBody = TextBody & "密　码：" & left(Form_Password1,1) & "***" & right(Form_Password1,1) & VbCrLf
	If DEF_UserNewRegAttestMode = 1 or DEF_UserNewRegAttestMode = 4 or DEF_UserNewRegAttestMode = 3 Then
		MailBody = MailBody & "激活码：" & AttestNumber & "<br>"
		TextBody = TextBody & "激活码：" & AttestNumber & VbCrLf
		MailBody = MailBody & "<p><b><a href=" & HomeUrl & "User/UserGetPass.asp?act=active&user=" & urlencode(Form_UserName) & ">请点击这里，输入您的注册信息，立即激活您的用户。</a></b><br>"
		TextBody = TextBody & VbCrLf & VbCrLf & "请输入下列网址，并输入您的注册信息，立即激活您的用户：" & VbCrLf & HomeUrl & "User/UserGetPass.asp?act=active&user=" & urlencode(Form_UserName) & VbCrLf & VbCrLf
	Else
		MailBody = MailBody & "<p>刚注册的用户需等待网站管理员进行认证才能成为正式用户，在通过之前在功能使用上会有一些限制。<br>"
		TextBody = TextBody & VbCrLf & VbCrLf & "刚注册的用户需等待网站管理员进行认证才能成为正式用户，在通过验证之前在功能使用上会有一些限制。" & VbCrLf
	End If
	MailBody = MailBody & "<br><br>"
	MailBody = MailBody & "<CENTER><font COLOR=RED><a href=""" & HomeUrl & """>欢迎经常光临论坛！</a></font>"
	MailBody = MailBody & "</td></tr></table><br><HR WIDTH=95% SIZE=1>"
	MailBody = MailBody & "<p ALIGN=CENTER>" & DEF_SiteNameString & " <a href=http://www.leadbbs.com target=_blank class=NavColor>" & DEF_Version & "</a></P>"
	TextBody = TextBody & VbCrLf & "论坛网址：" & HomeUrl & VbCrLf
	TextBody = TextBody & "------------------------------------------" & VbCrLf
	MailBody = MailBody & "</body>"
	MailBody = MailBody & "</html>"
	Select Case DEF_BBS_EmailMode
		Case 1: If SendEasyMail(Form_Mail,Topic,MailBody,TextBody) = 1 Then
					Response.Write "<br><br>资料成功发送到您的注册邮箱！"
				Else
					Response.Write "<br><br>论坛未正确设置邮件发送，资料发送失败！"
				End If
		Case 2: If SendJmail(Form_Mail,Topic,MailBody) = 1 Then
					Response.Write "<br><br>资料成功发送到您的注册邮箱！"
				Else
					Response.Write "<br><br>论坛未正确设置邮件发送，资料发送失败！"
				End If
		Case 3: If SendCDOMail(Form_Mail,Topic,TextBody) = 1 Then
					Response.Write "<br><br>资料成功发送到您的注册邮箱！"
				Else
					Response.Write "<br><br>论坛未正确设置邮件发送，资料发送失败！"
				End If
		Case Else: 
	End Select

End Sub

Function displayAccessFull

	Response.Cookies(DEF_MasterCookies)("user") = CodeCookie(Form_Username)
	Response.Cookies(DEF_MasterCookies)("pass") = CodeCookie(MD5(Form_Username & md5(Form_password1)))
	Response.Cookies(DEF_MasterCookies)("CDKEY") = MD5(Form_Username & CDKEY)
	Response.Cookies(DEF_MasterCookies)("expires") = LngStr(GetTimeValue(DateAdd("d",31,DEF_Now)))
	Response.Cookies(DEF_MasterCookies).Expires = DateAdd("d",31,DEF_Now)
	Response.Cookies(DEF_MasterCookies).Domain = DEF_AbsolutHome
	
	
	dim nomod
	if DEF_UserNewRegAttestMode > 0 then
		nomod = 1
	else
		nomod = 0
	end if
	CALL LDExeCute("Update LeadBBS_onlineUser set UserID=" & Form_ID & ",UserName='" & Replace(Form_Username,"'","''") & "',HiddenFlag=" & nomod & " where sessionID=" & session.sessionID,1)%>
	<div class=title>您已经成功<%If reg_action = "bind" Then%>完善帐号资料<%Else%>注册成为论坛用户<%End If%>，15秒钟后页面将自动返回相应页面。</a></div>
	<%If DEF_UserNewRegAttestMode = 1 or DEF_UserNewRegAttestMode = 3 or DEF_UserNewRegAttestMode = 4 Then
		Response.Write "<div class='value2 greenfont'>注册的用户只有浏览论坛的权限，激活用户的验证码已经成功发送到您的注册邮箱或手机。</div>" & VbCrLf
	ElseIf DEF_UserNewRegAttestMode = 2 Then
		Response.Write "<div class='value2 greenfont'>注册的用户只有浏览论坛的权限，请等待网站成员对您作出验证才能成为正式用户。</div>" & VbCrLf
	End If
	

	Dim HomeUrl,u
	HomeUrl = LD_GetUrl(0)
	u = filterUrlstr(Request("u"))
	If Left(u,1) <> "/" and Left(u,1) <> "\" and Left(u,Len(HomeUrl)) <> HomeUrl Then u = ""
	If u = "" Then
		u = LD_GetUrl(1) & "Boards.asp"
	else
		if u ="" and DEF_UserNewRegAttestMode <> 0 and DEF_UserNewRegAttestMode <> 2 then
			u = LD_GetUrl(1) & "usergetpass.asp?act=active"
		end if
	end if
	%><script type="text/javascript">
		function a_topage()
		{
			this.location.href = "<%=Replace(Replace(u,"\","\\"),"""","\""")%>"; 
		}
		setTimeout("a_topage()",15000);
		</script>

<%End Function

Sub Reg_Bind

	If reg_command = "bind" Then
		reg_BindExistUser()
		Exit Sub
	End If
	
	%>
	<div class="title">请选择: <a href="<%=DEF_RegisterFile%>?action=bind&command=bind&u=<%=Reg_GetRefer()%>">绑定已有论坛帐号</a> / <a href="<%=DEF_RegisterFile%>?action=bind&command=reg&u=<%=Reg_GetRefer()%>">完善帐号资料</div>
	<%

End Sub

Function Reg_GetRefer

	Dim HomeUrl,u
	HomeUrl = LD_GetUrl(0)
	u = filterUrlstr(Request.QueryString("u"))
	If Left(u,1) <> "/" and Left(u,1) <> "\" and Left(u,Len(HomeUrl)) <> HomeUrl Then u = ""
	If u = "" Then
		u = filterUrlstr(Lcase(Request.ServerVariables("HTTP_REFERER")))
		If Request.ServerVariables("SERVER_PORT") <> "80" Then HomeUrl = HomeUrl & ":" & Request.ServerVariables("SERVER_PORT")
		If Left(u,Len(HomeUrl)) <> Lcase(HomeUrl) Then u = ""
		If inStr(u,"/user/" & DEF_RegisterFile) > 0 Then u = ""
	End If
	Reg_GetRefer = htmlencode(u)

End Function

Sub reg_BindExistUser

	If request("SubmitFlag") = "" Then
		DisplayLoginForm("请填写要绑定的论坛用户信息:")
	Else
		If GBL_CHK_Flag = 1 and GBL_UserID > 0 Then
			If reg_CheckAppidForUserID(GBL_AppType,GBL_UserID) = 1 Then
				Response.Write "<div class=""redfont""><b><p>操作失败: </p></b>此账号已被绑定.</div>"
			Else
				If reg_checkAppidBinded() = 0 Then
					Response.Write "<div class=""redfont""><b>" & GBL_CHK_TempStr & "</b></div>"
				Else
					Form_ID = LngStr(GBL_UserID)
					BindRegUser()
					Response.Write "<div class=""greenfont""><b>帐号已成功绑定!</b></div>"
				End If
			End If
		Else
			Response.Write "<div class=""redfont""><b><p>操作失败: </p></b>您的帐号信息错误.<br /> " & GBL_CHK_Tempstr & "</div>"
		End If
	%>
	
	<%
	End If

end Sub

Sub BindRegUser

	If reg_action = "bind" and (reg_command = "reg" or reg_command = "bind") Then
		CALL LDExeCute("insert into LeadBBS_AppLogin(UserID,appid,GuestName,appType,ndatetime,IPAddress,Token) values(" & Form_ID & ",'" & Replace(Form_App_appid,"'","''") & "','" & Replace(Form_App_GuestName,"'","''") & "'," & GBL_AppType & "," & GetTimeValue(DEF_Now) & ",'" & Replace(GBL_IPAddress,"'","''") & "','" & Replace(Form_App_Token,"'","''") & "')",1)
	End If

End Sub

Function reg_checkAppidBinded
	
	Dim appInfo
	Form_App_GuestName = LeftTrue(GBL_CHK_User,20)
	appInfo = Request.Cookies(DEF_MasterCookies & "_AppInfo")
	Select Case CStr(GBL_AppType)
		Case "1":					
			If inStr(appInfo,",") Then appInfo = Split(appInfo,",")
			If IsArray(appInfo) Then
				If Ubound(appInfo,1) = 2 Then
					Form_App_Token = LeftTrue(appInfo(1),64)
					Form_App_appid = LeftTrue(appInfo(2),64)
				End If
			End If
			If Len(Form_App_appid) < 16 or Form_App_GuestName = "" Then
				GBL_CHK_TempStr = "操作失败:QQ互联信息已经失效,请重新登录. <br>" & VbCrLf
				reg_checkAppidBinded = 0
				Exit Function
			End If
		Case else
			GBL_CHK_TempStr = "操作失败:未知的互联商. <br>" & VbCrLf
			reg_checkAppidBinded = 0
			Exit Function
	End Select
	If reg_CheckAppid(GBL_AppType,Form_App_appid) = 1 Then
		GBL_CHK_TempStr = "操作失败:此互联帐号已被绑定或完善. <br>" & VbCrLf
		reg_checkAppidBinded = 0
		Exit Function
	End If
	reg_checkAppidBinded = 1

End Function
%>