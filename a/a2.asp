<!-- #include file=../inc/BBSsetup.asp -->
<!-- #include file=../inc/User_Setup.ASP -->
<!-- #include file=../inc/Ubbcode.asp -->
<!-- #include file=../inc/Board_Popfun.asp -->
<!-- #include file=../inc/Constellation.asp -->
<!-- #include file=inc/MakeAnnounceTop.asp -->
<!-- #include file=../inc/Limit_Fun.asp -->
<%DEF_BBS_HomeUrl = "../"%>
<!-- #include file=inc/Editor_Fun.asp -->
<!-- #include file=../inc/Upload_Fun.asp -->
<!-- #include file=inc/upload1_fun.asp -->
<!-- #include file=../User/inc/Fun_SendMessage.asp -->
<!-- #include file=../app/qqlogin/oauth.asp -->
<!-- #include file=../User/inc/Bind_Fun.asp -->
<!-- #include file=inc/get_remote_pic_fun.asp -->
<%
Const LMT_EnableOtherGuestName = 0 '开放论坛是否允许使用"游客"以外的名字
Const LMT_BuyAnnounceMaxPoints = 9 '购买帖消耗的最大积分

Dim LMT_EnableUpload
Const LMTDEF_MaxReAnnounce = 1500 '允许的最大回复帖数
Const LMTDEF_MinAnnounceLength = 2 '发帖需要最少字数
Const LMTDEF_NotReplyDate = 120 '最后回复时间至今高于多少天的帖子则禁止回复,对版主及以上无效
Const LMTDEF_NeedCachetValue = 1 '设定多少威望用户可以自己归类专题(发帖时)
Const LMTDEF_ColorSpend = 1 '设定帖子颜色消耗多少财富值
Const LMTDEF_RepostMsg = 2 '回复帖子是否默认短消息通知帖主,0．默认不通知 1.回复全部通知 2.仅被引用时才通知

Dim A_NotReplay
Dim Re_ID,Form_TopicSortID,Form_BoardID,Form_RootID
Dim Form_RootMaxID
Dim Form_Layer,Form_Title,Form_Content,Form_FaceIcon,Form_ndatetime,Form_LastTime
Dim Form_Length,Form_UserName,Form_UserID,Form_HTMLFlag,Form_UnderWriteFlag
Dim Form_UserPass,Form_NoUserUnderWriteFlag,Form_NotReplay
Dim Form_AnnounceIsTopFlag,Form_FaceUrl,Form_FaceWidth,Form_FaceHeight
Dim Form_TopicType,Form_NeedValue,Form_GoodAssort
Dim RootTopicType
Dim Form_VoteFlag,Form_VoteItem,Form_Vote_ExpireDay,Form_VoteType,Form_TitleStyle,Form_PollNum
Dim Form_Opinion,Form_Color,Form_ForumNumber
Dim Form_UpClass,Form_UpFlag,Form_Submitflag,Form_Hits
Form_Vote_ExpireDay = 0
Form_VoteType = 0
Form_TitleStyle = 0
Form_NoUserUnderWriteFlag = 1
Form_GoodAssort = 0
Form_Layer = 0
Form_TopicSortID = 0

Dim LMT_RootID,LMT_TopicName,LMT_ChildNum,LMT_RootIDBak,LMT_TopicTitleStyle,LMT_TopicNameNoHTML,LMT_LastInfo,LMT_TopicNameNoHTML_Temp,Topic_UserName,LMT_ReName
Dim Upd_ErrInfo
Dim Form_EditAnnounceID
Form_EditAnnounceID = 0

Dim AjaxFlag : AjaxFlag = 0
Dim AjaxFlagPrint : AjaxFlagPrint = ""

LMT_RootIDBak = 0

Form_HTMLFlag = 2

const PageSplitNum = 10

Rem 新发表帖子的ＩＤ号
Dim NewAnnounceID
NewAnnounceID = 0

rem 取后更新的用户信息 格式　(用户名|昵称#用户ID)
Dim GET_LastUser

dim Form_remoteEnable : Form_remoteEnable = 0

Function DisplayAnnounceForm

	Dim Temp
	Temp = GBL_CHK_TempStr
	GBL_CHK_TempStr = ""
	If Re_ID = 0 Then
		CheckBoardAnnounceLimit
	Else
		CheckBoardReAnnounceLimit
	End If
	CheckUserAnnounceLimit
	If GBL_CHK_TempStr <> "" Then Exit Function
	If A_NotReplay = 1 Then Exit Function
%>
<script language=javascript>
<!--
var ValidationPassed = true,submitflag=0;

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
	ValidationPassed = true;
	submit_disable(theform);
}

//-->
</script>
<%If Form_Submitflag = "" and Re_ID > 0 Then%><img src=../images/null.gif height=4 width=2><br><%End If

DisplayPreview

