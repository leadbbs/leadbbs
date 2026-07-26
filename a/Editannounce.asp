<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="../inc/Ubbcode.asp"-->
<!--#include file="../inc/Board_Popfun.asp"-->
<!--#include file="../inc/Limit_Fun.asp"-->
<!--#include file="inc/MakeAnnounceTop.asp"-->
<%DEF_BBS_HomeUrl = "../"%>
<!--#include file="inc/Editor_Fun.asp"-->
<!--#include file="../inc/Upload_Fun.asp"-->
<!--#include file="inc/upload1_fun.asp"-->
<!--#include file="inc/get_remote_pic_fun.asp"-->
<!--#include file="inc/Edit_BoardInfo_Fun.asp"-->

<%
Const LMTDEF_MinAnnounceLength = 2 '编辑提交的帖子内容需要最少字数
Const LMT_BuyAnnounceMaxPoints = 9 '购买帖消耗的最大积分
Const LMTDEF_NeedCachetValue = 1 '设定多少声望用户可以自己归类专题(编辑时)

Dim Form_EditAnnounceID,Form_BoardID,Form_RootID,Form_ParentID
Dim Form_Title,Form_Content,Form_FaceIcon,Form_ndatetime
Dim Form_Length,Form_UserName,Form_UserID,Form_HTMLFlag,Form_UnderWriteFlag
Dim Form_NoUserUnderWriteFlag,Form_NotReplay
Dim Form_GoodAssort,Form_GoodAssort_Old
Dim Form_TopicType,Form_NeedValue,Form_TitleStyle,Form_Topictype_Old,Form_TitleStyle_Old,Form_Title_Old
Dim Form_Root_TopicType,Form_Root_NeedValue
Form_TitleStyle = 0

Dim Form_VoteType,Form_VoteItem,Form_Vote_ExpireDay,VoteFlag,Form_VoteType_Old
VoteFlag = 0

Dim LMT_TopicName,LMT_TopicNameNoHTML,LMT_TopicTitleStyle,LMT_RootIDBak,LMT_TopicNameNoHTML_Temp
Dim Upd_ErrInfo,Form_UpClass,Form_UpFlag,Form_Submitflag,Form_ForumNumber

Form_HTMLFlag = 2
Dim LMT_RootMaxID,LMT_RootMinID
LMT_RootMaxID = 0
LMT_RootMinID = 0

Dim LMT_EnableUpload

Dim SupervisorFlag,VoteGetData,VoteNumber

dim Form_remoteEnable : Form_remoteEnable = 0



Function DisplayAnnounceForm

	Dim Temp
	Temp = GBL_CHK_TempStr
%>

<script type="text/javascript">
<!--
var submitflag=0;
function submitonce(theform)
{
	submitflag = 1;
	var lg;<%If DEF_EnableAttestNumber > 2 and (DEF_AttestNumberPoints = 0 or GBL_CHK_Points < DEF_AttestNumberPoints) Then%>
		
	if(theform.ForumNumber.value=="")
	{
		alert("请输入验证码!\n");
		ValidationPassed = false;
		theform.ForumNumber.focus();
		submitflag = 0;
		return;
	}
	else
	{ValidationPassed = true;
	}<%End If%>
	
	edt_checkContent();
	lg = edt_getdoclen();
	if(lg < <%=LMTDEF_MinAnnounceLength%>)
	{
		alert("发表的内容长度不符合要求 \n\n至少要求<%=LMTDEF_MinAnnounceLength%>文字，目前长度" + lg + "文字\n");
		ValidationPassed = false;
		submitflag = 0;
		return;
	}
	if(lg > <%=LMT_MaxTextLength%>)
	{
		alert("发表的内容超过了<%=LMT_MaxTextLength%>文字，目前长度" + lg + "文字\n");
		ValidationPassed = false;
		submitflag = 0;
		return;
	}
	else
	{
		ValidationPassed = true;
	}
	submit_disable(theform);
}

function storeCaret (textEl)
{
	if (textEl.createTextRange) 
	textEl.caretPos = document.selection.createRange().duplicate(); 
}

function ctlkey(event)
{
	if(event.ctrlKey && event.keyCode==13){submitonce(document.LeadBBSFm);if(ValidationPassed)document.LeadBBSFm.submit();return(false);}
	if(event.altKey && event.keyCode==83){submitonce(document.LeadBBSFm);if(ValidationPassed)document.LeadBBSFm.submit();return(false);}
}
//-->
</script><%
DisplayPreview()
Global_TableHead()
LMT_EnableUpload = 1
If GBL_UserID < 1 Then LMT_EnableUpload = 0
Select Case DEF_EnableUpload
	Case 0: LMT_EnableUpload = 0
	case 2: If CheckSupervisorUserName() = 0 Then LMT_EnableUpload = 0
	Case 3: If GBL_BoardMasterFlag < 4 Then LMT_EnableUpload = 0
	Case 4: If GetBinarybit(GBL_CHK_UserLimit,2) = 0 Then LMT_EnableUpload = 0
	Case 5: If GBL_BoardMasterFlag < 4 and GetBinarybit(GBL_CHK_UserLimit,2) = 0 Then LMT_EnableUpload = 0
End Select

If DEF_Upd_SpendFlag = 0 and GBL_BoardMasterFlag >=4 Then
	Upd_SpendFlag = 0
Else
	Upd_SpendFlag = 1
End If

If Upd_SpendFlag = 1 and DEF_UploadSpendPoints > 0 and DEF_UploadSpendPoints > GBL_CHK_Points Then LMT_EnableUpload = 0
If LMT_EnableUpload = 1 and (GBL_CHK_OnlineTime >= DEF_NeedOnlineTime or DEF_NeedOnlineTime = 0) Then
	LMT_EnableUpload = 1
Else
	LMT_EnableUpload = 0
