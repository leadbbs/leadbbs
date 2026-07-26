<%
Class Mini_Announce

	Public LMT_TopicName
	Private ID,Form_RootMaxID,Form_RootMinID,Form_ChildNum,LMT_RootIDBak,page
	Private Flag
	private class_page,class_sql,class_idname,class_selcolumn
	private Anc_listNum

	Public Sub GetTopicInfo
	
		Anc_listNum = 6
		ID = M_Par.ID
		If ID = 0 Then Exit Sub
		Dim Rs,SQL,Form_TopicType,Form_NeedValue,LMT_TopicTitleStyle,ThisBoardid
		Flag = 0
	
		SQL = sql_select("Select ta.Title,ta.RootMaxID,ta.RootMinID,ta.Hits,ta.ChildNum,ta.ID,ta.TitleStyle,ta.ParentID,tb.ForumPass,tb.BoardLimit,tb.OtherLimit,tb.HiddenFlag,TA.boardid from LeadBBS_Announce as TA left Join LeadBBS_Boards as TB on ta.boardid=tb.boardid where ta.ID=" & ID,1)
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			Rs.Close
			Set Rs = Nothing
			Flag = 1
			Exit Sub
		Else
			LMT_TopicName = Rs(0)
			Form_RootMaxID = cCur(Rs(1))
			Form_RootMinID = cCur(Rs(2))
			Form_ChildNum = cCur(Rs(4))
			LMT_RootIDBak = cCur(Rs(5))
			LMT_TopicTitleStyle = Rs(6)
			ThisBoardid = ccur(Rs(12))
			If cCur(Rs(7)) > 0 Then Flag = 1
			If GBL_CheckLimitContent(Rs(8),Rs(9),Rs(10),Rs(11)) = 1 Then Flag = 1
			Rs.Close
			Set Rs = Nothing
			
			If LMT_TopicTitleStyle = 1 Then
				LMT_TopicName = KillHTMLLabel(LMT_TopicName)
			Else
				LMT_TopicName = HtmlEncode(LMT_TopicName)
			End If
			if ThisBoardid <> GBL_board_ID then
				GBL_board_ID = ThisBoardid
				Call Borad_GetBoardIDValue(GBL_board_ID)
			end if
		End If
	
	End Sub
	
	Public Sub DisplayTopic

		Call CheckisBoardMaster()
		Response.Write CheckAccessLimit()
		If GBL_CHK_TempStr <> "" Then
			MiniPageDefine.Error("查询错误，" & GBL_CHK_TempStr & "<br />更多可能的原因：主题限制查看; 帖子不存在。")
			Exit Sub
		End If
		
		
		Dim sql_extend,classid
		sql_extend = ""

		class_page = GetFormData("page")
		class_page = FormClass_CheckFormValue(class_page,"","int","0","<~~~0|>~~~10000000000",12)
		
		Dim SQLEndString,WhereFlag
		WhereFlag = 1
		sql_extend = ""
		
		class_sql = "select {~~~} from (LeadBBS_Announce as T1 left join LeadBBS_User as T2 on T2.Id=T1.Userid) left join LeadBBS_User as tu on tu.Id=t1.Userid where T1.RootIDBak= " & ID & sql_extend
		class_idname = "T1.ID"
		
		class_selcolumn = "T1.ID,T1.ParentID,T1.BoardID,T1.ChildNum,T1.Title,T1.Content,T1.ndatetime,T1.UserName,T1.HTMLFlag,T2.UserLimit,T1.TopicType,T1.TitleStyle,tu.TrueName"
		splitpage_orderstr = "T1.ID ASC"
		'splitpage_listNum = DEF_TopicContentMaxListNum
		splitpage_listNum = Anc_listNum

		CALL splitpage_returnData(class_sql,class_idname,class_page,class_selcolumn,Form_ChildNum + 1)
		
		DisplayAnnounce 0,splitpage_num,1,splitpage_getdata
		
		dim paraextend : paraextend = ""
		paraextend = "&b=" & GBL_board_ID & "&ID=" & ID
		if M_Par.backPage>0 then paraextend = paraextend & "&backPage=" & M_Par.backPage
		splitpage_mobileflag = 1
		CALL splitpage_viewpagelist("default.asp?action=a" & paraextend,splitpage_maxpage,splitpage_page,"")
	
		'call MiniPageDefine.AnnounceForm(ID,LMT_TopicName)


	End Sub
	
	Private Sub DisplayAnnounce(For1,For2,StepValue,GetData)
	
		Dim N
	
		%>
		<script src="<%=DEF_BBS_HomeUrl%>mini/inc/mini_leadcode.js"></script>
		<%If GetBinarybit(DEF_Sideparameter,21) = 1 then%>
		<script src="<%=DEF_BBS_HomeUrl%>inc/js/plug/apijson.js<%=DEF_Jer%>" type="text/javascript"></script>
		<%end if%>
		<script language=javascript>
		var GBL_domain="<%=DEF_AbsolutHome%>|<%=DEF_SafeUrl%>|";
		HU="<%=DEF_BBS_HomeUrl%>";
		var DEF_DownKey="<%=UrlEncode(DEF_DownKey)%>";</script>
		<div class="vt">
    		<div class="bm">
		<%
		For N = For1 to For2 Step StepValue
			%>
			<div class="announcecontent">
			<div id="post_<%=GetData(0,n)%>" class="bm_c bm_c_bg">
            	<div class="bm_user">
			<%
			If cCur(GetData(1,n)) = 0 Then
				Response.Write "<em class=""floor"">楼主</em> "
			Else
				Response.Write "<em class=""floor"">" & class_page*Anc_listNum+N & "楼</em> "
			End If
			If isNull(GetData(9,n)) Then GetData(9,n) = 0
	
			If (GetData(8,n) = 0 or GetData(8,n) = 2) Then GetData(5,n) = PrintTrueText(GetData(5,n))
	
			If GetData(11,n) >=60 Then GetData(5,n) = GetFobStr("此帖有待管理人员审核才能查看")
			If GetBinarybit(GetData(9,n),7) = 1 Then%>
					</div>
				</div>
				<div class="thread">
					<div class="pbody">
						<div class="mes">
							<div id="postmessage_<%=GetData(0,n)%>" class="postmessage">
				<%
				Response.Write "<span style=""line-height:15pt;"">" & GetFobStr("该用户发言已经被屏蔽") & "</span>"
				%>
							</div>
						</div>
					</div>
				</div>
				<%
				
			Else
				If GetData(10,n) > 0 and cCur(GetData(1,n)) = 0 and GetData(10,n) <> 80 Then
					If GetData(10,n) > 0 Then GetData(5,n) = GetFobStr("此帖内容已经加密，要查看请点击完整模式")
				End If
				
				Response.Write "<em id=""authorposton" & GetData(0,n) & """ class=""post-date""><font class=""xs0 xg1"">" & HtmlEncode(GetTrueName(GetData(7,N),GetData(12,n))) & " 于 " & RestoreTime(GetData(6,N)) & "</font></em>" & VbCrLf
				%>
					</div>
				</div>
				<div class="thread">
					<div class="pbody">
						<div class="mes">
							<div id="postmessage_<%=GetData(0,n)%>" class="postmessage">
				<%
				If Lcase(Left(GetData(4,n),3)) <> "re:" or cCur(GetData(1,n)) = 0 Then Response.Write "<div class=""title""><b>" & DisplayAnnounceTitle(GetData(4,n),GetData(11,n)) & "</b></div>" & VbCrLf
				If DEF_AnnounceFontSize <> "0" then Response.Write "<span style=font-size:" & DEF_AnnounceFontSize & ">"
				If GetData(8,n) <> 2 Then
					Response.Write GetData(5,n)
				Else
					Response.Write "<span id=Content" & GetData(0,n) & ">"
					Response.Write GetData(5,n)
					Response.Write "</span><script language=javascript>" & VbCrLf & "<!--" & VbCrLf & "leadcode('Content" & GetData(0,n) & "');" & VbCrLf & "//-->" & VbCrLf & "</script>"
				End If
		
				If DEF_AnnounceFontSize <> "0" then Response.Write "</span>"%>
							</div>
						</div>
					</div>
					<div class="box pd2 mbn">
					<a class="button2 button" href="default.asp?action=p&b=<%=gbl_board_id%>&id=<%=GetData(0,n)%>" data-ajax=false>回复</a>
					</div>
				</div>
				<%
			End If
			Response.Write "</div>"
		Next
		%>
			</div>
		</div>
		<%
		'call MiniPageDefine.AnnounceForm(ID,LMT_TopicName)

	End Sub
	
	Private Function PrintTrueText(tempString)
	
		If tempString<>"" Then
			PrintTrueText=Replace(Replace(Replace(Replace(Replace(htmlEncode(tempString),VbCrLf & " ","<br>" & "&nbsp;"),VbCrLf,"<br>" & VbCrLf),"   "," &nbsp; "),"  "," &nbsp;"),chr(9)," &nbsp; &nbsp; &nbsp;")
	
			If Left(PrintTrueText,1) = chr(32) Then
				PrintTrueText = "&nbsp;" & Mid(PrintTrueText,2)
			End If
		Else
			PrintTrueText=""
		End If
	
	End Function
	
	
	Private Function GetFobStr(Str)
	
		GetFobStr = "<font color=888888 class=grayfont>……………………………………………………隐藏内容…<br>" & _
					"<font color=blue class=bluefont>" & Str & "</font><br>" & _
					"…………………………………………………………………</font><br>"
	
	End Function
	

End Class

' AxonASP: mini/ renders post content with PrintTrueText but never had a copy of it,
' and LeadBBS defines the helper separately in each page that uses it (article.asp,
' LookMessage.asp, PrintMessage.asp, ClearTopAnc.asp). Without it every mini topic view
' 500'd with 800A01C2. Same body as the article.asp copy.
Function PrintTrueText(tempString)

	If tempString<>"" Then
		PrintTrueText=Replace(Replace(Replace(Replace(Replace(Replace(htmlEncode(tempString),VbCrLf & " ","<br />" & "&nbsp;"),"[P] ","[P]&nbsp;"),VbCrLf,"<br />" & VbCrLf),"   "," &nbsp; "),"  "," &nbsp;"),chr(9)," &nbsp; &nbsp; &nbsp;")
		If Left(PrintTrueText,1) = chr(32) Then
			PrintTrueText = "&nbsp;" & Mid(PrintTrueText,2)
		End If
	Else
		PrintTrueText=""
	End If

End Function
%>
