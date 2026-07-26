<!-- #include file=../inc/BBSsetup.asp -->
<!-- #include file=../inc/Board_Popfun.asp -->
<!-- #include file=inc/UserTopic.asp -->
<%
DEF_BBS_HomeUrl = "../"

initDatabase
GBL_CHK_TempStr = ""

Dim Sdm_FromUser,Sdm_ToUser,Sdm_Title,Sdm_Content
Sdm_FromUser = GBL_CHK_User

UpdateOnlineUserAtInfo GBL_board_ID,"打包下载及删除我的收件箱"
GBL_CHK_TempStr=""
If GBL_UserID=0 or Sdm_FromUser = "" Then
	GBL_CHK_TempStr = GBL_CHK_TempStr & "你没有登录<br>" & VbCrLf
End If

Server.ScriptTimeOut = 600

If Request.Form("submitflag") = "" Then
	BBS_SiteHead DEF_SiteNameString & " - 短消息",0,"打包下载及删除我的收件箱"
	UserTopicTopInfo("user")
	If GBL_CHK_TempStr <> "" Then
		Response.Write "<div class=alert>" & GBL_CHK_TempStr & "</div>"
	Else%>
		<table width=100%>
		<tr>
		<td>
			<br><%DisplayForm%>
		</td>
		</tr>
		</table>
		<%
	End If
	UserTopicBottomInfo
	SiteBottom
Else
	SiteHead("   打印短消息")
	if GBL_CHK_TempStr <> "" Then
		Response.Write "<div class=alert>" & GBL_CHK_TempStr & "</div>"
	Else
		PersonalInfoManage
	End If
	SiteBottom_Spend
End If
closeDataBase

Function DisplayForm

	%>
				<script LANGUAGE="JavaScript" TYPE="text/javascript">
				function submitonce(theform)
				{
					if (document.all||document.getElementById)
					{
						for (i=0;i<theform.length;i++)
						{
							var tempobj=theform.elements[i];
							if(tempobj.type.toLowerCase()=="submit"||tempobj.type.toLowerCase()=="reset")
							tempobj.disabled=true;
						}
					}
				}
				</script>
				<form name=DellClientForm action=PrintMessage.asp method=post onSubmit="submitonce(this);" target="_blank">
					<input type=hidden name=submitflag value="dk9@dl9s92lw_SWxl">
					<%If CheckSupervisorUserName = 0 and GBL_CHK_User <> "Angel" and GBL_CHK_User <> "SpiderMan" Then%>
					<b>警告：<p></b><font color=Red class=redfont><b>打印收件箱全部短消息只能输出一次<br>
					，在打印结束后，论坛将会自动清除你的所有收件箱消息．</b><br>
					<%Else%>
					<font color=Blue class=bluefont><b>您是特殊用户，打印后并不清除您的收件箱，请放心使用．</b><br>
					<%End If%>
					
					<div class=value2><input type=submit value=确定操作 class="fmbtn btn_3"></div>
				</form>
	<%

End Function


Function PersonalInfoManage

	Dim ToUser
	If CheckSupervisorUserName = 0 Then
		ToUser = GBL_CHK_User
	Else
		ToUser = Trim(Left(Request.QueryString("ToUser"),14))
		If ToUser <> "" Then
			ToUser = ToUser
		Else
			ToUser = GBL_CHK_User
		End If
	End If

	Dim Rs,SQL

	GBL_CHK_TempStr=""

	SQL = sql_select("Select ID,FromUser,toUser,Title,Content,IP,SendTime,ReadFlag from LeadBBS_InfoBox where ToUser='" & Replace(ToUser,"'","''") & "' Order by ID ASC",8000)
	Set Rs = LDExeCute(SQL,0)

	Dim TempN,N,SuperFlag
	SuperFlag = CheckSupervisorUserName
	If GBL_UserID < 1 Then SuperFlag = 0
	
	Dim Content,Number
	Number = 0
	If Rs.Eof Then Response.Write "<p align=center><b><font color=Red class=redfont>您的收件箱为空！</font></b>"
		
	Do while Not Rs.Eof
%>
	
	<br>
	<table width="<%=DEF_BBS_ScreenWidth%>" border="0" cellspacing="0" cellpadding="0" align=center>
	<tr> 
		<td> 
				<%
				If Rs(3)<>"" Then Response.Write "<b>" & htmlencode(Rs(3)) & "</b>"%>
		</td>
	</tr>
	</table>
	<br>
	<table border=0 cellpadding=5 cellspacing=1 width=<%=DEF_BBS_ScreenWidth%> style="WORD-BREAK: break-all;" class=TBBG1 align=center>
	
	<tr class=TBBG9> 
		<td class=TBBG1>
			<%Response.Write "<font color=gray class=grayfont>编号：</font>" & Rs(0) & " &nbsp;"
			Response.Write "<font color=gray class=grayfont>发送人：</font><a href=" & RW_User(0,"",Rs(1),"") & " target=_blank>" & htmlencode(Rs(1)) & "</a> &nbsp;"
			Response.Write "<font color=gray class=grayfont>时间：</font>" & htmlencode(RestoreTime(Rs(6))) & " &nbsp;"
			If SuperFlag = 1 Then Response.Write "<font color=gray class=grayfont>IP：</font>" & Rs(5)%>
		</td>
	</tr>
	<tr class=TBBG9> 
		<td height=24 valign=top>
			<table border="0" cellspacing="0" cellpadding="0">
			<tr> 
				<td>
			<%
			SdM_Content = Rs(4)

		   	If DEF_UBBiconNumber > 0 then
		   		SdM_Content = PrintTrueText(SdM_Content)
				For TempN = 1 to DEF_UBBiconNumber
		   			SdM_Content=replace(SdM_Content,"[EM" & Right(("0" & TempN),2) & "]","<img src=""../images/UBBicon/em" & Right("0" & TempN,Len(DEF_UBBiconNumber)) & ".GIF"" width=20 height=20 align=middle border=0>",1,10,0)
		   			SdM_Content=replace(SdM_Content,"[em" & Right(("0" & TempN),2) & "]","<img src=""../images/UBBicon/em" & Right("0" & TempN,Len(DEF_UBBiconNumber)) & ".GIF"" width=20 height=20 align=middle border=0>",1,10,0)
		   			
		   		Next
		   		Response.Write Message_Code(SdM_Content)
		   		'Response.Write SdM_Content
		   	Else
		   		Response.Write PrintTrueText(SdM_Content)
		   	End If
			%>
				</td>
			</tr>
			</table>
		</td>
	</tr>
	</table>
	<br>
