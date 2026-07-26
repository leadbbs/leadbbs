<%
'Extent skin class.
'styleid restricted: 1000+.
'StyleName corresponding for column of leadbbs_skin.ScreenWidth.
'Extent skin can define DisplayTopicLength and css file content.
Class ExtentSkin_Manager

	Public StyleID,StyleName,DisplayTopicLength,CssContent,DT(5,4)
	Public Action,submitflag
	
	Private Sub Class_Initialize
	
		StyleID = 0
		StyleName = ""
		DisplayTopicLength = 0
		CssContent = ""
		submitflag = ""
		Action = "Extentskin_"
		DT(0,0) = "StyleID"
		DT(0,1) = 0
		DT(0,2) = 1
		DT(0,3) = 0
		DT(0,4) = StyleID
		DT(1,0) = "StyleName"
		DT(1,1) = 0
		DT(1,2) = 2
		DT(1,3) = 255
		DT(1,4) = StyleName
		DT(2,0) = "DisplayTopicLength"
		DT(2,1) = 0
		DT(2,2) = 1
		DT(2,3) = 0
		DT(2,4) = DisplayTopicLength
		DT(3,0) = "CssContent"
		DT(3,1) = 0
		DT(3,2) = 2
		DT(3,3) = 1024000
		DT(3,4) = CssContent
		DT(4,0) = "Action"
		DT(4,1) = 0
		DT(4,2) = 2
		DT(4,3) = 25
		DT(4,4) = Action
		DT(5,0) = "submitflag"
		DT(5,1) = 0
		DT(5,2) = 2
		DT(5,3) = 3
		DT(5,4) = ""

	End Sub

	Public Sub ExtentSkin
	
		submitflag = GetFormData("submitflag",2)
		Action = GetFormData("Action",0)
		select case LCase(Action)
		case "extentskin_add":
			if submitflag = "" Then
				DT(4,4) = "Extentskin_add"
				DT(5,4) = "1"
				CALL ExtentSkin_ViewForm("创建新风格","Extentskin_add")
			Else
				GetSendPara
				StyleID = DT(0,4)
				StyleName = DT(1,4)
				DisplayTopicLength = DT(2,4)
				CssContent = DT(3,4)
				If ExtentSkin_Check = 1 Then
					ExtentSkin_Save
					ExtentSkin_Done("成功创建风格.")
				else
					CALL ExtentSkin_ViewForm("创建新风格","Extentskin_add")
				End If
			End If
		case "extentskin_delete":
			deletestyle(GetFormData("StyleID",0))
			ExtentSkin_Done("删除操作完成.")
		case "extentskin_modify":
			StyleID = GetFormData("StyleID",0)
			If StyleID > 0 Then
				if submitflag = "" Then
					ExtentSkin_GetSkin(StyleID)
					StyleID = DT(0,4)
					StyleName = DT(1,4)
					DisplayTopicLength = DT(2,4)
					CssContent = DT(3,4)
					DT(4,4) = "Extentskin_modify"
					DT(5,4) = "1"
					If StyleID = 0 Then
						ExtentSkin_Err "参数不足．"
					Else
						CALL ExtentSkin_ViewForm("编辑扩展风格","Extentskin_modify")
					End If
				Else
					GetSendPara
					StyleID = DT(0,4)
					StyleName = DT(1,4)
					DisplayTopicLength = DT(2,4)
					CssContent = DT(3,4)
					If ExtentSkin_Check = 1 Then
						ExtentSkin_Save
						ExtentSkin_Done("编辑扩展风格完成.")
					else
						CALL ExtentSkin_ViewForm("编辑扩展风格","Extentskin_modify")
					End If
				end if
			Else
				ExtentSkin_Err "参数不足．"
			End If
		case else:
			DisplayskinList
		End select

	End Sub
	
	Sub DisplayskinList
	
		Dim Rs,SQL,GetData,n
		SQL = "select StyleID,ScreenWidth,SmallTableBottom from LeadBBS_Skin where styleid>=1000"

		Set Rs = LDExeCute(SQL,0)
		Dim Num
		If Not rs.Eof Then
			GetData = Rs.GetRows(-1)
			Num = Ubound(GetData,2)
		Else
			Num = -1
			Response.Write "无扩展风格．"
		End If
		Rs.close
		Set Rs = Nothing
		
		%>
		
		<a href=DefineStyleParameter.asp?action=extentskin_add>添加新的扩展风格</a>
		<ul>
		<%
		for n = 0 to num
			%>
			<li style="line-height:40px;height:40px;">
			<%=GetData(0,n)%> <a href=><%=htmlencode(GetData(1,n))%></a>
			 - <a href=DefineStyleParameter.asp?action=extentskin_modify&StyleID=<%=GetData(0,n)%>>修改</a>
			 - <a href="script:;" onclick="if (confirm('删除操作将不可逆,确定继续吗?'))document.location='DefineStyleParameter.asp?action=extentskin_delete&StyleID=<%=GetData(0,n)%>';return false;">删除</a>
			 - <a href="../SiteManage/siteInfo.asp?action=upload&p_filepath=images/style/preview/&p_filename=<%
			if ccur(GetData(0,n)) < 10000 then response.write "0"
			response.write GetData(0,n)%>.jpg&p_fileinfo=<%=urlencode("上传风格 ID:" & GetData(0,n) & " 的预览图片,必须是jpg文件，大小140x105")%>" target=_blank>
	上传风格预览图片</a>
			</li>
			<%
		next
		%>
		</ul>
		<%
	
	End Sub
	
	private function ExtentSkin_check
	
		if strlength(StyleName) > 255 or StyleName = "" Then
			ExtentSkin_Err "风格名称长度必须为1-25字符．"
			ExtentSkin_check = 0
			Exit function
		end if
		
		DisplayTopicLength = ccur(DisplayTopicLength)
		if DisplayTopicLength < 10 or DisplayTopicLength > 255 Then
			ExtentSkin_Err "主题长度请填写10-255之间的数字．"
			ExtentSkin_check = 0
			Exit function
		end if
		
		if len(CssContent)>1024000 then
			ExtentSkin_Err "样式文件过大，最多允许" & DEF_MaxTextLength & "字．"
			ExtentSkin_check = 0
			Exit function
		end if
		ExtentSkin_check = 1
	
	End Function
	
	private sub ExtentSkin_Save
	
		Dim Rs,exist
		exist = 1
		If StyleID >= 1000 Then
			If CheckSupervisorUserName = 1 Then
				Set Rs = LDExeCute(sql_select("Select * from LeadBBS_Skin Where StyleID=" & StyleID,1),0)
			Else
				Set Rs = LDExeCute(sql_select("Select * from LeadBBS_Skin Where StyleID=" & StyleID & " and SmallTableBottom like '" & Replace(GBL_CHK_User,"'","''") & "'",1),0)
			End If
			If Rs.Eof Then
				exist = 0
			End If
			Rs.Close
			Set Rs = Nothing
		Else
			exist = 0
		End If
		If exist = 1 Then
			'" Where StyleID=" & StyleID & " and SmallTableBottom like '" & Replace(GBL_CHK_User,"'","''") & "'",1)
			CALL LDExeCute("Update LeadBBS_Skin Set "&_
			"DisplayTopicLength=" & DisplayTopicLength & _
			",ScreenWidth='" & Replace(StyleName,"'","''") & "'" & _
			" Where StyleID=" & StyleID & " ",1)
			ExtentSkin_SaveCss(StyleID)
		Else
			If lcase(Action) = "extentskin_add" Then
				StyleID = GetMaxStyleID
				CALL LDExeCute("insert into LeadBBS_Skin(" & _
				"StyleID,ScreenWidth,DisplayTopicLength,SiteHeadString,SiteBottomString,DefineImage," & _
				"TableHeadString,TableBottomString,SmallTableHead,SmallTableBottom,ShowBottomSure,TempletID) values(" & _
				StyleID & _
				",'" & Replace(StyleName,"'","''") & "'" & _
				"," & DisplayTopicLength & _
				",''" & _
				",''" & _
				",0" & _
				",''" & _
				",''" & _
				",''" & _
				",'" & Replace(GBL_CHK_User,"'","''") & "'" & _
				",1" & _
				",0" & _
				")",1)
				ExtentSkin_SaveCss(StyleID)
			Else
				ExtentSkin_Err "因意外操作中止．"
			End If
		End If

	End sub

	private sub deletestyle(id)

		If id < 1000 then			
			ExtentSkin_Err "因意外操作中止．"
			Exit sub
		end If
		If CheckSupervisorUserName = 1 Then
			CALL LDExeCute("delete from LeadBBS_Skin Where StyleID=" & id,1)
		Else
			CALL LDExeCute("delete from LeadBBS_Skin Where StyleID=" & id & " and SmallTableBottom like '" & Replace(GBL_CHK_User,"'","''") & "'",1)
		End If
		Dim Rs
		If id < 10000 Then
			Rs = Right("00000" & cCur(id),5)
		Else
			Rs = id
		End If
		DeleteFiles(Server.Mappath(DEF_BBS_HomeUrl & "inc/css/" & Rs & ".css"))

	end sub

	private function GetMaxStyleID

		dim rs,id
		Set rs = LDExeCute("Select max(StyleID) from LeadBBS_Skin",0)
		if not rs.eof then
			id = ccur("0" & rs(0))
			if id >= 1000 then
				id = id + 1
			else
				id = 1000
			end if
		else
			id = 1000
		end if
		GetMaxStyleID = id
	
	End function
	
	private sub ExtentSkin_SaveCss(id)

		Dim Rs
		If id < 10000 Then
			Rs = Right("00000" & cCur(id),5)
		Else
			Rs = id
		End If
		ADODB_SaveToFile CssContent,DEF_BBS_HomeUrl & "inc/css/" & Rs & ".css"

	End Sub
	
	private sub ExtentSkin_GetSkin(id)
	
		Dim Rs
		Set Rs = LDExeCute(sql_select("Select * from LeadBBS_Skin Where StyleID=" & id,1),0)
		If Not Rs.Eof Then
			DT(0,4) = id
			DT(1,4) = Rs("ScreenWidth")
			DT(2,4) = Rs("DisplayTopicLength")
		Else
			DT(0,4) = 0
		End If
		Rs.Close
		Set Rs = Nothing
		If DT(0,4) > 0 Then
			If id < 10000 Then
				Rs = Right("00000" & cCur(id),5)
			Else
				Rs = id
			End If
			
			DT(3,4) = ADODB_LoadFile(DEF_BBS_HomeUrl & "inc/css/" & Rs & ".css")
		End If
	
	End sub
	
	private Sub ExtentSkin_ViewForm(title,action)
	
	%>	<form name="pollform3sdx" method="post" action="DefineStyleParameter.asp">
		<input type="hidden" name="SubmitFlag" value=yes>
		<input type="hidden" name="action" value="<%=action%>">
		<p><b>
		<%
		Response.Write title
		%>
		</b></p>
		<table border=0 cellpadding=0 cellspacing=0 width=100% class=frame_table>
		<%If StyleID > 0 Then%>
		<tr>
			<td class=tdbox width=120>风格编号 <b><%=StyleID%></b><input name=StyleID value=<%=StyleID%> type=hidden></td>
		</tr>
		<%End If%>
		<tr>
			<td class=tdbox>风格名称 <input class=fminpt type="text" name="StyleName" maxlength="255" size="25" value="<%=htmlencode(StyleName)%>"></td>
		</tr>
		<tr>
			<td class=tdbox>主题长度 <input class=fminpt type="text" name="DisplayTopicLength" maxlength="3" size="10" value="<%=htmlencode(DisplayTopicLength)%>"><span color=gray>(单位：字节，帖子主题显示最大长度，750宽=54，770宽=56,最长为255字节)</span></td>
		</tr>
		<tr>
			<td class=tdbox>样式文件
			<textarea name="CssContent" cols="80" rows="15" class=fmtxtra><%If CssContent <> "" Then Response.Write VbCrLf & server.htmlEncode(CssContent)%></textarea><p>
			</td>
		</tr>
		</table>
		<br>
		<input type=submit name=提交 value=提交 class=fmbtn>
		<input type=reset name=取消 value=取消 class=fmbtn>
		</form>
		<%
	
	End Sub
	
	private Sub ExtentSkin_Err(str)
	
		%>
		<div class=alert>Error: <%=str%></div>
		<%
	
	End Sub

	private Sub ExtentSkin_Done(str)
	
		%>
		<div class=alert><span class=greenfont><b><%=str%></b></span></div>
		<%
	
	End Sub
	

