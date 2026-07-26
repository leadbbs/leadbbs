<!-- #include file=../inc/BBSsetup.asp -->
<!-- #include file=../inc/Board_Popfun.asp -->
<!-- #include file=inc/UserTopic.asp -->
<%
DEF_BBS_HomeUrl = "../"
Const LMT_LookedMsgExpiresDay = 15 '短消息阅读后的保存期限(单位天)
Dim SdM_ID,SdM_Fromuser,SdM_toUser,SdM_Title,SdM_Content,SdM_IP,SdM_SendTime,SdM_ReadFlag
Dim AllPrintingString

Main

Sub Main

	initDatabase
	GBL_CHK_TempStr = ""
	
	Dim MessageID
	MessageID = Left(Request("MessageID"),14)
	If isNumeric(MessageID) = 0 or MessageID = "" or InStr(MessageID,",") > 0 Then MessageID = 0
	MessageID = Fix(cCur(MessageID))
	
	If MessageID < 0 Then MessageID = 0
	
	AllPrintingString = ""
	If Request.QueryString("AllPrinting")="Yesing" and CheckSupervisorUserName = 1 Then AllPrintingString = "&AllPrinting=Yesing"
	
	GBL_CHK_TempStr=""
	If GBL_UserID = 0 Then GBL_CHK_TempStr = GBL_CHK_TempStr & "你未登录,无法进行此操作." & VbCrLf
	
	
	If MessageID > 0 Then
		BBS_SiteHead DEF_SiteNameString & " - 查看短消息",0,"查看短消息"
		UpdateOnlineUserAtInfo GBL_board_ID,"查看短消息"
		UserTopicTopInfo("user")
	Else
		GBL_CHK_Flag = 0
		BBS_SiteHead DEF_SiteNameString & " - 公告",0,"公告"
		UpdateOnlineUserAtInfo GBL_board_ID,"查看公告"
		UserTopicTopInfo("")
	End If
	If MessageID = 0 Then
		LookPubMessage
	Else
		If GBL_CHK_TempStr <> "" Then
			Response.Write "<div class=alert>" & GBL_CHK_TempStr & "</div>"
		Else
			If MessageID = 0 Then
				GBL_CHK_TempStr = GBL_CHK_TempStr & "错误，找不到这条消息." & VbCrLf
				Response.Write "<div class=alert>" & GBL_CHK_TempStr & "</div>"
			Else
				GBL_CHK_TempStr = ""
				GetMessageValue(MessageID)
				If GBL_CHK_TempStr = "" Then
					LookMessage(MessageID)
				Else
					Response.Write "<div class=alert>" & GBL_CHK_TempStr & "</div>"
				End If
			End if
		End If
	End If
	UserTopicBottomInfo
	closeDataBase
	SiteBottom

End Sub