<%
		Number = Number + 1
		If (Number mod (DEF_TopicContentMaxListNum*2)) = 0 Then Response.Flush
		Rs.MoveNext
	Loop
	Rs.Close
	Set Rs = Nothing
	If Number > 0 Then Response.Write "<p><span class=bluefont><b>共" & Number & "条短消息</b></span></p>"
	If CheckSupervisorUserName = 0 and GBL_CHK_User <> "Angel" and GBL_CHK_User <> "SpiderMan" Then
		CALL LDExeCute("delete from LeadBBS_InfoBox where ToUser='" & Replace(GBL_CHK_User,"'","''") & "'",1)
		Response.Write "(已经删除)"
	End If

End Function


function Message_Code(Str)

	Dim UBBStrCnt
	UBBStrCnt = Str
	dim re
	set re = New RegExp
	re.Global = True
	re.IgnoreCase = True
	If DEF_EnableImagesUBB = 1 then
		UBBStrCnt = OneLevelCode(UBBStrCnt, "[IMG]", "[/IMG]", "<IMG SRC="," border=0 onLoad=""javascript:if(this.width>450)this.width=450;"" onMouseover=""javascript:if(this.width>450)this.width=450;"" align=middle>")
		UBBStrCnt = OneLevelCode(UBBStrCnt, "[IMGA]", "[/IMGA]", "<IMG SRC="," border=0 alt=按此在新窗口浏览图片 onclick=""javascript:window.open(this.src);"" onLoad=""javascript:if(this.width>450)this.width=450;"" onMouseover=""javascript:if(this.width>450)this.width=450;"" style=""cursor:hand"" align=middle>")
	End If
	Message_Code = UBBStrCnt

End Function

Function OneLevelCode(fString, Str1, Str2, ReStr1, ReStr2)

	If Lcase(Str1) = Ucase(Str1) and Lcase(Str2) = Ucase(Str2) Then
		OneLevelCode = OneLevelCode2(fString, Str1, Str2, ReStr1, ReStr2)
	Else
		OneLevelCode = OneLevelCode2(fString, Lcase(Str1), Lcase(Str2), ReStr1, ReStr2)
		OneLevelCode = OneLevelCode2(fString, Ucase(Str1), Ucase(Str2), ReStr1, ReStr2)
	End If

End Function

function OneLevelCode2(fString, Str1, Str2, ReStr1, ReStr2)

    Dim Str1Pos,Str2Pos
    Str1Pos = Instr(1, fString, Str1, 0)
    Str2Pos = Instr(Str1Pos + 1, fString, Str2, 0)

    Dim LenY,LenX
    LenY = Len(ReStr2) - len(Str2)
    LenX = Len(ReStr1) - len(Str1)

	Dim Flag,Tmp
	Flag = 0
    while (Str2Pos > 0 and Str1Pos > 0)
    	If (Ucase(Str1) = "[IMG]" or Ucase(Str1) = "[IMGA]") Then
    		Tmp = Trim(Lcase(Mid(fString,Str1Pos+Len(str1),15)))
    		'If Left(Tmp,2) = "&#" or Left(Tmp,14) = "&#106avascript" or Left(Tmp,10) = "javascript" or Left(Tmp,12)="&#106script:" or Left(Tmp,8)="jscript:" or Left(Tmp,7)="&#106s:" or Left(Tmp,3)="js:" or Left(Tmp,9)="about&#58" or Left(Tmp,6)="about:" or Left(Tmp,8)="file&#58" or Left(Tmp,5)="file:" or Left(Tmp,13)="&#118bscript:" or Left(Tmp,9)="vbscript:" or Left(Tmp,8)="&#118bs:" or Left(Tmp,4)="vbs:" Then Flag = 1
    		If Left(Tmp,1) <> "/" and Left(Tmp,3) <> "../" and Left(Tmp,7) <> "http://" and Left(Tmp,8) <> "https://" and Left(Tmp,6) <> "ftp://" Then Flag = 1
    	End If
    	If Flag = 1 Then
    		Flag = 0
    	Else
			fString = Left(fString,Str1Pos-1) & replace(fString, Str1, ReStr1, Str1Pos, 1, 0)
			'fString = Left(fString,Str2Pos-1) & replace(fString, Str2, ReStr2, Str2Pos, 1, 0)
			Str2Pos = Str2Pos + LenX
			fString = Left(fString,Str2Pos-1) & replace(fString, Str2, ReStr2, Str2Pos, 1, 0)
			Str2Pos = Str2Pos + LenY
		End If
		Str1Pos = Instr(Str2Pos + 1, fString, Str1, 0)
		Str2Pos = Instr(Str1Pos + 1, fString, Str2, 0)
    wend
    OneLevelCode2 = fString

end function

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