'class of requesting and checking form data
'arr structure: arr[index][5]
'arr[index][0]: form name
'arr[index][1]: request type(1-request,2-form,other-all),
'arr[index][2]: data type(1-numeric,2-text,3-bit)
'arr[index][3]: length limited
'arr[index][4]: return value


	Public function GetSendPara
	
		Dim m,n
		n = Ubound(DT,1)
		for m = 0 to n
			DT(m,4) = GetFormData(DT(m,0),DT(m,1))
			Select Case DT(m,2)
			Case 1:
				DT(m,4) = Left(Trim(DT(m,4)&""),34)
				If isNumeric(DT(m,4)) = 0 Then DT(m,4) = 0
			Case 2:				
				If ccur(DT(m,3)) > 0 Then DT(m,4) = Left(DT(m,4),DT(m,3))
			Case 3:
				DT(m,4) = Left(Trim(DT(m,4)&""),11)
				If DT(m,4) = "1" Then
					DT(m,4) = 1
				Else
					DT(m,4) = 0
				End If
			End Select
		next
	
	End function

	Public function GetFormData(name,tp)
	
		Dim Tmp
		Select Case tp
		Case 1:
			GetFormData = Request.QueryString(name)
		Case 2:
			If dontRequestFormFlag = "" Then
				GetFormData = Request.Form(name)
			Else
				GetFormData = Form_UpClass.form(name)
			End If
		Case Else:
			Tmp = Request.QueryString(name)
			If Tmp = "" Then
				If dontRequestFormFlag = "" Then
					GetFormData = Request.Form(name)
				Else
					GetFormData = Form_UpClass.form(name)
				End If
			Else
				GetFormData = Tmp
			End If
		End Select
	
	End function
	
	private Function DeleteFiles(path)

	If DEF_FSOString = "" Then Exit Function
	on error resume next
	Dim fs
	Set fs = Server.CreateObject(DEF_FSOString)
	If err <> 0 Then
		Err.Clear
		Response.Write "<br>服务器不支持FSO，硬盘文件未删除．"
		Exit Function
	End If
	If fs.FileExists(path) Then
		fs.DeleteFile path,True
		DeleteFiles = 1
	Else
		DeleteFiles = 0
	End If
	Set fs = Nothing
         
End Function

End Class
%>