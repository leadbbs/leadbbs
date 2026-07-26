<!-- #include file=../../inc/BBSsetup.asp -->
<!-- #include file=../../inc/Board_Popfun.asp -->
<!--#include file="inc/StarSetup.asp"-->
<%
DEF_BBS_HomeUrl = "../../"

Main

Sub Main

	BBS_SiteHead DEF_SiteNameString & " - 社区明星",0,"<span class=""navigate_string_step"">社区明星</span>"
	Dim Master
	InitDatabase
	If CheckSupervisorNameOnly = 1 Then
		Master = True
	Else
		Master = False
	End If

	Boards_Body_Head("")
	%>
	<div class="alertbox fire">
	<table cellpadding="0" cellspacing="0" class="table_in">
	<tr class="tbinhead">
		<td><div class="value"><b>＝官方版LeadBBS首页明星插件 社区明星管理中心＝</b></div></td>
	</tr>
	<tr>
	<td class="tdbox">
	<%
	If GBL_CHK_User="" or Not(Master) Then
		%>
		<div class="alert">产生错误的原因可能是：</div><br /><br />
		你不是管理员，无权进入！<
		br />如果你是管理员，请以管理员身份<a href="<%=DEF_BBS_HomeUrl%>User/Login.asp?Relogin=Yes&u=<%=urlencode(Request.Servervariables("SCRIPT_NAME") & "?" & Request.QueryString)%>"><b>重登录</b></a>！
		</div>
		<%
	Else
		Call Main_Star()
	End If
	CloseDatabase%>
	</td><tr>
	</table>
	<%
	Boards_Body_Bottom
	
	If GBL_ShowBottomSure = 0 Then GBL_SiteBottomString = ""
	SiteBottom

End Sub

