<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<!--#include file="inc/skin_fun.asp"-->

<%
DEF_BBS_HomeUrl = "../../"
Const MaxLinkNum = 100

Dim StyleID,ScreenWidth,DisplayTopicLength,SiteHeadString,SiteBottomString,DefineImage,TableHeadString,TableBottomString,ShowBottomSure
Dim SmallTableHead,SmallTableBottom,TempletID

Sub Main

	initDatabase()
	GBL_CHK_TempStr = ""
	checkSupervisorPass()
	
	Manage_sitehead DEF_SiteNameString & " - 管理员",""
	frame_TopInfo()
	DisplayUserNavigate("编辑风格参数")
	If GBL_CHK_Flag=1 Then
		Dim ExtentSkinManager,Action
		Action = Request.QueryString("Action")
		If Action = "" Then				
			If dontRequestFormFlag = "" Then
				Action = Request.Form("Action")
			Else
				Action = Form_UpClass.form("Action")
			End If
		End if
		
		If Action <> "" Then
			Set ExtentSkinManager = New ExtentSkin_Manager
			ExtentSkinManager.ExtentSkin
			Set ExtentSkinManager = Nothing
		Else
			GetDefaultValue()
			If GBL_CHK_TempStr <> "" Then
				Response.Write "<br><br>" & GBL_CHK_TempStr
			Else
				Siteskin()
			End If
		End If
	Else
		DisplayLoginForm()
	End If
	frame_BottomInfo()
	closeDataBase()
	Manage_Sitebottom("none")

End Sub

Main()

Function Siteskin

	%>
	<form name="pollform3sdx" method="post" action="DefineStyleParameter.asp">
	<input type="hidden" name="SubmitFlag" value=yes>
	<p>
		<b>
			论坛风格更多参数自定义 - <%=DEF_BoardStyleString(StyleID)%></b>
			<br><br><span class=grayfont>
			大输入框请使用html语法，具体风格请在本地调试好后再具体设定<br></span>
	</p>
	<%If Request.Form("SubmitFlag") <> "" Then
		GetFormValue()
	End If
	If GBL_CHK_TempStr <> "" Then%>
	<div class=alert><%=GBL_CHK_TempStr%></div>
	<%
	End If
	If Request("SubmitFlag") <> "" Then
		If GBL_CHK_TempStr <> "" Then
			DisplayDatabaseLink()
		Else
			SaveStyleDefine()
			Response.Write "<div class=alertdone>成功完成设置！</div>"
			Exit Function
		End If
	Else
		DisplayDatabaseLink()
	End If
	%>
	<br>
	<input type=submit name=提交 value=提交 class=fmbtn>
	<input type=reset name=取消 value=取消 class=fmbtn>
	</form>
	<%

End Function

