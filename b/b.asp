<!-- #include file=../inc/BBSsetup.asp -->
<!-- #include file=../inc/Board_Popfun.asp -->
<!-- #include file=../inc/Limit_Fun.asp -->
<!-- #include file=inc/Board_fun.asp -->
<!-- #include file=../inc/Fun/ViewOnline_fun.asp -->
<!-- #include file=inc/SmallList.asp -->
<!-- #include file=../inc/Templet/HTML/Normal_0.asp -->
<!-- #include file=../inc/Fun/VierAnc_Fun.asp -->
<!-- #include file=../inc/IncHtm/Boards_Side.asp -->
<!-- #include file=../inc/IncHtm/Boards_Side_Setup2.asp -->
<!-- #include file=../inc/UBBCode_Setup.asp -->
<!-- #include file=../article/inc/splitpage_fun.asp -->
<%
DEF_BBS_HomeUrl = "../"
Dim Boards_dis_assortStr

Dim EFlag,EString,EUrlString,EID,EName,ENumber,EIndex
ENumber = 0
EIndex = 0
Dim LMT_Simple : LMT_Simple = 0

Sub DisplayBoard_HTML_MastList(s,num,flag)

	If "?LeadBBS?" = s Then
		Response.Write "全体" & DEF_PointsName(8)
	Else
		If s = "" or s = null Then
			Response.Write flag & "：无"
			Exit Sub
		End If
		Dim ss,n,m
		ss = Split(s,",")
		m = Ubound(ss,1)
		If m >= num Then
			%><%=flag%>：<%
		Else%>
			<%=flag%>：<%
		End If
		For n = 0 to m
			If n >= num Then Exit For
			If n > 0 Then Response.Write ", "
			Response.Write "<a href=""" & DEF_BBS_HomeUrl & "User/" & RW_User(0,"",ss(n),"") & """"
			Response.Write ">" & HtmlEncode(ss(n)) & "</a>"
		Next
		If n >= num and n <= m Then
			%>
				<div class="layer_item" style="display:inline"><span class="layer_item_title"><em>...</em></span>
				<div class="layer_iteminfo">
				<ul class="menu_list">
					<%
			Response.Write "<li><b>更多" & flag & "</b></li>"
			Dim t
			t = n
			For n = t to m
				Response.Write "<li><a href=""" & DEF_BBS_HomeUrl & "User/" & RW_User(0,"",ss(n),"") & """"
				Response.Write ">" & HtmlEncode(ss(n)) & "</a></li>"
			Next
			%>
				</ul>
				</div>
			</div><%
		End If
	End If

End Sub

Function LoginAccuessFul

	GBL_CHK_TempStr = ""
	If GBL_board_ID = 0 and EFlag = 0 Then
		Global_ErrMsg "论坛不存在此版面，请返回首页重新访问。" & VbCrLf
		GBL_SiteBottomString = ""
		Exit Function
	End If
	If GBL_CHK_TempStr<> "" then
		Global_ErrMsg GBL_CHK_TempStr
		GBL_SiteBottomString = ""
	Else
		DisplayAnnouncesSplitPages
	End If

End Function

Function GetActiveUserNumber(BoardID)

	If GBL_board_ID < 1 Then
		GetActiveUserNumber = 0
		Exit Function
	End If
	Dim Rs,tmp
	If isArray(Application(DEF_MasterCookies & "BoardInfo" & BoardID)) = True Then
		Rs = Application(DEF_MasterCookies & "BDOL" & BoardID)
		If Rs >= 0 and Rs <= cCur(Application(DEF_MasterCookies & "ActiveUsers")) Then 
			GetActiveUserNumber = Rs
			Exit Function
		End If
	Else
		GetActiveUserNumber = 0
		Exit Function
	End If
	Set Rs = LDExeCute("select count(*) from LeadBBS_onlineUser where AtBoardID=" & BoardID,0)
	If Rs.Eof Then
		tmp = 0
	Else
		tmp = Rs(0)
		If isNull(tmp) Then tmp = 0
		tmp = cCur(tmp)
	End If
	Rs.Close
	Set Rs = Nothing
	GetActiveUserNumber = tmp
	If isArray(Application(DEF_MasterCookies & "BoardInfo" & BoardID)) = True Then
		Application.Lock
		Application(DEF_MasterCookies & "BDOL" & BoardID) = tmp
		Application.UnLock
	End if

End Function

Sub DisplayBoard_HTML(BoardNum,Blist)

	Dim BoardID,ForumPass,GetData
	Dim N
	Dim BoardClass
	Set BoardClass = New DisplayBoard_HTML_Class
	Dim ShowFlag
	ShowFlag = 0

	Dim CloseAssort,OpenAssort
	CloseAssort = Request.Cookies(DEF_MasterCookies & "clsassort")
	OpenAssort = Request.Cookies(DEF_MasterCookies & "openassort")
	Boards_dis_assortStr = Request.Cookies(DEF_MasterCookies & "dis_assort")
	For N = 0 to BoardNum
		BoardID = Blist(n)
		GetData = Application(DEF_MasterCookies & "BoardInfo" & BoardID)
		If isArray(GetData) = False Then
			ReloadBoardInfo(BoardID)
			GetData = Application(DEF_MasterCookies & "BoardInfo" & BoardID)
		End If

		ForumPass = GetData(7,0)
		If ForumPass <> "" Then ForumPass = "leadbbs"
		GetData(9,0) = cCur(GetData(9,0))
		If GBL_CheckLimitTitle(ForumPass,GetData(9,0),GetData(36,0),GetData(8,0)) = 1 Then
			GetData(20,0) = "已设置为隐藏"
			GetData(3,0) = ""
		End If
		GetData(1,0) = GBL_Board_ID
		GetData(14,0) = GBL_Board_BoardName
		If inStr(OpenAssort,",b" & GBL_Board_ID & ",") > 0 or ((GetBinarybit(GBL_Board_BoardLimit,19) = 0 and (inStr(CloseAssort,",b" & GBL_Board_ID) & ",") = 0)) Then
		'If GetBinarybit(GBL_Board_BoardLimit,19) = 0 Then
			If GetData(8,0) = 0 Then
				If ShowFlag = 0 Then
					Global_TableHead
					ShowFlag = 1
				End If
				CALL BoardClass.DisplayBoard_HTML_Fun(BoardID,GetData(1,0),GetData(0,0),GetData(2,0),GetData(3,0),GetData(4,0),GetData(29,0),GetData(30,0),ForumPass,GetData(19,0),Replace(GetData(20,0),"<","&lt;"),GetData(10,0),GetData(9,0),GetData(14,0),GetData(31,0),GetData(32,0),GetData(21,0),GetData(22,0),GetData(23,0),0,GetData(27,0),Replace(GetData(35,0),"<","&lt;"))
			End If
		Else
			
			If ShowFlag = 0 Then
				Global_TableHead
				ShowFlag = 1
			End If
			CALL BoardClass.DisplayBoard_HTML_Fun_Simple(BoardID,GetData(1,0),GetData(0,0),GetData(2,0),GetData(3,0),GetData(4,0),GetData(29,0),GetData(30,0),ForumPass,GetData(19,0),Replace(GetData(20,0),"<","&lt;"),GetData(10,0),GetData(9,0),GetData(14,0),GetData(31,0),GetData(32,0),GetData(21,0),GetData(22,0),GetData(23,0),0,GetData(27,0),Replace(GetData(35,0),"<","&lt;"))
			'CALL BoardClass.DisplayBoard_HTML_Fun_Simple(BoardID,GetData(1,0),GetData(0,0),GetData(14,0),GetData(18,0),GetData(5,0),GetData(6,0))
		End If
	Next
	BoardClass.DisplayBoard_HTML_Fill
	Set BoardClass = Nothing
	If ShowFlag = 1 Then
		Response.Write "</table></div></div>"
		Global_TableBottom
	End If

End Sub

Sub Boards_CloseAssort

	%>
	<script src="../inc/js/boardlist.js" type="text/javascript"></script>
	<%

End Sub

Sub DisplayBoard(Blist)

	If Blist & "" = "" Then Exit Sub
	Blist = Split(Blist,",")
	If Ubound(Blist,1) < 0 then Exit Sub

	Dim BoardNum
	BoardNum = Ubound(Blist,1)

	If BoardNum = -1 Then
	Else
		Boards_CloseAssort
		CALL DisplayBoard_HTML(BoardNum,Blist)
	End If

End Sub

Sub b_DisplayBoard

	Dim Page,JMPage
	Page = Left(Request.QueryString("p"),14)
	If isNumeric(Page) = 0 or inStr(Page,".") > 0 Then Page = 0
	Page = cCur(Page)
			
	JMPage = Left(Request.QueryString("q"),14)
	If isNumeric(JMPage) = 0 or inStr(JMPage,".") > 0 Then JMPage = 0
	JMPage = Fix(cCur(JMPage))
	If JMPage > DEF_MaxJumpPageNum Then JMPage = 0
			
	If Request.QueryString("Upflag")="1" Then
		Page = Page - JMPage
	Else
		Page = Page + JMPage
	End If

	If GetBinarybit(GBL_Board_BoardLimit,12) = 1 or (Page <= 1) Then
		If isArray(Application(DEF_MasterCookies & "BoardInfo" & GBL_board_ID)) Then DisplayBoard(Application(DEF_MasterCookies & "BoardInfo" & GBL_board_ID)(27,0))
	End If

End Sub

Sub B_Main(PassFormStr)

dim class_page '版规仅第一页显示
class_page = toNum(request.querystring("page"),0)
if class_page = 0 then class_page = toNum(request.querystring("q"),0)

if LMT_Simple = 0 then 'start simple check%>
	<script src="<%=DEF_BBS_HomeUrl%>a/inc/leadcode.js<%=DEF_Jer%>" type="text/javascript"></script>
	<script language="JavaScript" type="text/javascript">
	var GBL_domain="|<%=DEF_AbsolutHome%>|<%=DEF_SafeUrl%>|";
	var DEF_DownKey="<%=UrlEncode(DEF_DownKey)%>";
	HU="<%=DEF_BBS_HomeUrl%>";
	</script>
<%
	If GetBinarybit(DEF_Sideparameter,17) = 1 Then
	%>
	<script language="JavaScript" type="text/javascript">
	function forum_opt_init()
	{
		var cur="<%=GBL_Board_BoardAssort%>";
		$(".boardnavlist .user_itemlist ul").hide();
		$("#master_part_" + cur).show();
		$(".swap_collapse").toggleClass("swap_open");
		$("#master_part_" + cur).prev().attr("class","swap_collapse");
	}
	function swap_view(str,sobj)
	{
		$(".swap_collapse").attr("class","swap_open");
		sobj.className = "swap_collapse";
		$(".boardnavlist .user_itemlist ul").hide();
		$("#"+str).show();
	}
	function url_to(id)
	{<%if GetBinarybit(DEF_Sideparameter,16) = 0 then%>
		document.location="<%=DEF_BBS_HomeUrl%>b/b.asp?b="+id;
		<%Else%>
		document.location="<%=DEF_BBS_HomeUrl%>b/forum-"+id+"-1.html";
		<%end if%>
	}
	var b_nav_pos = "";
	$(document).ready(function() {
	$(window).scroll(function(){
			if(Browser.ie6)return;
			if($(".boardnavlist")[0])
			{
				if(b_nav_pos=="")b_nav_pos = $.getPos($(".boardnavlist")[0]);
				if($(document).scrollTop() > b_nav_pos.y&&$(".boardnavlist").is(":visible"))
				{
					if(!$("#nav_tmp")[0])$(".boardnavlist").after("<div id='nav_tmp' style='width:"+b_nav_pos.w +"px;height:1px;display:block;float:"+$(".boardnavlist").css("float")+";'></div>");
					$(".boardnavlist").css("position","fixed").css("left",b_nav_pos.x+"px").css("top","0px");
				}
				else
				{
					if($("#nav_tmp")[0])$("#nav_tmp").remove();
					$(".boardnavlist").css("position","static").css("left","0px").css("top","0px");
				}
			}
		});
	});
	</script>
	<div class="boardnavlist">
		<div class="user_itemlist">
			<div class="navtitle" oncontextmenu="$(this).parent().parent().hide();$('#nav_tmp').remove();return false;">版块导航</div>
			<!-- #include file=../inc/incHtm/BoardJump2.asp -->
		</div>
	</div>
	<script>
	forum_opt_init();
	</script>
	<div class="boardnavlist_sider">
	<%
	End If
end if 'end simple


	If GBL_CHK_TempStr = "" Then
		UpdateOnlineUserAtInfo GBL_board_ID,GBL_Board_BoardName & " " & EString
		If GetBinarybit(GBL_Board_BoardLimit,20) <> 1 Then
			if LMT_Simple = 0 then
				If GBL_B_SubBoard_Flag = 0 Then b_DisplayBoard
			end if
		End If
		If GetBinarybit(GBL_Board_BoardLimit,12) = 1 Then
			If GBL_ShowBottomSure = 0 Then GBL_SiteBottomString = ""
		Else
	%>
		<%	If GBL_Board_ID > 0 or EFlag > 0 Then
			if LMT_Simple = 0 then 'start simple
					%>
		<div class="b_box b_line_info fire">
			<div class="b_box_nav">
				<ul>
			<%
					Response.Write "<li>"
					If EFlag < 0 Then
						Response.Write "<b>全部</b>"
					Else
						Response.Write "<a href=""" & RW_b(GBL_board_ID,1,"") & """>全部</a>"
					End If
					Response.Write "</li>"
					If GBL_Board_GoodNum > 0 Then
						Response.Write "<li>"
						If EFlag = 0 Then
							Response.Write "<b>精华帖</b>"
						Else
							Response.Write "<a href=""" & RW_b(GBL_board_ID,1,"&e=0") & """>精华帖</a>"
						End If
						Response.Write "</li>"
					End If
					If isArray(Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID & "_TI")) = False Then
						If Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID & "_TI") & "" <> "yes" Then ReloadTopicAssort(GBL_Board_ID)
					End If
					If isArray(Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID & "_TI")) Then
						%><li><a href="<%=RW_b(GBL_board_ID,1,"&e=1")%>" onclick="ShowOnline('followAssort','swap_assort',2);return false;">
							<span class="swap_ol<%If GetBinarybit(GBL_Board_BoardLimit,18) = 0 Then Response.Write "_close"%>" id="swap_assort"><%
						If EFlag > 0 Then
							Response.Write "<b>专题</b>"
						Else
							Response.Write "专题"
						End If
						%></span></a></li><%
					End If
				If GetBinarybit(DEF_Sideparameter,6) = 1 Then
				%><li><a href="<%=RW_b(GBL_board_ID,1,"&e=1")%>" onclick="ShowOnline('follow0','swap_ol',1);return false;">
				
					<span class="swap_ol<%If DEF_DisplayOnlineUser = 1 or DEF_DisplayOnlineUser = 3 Then Response.Write "_close"%>" id="swap_ol">在线<%=GetActiveUserNumber(GBL_Board_ID)%>人</span></a>
					</li>
				<%end if%>
					<li>
					主题: <%=GBL_Board_TopicNum%> / 帖子: <%=GBL_Board_AnnounceNum%></li></ul>
			</div>
			<div class="b_anc_master">
				<%DisplayBoard_HTML_MastList GBL_Board_MasterList,3,DEF_PointsName(8) %>
				<%
				if class_page < 2 then displayboard_info(0)
				%>
			</div>
		</div>
		<%
			end if 'end simple
			End If
			
			if LMT_Simple = 0 then 'start simple%>
	<script type="text/javascript" language="JavaScript">
	<!--
	function ShowOnline(obj,swap,ol){
		if ($id(obj).style.display!='block'){
			$id(obj).style.display="block";
			if(ol!=999)
			{
				if($id(obj).innerHTML=="loading...")
				{
					$id(obj).innerHTML = layer_loadstr;
					getAJAX("b.asp","ol=" + ol + "&b=<%=GBL_Board_ID%>",obj);
				}
			}
			if(ol=999){LD.Cookie.Add("<%=DEF_MasterCookies%>clsbinfo","o");}
			$id(swap).className = "swap_ol";
			}else{
			$id(obj).style.display="none";
			$id(swap).className = "swap_ol_close";
			if(ol=999){LD.Cookie.Add("<%=DEF_MasterCookies%>clsbinfo","c");}
		}
	}
	-->
	</script>
			<%If GetBinarybit(GBL_Board_BoardLimit,18) = 1 Then%>
				<div class="b_box b_line_goodassort fire" id="followAssort" style="display: block">
			          <%DisplayTopicAssort%>
				</div>
			<%
			Else%>
				<div class="b_box fire" id="followAssort" style="display: none">loading...</div>
			<%
			End If
			if class_page < 2 then displayboard_info(1)
			If GetBinarybit(DEF_Sideparameter,6) = 1 Then
				If DEF_DisplayOnlineUser = 1 or DEF_DisplayOnlineUser = 3 Then%>
					<div class="b_box fire" id="follow0" style="display: none">loading...</div>
				<%End If%>
				<%If DEF_DisplayOnlineUser = 2 Then%>
					<div class="b_box fire" id="follow0" style="display: block">
				          <%DisplayUserOnline GBL_Board_ID,"../"%>
					</div><%
				End If
			end if
			end if 'end simple
			LoginAccuessFul
		End If
	Else
		response.write PassFormStr
		Global_ErrMsg GBL_CHK_TempStr
	End If
	
	If GBL_CHK_TempStr = "" and GetBinarybit(GBL_Board_BoardLimit,20) = 1 Then
		if LMT_Simple = 0 then b_DisplayBoard
	End If
	
	If GetBinarybit(DEF_Sideparameter,16) = 1 Then
		if LMT_Simple = 0 then%>
	</div>
	<%
		end if
	End If

End Sub

sub displayboard_info(flag)

	dim v : v = 0
	if GetBinarybit(GBL_Board_BoardLimit,25) = 1 or GetBinarybit(GBL_Board_BoardLimit,24) = 1 then v = 1
	if v = 0 and flag = 1 then exit sub
	
	dim close
	close = Request.Cookies(DEF_MasterCookies & "clsbinfo")
	if close = "c" then
		close = "c"
	else
		close = "o"
	end if
	if flag = 0 then
		if v = 1 then
		%>
		<a href="javascript:;" onclick="ShowOnline('b_logo_info','swap_b_info',999);return false;" class="swap_ol<%If close = "c" Then Response.Write "_close"%>" id="swap_b_info">版规</a>
		
		<%
		end if
		if instr("," & GBL_Board_MasterList & ",","," & GBL_CHK_User & ",") or GBL_BoardMasterFlag >= 5 then%>
		<a href="<%=DEF_BBS_HomeUrl%>a/editannounce.asp?b=<%=gbl_board_id%>&id=-1" class="b_edit_boardinfo">编辑版规</a>
		<%
		end if
	else
	%>
	<div class="b_box b_logo_info fire" id="b_logo_info" style="<%
		if close = "c" then
			%>display: none<%
			else%>display:block;<%
		end if%>"><%
		view_board_info%></div>
	<%
	end if

end sub

sub view_board_info

	if GetBinarybit(GBL_Board_BoardLimit,25) = 1 then%>
	<div class="b_logo_info_img" id="b_logo_info_img_<%=gbl_board_id%>">
	<img src="<%=DEF_BBS_HomeUrl%>images/board/b_<%=gbl_board_id%>.png">
	</div>
	<%
	end if
	if GetBinarybit(GBL_Board_BoardLimit,24) = 1 then
		dim sql,rs,bbs_Content
		SQL = "Select BoardIntro2 from LeadBBS_boards where boardID=" & GBL_Board_id
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			bbs_Content = ""
		else
			bbs_Content = rs(0)
		end if
		rs.close
		set rs = nothing
		dim htmltype
		htmltype = left(bbs_Content,2)
		if htmltype = "2|" then
			bbs_Content = mid(bbs_Content,3)
			bbs_Content = PrintTrueText(bbs_Content)
			htmltype = 2
		elseif htmltype = "1|" then
			bbs_Content = mid(bbs_Content,3)
			htmltype = 1
		elseif htmltype = "0|" then
			bbs_Content = mid(bbs_Content,3)
			bbs_Content = PrintTrueText(bbs_Content)
			htmltype = 0
		else
			htmltype = 2
		end if
		%>
		<div class="b_logo_info_txt" id="b_logo_info_txt_<%=gbl_board_id%>">
		<%
		if htmltype = 2 then
			dim LMTDEF_ConvetType : LMTDEF_ConvetType = GetBinarybit(DEF_Sideparameter,7)
			dim bbsObj,outstr
			if LMTDEF_ConvetType = 1 then
				Set bbsObj = CreateObject("leadbbs.bbsCode")
			End If
			%>
			<span id="b_info_ubb"><%
				if LMTDEF_ConvetType = 1 then
				if inStr(lcase(Request.ServerVariables("HTTP_USER_AGENT")),"msie") then
					Response.Write bbsObj.convertcode(bbs_Content,DEF_BBS_HomeUrl,DEF_DownKey,"|" & DEF_SafeUrl & "|",outstr,"msie")
				else
					Response.Write bbsObj.convertcode(bbs_Content,DEF_BBS_HomeUrl,DEF_DownKey,"|" & DEF_SafeUrl & "|",outstr,"other")
				end if
			else
				Response.Write bbs_Content
			end if
			%></span>
			<%
			if LMTDEF_ConvetType <> 1 then
			%>
			<script>leadcode('b_info_ubb');</script>
			<%
			end if
		else
			Response.Write bbs_Content
		end if%>
		</div>
		<%
	end if

end sub

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

Sub Main

	LMT_action = left(request.querystring("action"),4)
	if LMT_action <> "list" then
		LMT_action = ""
	else
		GBL_Board_ID = 0
		EString = "帖子"
	end if

	GBL_CHK_PWdFlag = 0
	GBL_CHK_GuestFlag = 0
	initDatabase
	CheckisBoardMaster
	GBL_CHK_TempStr = ""
	Select Case Request.form("ol")
		Case "3"
		If GBL_CHK_TempStr = "" Then
			Dim SmallList
			Set SmallList = New Small_List
			SmallList.DisplayAnnouncesSplit
			Set SmallList = Nothing
		End If
		CloseDataBase
		Exit Sub
	Case "1"
		GetStyleInfo
		If GBL_CHK_TempStr = "" Then DisplayUserOnline GBL_Board_ID,"../"
		CloseDataBase
		Exit Sub
	Case "2"
		GetStyleInfo
		If GBL_CHK_TempStr = "" Then DisplayTopicAssort
		CloseDataBase
		Exit Sub
	Case "side":
		Boars_Side_Box("")
		CloseDatabase
		Exit Sub
	End Select

	EFlag = Request.QueryString("E")
	If EFlag = "1" Then
		EFlag = 1
		EString = "专题"
		EUrlString = "&E=1"
	ElseIf EFlag = "0" Then
		EFlag = 0
		EString = "精华帖"
		EUrlString = ""
	Else
		EFlag = -1
		if LMT_action = "" then EString = ""
		EUrlString = ""
		If CheckSystem = 1 Then
			Response.Redirect Get_MobileUrl(DEF_BBS_HomeUrl,1,GBL_Board_ID,request.QueryString("id"),-5)
		End If
	End If

	if request.querystring("ajaxflag") = "1" then LMT_Simple = 1

	EID = Left(Request.QueryString("EID"),14)
	If isNumeric(EID) = 0 Then EID = 0
	EID = Fix(cCur(EID))
	If EID < 1 Then EID = 0
	If EID > 0 Then EName = GetEName(EID)
	If EName = "" Then EID = 0
	If EID > 0 Then
		EString = "<span class=""navigate_string_step""><a href=""" & RW_b(GBL_board_ID,1,"&e=1") & """><span>专题</span></a></span><span class=""navigate_string_step""><a href=javascript:;><span>" & EName & "</span></a></span>"
	Else
		If EString <> "" Then EString = "<span class=""navigate_string_step""><a href=javascript:;><span>" & EString & "</span></a></span>"
	End If


	Dim SideFlag,SideNomal
	SideFlag = GetBinarybit(DEF_Sideparameter,3)
	SideNomal = GetBinarybit(DEF_Sideparameter,4)
	SideFlag = Cstr(SideFlag)
	If SideFlag = "0" Then
		SideFlag = "1"
	Else
		SideFlag = "0"
	End If
	GBL_SideFlag = Cstr(SideFlag) & Cstr(SideNomal)

	DEF_GBL_Description = KillHTMLLabel(GBL_Board_BoardIntro)
	if DEF_GBL_Description = "" then DEF_GBL_Description = KillHTMLLabel(EString & " " & GBL_Board_BoardName) & " " & DEF_SiteNameString
	
if LMT_Simple = 0 then 'start simple
	BBS_SiteHead DEF_SiteNameString & " - " & KillHTMLLabel(GBL_Board_BoardName),GBL_board_ID,EString
	%><div class="area">
	<div id="ad_boardtop"></div></div>
	<div class="clear"></div>
	<%
	If SideFlag = 1 or GBL_CHK_TempStr <> "" Then
		Boards_Body_Head("")
	Else
		Boards_Body_Head("request" & SideNomal)
	End If
end if 'end simple
	Dim PassFormStr
	PassFormStr = CheckAccessLimit

	B_Main(PassFormStr)

	CloseDataBase
if LMT_Simple = 0 then 'start simple
	Boards_Body_Bottom
	If GBL_CHK_TempStr <> "" Then
		If GBL_ShowBottomSure = 0 Then GBL_SiteBottomString = ""
	End If
	%>
	<div class="clear"></div>
	<div class="area">
	<div id="ad_boardbottom"></div></div><%
End if%>
	<script>
	if(!(Browser.ie6 || Browser.ie7))
	{
		$(".b_list_topicname").mouseover(function(){
		$(this).find(".b_getlist_exist").show();
		});
		$(".b_list_topicname").mouseleave(function(){
		$(this).find(".b_getlist_exist").hide();
		});
	}
	</script>
	<%
	if LMT_Simple = 0 then SiteBottom

End Sub

Function GetBoardIDbyEID(EID)

	dim rs,sql
	sql = sql_select("select ID,boardid from LeadBBS_GoodAssort where id=" & EID,1)
	set rs = ldexecute(sql,0)
	if rs.eof then
		GetBoardIDbyEID = 0
	else
		GetBoardIDbyEID = ccur(rs(1))
	end if

End Function

Function GetEName(ID)

	If GBL_Board_ID = 0 Then
		GBL_Board_ID = GetBoardIDbyEID(EID)
		If GBL_Board_ID > 0 Then Borad_GetBoardIDValue(GBL_Board_ID)
	End If
	Dim TArray,N,Num
	TArray = Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID & "_TI")
	If isArray(TArray) = False Then
		ReloadTopicAssort(GBL_Board_ID)
		Exit Function
	End If
	Num = Ubound(TArray,2)
	For N = 0 To Num
		If ID = cCur(TArray(0,N)) Then
			EIndex = N
			EName = TArray(1,n)
			GetEName = EName
			ENumber = cCur(TArray(2,n))
			Exit For
		End If
	Next

End Function

Sub ReloadTopicAssort(BoardID)

	Dim Rs
	Set Rs = LDExeCute("select ID,AssortName,0,0,0 from LeadBBS_GoodAssort where BoardID=" & BoardID & " Order by BoardID,OrderID",0)
	If Not Rs.Eof Then
		Application.Lock
		Application(DEF_MasterCookies & "BoardInfo" & BoardID & "_TI") = Rs.GetRows(-1)
		Application.UnLock
	Else
		Application.Lock
		Set Application(DEF_MasterCookies & "BoardInfo" & BoardID & "_TI") = Nothing
		Application(DEF_MasterCookies & "BoardInfo" & BoardID & "_TI") = "yes"
		Application.UnLock
	End If
	Rs.Close
	Set Rs = Nothing

End Sub

Sub DisplayTopicAssort

	Dim TArray,N,Num,M
	TArray = Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID & "_TI")
	If isArray(TArray) = False Then Exit Sub
	Num = Ubound(TArray,2)
	If N < 0 Then Exit Sub
	%>
	<div class="b_assortlist">
	<ul>
	<%
	For N = 0 To Num
		%><li>
			<%
			If EID = TArray(0,N) Then
				Response.Write "<b>"
				Response.Write TArray(1,N)
				Response.Write "</b>"
			Else
				%><a href="<%=RW_b(GBL_board_ID,1,"&e=1&eid=" & TArray(0,N))%>"><%=TArray(1,N)%></a>			<%End If%></li>
		<%
	Next%>
	</ul>
	</div>
	<%

End Sub

Sub Boars_Side_Box_MakeFile(side)

	If side <> "_close" Then	
		Response.Write SideBoard_GetContent
	End If

End Sub

Sub Boars_Side_Box(side)

	Boars_Side_Box_MakeFile(side)

End Sub

Main
%>