If AjaxFlag = 0 Then Global_TableHead%>
<div class=contentbox>
<%
LMT_EnableUpload = 1
If GBL_UserID < 1 Then LMT_EnableUpload = 0
Select Case DEF_EnableUpload
	Case 0: LMT_EnableUpload = 0
	case 2: If CheckSupervisorUserName = 0 Then LMT_EnableUpload = 0
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
		<table border=0 cellpadding=0 cellspacing=0 width="100%" class=tablebox>
		<tr class=tbhead>
			<td><div class=value><%
			If cCur(Re_ID)=0 Then
				If Form_VoteFlag <> "" and Re_ID = 0 Then
					Response.Write "发表新投票 注意: *为必填项"
				Else
					Response.Write "发表新主题 *为必填项"
				End If
			Else
				Response.Write LMT_TopicNameNoHTML_Temp
			End If
			If GBL_BoardMasterFlag < 4 and GetBinarybit(GBL_Board_BoardLimit,13) = 1 Then
				Response.Write "<b>，你在此版发表的帖子需要等待管理员审核才能正常显示。</b>"
			End If%></div>
			</td>
		</tr>
		</table>
		<!-- #include file=inc/post_layer.asp -->
		<%If LMT_EnableUpload = 0 Then %>
		<form action=a2.asp method=post id=LeadBBSFm name=LeadBBSFm onsubmit="submitonce(this);return ValidationPassed;">
		<%Else%>
		<form action="a2.asp?dontRequestFormFlag=1" ID=LeadBBSFm name=LeadBBSFm method="post" enctype="multipart/form-data" onsubmit="submitonce(this);if(ValidationPassed)Upl_submit();return ValidationPassed;">
		<%End If%>
		<table border=0 cellpadding=0 cellspacing=0 width="100%" class=tablebox><%
		If GBL_UserID = 0 Then%>
		<tr>
			<td width="<%=DEF_BBS_LeftTDWidth%>" class=tdleft>*用户名</td>
			<td class=tdright>
				<input maxlength=20 name=User type="text" value="<%=htmlencode(Form_UserName)%>" size="20" class='fminpt input_2'> <%
				If GBL_CHK_User = "" Then
					%>没有注册的<a href=../User/<%=DEF_RegisterFile%>>点击这里注册</a>新用户<%
				End If
				If GetBinarybit(GBL_Board_BoardLimit,9) = 1 Then%> 可以不填写<%End If%></td>
                </tr>
        	<tr>
			<td width="<%=DEF_BBS_LeftTDWidth%>" class=tdleft>密码</td>
			<td class=tdright>
				<input maxlength=20 type=password name=Pass value="<%'=htmlencode(Form_UserPass)%>" size="20" class='fminpt input_2'><%
				If GetBinarybit(GBL_Board_BoardLimit,9) = 1 Then%> 可以不填写<%End If%>
			</td>
		</tr><%
		End If%>
		<tr>
			<td width="<%=DEF_BBS_LeftTDWidth%>" class=tdleft>
				<input name=test value="testvalue" type=hidden>
				<%If Re_ID = 0 Then
					%>
					<input id="Form_Color" name="Form_Color" value="<%=Form_Color%>" type="hidden" />
					<div style="float:left">标题 <span class="bluefont" title="现有财富:<%=GBL_CHK_CharmPoint%>">花<%=LMTDEF_ColorSpend & DEF_PointsName(1)%>增色</span></div>
					<%If GBL_CHK_CharmPoint >= LMTDEF_ColorSpend Then%>
					<div class="layer_item" style="float:left">
						<div id="Form_Color_view" class="layer_item_title color_pannel" style="BACKGROUND-COLOR:<%=Form_Color%>;">选择</div>
					<div class="layer_iteminfo" onclick="this.style.display='none';">
					<ul class="color_list">
					<script type="text/javascript">
					function titlecolor_set(co)
					{
						if(co=="")
						{
							$id("Form_Color").value="";
							$id("Form_Color_view").style.color = "";
							$id("Form_Color_view").style.backgroundColor = "";
							return;
						}
						$id("Form_Color").value="#" + co;
						var r = parseInt(co.substr(0,2),16);
						var g = parseInt(co.substr(2,2),16);
						var b = parseInt(co.substr(4,2),16);
						var tmp = "RGB(" + (256+~r) + "," + (256+~g) + "," + (256+~b) + ")";
						$id("Form_Color_view").style.color = tmp;
						$id("Form_Color_view").style.backgroundColor = "#" + co;
					}
					var Color_n,Color_l,Color_str = "f0f8ff faebd7 00ffff 7fffd4 f0ffff f5f5dc ffe4c4 ffebcd 0000ff 8a2be2 a52a2a deb887 5f9ea0 7fff00 d2691e ff7f50 000000 1e90ff 696969 6495ed fff8dc dc143c 00ffff 00008b 008b8b b8860b a9a9a9 006400 bdb76b 8b008b 556b2f ff8c00 9932cc 8b0000 e9967a 8fbc8f 483d8b 2f4f4f 00ced1 9400d3 ff1493 00bfff b22222 fffaf0 228b22 ff00ff dcdcdc f8f8ff ffd700 daa520 808080 008000 adff2f f0fff0 ff69b4 cd5c5c 4b0082 fffff0 f0e68c e6e6fa fff0f5 7cfc00 fffacd add8e6 f08080 e0ffff fafad2 90ee90 d3d3d3 ffb6c1 ffa07a 20b2aa 87cefa 778899 b0c4de ffffe0 00ff00 32cd32 faf0e6 ff00ff 800000 66cdaa 0000cd ba55d3 9370db 3cb371 7b68ee 00fa9a 48d1cc c71585 191970 f5fffa ffe4e1 ffe4b5 ffdead 000080 fdf5e6 808000 6b8e23 ffa500 ff4500 da70d6 eee8aa 98fb98 afeeee db7093 ffefd5 ffdab9 cd853f ffc0cb dda0dd b0e0e6 800080 ff0000 bc8f8f 4169e1 8b4513 fa8072 f4a460 2e8b57 fff5ee a0522d c0c0c0 87ceeb 6a5acd 708090 fffafa 00ff7f 4682b4 d2b48c 008080 d8bfd8 ff6347 40e0d0 ee82ee f5deb3 ffffff f5f5f5 ffff00 9acd32";
					Color_str=Color_str.split(" ");
					Color_l=Color_str.length;
					for(Color_n=0;Color_n<Color_l;Color_n++)
					if("#"+Color_str[Color_n]=="<%=Form_Color%>")
					document.write("<li style='COLOR: #" + Color_str[Color_n] + "; BACKGROUND-COLOR: #" + Color_str[Color_n] + "' onclick='titlecolor_set(\"" + Color_str[Color_n] + "\")'></li>");
					else
					document.write("<li style='COLOR: #" + Color_str[Color_n] + "; BACKGROUND-COLOR: #" + Color_str[Color_n] + "' onclick='titlecolor_set(\"" + Color_str[Color_n] + "\")'></li>");
					</script>
					<li onclick="titlecolor_set('');" style="width:90%;margin:6px 0px 0px 0px;"><span style="WHITE-SPACE: nowrap;font-size:9pt;">取消选择</span></li>
					</ul>
					</div>
					</div>
					<%
					Else%>
					<div id="Form_Color_view" class="layer_item_title color_pannel" style="BACKGROUND-COLOR:<%=Form_Color%>;"><span class="grayfont">选择</span></div>
					<%
					End If%><%
				Else
					%>帖子标题<%
				End If%>
				</td>
			<td class=tdright>
				<input name=submitflag value="true" type=hidden>
				<input name=VoteFlag value="<%=htmlencode(Form_VoteFlag)%>" type=hidden>
				<input name=BoardID value="<%=Form_BoardID%>" type=hidden>
				<input name=ID value="<%=Re_ID%>" type=hidden><%If Form_VoteFlag = "" Then%>
				<input tabindex="1" maxlength=255 type="text" id=Form_Title name=Form_Title size="49" value="<%
				If (Form_Submitflag = "first" or Form_Submitflag = "") and Re_ID > 0 and Form_Title="" Then
					If Left(LMT_TopicName,3) <> "Re:" Then
						Response.Write "Re:" & htmlencode(LMT_TopicNameNoHTML)
					Else
						Response.Write htmlencode(LMT_TopicNameNoHTML)
					End If
				Else
					Response.Write htmlencode(Form_title)
				End If%>" class='fminpt input_4'><%Else%>
				<input tabindex="1" maxlength=255 id=Form_Title name=Form_Title size="35" value="<%=htmlencode(Form_Title)%>" class='fminpt input_4'>
				<%If isNumeric(Form_Vote_ExpireDay) = 0 then Form_Vote_ExpireDay = 0
				Form_Vote_ExpireDay = cCur(Form_Vote_ExpireDay)%>
				<select name="Form_Vote_ExpireDay">
					<option value=0>到期时间
					<option value=0<%If Form_Vote_ExpireDay = 0 Then Response.Write " selected"%>>永不到期
					<option value=1<%If Form_Vote_ExpireDay = 1 Then Response.Write " selected"%>>一天
					<option value=2<%If Form_Vote_ExpireDay = 2 Then Response.Write " selected"%>>两天
					<option value=3<%If Form_Vote_ExpireDay = 3 Then Response.Write " selected"%>>三天
					<option value=7<%If Form_Vote_ExpireDay = 7 Then Response.Write " selected"%>>一周
					<option value=10<%If Form_Vote_ExpireDay = 10 Then Response.Write " selected"%>>十天
					<option value=15<%If Form_Vote_ExpireDay = 15 Then Response.Write " selected"%>>半个月
					<option value=20<%If Form_Vote_ExpireDay = 20 Then Response.Write " selected"%>>二十天
					<option value=30<%If Form_Vote_ExpireDay = 30 Then Response.Write " selected"%>>一个月
					<option value=45<%If Form_Vote_ExpireDay = 45 Then Response.Write " selected"%>>一个月半
					<option value=60<%If Form_Vote_ExpireDay = 60 Then Response.Write " selected"%>>二个月
					<option value=90<%If Form_Vote_ExpireDay = 90 Then Response.Write " selected"%>>三个月
					<option value=120<%If Form_Vote_ExpireDay = 120 Then Response.Write " selected"%>>四个月
					<option value=180<%If Form_Vote_ExpireDay = 180 Then Response.Write " selected"%>>六个月
					<option value=240<%If Form_Vote_ExpireDay = 240 Then Response.Write " selected"%>>八个月
					<option value=365<%If Form_Vote_ExpireDay = 365 Then Response.Write " selected"%>>一年
				</select>
				<%End If
				If GBL_BoardMasterFlag >= 5 Then
					If isNumeric(Form_TitleStyle) = 0 then Form_TitleStyle = 0
					Form_TitleStyle = cCur(Form_TitleStyle)
				%>
				<select name="Form_TitleStyle">
					<option value=0<%If Form_TitleStyle = 0 Then Response.Write " selected"%>>样式</option><%If GBL_BoardMasterFlag >= 9 Then%>
					<option value=1<%If Form_TitleStyle = 1 Then Response.Write " selected"%>>HTML</option><%End If%>
					<option value=2<%If Form_TitleStyle = 2 Then Response.Write " selected"%>>红色</option>
					<option value=3<%If Form_TitleStyle = 3 Then Response.Write " selected"%>>绿色</option>
					<option value=4<%If Form_TitleStyle = 4 Then Response.Write " selected"%>>蓝色</option>
					<option value=5<%If Form_TitleStyle = 5 Then Response.Write " selected"%>>加重</option>
					<option value=6<%If Form_TitleStyle = 6 Then Response.Write " selected"%>>重红</option>
					<option value=7<%If Form_TitleStyle = 7 Then Response.Write " selected"%>>重绿</option>
					<option value=8<%If Form_TitleStyle = 8 Then Response.Write " selected"%>>重蓝</option>
				</select>
				<%
				End If

				If cCur(Re_ID)=0 and (GBL_CHK_CachetValue >= LMTDEF_NeedCachetValue or GBL_BoardMasterFlag >= 4) Then
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
					<select name="Form_GoodAssort" style="width:74">
					<%
						If isArray(TArray) = True Then
							Response.Write "<Option value=0>选择专题" & VbCrLf
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
							Response.Write "<Option value=0>=总专题=" & VbCrLf
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
				End If%>
				</td>
		</tr><%If Form_VoteFlag <> "" Then%>
		<tr>
			<td width="<%=DEF_BBS_LeftTDWidth%>" class=tdleft>*投票选项
			<p>每行一个投票选项，最多<%=DEF_VOTE_MaxNum%>个选项，选项最长24字，超过作废，空行过滤
			<p><%If isNumeric(Form_VoteType) = 0 then Form_VoteType = 0
				Form_VoteType = cCur(Form_VoteType)%><table border=0 cellpadding=0 cellspacing=0><tr><td><input class=fmchkbox type=radio name=Form_VoteType value=0 <%If Form_VoteType = 0 Then Response.Write " checked"%>></td><td>单选票</td>
          		<td><input class=fmchkbox type=radio name=Form_VoteType value=1 <%If Form_VoteType = 1 Then Response.Write " checked"%>></td><td>多选票</td></tr></table>
			</td>
			<td class=tdright>
				<textarea tabindex="3" cols=80 name=Form_VoteItem rows=8 style="width: 95%; word-break: break-all;" onkeydown="if(ctlkey(event)==false)return(false);" class=fmtxtra><%If Form_VoteItem <> "" Then Response.Write VbCrLf & htmlEncode(Form_VoteItem)%></textarea>
				</td>
		</tr><%End If%>
		<tr>
			<td width="<%=DEF_BBS_LeftTDWidth%>" class=tdleft>发帖表情</td>
			<td class=tdright>
				<input name=Form_FaceIcon type=radio value=0>无
				<input name=Form_FaceIcon type=radio value=1<%If Form_FaceIcon=1 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE1.GIF" class=absmiddle>
				<input name=Form_FaceIcon type=radio value=2<%If Form_FaceIcon=2 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE2.GIF" class=absmiddle>
				<input name=Form_FaceIcon type=radio value=3<%If Form_FaceIcon=3 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE3.GIF" class=absmiddle>
				<input name=Form_FaceIcon type=radio value=5<%If Form_FaceIcon=5 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE5.GIF" class=absmiddle>
				<input name=Form_FaceIcon type=radio value=6<%If Form_FaceIcon=6 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE6.GIF" class=absmiddle>
				<input name=Form_FaceIcon type=radio value=7<%If Form_FaceIcon=7 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE7.GIF" class=absmiddle>
				<input name=Form_FaceIcon type=radio value=15<%If Form_FaceIcon=15 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE15.GIF" class=absmiddle>
				<input name=Form_FaceIcon type=radio value=16<%If Form_FaceIcon=16 Then Response.WRite " CHECKED"%>><img src="../images/<%=GBL_DefineImage%>bf/FACE16.GIF" class=absmiddle>
			</td>
		</tr><%
		call DisplayLeadBBSEditor1(Form_HTMLFlag,Form_Content,0,1)
		If Re_ID=0 and Form_VoteFlag = "" Then%>
		<tr>
			<td width="<%=DEF_BBS_LeftTDWidth%>" class=tdleft>加密本帖功能</td>
			<td class=tdright>
				<table border="0" cellspacing="0" cellpadding="0" class="blanktable"><tr><td><select name=Form_TopicType onchange="if(this.value<49)$id('NextContactDateDiv').style.display='none';if(this.value>=49)$id('NextContactDateDiv').style.display='block';">
					<option value="0">请选择限制条件...
					<%If DEF_EnableSpecialTopic = 1 and GetBinarybit(GBL_Board_BoardLimit,14) = 1 Then%><option value="7"<%If Form_TopicType = 7 Then Response.Write " selected"%>>回复本帖才能查看<%End If%>
					<option value="50"<%If Form_TopicType = 50 Then Response.Write " selected"%>>查看本帖需要达到<%=DEF_PointsName(0)%>
					<option value="51"<%If Form_TopicType = 51 Then Response.Write " selected"%>>回复本帖需要达到<%=DEF_PointsName(0)%>
					<option value="52"<%If Form_TopicType = 52 Then Response.Write " selected"%>>查看本帖需要达到<%=DEF_PointsName(4)%>
					<option value="53"<%If Form_TopicType = 53 Then Response.Write " selected"%>>回复本帖需要达到<%=DEF_PointsName(4)%>
					<option value="55"<%If Form_TopicType = 55 Then Response.Write " selected"%>>只限指定用户能查看此帖：
					<%If DEF_EnableSpecialTopic = 1 and GetBinarybit(GBL_Board_BoardLimit,14) = 1 Then%>
					<option value="54"<%If Form_TopicType = 54 Then Response.Write " selected"%>>出售本帖，花费<%=DEF_PointsName(0)%>
					<option value="49"<%If Form_TopicType = 49 Then Response.Write " selected"%>>出售本帖，花费<%=DEF_PointsName(1)%><%End If%>
					<option value="1"<%If Form_TopicType = 1 Then Response.Write " selected"%>>仅本版<%=DEF_PointsName(8)%>才能查看
					<option value="2"<%If Form_TopicType = 2 Then Response.Write " selected"%>>仅本版<%=DEF_PointsName(8)%>才能回复
					<option value="3"<%If Form_TopicType = 3 Then Response.Write " selected"%>>仅<%=DEF_PointsName(8)%>才能查看
					<option value="4"<%If Form_TopicType = 4 Then Response.Write " selected"%>>仅<%=DEF_PointsName(8)%>才能回复
					<option value="5"<%If Form_TopicType = 5 Then Response.Write " selected"%>>仅<%=DEF_PointsName(5)%>才能查看
					<option value="6"<%If Form_TopicType = 6 Then Response.Write " selected"%>>仅<%=DEF_PointsName(5)%>才能回复
					</select></td>
				<td>
				<span name=NextContactDateDiv id=NextContactDateDiv<%If Form_TopicType<49 Then Response.Write " style='display:none'"%>>
					&nbsp; <input name=Form_NeedValue value="<%If cStr(Form_NeedValue) <> "0" Then Response.Write htmlencode(Form_NeedValue)%>" size=10 maxlength=10 class='fminpt input_1'></span>
				</td>
				<td>
					&nbsp; <a href=#icon onclick="if(LeadBBSFm.Form_TopicType.value=='0'){alert('在插入隐藏标签前请选择限制条件.');}else{addcontent(0,'HIDDEN','/HIDDEN');}">插入隐藏标签</a></td></tr></table>
		</tr><%End If%>
		<tr>
			<td class=tdleft valign=top>其它选项</td>
			<td class=tdright>
				<table><tr><td>
				<%
				
					Dim ConnetBind
					set ConnetBind = New Connet_Bind
					ConnetBind.BindAnnounceList
					set ConnetBind = nothing
				%></td><td>
				<label>
				<input class=fmchkbox type="checkbox" name="Form_NoUserUnderWriteFlag" value="checkbox"<%If Form_NoUserUnderWriteFlag=1 Then Response.Write " checked"%>>显示签名</label>
				<%If Re_ID=0 and GBL_UserID>0 and GBL_BoardMasterFlag >= 5 and GetBinarybit(GBL_CHK_UserLimit,4) = 0 Then%>
				<label>
				<input class=fmchkbox type="checkbox" name="Form_AnnounceIsTop" value="checkbox"<%If Form_AnnounceIsTopFlag=1 Then Response.Write " checked"%>>帖子置顶</label><%
				End If%>
				<label>
				<input class=fmchkbox type="checkbox" name="Form_NotReplay" value="checkbox"<%If Form_NotReplay=1 Then Response.Write " checked"%>><%If Re_ID=0 Then
					Response.Write "锁定主题</label>"
				Else
					%>锁定帖子</label>
					<label>
					<input class=fmchkbox type="checkbox" name="Form_RepostMsg" value="checkbox"<%
					If GBL_CHK_User = LMT_ReName Then
						Response.Write " disabled=""disabled"""
					ElseIf LMTDEF_RepostMsg=1 or (LMTDEF_RepostMsg=2 and Request.QueryString("repost") = "1") Then
						Response.Write " checked=""checked"""
					End If
					%>>回复短消息通知</label><%
				End If%>
				
				<%if remote_checkEnable = 1 then%>
					<label title="提取非本站的图片并保存至本地,只限UBB格式">
					<input class=fmchkbox type="checkbox" name="Form_remoteEnable" value="1"<%If Form_remoteEnable=1 Then Response.Write " checked"%>>提取非本站图片(最多<%=Remote_MaxGet%>张)
					</label>
				<%end if
				%>
				</td>
				</tr>
				<tr>
				<td colspan="2">
				<%If DEF_EnableAttestNumber > 2 and (DEF_AttestNumberPoints = 0 or GBL_CHK_Points < DEF_AttestNumberPoints) Then%>
				<div style="line-height:400%">验证码
				<%
					Response.Write displayVerifycode%></div><%
				End If%>
				</td></tr>
				</table>
			</td>
		</tr>
		<tr>
			<td class=tdleft>
			<td class=tdright>
				<br />
				<input name=submit2 type=submit value="发表帖子" class="fmbtn btn_3">
				<input id=Preview_btn type=button value="预览帖子" onclick="edt_preview();" class="fmbtn btn_3">
				<br><br>
			</td>
		</tr>
		
		</table>
		</form>
</div>
<%
Global_TableBottom

End Function

Function GetFormData(name)

	If Form_UpFlag = 0 Then
		GetFormData = Request.Form(name)
	Else
		GetFormData = Form_UpClass.form(name)
	End If

End Function

Sub GetBoardID

	If dontRequestFormFlag = "" Then
		Form_UpFlag = 0
	Else
		Form_UpFlag = 1
		Server.ScriptTimeOut=3000
		set Form_UpClass=new upload_Class
		Form_UpClass.ProgressID = Request.QueryString("Upload_ID")
		Form_UpClass.GetUpFile
	End If
	If GBL_Board_ID = 0 Then
		GBL_Board_ID = GetFormData("BoardID")
		If GBL_Board_ID = "" Then GBL_Board_ID = GetFormData("b")
		If GBL_Board_ID = "" Then GBL_Board_ID = Request.QueryString("b")
		GBL_Board_ID = Left(GBL_Board_ID,14)
		If isNumeric(GBL_Board_ID)=0 Then GBL_Board_ID=0
		GBL_Board_ID = Fix(cCur(GBL_Board_ID))
		If GBL_Board_ID > 2147479999 Then GBL_Board_ID = 0
	End If

End Sub