Sub Main_Star()

	%>
		<br />
		<ol>
			<li>
			注意事项： 在下面，您将看到对当前社区明星显示方式的设定，如果想要修改，请点击相应的单选按钮对每一行的显示方式进行自定义，自定能力更加强大！
			</li>
			<li>经测算，从对首页显示的速度影响看，范围在：0.00秒——2.0秒间。每一种显示方式对速度的影响都不一样，管理员在使用时可自己实验一下！！！
			</li>
			<li>
			<a href="http://www.leadbbs.com/a/a.asp?B=10&ID=858130" target="_blank">
				<span class="redfont">官方版LeadBBS首页明星插件最新版最新更新请点击这里</span></a>
			</li>
		</ol>
				<form action="admin_HomePageStar.asp" method="post">
					<%
	Dim Temp_1,Temp_2,Temp_3,Temp_4,Temp_5,Temp_6
	If Request.Form("submit") <> " 提交 " Then
		Temp_1 = GBL_PLUG_HPS_LineFirstType
		Temp_2 = GBL_PLUG_HPS_LineSecondType
		Temp_3 = GBL_PLUG_HPS_ShowType
		Temp_4 = GBL_PLUG_HPS_RefreshSpace
		Temp_5 = GBL_PLUG_HPS_TopMax
		Temp_6 = GBL_PLUG_HPS_Collapse
		%>
		<ol>
		<li><b>第一行明星显示方式：</b>
			<br />
			<input type="radio" name="GBL_PLUG_HPS_LineFirstType" value="1" <%if Temp_1="1" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">每日发贴量
			<input type="radio" name="GBL_PLUG_HPS_LineFirstType" value="2" <%if Temp_1="2" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">每周发贴量
			<input type="radio" name="GBL_PLUG_HPS_LineFirstType" value="3" <%if Temp_1="3" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">每月发贴量
			<input type="radio" name="GBL_PLUG_HPS_LineFirstType" value="4" <%if Temp_1="4" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">每年发贴量 
			<input type="radio" name="GBL_PLUG_HPS_LineFirstType" value="5" <%if Temp_1="5" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">发贴总数
		</li>
		<li><b>第二行明星显示方式：</b>
			<br />
			<input type="radio" name="GBL_PLUG_HPS_LineSecondType" value="1" <%if Temp_2="1" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">每日发贴量
			<input type="radio" name="GBL_PLUG_HPS_LineSecondType" value="2" <%if Temp_2="2" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">每周发贴量
			<input type="radio" name="GBL_PLUG_HPS_LineSecondType" value="3" <%if Temp_2="3" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">每月发贴量
			<input type="radio" name="GBL_PLUG_HPS_LineSecondType" value="4" <%if Temp_2="4" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">每年发贴量
			<input type="radio" name="GBL_PLUG_HPS_LineSecondType" value="5" <%if Temp_2="5" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">发贴总数
		</li>
		<li><b>明星插件显示方式：</b>
			<br />
			<input type="radio" name="GBL_PLUG_HPS_ShowType" value="0" <%if Temp_3="0" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">禁止显示
			<input type="radio" name="GBL_PLUG_HPS_ShowType" value="1" <%if Temp_3="1" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">正常显示两行
			<input type="radio" name="GBL_PLUG_HPS_ShowType" value="2" <%if Temp_3="2" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">只显示第一行
			<input type="radio" name="GBL_PLUG_HPS_ShowType" value="3" <%if Temp_3="3" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">只显示第二行
		</li>
		<li>4. <b>明星插件刷新间隔：</b>
			<br />
			<input type="text" size="3" maxlength="3" name="GBL_PLUG_HPS_RefreshSpace" value="<%=Temp_4%>" class="fminpt input_1">分钟，为了你的网站更快速及各虚拟主机商利益，要求最少为5分钟，最多50分钟
		</li>
		<li><b>显示明星记录条数：</b>
			<br />
			<input type="text" size="2" maxlength="2" name="GBL_PLUG_HPS_TopMax" value="<%=Temp_5%>" class="fminpt input_1"> 最少为3条，最多只能设置为50条
		</li>
		<li><b>默认是否卷起：</b>
			<br />
			<input type="radio" name="GBL_PLUG_HPS_Collapse" value="0" <%if Temp_6="0" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">默认显示
			<input type="radio" name="GBL_PLUG_HPS_Collapse" value="1" <%if Temp_6="1" Then Response.Write("checked=""checked""") End If%> class="fmchkbox">默认卷起
		</li>
		</ol>
		<ol>
		<div class=value2>
			<input type="submit" name="Submit" value=" 提交 " class="fmbtn btn_2">
			<input type="reset" name="Submit2" value=" 重置 " class="fmbtn btn_2">
		</div>
		</ol>
		<%
	Else
		Temp_1 = Left(Trim(Request.Form("GBL_PLUG_HPS_LineFirstType")),14)
		Temp_2 = Left(Trim(Request.Form("GBL_PLUG_HPS_LineSecondType")),14)
		Temp_3 = Left(Trim(Request.Form("GBL_PLUG_HPS_ShowType")),14)
		Temp_4 = Left(Trim(Request.Form("GBL_PLUG_HPS_RefreshSpace")),14)
		Temp_5 = Left(Trim(Request.Form("GBL_PLUG_HPS_TopMax")),14)
		Temp_6 = Left(Trim(Request.Form("GBL_PLUG_HPS_Collapse")),14)
		If isNumeric(Temp_1) = 0 then Temp_1 = 0
		If isNumeric(Temp_2) = 0 then Temp_2 = 0
		If isNumeric(Temp_3) = 0 then Temp_3 = 0
		If isNumeric(Temp_4) = 0 then Temp_4 = 5
		If isNumeric(Temp_6) = 0 then Temp_6 = 0
		Temp_4 = Fix(cCur(Temp_4))
		If Temp_4 < 5 Then Temp_4 = 5
		If Temp_4 > 50 Then Temp_4 = 50
		
		If isNumeric(Temp_5) = 0 then Temp_5 = 5
		Temp_5 = Fix(cCur(Temp_5))
		If Temp_5 < 3 Then Temp_5 = 3
		If Temp_5 > 50 Then Temp_5 = 50
		
		Dim WriteString
		WriteString = ""
		WriteString = WriteString & "<%" & VbCrLf
		WriteString = WriteString & "const GBL_PLUG_HPS_LineFirstType = " & Temp_1 & VbCrLf
		WriteString = WriteString & "const GBL_PLUG_HPS_LineSecondType = " & Temp_2 & VbCrLf
		WriteString = WriteString & "const GBL_PLUG_HPS_ShowType = " & Temp_3 & VbCrLf
		WriteString = WriteString & "const GBL_PLUG_HPS_RefreshSpace = " & Temp_4 & VbCrLf
		WriteString = WriteString & "const GBL_PLUG_HPS_TopMax = " & Temp_5 & VbCrLf
		WriteString = WriteString & "const GBL_PLUG_HPS_Collapse = " & Temp_6 & VbCrLf & VbCrLf
		WriteString = WriteString & "'####################################################################" & VbCrLf
		WriteString = WriteString & "'##" & VbCrLf
		WriteString = WriteString & "'##　　社区明星显示方式设置!如你的服务器不支持FSO，请手动修改显示方式!" & VbCrLf
		WriteString = WriteString & "'##　　1为每日发贴量，2为每周发贴量，3为每月发贴量，4为每年发贴量，5为发贴总数，6为最佳男明星，7为最佳女明星" & VbCrLf
				WriteString = WriteString & "'##　　此程序最后由管理人员整理更新，时间2004-03-20 16:50 LeadBBS社区明星 for 3.14" & VbCrLf
		WriteString = WriteString & "'##　　切勿随意手工更改上面的位置!" & VbCrLf
		WriteString = WriteString & "'##　　使用前请先看安装说明!" & VbCrLf
		WriteString = WriteString & "'##　　主页：http://gafc.9126.com/" & VbCrLf
		WriteString = WriteString & "'##　　官方主页：http://www.LeadBBS.com/" & VbCrLf
		WriteString = WriteString & "'##　　感谢您使用本插件!" & VbCrLf
		WriteString = WriteString & "'##" & VbCrLf
		WriteString = WriteString & "'####################################################################" & VbCrLf

		WriteString = WriteString & "%" & chr(62) & VbCrLf
		ADODB_SaveToFile WriteString,"Inc/StarSetup.asp"
		
		If GBL_CHK_TempStr = "" Then
			Response.Write "<br /><span class=greenfont>2.成功完成设置！</span>"
			Response.Write("恭喜您，明星社区显示方式已经设定完毕！！！"&"<br /><br /><br />")
        	Response.Write("<input type=""button"" value=""重新设置"" onclick=""window.location.href='admin_HomePageStar.asp'"" class=""fmbtn btn_3"">")
		Else
			%><%=GBL_CHK_TempStr%><br />服务器不支持在线写入文件功能，请使用FTP等功能，将<span class="redfont">Inc/StarSetup.asp</span>文件替换成框中内容(注意备份)
			<p>
			<textarea name="fileContent" cols="80" rows="30" class="fmtxtra"><%=Server.htmlencode(WriteString)%></textarea>
			</p><%
			GBL_CHK_TempStr = ""
		End If
	End If
	%>
					</form>
<%
	Set Application(DEF_MasterCookies & "_PLUG_HPS_DAY") = Nothing
	Application(DEF_MasterCookies & "_PLUG_HPS_DAY") = ""
	Set Application(DEF_MasterCookies & "_PLUG_HPS_OTHER") = Nothing
	Application(DEF_MasterCookies & "_PLUG_HPS_OTHER") = ""
	Application(DEF_MasterCookies & "_PLUG_HPS_M") = ""

End Sub
%>