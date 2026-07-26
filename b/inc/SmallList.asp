<%
Class Small_List

Private RootID

PUBLIC Sub DisplayAnnouncesSplit

	RootID = fix(toNum(Request.form("id"),0))
	If RootID < 1 then exit sub
	dim rs,sql,childNum
	sql = sql_select("select childNum,boardid,parentid from leadbbs_announce where id=" & RootID,1)
	set rs = ldexecute(sql,0)
	if rs.eof then
		rootid = 0
	else
		if ccur(rs(1)) <> gbl_board_id then
			gbl_board_id = rs(1)
			Call Borad_GetBoardIDValue(gbl_board_id)
		end if
		if ccur(rs(2)) <> 0 then rootid = 0
		childNum = ccur(rs(0))
	end if
	rs.close
	set rs = nothing
	If RootID < 1 then exit sub

	dim class_sql,class_idname,class_selcolumn,class_page,sql_extend
	sql_extend = " where T1.RootIDBak=" & RootID
	class_page = 0
	class_sql = "select {~~~} from LeadBBS_Announce as T1 left join LeadBBS_User as T2 on T2.Id=T1.Userid " & sql_extend
	class_idname = "T1.id"
	class_selcolumn = "T1.id,T1.Title,T1.ndatetime,T1.UserName,T1.UserID,T1.TitleStyle,T2.UserName as username_dup2,T2.ID as id_dup2,T2.TrueName,T1.BoardID"
	splitpage_orderstr = "T1.id asc"
	
	class_page = fix(toNum(Request("page"),0))
	
	splitpage_listNum = DEF_MaxListNum
	CALL splitpage_returnData(class_sql,class_idname,class_page,class_selcolumn,childNum)
	
	if Ubound(splitpage_getdata,2) >= 0 then
		GBL_board_ID = ccur(splitpage_getdata(9,0))
		Dim TArray,ForumPass,BoardLimit,OtherLimit,HiddenFlag
		TArray = Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID)
		If isArray(TArray) = False Then
			Call ReloadBoardInfo(GBL_Board_ID)
			TArray = Application(DEF_MasterCookies & "BoardInfo" & GBL_Board_ID)
		End If
		If isArray(TArray) = False Then
				Exit Sub
		Else
			ForumPass = TArray(7,0)
			BoardLimit = cCur(TArray(9,0))
			OtherLimit = cCur(TArray(36,0))
			HiddenFlag = TArray(8,0)
		End If
		If GBL_CheckLimitTitle(ForumPass,BoardLimit,OtherLimit,HiddenFlag) = 1 Then
			Response.Write "<ul><li>限制版面已禁用此功能.</li></ul>"
			Exit Sub
		End If
		DisplaySmallAnnounceData 0,Ubound(splitpage_getdata,2),1,splitpage_getdata
	end if
	
	dim extendurl,tmp
	extendurl = ""
	tmp = "&ID=" & RootID
	'PageSplitString = PageSplitString & " <a href=#no onclick='getAJAX(""b.asp"",""ol=3" & tmp & """,""Lead" & RootID & """);'>尾页</a>"
	CALL splitpage_viewpagelist("b.asp?b=" & GBL_board_ID,splitpage_maxpage,splitpage_page,"Lead" & RootID & "|" & "ol=3" & tmp & "|$(\'#Lead" & RootID & "\').parent().ScrollTo(600);")

end sub

Private Sub DisplaySmallAnnounceData(For1,For2,StepValue,GetData)

	Dim N,Temp
	Response.Write "<ul>"
	For N = For1 to For2 Step StepValue
		If RootID <> cCur(GetData(0,N)) Then
			Response.Write "<li>" & VbCrLf	
			If N = For2 Then
				Response.Write "└" & VbCrLf
			Else
				Response.Write "├" & VbCrLf
			End If
			Response.Write "<a href=" & DEF_BBS_HomeUrl & "a/" & RW_a(GBL_Board_ID,GetData(0,N),1,1,"re=1") & ">" & VbCrLf
		End If
		If Left(GetData(1,n),3) = "re:" Then GetData(1,n) = Mid(GetData(1,n),4)
		If GetData(5,n) <> 1 and Len(GetData(1,N))>DEF_BBS_DisplayTopicLength Then GetData(1,N) = Left(GetData(1,N),DEF_BBS_DisplayTopicLength-3) & "..."
		If GetData(5,n) <> 1 Then GetData(1,n) = Replace(GetData(1,n) & "","<","&lt;")
		GetData(1,n) = DisplayAnnounceTitle(GetData(1,n),GetData(5,n))
		If GetData(5,n) >=60 Then
			GetData(1,n) = "帖子等待审核中..."
			GetData(5,n) = 1
		End If
		GetData(1,n) = Replace(Replace(GetData(1,N) & "","\","\\"),"""","\""")
		Response.Write GetData(1,n) & VbCrLf
		If RootID <> cCur(GetData(0,N)) Then
			Response.Write "</a>" & VbCrLf
		End If
		If cCur(GetData(4,N)) > 0 Then
			Response.Write " [<a href=" & DEF_BBS_HomeUrl & "User/" & RW_User(GetData(4,N),"","","") & ">" & GetTrueName(GetData(3,N),GetData(8,N)) & "</a> " & VbCrLf
		Else
			Response.Write " [" & GetData(3,N) & " " & VbCrLf
		End If
		Temp = RestoreTime(GetData(2,N))
		If DateDiff("d",Temp,DEF_Now)<1 Then
			Response.Write " <font color=Red class=redfont>" & VbCrLf
			Response.Write ConvertSimTimeString(Temp) & "</font>]</li>" & VbCrLf
		Else
			Response.Write ConvertSimTimeString(Temp) & "]</li>" & VbCrLf
		End If
	Next
	Response.Write "</ul>" & VbCrLf

End Sub

End Class%>