<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Const MaxLinkNum = 200
initDatabase()
GBL_CHK_TempStr = ""
checkSupervisorPass()

Dim ReqN,WriteN,SiteLink_Flag,SiteLink_Title,SiteLink_Name,SiteLink_WriteFile,SiteLink_Info
SiteLink_Flag = 0
If Request.QueryString("SiteLink_Flag") = "10" Then SiteLink_Flag = 10

Select Case SiteLink_Flag
Case 10:
	SiteLink_Title = "广告"  '栏目标题
	SiteLink_Name = "广告"   '项目名字
	SiteLink_WriteFile = "inc/AD_Data.asp"  '写入文件地址(相对于论坛根目标)
	SiteLink_Info = "帖间广告：在主题帖和1楼帖中随机显示您所添加的广告"
Case Else:
	SiteLink_Flag = 0
	SiteLink_Title = "友情链接"
	SiteLink_Name = "网站"
	SiteLink_WriteFile = "inc/IncHtm/BoardLink.asp"
End Select

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("修改" & SiteLink_Title)
If GBL_CHK_Flag=1 Then
	SiteLink()
Else
DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

Sub SiteLink

ReqN = 0
WriteN = 0
%>
<form name="pollform3sdx" method="post" action="SiteLink.asp<%If SiteLink_Flag > 0 Then Response.Write "?SiteLink_Flag=" & SiteLink_Flag%>" onsubmit="return checksubmit();">
<input type="hidden" name="SubmitFlag" value=yes>
<div class="frameline">
	<b>
		修改<%=SiteLink_Title%></b><font color=8888888 class=grayfont>(下面是相应信息，不填写(或除去)名称表示删除，要增加请点下面的增加按钮)</font>
</div>
<%If Request("SubmitFlag") <> "" Then
	'CheckLinkValue
End If
If GBL_CHK_TempStr <> "" Then%>
<div class="alert"><%=GBL_CHK_TempStr%></div>
<%End If%>

<div name=SiteString id=SiteString>
<%
If Request.Form("SubmitFlag") <> "" Then
	If GBL_CHK_TempStr <> "" Then
		If Request.Form("SiteName1") = "" Then
			WriteN = 1%>
			<div class="frameline"><%=SiteLink_Name%>1</div>
			<div class="frameline"><%=SiteLink_Name%>名称：<input type="text" name="SiteName1" maxlength="255" size="50" class=fminpt>(允许HTML)</div>
			<div class="frameline">链接地址：<input type="text" name="SiteUrl1" maxlength="255" size="50" class=fminpt></div>
			<div class="frameline">LOGO地址：<input type="text" name="LogoUrl1" maxlength="255" size="50" class=fminpt></div>
			<div class="frameline">LOGO宽度：<input type="text" name="LogoWidth1" maxlength="5" size="5" value=88 class=fminpt></div>
			<div class="frameline">LOGO高度：<input type="text" name="LogoHeight1" maxlength="5" size="5" value=31 class=fminpt></div>
			<%If SiteLink_Flag = 0 Then%>
			<div class="frameline">是否换行：<input type="text" name="BreakFlag1" maxlength="5" size="5" class=fminpt>另起一行排版，1-换行，0-自动</div>
			<%End If%>
			<div class="frameline">排列顺序：<input type="text" name="OrderID1" maxlength="5" size="5" class=fminpt>越小越前面</div>
		<%Else
			For ReqN = 1 to MaxLinkNum
				If Request.Form("SiteName" & ReqN) <> "" Then
					WriteN = WriteN + 1
			%>
			<div class="frameline"><%=SiteLink_Name%><%=ReqN%></div>
			<input type="hidden" name="SiteID<%=ReqN%>" maxlength="100" size="50" Value="<%=htmlencode(Request.Form("SiteID" & ReqN))%>">
			<div class="frameline"><%=SiteLink_Name%>名称：<input type="text" name="SiteName<%=ReqN%>" maxlength="255" size="50" Value="<%=htmlencode(Request.Form("SiteName" & ReqN))%>" class=fminpt>(允许HTML)</div>
			<div class="frameline">链接地址：<input type="text" name="SiteUrl<%=ReqN%>" maxlength="255" size="50" Value="<%=htmlencode(Request.Form("SiteUrl" & ReqN))%>" class=fminpt></div>
			<div class="frameline">LOGO地址：<input type="text" name="LogoUrl<%=ReqN%>" maxlength="255" size="50" Value="<%=htmlencode(Request.Form("LogoUrl" & ReqN))%>" class=fminpt></div>
			<div class="frameline">LOGO宽度：<input type="text" name="LogoWidth<%=ReqN%>" maxlength="5" size="5" Value="<%=htmlencode(Request.Form("LogoWidth" & ReqN))%>" class=fminpt></div>
			<div class="frameline">LOGO高度：<input type="text" name="LogoHeight<%=ReqN%>" maxlength="5" size="5" Value="<%=htmlencode(Request.Form("LogoHeight" & ReqN))%>" class=fminpt></div>
					<%If SiteLink_Flag = 0 Then%>
			<div class="frameline">是否换行：<input type="text" name="BreakFlag<%=ReqN%>" maxlength="5" size="5" Value="<%=htmlencode(Request.Form("BreakFlag" & ReqN))%>" class=fminpt>另起一行排版，1-换行，0-自动</div>
					<%End If%>
			<div class="frameline">排列顺序：<input type="text" name="OrderID<%=ReqN%>" maxlength="5" size="5" Value="<%=htmlencode(Request.Form("SiteUrl" & ReqN))%>" class=fminpt>越小越前面</div>
			<%
				End If
			Next
		End if
	Else
		If SaveSiteLink() = 1 Then
			Response.Write "成功更新数据库！"
			MakeDataBaseLinkFile()
			Exit Sub
		Else
			DisplayDatabaseLink()
		End If
	End If