Function DisplayDatabaseLink

	%>
		<table border=0 cellpadding=0 cellspacing=0 width=100% class=frame_table>
		<tr>
			<td class=tdbox width=120>风格编号</td>
			<td class=tdbox><b><%=StyleID%></b> (<%=DEF_BoardStyleString(StyleID)%>)<input name=StyleID value=<%=StyleID%> type=hidden></td>
		</tr>
		<!--
		<tr>
			<td class=tdbox>论坛宽度</td>
			<td class=tdbox><input class=fminpt type="text" name="ScreenWidth" maxlength="50" size="30" value="<%=htmlencode(ScreenWidth)%>"><font color=gray>(支持使用百分比和绝对宽度)</font></td>
		</tr>
		-->
		<tr>
			<td class=tdbox>主题长度</td>
			<td class=tdbox><input class=fminpt type="text" name="DisplayTopicLength" maxlength="3" size="10" value="<%=htmlencode(DisplayTopicLength)%>"><font color=gray>(单位：字节，帖子主题显示最大长度，750宽=54，770宽=56,最长为255字节)</font></td>
		</tr>
		<!--
		<tr>
			<td class=tdbox>自定图片</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=DefineImage value=0<%If DefineImage = 0 Then%> checked<%End If%>></td><td>无</td>
          		<td><input class=fmchkbox type=radio name=DefineImage value=1<%If DefineImage = 1 Then%> checked<%End If%>></td><td>有</td><td><font color=gray>&nbsp; (是否自带新风格图片，存放于images/skin/<%=StyleID%>/，不指定则使用默认图片)</font></td></tr></table></td>
		</tr>
		-->
		<tr>
			 <td class=tdbox>网站首部<br>内容自定<br>使用HTML</td>
			<td class=tdbox><textarea name=SiteHeadString rows=5 cols=60 class=fmtxtra><%If SiteHeadString <> "" Then Response.Write VbCrLf & Server.htmlEncode(SiteHeadString)%></textarea></td>
		</tr>
		<tr>
			<td class=tdbox>网站尾部<br>内容自定<br>使用HTML</td>
			<td class=tdbox><textarea name=SiteBottomString rows=5 cols=60 class=fmtxtra><%If SiteBottomString <> "" Then Response.Write VbCrLf & Server.htmlEncode(SiteBottomString)%></textarea></td>
		</tr>
		<tr>
			<td class=tdbox>大局表格<br>头部内容<br>支持HTML</td>
			<td class=tdbox><textarea name=TableHeadString rows=5 cols=60 class=fmtxtra><%If TableHeadString <> "" Then Response.Write VbCrLf & Server.htmlEncode(TableHeadString)%></textarea></td>
		</tr>
		<tr>
			<td class=tdbox>大局表格<br>尾部内容<br>支持HTML</td>
			<td class=tdbox><textarea name=TableBottomString rows=5 cols=60 class=fmtxtra><%If TableBottomString <> "" Then Response.Write VbCrLf & Server.htmlEncode(TableBottomString)%></textarea></td>
		</tr>
		<tr>
			<td class=tdbox>小局表格<br>头部内容<br>支持HTML</td>
			<td class=tdbox><textarea name=SmallTableHead rows=5 cols=60 class=fmtxtra><%If SmallTableHead <> "" Then Response.Write VbCrLf & Server.htmlEncode(SmallTableHead)%></textarea></td>
		</tr>
		<tr>
			<td class=tdbox>小局表格<br>尾部内容<br>支持HTML</td>
			<td class=tdbox><textarea name=SmallTableBottom rows=5 cols=60 class=fmtxtra><%If SmallTableBottom <> "" Then Response.Write VbCrLf & Server.htmlEncode(SmallTableBottom)%></textarea></td>
		</tr>
		<tr>
			<td class=tdbox>尾部内容<br>必须显示</td>
			<td class=tdbox><table border=0 cellpadding=0 cellspacing=0><tr>
				<td><input class=fmchkbox type=radio name=ShowBottomSure value=0<%If ShowBottomSure = 0 Then%> checked<%End If%>></td><td>有选择显示</td>
          		<td><input class=fmchkbox type=radio name=ShowBottomSure value=1<%If ShowBottomSure = 1 Then%> checked<%End If%>></td><td>肯定显示</td><td><font color=gray>&nbsp; (为了美观，某些页 面底部自定义内容不想显示，请选择＂有选择＂，否则选择后者)</font></td></tr></table></td>
		</tr>
		<!--
		<tr>
			<td class=tdbox>使用模板</td>
			<td class=tdbox><%DisplayTempletList(TempletID)%> <font color=Gray>若不使用JS模板，请选择第一项</font></td>
		</tr>
		-->
		</table>
	<%

End Function

Function GetDefaultValue

	StyleID = Left(Request("StyleID"),14)
	If isNumeric(StyleID) = 0 Then StyleID = 0
	StyleID = Fix(cCur(StyleID))
	If StyleID < 0 or StyleID > DEF_BoardStyleStringNum Then StyleID = 0
	
	Dim Rs
	Set Rs = LDExeCute(sql_select("Select * from LeadBBS_Skin Where StyleID=" & StyleID,1),0)
	If Not Rs.Eof Then
		ScreenWidth = Rs("ScreenWidth")
		DisplayTopicLength = Rs("DisplayTopicLength")
		SiteHeadString = Rs("SiteHeadString")
		SiteBottomString = Rs("SiteBottomString")
		DefineImage = ccur(Rs("DefineImage"))
		TableHeadString = Rs("TableHeadString")
		TableBottomString = Rs("TableBottomString")
		SmallTableHead = Rs("SmallTableHead")
		SmallTableBottom = Rs("SmallTableBottom")
		ShowBottomSure = Rs("ShowBottomSure")
		If DefineImage = 1 Then
			DefineImage = 1
		Else
			DefineImage = 0
		End If
		If ShowBottomSure >= 1 Then
			ShowBottomSure = 1
		Else
			ShowBottomSure = 0
		End If
		TempletID = cCur(Rs("TempletID"))
		If isNull(TempletID) Then TempletID = 0
	Else
		ScreenWidth = "770"
		DisplayTopicLength = 56
		SiteHeadString = ""
		SiteBottomString = ""
		DefineImage = 0
		TableHeadString = ""
		TableBottomString = ""
		ShowBottomSure = 0
		TempletID = 0
	End If
	Rs.Close
	Set Rs = Nothing

End Function