End If
%>
<div class=contentbox>
		<table border=0 cellpadding=0 cellspacing=0 width="100%" class=tablebox>
		<tr>
			<td class=tbhead><div class=value><%
				Response.Write "编辑帖子："  & LMT_TopicNameNoHTML_Temp%></div></td>
		</tr>
		</table>
		<%If LMT_EnableUpload = 0 Then %>
		<form action=EditAnnounce.asp method=post id=LeadBBSFm name=LeadBBSFm onSubmit="submitonce(this);return ValidationPassed;">
		<%Else%>
		<form action="EditAnnounce.asp?dontRequestFormFlag=1" id=LeadBBSFm name=LeadBBSFm method="post" enctype="multipart/form-data" onsubmit="submitonce(this);if(ValidationPassed)Upl_submit();return ValidationPassed;">
		<%End If%>
		<table border=0 cellpadding=0 cellspacing=0 width="100%" class=tablebox>
		<tr>
			<td width="<%=DEF_BBS_LeftTDWidth%>" class=tdleft>*原发帖人</td>
			<td class=tdright>
				<input name=test value="testvalue" type=hidden>
				<input maxlength=20 name=Form_User value="<%=htmlencode(Form_UserName)%>" size="20" readonly class='fminpt input_2'>
				<input name=submitflag value="slzOowl_kdO8m610" type=hidden>
				<input name=BoardID value="<%=Form_BoardID%>" type=hidden>
				<input name=ID value="<%=LngStr(Form_EditAnnounceID)%>" type=hidden>
			</td>
		</tr>
		<tr>
			<td width="<%=DEF_BBS_LeftTDWidth%>" class=tdleft>*帖子标题</td>
			<td class=tdright>
				<%
				If VoteFlag = 0 Then%>
					<input maxlength=255 name=Form_Title size="49" value="<%
					If (Form_Submitflag = "first" or Form_Submitflag = "") and form_ParentID > 0 and Form_Title="" Then
						If Left(LMT_TopicName,3) <> "Re:" Then
							Response.Write "Re:" & htmlencode(LMT_TopicNameNoHTML)
						Else
							Response.Write htmlencode(LMT_TopicNameNoHTML)
						End If
					Else
						Response.Write htmlencode(Form_title)
					End If%>" class='fminpt input_4'><%
				Else%>
              		<input maxlength=255 name=Form_Title size="35" value="<%=htmlencode(Form_Title)%>" class='fminpt input_4'>
					<%If isNumeric(Form_Vote_ExpireDay) = 0 then Form_Vote_ExpireDay = 0
					Form_Vote_ExpireDay = cCur(Form_Vote_ExpireDay)%>
					<select name="Form_Vote_ExpireDay">
						<option value=0>到期时间</option>
						<option value=0<%If Form_Vote_ExpireDay = 0 Then Response.Write " selected"%>>永不到期</option>
						<option value=1<%If Form_Vote_ExpireDay = 1 Then Response.Write " selected"%>>一天</option>
						<option value=2<%If Form_Vote_ExpireDay = 2 Then Response.Write " selected"%>>两天</option>
						<option value=3<%If Form_Vote_ExpireDay = 3 Then Response.Write " selected"%>>三天</option>
						<option value=7<%If Form_Vote_ExpireDay = 7 Then Response.Write " selected"%>>一周</option>
						<option value=10<%If Form_Vote_ExpireDay = 10 Then Response.Write " selected"%>>十天</option>
						<option value=15<%If Form_Vote_ExpireDay = 15 Then Response.Write " selected"%>>半个月</option>
						<option value=20<%If Form_Vote_ExpireDay = 20 Then Response.Write " selected"%>>二十天</option>
						<option value=30<%If Form_Vote_ExpireDay = 30 Then Response.Write " selected"%>>一个月</option>
						<option value=45<%If Form_Vote_ExpireDay = 45 Then Response.Write " selected"%>>一个月半</option>
						<option value=60<%If Form_Vote_ExpireDay = 60 Then Response.Write " selected"%>>二个月</option>
						<option value=90<%If Form_Vote_ExpireDay = 90 Then Response.Write " selected"%>>三个月</option>
						<option value=120<%If Form_Vote_ExpireDay = 120 Then Response.Write " selected"%>>四个月</option>
						<option value=180<%If Form_Vote_ExpireDay = 180 Then Response.Write " selected"%>>六个月</option>
						<option value=240<%If Form_Vote_ExpireDay = 240 Then Response.Write " selected"%>>八个月</option>
						<option value=365<%If Form_Vote_ExpireDay = 365 Then Response.Write " selected"%>>一年</option>
					</select>
				<%End If
				If GBL_BoardMasterFlag >= 5 Then%>
				<select name="Form_TitleStyle">
					<option value=0<%If Form_TitleStyle = 0 Then Response.Write " selected"%>>样式</option><%If GBL_BoardMasterFlag >= 9 or Form_TitleStyle_Old = 1 Then%>
					<option value=1<%If Form_TitleStyle = 1 Then Response.Write " selected"%>>HTML</option><%End If%>
					<option value=2<%If Form_TitleStyle = 2 Then Response.Write " selected"%>>红色</option>
					<option value=3<%If Form_TitleStyle = 3 Then Response.Write " selected"%>>绿色</option>
					<option value=4<%If Form_TitleStyle = 4 Then Response.Write " selected"%>>蓝色</option>
					<option value=5<%If Form_TitleStyle = 5 Then Response.Write " selected"%>>加重</option>
					<option value=6<%If Form_TitleStyle = 6 Then Response.Write " selected"%>>重红</option>
					<option value=7<%If Form_TitleStyle = 7 Then Response.Write " selected"%>>重绿</option>
					<option value=8<%If Form_TitleStyle = 8 Then Response.Write " selected"%>>重蓝</option>
				</select>
				<%End If

				If cCur(Form_ParentID)=0 and (GBL_CHK_CachetValue >= LMTDEF_NeedCachetValue or GBL_BoardMasterFlag >= 4) Then
					Dim TArray,Num,N,TArray2
					TArray = Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID & "_TI")
					TArray2 = Application(DEF_MasterCookies & "BoardInfo" & 0 & "_TI")
					If isArray(TArray) = False Then
						If TArray & "" <> "yes" Then ReloadTopicAssort(GBL_Board_ID)
						TArray = Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID & "_TI")
					End If
					If isArray(TArray2) = False Then
						If TArray2 & "" <> "yes" Then ReloadTopicAssort(0)
						TArray2 = Application(DEF_MasterCookies & "BoardInfo" & 0 & "_TI")
					End If
					If isArray(TArray) = True or isArray(TArray2) = True Then%>
					<select name="Form_GoodAssort"  style="width:74">
					<%
						If isArray(TArray) = True Then
							Response.Write "<Option value=0 class=TBBG1>选择专题" & VbCrLf
							Num = Ubound(TArray,2)
							For N = 0 To Num
								If cCur(TArray(0,N)) = Form_GoodAssort Then
									Response.Write "<Option value=" & TArray(0,N) & " selected>" & TArray(1,N) & VbCrLf
								Else
									Response.Write "<Option value=" & TArray(0,N) & ">" & TArray(1,N) & VbCrLf
								End If
							Next
						End If
						If isArray(TArray2) = True Then
							Response.Write "<Option value=0 class=TBBG1>=总专题=" & VbCrLf
							Num = Ubound(TArray2,2)
							For N = 0 To Num
								If cCur(TArray2(0,N)) = Form_GoodAssort Then
									Response.Write "<Option value=" & TArray2(0,N) & " selected>" & TArray2(1,N) & VbCrLf
								Else
									Response.Write "<Option value=" & TArray2(0,N) & ">" & TArray2(1,N) & VbCrLf
								End If
							Next
						End If
						Response.Write "</select>" & VbCrLf
					End If
				End If%></td>
		</tr><%If VoteFlag = 1 Then%>
		<tr>
			<td width="<%=DEF_BBS_LeftTDWidth%>" class=tdleft>*投票选项
			<p>每行一个投票选项，不能减少选项，可增加选项最多到<br><%=DEF_VOTE_MaxNum%>个，可修改选项
			<p><%
			if Form_VoteType then
				Form_VoteType = 1
			else
				Form_VoteType = 0
			end if
				Form_VoteType = cCur(Form_VoteType)%><table border=0 cellpadding=0 cellspacing=0><tr><td><input class=fmchkbox type=radio name=Form_VoteType value=0 <%If Form_VoteType = 0 Then Response.Write " checked"%>></td><td>单选票</td>
          		<td><input class=fmchkbox type=radio name=Form_VoteType value=1 <%If Form_VoteType = 1 Then Response.Write " checked"%>></td><td>多选票</td></tr></table>
			</td>
			<td class=tdright>
				<textarea cols=80 name=Form_VoteItem rows=8 style="width: 95%; word-break: break-all;" onkeydown="if(ctlkey(event)==false)return(false);" class=fmtxtra><%If Form_VoteItem <> "" Then Response.Write VbCrLf & htmlEncode(Form_VoteItem)%></textarea>
				</td>
		</tr><%End If%>
		<tr>
			<td width="<%=DEF_BBS_LeftTDWidth%>" class=tdleft>发帖表情</td>
			<td class=tdright>
				<input name=Form_FaceIcon class=fmchkbox type=radio value=0>无
				<input name=Form_FaceIcon class=fmchkbox type=radio value=1<%If Form_FaceIcon=1 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE1.GIF" class=absmiddle>
				<input name=Form_FaceIcon class=fmchkbox type=radio value=2<%If Form_FaceIcon=2 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE2.GIF" class=absmiddle>
				<input name=Form_FaceIcon class=fmchkbox type=radio value=3<%If Form_FaceIcon=3 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE3.GIF" class=absmiddle>
				<input name=Form_FaceIcon class=fmchkbox type=radio value=5<%If Form_FaceIcon=5 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE5.GIF" class=absmiddle>
				<input name=Form_FaceIcon class=fmchkbox type=radio value=6<%If Form_FaceIcon=6 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE6.GIF" class=absmiddle>
				<input name=Form_FaceIcon class=fmchkbox type=radio value=7<%If Form_FaceIcon=7 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE7.GIF" class=absmiddle>
				<input name=Form_FaceIcon class=fmchkbox type=radio value=15<%If Form_FaceIcon=15 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE15.GIF" class=absmiddle>
				<input name=Form_FaceIcon class=fmchkbox type=radio value=16<%If Form_FaceIcon=16 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE16.GIF" class=absmiddle>
			</td>
		</tr><%
		call DisplayLeadBBSEditor1(Form_HTMLFlag,Form_Content,0,1)
		
		If Form_ParentID=0 and Form_TopicType <> 80 Then%>
		<tr>
			<td width="<%=DEF_BBS_LeftTDWidth%>" class=tdleft>加密本帖功能</td>
			<td class=tdright>
				<table border="0" cellspacing="0" cellpadding="0" class="blanktable"><tr><td>
					<select name=Form_TopicType onchange="if(this.value<49)$id('NextContactDateDiv').style.display='none';if(this.value>=49)$id('NextContactDateDiv').style.display='block';">
						<%If Form_Topictype_Old <> 54 Then%><option value="0">请选择限制条件...
						<%If DEF_EnableSpecialTopic = 1 and GetBinarybit(GBL_Board_BoardLimit,14) = 1 Then%><option value="7"<%If Form_TopicType = 7 Then Response.Write " selected"%>>回复本帖才能查看<%End If%>
						<option value="50"<%If Form_TopicType = 50 Then Response.Write " selected"%>>查看本帖需要达到<%=DEF_PointsName(0)%>
						<option value="51"<%If Form_TopicType = 51 Then Response.Write " selected"%>>回复本帖需要达到<%=DEF_PointsName(0)%>
						<option value="52"<%If Form_TopicType = 52 Then Response.Write " selected"%>>查看本帖需要达到<%=DEF_PointsName(4)%>
						<option value="53"<%If Form_TopicType = 53 Then Response.Write " selected"%>>回复本帖需要达到<%=DEF_PointsName(4)%>
						<option value="55"<%If Form_TopicType = 55 Then Response.Write " selected"%>>只限指定用户能查看此帖：<%End If%>
						<%If (Form_TopicType_Old = 54 or (DEF_EnableSpecialTopic = 1 and GetBinarybit(GBL_Board_BoardLimit,14) = 1)) and Form_TopicType_Old <> 49 Then%>
						<option value="54"<%If Form_TopicType = 54 Then Response.Write " selected"%>>出售本帖，花费<%=DEF_PointsName(0)%><%End If%>
						<%If (Form_TopicType_Old = 49 or (DEF_EnableSpecialTopic = 1 and GetBinarybit(GBL_Board_BoardLimit,14) = 1)) and Form_TopicType_Old <> 54 Then%>
						<option value="49"<%If Form_TopicType = 49 Then Response.Write " selected"%>>出售本帖，花费<%=DEF_PointsName(1)%><%End If%>
						<%If Form_Topictype_Old <> 54 Then%><option value="1"<%If Form_TopicType = 1 Then Response.Write " selected"%>>仅本版<%=DEF_PointsName(8)%>才能查看
						<option value="2"<%If Form_TopicType = 2 Then Response.Write " selected"%>>仅本版<%=DEF_PointsName(8)%>才能回复
						<option value="3"<%If Form_TopicType = 3 Then Response.Write " selected"%>>仅<%=DEF_PointsName(8)%>才能查看
						<option value="4"<%If Form_TopicType = 4 Then Response.Write " selected"%>>仅<%=DEF_PointsName(8)%>才能回复
						<option value="5"<%If Form_TopicType = 5 Then Response.Write " selected"%>>仅<%=DEF_PointsName(5)%>才能查看
						<option value="6"<%If Form_TopicType = 6 Then Response.Write " selected"%>>仅<%=DEF_PointsName(5)%>才能回复<%End If%>
					</select>
				</td><td>
				<span name=NextContactDateDiv id=NextContactDateDiv<%If Form_TopicType<49 Then Response.Write " style='display:none'"%>>
					<input name=Form_NeedValue value="<%If cStr(Form_NeedValue) <> "0" Then Response.Write htmlencode(Form_NeedValue)%>" size=10 maxlength=10 class='fminpt input_1'></span>
				</td><td>
					<a href="#icon" onclick="if(LeadBBSFm.Form_TopicType.value=='0'){alert('在插入隐藏标签前请选择限制条件.');}else{addcontent(0,'HIDDEN','/HIDDEN');}">插入隐藏标签</a>
				</td></tr></table>
		</tr><%End If%>
		<tr class=tdleft>
			<td class=tdleft>其它选项</td>
			<td class=tdright>
				<label>
				<input type="checkbox" class=fmchkbox name="Form_UnderWriteFlag" value="checkbox"<%If Form_UnderWriteFlag=1 Then Response.Write " checked"%>>显示签名</label>
				<label>
				<input type="checkbox" class=fmchkbox name="Form_NotReplay" value="checkbox"<%If Form_NotReplay = 1 Then Response.Write " checked"
						If GBL_BoardMasterFlag < 5 and Form_NotReplay = 1 Then Response.Write " DISABLED"%>><%
						If Form_ParentID=0 Then
							Response.Write "锁定主题"
						Else
							Response.Write "锁定帖子"
						End If%></label>
				<%if remote_checkEnable() = 1 then%>
					<label title="提取非本站的图片并保存至本地,只限UBB格式">
					<input class=fmchkbox type="checkbox" name="Form_remoteEnable"<%
					
					if UploadListNum > Remote_MaxGet then Form_remoteEnable = 0
					if UploadListNum > Remote_MaxGet then%> disabled="true"<%End If%> value="1"<%If Form_remoteEnable=1 Then Response.Write " checked"%>>提取非本站图片(最多<%=Remote_MaxGet%>张)
					</label>
				<%end if
				%>
				<%If DEF_EnableAttestNumber > 2 and (DEF_AttestNumberPoints = 0 or GBL_CHK_Points < DEF_AttestNumberPoints) Then%>
				<div style="line-height:400%">验证码
				<%
					Response.Write displayVerifycode()%></div><%
				End If%>
			</td>
		</tr>
		<tr>
			<td class=tdleft>&nbsp;</td>
			<td class=tdright>
				<br />
				<input name=submit2 type=submit value="完成编辑" class="fmbtn btn_3">
				<input id=Preview_btn type=button value="预览编辑" onclick="edt_preview();" class="fmbtn btn_3">
				<br /><br />
			</td>
		</tr>
		</table>
		</form>