Else
	DisplayDatabaseLink()
End If
%>

</div>
<div class="frameline">
<input type=submit name=提交 value=提交 class=fmbtn>
<input type=button name=add value=增加<%=SiteLink_Title%> onclick="additem();" class=fmbtn>
</div>
</form>
<div class="frameline">注意，如果你的服务器不支持文件写入，将不能自动产生需要的文件信息，<br>请手动更改 <%=SiteLink_WriteFile%> 的文件内容</div>
<script language=javascript>
var maxNumber=<%=MaxLinkNum%>;
var Number=<%=WriteN%>;
function checksubmit()
{
	return true
}

function additem()
{
	Number+=1;
	if(Number>maxNumber)
	{
		alert("已经达到最大<%=SiteLink_Title%>项目，不能再增加!");
	}
	else
	{
		this.SiteString.innerHTML+="<div class=frameline><%=SiteLink_Name%>"+Number+"</div>";
		this.SiteString.innerHTML+="<div class=frameline><%=SiteLink_Name%>名称：<input type=text name=SiteName"+Number+" maxlength=255 size=50 class=fminpt></div>";
		this.SiteString.innerHTML+="<div class=frameline>链接地址：<input type=text name=SiteUrl"+Number+" maxlength=255 size=50 class=fminpt></div>";
		this.SiteString.innerHTML+="<div class=frameline>图片地址：<input type=text name=LogoUrl"+Number+" maxlength=255 size=50 class=fminpt></div>";
		this.SiteString.innerHTML+="<div class=frameline>图片宽度：<input type=text name=LogoWidth"+Number+" maxlength=5 size=5 value=88 class=fminpt></div>";
		this.SiteString.innerHTML+="<div class=frameline>图片高度：<input type=text name=LogoHeight"+Number+" maxlength=5 size=5 value=31 class=fminpt></div>";
		<%If SiteLink_Flag = 0 Then%>
		this.SiteString.innerHTML+="<div class=frameline>是否换行：<input type=text name=BreakFlag"+Number+" maxlength=5 size=5 value=0 class=fminpt></div>";
		<%End If%>
		this.SiteString.innerHTML+="<div class=frameline>排列顺序：<input type=text name=OrderID"+Number+" maxlength=5 size=5 class=fminpt></div>";
		this.scroll(0, 65000);
	}
}
</script>
<%

End Sub