Function GetRequestValue

	dim unicode
	AjaxFlag = toNum(Request.QueryString("ajaxflag"),0)
	If AjaxFlag = 1 Then AjaxFlagPrint = "ajaxflag=1|"
	
	Form_Submitflag = Request.QueryString("submitflag")
	If Form_Submitflag = "" Then Form_Submitflag = GetFormData("submitflag")

	If cStr(Re_ID) = "" Then Re_ID = Left(Request.QueryString("ID"),14)
	If cStr(Re_ID) = "" Then Re_ID = Left(GetFormData("ID"),14)
	If isNumeric(Re_ID) = 0 Then Re_ID = 0
	Re_ID = Fix(cCur(Re_ID))

	If GBL_Board_ID = 0 Then
		GBL_Board_ID = GetFormData("BoardID")
		If GBL_Board_ID = "" Then GBL_Board_ID = GetFormData("b")
		GBL_Board_ID = Left(GBL_Board_ID,14)
		If isNumeric(GBL_Board_ID)=0 Then GBL_Board_ID=0
		GBL_Board_ID = Fix(cCur(GBL_Board_ID))
		If GBL_Board_ID > 2147479999 Then GBL_Board_ID = 0
		If GBL_Board_ID > 0 Then Borad_GetBoardIDValue(GBL_Board_ID)
	End If
	Form_BoardID = GBL_board_ID

	If A_NotReplay = 1 Then Exit Function

	If Form_Submitflag = "true" Then
		Form_Title = Trim(GetFormData("Form_Title"))
		if AjaxFlag = 1 then Form_Title = trim(uniDecode(Form_Title))
		Form_HTMLFlag = GetFormData("Form_HTMLFlag")
		If Form_HTMLFlag="2" Then
			Form_HTMLFlag=2
		ElseIf Form_HTMLFlag = "1" and ((GetBinarybit(GBL_CHK_UserLimit,16) = 1 and GBL_BoardMasterFlag >= 2) or CheckSupervisorUserName = 1) and GBL_UserID > 0 Then
			Form_HTMLFlag = 1
		Else
			Form_HTMLFlag = 0
		End If
		'If Re_ID<>0 and Form_Title = "" Then Form_Title="回复:"
	Else
		Form_HTMLFlag = 2
	End If

	If Form_Submitflag <> "first" Then
		Form_Content = GetFormData("Form_Content")
		if AjaxFlag = 1 then Form_Content = uniDecode(Form_Content)
	End If

	Form_FaceIcon = Left(GetFormData("Form_FaceIcon"),14)
	If isNumeric(Form_FaceIcon) = 0 Then Form_FaceIcon = 0
	Form_FaceIcon = Fix(cCur(Form_FaceIcon))
	If Form_FaceIcon < 0 or Form_FaceIcon > 16 Then Form_FaceIcon = 0

	Form_UserID = GBL_UserID

	Form_UserName = GBL_CHK_User
	'Form_UserPass = GBL_CHK_pass
	
	If Form_Submitflag <> "" and Form_Submitflag <> "first" Then
		Form_NoUserUnderWriteFlag = GetFormData("Form_NoUserUnderWriteFlag")
		If Form_NoUserUnderWriteFlag="checkbox" Then
			Form_NoUserUnderWriteFlag = 1
		Else
			Form_NoUserUnderWriteFlag = 0
		End If
	
		Form_AnnounceIsTopFlag = GetFormData("Form_AnnounceIsTop")
		If Form_AnnounceIsTopFlag="checkbox" Then
			Form_AnnounceIsTopFlag = 1
		Else
			Form_AnnounceIsTopFlag = 0
		End If
		
		Form_remoteEnable = toNum(GetFormData("Form_remoteEnable"),0)
		
		Form_NotReplay = GetFormData("Form_NotReplay")
		If Form_NotReplay <> "" Then 
			Form_NotReplay = 1
		Else
			Form_NotReplay = 0
		End If
	End If

	Form_VoteFlag = Request.QueryString("VoteFlag")
	If Form_VoteFlag = "" Then Form_VoteFlag = Left(GetFormData("VoteFlag"),14)

	If IsNull(Form_TopicType) Then Form_TopicType = 0
	If IsNull(Form_NeedValue) Then Form_NeedValue = 0
	If Re_ID=0 and Form_VoteFlag = "" and Form_TopicType <> 80 Then
		Form_TopicType = Left(GetFormData("Form_TopicType"),14)
		If isNumeric(Form_TopicType) = 0 Then Form_TopicType = 0
		Form_TopicType = cCur(Form_TopicType)
		If Not ((Form_TopicType >=0 and Form_TopicType <=7) or (Form_TopicType>=49 and Form_TopicType<=55)) Then Form_TopicType = 0
		If Form_TopicType = 55 Then
			Form_NeedValue = Left(GetFormData("Form_NeedValue"),20)
		Else
			If Form_TopicType >=49 and Form_TopicType <=54 Then
				Form_NeedValue = Left(GetFormData("Form_NeedValue"),14)
				If isNumeric(Form_NeedValue) = 0 Then Form_NeedValue = 0
				Form_NeedValue = cCur(Form_NeedValue)
				If Form_NeedValue<0 or Form_NeedValue > 999999 Then Form_NeedValue = 0
				If Form_NeedValue = 0 Then Form_TopicType = 0
			Else
				Form_NeedValue = 0
			End If
		End If
		If Form_TopicType = 54 or Form_TopicType = 49 or Form_TopicType = 7 Then
			If DEF_EnableSpecialTopic = 0 or GetBinarybit(GBL_Board_BoardLimit,14) = 0 Then
				Form_TopicType = 0
				Form_NeedValue = 0
			End If
		End If
	Else
		If Form_VoteFlag <> "" and Re_ID=0 Then
			Form_TopicType = 80
		Else
			Form_TopicType = 0
			Form_NeedValue = 0
		End If
	End If
	
	If Form_VoteFlag <> "" and Re_ID=0 Then
		Form_VoteItem = Trim(GetFormData("Form_VoteItem"))
		Form_Vote_ExpireDay = Left(Trim(GetFormData("Form_Vote_ExpireDay")),14)
		Form_VoteType = Left(Trim(GetFormData("Form_VoteType")),14)
	End If
	Form_TitleStyle = Left(GetFormData("Form_TitleStyle"),14)
	Form_GoodAssort = Left(GetFormData("Form_GoodAssort"),14)
	Form_Color = LeftTrue(GetFormData("Form_Color"),7)
	If Form_Color = "--" then Form_Color = ""

	Form_ForumNumber = Left(GetFormData("ForumNumber"),4)

End Function

Function Borad_CheckAnnounceIDExist(ID)

	Borad_CheckAnnounceIDExist = 1
	exit function
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

function GetUserName(UserID)

	Dim Rs,SQL
	SQL = sql_select("Select UserName from LeadBBS_User Where ID=" & UserID,1)
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		GetUserName = ""
	Else
		SQL = Rs(0)
		If isNull(SQL) Then SQL = 0
		GetUserName = SQL
	End If
	Rs.Close
	Set Rs = Nothing

End Function

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

Function Borad_CheckBoardIDExist(ID)

	Dim Temp
	Temp = Application(DEF_MasterCookies & "BoardInfo" & ID)
	If isArray(Temp) = False Then
		ReloadBoardInfo(ID)
		Temp = Application(DEF_MasterCookies & "BoardInfo" & ID)
	End If
	If isArray(Temp) = False Then
		Borad_CheckBoardIDExist = 0
	Else
		Borad_CheckBoardIDExist = 1
	End If

End Function


Rem 检测某用户名是否存在
Function CheckUserNameExist(UserName)

	Dim Rs
	Set Rs=LDExeCute(sql_select("Select ID from LeadBBS_User where UserName='" & Replace(UserName,"'","''") & "'",1),0)
	If Rs.Eof Then
		CheckUserNameExist = 0
	Else
		CheckUserNameExist = 1
	End if
	Rs.Close
	Set Rs = Nothing

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

Sub ChangeGoodAssort(ID)

	If ID = 0 Then Exit Sub
	Dim TArray,Temp
	Temp = GBL_Board_ID
	TArray = Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID & "_TI")
	If isArray(TArray) = False Then
		'ChangeGoodAssort = 0
		Exit Sub
	End If
	If ID <> cCur(TArray(0,LMT_GoodAssortIndex)) Then		
		Temp = 0
		TArray = Application(DEF_MasterCookies & "BoardInfo" & 0 & "_TI")
		If isArray(TArray) = False Then
			'ChangeGoodAssort = 0
			Exit Sub
		End If
	End If
	If cCur(TArray(2,LMT_GoodAssortIndex)) = -1 Then
		TArray(2,LMT_GoodAssortIndex) = 1
		TArray(3,LMT_GoodAssortIndex) = 0
		TArray(4,LMT_GoodAssortIndex) = 0
	Else
		TArray(2,LMT_GoodAssortIndex) = cCur(TArray(2,LMT_GoodAssortIndex)) + 1
		TArray(3,LMT_GoodAssortIndex) = 0
		TArray(4,LMT_GoodAssortIndex) = 0
	End If
	Application.Lock
	Application(DEF_MasterCookies & "BoardInfo" & Temp & "_TI") = TArray
	Application.UnLock

End Sub