Function GetMessageValue(MessageID)

	Dim Rs,SQL
	Dim go
	go = Left(Request.QueryString("go"),4)
	If go = "pre" Then
		If CheckSupervisorUserName = 1 and AllPrintingString <> "" Then
			SQL = sql_select("Select ID,FromUser,toUser,Title,Content,IP,SendTime,ReadFlag from LeadBBS_InfoBox where ID>" & MessageID & " order by ID ASC",1)
		Else
			SQL = sql_select("Select ID,FromUser,toUser,Title,Content,IP,SendTime,ReadFlag from LeadBBS_InfoBox where ToUser='" & Replace(GBL_CHK_User,"'","''") & "' and ID>" & MessageID & " order by ID ASC",1)
		End If
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			Rs.Close
			Set Rs = Nothing
			SQL = sql_select("Select ID,FromUser,toUser,Title,Content,IP,SendTime,ReadFlag from LeadBBS_InfoBox where ID=" & MessageID,1)
			Set Rs = LDExeCute(SQL,0)
		End If
	ElseIf go = "next" Then
		If CheckSupervisorUserName = 1 and AllPrintingString <> "" Then
			SQL = sql_select("Select ID,FromUser,toUser,Title,Content,IP,SendTime,ReadFlag from LeadBBS_InfoBox where ID<" & MessageID & " order by ID DESC",1)
		Else
			SQL = sql_select("Select ID,FromUser,toUser,Title,Content,IP,SendTime,ReadFlag from LeadBBS_InfoBox where ToUser='" & Replace(GBL_CHK_User,"'","''") & "' and ID<" & MessageID & " order by ID DESC",1)
		End If
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			Rs.Close
			Set Rs = Nothing
			SQL = sql_select("Select ID,FromUser,toUser,Title,Content,IP,SendTime,ReadFlag from LeadBBS_InfoBox where ID=" & MessageID,1)
			Set Rs = LDExeCute(SQL,0)
		End If
	Else
		SQL = sql_select("Select ID,FromUser,toUser,Title,Content,IP,SendTime,ReadFlag from LeadBBS_InfoBox where ID=" & MessageID,1)
		Set Rs = LDExeCute(SQL,0)
	End If

	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		GBL_CHK_TempStr = "无相关短消息。"
	Else
		SdM_ID = cCur(Rs(0))
		SdM_FromUser = Rs(1)
		SdM_toUser = Rs(2)
		SdM_Title = Rs(3)
		SdM_Content = Rs(4)
		SdM_IP = Rs(5)
		SdM_SendTime = cCur(Rs(6))
		SdM_ReadFlag = cCur(Rs(7))
		Rs.Close
		Set Rs = Nothing
		If SdM_FromUser <> GBL_CHK_User and lcase(SdM_toUser) <> lcase(GBL_CHK_User) Then
			'GBL_CHK_TempStr = "无权限阅读他人消息。"
		Else
			If SdM_ReadFlag = 0 and lcase(SdM_toUser) = lcase(GBL_CHK_User) Then
				CALL LDExeCute("Update LeadBBS_InfoBox Set readFlag=1,ExpiresDate=" & CLng(Left(GetTimeValue(DateAdd("d",LMT_LookedMsgExpiresDay,Now)),8)) & " where ID=" & SdM_ID,1)
			End If
		End If
	End If
	If GBL_CHK_MessageFlag = 1 Then
		SQL = sql_select("Select ID from LeadBBS_InfoBox where ReadFlag=0 and ToUser='" & Replace(GBL_CHK_User,"'","''") & "'",1)
		Set Rs = LDExeCute(SQL,0)
		
		If Rs.Eof Then
			Rs.Close
			Set Rs = Nothing
			CALL LDExeCute("Update LeadBBS_User Set MessageFlag=0 where ID=" & GBL_UserID,1)
			UpdateSessionValue 6,0,0
		Else
			Rs.Close
			Set Rs = Nothing
		End If
	End If

End Function

