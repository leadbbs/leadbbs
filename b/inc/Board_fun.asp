<!-- #include file=../../inc/Templet/HTML/Normal_1.asp -->
<!-- #include file=cache_fun.asp -->
<%
Dim LMT_UrlEndString
Dim SpecialIDList : SpecialIDList = ","
dim LMT_listtype : LMT_listtype = 1
dim LMT_action : LMT_action = ""

Sub DisplayAnnouncesSplitPages

	Dim Temp
if LMT_Simple = 0 then 'start simple
	If GBL_BoardMasterFlag >= 5 Then%>
	<script src="<%=DEF_BBS_HomeUrl%>inc/js/p_list.js?ver=20090601.2" type="text/javascript"></script>
	<%End If%>
	<script type="text/javascript">
	<!--
	function Show2(obj,obj2,id)
	{
		if ($id(obj).style.display!='block')
		{
			$id(obj).style.display="block";
			$id((obj2)).src="../images/<%=GBL_DefineImage%>Expand.gif";
			if($id(obj).innerHTML=="")
			{
				$id(obj).innerHTML="下载中...";getAJAX("b.asp?b=<%=GBL_Board_ID%>","ol=3&id=" + id,"Lead" + id);
			}
		}else{
			$id(obj).style.display="none";
			$id((obj2)).src="../images/<%=GBL_DefineImage%>clsExpand.gif";
		}
	}
	<%If GBL_BoardMasterFlag >= 5 Then
		If GBL_Board_ID <> 444 and DEF_EnableDelAnnounce = 0 Then
			Temp = "Move&b=" & GBL_Board_ID & "&BoardID2=444"
		Else
			Temp = "Del&b=" & GBL_Board_ID
		End If
	%>
	function a_command(cstr,obj,action)
	{
		layer_view(cstr,obj,'','','anc_delbody','<%=DEF_BBS_HomeUrl%>a/Processor.asp','',1,'AjaxFlag=1&action=' + action,1);return(false);
	}
	function delbody_view(obj)
	{
		layer_create("anc_msgbody");
		$id('anc_msgbody').innerHTML="<div class=ajaxbox>已选择 <b id=layer_selectnum>" + p_getnum() + "</b> 条记录：<br>请选择操作：<b><a href=\"javascript:;\" onclick=\"a_command('删除帖子',$id('" + obj.id + "'),'<%=Temp%>&ID='+p_getselected());\">批量删除</a>, <a href=\"javascript:;\" onclick=\"a_command('转移帖子',$id('" + obj.id + "'),'<%Response.Write "Move&b=" & GBL_Board_ID & ""%>&ID='+p_getselected());\">批量转移</a></b><br><input class=\"fmchkbox\" type=\"checkbox\" name=\"selmsg\" id=\"selmsg\" value=\"1\" onclick=\"achoose();\" />选择全部</div>";
		layer_view('',obj,'','','anc_msgbody','','',0,'',0,20);
	}
	<%End If%>
	-->
	</script>
<%
end if 'end simple
	DisplayAnnouncesSplitPages_List

End Sub


function DisplayAnnouncesSplitPages_List
	
	dim forindex

	dim class_sql,class_idname,class_selcolumn,class_page,sql_extend
	class_page = toNum(request.querystring("page"),0)
	if class_page = 0 then class_page = toNum(request.querystring("q"),0)
	class_page = fix(class_page - 1)
	if class_page < 0 then class_page = 0

	'startid = toNum(request.querystring("sid"),0)
	'if startid > 0 then
	'	
	'end if
	
	dim ALL_Count : ALL_Count = 0
	Con.CommandTimeout = 6
	
	dim LMT_actionColumn : LMT_actionColumn = ""
	dim LMT_actionInner : LMT_actionInner = ""
	if gbl_board_id = 0 and LMT_action = "" then
		if LMT_action = "" then
			LMT_listtype = 1
		end if
		LMT_action = "list"
	end if