Sub DisplayDatabaseLink

	Dim Rs,SQL,GetData
	Set Rs = Server.CreateObject("ADODB.RecordSet")
	SQL = "select ID,SiteName,SiteUrl,LogoUrl,OrderID,LogoWidth,LogoHeight,BreakFlag from LeadBBS_Link where LinkType=" & SiteLink_Flag & " order by OrderID,ID ASC"
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		WriteN = 1
		%>
		<div class="frameline"><%=SiteLink_Name%>1</div>
		<div class=frameline><%=SiteLink_Name%>名称：<input type="text" name="SiteName1" maxlength="255" size="50" class=fminpt>(允许HTML)</div>
		<div class=frameline>链接地址：<input type="text" name="SiteUrl1" maxlength="255" size="50" class=fminpt></div>
		<div class=frameline>图片地址：<input type="text" name="LogoUrl1" maxlength="255" size="50" class=fminpt></div>
		<div class=frameline>图片宽度：<input type="text" name="LogoWidth1" maxlength="5" size="5" value=88 class=fminpt></div>
		<div class=frameline>图片高度：<input type="text" name="LogoHeight1" maxlength="5" size="5" value=31 class=fminpt></div>
		<%If SiteLink_Flag = 0 Then%>
		<div class=frameline>是否换行：<input type="text" name="BreakFlag1" maxlength="5" size="5" class=fminpt>另起一行排版，1-换行，0-自动</div>
		<%End If%>
		<div class=frameline>排列顺序：<input type="text" name="OrderID1" maxlength="5" size="5" class=fminpt>越小越前面</div>
		<%
		Exit Sub
	Else
		GetData = Rs.GetRows(-1)
		Rs.Close
		Set Rs = Nothing
	End If

	WriteN = Ubound(GetData,2)+1
	For SQL = 0 To Ubound(GetData,2)
		ReqN = SQL + 1
		If GetData(7,SQL) Then
			GetData(7,SQL) = 1
		Else
			GetData(7,SQL) = 0
		End If
		%>
		<div class="frameline"><%=SiteLink_Name%><%=ReqN%></div>
		<input type="hidden" name="SiteID<%=ReqN%>" Value="<%=GetData(0,SQL)%>">
		<div class=frameline><%=SiteLink_Name%>名称：<input type="text" name="SiteName<%=ReqN%>" maxlength="255" size="50" Value="<%=htmlencode(GetData(1,SQL))%>" class=fminpt>(允许HTML)</div>
		<div class=frameline>链接地址：<input type="text" name="SiteUrl<%=ReqN%>" maxlength="255" size="50" Value="<%=htmlencode(GetData(2,SQL))%>" class=fminpt></div>
		<div class=frameline>图片地址：<input type="text" name="LogoUrl<%=ReqN%>" maxlength="255" size="50" Value="<%=htmlencode(GetData(3,SQL))%>" class=fminpt></div>
		<div class=frameline>图片宽度：<input type="text" name="LogoWidth<%=ReqN%>" maxlength="5" size="5" Value="<%=htmlencode(GetData(5,SQL))%>" class=fminpt></div>
		<div class=frameline>图片高度：<input type="text" name="LogoHeight<%=ReqN%>" maxlength="5" size="5" Value="<%=htmlencode(GetData(6,SQL))%>" class=fminpt></div>
		<%If SiteLink_Flag = 0 Then%>
		<div class=frameline>是否换行：<input type="text" name="BreakFlag<%=ReqN%>" maxlength="5" size="5" Value="<%=htmlencode(GetData(7,SQL))%>" class=fminpt>另起一行排版，1-换行，0-自动</div>
		<%End If%>
		<div class=frameline>排列顺序：<input type="text" name="OrderID<%=ReqN%>" maxlength="5" size="5" Value="<%=htmlencode(GetData(4,SQL))%>" class=fminpt>越小越前面</div>
		<%
	Next

End Sub