Sub Message_Code
%>
	<script>
	function msg_url_filter(str)
	{
		var tmp = str;
		tmp = tmp.replace(/(javascript|jscript|js|about|file|vbscript|vbs)(:)/gim,"$1%3a");
		tmp = tmp.replace(/(value)/gim,"%76alue");
		tmp = tmp.replace(/(document)(.)(cookie)/gim,"$1%2e$3");
		tmp = tmp.replace(/(')/g,"%27");
		tmp = tmp.replace(/(")/g,"%22");
		return(tmp);
	}
	function message_code(id)
	{
		var str=$id(id).innerHTML;
		str = str.replace(/\n/g, "");
		str = str.replace(/\[em([0-9]{1,4})\]/gi,"<img src=\"<%=DEF_BBS_HomeUrl%>images/UBBicon/em$1.GIF\" align=absmiddle>");
		str = str.replace(/\[img\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/img\]/gi,function($0,$1,$2){return("<img rel=\"lightbox\" src=\"" + msg_url_filter($1+$2) + "\" class=\"a_image\" align=\"absmiddle\" border=\"0\" />")});
		str = str.replace(/\[imga\](\/|..\/|http:\/\/|https:\/\/|ftp:\/\/)(.+?)\[\/imga\]/gi,function($0,$1,$2){return("<img rel=\"lightbox\" src=\"" + msg_url_filter($1+$2) + "\" class=\"a_image\" align=\"absmiddle\" border=\"0\" />")});
		str = str.replace(/\[url=(.+?)\](.+?)\[\/url\]/gi,function($0,$1,$2){return("<a href=" + msg_url_filter($1) + " target=_blank>" + $2 + "</a>")});//[url]
		str = str.replace(/\[url\](.+?)\[\/url\]/gi,function($0,$1){return("<a href=" + msg_url_filter($1) + " target=_blank>" + $1 + "</a>")});//[url]
		str = str.replace(/\[quote\](.+?)\[\/quote\]/gim,"<table border=0 cellspacing=0 cellpadding=0><tr><td><div class=ubb_quote><div class=ubb_quotein><table border=0 cellspacing=0 cellpadding=0><tr><td>$1</td></tr></table></div></div></td></tr></table>");
		str = str.replace(/\[(\/?(u|b|i|sup|sub|strike|ul|ol|colo))\]/gim,"<$1>");//[u] [b] [i] [sup] [strike] [ul]
		str = str.replace(/\[hr\]/gim,"<hr size=1 class=splitline>");//[hr]
		str = str.replace(/\[color=([#0-9a-z\(\)\,\ ]{1,25})\](.+?)\[\/color\]/gim,"<font color=\"$1\">$2</font>");//[color]
		$id(id).innerHTML = str;
	}
	</script>
<%
End Sub

Function LookMessage(MessageID)

	Dim TempN
	Message_Code
%>
	<div class="title"><%=htmlencode(SdM_Title)%></div>
	<table border=0 cellpadding="0" class="table_in">
	<%If SdM_toUser = "" Then%>
	<tr> 
		<td class="tdbox" colspan="2">
			<div class=value2>发 布 人：<%=htmlencode(SdM_fromUser)%>
			<div class=value2>发布时间：<%=htmlencode(RestoreTime(SdM_SendTime))%>
			<div class=value2>公告内容</div>
			<hr class=splitline>
			<%
			Response.Write "<div id=Message" & SdM_ID & ">"
			Response.Write VbCrLf & Replace(Replace(htmlencode(SdM_Content & ""),VbCrLf,"<br>"),"  ","&nbsp;&nbsp;")
			Response.Write "</div><script>message_code(""Message" & Sdm_ID & """);</script>"
			%>
		</td>
	</tr><%
	Else%>
	<tr>
		<td class=tdbox colspan=2>
			<%
			If Trim(SdM_Content) = "" Then
				Response.Write "<font color=Gray class=grayfont>短消息内容为空。</font>"
			Else
				Response.Write "<div id=Message" & SdM_ID & " class=word-break-all>"
			   	Response.Write PrintTrueText(SdM_Content)
			   	Response.Write "</div><script>message_code(""Message" & Sdm_ID & """);</script>"
		   	End If
		   	%>
		   	<hr class=splitline>
		   	<div class=value2><span class=grayfont>发送用户：</span><%
		   	If SdM_fromUser <> "[LeadBBS]" Then
		   		Response.Write "<a href=../User/" & RW_User(0,"",SdM_fromUser,"") & ">" & htmlencode(SdM_fromUser) & "</a>"
		   	Else
		   		Response.Write "<span class=bluefont>系统</span>"
		   	End If%>
		   	</div>
		   	<div class=value2>
			<span class=grayfont>接收用户：</span><a href=../User/<%=RW_User(0,"",SdM_toUser,"")%>><%=SdM_toUser%></a>
			<%
			If SdM_ReadFlag = 0 Then
				Response.write "， <b><span class=greenfont>您首次浏览此消息</span></b>"
			End If%>
			</div>
			<div class=value2><span class=grayfont>发出时间：</span><%=htmlencode(RestoreTime(SdM_SendTime))%>
			</div>
		</td>
	</tr>
	<%End If
	If SdM_toUser = GBL_CHK_User or CheckSupervisorUserName = 1 Then%>
	<tr> 
		<td colspan=2 class=tdbox>
			<script language=javascript>
			function kill(id)
			{
				if (confirm('确定删除此消息吗?'))
				getAJAX('DeleteMessage.asp','AjaxFlag=1&DeleteSureFlag=dk9@dl9s92lw_SWxl&MessageID=' + id,'alert(tmp);this.location="MyInfoBox.asp";',1);
			}
			</script>
			<div class=j_page>
			<a href='javascript:kill(<%=SdM_ID%>);'>删除短消息</a>
			<a href=SendMessage.asp?ModifyMessageID=<%=SdM_ID%>>编辑短消息</a>
			<%If SdM_fromUser <> "[LeadBBS]" Then%>
			<a href=SendMessage.asp?SdM_toUser=<%=urlencode(SdM_fromUser)%>&ReplyMessageID=<%=SdM_ID%>>回复此消息</a><%
			End If%>
			<%If SdM_ID = MessageID and Request("go") = "pre" Then
			Else%>
			<a href=LookMessage.asp?MessageID=<%=SdM_ID%>&go=pre<%=AllPrintingString%>>上一条</a><%
			End If%>
			<%If SdM_ID = MessageID and Request("go") = "next" Then
			Else%>
			<a href=LookMessage.asp?MessageID=<%=SdM_ID%>&go=next<%=AllPrintingString%>>下一条</a><%
			End If%>
		</td>
	</tr><%End If%>
	</table>
	<div class=title>注意：短消息在查看完成后，最多保存<%=LMT_LookedMsgExpiresDay%>天将作自动删除</div>

<%End Function

Function LookPubMessage

	GBL_CHK_TempStr = ""
	Dim Rs,SQL,GetData
	Set Rs = Server.CreateObject("ADODB.RecordSet")
	SQL = sql_select("Select ID,FromUser,toUser,Title,Content,IP,SendTime,ReadFlag from LeadBBS_InfoBox where ToUser='' order by ID DESC",DEF_TopicContentMaxListNum)
	Set Rs = LDExeCute(SQL,0)

	If Rs.Eof Then
		GBL_CHK_TempStr = "错误，找不到这条消息相关资料．"
	Else
		GetData = Rs.GetRows(-1)
	End If
	Rs.Close
	Set Rs = Nothing

	Dim TempN,N,SuperFlag
	SuperFlag = CheckSupervisorUserName

	If GBL_CHK_TempStr <> "" Then
		Response.Write "<div class=alert>" & GBL_CHK_TempStr & "</div>"
		Exit Function
	End If

	If GBL_UserID < 1 Then SuperFlag = 0
	Message_Code
	If SuperFlag = 1 Then
	%>
	<span class="grayfont">管理员操作：</span><a href=SendMessage.asp?pub=1>发布新公告</a>
	<%
	End If
	For N = 0 to Ubound(GetData,2)
		Response.Write "<a name=" & N & "></a>"
%>
	<%
				If GetData(3,N)<>"" Then Response.Write "<div class=title>" & GetData(3,N) & "</div>"%>

	<table border=0 cellpadding=0 cellspacing=0 class=table_in>
	
	<tr> 
		<td class="tdbox">
			公告时间： <%=htmlencode(RestoreTime(GetData(6,N)))%>
		</td>
	</tr><%If GetData(4,N) <> "" Then%>
	<tr> 
		<td class="tdbox">
			<%
		   	Response.Write "<div id=Message" & GetData(0,N) & " class=word-break-all>"
			Response.Write VbCrLf & Replace(Replace(GetData(4,N) & "",VbCrLf,"<br>"),"  ","&nbsp;&nbsp;")
			Response.Write "</div><script>message_code(""Message" & GetData(0,N) & """);</script>"
			%>
		</td>
	</tr>
	<%
	End If
	If SuperFlag = 1 Then%>
	<tr> 
		<td class="tdbox">
			<script language=javascript>
				function kill(id)
				{
					if (confirm('确定删除此公告吗?'))
					getAJAX('DeleteMessage.asp','AjaxFlag=1&DeleteSureFlag=dk9@dl9s92lw_SWxl&MessageID=' + id,'alert(tmp);document.location.reload();',1);
				}
			</script>
			<br><span class="grayfont">管理员信息：</span><a href='javascript:kill(<%=GetData(0,N)%>);'>删除公告</a>，<a href=SendMessage.asp?ModifyMessageID=<%=GetData(0,N)%>&pub=1>编辑公告</a>，发布公告人IP：<%=GetData(5,N)%>
		</td>
	</tr><%End If%>
	</table>
	<br>
<%
	Next

End Function

Function PrintTrueText(tempString)

	If tempString<>"" Then
		PrintTrueText=Replace(Replace(Replace(Replace(Replace(htmlEncode(tempString),VbCrLf & " ","<br>" & "&nbsp;"),VbCrLf,"<br>" & VbCrLf),"   "," &nbsp; "),"  "," &nbsp;"),chr(9)," &nbsp; &nbsp; &nbsp;")

		If Left(PrintTrueText,1) = chr(32) Then
			PrintTrueText = "&nbsp;" & Mid(PrintTrueText,2)
		End If
	Else
		PrintTrueText=""
	End If

End Function%>