if LMT_action <> "" then  'start LMT_action
	LMT_listtype = toNum(request.querystring("type"),0)
	class_idname = "T1.ID"
	
	dim c
	c = fix(toNum(request.querystring("c"),0))
	dim tmp_sql
	select case LMT_listtype
		case 1:
			forindex = get_index("IX_LeadBBS_Announce_RootIDBak2")
			select case DEF_UsedDataBase
				case 0,2:
					splitpage_orderstr = "T1.rootidbak DESC"
					sql_extend = " where T1.ParentID=0"
				case Else
					splitpage_orderstr = "T1.id DESC"
					sql_extend = ""
			End select
			tmp_sql = "Select sum(TopicNum) from LeadBBS_Boards"
		case 2:
			forindex = get_index("IX_LeadBBS_Announce_1")
			splitpage_orderstr = "T1.ID DESC"
			sql_extend = " where T1.goodflag=1"
			tmp_sql = "Select sum(GoodNum) from LeadBBS_Boards"
		case else
			forindex = ""
			splitpage_orderstr = "T1.ID DESC"
			sql_extend = ""
			tmp_sql = "Select sum(AnnounceNum) from LeadBBS_Boards"
	end select
	if c > 0 then
		ALL_Count = c
	else
		set rs = ldexecute(tmp_sql,0)
		if not rs.eof then ALL_Count = ccur("0" & rs(0))
		rs.close
		set rs = nothing
	end if
	LMT_actionColumn = ",T4.ForumPass,T4.BoardLimit,T4.OtherLimit,T4.HiddenFlag"
	LMT_actionInner = " left join LeadBBS_Boards as T4 on T1.BoardID=T4.BoardID"

else ' about LMT_action
	
	ALL_Count = GBL_Board_TopicNum
	If EFlag = "0" or EFlag = "1" then
		If EID > 0 Then
			sql_extend = " where T1.GoodAssort=" & EID
			forindex = get_index("IX_LeadBBS_Announce_GoodAssort")
		Else
			sql_extend = " where T1.GoodFlag=1"
			if GBL_board_ID > 0 then sql_extend = sql_extend & " and T1.boardid=" & GBL_board_ID
			forindex = get_index("IX_LeadBBS_Announce_GoodFlag2")
		End If
		splitpage_orderstr = "T1.ID DESC"
		
		dim TempArray,rs
		If EFlag = "1" Then
			TempArray = Application(DEF_MasterCookies & "BoardInfo" & GBL_board_ID & "_TI")
			If isArray(TempArray) Then
				If EID = 0 Then EID = cCur(TempArray(0,0))
			Else
				TempArray = Application(DEF_MasterCookies & "BoardInfo" & GBL_board_ID)
				EID = 0
			End If
		Else
			TempArray = Application(DEF_MasterCookies & "BoardInfo" & GBL_board_ID)
		End if
		If isArray(TempArray) = False Then Exit Function
	
		If EID > 0 Then
			'If Ubound(TempArray,2) = 0 or Ubound(TempArray,2) < EIndex Then Exit Function
			ALL_Count = cCur(TempArray(2,EIndex))
			If ALL_Count <= 0 Then
				select case DEF_UsedDataBase
					case 0,2:
						Set Rs = LDExeCute("Select Count(*) from LeadBBS_Announce where GoodAssort=" & EID,0)
					case Else
						Set Rs = LDExeCute("Select Count(*) from LeadBBS_Topic where GoodAssort=" & EID,0)
				End select
				If Rs.Eof Then
					ALL_Count = -1
				Else
					ALL_Count = Rs(0)
					If isNull(ALL_Count) Then ALL_Count = 0
					ALL_Count = cCur(ALL_Count)
					If ALL_Count = 0 Then ALL_Count = -1
				End If
				Rs.Close
				Set Rs = Nothing
				TempArray(2,EIndex) = ALL_Count
				Application.Lock
				Application(DEF_MasterCookies & "BoardInfo" & GBL_board_ID & "_TI") = TempArray
				Application.UnLock
			End If
		Else
			ALL_Count = GBL_Board_GoodNum
		End If
	else
		select case DEF_UsedDataBase
			case 0,2:
				sql_extend = " where T1.ParentID=0"
				if GBL_board_ID > 0 then sql_extend = sql_extend & " and T1.boardid=" & GBL_board_ID
			case Else
				if GBL_board_ID > 0 then sql_extend = " where T1.boardid=" & GBL_board_ID
		End select
		if gbl_board_ID > 0 then
			forindex = get_index("IX_LeadBBS_Announce_ParentID")
		else
			exit function
		end if
		splitpage_orderstr = "T1.RootID DESC"
	end if
	class_idname = "T1.rootid"