</div>
<%
	Global_TableBottom()

End Function

Function GetFormData(name)

	If Form_UpFlag = 0 Then
		GetFormData = Request.Form(name)
	Else
		GetFormData = Form_UpClass.form(name)
	End If
	if GetFormData = "" then GetFormData = request.querystring(name)

End Function

Sub Get_PublicValue

	If Request.QueryString("dontRequestFormFlag") = "" Then
		Form_UpFlag = 0
	Else
		Form_UpFlag = 1
		Server.ScriptTimeOut=3000
		set Form_UpClass=new upload_Class
		Form_UpClass.ProgressID = Request.QueryString("Upload_ID")
		Form_UpClass.GetUpFile
	End If
	Form_Submitflag = Request.QueryString("submitflag")
	If Form_Submitflag = "" Then Form_Submitflag = GetFormData("submitflag")

	Form_EditAnnounceID = Request.QueryString("ID")
	If Form_EditAnnounceID = "" Then Form_EditAnnounceID = Left(GetFormData("ID"),14)
	Form_EditAnnounceID = toNum(Form_EditAnnounceID,0)

	If GBL_Board_ID = 0 Then
		GBL_Board_ID = GetFormData("BoardID")
		If GBL_Board_ID = "" Then GBL_Board_ID = GetFormData("b")
		GBL_Board_ID = fix(toNum(GBL_Board_ID,0))
		If GBL_Board_ID > 2147479999 Then GBL_Board_ID = 0
		If GBL_Board_ID > 0 Then Borad_GetBoardIDValue(GBL_Board_ID)
	End If

	Form_BoardID = GBL_board_ID

End Sub

Function GetRequestValue

	If Form_Submitflag = "slzOowl_kdO8m610" Then
		Form_Title = LeftTrue(Trim(GetFormData("Form_Title")),255)
		Form_HTMLFlag = GetFormData("Form_HTMLFlag")
		If Form_HTMLFlag="2" Then
			Form_HTMLFlag=2
		ElseIf Form_HTMLFlag = "1" and ((GetBinarybit(GBL_CHK_UserLimit,16) = 1 and GBL_BoardMasterFlag >= 2) or SupervisorFlag = 1) and GBL_UserID > 0 Then
			Form_HTMLFlag = 1
		Else
			Form_HTMLFlag = 0
		End If
	Else
		Form_HTMLFlag = 2
	End If

	Form_Content = GetFormData("Form_Content")
	
	Form_FaceIcon = Left(GetFormData("Form_FaceIcon"),14)
	If isNumeric(Form_FaceIcon) = 0 Then Form_FaceIcon = 0	
	Form_FaceIcon = Fix(cCur(Form_FaceIcon))
	If Form_FaceIcon < 0 or Form_FaceIcon > 16 Then Form_FaceIcon = 0
	
	Form_NoUserUnderWriteFlag = GetFormData("Form_NoUserUnderWriteFlag")
	If Form_NoUserUnderWriteFlag="checkbox" Then
		Form_NoUserUnderWriteFlag = 1
	Else
		Form_NoUserUnderWriteFlag = 0
	End If

	If GBL_BoardMasterFlag >= 5 or Form_NotReplay = 0 Then
		Form_NotReplay = GetFormData("Form_NotReplay")
		If Form_NotReplay <> "" Then 
			Form_NotReplay = 1
		Else
			Form_NotReplay = 0
		End If
	End If

	If IsNull(Form_TopicType) Then Form_TopicType= 0
	If IsNull(Form_NeedValue) Then Form_NeedValue = 0

	If Form_ParentID = 0 and Form_Topictype_Old <> 80 Then
		Form_TopicType = Left(GetFormData("Form_TopicType"),14)
		If isNumeric(Form_TopicType) = 0 Then Form_TopicType = 0
		Form_TopicType = cCur(Form_TopicType)
		If Not ((Form_TopicType >=0 and Form_TopicType <=7) or (Form_TopicType>=49 and Form_TopicType<=55)) Then Form_TopicType = 0
		If Form_Topictype_Old = 54 or Form_Topictype_Old = 49 or Form_Topictype_Old = 114 or Form_Topictype_Old = 109 Then Form_Topictype = Form_Topictype_Old
		If Form_TopicType = 55 Then
			Form_NeedValue = Left(GetFormData("Form_NeedValue"),20)
		Else
			If Form_TopicType >=49 and Form_TopicType <=54 Then
				Form_NeedValue = Left(GetFormData("Form_NeedValue"),14)
				If isNumeric(Form_NeedValue) = 0 Then Form_NeedValue = 0
				Form_NeedValue = cCur(Form_NeedValue)
				If Form_NeedValue<0 or Form_NeedValue > 999999 Then Form_NeedValue = 0
			Else
				Form_NeedValue = 0
			End If
		End If
		If Form_TopicType = 7 Then
			If DEF_EnableSpecialTopic = 0 or GetBinarybit(GBL_Board_BoardLimit,14) = 0 Then
				Form_TopicType = 0
				Form_NeedValue = 0
			End If
		End If
	Else
		Form_NeedValue = 0
		If Form_Topictype_Old <> 80 Then Form_TopicType = 0
	End If

	Form_GoodAssort = Left(GetFormData("Form_GoodAssort"),14)
	
	Form_UnderWriteFlag = GetFormData("Form_UnderWriteFlag")
	If Form_UnderWriteFlag="checkbox" Then
		Form_UnderWriteFlag = 1
	Else
		Form_UnderWriteFlag = 0
	End If
	
	If VoteFlag = 1 Then
		Form_VoteItem = Trim(GetFormData("Form_VoteItem"))
		Form_Vote_ExpireDay = Left(Trim(GetFormData("Form_Vote_ExpireDay")),14)
		Form_VoteType = Left(Trim(GetFormData("Form_VoteType")),14)
	End If
	Form_TitleStyle = Left(GetFormData("Form_TitleStyle"),14)
	Form_ForumNumber = Left(GetFormData("ForumNumber"),4)
	Form_remoteEnable = toNum(GetFormData("Form_remoteEnable"),0)
	
	if UploadListNum > Remote_MaxGet then Form_remoteEnable = 0

End Function

Function Borad_CheckAnnounceIDExist(ID)

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select id from LeadBBS_Announce where id=" & ID,1),0)
	If Rs.Eof Then
		Borad_CheckAnnounceIDExist = 0
	Else
		Borad_CheckAnnounceIDExist = 1
	End If
	Rs.Close
	Set Rs = Nothing

End Function

Function DisplayOfficerString(Officer)

	Dim Officer_Temp,Temp_N,dotFlag
	dotFlag = 0
	Officer_Temp = split(Officer,",")
	For Temp_N = 0 to Ubound(Officer_Temp,1)
		If isNumeric(Officer_Temp(Temp_N)) Then
			Officer_Temp(Temp_N) = cCur(Officer_Temp(Temp_N))
			If Officer_Temp(Temp_N)>=0 and Officer_Temp(Temp_N)<=DEF_UserOfficerNum Then
				If dotFlag = 0 Then
					dotFlag = 1
					DisplayOfficerString = DisplayOfficerString & DEF_UserOfficerString(Officer_Temp(Temp_N))
				Else
					DisplayOfficerString = DisplayOfficerString & "," & DEF_UserOfficerString(Officer_Temp(Temp_N))
				End If
			End If
		End If
	Next

End Function

function GetUserID(UserName)

	Dim Rs,SQL
	SQL = sql_select("Select ID from LeadBBS_User Where UserName='" & Replace(username,"'","''") & "'",1)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		GetUserID = 0
	Else
		SQL = Rs(0)
		If isNull(SQL) Then SQL = 0
		GetUserID = cCur(SQL)
	End If
	Rs.Close
	Set Rs = Nothing

End Function

