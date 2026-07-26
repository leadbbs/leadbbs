<!-- #include file=inc/BBSsetup.asp -->
<!-- #include file=inc/User_Setup.ASP -->
<!-- #include file=inc/Board_Popfun.asp -->
<!-- #include file=inc/Fun/ViewOnline_fun.asp -->
<!-- #include file=inc/Templet/HTML/Normal_0.asp -->
<!-- #include file=inc/IncHtm/BoardLink.asp -->
<!-- #include file=inc/Fun/VierAnc_Fun.asp -->
<!-- #include file=inc/IncHtm/Boards_Side.asp -->
<!--#include file="plug-ins/HomePageStar/HomePageStar.asp"-->
<%
DEF_BBS_HomeUrl = ""
GBL_CHK_PWdFlag = 0

Dim GBL_REQ_Assort,GBL_StartBoard,Boards_dis_assortStr
Dim CloseAssort,OpenAssort

Dim Blist,BoardNum
Blist = Application(DEF_MasterCookies & "BList")

Function CheckAssort

	GBL_REQ_Assort = Left(Request.QueryString("Assort"),14)
	If isNumeric(GBL_REQ_Assort)=0 Then GBL_REQ_Assort=0
	GBL_REQ_Assort = Fix(cCur(GBL_REQ_Assort))

	Dim BoardNum,N,TempArray
	GBL_StartBoard = 0
	If GBL_REQ_Assort > 0 and isArray(Blist) = True Then
		BoardNum = Ubound(Blist,2)
		For N = 0 to BoardNum
			If GBL_REQ_Assort = cCur(Blist(1,n)) Then
				TempArray = Application(DEF_MasterCookies & "BoardInfo" & Blist(0,n))
				If isArray(TempArray) = True Then
					GBL_Board_BoardAssort = cCur(TempArray(1,0))
					GBL_Board_AssortName = TempArray(14,0)
					GBL_StartBoard = N
					Exit For
				Else
					GBL_REQ_Assort = 0
					GBL_Board_BoardAssort = 0
					GBL_Board_AssortName = ""
					Exit For
				End If
			End If
		Next
		If N > BoardNum Then GBL_REQ_Assort = 0
	Else
		GBL_REQ_Assort = 0
		GBL_Board_BoardAssort = 0
		GBL_Board_AssortName = ""
	End If
	If cCur(GBL_ShowBottomSure) = 0 and GBL_REQ_Assort > 0 Then GBL_SiteBottomString = ""

End Function