end if 'end LMT_action
	dim TB
	select case DEF_UsedDataBase
		case 0,2:
			TB = "LeadBBS_Announce"
		case 1:
			TB = "LeadBBS_Topic"
	end select
	class_sql = "select {~~~} from ((" & TB & " as T1 " & forindex & " left join LeadBBS_User as T2 on T2.Id=T1.Userid) left join leadbbs_extend as T3 on (T3.ClassType=200 and T1.ID=T3.extendID)) " & LMT_actionInner & sql_extend
	class_sql = class_sql & "---split---select {~~~} from " & TB & " as T1 " & forindex & " " & sql_extend
			
	class_selcolumn = "T1.id,T1.ChildNum,T1.Title,T1.FaceIcon,T1.LastTime,T1.Hits,T1.Length,T1.UserName,T1.UserID,T1.RootID,T1.LastUser,T1.NotReplay,T1.GoodFlag,T1.BoardID,T1.TopicType,T1.PollNum,T1.TitleStyle,T1.LastInfo,T1.ndatetime,T1.GoodAssort,T1.NeedValue,T2.UserName,T2.ID,T2.TrueName,T3.extent_content,''" & LMT_actionColumn 'T1.content

	splitpage_listNum = DEF_MaxListNum

	if LMT_Action <> "" then splitpage_MaxJumpPageNum = fix(DEF_MaxJumpPageNum/4) '查看全部返回数量减少4倍
	CALL splitpage_returnData(class_sql,class_idname,class_page,class_selcolumn,ALL_Count)
	
	if LMT_Simple = 0 then 'start simple
	%>
	<div id="board_content">
	<%
	end if
	if eflag <> -1 then LMT_UrlEndString = "&e=" & eflag
	if eid <> 0 then LMT_UrlEndString = LMT_UrlEndString & "&eid=" & eid
	'if startid <> 0 then LMT_UrlEndString = LMT_UrlEndString & "&sid=" & startid
	
	if LMT_action <> "" then LMT_UrlEndString = LMT_UrlEndString & "&c=" & ALL_Count
	CALL B_DisplaySplitPageString("b_box_none",LMT_UrlEndString)

	Global_TableHead
	
	dim BoardListClass,AllTopNum,PartTopNum
	Set BoardListClass = New BoardList_HTML_Class
	%>
	<div class="contentbox">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="tablebox table_options<%
		If BoardListClass.CFlag = 1 Then Response.Write "_sim"
		%>" id="table_options">
	<%
	BoardListClass.Showhead

if LMT_action = "" then 'start LMT_action
	dim GetDataTop,GetDataPartTop,n
	AllTopNum = -1
	PartTopNum = -1
	
	If class_page < 1 Then
		GetDataTop = application(DEF_MasterCookies & "TopAnc")
		If isArray(GetDataTop) = False Then
			If GetDataTop & "" <> "yes" Then
				ReloadTopAnnounceInfo(0)
				GetDataTop = application(DEF_MasterCookies & "TopAnc")
			End If
		End If
		If isArray(GetDataTop) Then
			GetDataTop = application(DEF_MasterCookies & "TopAnc")
			AllTopNum = Ubound(GetDataTop,2)
		End If
	
		GetDataPartTop = application(DEF_MasterCookies & "TopAnc" & GBL_Board_BoardAssort)
		If isArray(GetDataPartTop) = False Then
			If GetDataPartTop & "" <> "yes" Then
				ReloadTopAnnounceInfo(GBL_Board_BoardAssort)
				GetDataPartTop = application(DEF_MasterCookies & "TopAnc" & GBL_Board_BoardAssort)
			End If
		End If
		If isArray(GetDataPartTop) Then
			GetDataPartTop = application(DEF_MasterCookies & "TopAnc" & GBL_Board_BoardAssort)
			PartTopNum = Ubound(GetDataPartTop,2)
		End If
	End If
	
	If AllTopNum <> -1 Then DisplayAnnounceData_HTML GetDataTop,1,BoardListClass
	If PartTopNum <> -1 Then DisplayAnnounceData_HTML GetDataPartTop,2,BoardListClass
	for N = 0 to AllTopNum
		SpecialIDList = SpecialIDList & GetDataTop(0,N) & ","
	Next
	
	for N = 0 to PartTopNum
		SpecialIDList = SpecialIDList & GetDataPartTop(0,N) & ","
	Next
end if 'end LMT_action
	if isArray(splitpage_getdata) then
		if LMT_Action <> "" then
			for n = 0 to splitpage_num
				If CheckSupervisorUserName = 0 and GBL_CheckLimitTitle(splitpage_getdata(26,n),splitpage_getdata(27,n),splitpage_getdata(28,n),splitpage_getdata(29,n)) = 1 Then
					splitpage_getdata(2,n) = "<span calss=grayfont>此帖子标题已设置为隐藏</span>"
					splitpage_getdata(16,n) = 1
				else
					if LMT_listtype = 0 then
						if left(splitpage_getdata(2,n),3) = "re:" then
							if splitpage_getdata(2,n) <> "re:" then splitpage_getdata(2,n) = mid(splitpage_getdata(2,n),4)
						end if
					end if
				End If
			next
		end if
		DisplayAnnounceData_HTML splitpage_getdata,0,BoardListClass
	end if
	Set BoardListClass = Nothing
	%>
		</table>
	</div>
	<%Global_TableBottom
	CALL B_DisplaySplitPageString("b_box_none2",LMT_UrlEndString)
	if LMT_Simple = 0 then 'start simple
	%>
	</div>
	<%
	end if