Function GetFormValue

	ScreenWidth = Request("ScreenWidth")
	DisplayTopicLength = Left(Request("DisplayTopicLength"),4)
	If isNumeric(DisplayTopicLength) = 0 Then DisplayTopicLength = 56
	DisplayTopicLength = Fix(cCur(DisplayTopicLength))
	DefineImage = Request.Form("DefineImage")
	If DefineImage = "1" Then
		DefineImage = 1
	Else
		DefineImage = 0
	End If
	If DisplayTopicLength < 10 or DisplayTopicLength > 255 Then DisplayTopicLength = 56
	SiteHeadString = Left(Request.Form("SiteHeadString"),DEF_MaxTextLength)
	SiteBottomString = Left(Request.Form("SiteBottomString"),DEF_MaxTextLength)
	TableHeadString = Left(Request.Form("TableHeadString"),DEF_MaxTextLength)
	TableBottomString = Left(Request.Form("TableBottomString"),DEF_MaxTextLength)
	SmallTableHead = Left(Request.Form("SmallTableHead"),DEF_MaxTextLength)
	SmallTableBottom = Left(Request.Form("SmallTableBottom"),DEF_MaxTextLength)
	ShowBottomSure = Left(Request.Form("ShowBottomSure"),4)
	TempletID = Left(Request.Form("TempletID"),4)
	
	If ShowBottomSure = "1" Then
		ShowBottomSure = 1
	Else
		ShowBottomSure = 0
	End If

	If isNumeric(TempletID) = 0 Then TempletID = 0

End Function

Function SaveStyleDefine

	Dim Rs
	Set Rs = LDExeCute(sql_select("Select * from LeadBBS_Skin Where StyleID=" & StyleID,1),0)
	If Not Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		rem '"ScreenWidth='" & Replace(ScreenWidth,"'","''") & "'" & _
		rem ",TempletID=" & TempletID &_
		rem ",DefineImage=" & DefineImage & _
		CALL LDExeCute("Update LeadBBS_Skin Set "&_
		"DisplayTopicLength=" & DisplayTopicLength & _
		",SiteHeadString='" & Replace(SiteHeadString,"'","''") & "'" & _
		",SiteBottomString='" & Replace(SiteBottomString,"'","''") & "'" & _
		",TableHeadString='" & Replace(TableHeadString,"'","''") & "'" & _
		",TableBottomString='" & Replace(TableBottomString,"'","''") & "'" & _
		",SmallTableHead='" & Replace(SmallTableHead,"'","''") & "'" & _
		",SmallTableBottom='" & Replace(SmallTableBottom,"'","''") & "'" & _
		",ShowBottomSure=" & ShowBottomSure & _
		" Where StyleID=" & StyleID,1)
	Else
		Rs.Close
		Set Rs = Nothing
		CALL LDExeCute("insert into LeadBBS_Skin(" & _
		"StyleID,ScreenWidth,DisplayTopicLength,SiteHeadString,SiteBottomString,DefineImage," & _
		"TableHeadString,TableBottomString,SmallTableHead,SmallTableBottom,ShowBottomSure,TempletID) values(" & _
		StyleID & _
		",'" & Replace(ScreenWidth,"'","''") & "'" & _
		"," & DisplayTopicLength & _
		",'" & Replace(SiteHeadString,"'","''") & "'" & _
		",'" & Replace(SiteBottomString,"'","''") & "'" & _
		"," & DefineImage & _
		",'" & Replace(TableHeadString,"'","''") & "'" & _
		",'" & Replace(TableBottomString,"'","''") & "'" & _
		",'" & Replace(SmallTableHead,"'","''") & "'" & _
		",'" & Replace(SmallTableBottom,"'","''") & "'" & _
		"," & ShowBottomSure & _
		"," & TempletID & _
		")",1)
	End If
	ReloadBoardStyleInfo(StyleID)

End Function

Sub DisplayTempletList(TempletID)

	%>
	<script language=javascript>
	var TempletID = <%=TempletID%>;
	function s(ID,TempletName)
	{
		if(ID=="")return;
		if(TempletID == parseInt(ID)){document.write("<option value=" + ID + " selected>" + TempletName);}
		else{document.write("<option value=" + ID + ">" + TempletName);}
	}
	</script>
	<%
	Dim Rs,SQL
	SQL = "select ID,TempletName from LeadBBS_Templet"

	Set Rs = LDExeCute(SQL,0)
	Dim Num
	If Not rs.Eof Then
		Response.Write "<select name=TempletID><script language=javascript>s(""9999"",""HTML输出(非JS模板)"");" & VbCrLf & "s("""
		Response.Write RsGetString(Rs,""",""",""");" & VbCrLf & "s(""","")
		%>","","","");
		</script>
		</select>
		<%
	Else
		Num = -1
		Response.Write "无可用模板"
	End If
	Rs.close
	Set Rs = Nothing

End Sub
%>