Function ResumeCode(Tstr)

	Dim str
	str = Tstr
	Str = Replace(str," &nbsp; &nbsp; &nbsp;",chr(9))
	Str = Replace(str,"<br>" & "&nbsp;",VbCrLf & " ")
	Str = Replace(str,"<br>" & "&nbsp;",VbCrLf & " ")
	Str = Replace(str,"<br>" & VbCrLf,VbCrLf)
	Str = Replace(str,"<br>" & VbCrLf,VbCrLf)
	Str = Replace(str,"<br>",VbCrLf)
	Str = Replace(str,"<br>",VbCrLf)
	Str = Replace(str,"&nbsp;"," ")
	str = Replace(str,"&gt;",">")
	Str = Replace(str,"&lt;","<")
	Str = Replace(str,"&quot;","""")
	ResumeCode = Str

End Function

Function Borad_CheckBoardIDExist(ID)

	If isArray(Application(DEF_MasterCookies & "BoardInfo" & ID)) = False Then
		ReloadBoardInfo(ID)
		If isArray(Application(DEF_MasterCookies & "BoardInfo" & ID)) = False Then
			Borad_CheckBoardIDExist = 0
		Else
			Borad_CheckBoardIDExist = 1
		End If
	Else
		Borad_CheckBoardIDExist = 1
	End If

End Function

Dim LMT_GoodAssortIndex
LMT_GoodAssortIndex = -1
Function CheckGoodAssortID(ID)

	Dim TArray,Num,N

	TArray = Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID & "_TI")
	If isArray(TArray) = True Then
		Num = Ubound(TArray,2)
		For N = 0 To Num
			If cCur(TArray(0,N)) = ID Then
				CheckGoodAssortID = 1
				LMT_GoodAssortIndex = N
				Exit Function
			End If
		Next
	End If
	TArray = Application(DEF_MasterCookies & "BoardInfo" & 0 & "_TI")
	If isArray(TArray) = True Then
		Num = Ubound(TArray,2)
		For N = 0 To Num
			If cCur(TArray(0,N)) = ID Then
				CheckGoodAssortID = 1
				LMT_GoodAssortIndex = N
				Exit Function
			End If
		Next
	End If
	CheckGoodAssortID = 0

End Function


Sub ChangeGoodAssort(ID,ID2)

	If ID = ID2 Then Exit Sub
	Dim TArray,N,Num,NN,ExitN
	TArray = Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID & "_TI")
	If isArray(TArray) = False Then
		'ChangeGoodAssort = 0
		Exit Sub
	End If
	Num = Ubound(TArray,2)
	NN = 0
	ExitN = 2
	If ID = 0 or ID2 = 0 Then ExitN = 1
	For N = 0 To Num
		If ID = cCur(TArray(0,N)) Then
			If cCur(TArray(2,N)) = -1 Then
				TArray(3,N) = 0
				TArray(4,N) = 0
			Else
				TArray(2,N) = cCur(TArray(2,N)) - 1
				TArray(3,N) = 0
				TArray(4,N) = 0
			End If
			NN = NN + 1
			If NN >= ExitN Then Exit For
		End If
		If ID2 = cCur(TArray(0,N)) Then
			If cCur(TArray(2,N)) <> 0 Then
				If cCur(TArray(2,N)) = -1 Then
					TArray(2,N) = 1
					TArray(3,N) = 0
					TArray(4,N) = 0
				Else
					TArray(2,N) = cCur(TArray(2,N)) + 1
					TArray(3,N) = 0
					TArray(4,N) = 0
				End If
			End If
			TArray(2,N) = 0
			NN = NN + 1
			If NN >= ExitN Then Exit For
		End If
	Next
	If NN > 0 Then
		Application.Lock
		Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID & "_TI") = TArray
		Application.UnLock
	End If

	If NN < 2 Then
		TArray = Application(DEF_MasterCookies & "BoardInfo" & 0 & "_TI")
		If isArray(TArray) = False Then
			'ChangeGoodAssort = 0
			Exit Sub
		End If
		Num = Ubound(TArray,2)
		NN = 0
		ExitN = 2
		If ID = 0 or ID2 = 0 Then ExitN = 1
		For N = 0 To Num
			If ID = cCur(TArray(0,N)) Then
				If cCur(TArray(2,N)) = -1 Then
					TArray(3,N) = 0
					TArray(4,N) = 0
				Else
					TArray(2,N) = cCur(TArray(2,N)) - 1
					TArray(3,N) = 0
					TArray(4,N) = 0
				End If
				NN = NN + 1
				If NN >= ExitN Then Exit For
			End If
			If ID2 = cCur(TArray(0,N)) Then
				If cCur(TArray(2,N)) <> 0 Then
					If cCur(TArray(2,N)) = -1 Then
						TArray(2,N) = 1
						TArray(3,N) = 0
						TArray(4,N) = 0
					Else
						TArray(2,N) = cCur(TArray(2,N)) + 1
						TArray(3,N) = 0
						TArray(4,N) = 0
					End If
				End If
				TArray(2,N) = 0
				NN = NN + 1
				If NN >= ExitN Then Exit For
			End If
		Next
		If NN > 0 Then
			Application.Lock
			Application(DEF_MasterCookies & "BoardInfo" & 0 & "_TI") = TArray
			Application.UnLock
		End If
	End If

End Sub

Function CheckAnnouceValue

	GBL_CHK_TempStr = ""
	If CheckWriteEventSpace() = 0 Then
		GBL_CHK_TempStr = GBL_CHK_TempStr & "您在修改资料的过程中提交得太频，请稍候再作提交! <br>" & VbCrLf
		GBL_CHK_Flag = 0
		Exit Function
	End If

	If DEF_EnableAttestNumber > 2 and (DEF_AttestNumberPoints = 0 or GBL_CHK_Points < DEF_AttestNumberPoints) Then
		If CheckRndNumber() = 0 Then
			GBL_CHK_TempStr = "<b><font color=ff0000>验证码填写错误!</font></b><br>"
			GBL_CHK_Flag = 0
			Exit Function
		End If
	End If

	If GBL_BoardMasterFlag < 5 or isNumeric(Form_TitleStyle) = 0 then
		Form_TitleStyle = Form_TitleStyle_Old
		If Form_TitleStyle >= 60 Then Form_TitleStyle = Form_TitleStyle - 60
		If Form_TitleStyle <> Form_TitleStyle_Old and (cCur(Form_TitleStyle) + 60) <> cCur(Form_TitleStyle_Old) Then
			Form_TitleStyle = 0
		End If
	Else
		Form_TitleStyle = fix(cCur(Form_TitleStyle))
		If Form_TitleStyle < 0 or Form_TitleStyle > 8 Then Form_TitleStyle = 0
	End If
	If Form_TitleStyle = 1 and GBL_BoardMasterFlag <9 and ((Form_TitleStyle_Old <> 1 and Form_TitleStyle_Old <> 61) or Form_Title <> Form_Title_Old) then Form_TitleStyle = 0
	If Form_TitleStyle_Old >= 60 Then Form_TitleStyle = Form_TitleStyle + 60

	If Form_TitleStyle < 60 and GBL_BoardMasterFlag < 4 and GetBinarybit(GBL_Board_BoardLimit,13) = 1 Then
		Form_TitleStyle = Form_TitleStyle + 60
	End If

	Dim SQL_Temp
	If Form_TitleStyle_Old < 60 and GBL_BoardMasterFlag < 9 and (GetBinarybit(GBL_Board_BoardLimit,13) = 1 or GetBinarybit(GBL_Board_BoardLimit,22) = 1) Then
		SQL_Temp = "Insert into LeadBBS_Assessor(BoardID,Title,UserName,NdateTime,AnnounceID,Content,HTMLFlag,TypeFlag) Values(" & _
				GBL_Board_ID & _
				",'" & Replace(Form_Title,"'","''") & "'" & _
				",'" & Replace(Form_UserName,"'","''") & "'" & _
				"," & GetTimeValue(DEF_Now) & ""
		SQL_Temp = SQL_Temp & "," & Form_EditAnnounceID
		SQL_Temp = SQL_Temp & ",'" & Replace(Replace(Form_Content & "","\" & VbCrLf,"\\" & VbCrLf & VbCrLf),"'","''") & "'"
		SQL_Temp = SQL_Temp & "," & Form_htmlflag
		If GetBinarybit(GBL_Board_BoardLimit,13) = 1 Then
			SQL_Temp = SQL_Temp & ",0"
		Else
			SQL_Temp = SQL_Temp & ",1"
		End If
		SQL_Temp = SQL_Temp & ")"
		CALL LDExeCute(SQL_Temp,1)
	End If

	If cCur(Form_ParentID) <> 0 or (GBL_CHK_CachetValue < LMTDEF_NeedCachetValue and GBL_BoardMasterFlag <= 4) or isNumeric(Form_GoodAssort) = 0 Then
		Form_GoodAssort = Form_GoodAssort_Old
	Else
		Form_GoodAssort = fix(cCur(Form_GoodAssort))
		If Form_GoodAssort <> 0 Then
			If CheckGoodAssortID(Form_GoodAssort) = 0 Then
				GBL_CHK_TempStr = "错误，所属专题选择错误.<br>" & VbCrLf
				CheckAnnouceValue = 0
				Exit Function
			End If
		End If
	End If

	If Form_ParentID = 0 and GetBinarybit(GBL_Board_BoardLimit,23) = 1 and Form_GoodAssort < 1 Then
			GBL_CHK_TempStr = "此版面必须选择所属专题.<br>" & VbCrLf
			CheckAnnouceValue = 0
			Exit Function
	End If

	If Len(Form_Content)>LMT_MaxTextLength Then
		If (GBL_UserID>0 and SupervisorFlag = 1) Then
			If Len(Form_Content)>LMT_MaxTextLength*4 Then
				GBL_CHK_TempStr = "错误，帖子内容不能超过" & LMT_MaxTextLength*4 & "字节.<br>" & VbCrLf
				CheckAnnouceValue = 0
				Exit Function
			End If
		Else
			GBL_CHK_TempStr = "错误，帖子内容不能超过" & LMT_MaxTextLength & "字节.<br>" & VbCrLf
			CheckAnnouceValue = 0
			Exit Function
		End If
	End If

	If GBL_UserID<1 Then
		GBL_CHK_TempStr = "密码或用户名错误。<br>" & VbCrLf
		CheckAnnouceValue = 0
		Exit Function
	End If
	If isNumeric(Form_BoardID)=0 Then
		GBL_CHK_TempStr = "发生错误，一切资料需要重发。<br>" & VbCrLf
		CheckAnnouceValue = 0
		Exit Function
	End If
	Form_BoardID = cCur(Form_BoardID)
	If Borad_CheckBoardIDExist(Form_BoardID) = 0 Then
		GBL_CHK_TempStr = "发生错误，一切资料需要重发.<br>" & VbCrLf
		CheckAnnouceValue = 0
		Exit Function
	End If
	
	If isNumeric(Form_EditAnnounceID)=0 Then Form_EditAnnounceID=0
	Form_EditAnnounceID = cCur(Form_EditAnnounceID)
	If Borad_CheckAnnounceIDExist(Form_EditAnnounceID) = 0 Then
		GBL_CHK_TempStr = "发生错误，要编辑的帖子不存在，可以是刚删除或其它原因.<br>" & VbCrLf
		CheckAnnouceValue = 0
		Exit Function
	End If
	
	If Trim(Replace(Replace(Replace(Replace(Form_Title & "","&nbsp;",""),chr(13),""),chr(10),""),chr(0),"")) = "" Then
		GBL_CHK_TempStr = "帖子名称必须填写.<br>" & VbCrLf
		CheckAnnouceValue = 0
		Exit Function
	End If

	If len(Form_Title)>255 Then
		GBL_CHK_TempStr = "帖子名称太长，最多允许255字节.<br>" & VbCrLf
		CheckAnnouceValue = 0
		Exit Function
	End If
	
 	If Trim(Replace(Replace(Form_Content,"&nbsp;",""),VbCrLf,"")) = "" and (Form_ParentID = 0 or LCase(Left(Form_Title,3)) = "re:") Then
		GBL_CHK_TempStr = "必须填写帖子内容信息.<br>" & VbCrLf
		CheckAnnouceValue = 0
		Exit Function
	ElseIf LMTDEF_MinAnnounceLength > 0 Then
		If (Len(Form_Title) < LMTDEF_MinAnnounceLength or inStr(htmlencode(Form_Title),LMT_TopicNameNoHTML) or LCase(Left(Form_Title,3)) = "re:") Then
			If Form_htmlflag = 2 Then
				If Len(Trim(ResumeCode(Replace(Replace(Replace(Replace(Form_Content,VbCrLf,""),chr(13),""),chr(10),""),chr(0),"")))) < LMTDEF_MinAnnounceLength Then
					GBL_CHK_TempStr = "错误，帖子内容信息过短。<br>" & VbCrLf
					CheckAnnouceValue = 0
					Exit Function
				End If
			Else
				If Len(Trim(ResumeCode(Replace(Replace(Replace(Replace(Form_Content,VbCrLf,""),chr(13),""),chr(10),""),chr(0),"")))) < LMTDEF_MinAnnounceLength Then
					GBL_CHK_TempStr = "错误，帖子内容信息过短。<br>" & VbCrLf
					CheckAnnouceValue = 0
					Exit Function
				End If
			End If
		End If
	End If

	If Form_TopicType = 54 and Form_NeedValue > LMT_BuyAnnounceMaxPoints Then
		GBL_CHK_TempStr = "错误，出售帖最多只能标价" & LMT_BuyAnnounceMaxPoints & DEF_PointsName(0) & "。<br>" & VbCrLf
		CheckAnnouceValue = 0
		Exit Function
	End If
	If Form_TopicType = 49 and Form_NeedValue > LMT_BuyAnnounceMaxPoints Then
		GBL_CHK_TempStr = "错误，出售帖最多只能标价" & LMT_BuyAnnounceMaxPoints & DEF_PointsName(1) & "。<br>" & VbCrLf
		CheckAnnouceValue = 0
		Exit Function
	End If

	Dim TempURL,Loop_N,Temp
	If VoteFlag = 1 Then
		If Replace(Form_VoteItem,VbCrLf,"") = "" Then
			GBL_CHK_TempStr = "错误，投票选项必须填写.<br>" & VbCrLf
			CheckAnnouceValue = 0
			Exit Function
		End If
		
		Dim Form_VoteItem_Old
		Form_VoteItem_Old = Form_VoteItem
		Temp = 0
		TempURL = Split(Form_VoteItem,VbCrLf)
		Form_VoteItem = ""
		For Loop_N = 0 to Ubound(TempURL,1)
			TempURL(Loop_N) = Trim(TempURL(Loop_N))
			If TempURL(Loop_N) <> "" Then
				If Len(TempURL(Loop_N)) > 48 Then
					GBL_CHK_TempStr = "错误，投票选项内容太长，不能超过24字.<br>" & VbCrLf
					Form_VoteItem = Form_VoteItem_Old
					CheckAnnouceValue = 0
					Exit Function
				ElseIf StrLength(TempURL(Loop_N)) > 48 Then
					GBL_CHK_TempStr = "错误，投票选项内容太长，不能超过24字.<br>" & VbCrLf
					Form_VoteItem = Form_VoteItem_Old
					CheckAnnouceValue = 0
					Exit Function
				End If
				If Temp > 0 Then
					Form_VoteItem = Form_VoteItem & VbCrLf & TempURL(Loop_N)
				Else
					Form_VoteItem = Form_VoteItem & TempURL(Loop_N)
				End If
				Temp = Temp + 1
				If Temp > DEF_VOTE_MaxNum Then
					GBL_CHK_TempStr = "错误，投票选项不能超过" & DEF_VOTE_MaxNum & "个.<br>" & VbCrLf
					Form_VoteItem = Form_VoteItem_Old
					CheckAnnouceValue = 0
					Exit Function
				End If
			End If
		Next

		If Temp < 2 or Temp < VoteNumber + 1 Then
			GBL_CHK_TempStr = "修改的投票选项不能减少，原来的投票共有" & VoteNumber + 1 & "个选项.<br>" & VbCrLf
			Form_VoteItem = Form_VoteItem_Old
			CheckAnnouceValue = 0
			Exit Function
		End If

		If Left(Form_VoteItem,1) = VbCrLf Then Form_VoteItem = Mid(Form_VoteItem,2)

		If isNumeric(Form_Vote_ExpireDay) = 0 then Form_Vote_ExpireDay = 0
		Form_Vote_ExpireDay = Fix(cCur(Form_Vote_ExpireDay))
		If Form_Vote_ExpireDay < 0 or Form_Vote_ExpireDay > 365 Then
			GBL_CHK_TempStr = "错误，投票到期时间选择错误.<br>" & VbCrLf
			Form_VoteItem = Form_VoteItem_Old
			CheckAnnouceValue = 0
			Exit Function
		End If

		If isNumeric(Form_VoteType) = 0 then Form_VoteType = 0
		Form_VoteType = Fix(cCur(Form_VoteType))
		If Form_VoteType <> 0 and Form_VoteType <> 1 Then
			GBL_CHK_TempStr = "错误，投票类型只能是单选票或多选票.<br>" & VbCrLf
			Form_VoteItem = Form_VoteItem_Old
			CheckAnnouceValue = 0
			Exit Function
		End If
		
		If Form_VoteType = 0 and Form_VoteType_Old = 1 Then
			GBL_CHK_TempStr = "错误，投票类型不能由多选票改为单选票.<br>" & VbCrLf
			Form_VoteItem = Form_VoteItem_Old
			CheckAnnouceValue = 0
			Exit Function
		End If
	End If

	Form_Title = UBB_FiltrateBadWords(Form_Title)

	'If Left(Form_Title,3) = "Re:" and Form_Title <> "Re:" & LMT_TopicNameNoHTML and Form_ParentID <> 0 Then Form_Title = Mid(Form_Title,4)
	'Form_Title = Replace(Replace(Form_Title,chr(13),""),chr(10),"")

	Form_Length = Len(Form_Content)
	If GBL_Board_ForumPass <> "" or GBL_Board_OtherLimit > 0 or GetBinarybit(GBL_Board_BoardLimit,2) = 1 or GetBinarybit(GBL_Board_BoardLimit,7) = 1 Then
	Else
		If Left(Form_Title,3) = "re:" Then
		
			If Form_HTMLFlag = 2 Then
				GBL_CHK_TempStr = Trim(Left(clearUbbcode(Form_Content),20))
			Else
				GBL_CHK_TempStr = Trim(Left(Form_Content,20))
			End If
			If Form_Length > 20 Then GBL_CHK_TempStr = GBL_CHK_TempStr & "..."
			If Replace(Replace(GBL_CHK_TempStr,chr(13),""),chr(10),"") <> "" Then Form_Title = "re:" & GBL_CHK_TempStr
			GBL_CHK_TempStr = ""
		ElseIf Left(Form_Title,3) = "Re:" Then
			GBL_CHK_TempStr = Trim(Left(Form_Content,20))
			If Form_Length > 20 Then GBL_CHK_TempStr = GBL_CHK_TempStr & "..."
			If Replace(Replace(GBL_CHK_TempStr,chr(13),""),chr(10),"") <> "" Then Form_Title = "re:" & GBL_CHK_TempStr
			GBL_CHK_TempStr = ""
		End If
	End If

	If Form_TopicType = 55 Then
		Form_NeedValue = GetUserID(Form_NeedValue)
		If Form_NeedValue = 0 Then
			GBL_CHK_TempStr = "错误，设置了此帖只允许某用户查看，但此用户并不存在。<br>" & VbCrLf
			Form_NeedValue = Left(Form_NeedValue,20)
			CheckAnnouceValue = 0
			Exit Function
		End If
	End If

	Form_Title = Replace(Replace(Form_Title,chr(13),""),chr(10),"")
	CheckAnnouceValue = 1

End Function

Function SaveEditAnnounceValue

	Dim MaxAnnounceID,MaxRootID
	Form_NoUserUnderWriteFlag = cCur(Form_NoUserUnderWriteFlag)
	Form_UnderWriteFlag = cCur(Form_UnderWriteFlag)
	Dim SQL,Rs
	Dim PollString,PollNum
	Dim New_Form_RootID
	Dim TempURL,Loop_N
	
	Form_Content = UBB_FiltrateBadWords(Form_Content) '脏字过滤
	
	If Form_UpFlag = 1 Then
		Dim Upd_FileInfo,UploadSave
		Set UploadSave = New Upload_Save
		UploadSave.Upload_File
		Upd_FileInfo = UploadSave.Upd_FileInfo
		Upd_ErrInfo = UploadSave.Upd_ErrInfo
	End If

	PollNum = 0
	If Form_htmlflag = 2 and Form_TopicType <> 80 and Form_ParentID = 0 and Form_TopicType <> 54 and Form_TopicType <> 49 Then
		If Upd_FileInfo <> 0 Then
			PollNum = Upd_FileInfo
		End If
		PollString = ",PollNum=" & PollNum
	ElseIf Form_TopicType <> 80 and Form_TopicType <> 54 and Form_TopicType <> 49 Then
		PollString = ",PollNum=0"
	End If

	If Form_TopicType <> 80 and Form_TopicType < 60 and Form_ParentID = 0 and Form_TopicType > 0 Then
		Loop_N = inStr(Form_Content,"[HIDDEN]")
		If Loop_N > 0 Then
			TempURL = inStr(Loop_N,Form_Content,"[/HIDDEN]")
			If TempURL > Loop_N + 9 Then
				Form_TopicType = Form_TopicType + 60
			End If
		End If
	End If

	select case DEF_UsedDataBase
		case 0,2:
			Set Rs = LDExeCute("Select Max(RootID) from LeadBBS_Announce where ParentID = 0 and BoardID=" & GBL_Board_ID & " and RootID<" & DEF_BBS_TOPMinID,0)
		case Else
			Set Rs = LDExeCute("Select Max(RootID) from LeadBBS_Topic where BoardID=" & GBL_Board_ID & " and RootID<" & DEF_BBS_TOPMinID,0)
	End select
	If Rs.Eof Then
		MaxRootID = 1
	Else
		MaxRootID = Rs(0)
		If isNull(MaxRootID) or MaxRootID="" Then MaxRootID=1
		MaxRootID = cCur(MaxRootID)
	End If
	Rs.Close
	Set Rs = Nothing

	New_Form_RootID = Form_RootID

	Rem 置顶的帖子编辑一次, 就帖到最顶
	If Form_ParentID=0 and GBL_BoardMasterFlag >= 5 and Form_RootID > DEF_BBS_TOPMinID Then
		'If Form_RootID < cCur(Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID)(11,0)) Then
			select case DEF_UsedDataBase
				case 0,2:
					Set Rs = LDExeCute("Select Max(RootID) from LeadBBS_Announce Where ParentID = 0 and BoardID=" & GBL_Board_ID,0)
				case Else
					Set Rs = LDExeCute("Select Max(RootID) from LeadBBS_Topic Where BoardID=" & GBL_Board_ID,0)
			End select
			If Rs.Eof Then
				New_Form_RootID = DEF_BBS_TOPMinID+1
			Else
				New_Form_RootID = Rs(0)
				If isNull(New_Form_RootID) or New_Form_RootID="" Then New_Form_RootID = DEF_BBS_TOPMinID+1
				New_Form_RootID = cCur(New_Form_RootID)+1
				If New_Form_RootID<DEF_BBS_TOPMinID Then New_Form_RootID=DEF_BBS_TOPMinID
			End If
			Rs.Close
			Set Rs = Nothing
			
			select case DEF_UsedDataBase
				case 0,2:
					SQL = " Update LeadBBS_Announce Set RootID=" & New_Form_RootID & " where ParentID=0 and RootIDBak=" & LMT_RootIDBak
					CALL LDExeCute(SQL,1)
				case Else
					SQL = " Update LeadBBS_Announce Set RootID=" & New_Form_RootID & " where ID=" & LMT_RootIDBak
					CALL LDExeCute(SQL,1)
					SQL = " Update LeadBBS_Topic Set RootID=" & New_Form_RootID & " where ID=" & LMT_RootIDBak
					CALL LDExeCute(SQL,1)
			End select
		'End If
	End If
	If New_Form_RootID<> Form_RootID Then
		UpdateBoardValue(Form_BoardID)
	End If

	SQL = "Update LeadBBS_Announce set Title='" & Replace(Form_Title,"'","''") & "',Content='" & Replace(Form_Content,"'","''") & "',FaceIcon=" & Form_FaceIcon & ",htmlflag=" & Form_htmlflag & ",NotReplay=" & Form_NotReplay & ",UnderWriteFlag=" & Form_UnderWriteFlag &_
	",TopicType=" & Form_TopicType & ",NeedValue=" & Form_NeedValue & ",TitleStyle=" & Form_TitleStyle & ",Length=" & Form_Length & ",GoodAssort=" & Form_GoodAssort & PollString
	If SupervisorFlag = 0 and (Form_UserID <> GBL_UserID or DateDiff("s",RestoreTime(Form_ndatetime),DEF_Now) > DEF_EditAnnounceDelay) Then SQL = SQL & ",OtherInfo='此贴最后由[" & Replace(LeftTrue(GetTrueName(GBL_CHK_User,GBL_CHK_TrueName),63),"'","''") & "#" & GBL_UserID & "]在" & DEF_Now & "编辑过" & "'"
	If ((Form_TopicType = 54 or Form_TopicType = 49 or Form_TopicType = 114 or Form_TopicType = 109) and (Form_TopicType_Old <> 54 and Form_TopicType_Old <> 49 and Form_TopicType_Old <> 114 and Form_TopicType_Old <> 109)) and Form_ParentID = 0 Then SQL = SQL & ",PollNum=0"
	SQL = SQL & " where ID=" & Form_EditAnnounceID
	If inStr(application(DEF_MasterCookies & "TopAncList"),"," & Form_EditAnnounceID & ",") Then
		Call UpdateAnnounceApplicationInfo(LMT_RootIDBak,2,Form_Title,0,0)
		Call UpdateAnnounceApplicationInfo(LMT_RootIDBak,3,Form_FaceIcon,0,0)
		Call UpdateAnnounceApplicationInfo(LMT_RootIDBak,14,Form_TopicType,0,0)
		Call UpdateAnnounceApplicationInfo(LMT_RootIDBak,16,Form_TitleStyle,0,0)
		Call UpdateAnnounceApplicationInfo(LMT_RootIDBak,6,Form_Length,0,0)
		If PollString <> "" Then UpdateAnnounceApplicationInfo LMT_RootIDBak,15,PollNum,0,0
	Else
		If inStr(application(DEF_MasterCookies & "TopAncList" & GBL_Board_BoardAssort),"," & Form_EditAnnounceID & ",") Then
			Call UpdateAnnounceApplicationInfo(LMT_RootIDBak,2,Form_Title,0,GBL_Board_BoardAssort)
			Call UpdateAnnounceApplicationInfo(LMT_RootIDBak,3,Form_FaceIcon,0,GBL_Board_BoardAssort)
			Call UpdateAnnounceApplicationInfo(LMT_RootIDBak,14,Form_TopicType,0,GBL_Board_BoardAssort)
			Call UpdateAnnounceApplicationInfo(LMT_RootIDBak,16,Form_TitleStyle,0,GBL_Board_BoardAssort)
			Call UpdateAnnounceApplicationInfo(LMT_RootIDBak,6,Form_Length,0,GBL_Board_BoardAssort)
			If PollString <> "" Then If PollString <> "" Then UpdateAnnounceApplicationInfo LMT_RootIDBak,15,PollNum,0,GBL_Board_BoardAssort
		End If
	End If

	ChangeGoodAssort Form_GoodAssort_Old,Form_GoodAssort

	'on error resume next
	CALL LDExeCute(SQL,1)

	If Form_ParentID = 0 Then
		If DEF_UsedDataBase = 1 Then
			SQL = "Update LeadBBS_Topic set Title='" & Replace(Form_Title,"'","''") & "',FaceIcon=" & Form_FaceIcon & ",NotReplay=" & Form_NotReplay &_
			",TopicType=" & Form_TopicType & ",NeedValue=" & Form_NeedValue & ",TitleStyle=" & Form_TitleStyle & ",Length=" & Form_Length & ",GoodAssort=" & Form_GoodAssort & PollString
			SQL = SQL & " where ID=" & Form_EditAnnounceID
			CALL LDExeCute(SQL,1)
		End If
		If Form_TitleStyle = 1 Then
			LMT_TopicNameNoHTML = KillHTMLLabel(Form_Title)
		Else
			LMT_TopicNameNoHTML = Form_Title
		End If
		UpdateBoardLastAnnounce()
	ElseIf Form_ParentID > 0 and LMT_RootMaxID = Form_EditAnnounceID Then
		SQL = " Update LeadBBS_Announce Set RootID=" & New_Form_RootID & " where ParentID=0 and RootIDBak=" & LMT_RootIDBak
		If left(Form_Title,3) = "re:" Then Form_Title = Mid(Form_Title,4)
		CALL LDExeCute("Update LeadBBS_Announce Set LastInfo='" & Replace(LeftTrue(Form_Title,50),"'","''") & "' where ID=" & LMT_RootIDBak,1)
	End If
	if err Then
		SaveEditAnnounceValue = 0
		GBL_CHK_TempStr = "错误，服务器太忙或您的文档大太，请重新提交表单!<br>" & VbCrLf
	Else
		SaveEditAnnounceValue = 1
	End If
	
	Rem 下面保存投票选项
	If VoteFlag = 1 Then
		Form_Vote_ExpireDay = cCur(Form_Vote_ExpireDay)
		If Form_Vote_ExpireDay <> 0 Then Form_Vote_ExpireDay = GetTimeValue(DateAdd("d",Form_Vote_ExpireDay,DEF_Now))
		TempURL = Split(Form_VoteItem,VbCrLf)
		For Loop_N = 0 to VoteNumber
			CALL LDExeCute("Update LeadBBS_VoteItem Set VoteType=" & Form_VoteType & ",VoteName='" & Replace(UBB_FiltrateBadWords(TempURL(Loop_N)),"'","''") & "',ExpiresTime=" & Form_Vote_ExpireDay & " where ID=" & VoteGetData(3,Loop_N),1)
		Next
		For Loop_N = VoteNumber + 1 to Ubound(TempURL,1)
			CALL LDExeCute("insert into LeadBBS_VoteItem(AnnounceID,VoteType,VoteName,ExpiresTime) values(" & Form_EditAnnounceID & "," & Form_VoteType & ",'" & Replace(UBB_FiltrateBadWords(TempURL(Loop_N)),"'","''") & "'," & Form_Vote_ExpireDay & ")",1)
		Next
	End If
	
	If Form_UpFlag = 1 Then
		if Form_ParentID = 0 then
			call UploadSave.UpdateUpload(Form_EditAnnounceID,1)
			if extent_content = "" then
				dim sharevideo
				sharevideo = get_videoInfo(form_content)
				extent_content = sharevideo
				call UploadSave.UpdateUpload(Form_EditAnnounceID,1)
			end if
		end if
		Set UploadSave = Nothing
	End If
	
	if Form_HTMLFlag = 2 and Form_remoteEnable = 1 then
		dim remotepicsave
		set remotepicsave = new remote_pic_save
		call remotepicsave.get_remoteImg(Form_content,Form_EditAnnounceID,form_ParentID)
		set remotepicsave = nothing
	end if

End Function

function get_videoInfo(content)

	dim patrn,strng
	Dim regEx, Match, Matches, s
	strng = form_content
	Set regEx = New RegExp
	regEx.IgnoreCase = True
	regEx.Global = True

	patrn = "\[FLASH=([0-9]{1,4}),([0-9]{1,4})\](.+?)\[\/FLASH\]"
	regEx.Pattern = patrn
	if regEx.test(strng) then
		Set Matches = regEx.Execute(strng)
		For Each Match in Matches
			get_videoInfo = "[FLASH=" & toNum(Match.SubMatches(0),320) & "," & toNum(Match.SubMatches(1),240) & "]" & htmlencode(left(Match.SubMatches(2),500)) & "[/FLASH]"
			exit function
		next
	end if

	patrn = "\[FLASH\](.+?)\[\/FLASH\]"
	regEx.Pattern = patrn
	if regEx.test(strng) then
		Set Matches = regEx.Execute(strng)
		For Each Match in Matches
			get_videoInfo = "[FLASH]" & htmlencode(left(Match.SubMatches(0),500)) & "[/FLASH]"
			exit function
		next
	end if

	patrn = "\[FLV=([0-9]{1,4}),([0-9]{1,4})\](.+?)\[\/FLV\]"
	regEx.Pattern = patrn
	if regEx.test(strng) then
		Set Matches = regEx.Execute(strng)
		For Each Match in Matches
			get_videoInfo = "[FLV=" & toNum(Match.SubMatches(0),320) & "," & toNum(Match.SubMatches(1),240) & "]" & htmlencode(left(Match.SubMatches(2),500)) & "[/FLV]"
			exit function
		next
	end if

	patrn = "\[MP=([0-9]{1,4}),([0-9]{1,4})\](.+?)\[\/MP\]"
	regEx.Pattern = patrn
	if regEx.test(strng) then
		Set Matches = regEx.Execute(strng)
		For Each Match in Matches
			get_videoInfo = "[MP=" & toNum(Match.SubMatches(0),320) & "," & toNum(Match.SubMatches(1),240) & "]" & htmlencode(left(Match.SubMatches(2),500)) & "[/MP]"
			exit function
		next
	end if	

end function

sub UpdateBoardLastAnnounce

	Dim Rs,SQL
	Dim LastAnnounceID
	LastAnnounceID = cCur(Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID)(19,0))

	If LastAnnounceID = Form_EditAnnounceID or LastAnnounceID = LMT_RootIDBak Then
		CALL LDExeCute("Update LeadBBS_Boards Set LastTopicName='" & Replace(LMT_TopicNameNoHTML,"'","''") & "' where BoardID=" & Form_BoardID,1)
		Call UpdateBoardApplicationInfo(Form_BoardID,LMT_TopicNameNoHTML,20)
	End If

End sub

Sub UpdateAnnounceApplicationInfo(AncID,IndexN,Value,tp,tid)

	Dim GetDataTop,AllTopNum,N,Str
	If tid = 0 Then
		Str = ""
	Else
		Str = tid
	End if
	AllTopNum = -1
	GetDataTop = Application(DEF_MasterCookies & "TopAnc" & Str)
	If isArray(GetDataTop) = False Then
		'If GetDataTop <> "yes" Then ReloadTopAnnounceInfo(tid)
		Exit Sub
	Else
		AllTopNum = Ubound(GetDataTop,2)
	End If

	For N = 0 to AllTopNum
		If cCur(AncID) = cCur(GetDataTop(0,N)) Then
			If tp = 1 Then
				GetDataTop(IndexN,N) = cCur(GetDataTop(IndexN,N)) + Value
			Else
				GetDataTop(IndexN,N) = Value
			End If
			Application.Lock
			Application(DEF_MasterCookies & "TopAnc" & Str) = GetDataTop
			Application.UnLock
			Exit Sub
		End If
	Next

End Sub

Function DisplayAnnounceAccessfull

Global_TableHead%>
<div class=contentbox>
		<table border=0 cellpadding=0 cellspacing=0 width="100%" class=tablebox>
		<tr class=tbhead>
			<td><div class=value>已经成功编辑版面“<%=GBL_Board_BoardName%>”中的帖子，您可以选择以下操作：</div></td>
		</tr>
		<tr>
			<td class=tdright>
			<br>
			<%If Upd_ErrInfo <> "" Then Response.Write "<font color=Red class=redfont>" & Upd_ErrInfo & "</font><br>"%>
			页面将在1秒后自动返回您所编辑的帖子，可以继续选择以下操作：<br>
				<script type="text/javascript">
				function a_topage()
				{
					this.location.href = "<%					
					Dim Url : Url = ""
					If LMT_RootIDBak <> Form_EditAnnounceID Then Url = "RID=" & Form_EditAnnounceID & "#F" & Form_EditAnnounceID
					response.write RW_a(GBL_Board_ID,LMT_RootIDBak,1,1,Url)
					%>"; 
				}
				setTimeout("a_topage()",1000);
				</script>
				<ul>
					<li><a href="<%=DEF_BBS_HomeUrl%>Boards.asp">返回首页</a></li>
					<li>返回<a href="<%=DEF_BBS_HomeUrl%>b/<%=RW_b(GBL_Board_ID,0,"")%>"><%=GBL_Board_BoardName%></a>论坛</li>
					<li>到<a href="<%=RW_a(GBL_Board_ID,LMT_RootIDBak,1,1,url)%>">刚编辑的帖子</a></li>
					<li>到<a href="<%=RW_a(GBL_Board_ID,LMT_RootIDBak,1,1,"")%>">刚编辑的主题</a></li>
				</ul>
			</td>
		</tr>		
		</table>
</div>
<%
	Global_TableBottom()

End Function

Function GetTopicInfo

	If GBL_UserID < 1 Then
		GetTopicInfo = 0
		GBL_CHK_TempStr = "错误, 游客不能编辑帖子!<br>" & VbCrLf
		Exit Function
	End If

	Dim Rs,SQL

	SQL = "Select RootID,Title,BoardID,RootIDBak,TitleStyle,ParentID,HTMLFlag,Opinion,Content,FaceIcon,ndatetime,Length,UserName,UserID,UnderWriteFlag,NotReplay,TopicType,NeedValue,GoodAssort from LeadBBS_Announce where ID=" & Form_EditAnnounceID
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		LMT_RootIDBak = 0
		Rs.Close
		Set Rs = Nothing
		GBL_CHK_TempStr = "错误,该主题不存在!<br>" & VbCrLf
		Exit Function
	Else
		Form_BoardID = cCur(Rs("BoardID"))
		Form_UserID = cCur(Rs("UserID"))
		Form_UserName = Rs("UserName")
		If Form_BoardID <> GBL_Board_ID Then
			LMT_RootIDBak = 0
			GBL_CHK_TempStr = "错误,该主题不存在!<br>" & VbCrLf
			Rs.close
			Set Rs = Nothing
			Exit function
		End If

		If CheckSupervisorNameOnly() = 0 and ((GBL_BoardMasterFlag < 5 and Form_UserID <> GBL_UserID) or (CheckLimitNameOnly(Form_UserName) = 1 and GBL_BoardMasterFlag < 9)) Then
			GetTopicInfo = 0
			GBL_CHK_TempStr = "错误, 您没有权限编辑此帖!<br>" & VbCrLf
			Rs.Close
			Set Rs = Nothing
			Exit Function
		End If

		Form_ParentID = cCur(Rs("ParentID"))
		Form_RootID = cCur(Rs("RootID"))
		Form_Title = Rs("Title")
		Form_Title_Old = Form_Title
		Form_HTMLFlag = cCur(Rs("HTMLFlag"))

		Form_FaceIcon = cCur(Rs("FaceIcon"))
		Form_ndatetime = cCur(Rs("ndatetime"))
		Form_UnderWriteFlag = Rs("UnderWriteFlag")
		Form_NotReplay = Rs("NotReplay")
		Form_Topictype = Rs("TopicType")
		If Form_Topictype <> 80 and Form_Topictype > 60 Then Form_Topictype = Form_Topictype - 60
		Form_Topictype_Old = Form_Topictype
		Form_NeedValue = cCur(Rs("NeedValue"))
		Form_Root_TopicType = Form_Topictype
		Form_Root_NeedValue = Form_NeedValue
		Form_TitleStyle = Rs("TitleStyle")
		Form_TitleStyle_Old = Form_TitleStyle
		If Form_TitleStyle >= 60 Then Form_TitleStyle = Form_TitleStyle - 60
		Form_GoodAssort = cCur(Rs("GoodAssort"))
		Form_GoodAssort_Old = Form_GoodAssort
		If isNull(Form_Topictype) Then Form_Topictype = 0
		If isNull(Form_NeedValue) Then Form_NeedValue = 0
		Form_Content = Rs("Content")
		
		LMT_TopicName = Form_Title
		LMT_RootIDBak = cCur(RS("RootIDBak"))
		LMT_TopicTitleStyle = Rs("TitleStyle")

		If Form_Topictype = 39 Then
			GBL_CHK_TempStr = "镜像帖无法编辑。<br>" & VbCrLf
			GetTopicInfo = 0
			Exit Function
		End If
		
		If (Form_Topictype = 55 and cCur(Form_NeedValue) > 0) Then
			If Form_NeedValue <> GBL_UserID and GBL_UserID <> Form_UserID Then
				GBL_CHK_TempStr = "隐私帖子不允许他人编辑。<br>" & VbCrLf
				Rs.Close
				Set Rs = Nothing
				GetTopicInfo = 0
				Exit Function
			End If
		End If
		If DEF_EditAnnounceExpires > 0 and GBL_BoardMasterFlag < 4 and DateDiff("s",RestoreTime(Form_ndatetime),DEF_Now) > DEF_EditAnnounceExpires Then
			GBL_CHK_TempStr = "此帖子已经超过了允许编辑的最大期限。<br>" & VbCrLf
			Rs.Close
			Set Rs = Nothing
			GetTopicInfo = 0
			Exit Function
		End If
		Rs.close
		Set Rs = Nothing
	End If

	If Form_ParentID <> 0 Then
		select case DEF_UsedDataBase
			case 0,2:
				SQL = sql_select("Select Title,BoardID,RootIDBak,TitleStyle,RootMaxID,RootMinID,TopicType,NeedValue from LeadBBS_Announce where ParentID=0 and RootIDBak=" & LMT_RootIDBak,1)
			case Else
				SQL = sql_select("Select Title,BoardID,ID,TitleStyle,RootMaxID,RootMinID,TopicType,NeedValue from LeadBBS_Topic where ID=" & LMT_RootIDBak,1)
		End select
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			LMT_RootIDBak = 0
			Rs.Close
			Set Rs = Nothing
			GBL_CHK_TempStr = "错误,该主题不存在!<br>" & VbCrLf
			Exit Function
		End If
		If Form_BoardID <> GBL_Board_ID Then
			LMT_RootIDBak = 0
			GBL_CHK_TempStr = "错误,该主题不存在!<br>" & VbCrLf
			Rs.close
			Set Rs = Nothing
			Exit function
		Else
			LMT_TopicName = Rs(0)
			LMT_RootIDBak = cCur(RS(2))
			LMT_TopicTitleStyle = Rs(3)
			If isNull(LMT_RootIDBak) then LMT_RootIDBak = 0
			LMT_RootMaxID = cCur(Rs(4))
			LMT_RootMinID = cCur(Rs(5))
			Form_Root_TopicType = cCur(Rs(6))
			Form_Root_NeedValue = cCur(Rs(7))
			Rs.Close
			Set Rs = Nothing
		End If
	End If
	If (Form_Root_Topictype = 55 and cCur(Form_Root_NeedValue) > 0) Then
		If Form_Root_NeedValue <> GBL_UserID and GBL_UserID <> Form_UserID Then
			GBL_CHK_TempStr = "此主题及相关回复已限制他人编辑。<br>" & VbCrLf
			GetTopicInfo = 0
			Exit Function
		End If
	End If

	If GBL_BoardMasterFlag >= 7 and Form_Topictype = 80 and Form_ParentID = 0 Then VoteFlag = 1
	If VoteFlag = 1 Then
		SQL = sql_select("Select VoteName,VoteType,ExpiresTime,ID from LeadBBS_VoteItem where AnnounceID=" & Form_EditAnnounceID,DEF_VOTE_MaxNum)
		Set Rs = LDExeCute(SQL,0)
		If Not Rs.Eof Then VoteGetData = Rs.GetRows(DEF_VOTE_MaxNum)
		Rs.Close
		Set Rs = Nothing
		VoteNumber = 0
		Form_VoteType = 0
		Form_VoteType_Old = 0
		Form_Vote_ExpireDay = 0
		If isArray(VoteGetData) Then
			VoteNumber = Ubound(VoteGetData,2)
			if VoteGetData(1,0) Then
				Form_VoteType = 1
			Else
				Form_VoteType = 0
			end if
			If Form_VoteType = 1 Then
				Form_VoteType = 1
			Else
				Form_VoteType = 0
			End If
			Form_VoteType_Old = Form_VoteType
			If cCur(VoteGetData(2,0)) = 0 Then
				Form_Vote_ExpireDay = 0
			Else
				Form_Vote_ExpireDay = DateDiff("d",DEF_Now,RestoreTime(VoteGetData(2,0)))
			End If
			Form_VoteItem = VoteGetData(0,0)
			For SQL = 1 to VoteNumber
				Form_VoteItem = Form_VoteItem & VbCrLf & VoteGetData(0,SQL)
			Next
		End If
	End If
	If Form_TitleStyle_Old >= 30 and Form_TitleStyle_Old <= 60 Then GBL_CHK_TempStr = "该帖子已经禁止编辑！<br>" & VbCrLf

End Function

Sub Main

	initDatabase()
	if CheckSupervisorNameOnly() = 1 and gbl_userid > 0 then
		SupervisorFlag = 1
	else
		SupervisorFlag = 0
	end if
	CheckisBoardMaster()
	Get_PublicValue()
	
	Select Case Form_EditAnnounceID
		Case -1:
			BBS_SiteHead DEF_SiteNameString & " - " & KillHTMLLabel(GBL_Board_BoardName) & " - 设置版块公告",GBL_board_ID,"设置版块公告"
			Boards_Body_Head("")
			dim classeditboardintro
			set classeditboardintro = new class_editboardintro
			classeditboardintro.Edit_BoardInfo
			set classeditboardintro = nothing
			If Form_UpFlag = 1 Then Set Form_UpClass = Nothing
			closeDataBase()
			Boards_Body_Bottom()
			SiteBottom()
			Exit Sub
	End Select
	
	GetTopicInfo()
	
	If GetBinarybit(GBL_Board_BoardLimit,16) = 1 Then
		If LMT_DefaultEdit = 1 Then
			LMT_DefaultEdit = 0
		Else
			LMT_DefaultEdit = 1
		End If
	End If

	If LMT_TopicTitleStyle = 1 Then
		LMT_TopicNameNoHTML = KillHTMLLabel(LMT_TopicName)
	Else
		LMT_TopicNameNoHTML = LMT_TopicName
	End If
	Temp = htmlencode(LMT_TopicNameNoHTML)
	Dim Temp
	
	If Temp = "" Then
		Temp = "编辑帖子"
	Else
		If strLength(Temp)>DEF_BBS_DisplayTopicLength-5 Then
			LMT_TopicNameNoHTML_Temp = htmlencode(LeftTrue(Temp,DEF_BBS_DisplayTopicLength-8)) & "..."
			Temp = "编辑：" & LMT_TopicNameNoHTML_Temp
		Else
			LMT_TopicNameNoHTML_Temp = htmlencode(Temp)
			Temp = "编辑：" & LMT_TopicNameNoHTML_Temp
		End if
	End If
	BBS_SiteHead DEF_SiteNameString & " - " & KillHTMLLabel(GBL_Board_BoardName) & " - 编辑帖子",GBL_board_ID,"编辑帖子"
	UpdateOnlineUserAtInfo GBL_board_ID,GBL_Board_BoardName & "→" & Temp
	
	Boards_Body_Head("")
	CheckAccessLimit()
	CheckAccessLimit_TimeLimit()
	CheckBoardModifyLimit()
	CheckUserModifyLimit()

	If Form_Submitflag = "" and Form_EditAnnounceID > 0 Then
		%>
		<div class="a_editanc_nav fire">
			<ul>
			<li><a href="../a/a2.asp?B=<%=GBL_board_ID%>"><b>发表新帖</b></a></li>
			<li><a href="../b/<%=RW_b(GBL_Board_ID,0,"")%>">讨论区</a></li>
			<li><a href="../b/<%=RW_b(GBL_Board_ID,0,"e=1")%>">精华区</a></li>
			<li><a href="<%=RW_a(GBL_Board_ID,Form_EditAnnounceID,1,1,"")%>">返回帖子</a></li>
			</ul>
		</div><%
	End If
	If GBL_CHK_TempStr <> "" Then
		Global_ErrMsg GBL_CHK_TempStr
	Else
		EditFlag = 1		
		LMT_Upload_ExtendID = Form_EditAnnounceID
		GetAncUploaInfo()
		If Form_Submitflag <> "slzOowl_kdO8m610" Then
			DisplayAnnounceForm()
		Else
			GetRequestValue()
			If CheckAnnouceValue() = 1 Then
				If SaveEditAnnounceValue() = 1 Then
					If SupervisorFlag = 0 Then
						CALL LDExeCute("Update LeadBBS_User Set LastWriteTime=" & GetTimeValue(DEF_Now) & " where ID=" & GBL_UserID,1)
						UpdateSessionValue 13,GetTimeValue(DEF_Now),0
					End If
					DisplayAnnounceAccessfull()
				Else
					Global_ErrMsg GBL_CHK_TempStr
					DisplayAnnounceForm()
				End If
			Else
				Global_ErrMsg GBL_CHK_TempStr
				DisplayAnnounceForm()
			End If
		End If
	End If
	If Form_UpFlag = 1 Then Set Form_UpClass = Nothing
	closeDataBase()
	Boards_Body_Bottom()
	SiteBottom()

End Sub

Main()
%>