end function

Sub DisplayAnnounceData_HTML(GetData,AllFlag,obj)

	Dim N,Temp,Temp1,Vflag
	dim Num
	Num = ubound(GetData,2)
	For N = 0 to Num
		'If AllFlag = 0 or GBL_Board_ID <> cCur(GetData(13,N)) Then
		'If AllFlag = 1 or GBL_Board_ID <> cCur(GetData(13,N)) Then
		Vflag = 1
		If AllFlag = 0 and ccur(GetData(9,n)) > DEF_BBS_TOPMinID then
			If inStr(SpecialIDList,"," & GetData(0,n) & ",") then Vflag = 0
		end if
		if Vflag = 1 then
			'GetData(2,n) = Replace(GetData(2,n),"&#60","&lt;")
			If GetData(16,n) <> 1 Then GetData(2,n) = Replace(GetData(2,n) & "","<","&lt;")
			If GetData(16,n) >=60 Then
				GetData(2,n) = "<span class=""grayfont"">帖子等待审核中...</span>"
				GetData(16,n) = 1
			End If
			GetData(17,n) = Replace(Replace(Replace(GetData(17,N) & "","<","&lt;"),chr(13),""),chr(10),"")
			CALL obj.leadbbs(AllFlag,GetData(0,N),GetData(1,N),GetData(2,N),GetData(3,N),GetData(4,N),GetData(5,N),GetData(6,N),Replace(GetData(7,N),"<","&lt;"),GetData(8,N),GetData(9,N),Replace(GetData(10,N),"<","&lt;"),GetData(11,n),GetData(12,N),GetData(13,N),GetData(14,N),GetData(15,N),GetData(16,N),GetData(17,n),GetData(18,N),GetData(19,N),GetData(20,N),GetData(21,N),GetData(22,N),GetData(23,N),GetData(24,N),GetData(25,N))
		End If
	Next

End Sub

Sub B_DisplaySplitPageString(css,more)

	splitpage_notbreak = 1
%>
	<div class="<%=css%> fire"><%If gbl_board_id > 0 then%>
		<div class="a_post_image">
			<div class="layer_item">
				<a href="../a/a2.asp?B=<%=GBL_board_ID%>" class="b_post_link"><img src="../images/blank.gif" class="b_post" /></a>
				<div class="layer_iteminfo">
					<ul class="menu_list"><li><a href="../a/a2.asp?B=<%=GBL_board_ID%>">发表新主题</a></li>
					<li><a href="../a/a2.asp?B=<%=GBL_board_ID%>&amp;VoteFlag=yes">发起投票</a></li>
					</ul>
				</div>
			</div>
		</div><%
		elseif LMT_Action <> "" then%>
		<div class="b_assortlist" style="float:left!important">
			<ul>
			<li>
			<%if LMT_listtype = 1 then
				response.write "<b>主题</b>"
			else
				response.write "<a href=""" & RW_b(0,0,"action=list&type=1") & """>主题</a>"
			end if%></li>
			<li><%if LMT_listtype = 0 then
				response.write "<b>回复</b>"
			else
				response.write "<a href=""" & RW_b(0,0,"action=list&type=0") & """>回复</a>"
			end if%></li>
			<li><%if LMT_listtype = 2 then
				response.write "<b>精华</b>"
			else
				response.write "<a href=""" & RW_b(0,0,"action=list&type=2") & """>精华</a>"
			end if%></li>
			</ul>
		</div>
		<%End if%>
	<%
	splitpage_cazhi = 1
	dim url
	if LMT_action = "" then
		url = RW_b(GBL_board_ID,"{page}",more)
	else
		url = RW_b(0,"{page}","action=list&type=" & LMT_listtype & more)
	end if
	'最后一参数使用则启用ajax调用 'board_content||$(\'#board_content\').ScrollTo(600);
	CALL splitpage_viewpagelist(url,splitpage_maxpage,splitpage_page,"")
	'CALL splitpage_viewpagelist(url,splitpage_maxpage,splitpage_page,"board_content||$(\'.head_top_out\').ScrollTo(0);")
	%>
	</div>
<%
End Sub
%>