Function CheckLinkValue

	Dim N
	Dim SiteName,SiteUrl,LogoUrl,LogoWidth,LogoHeight,BreakFlag,OrderID
	For N = 0 to MaxLinkNum
		SiteName = Trim(Request.Form("SiteName" & N+1))
		SiteUrl = Trim(Request.Form("SiteUrl" & N+1))
		LogoUrl = Trim(Request.Form("LogoUrl" & N+1))
		LogoWidth = Left(Trim(Request.Form("LogoWidth" & N+1)),14)
		LogoHeight = Left(Trim(Request.Form("LogoHeight" & N+1)),14)
		BreakFlag = Trim(Request.Form("BreakFlag" & N+1))
		OrderID = Trim(Request.Form("OrderID" & N+1))
		If SiteName <> "" Then
			'If SiteUrl = "" Then
			'	GBL_CHK_TempStr = "错误，" & SiteLink_Name & N + 1 & "的链接未填写．<br>" & VbCrLf
			'	Exit function
			'End If
			
			If LogoUrl <> "" Then
				If isNumeric(LogoWidth) = 0 Then LogoWidth = 0
				LogoWidth = fix(cCur(LogoWidth))
				If isNumeric(LogoHeight) = 0 Then LogoHeight = 0
				LogoHeight = fix(cCur(LogoHeight))
				If LogoWidth < 1 Then LogoWidth = 1
				If LogoWidth > 1000 Then LogoWidth = 1000
				If LogoHeight < 1 Then LogoHeight = 1
				If LogoHeight > 1000 Then LogoHeight = 1000
			Else
				LogoWidth = 88
				LogoHeight = 31
			End If
			
			If BreakFlag <> "1" and BreakFlag <> "0" Then BreakFlag = 0
			
			If isNumeric(OrderID) = 0 Then OrderID = 0
			OrderID = fix(cCur(OrderID))
			If OrderID < 0 Then OrderID = 0
		End If
	Next

End Function