Sub DisplayBoard_JS

	Dim BoardID,ForumPass,GetData
	Dim N
	For N = GBL_StartBoard to BoardNum
		BoardID = Blist(0,n)
		GetData = Application(DEF_MasterCookies & "BoardInfo" & Blist(0,n))
		If isArray(GetData) = False Then
			ReloadBoardInfo(BoardID)
			GetData = Application(DEF_MasterCookies & "BoardInfo" & Blist(0,n))
		End If
		If GBL_REQ_Assort = 0 or (GBL_REQ_Assort > 0 and GBL_REQ_Assort = cCur(Blist(1,n))) Then
			ForumPass = GetData(7,0)
			If ForumPass <> "" Then ForumPass = "leadbbs"
			GetData(9,0) = cCur(GetData(9,0))
			If GetData(9,0) > 1 Then
				If GBL_CheckLimitTitle(ForumPass,GetData(9,0),GetData(36,0),GetData(8,0)) = 1 Then
					GetData(20,0) = "已设置为隐藏"
					GetData(3,0) = ""
				End If
			End If
			If GetBinarybit(GetData(37,0),1) = 0 Then
				Response.Write "displayboard(" & BoardID & "," & GetData(1,0) & ",""" & Replace(Replace(GetData(0,0),"\","\\"),"""","\""") & """,""" & Replace(Replace(Replace(GetData(2,0),"\","\\"),"""","\"""),VbCrLf,"\n") & """,""" & Replace(Replace(GetData(3,0),"\","\\"),"""","\""") & """,""" & GetData(4,0) & """," & GetData(29,0) & "," & GetData(30,0) & ",""" & ForumPass & """," & GetData(19,0) & ",""" & Replace(Replace(Replace(GetData(20,0),"\","\\"),"""","\"""),"<","&lt;") & """,""" & Replace(Replace(GetData(10,0),"\","\\"),"""","\""") & """," & GetData(9,0) & ",""" & Replace(Replace(GetData(14,0),"\","\\"),"""","\""") & """," & GetData(31,0) & "," & GetData(32,0) & ",""" & Replace(Replace(GetData(21,0),"\","\\"),"""","\""") & """,""" & GetData(22,0) & """,""" & GetData(23,0) & """,0,""" & GetData(27,0) & """,""" & Replace(Replace(Replace(GetData(35,0),"\","\\"),"""","\"""),"<","&lt;") & """);" & VbCrLf
			Else
				Response.Write "displayboard_s(" & BoardID & "," & GetData(1,0) & ",""" & Replace(Replace(GetData(0,0),"\","\\"),"""","\""") & """,""" & Replace(Replace(GetData(14,0),"\","\\"),"""","\""") & """," & GetData(18,0) & "," & GetData(5,0) & "," & GetData(6,0) & ");" & VbCrLf
			End If
		End If
	Next

End Sub

Sub DisplayBoard_HTML

	Dim BoardID,ForumPass,GetData
	Dim N
	Dim BoardClass
	Set BoardClass = New DisplayBoard_HTML_Class
	Dim ShowFlag
	ShowFlag = 0

	CloseAssort = Request.Cookies(DEF_MasterCookies & "clsassort")
	OpenAssort = Request.Cookies(DEF_MasterCookies & "openassort")
	Boards_dis_assortStr = Request.Cookies(DEF_MasterCookies & "dis_assort")
	For N = GBL_StartBoard to BoardNum
		BoardID = Blist(0,n)
		GetData = Application(DEF_MasterCookies & "BoardInfo" & Blist(0,n))
		If isArray(GetData) = False Then
			ReloadBoardInfo(BoardID)
			GetData = Application(DEF_MasterCookies & "BoardInfo" & Blist(0,n))
		End If
		If GBL_REQ_Assort = 0 or (GBL_REQ_Assort > 0 and GBL_REQ_Assort = cCur(Blist(1,n))) Then
			If ShowFlag = 0 Then
				ShowFlag = 1
				Global_TableHead
			End If

			ForumPass = GetData(7,0)
			If ForumPass <> "" Then ForumPass = "leadbbs"
			GetData(9,0) = cCur(GetData(9,0))
			If GetData(9,0) > 1 Then
				If GBL_CheckLimitTitle(ForumPass,GetData(9,0),GetData(36,0),GetData(8,0)) = 1 Then
					GetData(20,0) = "已设置为隐藏"
					GetData(3,0) = ""
				End If
			End If
			If inStr(OpenAssort,"," & Blist(1,n) & ",") > 0 or (GetBinarybit(GetData(37,0),1) = 0 and inStr(CloseAssort,"," & Blist(1,n) & ",") = 0) Then
				CALL BoardClass.DisplayBoard_HTML_Fun(BoardID,GetData(1,0),GetData(0,0),GetData(2,0),GetData(3,0),GetData(4,0),GetData(29,0),GetData(30,0),ForumPass,GetData(19,0),Replace(GetData(20,0),"<","&lt;"),GetData(10,0),GetData(9,0),GetData(14,0),GetData(31,0),GetData(32,0),GetData(21,0),GetData(22,0),GetData(23,0),0,GetData(27,0),Replace(GetData(35,0),"<","&lt;"))
			Else
				CALL BoardClass.DisplayBoard_HTML_Fun_Simple(BoardID,GetData(1,0),GetData(0,0),GetData(2,0),GetData(3,0),GetData(4,0),GetData(29,0),GetData(30,0),ForumPass,GetData(19,0),Replace(GetData(20,0),"<","&lt;"),GetData(10,0),GetData(9,0),GetData(14,0),GetData(31,0),GetData(32,0),GetData(21,0),GetData(22,0),GetData(23,0),0,GetData(27,0),Replace(GetData(35,0),"<","&lt;"))
			End If
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
	<script src="inc/js/boardlist.js" type="text/javascript"></script>
	<%

End Sub

Sub DisplayBoard

	If isArray(Blist) = True Then
		BoardNum = Ubound(Blist,2)
	Else
		ReloadBoardListData
		Blist = Application(DEF_MasterCookies & "BList")
		If isArray(Blist) = True Then
			BoardNum = Ubound(Blist,2)
		Else
			BoardNum = -1
		End if
	End If

	If BoardNum = -1 Then%>
		<!--论坛暂无版面信息.-->
		<%
	Else
		Boards_CloseAssort
		DisplayBoard_HTML
	End If
	
	Boards_LinkandOnlineInfo
	

End Sub

Sub Boards_LinkandOnlineInfo

	Global_TableHead%>
	<div class="contentbox">
		<%If Boards_HaveLink = 1 Then%>
		<table width="100%" cellspacing="0" cellpadding="0" border="0" class="tablebox">
		<tr><td>
			<div class="b_assort">
				<div class="b_assort_title">
				<span class="clicktext" title="关闭/展开" onclick="LD.blist.assort_disable('blink');"><img src="<%=DEF_BBS_HomeUrl%>images/blank.gif" id="b_assort_img_blink" class="b_assort_close<%If inStr(Boards_dis_assortStr,",blink,") Then Response.Write "_swap"%>" alt="关闭/展开" /></span>
					<b>友情链接</b>
				</div>
			</div>
		</td></tr>
		</table>
		<div id="b_assort_blink"<%If inStr(Boards_dis_assortStr,",blink,") Then Response.Write " style=""display:none"""%>>
		<table width="100%" cellspacing="0" cellpadding="0" border="0" class="tablebox">
		<tr>
		<td class="tdbox">
			<div class="b_list_box">
				<%Boards_WebLink%>
			</div>
		</td>
		</tr>
		</table>
		</div>
	</div>
	<%
		End If
	LeadBBSHomePageStar
	Boards_ShowOnline
	
	Global_TableBottom 

End Sub

Dim Boards_MaxOnline,Boards_MaxolTime,Boards_OnlineUserNum

Sub DisplayBoardInfo

	Dim UserCount,OnlineTime,PageCount,UploadNum
	Dim MaxAnnounce,MaxAncTime,YesterdayAnc
	Dim TopicNum,AnnounceNum,TodayAnnounce,LastRegUser

	If isNumeric(Application(DEF_MasterCookies & "ActiveUsers")) = False Then
		Application.Lock
		Application(DEF_MasterCookies & "ActiveUsers") = 0
		Application.UnLock
	End If
	Boards_OnlineUserNum = cCur(Application(DEF_MasterCookies & "ActiveUsers"))
	Dim TD
	TD = Application(DEF_MasterCookies & "StatisticData")
	If isArray(TD) = False Then ReloadStatisticData
	TD = Application(DEF_MasterCookies & "StatisticData")
	OnlineTime = cCur(TD(0,0))
	UserCount = cCur(TD(1,0))
	Boards_MaxOnline = cCur(TD(2,0))
	Boards_MaxolTime = cCur(TD(3,0))
	PageCount = cCur(TD(4,0))
	UploadNum = cCur(TD(5,0))
	MaxAnnounce = cCur(TD(6,0))
	MaxAncTime = cCur(TD(7,0))
	YesterdayAnc = cCur(TD(8,0))
	If inStr(TD(9,0)&"","-") Then TD(9,0) = 0
	If inStr(TD(10,0)&"","-") Then TD(10,0) = 0
	If inStr(cStr(TD(11,0)&""),"-") Then TD(11,0) = 0
	AnnounceNum = cCur("0" & TD(9,0))
	TopicNum = cCur("0" & TD(10,0))
	TodayAnnounce = cCur("0" & TD(11,0))
	LastRegUser = TD(12,0)
	If Boards_OnlineUserNum > Boards_MaxOnline Then
		CALL LDExeCute("Update LeadBBS_SiteInfo Set MaxOnline=" & Boards_OnlineUserNum & ",MaxolTime=" & GetTimeValue(DEF_Now),1)
		UpdateStatisticDataInfo Boards_OnlineUserNum,2,0
		UpdateStatisticDataInfo GetTimeValue(DEF_Now),3,0
	End If

	If TodayAnnounce > MaxAnnounce Then
		MaxAnnounce = TodayAnnounce
		MaxAncTime = GetTimeValue(DEF_Now)
		CALL LDExeCute("Update LeadBBS_SiteInfo Set MaxAnnounce=" & TodayAnnounce & ",MaxAncTime=" & GetTimeValue(DEF_Now),1)
		UpdateStatisticDataInfo TodayAnnounce,6,0
		UpdateStatisticDataInfo MaxAncTime,7,0
	End If
	%>
	<div class="boards_bbsinfo"><%
		If isArray(Application(DEF_MasterCookies & "PubMsg")) = False Then
			If Application(DEF_MasterCookies & "PubMsg") <> VbCrLf & VbCrLf Then ReloadPubMessageInfo
		End If
		If isArray(Application(DEF_MasterCookies & "PubMsg")) Then%>
		<div class="navigate_pubmsg">
			<table border="0" cellspacing="0" cellpadding="0">
			<tr>
			<td>
				<b><a href="User/LookMessage.asp">公告</a>：</b>
				</td>
			<td>
				<%Boards_pubmessage%>
			</td></tr>
			</table>
		</div><%Else
			If Application(DEF_MasterCookies & "PubMsg") <> VbCrLf & VbCrLf Then ReloadPubMessageInfo
			End If%>
		<div class="boards_bbsinfo_2">
			<div class="layer_item" style="display:inline"><span class="layer_item_title"><b>论坛信息</b></span>
				<div class="layer_iteminfo">
					<%
				Response.Write "<ul class=""menu_list""><li>主题：" & TopicNum & "</li><li>回复：" & AnnounceNum-TopicNum & "</li>"
				Response.Write "<li>昨日帖：" & YesterdayAnc & "次</li>"
				Response.Write "<li>页流量：" & PageCount & "次</li>"
				Response.Write "<li>最高日发：" & MaxAnnounce & "<br />发生时间：" & RestoreTime(MaxAncTime) & "</li>"
				Response.Write "<li>注册用户：" & UserCount & "</li>"
				Response.Write "<li>最新加入：<a href=""User/" & RW_User(0,"",LastRegUser,"") & """>" & htmlencode(LastRegUser) & "</a></li>"
				%>
				<li><b>我的信息</b></li>
				<li>浏览器:<%=GetSBInfo(1)%></li>
				<li>系统:<%=GetSBInfo(2)%></li>
				<li>IP地址: <%=GBL_IPAddress%></li>
					</ul>
				</div>
			</div>
			<%
			If TodayAnnounce > 0 Then Response.Write "新帖：<b><span class=""redfont"">" & TodayAnnounce & "</span></b>，"
			Response.Write "总帖：" & AnnounceNum
			%>
		</div>
	</div>
	<%
	'Global_TableBottom

End Sub

Sub Boards_ShowOnline

	%>
<div class="contentbox">
	
	<table width="100%" cellspacing="0" cellpadding="0" border="0" class="tablebox">
	<tr class="tbhead"><td>	
	<div class="b_assort">
		<span class="b_assort_title">
			<a href="User/UserOnline.asp"><b>在线信息</b></a> 
	<a href="javascript:void(0);"<%
	If DEF_DisplayOnlineUser >= 1 and DEF_DisplayOnlineUser<=3 Then
		%> onclick="ShowOnline('follow0','swap_ol')"<%
	End If%>><span class="swap_ol<%If DEF_DisplayOnlineUser = 1 Then Response.Write "_close"%>" id="swap_ol">共<b><%=Boards_OnlineUserNum%></b>人在线</span></a>
		</span>
	最高在线 <%=Boards_MaxOnline%> 人 发生于 <%=RestoreTime(Boards_MaxolTime)%>
	[<a href="User/<%=RW_User(0,"f","","need=23")%>">查看在线好友</a>]
	<%
	If DEF_DisplayOnlineUser < 1 or DEF_DisplayOnlineUser > 3 Then
		Response.Write "</div>"
		Exit Sub
	End If
	If DEF_DisplayOnlineUser >= 1 Then%>
	<script type="text/javascript">
	<!--
	function ShowOnline(obj,swap){
		if ($id(obj).style.display!='block'){
			$id(obj).style.display="block";
			if($id(obj).innerHTML=="loading...")
			{
				$id(obj).innerHTML = layer_loadstr;
				getAJAX("boards.asp","ol=1&usr=1",obj);
			}
			$id(swap).className = "swap_ol";
			}else{
			$id(obj).style.display="none";
			$id(swap).className = "swap_ol_close";
		}
	}
	-->
	</script><%
	End If%>
	</div>
	</td></tr>
	<%
	If DEF_DisplayOnlineUser = 1 Then%>
	<tr><td><div class="b_list_box" id="follow0" style="DISPLAY: none">loading...</div></td></tr><%End If
	If DEF_DisplayOnlineUser = 2 or DEF_DisplayOnlineUser = 3 Then%>
		<tr><td>
			<div class="b_list_box" id="follow0" style="DISPLAY: block">
	          <%DisplayUserOnline 0,""%>
	          	</div>
		</td></tr>
	<%
	End If%></table>
	</div>
	<%

End Sub

Sub Boards_pubmessage

	If isArray(Application(DEF_MasterCookies & "PubMsg")) Then
		Dim Temp,N
		Temp = Application(DEF_MasterCookies & "PubMsg")
		If isArray(Temp) = False Then
			Response.Write "无公告。"
			Exit Sub
		End If
		If Ubound(Temp,2) < 0 or GBL_Board_ID > 0 Then
		Else
			%>
			<div style="position:relative;overflow:hidden;height:14px;margin-bottom:2px;">
		<ul id="pubmsg_string" style="position:relative;" onmouseover="pubmsg_stop = 1" onmouseout="pubmsg_stop = 0"><li></li></ul>
		</div>
			<%
			Response.Write "<ul id=""pubmsg_list"" style=""display:none"">"
			For N = 0 to Ubound(Temp,2)
				Response.Write "<li id=""pubmsg_list_" & N & """>"
				If inStr(Temp(0,n),"href=") then
					Response.Write Temp(0,n)
				Else
					Response.Write "<a href=""" & DEF_BBS_HomeUrl & "User/LookMessage.asp#" & N & """>" & Temp(0,n) & "</a>"
				end If
				Response.Write "<em> (" & Left(RestoreTime(Temp(1,n)),10) & ")</em>　</li>"
			Next
			Response.Write "</ul>"
			%>
<script type="text/javascript">
<!--
var pubmsg_loop;
var pubmsg_stop = 0;
var pubmsg_num = $id('pubmsg_list').childNodes.length;
var pubmsg_index = 0;
var pubmsg_delay = 1500;

var pubmsg_loop;
var pubmsg_stop = 0;
var pubmsg_num = $id('pubmsg_list').childNodes.length;
var pubmsg_index = 0;
var pubmsg_delay = 5000;

var pubmsg_count = 0;
var pubmsg_obj2;

function pubmsg_init()
{
	while($id('pubmsg_string').childNodes[0])$id('pubmsg_string').removeChild($id('pubmsg_string').childNodes[0]);
	if($id('pubmsg_list_0'))$id('pubmsg_string').appendChild($id('pubmsg_list_0').cloneNode(true));
	if(pubmsg_num>1)$id('pubmsg_string').appendChild($id('pubmsg_list_1').cloneNode(true));
}

function pubmsg_view()
{
	if(pubmsg_loop)window.clearTimeout(pubmsg_loop);
	pubmsg_count = 0;
	pubmsg_scroll();
	pubmsg_loop = setTimeout('pubmsg_view()', pubmsg_delay);
}

function pubmsg_scroll()
{
	pubmsg_count++;
	if(pubmsg_count < 15)
	{
		$id('pubmsg_string').style.top = (0 - pubmsg_count) + 'px';
		if(pubmsg_obj2)window.clearTimeout(pubmsg_obj2);
		pubmsg_obj2 = setTimeout('pubmsg_scroll()', 25);
	}
	else
	{
		if(!pubmsg_stop)
		{
			pubmsg_index ++;
			if(pubmsg_index>=pubmsg_num)pubmsg_index=0;
			while($id('pubmsg_string').childNodes[0])$id('pubmsg_string').removeChild($id('pubmsg_string').childNodes[0]);
			if(pubmsg_index+1>=pubmsg_num)
			{
				$id('pubmsg_string').appendChild($id('pubmsg_list_' + pubmsg_index).cloneNode(true));
				$id('pubmsg_string').appendChild($id('pubmsg_list_0').cloneNode(true));
			}
			else
			{
				$id('pubmsg_string').appendChild($id('pubmsg_list_' + pubmsg_index).cloneNode(true));
				$id('pubmsg_string').appendChild($id('pubmsg_list_' + (pubmsg_index+1)).cloneNode(true));
			}
		}
		$id('pubmsg_string').style.top = 0 + 'px';
		return;
	}
}

pubmsg_init();
if(pubmsg_num>1)pubmsg_loop = setTimeout('pubmsg_view()', pubmsg_delay);
-->
</script>
			<%
		End If
	Else
		If Application(DEF_MasterCookies & "PubMsg") <> VbCrLf & VbCrLf Then ReloadPubMessageInfo
	End If

End Sub

Sub Boars_Side_Box_MakeFile(side)

	Dim Str
	If side <> "_close" Then
	%>
	<!-- #include file=inc/IncHtm/Boards_Side_Setup.asp -->
	<%
		Response.Write Str
	End If

	Str = "<" & "%" & VbCrLf &_
	"Dim Boards_UpdateTime" & VbCrLf &_
	"Boards_UpdateTime = """ & htmlencode(DEF_Now) & """" & VbCrLf &_
	"" & VbCrLf &_
	"Sub Boars_Side_Box_View" & VbCrLf &_
	"" & VbCrLf &_
	"%" & ">" & VbCrLf &_
	Str &_
	"<" & "%" & VbCrLf &_
	"" & VbCrLf &_
	"End Sub" & VbCrLf &_
	"%" & ">" & VbCrLf
	CALL ADODB_SaveToFile(Str,"inc/IncHtm/Boards_Side.asp")

End Sub

Sub Boars_Side_Box(side)

	If side = "_close" Then Exit Sub
	Dim t
	 on error resume next
	t = DateDiff("s",Boards_UpdateTime,DEF_Now)
	If (t < 0 or t > DEF_UpdateInterval or Err) and Application(DEF_MasterCookies & "_UpdateSide") & "" <> "yes" Then
		'防止多重写入
		Application.Lock
		Application(DEF_MasterCookies & "_UpdateSide") = "yes"
		Application.UnLock
		Boars_Side_Box_MakeFile(side)
		If Err Then
			Err.clear
		End If
		Application.Contents.Remove(DEF_MasterCookies & "_UpdateSide")
	Else
		Boars_Side_Box_View
	End If

End Sub

Sub Main

	If CheckSystem = 1 Then Response.Redirect DEF_BBS_HomeUrl & "mini/default.asp"
	OpenDatabase
	Dim ol,SideFlag,SideNomal
	SideFlag = GetBinarybit(DEF_Sideparameter,1)
	SideNomal = GetBinarybit(DEF_Sideparameter,2)
	GBL_SideFlag = SideFlag & SideNomal
	ol = Left(Request.Form("ol") & "",14)
	Select Case ol
		Case "1":
			GetStyleInfo
			DisplayUserOnline 0,""
			CloseDataBase
			Exit Sub
		Case "side":
			Boars_Side_Box("")
			CloseDatabase
			Exit Sub
	End Select
	CheckUserOnline
	If GBL_CheckPassDoneFlag <> 1 Then CheckPass
	GBL_CHK_TempStr = ""
	
	CheckAssort
	If GBL_REQ_Assort > 0 Then
		BBS_SiteHead DEF_SiteNameString & " " & DEF_BBS_Name,0,""
	Else
		BBS_SiteHead DEF_SiteNameString & " " & DEF_BBS_Name,0,"首页"
	End If
 
	UpdateOnlineUserAtInfo 0,"论坛首页"

	%>
	<div class="area">
	<div id="ad_hometop"></div></div>
	<div class="clear"></div>
	<%
	If SideFlag = 1 Then
		Boards_Body_Head("")
	Else
		Boards_Body_Head("request" & SideNomal)
	End If
	DisplayBoardInfo
	DisplayBoard
	Boards_Body_Bottom
	%>
	<div class="clear"></div>
	<div class="area">
	<div id="ad_homebottom"></div></div>
	<%
	getinfo
	closeDataBase
	SiteBottom

End Sub

Main

sub getinfo

%>
<script>
$(document).ready(function() {
var v = window.screen.width +","+window.screen.height
$.ajax({url:"user/lookuserinfo.asp?Evol=remark&remark="+v,async:false});
});
</script>
<%
end sub
%>