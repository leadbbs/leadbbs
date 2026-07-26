<%
Function Upload_List(UserID,upNum,FileUrl,Col)

	Dim TmpData
	Dim Rs,SQL,NewNum,UserName,recordCount
	
	If upNum > 0 Then
		recordCount = upNum
	Else
		If isArray(application(DEF_MasterCookies & "StatisticData")) = False Then ReloadStatisticData
		TmpData = Application(DEF_MasterCookies & "StatisticData")
		recordCount = cCur(TmpData(5,0))
	End If

	GBL_CHK_TempStr=""
	Dim UpDownPageFlag
	UpDownPageFlag = Request("UpDownPageFlag")

	Dim Start

	Dim SQLendString

	Start = Left(Trim(Request("Start")),14)
	Start = start
	If isNumeric(Start)=0 or Start="" Then Start=999999999
	Start = cCur(Start)
	If Start = 0 Then Start=999999999
	if Start = 1 Then Start = 0

	Dim SQLCountString,whereFlag
	whereFlag = 0

	If UserID > 0 Then
		SQLendString = " Where T1.UserID=" & UserID
		whereFlag = 1
	End If
	SQLCountString = SQLendString
	If UpDownPageFlag = "1" and Start>=0 then
		If whereFlag = 1 Then
			SQLendString = SQLendString & " and T1.ID>" & Start
		Else
			SQLendString = SQLendString & " where T1.ID>" & Start
			whereFlag = 1
		End If
	Else
		If whereFlag = 1 Then
			SQLendString = SQLendString & " and T1.ID<" & Start
		Else
			SQLendString = SQLendString & " where T1.ID<" & Start
			whereFlag = 1
		End If
	end If

	If UpDownPageFlag = "1" then
		SQLendString = SQLendString & " Order by  T1.ID ASC"
	Else
		SQLendString = SQLendString & " Order by T1.ID DESC"
	End If
	
	Dim MaxRecordID,MinRecordID
	MaxRecordID = 0

	SQL = "select Max(id) from LeadBBS_Upload as T1 " & SQLCountString
	Set Rs = LDExeCute(SQL,0)
	
	If not Rs.Eof Then
		If Rs(0) <> "" Then
			MaxRecordID = cCur(Rs(0))
		Else
			MaxRecordID = 0
		End If
	End If
	Rs.Close
	Set Rs = Nothing
	
	SQL = "select Min(id) from LeadBBS_Upload as T1 " & SQLCountString
	Set Rs = LDExeCute(SQL,0)

	If not Rs.Eof Then
		If Rs(0) <> "" Then
			MinRecordID = cCur(Rs(0))
		else
			MinRecordID = 0
		end If
	End If
	Rs.Close
	Set Rs = Nothing

	Dim FirstID,LastID	

	SQL = sql_select("select T1.ID,T1.UserID,T1.PhotoDir,T1.SPhotoDir,T1.NdateTime,T1.FileType,T2.UserName,T1.Hits,T1.Info,T1.AnnounceID,T1.BoardID,T3.RootIDBak,T3.title,T2.TrueName from (LeadBBS_Upload As T1 left join LeadBBS_User as T2 on T1.UserID=T2.ID) left join LeadBBS_Announce as T3 on T1.AnnounceID=T3.ID " & SQLendString,DEF_TopicContentMaxListNum)
	Set Rs = LDExeCute(SQL,0)
	Dim Num
	Dim GetData
	If Not rs.Eof Then
		GetData = Rs.GetRows(-1)
		Num = Ubound(GetData,2)
	Else
		Num = -1
	End If
	Rs.close
	Set Rs = Nothing
	
	
	Dim i,N
	If Num>=0 Then
		i=1
	
		Dim MinN,MaxN,StepValue
		SQL = ubound(getdata,2)
		If UpDownPageFlag = "1" then
			MinN = SQL
			MaxN = 0
			StepValue = -1
		Else
			MinN = 0
			MaxN = SQL
			StepValue = 1
		End If

		LastID = cCur(GetData(0,MaxN))
		FirstID = cCur(GetData(0,MinN))
	
		Dim EndwriteQueryString,PageSplictString
		EndwriteQueryString = FileUrl
	
		PageSplictString = PageSplictString & "<div class=j_page>"
		If FirstID >= MaxRecordID Then
			'PageSplictString = PageSplictString & "首页" & VbCrLf
			'PageSplictString = PageSplictString & " 上页" & VbCrLf
		else
			PageSplictString = PageSplictString & "<a href=""" & EndwriteQueryString & "?Start=0"">首页</a>" & VbCrLf
			PageSplictString = PageSplictString & "<a href=""" & EndwriteQueryString & "?Start=" & LngStr(FirstID) & "&UpDownPageFlag=1"">上页</a>" & VbCrLf
		end if
	
		If LastID <= MinRecordID Then
			'PageSplictString = PageSplictString & " 下页" & VbCrLf
			'PageSplictString = PageSplictString & " 尾页" & VbCrLf
		else
			PageSplictString = PageSplictString & " <a href=""" & EndwriteQueryString & "?Start=" & LngStr(LastID) & """>下页</a> " & VbCrLf
			PageSplictString = PageSplictString & " <a href=""" & EndwriteQueryString & "?Start=1&UpDownPageFlag=1"">尾页</a> " & VbCrLf
		end if
		
		PageSplictString = PageSplictString & "<b>共" & recordCount & "</b>"
		'If (recordCount mod DEF_TopicContentMaxListNum)=0 Then
		'	PageSplictString = PageSplictString & " 计<b>" & clng(recordCount/DEF_TopicContentMaxListNum) & "</b>页"
		'Else
		'	If recordCount>=DEF_TopicContentMaxListNum Then
		'		PageSplictString = PageSplictString & " 计<b>" & clng(recordCount/DEF_TopicContentMaxListNum)+1 & "</b>页"
		'	Else
		'		PageSplictString = PageSplictString & " 计<b>1</b>页"
		'	End If
		'End If
		'PageSplictString = PageSplictString & " 每页<b>" & DEF_TopicContentMaxListNum & "</b>条记录"
		PageSplictString = PageSplictString & "</div>"
	
	End If
	%>
	
	<script src="<%=DEF_BBS_HomeUrl%>inc/js/p_list.js?ver=20090601.2" type="text/javascript"></script>
	<script type="text/javascript">
		p_url = "<%=DEF_BBS_HomeUrl%>User/DeleteMessage.asp";
		p_para = "AjaxFlag=1&FriendFlag=3&DeleteSureFlag=dk9@dl9s92lw_SWxl&MessageID=";
		p_command = 'alert(tmp);this.location="<%=FileUrl%>";';
		p_type = 1;
		//function kill(str)
		//{
		//	window.open('../User/DeleteUpload.asp?FileID='+str,'','width=450,height=37,scrollbars=auto,status=no');
		//}
	</script>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class=table_in>
	  <tr class=tbinhead>
	  <%
	Dim TempN,Temp
	
	If DEF_EnableGFL = 1 Then
		Temp = DEF_UploadSwidth + 30
		'Temp = Fix(50/Col) & "%"
	Else
		Temp = Fix(50/Col) & "%"
	End If
	For N = 1 to Col%>
	    <td width=<%=Temp%>><div class=value>缩略图/下载</div></td>
	    <td align=left width=<%=Fix(100/Col)%>%><div class=value>信息</div></td>
	    <%Next%>
	  </tr>
	<%
	If Num = -1 Then
		response.write "<tr><td colspan=2 class=tdbox>没有任何上传附件!</td></tr>"
	end if
	
	Dim DeleteEnable
	If GetBinarybit(GBL_CHK_UserLimit,11) = 1 and (GetBinarybit(GBL_CHK_UserLimit,10) = 1 or GetBinarybit(GBL_CHK_UserLimit,8) = 1) Then
		DeleteEnable = 1
	Else
		DeleteEnable = 0
	End If

	Dim WidthHeight,TrFlag,TBStr,fUrl
	TBStr = "<table cellspacing=2 class=uploadimg width=" & DEF_UploadSwidth + 10 & " height=" & DEF_UploadSheight + 10 & "><tr><td align=center valign=center>"
	If DEF_EnableGFL = 1 Then
		WidthHeight = ""
	Else
		WidthHeight = " width=140 height=140"
	End If
	TrFlag = 0
	Dim Index
	Index = 0
	if Num <> -1 then
		LastID = GetData(0,ubound(getdata,2))
		for n= MinN to MaxN Step StepValue
			TrFlag = TrFlag + 1
			If TrFlag > Col Then TrFlag = 1
			If TrFlag = 1 Then Response.Write "<tr>"

			Response.Write "<td class=tdbox>"
			fUrl = "../a/file.asp?lid=" & GetData(0,n) & "&s=" & UrlEncode(DEF_DownKey)
			If GetData(3,n) <> "" and GetData(5,N) = 0 Then
				Response.Write TBStr
				Response.Write "<a href=""" & fUrl & """ target=_blank>"
				Response.Write "<img src=""" & fUrl & "&small=1""" & WidthHeight & " style='border-color:white' border=2></a></td></tr></table>"
			ElseIf GetData(2,n) <> "" and GetData(5,N) = 0 Then
				Response.Write TBStr
				Response.Write "<a href=""" & fUrl & """ target=_blank>"
				Response.Write "<img src=""" & fUrl & """" & WidthHeight & " style='border-color:white' border=2></a></td></tr></table>"
			ElseIf GetData(2,n) <> "" and GetData(5,N) = 1 Then
				Response.Write "<a href=""" & fUrl & """ target=_blank>全屏播放</a>"
			Else
				Response.Write "<a href=""" & fUrl & "&down=1"">下载</a>"
			End If
			Response.Write "</td><td align=left class=tdbox>"
			
			If isNull(GetData(6,N)) Then
				Response.Write "作者：无"
			Else
				Response.Write "作者：<a href=""../user/" & RW_User(GetData(1,n),"","","") & """>" & htmlencode(GetTrueName(GetData(6,n),GetData(13,n))) & "</a>"
			End If
			Response.Write "<br>时间：" & Left(RestoreTime(GetData(4,n)),16)
			If GetData(2,n) <> "" Then
				Temp = inStrRev(GetData(2,n),".")
				Temp = Mid(GetData(2,n),Temp+1)
			Else
				Temp = "file"
			End If
			Response.Write "<br>类型：<img src=../images/fileType/" & Temp & ".gif align=absmiddle width=16>"
			If GetData(5,N) = 0 Then
				Response.Write "图片文件"
			ElseIf GetData(5,N) = 1 Then
				Response.Write "Flash动画"
			Else
				Response.Write "其它文件"
			End If
			
			If GBL_CHK_User = GetData(6,n) or CheckSupervisorUserName() = 1 or DeleteEnable = 1 Then
				%>
				<input class="fmchkbox" type="checkbox" name="ids" id="ids<%=Index%>" value="<%=LngStr(GetData(0,N))%>" /><%
				Response.Write "<a href='javascript:p_once(" & GetData(0,N) & ");'>删除</a>"
				Index = Index + 1
			End If
			
			If GetData(5,N) <> 0 Then Response.Write "<br>下载：" & GetData(7,n) & " 次"
			If GetData(8,N) <> "" Then Response.Write "<br>注释：" & HtmlEncode(GetData(8,n))
			
			GetData(12,N) = GetData(12,N) & ""
			If "0" & GetData(9,N) = "0" & GetData(11,N) Then
				Temp = ""
			Else
				Temp = "&RID=" & GetData(9,N) & "#F" & GetData(9,N)
				If Left(GetData(12,N),3) = "re:" Then GetData(12,N) = Mid(GetData(12,N),4)
			End if
			If Len(GetData(12,N) & "") > 25 Then
				GetData(12,N) = Left(GetData(12,N),25) & "..."
			End If
			If cCur("0" & GetData(11,N)) <> 0 Then Response.Write "<br>帖子：<a href=""" & DEF_BBS_HomeUrl & "a/" & RW_a(GetData(10,N),GetData(11,N),1,1,Temp) & """>" & htmlencode(GetData(12,N)) & "</a>"

			Response.Write "</td>"
	
			If TrFlag = Col Then Response.Write "</tr>" & VbCrLf
		Next
		If TrFlag < Col Then
			For N = TrFlag + 1 to Col
				Response.Write "<td>&nbsp;</td><td>&nbsp;</td>" & VbCrLf
			Next
		End If
	End If
	If PageSplictString<>"" Then Response.Write "<tr><td colspan=" & Col * 2 & " class=tdbox>" & PageSplictString & "</td></tr>"
	%>
		<tr><td colspan=<%=Col * 2%> class=tdbox align=right>
		<input class="fmchkbox" type="checkbox" name="selmsg" id="selmsg" value="1" onclick="achoose();" />选择所有记录
		<input type=button value="批量删除" onclick="pchoose();" class="fmbtn btn_4">
		</td></tr>
	      </table><%

End Function
%>