Function SaveSiteLink

	Dim N
	Dim SiteID,SiteName,SiteUrl,LogoUrl,LogoWidth,LogoHeight,BreakFlag,OrderID
	For N = 0 to MaxLinkNum
		SiteID = Trim(Left(Request.Form("SiteID" & N+1),14))
		SiteName = Trim(Request.Form("SiteName" & N+1))
		SiteUrl = Trim(Request.Form("SiteUrl" & N+1))
		LogoUrl = Trim(Request.Form("LogoUrl" & N+1))
		LogoWidth = Left(Trim(Request.Form("LogoWidth" & N+1)),14)
		LogoHeight = Left(Trim(Request.Form("LogoHeight" & N+1)),14)
		BreakFlag = Trim(Request.Form("BreakFlag" & N+1))

		If inStr(LCase(SiteName),"<%") or inStr(LCase(SiteName),"include") or (inStr(LCase(SiteName),"server") and inStr(LCase(SiteName),"script")) Then
			Response.Write "<p><br><font color=red class=redfont>第" & N + 1 & SiteLink_Name & "名称中含有<%，include，Server等字符，请仔细检查！</font></p>" & VbCrLf
			SaveSiteLink = 0
			Exit Function
		End If
		If inStr(LCase(SiteUrl),"<%") or inStr(LCase(SiteName),"SiteUrl") or (inStr(LCase(SiteUrl),"server") and inStr(LCase(SiteUrl),"script")) Then
			Response.Write "<p><br><font color=red class=redfont>第" & N + 1 & SiteLink_Name & "链接中含有<%，include，Server等字符，请仔细检查！</font></p>" & VbCrLf
			SaveSiteLink = 0
			Exit Function
		End If
		If inStr(LCase(LogoUrl),"<%") or inStr(LCase(LogoUrl),"SiteUrl") or (inStr(LCase(LogoUrl),"server") and inStr(LCase(LogoUrl),"script")) Then
			Response.Write "<p><br><font color=red class=redfont>第" & N + 1 & "Logo地址中含有<%，include，Server等字符，请仔细检查！</font></p>" & VbCrLf
			SaveSiteLink = 0
			Exit Function
		End If

		OrderID = Left(Trim(Request.Form("OrderID" & N+1)),14)
			'If SiteUrl = "" Then
			'	GBL_CHK_TempStr = "错误，" & SiteLink_Name & N + 1 & "的链接未填写．<br>" & VbCrLf
			'	Exit Function
			'	SaveSiteLink = 0
			'End If
			
			If LogoUrl <> "" Then
				If isNumeric(LogoWidth) = 0 Then LogoWidth = 0
				LogoWidth = fix(cCur(LogoWidth))
				If isNumeric(LogoHeight) = 0 Then LogoHeight = 0
				LogoHeight = fix(cCur(LogoHeight))
				If LogoWidth < 1 Then LogoWidth = 1
				If LogoWidth > 1000 Then LogoWidth = 1000
				If LogoHeight < 1 Then LogoHeight = 1
				If LogoHeight > 1000 Then LogoHeight = 1000
			Else
				LogoWidth = 88
				LogoHeight = 31
			End If
			
			If BreakFlag <> "1" and BreakFlag <> "0" Then BreakFlag = 0
			
			If isNumeric(OrderID) = 0 Then OrderID = 0
			OrderID = fix(cCur(OrderID))
			If OrderID < 0 Then OrderID = 0
			
			If isNumeric(SiteID) = 0 Then SiteID = 0
			SiteID = fix(cCur(SiteID))
			If SiteID < 0 Then SiteID = 0
			If SiteID = 0 and SiteName <> "" Then
				CALL LDExeCute("insert into LeadBBS_Link(SiteName,SiteUrl,LogoUrl,LogoWidth,LogoHeight,BreakFlag,OrderID,LinkType)" & _
					" Values('" & Replace(SiteName,"'","''") & "','" & Replace(SiteUrl,"'","''") & "','" & Replace(LogoUrl,"'","''") & "'," & LogoWidth & "," & LogoHeight & "," & BreakFlag & "," & OrderID & "," & SiteLink_Flag & ")",1)
			ElseIf SiteName = "" and SiteID > 0 Then
				CALL LDExeCute("Delete from LeadBBS_Link where ID=" & SiteID,1)
			ElseIf SiteID > 0 Then
				CALL LDExeCute("Update LeadBBS_Link Set SiteName='" & Replace(SiteName,"'","''") & "',SiteUrl='" & Replace(SiteUrl,"'","''") & "',LogoUrl='" & Replace(LogoUrl,"'","''") & "',LogoWidth=" & LogoWidth & ",LogoHeight=" & LogoHeight & ",BreakFlag=" & BreakFlag & ",OrderID=" & OrderID & " Where ID=" & SiteID,1)
			End If
	Next
	SaveSiteLink = 1

End Function