Function CheckAnnouceValue

	If A_NotReplay = 1 Then Exit Function

	GBL_CHK_TempStr = ""

	If DEF_EnableAttestNumber > 2 and (DEF_AttestNumberPoints = 0 or GBL_CHK_Points < DEF_AttestNumberPoints) Then
		If CheckRndNumber = 0 Then
			GBL_CHK_TempStr = "<b><font color=ff0000>验证码填写错误!</font></b><br>"
			GBL_CHK_Flag = 0
			Exit Function
		End If
	End If
	If GBL_BoardMasterFlag < 5 or isNumeric(Form_TitleStyle) = 0 then
		Form_TitleStyle = 0
	Else
		Form_TitleStyle = fix(cCur(Form_TitleStyle))
		If Form_TitleStyle < 0 or Form_TitleStyle > 8 Then Form_TitleStyle = 0
		If Form_TitleStyle = 1 and GBL_BoardMasterFlag <9 then Form_TitleStyle = 0
	End If

	If cCur(Re_ID) <> 0 or (GBL_CHK_CachetValue < LMTDEF_NeedCachetValue and GBL_BoardMasterFlag <= 4) or isNumeric(Form_GoodAssort) = 0 Then
		Form_GoodAssort = 0
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

	If Re_ID = 0 and GetBinarybit(GBL_Board_BoardLimit,23) = 1 and Form_GoodAssort < 1 Then
			GBL_CHK_TempStr = "此版面必须选择所属专题.<br>" & VbCrLf
			CheckAnnouceValue = 0
			Exit Function
	End If
		

	If Len(Form_Content)>LMT_MaxTextLength Then
		GBL_CHK_TempStr = "错误，帖子内容不能超过" & DEF_MaxTextLength & "字节.<br>" & VbCrLf
		CheckAnnouceValue = 0
		Exit Function
	End If

	If GetBinarybit(GBL_Board_BoardLimit,9) = 0 Then
		If GBL_UserID<1 Then
			GBL_CHK_TempStr = "密码或用户名错误，或此用户已经被服务器暂时屏蔽。<br>" & VbCrLf
			CheckAnnouceValue = 0
			Exit Function
		End If
		If GBL_CHK_OnlineTime < DEF_NeedOnlineTime and DEF_NeedOnlineTime > 0 and CheckSupervisorUserName = 0 Then
			GBL_CHK_TempStr = "论坛限制在线时间(" & DEF_PointsName(4) & ")" & Fix(DEF_NeedOnlineTime/60) & "分钟以上用户才能发言。<br>" & VbCrLf
			CheckAnnouceValue = 0
			Exit Function
		End If
	Else
		If GBL_UserID <= 0 and Form_UserName <> "" Then
			If CheckUserNameExist(Form_UserName) = 1 Then
				GBL_CHK_TempStr = "注意：用户名" & htmlencode(Form_UserName) & "已经有人使用，请不要使用此用户名发帖。<br>" & VbCrLf
				CheckAnnouceValue = 0
				Exit Function
			End If
		End If
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

	If isNumeric(Re_ID)=0 Then Re_ID=0
	Re_ID = cCur(Re_ID)
	If Re_ID<>0 Then
		If Borad_CheckAnnounceIDExist(Re_ID) = 0 Then
			GBL_CHK_TempStr = "发生错误，要回复的帖子不存在，可以是刚删除或其它原因.<br>" & VbCrLf
			CheckAnnouceValue = 0
			Exit Function
		End If
	End If
	
	If Trim(Replace(Replace(Replace(Replace(Form_Title & "","&nbsp;",""),chr(13),""),chr(10),""),chr(0),"")) = "" Then
		GBL_CHK_TempStr = "帖子名称必须填写.<br>" & VbCrLf
		CheckAnnouceValue = 0
		Exit Function
	End If

	If strLength(Form_Title)>255 Then
		GBL_CHK_TempStr = "帖子名称太长，最多允许255字节.<br>" & VbCrLf
		CheckAnnouceValue = 0
		Exit Function
	End If

 	If Trim(Replace(Replace(Form_Content,"&nbsp;",""),VbCrLf,"")) = "" and (Re_ID = 0 or (htmlencode(Form_Title) = LMT_TopicNameNoHTML or Lcase(left(Form_Title,3)) = "re:")) Then
		GBL_CHK_TempStr = "必须填写帖子内容信息.<br>" & VbCrLf
		CheckAnnouceValue = 0
		Exit Function
	ElseIf LMTDEF_MinAnnounceLength > 0 Then
		If (Len(Form_Title) < LMTDEF_MinAnnounceLength or inStr(htmlencode(Form_Title),LMT_TopicNameNoHTML) or Lcase(left(Form_Title,3)) = "re:") Then
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
	If Form_VoteFlag <> "" and Re_ID=0 Then
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
				If StrLength(TempURL(Loop_N)) > 48 Then
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
		
		If Temp < 2 Then
			GBL_CHK_TempStr = "既然是投票，请不要少于两个选项.<br>" & VbCrLf
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
	End If

	Loop_N = CheckIsRestSpaceTime(Form_Title)
	Select Case Loop_N
	Case 1: If CheckSupervisorUserName = 0 Then
			GBL_CHK_TempStr = GBL_CHK_TempStr & "不能连续发太多的帖子，请休息" & DEF_RestSpaceTime & "秒钟后再发帖!<br>"
			GBL_CHK_Flag = 0
			Exit Function
		End If
	Case 2:	GBL_CHK_TempStr = GBL_CHK_TempStr & "请不要发重复的帖子!<br>"
		GBL_CHK_Flag = 0
		Exit Function
	Case 3: Exit Function
	End Select

	If Re_ID=0 and GBL_UserID>0 and (GBL_BoardMasterFlag >= 5) and Form_AnnounceIsTopFlag=1 and GetBinarybit(GBL_CHK_UserLimit,4) = 0 Then
		If CheckMakeTopAnnounceOver = 1 then
			GBL_CHK_TempStr = GBL_CHK_TempStr & "错误,置顶的帖子太多，不能再发表直接置顶的帖子.<br>"
			GBL_CHK_Flag = 0
			Exit Function
		End If
	End If

	Form_Title = UBB_FiltrateBadWords(Form_Title)

	If Re_ID = 0 Then
		LMT_LastInfo = ""
	Else
		If Form_Title = "Re:" & LMT_TopicNameNoHTML Then
			If Form_HTMLFlag = 2 Then
				LMT_LastInfo = clearUbbcode(Form_Content)
			Else
				LMT_LastInfo = Form_Content
			End If
		Else
			If Form_TitleStyle = 1 Then
				LMT_LastInfo = KillHTMLLabel(Form_Title)
			Else
				LMT_LastInfo = Form_Title
			End if
		End If
		If StrLength(LMT_LastInfo) > 50 Then LMT_LastInfo = LeftTrue(LMT_LastInfo,47) & "..."
		LMT_LastInfo = UBB_FiltrateBadWords(LMT_LastInfo)
	End If

	Form_Length = Len(Form_Content)
	If Left(Form_Title,3) = "Re:" and Form_Title <> "Re:" & LMT_TopicNameNoHTML and Re_ID <> 0 Then Form_Title = Mid(Form_Title,4)
	'If GBL_Board_ForumPass <> "" or GBL_Board_OtherLimit > 0 or GetBinarybit(GBL_Board_BoardLimit,2) = 1 or GetBinarybit(GBL_Board_BoardLimit,7) = 1 Then
	'限制版面，回复标题同主题的标题
	'Else
		If Left(Form_Title,3) = "Re:" Then
			If Form_HTMLFlag = 2 Then
				GBL_CHK_TempStr = Trim(Left(clearUbbcode(Form_Content),20))
			Else
				GBL_CHK_TempStr = Trim(Left(Form_Content,20))
			End If
			If Form_Length > 20 Then GBL_CHK_TempStr = GBL_CHK_TempStr & "..."
			If Replace(Replace(GBL_CHK_TempStr,chr(13),""),chr(10),"") <> "" Then Form_Title = "re:" & GBL_CHK_TempStr
			GBL_CHK_TempStr = ""
		End If
	'End If
	Form_Title = Replace(Replace(Form_Title,chr(13),""),chr(10),"")
	
	If Form_TitleStyle = 0 and Re_ID = 0 and Len(Form_Color) = 7 and GBL_CHK_CharmPoint >= LMTDEF_ColorSpend Then
		Temp = "<font color=""" & htmlencode(Form_Color) & """>" & htmlencode(Form_Title) & "</font>"
		If strLength(Temp)>255 Then
			GBL_CHK_TempStr = "错误，帖子名称太长.<br>" & VbCrLf
			CheckAnnouceValue = 0
			Exit Function
		End If
		Form_Title = Temp
		Form_TitleStyle = 1
	Else
		Form_Color = ""
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

	CheckAnnouceValue = 1

End Function

Function CheckMakeTopAnnounceOver

	Dim Rs,SQL
	Set Rs = Server.CreateObject("ADODB.RecordSet")
	
	select case DEF_UsedDataBase
		case 0,2:
			SQL = "Select count(*) from LeadBBS_Announce Where ParentID = 0 and BoardID=" & GBL_board_ID & " and RootID>=" & DEF_BBS_TOPMinID
		case Else
			SQL = "Select count(*) from LeadBBS_Topic Where BoardID=" & GBL_board_ID & " and RootID>=" & DEF_BBS_TOPMinID
	End select
	Set Rs = LDExeCute(SQL,0)
	If Not Rs.Eof Then
		SQL = Rs(0)
		If isNull(SQL) Then SQL = 0
		SQL = cCur(SQL)
	Else
		SQL = 0
	End If
	Rs.Close
	Set Rs = Nothing

	If SQL > DEF_BBS_MaxTopAnnounce Then
		CheckMakeTopAnnounceOver = 1
	Else
		CheckMakeTopAnnounceOver = 0
	End If

End Function

Function CheckIsRestSpaceTime(Form_Title)

	If CheckWriteEventSpace = 0 and GBL_CHK_User <> "" Then
		CheckIsRestSpaceTime = 3
		Exit Function
	End If
	Dim Rs,ndatetime,Temp_ID,Temp_Title,Temp_Content
	If GBL_CHK_LastAnnounceID > 0 and GetBinarybit(GBL_Board_BoardLimit,9) = 0 or GBL_UserID > 0 Then
		Set Rs = LDExeCute(sql_select("Select ndatetime,ID,title,Content,htmlflag from LeadBBS_Announce where ID=" & GBL_CHK_LastAnnounceID,1),0)
		If Rs.Eof Then
			CheckIsRestSpaceTime = 0
			Rs.Close
			Set Rs = Nothing
			Temp_ID = 0
		Else
			ndatetime = Rs(0)
			Temp_ID = cCur(Rs(1))
			Temp_Title = Rs(2)
			Temp_Content = Rs(3)
			Rs.Close
			Set Rs = Nothing
		End if
	Else
		Set Rs = LDExeCute(sql_select("Select ndatetime,ID,title,Content,htmlflag from LeadBBS_Announce where IPAddress='" & Replace(GBL_IPAddress,"'","''") & "' Order by ID DESC",1),0)
		If Rs.Eof Then
			CheckIsRestSpaceTime = 0
			Rs.Close
			Set Rs = Nothing
			Exit Function
		Else
			ndatetime = Rs(0)
			Temp_ID = cCur(Rs(1))
			Temp_Title = Rs(2)
			Temp_Content = Rs(3)
			Rs.Close
			Set Rs = Nothing
		End if
	End If

	If Temp_ID = 0 Then
		Exit Function
	End If

	If DateDiff("s", RestoreTime(ndatetime), DEF_Now) < 0 Then
		CheckIsRestSpaceTime = 0
		Exit Function
	End If

	If DateDiff("s", RestoreTime(ndatetime), DEF_Now) < DEF_RestSpaceTime and CheckSupervisorUserName = 0 Then
		CheckIsRestSpaceTime = 1
		'CALL LDExeCute("Update LeadBBS_Announce set ndatetime=" & GetTimeValue(DEF_Now) & " where id=" & Temp_ID,1)
	Else
		If (Temp_Title = Form_Title or "Re:" & Temp_Title = Form_Title) and Temp_Content = Form_Content Then
			CheckIsRestSpaceTime = 2
		Else
			CheckIsRestSpaceTime = 0
		End If
	End If

End Function

Function SaveAnnounceValue

	if cstr(GBL_ipaddress)="115.221.54.100" then
		Response.Write "<p>Form_UserName:" & Form_UserName
		Response.Write "<p>Form_UserID:" & Form_UserID
	End If

	If Form_UserName = "" Then
		Form_UserName = "游客"
		GBL_UserID = 0
		Form_UserID = 0
	ElseIf Form_UserID < 1 and LMT_EnableOtherGuestName = 0 Then
		Form_UserName = "游客"
	End If
	if cstr(GBL_ipaddress)="115.221.54.100" then
		Response.Write "<p>Form_UserName:" & Form_UserName
		Response.Write "<p>Form_UserID:" & Form_UserID
	End If
	Form_UserID = cCur(Form_UserID)
	If inStr(Lcase(Form_UserName),"<script") or inStr(Lcase(Form_UserName),"<\script") or inStr(Lcase(Form_UserName),"</script") or inStr(Lcase(Form_UserName),"\") or inStr(Lcase(Form_UserName),">") or inStr(Lcase(Form_UserName),"<") or inStr(Lcase(Form_UserName),"""") or inStr(Lcase(Form_UserName),",") or inStr(Lcase(Form_UserName),chr(10)) or inStr(Lcase(Form_UserName),chr(13)) Then Form_UserName = "游客"
	Form_NoUserUnderWriteFlag = cCur(Form_NoUserUnderWriteFlag)
	Form_UnderWriteFlag = cCur(Form_UnderWriteFlag)
	Dim SQL,Rs,MaxRootID
	Dim NewMaxAnnounceID
	Dim TempURL,Loop_N,Temp
	Rem 为了兼容，最好加入选取最大RootID值，如果RootID大于MaxID，则RootID取代MaxID(RootID<DEF_BBS_TOPMinID)

	If Form_UserID > 0 then
		GET_LastUser = GetTrueName(Form_UserName,GBL_CHK_TrueName) & "#" & Form_UserID
	Else
		GET_LastUser = Form_UserName
	end if
	
	If Re_ID = 0 or DEF_EnableMakeTopAnc <> GetBinarybit(GBL_Board_BoardLimit,17) Then
		'MaxRootID = cCur(Application(DEF_MasterCookies & "BoardInfo" & GBL_board_ID)(11,0))
		'If MaxRootID >= DEF_BBS_TOPMinID Then
			select case DEF_UsedDataBase
				case 0,2:
					Set Rs = LDExeCute(sql_select("Select RootID from LeadBBS_Announce where ParentID=0 and BoardID=" & GBL_Board_ID & " Order by RootID DESC",DEF_BBS_MaxTopAnnounce + 2),0)
				case Else
					Set Rs = LDExeCute(sql_select("Select RootID from LeadBBS_Topic where BoardID=" & GBL_Board_ID & " Order by RootID DESC",DEF_BBS_MaxTopAnnounce + 2),0)
			End select
			MaxRootID = 0
			Do while Not Rs.Eof
				If cCur(Rs(0)) < DEF_BBS_TOPMinID Then
					MaxRootID = cCur(Rs(0))
					Exit Do
				End If
				Rs.MoveNext
			Loop
			Rs.Close
			Set Rs = Nothing
			
			If MaxRootID >= DEF_BBS_TOPMinID and MaxRootID > 0 Then
				select case DEF_UsedDataBase
					case 0,2:
						Set Rs = LDExeCute("Select Max(RootID) from LeadBBS_Announce where ParentID=0 and BoardID=" & GBL_Board_ID & " and RootID<" & DEF_BBS_TOPMinID,0)
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
			End If
		'End If
	End If

	If Re_ID<>0 Then
		Form_RootID = 0
	Else
		If Re_ID=0 and GBL_UserID>0 and (GBL_BoardMasterFlag >= 5) and Form_AnnounceIsTopFlag=1 and GetBinarybit(GBL_CHK_UserLimit,4) = 0 Then
			select case DEF_UsedDataBase
				case 0,2:
					Set Rs = LDExeCute("Select Max(RootID) from LeadBBS_Announce Where ParentID=0 and BoardID=" & GBL_Board_ID & " and RootID>=" & DEF_BBS_TOPMinID,0)
				case Else
					Set Rs = LDExeCute("Select Max(RootID) from LeadBBS_Topic Where BoardID=" & GBL_Board_ID & " and RootID>=" & DEF_BBS_TOPMinID,0)
			End select
			If Rs.Eof Then
				Form_RootID = DEF_BBS_TOPMinID+1
			Else
				Form_RootID = Rs(0)
				If isNull(Form_RootID) or Form_RootID="" Then Form_RootID = DEF_BBS_TOPMinID+1
				Form_RootID = cCur(Form_RootID)+1
				If Form_RootID<DEF_BBS_TOPMinID Then Form_RootID=DEF_BBS_TOPMinID
			End If
			Rs.Close
			Set Rs = Nothing
		Else
			Form_RootID = MaxRootID+1
		End If
	End If
	Form_ndatetime = GetTimeValue(DEF_Now)
	Form_LastTime = Form_ndatetime
	
	Form_Content = UBB_FiltrateBadWords(Form_Content) '脏字过滤

	If Form_UpFlag = 1 Then
		LMT_Upload_ExtendID = NewAnnounceID
		Dim Upd_FileInfo,UploadSave
		Set UploadSave = New Upload_Save
		UploadSave.Upload_File
		Upd_FileInfo = UploadSave.Upd_FileInfo
		Upd_ErrInfo = UploadSave.Upd_ErrInfo
	End If
	
	Form_PollNum = 0
	If Form_htmlflag = 2 and Form_TopicType <> 80 and Re_ID = 0 and Form_TopicType <> 54 and Form_TopicType <> 49 Then
		If Upd_FileInfo <> 0 Then
			Form_PollNum = Upd_FileInfo
		End If
	End If

	If Form_TopicType <> 80 and Form_TopicType < 60 and Re_ID = 0 and Form_TopicType > 0 Then
		Loop_N = inStr(Form_Content,"[HIDDEN]")
		If Loop_N > 0 Then
			Temp = inStr(Loop_N,Form_Content,"[/HIDDEN]")
			If Temp > Loop_N + 9 Then
				Form_TopicType = Form_TopicType + 60
			End If
		End If
	End If

	If Form_NeedValue = "" then Form_NeedValue = 0
	Form_NeedValue = cCur(Form_NeedValue)

	If Re_ID <> 0 Then
		Form_TopicType = 0
		Form_NeedValue = 0
	End If

	If GBL_BoardMasterFlag < 4 and GetBinarybit(GBL_Board_BoardLimit,13) = 1 Then
		Form_TitleStyle = Form_TitleStyle + 60
	End If
	SQL = " insert into LeadBBS_Announce(ParentID,TopicSortID,BoardID,RootID," & _
		    "Layer,Title,Content,FaceIcon,ndatetime,LastTime,Length," &_
		    "UserName,UserID,UnderWriteFlag,htmlflag,NotReplay,IPAddress,TopicType,NeedValue,TitleStyle,RootIDBak,VisitIP,GoodAssort,PollNum)" &_
	" values(" & Re_ID & "," & Form_TopicSortID & "," & Form_BoardID & "," & Form_RootID & "," &_
	Form_Layer & ",'" & Replace(Form_Title,"'","''") & "','" & Replace(Replace(Form_Content & "","\" & VbCrLf,"\\" & VbCrLf & VbCrLf),"'","''") & "'," &_
	Form_FaceIcon & "," & Form_ndatetime & "," & Form_LastTime & "," & Form_Length & ",'" &_
	Replace(Form_UserName,"'","''") & "'," & Form_UserID & "," & Form_NoUserUnderWriteFlag & "," & Form_htmlflag & "," & Form_NotReplay & ",'" & Replace(GBL_IPAddress,"'","''") & "'" & _
	"," & Form_TopicType & "," & Form_NeedValue & "," & Form_TitleStyle & "," & LMT_RootIDBak & ",'0.0.0.0'," & Form_GoodAssort & "," & Form_PollNum & ")"

	Dim SQL_Temp
	SQL_Temp = "Insert into LeadBBS_Assessor(BoardID,Title,UserName,NdateTime,AnnounceID,Content,HTMLFlag,TypeFlag) Values(" & _
			GBL_Board_ID & _
			",'" & Replace(Form_Title,"'","''") & "'" & _
			",'" & Replace(Form_UserName,"'","''") & "'" & _
			"," & GetTimeValue(DEF_Now) & ""
	ChangeGoodAssort(Form_GoodAssort)

	CALL LDExeCute(SQL,1)
	
	If Form_Color <> "" and Form_TitleStyle = 1 Then
		Form_Color = ",CharmPoint=CharmPoint-" & LMTDEF_ColorSpend
	Else
		Form_Color = ""
	End if
	If GBL_BoardMasterFlag < 4 and GetBinarybit(GBL_Board_BoardLimit,13) = 1 Then
		Form_Title = "新审核帖子..."
		LMT_TopicNameNoHTML = "新审核帖子..."
		LMT_LastInfo = ""
	End If

	'不需要指定User
	'此方法虽然非常快，但当并发多时，会产生错误的现象
	If DEF_UsedDataBase = 0 or DEF_UsedDatabase = 2 Then
		Set Rs = LDExeCute("select @@IDENTITY as id",0)
		NewAnnounceID = Rs(0)
		Rs.Close
		Set Rs = Nothing
		If isNull(NewAnnounceID) Then NewAnnounceID = 0
		NewAnnounceID = cCur(NewAnnounceID)
		If Re_ID = 0 then LMT_RootIDBak = NewAnnounceID

		If NewAnnounceID = 0 Then
			'SQL = sql_select("Select ID,RootID from LeadBBS_Announce where UserID=" & Form_UserID & " and ParentID=" & Re_ID & " order by id DESC",1)
			SQL = sql_select("Select ID,RootID from LeadBBS_Announce where UserID=" & Form_UserID & " order by id DESC",1)
			'SQL = "Select max(ID) from LeadBBS_Announce where UserID=" & Form_UserID
	
			Set Rs = LDExeCute(SQL,0)
			If Rs.Eof Then
				GBL_CHK_TempStr = "意外错误，刚发的帖可能已经删除或其它意外错误！<br>" & VbCrLf
				Rs.Close
				Set Rs = Nothing
				Exit Function
			End If
			NewAnnounceID = Rs(0)
			'Form_RootID = cCur(Rs(1))
			If isNull(NewAnnounceID) Then NewAnnounceID = 0
			NewAnnounceID = cCur(NewAnnounceID)
			If Re_ID = 0 then LMT_RootIDBak = NewAnnounceID
			Rs.Close
			Set Rs = Nothing
		End If
	Else
		SQL = "Select max(ID) from LeadBBS_Announce where UserID=" & Form_UserID
		Set Rs=LDExeCute(SQL,0)
		GBL_DBNum = GBL_DBNum + 1
		If Rs.Eof Then
			GBL_CHK_TempStr = "意外错误，刚发的帖可能已经删除或其它意外错误！<br>" & VbCrLf
			Rs.Close
			Set Rs = Nothing
			Exit Function
		End If
		NewAnnounceID = Rs(0)
		If isNull(NewAnnounceID) Then NewAnnounceID = 0
		NewAnnounceID = cCur(NewAnnounceID)
		If Re_ID = 0 then LMT_RootIDBak = NewAnnounceID
		Rs.Close
		Set Rs = Nothing
		
		If Re_ID = 0 Then
			SQL = " insert into LeadBBS_Topic(ID,BoardID,RootID," & _
				    "Title,FaceIcon,ndatetime,LastTime,Length," &_
				    "UserName,UserID,NotReplay,TopicType,NeedValue,TitleStyle,VisitIP,GoodAssort,PollNum)" &_
			" values(" & NewAnnounceID & "," & Form_BoardID & "," & Form_RootID & "," &_
			"'" & Replace(Form_Title,"'","''") & "'," &_
			Form_FaceIcon & "," & Form_ndatetime & "," & Form_LastTime & "," & Form_Length & ",'" &_
			Replace(Form_UserName,"'","''") & "'," & Form_UserID & "," & Form_NotReplay & "" & _
			"," & Form_TopicType & "," & Form_NeedValue & "," & Form_TitleStyle & ",'0.0.0.0'," & Form_GoodAssort & "," & Form_PollNum & ")"
			CALL LDExeCute(SQL,1)
		End If
	End If
	
	If Form_UpFlag = 1 Then
		dim tmpt
		if LMT_RootIDBak = NewAnnounceID or LMT_RootIDBak = 0 then
			tmpt = 1
		else
			tmpt = 0
		end if
		call UploadSave.UpdateUpload(NewAnnounceID,tmpt)
	End If

	NewMaxAnnounceID = NewAnnounceID
	If GBL_BoardMasterFlag < 9 and (GetBinarybit(GBL_Board_BoardLimit,13) = 1 or GetBinarybit(GBL_Board_BoardLimit,22) = 1) Then
		SQL_Temp = SQL_Temp & "," & NewAnnounceID
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

	Rem 更新MaxRootID
	If Re_ID > 0 Then
		If (DEF_EnableMakeTopAnc <> GetBinarybit(GBL_Board_BoardLimit,17)) and cCur(LMT_RootID)<DEF_BBS_TOPMinID Then
			CALL LDExeCute("Update LeadBBS_Announce Set RootID=" & MaxRootID+1 & ",ChildNum=ChildNum+1,LastTime=" & GetTimeValue(DEF_Now) & ",LastUser='" & Replace(GET_LastUser,"'","''") & "',RootMaxID=" & NewMaxAnnounceID & ",LastInfo='" & Replace(Left(LMT_LastInfo,50),"'","''") & "' where ID=" & LMT_RootIDBak,1)
			If DEF_UsedDataBase = 1 Then CALL LDExeCute("Update LeadBBS_Topic Set RootID=" & MaxRootID+1 & ",ChildNum=ChildNum+1,LastTime=" & GetTimeValue(DEF_Now) & ",LastUser='" & Replace(GET_LastUser,"'","''") & "',RootMaxID=" & NewMaxAnnounceID & ",LastInfo='" & Replace(Left(LMT_LastInfo,50),"'","''") & "' where ID=" & LMT_RootIDBak,1)
			
			If cCur(Application(DEF_MasterCookies & "BoardInfo" & GBL_board_ID)(12,0)) >= cCur(LMT_RootID) Then
				UpdateBoardValue(GBL_board_ID)
			Else
				CALL LDExeCute(" Update LeadBBS_Boards Set AllMaxRootID=" & MaxRootID+1 & ",LastWriter='" & Replace(GET_LastUser,"'","''")  &"',LastWriteTime=" & Form_LastTime & ",LastAnnounceID=" & LMT_RootIDBak & ",LastTopicName='" & Replace(LMT_TopicNameNoHTML,"'","''") & "' where BoardID=" & GBL_board_ID,1)
				UpdateBoardApplicationInfo GBL_Board_ID,MaxRootID+1,11
			End If
			'UpdateBoardValue(GBL_board_ID)
		Else
			CALL LDExeCute(" Update LeadBBS_Boards Set LastWriter='" & Replace(GET_LastUser,"'","''")  &"',LastWriteTime=" & Form_LastTime & ",LastAnnounceID=" & LMT_RootIDBak & ",LastTopicName='" & Replace(LMT_TopicNameNoHTML,"'","''") & "' where BoardID=" & GBL_board_ID,1)
			CALL LDExeCute("Update LeadBBS_Announce Set ChildNum=ChildNum+1,LastTime=" & GetTimeValue(DEF_Now) & ",LastUser='" & Replace(GET_LastUser,"'","''") & "',RootMaxID=" & NewMaxAnnounceID & ",LastInfo='" & Replace(Left(LMT_LastInfo,50),"'","''") & "' where ID=" & LMT_RootIDBak,1)
			If DEF_UsedDataBase = 1 Then CALL LDExeCute("Update LeadBBS_Topic Set ChildNum=ChildNum+1,LastTime=" & GetTimeValue(DEF_Now) & ",LastUser='" & Replace(GET_LastUser,"'","''") & "',RootMaxID=" & NewMaxAnnounceID & ",LastInfo='" & Replace(Left(LMT_LastInfo,50),"'","''") & "' where ID=" & LMT_RootIDBak,1)
		End If

		UpdateBoardApplicationInfo GBL_board_ID,GET_LastUser,3
		UpdateBoardApplicationInfo GBL_board_ID,Form_LastTime,4
		UpdateBoardApplicationInfo GBL_board_ID,LMT_RootIDBak,19
		UpdateBoardApplicationInfo GBL_board_ID,LMT_TopicNameNoHTML,20
		UpdateBoardAnnounceNum Application(DEF_MasterCookies & "BoardInfo" & GBL_board_ID)(28,0),0,1,1,0,GET_LastUser,Form_LastTime,LMT_RootIDBak,LMT_TopicNameNoHTML
		UpdateStatisticDataInfo 1,9,1
		UpdateStatisticDataInfo 1,11,1
		CALL LDExeCute("Update LeadBBS_User set Points=Points+" & DEF_BBS_AnnouncePoints & ",AnnounceNum=AnnounceNum+1,AnnounceNum2=AnnounceNum2+1,LastAnnounceID=" & NewAnnounceID & Form_Color & " Where ID = " & Form_UserID,1)
		add_tips(DEF_PointsName(0) & "+" & DEF_BBS_AnnouncePoints)
		UpdateSessionValue 4,DEF_BBS_AnnouncePoints,1
		UpdateSessionValue 14,NewAnnounceID,0
		If Form_Color <> "" Then UpdateSessionValue 15,0-LMTDEF_ColorSpend,1
		If inStr(application(DEF_MasterCookies & "TopAncList"),"," & LMT_RootIDBak & ",") Then
			UpdateAnnounceApplicationInfo LMT_RootIDBak,10,GET_LastUser,0,0
			UpdateAnnounceApplicationInfo LMT_RootIDBak,4,Form_LastTime,0,0
			UpdateAnnounceApplicationInfo LMT_RootIDBak,1,LMT_ChildNum + 1,0,0
			UpdateAnnounceApplicationInfo LMT_RootIDBak,17,LMT_LastInfo,0,0
		Else
			If inStr(application(DEF_MasterCookies & "TopAncList" & GBL_Board_BoardAssort),"," & LMT_RootIDBak & ",") Then
				UpdateAnnounceApplicationInfo LMT_RootIDBak,10,GET_LastUser,0,GBL_Board_BoardAssort
				UpdateAnnounceApplicationInfo LMT_RootIDBak,4,Form_LastTime,0,GBL_Board_BoardAssort
				UpdateAnnounceApplicationInfo LMT_RootIDBak,1,LMT_ChildNum + 1,0,GBL_Board_BoardAssort
				UpdateAnnounceApplicationInfo LMT_RootIDBak,17,LMT_LastInfo,0,GBL_Board_BoardAssort
			End If
		End If
		
		'同时提镜像帖(最多3个)
		SQL = sql_select("Select ID from LeadBBS_Announce where TopicType=39 and NeedValue=" & Re_ID,3)
		Set Rs = LDExeCute(SQL,0)
		If Not Rs.Eof Then
			SQL = Rs.GetRows(3)
			Rs.Close
			Set Rs = Nothing
			For Temp = 0 to Ubound(SQL,2)
				CALL MakeAnnounceTop(SQL(0,Temp),",LastUser='" & Replace(GET_LastUser,"'","''") & "',LastTime=" & GetTimeValue(DEF_Now) & ",ChildNum=ChildNum+1,Hits=" & Form_Hits)
			Next
		Else
			Rs.Close
			Set Rs = Nothing
		End If
	Else
		CALL LDExeCute("Update LeadBBS_Announce Set RootMaxID=ID,RootMinID=ID,RootIDBak=ID where RootIDBak=0",1)
		If DEF_UsedDataBase = 1 Then CALL LDExeCute("Update LeadBBS_Topic Set RootMaxID=ID,RootMinID=ID where ID=" & NewAnnounceID,1)
		CALL LDExeCute("Update LeadBBS_User set Points=Points+" & DEF_BBS_AnnouncePoints * 2 & ",AnnounceNum=AnnounceNum+1,AnnounceNum2=AnnounceNum2+1,AnnounceTopic=AnnounceTopic+1,LastAnnounceID=" & NewAnnounceID & Form_Color & " Where ID = " & Form_UserID,1)
		add_tips(DEF_PointsName(0) & "+" & DEF_BBS_AnnouncePoints * 2)
		UpdateSessionValue 4,DEF_BBS_AnnouncePoints * 2,1
		UpdateSessionValue 14,NewAnnounceID,0
		If Form_Color <> "" Then UpdateSessionValue 15,0-LMTDEF_ColorSpend,1

		LMT_TopicName = Form_Title
		If Form_TitleStyle <> 1 Then
			LMT_TopicNameNoHTML = Form_Title
		Else
			LMT_TopicNameNoHTML = KillHTMLLabel(Form_Title)
		End If
		
		If Form_RootID > cCur(Application(DEF_MasterCookies & "BoardInfo" & GBL_board_ID)(11,0)) Then
			If cCur(Application(DEF_MasterCookies & "BoardInfo" & GBL_board_ID)(12,0)) = 0 Then
				UpdateBoardValue(GBL_board_ID)
			Else
				CALL LDExeCute("Update LeadBBS_Boards Set AllMaxRootID=" & Form_RootID & ",LastWriter='" & Replace(GET_LastUser,"'","''")  &"',LastWriteTime=" & Form_LastTime & ",LastAnnounceID=" & LMT_RootIDBak & ",LastTopicName='" & Replace(LMT_TopicNameNoHTML,"'","''") & "' where BoardID=" & GBL_board_ID,1)
				UpdateBoardApplicationInfo GBL_Board_ID,Form_RootID,11
			End If
		Else
			CALL LDExeCute("Update LeadBBS_Boards Set LastWriter='" & Replace(GET_LastUser,"'","''")  &"',LastWriteTime=" & Form_LastTime & ",LastAnnounceID=" & LMT_RootIDBak & ",LastTopicName='" & Replace(LMT_TopicNameNoHTML,"'","''") & "' where BoardID=" & GBL_board_ID,1)
		End If
		UpdateBoardApplicationInfo GBL_board_ID,Form_RootID,11
		UpdateBoardApplicationInfo GBL_board_ID,GET_LastUser,3
		UpdateBoardApplicationInfo GBL_board_ID,Form_LastTime,4
		UpdateBoardApplicationInfo GBL_board_ID,LMT_RootIDBak,19
		UpdateBoardApplicationInfo GBL_board_ID,LMT_TopicNameNoHTML,20
		UpdateStatisticDataInfo 1,9,1
		UpdateStatisticDataInfo 1,10,1
		UpdateStatisticDataInfo 1,11,1
		UpdateBoardAnnounceNum Application(DEF_MasterCookies & "BoardInfo" & GBL_board_ID)(28,0),1,1,1,0,GET_LastUser,Form_LastTime,LMT_RootIDBak,LMT_TopicNameNoHTML
	End If
	'on error resume next
	If err Then
		SaveAnnounceValue = 0
		GBL_CHK_TempStr = "错误，服务器太忙或您的文档大太，请重新提交表单!<br>" & VbCrLf
		err.clear
	Else
		SaveAnnounceValue = 1
	End If

	Rem 下面保存投票选项
	If Form_VoteFlag <> "" and Re_ID=0 Then
		Form_Vote_ExpireDay = cCur(Form_Vote_ExpireDay)
		If Form_Vote_ExpireDay <> 0 Then Form_Vote_ExpireDay = GetTimeValue(DateAdd("d",Form_Vote_ExpireDay,DEF_Now))
		Temp = 0
		TempURL = Split(Form_VoteItem,VbCrLf)
		Form_VoteItem = ""
		For Loop_N = 0 to Ubound(TempURL,1)
			If TempURL(Loop_N) <> "" Then
				CALL LDExeCute("insert into LeadBBS_VoteItem(AnnounceID,VoteType,VoteName,ExpiresTime) values(" & NewAnnounceID & "," & Form_VoteType & ",'" & Replace(UBB_FiltrateBadWords(TempURL(Loop_N)),"'","''") & "'," & Form_Vote_ExpireDay & ")",1)
				Temp = Temp + 1
				If Temp > DEF_VOTE_MaxNum Then
					GBL_CHK_TempStr = "错误，投票选项不能超过" & DEF_VOTE_MaxNum & "个.<br>" & VbCrLf
					SaveAnnounceValue = 0
					Exit Function
				End If
			End If
		Next
	End If
	
	Dim sendedList : sendedList = "," & GBL_CHK_User & ","
	Rem 下面短消息通知帖主
	If LMT_ReName = "游客" or LMT_ReName = "[LeadBBS]" Then LMT_ReName = ""
	
	dim retitle
	retitle = Form_Title
	if lcase(left(Form_Title,3)) = "re:" then retitle = Form_Content
	retitle = left(GetReContent(retitle),60) & "..."
	If Re_ID > 0 and LMT_ReName <> "" Then
		If GetFormData("Form_RepostMsg") = "checkbox" Then
			sendedList = sendedList & LMT_ReName & ","
			SendNewMessage "[LeadBBS]",LMT_ReName,"论坛短信：帖子回复通知","[color=blue]您所发表的帖子受到回复[/color][hr]" &_
			"[b]所在版面：[/b][url=../b/" & RW_b(GBL_Board_ID,0,"") & "]" & htmlencode(KillHTMLLabel(GBL_Board_BoardName)) & "[/url]" & VbCrLf & _
			"[b]回复作者：[/b]" & GBL_CHK_User & VbCrLf & _
			"[b]回复帖子：[/b][url=../a/" & RW_a(GBL_Board_ID,NewAnnounceID,1,1,"") & "]" & htmlencode(retitle) & "[/url]",GBL_IPAddress
		End If
	End If

	dim patrn,strng
	Dim regEx, Match, Matches, s
	If Form_HTMLFlag = 2 Then
		strng = form_content
	
		Set regEx = New RegExp
		regEx.IgnoreCase = True
		regEx.Global = True
		
		patrn = "\[email[\=]?(.*?)\](.*?)\[\/email\]"
		regEx.Pattern = patrn
		strng = regEx.replace(strng,"")
		
		patrn = "\[@(.{2,20}?)\]"
		regEx.Pattern = patrn
	
		if regEx.test(strng) = false then
			'patrn = "@([a-z0-9\_]{1,20})"
			patrn = "@([^\ \　\.\""\'\[\]\(\)\<\>\&\\\/]{1,30})"
			
			regEx.Pattern = patrn
		end if
		Set Matches = regEx.Execute(strng)
	
		s = 1
		dim touser,totruename,toid,su,checked
		For Each Match in Matches
			touser = Match.SubMatches(0)
			if inStr(touser,",") = 0 Then
				If inStr(sendedList,"," & touser & ",") = 0 then
					totruename = ""
					toid = 0
					checked = 0
					if inStr(touser,"#") > 0 then
						if left(touser,3) <> "QQ#" and left(touser,3) <> "LD#" then
							su = split(touser,"#")
							totruename = su(0)
							toid = toNum(su(1),0)
							touser = CheckUserNameExist("",totruename,toid)
							checked = 1
						end if
					else
					end if
					if checked = 0 then
						touser = CheckUserNameExist(touser,"",0)
					end if
					If touser <> "" Then
						sendedList = sendedList & touser & ","
						SendNewMessage "[LeadBBS]",touser,"论坛短信：帖子中提到你","[color=blue]此帖中提到你[/color][hr]" &_
						"[b]所在版面：[/b][url=../b/" & RW_b(GBL_Board_ID,0,"") & "]" & htmlencode(KillHTMLLabel(GBL_Board_BoardName)) & "[/url]" & VbCrLf & _
						"[b]作者：[/b]" & GetTrueNameID(GBL_CHK_User,GBL_CHK_TrueName,GBL_UserID) & VbCrLf & _
						"[b]帖子：[/b][url=../a/" & RW_a(GBL_Board_ID,NewAnnounceID,1,1,"") & "]" & htmlencode(retitle) & "[/url]",GBL_IPAddress
					End If
				end if
			End If
			s = s + 1
			If s > 5 Then exit for
		Next
	End If

	Rem 下面发表同步
	dim weiBoFlag
	If GetFormData("bindpost_1_1") = "1" Then
		weiBoFlag = 1
	Else
		weiBoFlag = 0
	End If
	
	dim sync_list,n,hassync
	hassync = 0
	redim sync_list(ubound(connect_allow))
	for n = 0 to ubound(connect_allow)
		if GetFormData("bindpost_" & (n+1)) = "1" then
			sync_list(n) = 1
			hassync = 1
		else
			sync_list(n) = 0
		end if
	next
	
	dim apptype
	dim shareimg,sharevideo
	Dim ConnetBind
	
	If hassync = 1 or weiBoFlag = 1 Then
		shareimg = ""
		sharevideo = ""
		strng = form_content
		Set regEx = New RegExp
		regEx.IgnoreCase = True
		regEx.Global = True

		patrn = "\[upload=([0-9]{1,14}),0\](.+?)\[\/upload\]"
		regEx.Pattern = patrn
	
		if regEx.test(strng) then
			Set Matches = regEx.Execute(strng)
			For Each Match in Matches
				shareimg = LD_GetUrl(1) & "a/file.asp?lid=" & Match.SubMatches(0) & "&s=" + DEF_DownKey
				exit for
			next
		end if
		
		patrn = "(http:\/\/|ftp:\/\/|https:\/\/|mms:\/\/|rtsp:\/\/|www.)([^# \f\n\r\t\v\<\u3000\]]*)\.swf([^# \f\n\r\t\v\<\u3000\]]*)"
		regEx.Pattern = patrn
		
		if regEx.test(strng) then
			Set Matches = regEx.Execute(strng)
			For Each Match in Matches
				sharevideo = Match.SubMatches(0) & Match.SubMatches(1) & ".swf" & Match.SubMatches(2)
				exit for
			next
		end if
	end if

If hassync = 1 or weiBoFlag = 1 Then
	for n = 0 to ubound(connect_allow)
	if sync_list(n) = 1 or (n=0 and weiBoFlag=1) then 
		apptype = connect_apptype(n)
		if n=0 then
			if weiBoFlag = 1 and GetFormData("bindpost_1") = "1" then
				weiBoFlag = 2
			elseif weiBoFlag = 1 then
				weiBoFlag = 1
			elseif GetFormData("bindpost_1") = "1" then
				weiBoFlag = 0
			end if
			'if weiBoFlag = 0 then weiBoFlag = 2
		else
			weiBoFlag = 0
		end if
		set ConnetBind = New Connet_Bind
		call ConnetBind.PostShare(apptype,LeftTrue(Form_Title,72),LD_GetUrl(1) & "a/" & RW_a(GBL_Board_ID,NewAnnounceID,1,0,""),"",LeftTrue(clearUbbcode(GetReContent(Form_Content)),80),shareimg,weiBoFlag,sharevideo)
		set ConnetBind = nothing
	end if
	next
End If
	
	
	'if LMT_RootIDBak = NewAnnounceID or LMT_RootIDBak = 0 then UploadSave.UpdateUpload(NewAnnounceID)
	
	If Form_UpFlag = 1 Then
		if LMT_RootIDBak = NewAnnounceID or LMT_RootIDBak = 0 then
			if extent_content = "" then
				sharevideo = get_videoInfo(form_content)
				extent_content = sharevideo
				call UploadSave.UpdateUpload(NewAnnounceID,1)
			end if
		end if
		Set UploadSave = Nothing
	End If
	If Form_UpFlag = 1 Then Set UploadSave = Nothing
	
	if Form_HTMLFlag = 2 and Form_remoteEnable = 1 then
		dim remotepicsave
		set remotepicsave = new remote_pic_save
		call remotepicsave.get_remoteImg(Form_content,NewAnnounceID,Re_ID)
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

Function CheckUserNameExist(username,truename,toid)

	Dim UserLimit
	Dim Rs,ToUserID
	
	if username <> "" then
		Set Rs = LDExeCute(sql_select("Select ID,UserName,UserLimit from LeadBBS_User where UserName='" & Replace(Left(username,20),"'","''") & "'",1),0)
	else
		Set Rs = LDExeCute(sql_select("Select ID,UserName,UserLimit from LeadBBS_User where truename='" & Replace(Left(truename,20),"'","''") & "' and id=" & ccur(toid),1),0)
	end if
	
	If Rs.Eof Then
		CheckUserNameExist = ""
	Else
		ToUserID = Rs(0)
		CheckUserNameExist = Rs(1)
		UserLimit = Rs(2)
	End if
	Rs.Close
	Set Rs = Nothing
	If GetBinaryBit(UserLimit,13) = 1 and GBL_BoardMasterFlag < 4 Then '版主或以上权限者不受此限制
		Set Rs = LDExeCute(sql_select("Select ID from LeadBBS_FriendUser where FriendUserID=" & GBL_UserID & " and UserID=" & ToUserID,1),0)
		If Rs.Eof Then
			CheckUserNameExist = ""
		End If
		Rs.Close
		Set Rs = Nothing
	End If

End Function

Function DisplayAnnounceAccessfull

Global_TableHead%>
<div class=contentbox>
		<table border=0 cellpadding=0 cellspacing=0 width="100%" class=tablebox>
		<tr class=tbhead>
			<td><div class=value><%
			If Re_ID=0 Then
				Response.Write "刚发的新帖子"
			Else
				Response.Write "刚发的回复帖子"
			End If%> 已经成功发表到版面“<%=GBL_Board_BoardName%>”中，您可以选择以下操作：</div></td>
		</tr>
		</table>
		<table border=0 cellpadding=0 cellspacing=0 width="100%" class=tablebox>
		<tr>
			<td class=tdright>
			<br>
			<%
			Dim UpdateFlag
			UpdateFlag = UpdateUserLevel(Form_UserID)
			If GBL_BoardMasterFlag < 4 and GetBinarybit(GBL_Board_BoardLimit,13) = 1 Then
				Response.Write "请耐心等待论坛管理员审核您的帖子。<br>"
			End If

			
			If Upd_ErrInfo <> "" Then Response.Write "<font color=Red class=redfont>" & Upd_ErrInfo & "</font><br>"%>
			本页面将在5秒后自动返回您所发表的帖子，可以继续选择以下操作：<br>
				<script language=javascript>
				function a_topage()
				{
					//this.location.href = "<%=RW_a(GBL_Board_ID,LMT_RootIDBak,1,1,"lastpage=1")%>"; 
				}
				setTimeout("a_topage()",5000);
				</script>
				<ul>
					<li><a href=../Boards.asp>返回首页</a><br>
					<li>返回<a href=../b/<%=RW_b(GBL_Board_ID,0,"")%>><%=GBL_Board_BoardName%></a>论坛<br>
					<%
					If (LMT_ChildNum + 2) > DEF_TopicContentMaxListNum Then%>
					<li>返回<a href=<%=RW_a(GBL_Board_ID,LMT_RootIDBak,1,1,"")%>>刚发表的主题</a><br>
					<%End If%>
					<li>到<a href=<%=RW_a(GBL_Board_ID,LMT_RootIDBak,1,1,"lastpage=1")%>>刚发表的帖子</a>
				</ul>
			</td>
		</tr>
		
		</table>
</div>
<%
REM *******Chat Start*******
If GBL_CheckLimitTitle(GBL_Board_ForumPass,GBL_Board_BoardLimit,GBL_Board_OtherLimit,GBL_Board_HiddenFlag) = 1 Then
	Form_Title = "<font color=gray calss=grayfont>此帖子标题已设置为隐藏</font>"
	Form_TitleStyle = 1
Else
	If Left(Form_Title,3) = "re:" and Form_Title <> "re:" Then Form_Title = Mid(Form_Title,4)
End If
CALL Chat_Appand_pop(3,"<span onclick=c_sc(this.innerHTML) style=cursor: pointer class=c_name>" & GBL_CHK_User & "</span>发表帖子：<a href=../../a/" & RW_a(GBL_Board_ID,LMT_RootIDBak,1,1,"") & " target=_blank>" & Replace(DisplayAnnounceTitle(Form_Title,Form_TitleStyle),"""","\""") & "</a>。")
REM *******Chat End*********

	
	If UpdateFlag = 0 Then
		Response.Clear
		If AjaxFlag = 0 Then
			CloseDatabase
			Response.Redirect RW_a(GBL_Board_ID,LMT_RootIDBak,1,0,"")
		Else
			Response.Write "success|" & NewAnnounceID
			resetVerifyCode
		End If
	else
		If AjaxFlag = 1 Then
			Response.Clear
			Response.Write "success|" & NewAnnounceID
			resetVerifyCode
		end if
	End If
	If AjaxFlag = 0 Then Global_TableBottom

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

Function GetReContent(str)

	Dim in1,in2,Str2
	in1 = inStr(str,"[QUOTE]")
	if in1 > 0 Then
		in2 = inStr(str,"[/QUOTE]")
	Else
		in2 = 0
	End If
	If in1 = 0 or in2 = 0 or in1 >= in2 Then
		GetReContent = str
		Exit Function
	End If
	Str2 = Left(str,in1-1) & Mid(str,in2+8)
	If Left(Str2,2) = VbCrLf Then Str2 = Mid(Str2,3)
	If Replace(Trim(Str2),VbCrLf,"") = "" Then Str2 = Replace(Replace(Str,"[QUOTE]",""),"[/QUOTE]","")
	GetReContent = Str2

End Function

Function GetTopicInfo

	If Re_ID = 0 Then Exit Function
	Dim ThisParentID,TmpContent,LMT_LastTime
	ThisParentID = 1
	Dim Rs,SQL,Form_TopicType,Form_NeedValue,TParentID
	dim Re_TrueName,Re_Uid

	TParentID = -1
	
	Dim RootIDBak

	Dim ac,rd
	ac = Request.QueryString("ac")
	rd = Left(Request.QueryString("rd"),14)
	If isNumeric(rd) = 0 or inStr(rd,".") then rd = 0
	rd = cCur(rd)
	If rd = 0 Then
		SQL = ""
	Else
		Select Case ac
			Case "pre": SQL = sql_select("Select t1.ID,t1.RootID,t1.TopicType,t1.NeedValue,t1.ParentID,t1.ChildNum,t1.Title,t1.hits,t1.NotReplay,t1.Content,t1.UserName,t1.RootIDBak,t1.TitleStyle,t1.Opinion,t1.HtmlFlag,T2.UserLimit,T1.VisitIP,T1.RootMaxID,T1.RootMinID,T1.LastTime,T2.TrueName,T2.ID from LeadBBS_Announce as T1 left join LeadBBS_User as T2 on T1.UserID=T2.ID where t1.ParentID=0 and t1.boardid=" & GBL_board_ID & " and t1.RootID>" & rd & " order by t1.RootID ASC",1)
			Case "nxt": SQL = sql_select("Select t1.ID,t1.RootID,t1.TopicType,t1.NeedValue,t1.ParentID,t1.ChildNum,t1.Title,t1.hits,t1.NotReplay,t1.Content,t1.UserName,t1.RootIDBak,t1.TitleStyle,t1.Opinion,t1.HtmlFlag,T2.UserLimit,T1.VisitIP,T1.RootMaxID,T1.RootMinID,T1.LastTime,T2.TrueName,T2.ID from LeadBBS_Announce as T1 left join LeadBBS_User as T2 on T1.UserID=T2.ID where t1.ParentID=0 and t1.boardid=" & GBL_board_ID & " and t1.RootID<" & rd & " order by t1.RootID DESC",1)
			Case Else: SQL = ""
		End Select
	End If

	If SQL <> "" Then
		Set Rs = LDExeCute(SQL,0)
		If Not Rs.Eof Then
			Re_ID = cCur(Rs(0))
			'LMT_RootIDBak = Re_ID
			LMT_RootIDBak = cCur(Rs(11))
			LMT_RootID = cCur(Rs(1))
			Form_TopicType = Rs(2)
			Form_NeedValue = Rs(3)
			TParentID = cCur(Rs(4))
			ThisParentID = TParentID
			LMT_ChildNum = cCur(Rs(5))
			LMT_TopicName = Rs(6)
			'Rs(7) = cCur(Rs(7)) + 1
			A_NotReplay = Rs(8)
			Topic_UserName = Rs(10) & ""
			LMT_ReName = Topic_UserName
			Re_TrueName = Rs(20)
			Re_Uid = ccur("0" & Rs(21))
			RootIDBak = Rs(11)
			LMT_TopicTitleStyle = Rs(12)
			ac = Trim(Rs(16))
			If GetBinarybit(Rs(15),7) = 1 or Form_Submitflag <> "first" or Request.QueryString("repost") <> "1" or LMT_TopicTitleStyle >= 60 or (Form_TopicType > 0 and Form_TopicType <> 80) Then
				'TmpContent = "此用户发言已经被管理员屏蔽，引用内容无效。"
			Else
				Select Case Rs(14)
					Case 0: TmpContent = GetReContent(ResumeCode(Rs(9)))
					Case 1: TmpContent = KillHTMLLabel(GetReContent(Left(Rs(9),500)))
					Case 2: 
							'If LMT_DefaultEdit = 0 Then
							'	TmpContent = clearUbbcode(GetReContent(Rs(9)))
							'Else
								TmpContent = clearUbbcode(GetReContent(Rs(9)))
							'End If
					Case 3: 
							'If LMT_DefaultEdit = 0 Then
							'	TmpContent = clearUbbcode(GetReContent(ResumeCode(Rs(9))))
							'Else
								TmpContent = clearUbbcode(GetReContent(ResumeCode(Rs(9))))
							'End If
							Form_HTMLFlag = 2
				End Select
				Do While Right(TmpContent,2) = VbCrLf
					TmpContent = Mid(TmpContent,1,len(TmpContent)-2)
				Loop
				If Len(TmpContent)>100 Then
					Form_Content = "[QUOTE][b]下面引用由[@" & GetTrueNameID(LMT_ReName,Re_TrueName,Re_Uid) & "]发表的内容：[/b]" & VbCrLf & Left(TmpContent,100) & "...[/QUOTE]" & VbCrLf
				Else
					Form_Content = "[QUOTE][b]下面引用由[@" & GetTrueNameID(LMT_ReName,Re_TrueName,Re_Uid) & "]发表的内容：[/b]" & VbCrLf & TmpContent & "[/QUOTE]" & VbCrLf
				End If
				'If LMT_DefaultEdit = 0 Then Form_Content = UBB_Code(Form_Content)
			End If
			Form_RootMaxID = cCur(Rs(17))
			LMT_LastTime = cCur(Rs(19))
			Form_Hits = cCur(Rs(7)) + 1
			Rs.Close
			Set Rs = Nothing
		Else
			Rs.Close
			Set Rs = Nothing
		End If
	End If

	If TParentID = -1 Then
		SQL = sql_select("Select T1.RootID,t1.TopicType,t1.NeedValue,t1.ParentID,t1.ChildNum,t1.Hits,t1.title,t1.NotReplay,t1.Content,t1.UserName,t1.RootIDBak,t1.BoardID,t1.TitleStyle,t1.Opinion,t1.HtmlFlag,T2.UserLimit,T1.VisitIP,T1.RootMaxID,T1.RootMinID,T1.LastTime,T2.TrueName,T2.ID from LeadBBS_Announce as T1 left join LeadBBS_User as T2 on T1.UserID=T2.ID where T1.ID=" & Re_ID,1)
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			Rs.Close
			Set Rs = Nothing
			GBL_CHK_TempStr = "错误,该主题不存在!<br>" & VbCrLf
			Exit Function
		Else
			If cCur(Rs(11)) <> GBL_board_ID Then
				Rs.Close
				Set Rs = Nothing
				GBL_CHK_TempStr = "错误,该主题不存在!<br>" & VbCrLf
				Exit Function
			Else
				LMT_RootID = Rs(0)
				'LMT_RootIDBak = Re_ID
				Form_TopicType = Rs(1)
				Form_NeedValue = Rs(2)
				TParentID = cCur(Rs(3))
				ThisParentID = TParentID
				LMT_ChildNum = cCur(Rs(4))
				'Rs(5) = cCur(Rs(5)) + 1
				LMT_TopicName = Rs(6)
				A_NotReplay = Rs(7)
				RootIDBak = Rs(10)
				LMT_RootIDBak = cCur(RootIDBak)
				Topic_UserName = Rs(9)
				LMT_ReName = Topic_UserName
				
				Re_TrueName = Rs(20)
				Re_Uid = ccur("0" & Rs(21))
				LMT_TopicTitleStyle = Rs(12)

				ac = Trim(Rs(16))
				If GetBinarybit(Rs(15),7) = 1 or Form_Submitflag <> "first" or Request.QueryString("repost") <> "1" or LMT_TopicTitleStyle >= 60 or (Form_TopicType > 0 and Form_TopicType <> 80) Then
					'TmpContent = "此用户发言已经被管理员屏蔽，引用内容无效。"
				Else
					Select Case Rs(14)
						Case 0: TmpContent = GetReContent(ResumeCode(Rs(8)))
						Case 1: TmpContent = KillHTMLLabel(GetReContent(Left(Rs(8),500)))
						Case 2: 
								'If LMT_DefaultEdit = 0 Then
								'	TmpContent = clearUbbcode(GetReContent(Rs(8)))
								'Else
									TmpContent = clearUbbcode(GetReContent(Rs(8)))
								'End If
						Case 3: 
								'If LMT_DefaultEdit = 0 Then
								'	TmpContent = clearUbbcode(GetReContent(ResumeCode(Rs(8))))
								'Else
									TmpContent = clearUbbcode(GetReContent(ResumeCode(Rs(8))))
								'End If
								Form_HTMLFlag = 2
					End Select
					Do While Right(TmpContent,2) = VbCrLf
						TmpContent = Mid(TmpContent,1,len(TmpContent)-2)
					Loop
					If Form_Submitflag = "first" and Request.QueryString("repost") = "1" Then
						If Len(TmpContent)>100 Then
							Form_Content = "[QUOTE][b]下面引用由[@" & GetTrueNameID(LMT_ReName,Re_TrueName,Re_Uid) & "]发表的内容：[/b]" & VbCrLf & VbCrLf & Left(TmpContent,100) & "...[/QUOTE]" & VbCrLf
						Else
							Form_Content = "[QUOTE][b]下面引用由[@" & GetTrueNameID(LMT_ReName,Re_TrueName,Re_Uid) & "]发表的内容：[/b]" & VbCrLf & VbCrLf & TmpContent & "[/QUOTE]" & VbCrLf
						End If
						'If LMT_DefaultEdit = 0 Then Form_Content = UBB_Code(Form_Content)
					End If
				End If
				Form_RootMaxID = cCur(Rs(17))
				LMT_LastTime = cCur(Rs(19))
				Form_Hits = cCur(Rs(5)) + 1
				Rs.Close
				Set Rs = Nothing
			End If
		End If
	End If

	If TParentID > 0 Then
		If cCur(RootIDBak) > 0 Then
			select case DEF_UsedDataBase
				case 0,2:
					SQL = sql_select("Select Title,Hits,ChildNum,ID,TitleStyle,NotReplay,RootIDBak,RootID,RootMaxID,RootMinID,UserName,TopicType,NeedValue,LastTime from LeadBBS_Announce where ParentID=0 and RootIDBak=" & RootIDBak & " order by ID ASC",1)
				case Else
					SQL = sql_select("Select Title,Hits,ChildNum,ID,TitleStyle,NotReplay,ID,RootID,RootMaxID,RootMinID,UserName,TopicType,NeedValue,LastTime from LeadBBS_Topic where ID=" & RootIDBak & " order by ID ASC",1)
			End select
		Else
			select case DEF_UsedDataBase
				case 0,2:
					SQL = sql_select("Select Title,Hits,ChildNum,ID,TitleStyle,NotReplay,RootIDBak,RootID,RootMaxID,RootMinID,UserName,TopicType,NeedValue,LastTime from LeadBBS_Announce where ParentID=0 and boardid=" & GBL_board_ID & " and RootID=" & LMT_RootID,1)
				case Else
					SQL = sql_select("Select Title,Hits,ChildNum,ID,TitleStyle,NotReplay,id,RootID,RootMaxID,RootMinID,UserName,TopicType,NeedValue,LastTime from LeadBBS_Topic where boardid=" & GBL_board_ID & " and RootID=" & LMT_RootID,1)
			End select
		End If
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			Rs.Close
			Set Rs = Nothing
			GBL_CHK_TempStr = "错误,该主题已经删除!<br>" & VbCrLf
			Exit Function
		Else
			LMT_TopicName = Rs(0)
			LMT_ChildNum = cCur(Rs(2))
			LMT_RootIDBak = cCur(Rs(6))
			LMT_TopicTitleStyle = Rs(4)
			If A_NotReplay = 0 Then A_NotReplay = Rs(5)
			LMT_RootID = cCur(Rs(7))
			Form_RootMaxID = cCur(Rs(8))
			Topic_UserName = Rs(10)
			Form_TopicType = Rs(11)
			Form_NeedValue = Rs(12)
			LMT_LastTime = cCur(Rs(13))
			Rs.Close
			Set Rs = Nothing
		End If
	End If

	If Form_TopicType = 39 Then
		GBL_CHK_TempStr = "镜像帖无法回复。<br>" & VbCrLf
		A_NotReplay = 1
		Exit Function
	End If
	If Form_TopicType > 0 and A_NotReplay = 0 and Form_TopicType <> 80 Then
		Form_NeedValue = cCur(Form_NeedValue)
		Select case Form_TopicType
			Case 2:
				If GBL_CHK_User <> "" Then
					If GBL_BoardMasterFlag < 5 Then
						A_NotReplay = 1
						If Form_Submitflag <> "" Then GBL_CHK_TempStr = "错误,只有本版" & DEF_PointsName(8) & "才能回复此帖!<br>" & VbCrLf
					End If
				Else
					A_NotReplay = 1
				End If
			Case 4:
				If GBL_BoardMasterFlag < 4 Then
					A_NotReplay = 1
					If Form_Submitflag <> "" Then GBL_CHK_TempStr = "错误,只有" & DEF_PointsName(8) & "才能回复此帖!<br>" & VbCrLf
				End If
			Case 6:
				If GBL_CHK_User = "" or GetBinarybit(GBL_CHK_UserLimit,2) <> 1 Then
					A_NotReplay = 1
					If Form_Submitflag <> "" Then GBL_CHK_TempStr = "错误,只有" & DEF_PointsName(5) & "才能回复此帖!<br>" & VbCrLf
				End If
			Case 51:
				If GBL_CHK_Points < Form_NeedValue Then
					A_NotReplay = 1
					If Form_Submitflag <> "" Then GBL_CHK_TempStr = "错误,需要" & DEF_PointsName(0) & "" & Form_NeedValue & "以上才能回复此帖!<br>" & VbCrLf
				End If
			Case 53:
				If GBL_CHK_OnlineTime < Form_NeedValue*60 Then
					A_NotReplay = 1
					If Form_Submitflag <> "" Then GBL_CHK_TempStr = "错误,需要" & DEF_PointsName(4) & Form_NeedValue & "以上才能回复此帖!<br>" & VbCrLf
				End If
			Case 55:
					If Form_NeedValue > 0 and Form_Submitflag <> "" Then
						If Form_NeedValue <> GBL_UserID and GBL_CHK_User <> Topic_UserName Then
							A_NotReplay = 1
							GBL_CHK_TempStr = "此帖只允许发帖人和接收人回复"
						End If
					End If
		End Select
	End If

	Dim RootTopicNeedValue
	
		
	If Len(LMT_LastTime) = 14 and GBL_BoardMasterFlag < 4 Then
		If DateDiff("d",ReStoreTime(LMT_LastTime),Now) > LMTDEF_NotReplyDate Then
			If Form_Submitflag <> "" Then GBL_CHK_TempStr = "此主题最后回复时间超过" & LMTDEF_NotReplyDate & "天，不能再作回复！"
			A_NotReplay = 1 '
		End If
	End If
	If Form_TopicType > 0 And Form_TopicType <> 80 and Form_Submitflag = "first" and ThisParentID = 0 and Request.QueryString("repost") = "1" Then
		RootTopicNeedValue = cCur(Form_NeedValue)
		RootTopicType = Form_TopicType
		Select case RootTopicType
			Case 1:
				If GBL_CHK_User <> "" Then
					If GBL_BoardMasterFlag < 5 Then
						GBL_CHK_TempStr = "此帖只有本版" & DEF_PointsName(8) & "才能引用回复"
					End If
				Else
					GBL_CHK_TempStr = "此帖只有本版" & DEF_PointsName(8) & "才能引用回复"
				End If
			Case 3:
				If GBL_BoardMasterFlag < 4 Then
					GBL_CHK_TempStr = "此帖只有" & DEF_PointsName(8) & "才能引用回复"
				End If
			Case 5:
				If GBL_CHK_User = "" or GetBinarybit(GBL_CHK_UserLimit,2) <> 1 Then
					GBL_CHK_TempStr = "此帖只有" & DEF_PointsName(5) & "才能引用回复"
				End If
			Case 7,54,49:
				If Form_Submitflag = "first" and Request.QueryString("repost") = "1" Then
					A_NotReplay = 1
					GBL_CHK_TempStr = "错误，此帖不能引用回复！<br>" & VbCrLf
				End If
			Case 50:
				If GBL_CHK_Points < RootTopicNeedValue Then
					GBL_CHK_TempStr = "此帖需要" & DEF_PointsName(0) & "" & RootTopicNeedValue & "才能引用回复"
				End If
			Case 52:
				If GBL_CHK_OnlineTime < RootTopicNeedValue*60 Then
					GBL_CHK_TempStr = "此帖需要" & DEF_PointsName(4) & RootTopicNeedValue & "才能引用回复"
				End If
			Case 115:
					If Form_NeedValue > 0 Then
						If Form_NeedValue <> GBL_UserID and GBL_CHK_User <> Topic_UserName Then
							A_NotReplay = 1
							GBL_CHK_TempStr = "此帖只允许发帖人和接收人回复"
						End If
					End If
		End Select
	End If

End Function

Function UpdateUserLevel(UserID)

	Dim Temp_N,UserLevel,Points,OnlineTime,Save_UserLevel
	Dim Rs
	Set Rs = LDExeCute(sql_select("Select UserLevel,AnnounceNum2,OnlineTime from LeadBBS_User where id=" & UserID,1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		Exit Function
	End If
	UserLevel = Rs(0)
	Save_UserLevel = UserLevel
	Points = cCur(Rs(1))
	OnlineTime = cCur(Rs(2))
	Rs.Close
	Set Rs = Nothing

	For Temp_N = 0 To DEF_UserLevelNum
		'自动重新计算等级
		'If Points >= DEF_UserLevelPoints(Temp_N) Then UserLevel = Temp_N
		If Points >= DEF_UserLevelPoints(Temp_N) and Temp_N >= UserLevel Then UserLevel = Temp_N
	Next

	Randomize

	REM **** 旧财富机率设定开始 *****
	'vvv = Fix(Rnd*1314)+1
	'If vvv = 1314 Then
	'	vvv = 1
	'	Response.Write "<br>&nbsp;<font color=""blue"" class=""bluefont"">你历经辛苦，终于遇到" & DEF_PointsName(1) & "之神，赐予你新的" & DEF_PointsName(1) & "！</font><br>"
REM *******Chat Start*******
	'CALL Chat_Appand_pop(3,"<b><span onclick=""c_sc(this.innerHTML)"" style=""cursor: pointer"" class=""c_name"">" & GBL_CHK_User & "</span>历经辛苦，终于遇到" & DEF_PointsName(1) & "之神，并赐予新的" & DEF_PointsName(1) & "！</b>")
REM *******Chat End*********
	'Else
	'	vvv = 0
	'End If
	REM **** 旧财富机率结束 *****
	
	REM **** 特定帖奖励设定开始 *****
	
	'定义需要奖励的帖子ID编号,只限主题编号
	Dim AncIDStr
	AncIDStr = "" '红包帖子主题ID列表，逗号分隔，回复此类帖子将奖励随机声望(1-3)，注意与[DelAnnounce.asp]配置保持一致

	Dim Tn,vvv
	vvv = 0
	If Re_ID > 0 and GBL_CHK_OnlineTime > 3600 and inStr("," & AncIDStr & ",","," & LMT_RootIDBak & ",") Then
		'Set Rs = LDExeCute(sql_select("Select ID,Opinion from LeadBBS_Announce where UserID=" & GBL_UserID & " and ParentID=" & LMT_RootIDBak,10),0)
		set rs = ldexecute(sql_select("Select ID,Opinion from LeadBBS_Announce where rootidbak=" & LMT_RootIDBak & " and UserID=" & GBL_UserID,10),0)
		Dim FirFlag,Opinion
		FirFlag = 0
		Opinion = ""

		Do While Opinion = "" and Not Rs.Eof
			if ccur(rs(0)) <> LMT_RootIDBak then Opinion = Opinion & Rs(1)
			Rs.MoveNext
		Loop
		If Opinion = "" Then
			FirFlag = 1
		Else
			FirFlag = 0
		End If
		Rs.Close
		Set Rs = Nothing

		If FirFlag = 1 Then
			Dim Tmp
			Tmp = Fix(Rnd*1314)+1
			If Tmp = 1314 Then
				vvv = 3
			ElseIf Tmp > 1200 Then
				vvv = 2
			Else
				vvv = 1
			End If
			CALL LDExeCute("Update LeadBBS_Announce Set Opinion='" & "[LeadBBS]|0|幸运指数" & Tmp & "共获得" & DEF_PointsName(2) & "" & vvv & "' where ID=" & NewAnnounceID,1)
			Response.Write "<br>&nbsp;<font color=red class=redfont>恭喜，因回复此帖赐予您新的" & DEF_PointsName(2) & "！</font><br>"
			add_tips(DEF_PointsName(2) & "+" & vvv)
		End If
	End If
	REM **** 特定帖奖励设定结束 *****

	If Save_UserLevel <> UserLevel or vvv >= 1 Then
		CALL LDExeCute("Update LeadBBS_User set UserLevel=" & UserLevel & ",CachetValue=CachetValue+" & vvv & " where id=" & UserID,1)
		add_tips("<span class=""greenfont"">" & "升级了，" & DEF_UserLevelString(UserLevel) & "！</span>")
		UpdateSessionValue 15,vvv,1
	End If
	If vvv >= 1 Then
		UpdateUserLevel = 1
	Else
		UpdateUserLevel = 0
	End If

End Function

Function UpdateBoardAnnounceNum(BoardList,TopicNum,AnnounceNum,TodayAnnounce,GoodNum,LastWriter,LastWriteTime,LastAnnounceID,LastTopicName)

	Dim SafeFlag
	SafeFlag = 0
	'密码论坛 认证版面 专业用户版面 仅限版主版面
	If GBL_Board_ForumPass <> "" or GetBinarybit(GBL_Board_BoardLimit,2) = 1 or GetBinarybit(GBL_Board_BoardLimit,15) = 1 or GetBinarybit(GBL_Board_BoardLimit,7) = 1 Then SafeFlag = 1
	Dim SQL,N,Num
	If BoardList = "" or (TopicNum = 0 and AnnounceNum = 0 and TodayAnnounce = 0 and GoodNum = 0) Then Exit Function
	SQL = "Update LeadBBS_Boards Set AnnounceNum=AnnounceNum+" & AnnounceNum & ",AnnounceNum_All=AnnounceNum_All+" & AnnounceNum
	If TopicNum <> 0 Then SQL = SQL & ",TopicNum=TopicNum+" & TopicNum
	If TopicNum <> 0 Then SQL = SQL & ",TopicNum_All=TopicNum_All+" & TopicNum
	If TodayAnnounce <> 0 Then  SQL = SQL & ",TodayAnnounce=TodayAnnounce+" & TodayAnnounce
	If TodayAnnounce <> 0 Then  SQL = SQL & ",TodayAnnounce_All=TodayAnnounce_All+" & TodayAnnounce
	If GoodNum <> 0 Then SQL = SQL & ",GoodNum=GoodNum+" & GoodNum
	If GoodNum <> 0 Then SQL = SQL & ",GoodNum_All=GoodNum_All+" & GoodNum
	If inStr(BoardList,",") = False Then
		If LastWriter <> "" Then SQL = SQL & ",LastWriter='" & Replace(LastWriter,"'","''") & "'"
		If cCur(LastWriteTime) > 0 Then SQL = SQL & ",LastWriteTime=" & LastWriteTime
		If LastTopicName <> "" Then SQL = SQL & ",LastTopicName='" & Replace(LastTopicName,"'","''") & "'"
		If cCur(LastAnnounceID) > 0 Then SQL = SQL & ",LastAnnounceID=" & LastAnnounceID
		SQL = SQL & " where BoardID=" & GBL_Board_ID
		CALL LDExeCute(SQL,1)
	Else
		If SafeFlag = 0 Then '加密版面不更新上级版面最新发表
			If LastWriter <> "" Then SQL = SQL & ",LastWriter='" & Replace(LastWriter,"'","''") & "'"
			If cCur(LastWriteTime) > 0 Then SQL = SQL & ",LastWriteTime=" & LastWriteTime
			If LastTopicName <> "" Then SQL = SQL & ",LastTopicName='" & Replace(LastTopicName,"'","''") & "'"
			If cCur(LastAnnounceID) > 0 Then SQL = SQL & ",LastAnnounceID=" & LastAnnounceID
		End If
		SQL = SQL & " where BoardID in(" & BoardList & "," & GBL_Board_ID & ")"
		CALL LDExeCute(SQL,1)
	End If
	BoardList = Split(BoardList,",")
	Num = Ubound(BoardList,1)
	Dim Temp
	For N = 0 To Num
		Temp = Application(DEF_MasterCookies & "BoardInfo" & BoardList(N))
		If isArray(Temp) = False Then
			ReloadBoardInfo(BoardList(N))
			Temp = Application(DEF_MasterCookies & "BoardInfo" & BoardList(N))
		End If
		If isArray(Temp) = True Then
			'发帖数量统计信息无视版面保密情况更新
			If TopicNum <> 0 Then
				UpdateBoardApplicationInfo BoardList(N),cCur(Temp(5,0))+TopicNum,5
				UpdateBoardApplicationInfo BoardList(N),cCur(Temp(29,0))+TopicNum,29
			End If
			If AnnounceNum <> 0 Then
				UpdateBoardApplicationInfo BoardList(N),cCur(Temp(6,0))+AnnounceNum,6
				UpdateBoardApplicationInfo BoardList(N),cCur(Temp(30,0))+AnnounceNum,30
			End If
			If TodayAnnounce <> 0 Then
				UpdateBoardApplicationInfo BoardList(N),cCur(Temp(18,0))+TodayAnnounce,18
				UpdateBoardApplicationInfo BoardList(N),cCur(Temp(31,0))+TodayAnnounce,31
			End If
			If GoodNum <> 0 Then
				UpdateBoardApplicationInfo BoardList(N),cCur(Temp(13,0))+GoodNum,13
				UpdateBoardApplicationInfo BoardList(N),cCur(Temp(32,0))+GoodNum,32
			End If
			If (SafeFlag = 1 and GBL_Board_ID = cCur(BoardList(N))) or SafeFlag = 0 Then
				If SafeFlag = 0 Then	
					If LastWriter <> "" Then UpdateBoardApplicationInfo BoardList(N),LastWriter,3
					If cCur(LastWriteTime) > 0 Then UpdateBoardApplicationInfo BoardList(N),Form_LastTime,4
					If LastTopicName <> "" Then UpdateBoardApplicationInfo BoardList(N),LastTopicName,20
				End If
				If SafeFlag = 1 or Num = 0 or GBL_Board_ID = cCur(BoardList(N)) Then
					If cCur(LastAnnounceID) > 0 Then UpdateBoardApplicationInfo BoardList(N),LastAnnounceID,19
				Else
					'If cCur(LastAnnounceID) > 0 Then UpdateBoardApplicationInfo BoardList(N),0,19
					If cCur(LastAnnounceID) > 0 Then UpdateBoardApplicationInfo BoardList(N),LastAnnounceID,19
				End If
			End If
		End If
	Next
	'28,T1.ParentBoardStr,29.TopicNum_All,30.AnnounceNum_All,31.TodayAnnounce_All,32.GoodNum_All

End Function

Sub Announce_ErrorMsg(str)

	If AjaxFlag = 1 Then Response.Clear
	Global_ErrMsg AjaxFlagPrint & GBL_CHK_TempStr

End Sub

Sub Main

	If dontRequestFormFlag = "" Then
		Select Case Left(Request.Form("ol"),1)
			Case "1":
				CALL Editor_View(Edt_MiniMode,"")
				Exit Sub
		End Select
	End If

	GetBoardID
	initDatabase
	Free_UDT
	GetRequestValue
	CheckisBoardMaster
	GBL_CHK_TempStr = ""
	If Re_ID > 0 Then Form_VoteFlag = ""
	GetTopicInfo

	If GetBinarybit(GBL_Board_BoardLimit,16) = 1 Then
		If LMT_DefaultEdit = 1 Then
			LMT_DefaultEdit = 0
		Else
			LMT_DefaultEdit = 1
		End If
	End If

	If LMT_TopicTitleStyle >= 60 and GBL_BoardMasterFlag < 4 Then
		LMT_TopicNameNoHTML = "帖子等待审核中..."
		LMT_TopicName = "<font color=gray class=grayfont>帖子等待审核中...</font>"
		'LMT_TopicTitleStyle = 1
		A_NotReplay = 1
	Else
		If LMT_TopicTitleStyle = 1 Then
			LMT_TopicNameNoHTML = KillHTMLLabel(LMT_TopicName)
		Else
			LMT_TopicNameNoHTML = LMT_TopicName
		End If
	End If
	LMT_TopicNameNoHTML_Temp = LMT_TopicNameNoHTML
	
	If strLength(LMT_TopicNameNoHTML_Temp)>DEF_BBS_DisplayTopicLength-6 Then
		LMT_TopicNameNoHTML_Temp = htmlencode(LeftTrue(LMT_TopicNameNoHTML_Temp,DEF_BBS_DisplayTopicLength-9)) & "..."
	Else
		LMT_TopicNameNoHTML_Temp = htmlencode(LMT_TopicNameNoHTML_Temp)
	End if
	If Re_ID > 0 Then
		CheckAccessLimit_TimeLimit
		LMT_TopicNameNoHTML_Temp = "回复：" & LMT_TopicNameNoHTML_Temp
		If AjaxFlag = 0 Then BBS_SiteHead DEF_SiteNameString & " - " & KillHTMLLabel(GBL_Board_BoardName) & " - 回复帖子",GBL_board_ID,"回复帖子"
	Else
		CheckAccessLimit_TimeLimit
		If Form_VoteFlag <> "" and Re_ID = 0 Then
			LMT_TopicNameNoHTML_Temp = "发表新投票"
		Else
			LMT_TopicNameNoHTML_Temp = "发表新帖子"
		End If
		If AjaxFlag = 0 Then BBS_SiteHead DEF_SiteNameString & " - " & KillHTMLLabel(GBL_Board_BoardName) & " - " & LMT_TopicNameNoHTML_Temp,GBL_board_ID,"" & LMT_TopicNameNoHTML_Temp & ""
	End If

	If AjaxFlag = 0 Then Boards_Body_Head("")
	CheckAccessLimit
	If Form_Submitflag <> "" or Re_ID = 0 Then
		If Re_ID = 0 Then
			CheckBoardAnnounceLimit
		Else
			CheckBoardReAnnounceLimit
		End If
		CheckUserAnnounceLimit
	End If
	If GBL_CHK_TempStr = "" Then
		If Form_Submitflag = "" Then
			'GetRequestValue
			Form_NoUserUnderWriteFlag=1
			If Re_ID<>0 Then
				If Left(LMT_TopicName,3) <> "Re:" Then
					Form_Title = "Re:" & LMT_TopicNameNoHTML
				Else
					Form_Title = LMT_TopicNameNoHTML4
				End If
				'Form_Title = ""
			End If
			DisplayAnnounceForm
			GBL_CHK_TempStr = ""
		Else
			If A_NotReplay = 0 and LMT_ChildNum > LMTDEF_MaxReAnnounce and 1 <> 1 Then
				Announce_ErrorMsg "回复已经达到最大数目,不能再回复帖子,请另开主题。"
				GBL_CHK_TempStr = " "
			ElseIf A_NotReplay = 1 and Form_Submitflag = "first" Then
				Announce_ErrorMsg "此帖处于锁定状态，不允许回复。"
				GBL_CHK_TempStr = " "
			Else
				If CheckAnnouceValue = 1 Then
					If SaveAnnounceValue = 1 Then
						DisplayAnnounceAccessfull
					Else
						If AjaxFlag = 1 Then Response.Clear
						If Form_Submitflag <> "first" Then
							Announce_ErrorMsg AjaxFlagPrint & GBL_CHK_TempStr
							GBL_CHK_TempStr = " "
						End If
						If AjaxFlag = 0 Then DisplayAnnounceForm
					End If
				Else
					If AjaxFlag = 1 Then Response.Clear
					If Form_Submitflag <> "first" Then
						Announce_ErrorMsg AjaxFlagPrint & GBL_CHK_TempStr
					End If
					If AjaxFlag = 0 Then DisplayAnnounceForm
				End If
			End If
		End If
		If AjaxFlag = 0 Then UpdateOnlineUserAtInfo GBL_board_ID,GBL_Board_BoardName & "→" & LMT_TopicNameNoHTML_Temp
	Else
		If AjaxFlag = 1 Then Response.Clear
		Announce_ErrorMsg AjaxFlagPrint & GBL_CHK_TempStr
	End If
	If Form_UpFlag = 1 Then Set Form_UpClass = Nothing
	CloseDatabase
	If AjaxFlag = 0 Then Boards_Body_Bottom
	If AjaxFlag = 0 Then SiteBottom

End Sub

Main
%>