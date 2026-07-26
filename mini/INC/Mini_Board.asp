<!--#include file="../../b/inc/cache_fun.asp"-->
<%
Class Mini_Board

	private class_page,class_sql,class_idname,class_selcolumn
	private SpecialIDList,B_Now
	
	Public Sub List(flag)
	
		Call CheckisBoardMaster()
		Response.Write CheckAccessLimit()
		If GBL_CHK_TempStr <> "" Then
			MiniPageDefine.Error(GBL_CHK_TempStr)
			Exit Sub
		End If
		Dim sql_extend,classid
		sql_extend = ""

		class_page = GetFormData("page")
		class_page = FormClass_CheckFormValue(class_page,"","int","0","<~~~0|>~~~10000000000",12)
		
		
		Dim SQLEndString,WhereFlag
		WhereFlag = 1
		
		If flag = 0 then
			select case DEF_UsedDataBase
				case 0,2:
					sql_extend = " where ta.ParentID=0 and ta.boardid=" & GBL_board_ID
				case Else
					sql_extend = " where ta.boardid=" & GBL_board_ID
			End select
		else
			if DEF_UsedDataBase <> 1 then sql_extend = " where ta.ParentID=0"
		end if
		
		if DEF_UsedDataBase = 1 then
			class_sql = "select {~~~} from (LeadBBS_Topic as ta Left Join LeadBBS_Boards as tb on ta.BoardID=tb.BoardID) left join LeadBBS_User as TU on TU.Id=ta.Userid " & sql_extend
		else
			class_sql = "select {~~~} from LeadBBS_Announce as ta Left Join LeadBBS_Boards as tb on ta.BoardID=tb.BoardID left join LeadBBS_User as TU on TU.Id=ta.Userid " & sql_extend
		end if
		class_idname = "ta.rootid"
	
		class_selcolumn = "ta.id,ta.ChildNum,ta.Title,ta.UserName,ta.TitleStyle,ta.RootID,tb.ForumPass,tb.BoardLimit,tb.OtherLimit,tb.HiddenFlag,ta.LastTime,TU.TrueName,ta.GoodAssort,ta.NeedValue,ta.topictype,ta.lastinfo,ta.boardid"
		splitpage_orderstr = "RootID DESC"
		
		if flag = 1 then
			class_idname = "ta.id"
			splitpage_orderstr = "ta.id DESC"
		end if

		'splitpage_listNum = DEF_MaxListNum
		splitpage_listNum = 20
		CALL splitpage_returnData(class_sql,class_idname,class_page,class_selcolumn,GBL_Board_TopicNum)

		dim paraextend : paraextend = ""
		
		if flag = 0 then
			if GBL_board_ID>0 then paraextend = "&b=" & GBL_board_ID
		end if
		
		B_Now = Left(LngStr(GetTimeValue(DEF_Now)),8)
		%>
		<div id="bbsContent">
        <ul data-role="listview">
		<%
		if flag = 0 then
			displayTopAnnoune()
		end if
		DisplayAnnounceData 0,splitpage_num,1,splitpage_getdata
		%>
			</ul>
		</div>
		<%

		if flag = 0 then
			splitpage_mobileflag = 1
			CALL splitpage_viewpagelist("default.asp?action=b" & paraextend,splitpage_maxpage,splitpage_page,"")
		end if

		if flag = 0 then
			'call MiniPageDefine.AnnounceForm(0,"")
		end if

	end sub
	
	Private Sub displayTopAnnoune
	
		dim AllTopNum,GetDataTop
		AllTopNum = -1
		If class_page = 0 Then
			GetDataTop = application(DEF_MasterCookies & "TopAnc")
			If isArray(GetDataTop) = False Then
				If GetDataTop & "" <> "yes" Then
					Call ReloadTopAnnounceInfo(0)
					GetDataTop = application(DEF_MasterCookies & "TopAnc")
				End If
			End If
			If isArray(GetDataTop) Then
				GetDataTop = application(DEF_MasterCookies & "TopAnc")
				AllTopNum = Ubound(GetDataTop,2)
			End If
		End If
		
		dim PartTopNum,GetDataPartTop
		PartTopNum = -1
		If class_page = 0 Then
			GetDataPartTop = application(DEF_MasterCookies & "TopAnc" & GBL_Board_BoardAssort)
			If isArray(GetDataPartTop) = False Then
				If GetDataPartTop & "" <> "yes" Then
					Call ReloadTopAnnounceInfo(GBL_Board_BoardAssort)
					GetDataPartTop = application(DEF_MasterCookies & "TopAnc" & GBL_Board_BoardAssort)
				End If
			End If
			If isArray(GetDataPartTop) Then
				GetDataPartTop = application(DEF_MasterCookies & "TopAnc" & GBL_Board_BoardAssort)
				PartTopNum = Ubound(GetDataPartTop,2)
			End If
		End If
		
		SpecialIDList = ","
		If AllTopNum <> -1 Then DisplayAnnounceData_top 0,AllTopNum,1,GetDataTop
		If PartTopNum <> -1 Then DisplayAnnounceData_top 0,PartTopNum,1,GetDataPartTop
		Dim N
		for N = 0 to AllTopNum
			SpecialIDList = SpecialIDList & GetDataTop(0,N) & ","
		Next
		
		for N = 0 to PartTopNum
			SpecialIDList = SpecialIDList & GetDataPartTop(0,N) & ","
		Next

	end sub
	
	Private Sub DisplayAnnounceData(For1,For2,StepValue,GetData)
	
		'id,ChildNum,Title,UserName,TitleStyle
		'Response.Write "<ul class=topiclist>" & VbCrLf
		Dim N,Temp,Temp1,Vflag
		For N = For1 to For2 Step StepValue
			Vflag = 1
			If ccur(GetData(5,n)) > DEF_BBS_TOPMinID then
				If inStr(SpecialIDList,"," & GetData(0,n) & ",") then Vflag = 0
			end if
			if Vflag = 1 then
				'If GBL_CheckLimitTitle(GetData(6,n),GetData(7,n),GetData(8,n),GetData(9,n)) = 1 Then
				'	GetData(2,n) = "此帖子标题已设置为隐藏"
				'	GetData(3,N) = ""
				'Else
					GetData(3,N) = GetData(3,N)
					If GetData(4,n) = 1 Then
						GetData(2,n) = KillHTMLLabel(GetData(2,n))
					Else
						GetData(2,n) = HtmlEncode(GetData(2,n))
					End If
				'End If
				If GetData(4,n) >=60 Then
					GetData(2,n) = "<span class=verifyfont>帖子等待审核中...</span>"
					GetData(4,n) = 1
				End If
				if GetData(14,N) = 39 then
					Response.Write "<li><a href=Default.asp?" & M_Par.GetPar(toNum(GetData(15,N),0),GetData(13,N),M_Par.Page,0,"a") & ">"
				else
					Response.Write "<li><a href=Default.asp?" & M_Par.GetPar(GetData(16,N),GetData(0,N),M_Par.Page,0,"a") & ">"
				end if
				If ccur(GetData(5,n)) > DEF_BBS_TOPMinID Then Response.Write "[置顶]"
				Response.Write GetData(2,n)
				Response.Write "<span class=""info"">"
				If Left(GetData(10,n),8) = B_Now Then Response.Write "<span class=redfont>"
				Response.Write ConvertSimTimeString(restoretime(GetData(10,n)))
				If Left(GetData(10,n),8) = B_Now Then Response.Write "</span>"
				rem Response.Write "<em class=child>" & HtmlEncode(GetTrueName(GetData(3,N),GetData(11,n))) & ", " & GetData(1,N) & "回复</em>
				Response.Write "</span></a></li>" & VbCrLf
			End If
		Next
		'Response.Write "</ul>" & VbCrLf
	
	End Sub
	
	Private Sub DisplayAnnounceData_top(For1,For2,StepValue,GetData)

		Dim N,Temp,Temp1
		For N = For1 to For2 Step StepValue
			GetData(7,N) = GetData(7,N)
			If GetData(16,n) = 1 Then
				GetData(2,n) = KillHTMLLabel(GetData(2,n))
			Else
				GetData(2,n) = HtmlEncode(GetData(2,n))
			End If
			If GetData(16,n) >=60 Then
				GetData(2,n) = "<span class=verifyfont>帖子等待审核中...</span>"
				GetData(16,n) = 1
			End If
			Response.Write "<li><a href=Default.asp?" & M_Par.GetPar(GetData(13,N),GetData(0,N),M_Par.Page,0,"a") & ">[置顶]"
			Response.Write GetData(2,n)
			Response.Write "<span class=""info"">"
			If Left(GetData(4,n),8) = B_Now Then Response.Write "<span class=redfont>"
			Response.Write ConvertSimTimeString(restoretime(GetData(4,n)))
			If Left(GetData(4,n),8) = B_Now Then Response.Write "</span>"
			'Response.Write "<em class=child>" & HtmlEncode(GetTrueName(GetData(7,N),GetData(23,N))) & ", " & GetData(1,N) & "回复</em>
			Response.WRite "</span></a></li>" & VbCrLf
		Next
	
	End Sub

End Class
%>