Sub MakeDataBaseLinkFile

	Dim TempStr
	TempStr = ""
	Dim Rs,SQL,GetData
	Dim SiteName,SiteUrl,LogoUrl,OrderID,LogoWidth,LogoHeight,BreakFlag
	SQL = "select ID,SiteName,SiteUrl,LogoUrl,OrderID,LogoWidth,LogoHeight,BreakFlag from LeadBBS_Link where LinkType=" & SiteLink_Flag & " order by OrderID"
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		TempStr = TempStr & " "
		Rs.Close
		Set Rs = Nothing
		Select Case SiteLink_Flag
		Case 10:
			TempStr = TempStr & "<" & "%" & VbCrLf
			TempStr = TempStr & "Dim DEF_AD_DataNum" & VbCrLf
			TempStr = TempStr & "DEF_AD_DataNum = 0" & VbCrLf & VbCrLf
			TempStr = TempStr & "%" & ">" & VbCrLf
		Case Else	
			TempStr = TempStr & "<" & "%" & VbCrLf
			TempStr = TempStr & "Dim Boards_HaveLink" & VbCrLf
			TempStr = TempStr & "Boards_HaveLink = 0" & VbCrLf & VbCrLf
			TempStr = TempStr & "%" & ">" & VbCrLf
		End Select
	Else
		GetData = Rs.GetRows(-1)
		Rs.Close
		Set Rs = Nothing
		Select Case SiteLink_Flag
		Case 10:
			TempStr = TempStr & chr(60) & "%" & VbCrLf
			TempStr = TempStr & "Dim DEF_AD_DataArray(" & Ubound(GetData,2) + 1 & "),DEF_AD_DataNum" & VbCrLf
			TempStr = TempStr & "DEF_AD_DataNum = " & Ubound(GetData,2) + 1 & VbCrLf
			Dim Tmp
			For SQL = 0 To Ubound(GetData,2)
				Tmp = ""
				If GetData(2,SQL) <> "" Then Tmp = Tmp & "<a href=""" & htmlencode(GetData(2,SQL)) & """ target=_blank>"
				If GetData(3,SQL) <> "" Then
					Tmp = Tmp & "<img src=""" & htmlencode(GetData(3,SQL)) & """ width=" & GetData(5,SQL) & " height=" & GetData(6,SQL) & " border=0 title=""" & htmlencode(GetData(1,SQL)) & """ align=middle>"
				Else
					Tmp = Tmp & GetData(1,SQL)
				End If
				If GetData(2,SQL) <> "" Then Tmp = Tmp & "</a>"
				Tmp = Replace(Tmp,Chr(34),Chr(34) & Chr(34))
				TempStr = TempStr & "DEF_AD_DataArray(" & SQL & ") = """ & Tmp & """" & VbCrLf
			Next
			TempStr = TempStr & "%" & chr(62) & VbCrLf
		Case Else:
			TempStr = TempStr & "<" & "%" & VbCrLf
			TempStr = TempStr & "Dim Boards_HaveLink" & VbCrLf
			TempStr = TempStr & "Boards_HaveLink = 1" & VbCrLf & VbCrLf
			TempStr = TempStr & "Sub Boards_WebLink" & VbCrLf
			TempStr = TempStr & "%" & ">" & VbCrLf

			TempStr = TempStr & "<div class=""b_web_link_sites fire""><ul>"
			For SQL = 0 To Ubound(GetData,2)
				If ccur(GetData(7,SQL)) = 1 or GetData(7,SQL) Then
					GetData(7,SQL) = 1
				Else
					GetData(7,SQL) = 0
				End If
				TempStr = TempStr & " " & VbCrLf
				If GetData(2,SQL) <> "" Then TempStr = TempStr & "<li><a href=""" & htmlencode(GetData(2,SQL)) & """ target=""_blank"">" & VbCrLf
				If GetData(3,SQL) <> "" Then
					TempStr = TempStr & "<img src=""" & htmlencode(GetData(3,SQL)) & """ width=""" & GetData(5,SQL) & """ height=""" & GetData(6,SQL) & """ title=""" & htmlencode(GetData(1,SQL)) & """ align=""middle"" />"
				Else
					TempStr = TempStr & GetData(1,SQL)
				End If
				If GetData(2,SQL) <> "" Then TempStr = TempStr & "</a></li>" & VbCrLf
				If GetData(7,SQL) = 1 Then
					TempStr = TempStr & "</ul></div><div class=""b_web_link_sites fire""><ul>" & VbCrLf
				End If
			Next
			TempStr = TempStr & "</ul></div>" & VbCrLf
			TempStr = TempStr & "<" & "%" & VbCrLf
			TempStr = TempStr & "End Sub" & VbCrLf
			TempStr = TempStr & "%" & ">" & VbCrLf
		End Select
	End If

	ADODB_SaveToFile TempStr,"../../" & SiteLink_WriteFile
	If SiteLink_WriteFile = "inc/AD_Data.asp" Then
		CALL Update_InsertSetupRID(1051,"inc/AD_Data.ASP",4,TempStr," and ClassNum=" & 4)
	End If
	
	If GBL_CHK_TempStr = "" Then
		Response.Write "<br><font color=Green class=greenfont>2.成功完成设置！</font>"
	Else
		%><%=GBL_CHK_TempStr%><br>服务器不支持在线写入文件功能，请使用FTP等功能，将<font color=Red Class=redfont><%=SiteLink_WriteFile%></font>文件替换成框中内容(注意备份)<p>
		<textarea name="fileContent" cols="80" rows="30" class=fmtxtra><%=Server.htmlencode(TempStr)%></textarea><%
		GBL_CHK_TempStr = ""
	End If

End Sub
%>