<!-- #include file=../../inc/BBSsetup.asp -->
<!-- #include file=../../inc/Board_popfun.asp -->
<!-- #include file=../../User/inc/UserTopic.asp -->
<%
DEF_BBS_homeUrl="../../"

Class Plug_Flash_Gold

Private con2,u_name

Public Sub Main

	InitDatabase
	OpenDatabase_2
	u_name = Request.form("userid")
	if u_name <> "" Then
		UpdateData
		CloseDatabase
		CloseDatabase_2
		Response.Write "ok"
		Exit Sub
	End If
	Dim appflag
	appflag = request("appflag")
	if appflag <> "1" then
		BBS_SiteHead DEF_SiteNameString & " - 挖金子",0,"<span class=navigate_string_step>挖金子</span>"
	else%>
		<html><head>
		<style>
		*{font-size: 12px;}
		.clear {clear:both;height:0;width:0;}
		.title{color:#3D7800;font-weight:bold;padding-bottom:6px;padding-top:1px;}
		 .value3{padding-top:6px;padding-left:12px;}
		.value2{padding-top:6px;line-height:1.6;}
		.table_in{table-layout:fixed;}
		.table_in .tdbox{font-size:9pt;padding-top:6px;padding-bottom:6px;padding-right:12px;border-top:1px dotted #d3e6d4;line-height:1.8;}
		.table_in .num {font-family:Arial,sans-serif;font-style:normal;font-size:12px;}
		.table_in em {font-family:Arial,sans-serif;font-style:normal;font-size:11px;}
		.tbinhead td{color:#3D7800;padding:0px;}
		.tbinhead .value{padding-right:3px;padding-top:6px;padding-bottom:5px;}
		.table_in .tdbox .user {font-weight:bold;color:#3D7800;padding-top:6px;}
		.table_in .tdbox ul{padding:3px; margin:0px;list-style:none ;}
		.table_in .tdbox li{margin-bottom:2px;}
		</style></head><body>
	<%
	end if
	
	if appflag <> "1" then UserTopicTopInfo("plug")
	
	If GBL_CHK_User = "" then
		Response.write "<div class=alert>您没有使用此功能权限，请先登陆或者注册为论坛会员。</div>"
	Else
		Main_Gold
	End If
	
	CloseDatabase
	CloseDatabase_2
	if appflag <> "1" then UserTopicBottomInfo
	if appflag <> "1" then
		SiteBottom
	else%>
		</body></html>
	<%end if

End Sub

Private Sub OpenDatabase_2

	'on error resume next
	Set Con2 = Server.CreateObject("ADODB.Connection")
	Con2.ConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0; Data Source=" & Server.MapPath("normal.mdb")
	Con2.Open

End Sub

Private Sub CloseDatabase_2

	Con2.Close
	Set Con2 = Nothing

End Sub

Private Sub UpdateData


	'dim x
	
	'dim str
	'str = Request.QueryString & VbCrLf
	'for each x in request.Form 
	'str=str&x & ": " & request.Form (x) & VbCrLf
	'next
	'str = str & "GBL_UserID: " & GBL_UserID & VbCrLf
	'str = str & "GBL_CHK_User: " & GBL_CHK_User & VbCrLf
	'str = str & "score: " & score & VbCrLf
	'str = str & "u_name: " & u_name & VbCrLf
	'ADODB_SaveToFile str,"gold.txt"
	'if GBL_UserID < 1 or GBL_CHK_User <> u_name Then Exit Sub	
	if GBL_UserID < 1 Then Exit Sub	
	u_name = GBL_CHK_User

	'u_name = left(u_name,20)
	Dim score
	score = Request.form("score")
	If isNumeric(score) = 0 Then score = 0
	score = Fix(cCur(score))
	If score = 0 or score > 100000 Then Exit Sub

	Dim Rs

	Dim points,exist
	Set Rs = Con2.ExeCute("Select points from Plug_Flash_Gold where username='" & Replace(GBL_CHK_User,"'","''") & "'")
	If Rs.Eof Then
		exist = 0
	Else
		exist = 1
		points = cCur(Rs(0))
	End If
	Rs.Close
	Set Rs = Nothing
	
	dim createtime,recordtime
	createtime = GetTimeValue(DEF_Now)
	recordtime = createtime
	If exist = 0 Then
		Con2.ExeCute("insert into Plug_Flash_Gold(username,createtime,recordtime,points) values('" & Replace(u_name,"'","''") & "'," & createtime & "," & recordtime & "," & score & ")")
	ElseIf score > points Then
		con2.ExeCute("Update Plug_Flash_Gold Set points=" & score & ",recordtime=" & recordtime & " where username='" & Replace(u_name,"'","''") & "'")
	End If
	

End Sub

Private Sub Main_Gold

%>
	<div class=title>挖金子</div>
	<div class=value2>
	<b>您的状态</b><%ViewMyInfo%>
	</div>
	<div class=value2>
	<object codeBase=http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=4,0,2,0 classid=clsid:D27CDB6E-AE6D-11cf-96B8-444553540000 width=540 height=393><param name=movie value="a.swf?username=<%=urlencode(GBL_CHK_User)%>"><param name=quality value=high>
	<embed height="393" width="540" name="plugin" src="a.swf?username=<%=urlencode(GBL_CHK_User)%>" type="application/x-shockwave-flash"/>
	</object>
	</div>
	<div class=value2>
	<br>
	</div>
	<%ViewData%>
	<div class="clear"></div>
	<hr class="splitline" />
	<div class=title>操作说明:</div>
	<div class=value2><↓方向键下: 扔钩，↑方向键上: 扔炸药。<br /><span class=bluefont>获得高分后，点“提交分数”按钮才能保存分数</span>.
	</div>
<%

End Sub

Private Sub ViewMyInfo

	Dim Rs,createtime,recordtime,points,id
	Set Rs = Con2.ExeCute("Select ID,username,createtime,recordtime,points from Plug_Flash_Gold where username='" & Replace(GBL_CHK_User,"'","''") & "'")
	If Rs.Eof Then
		createtime = "无"
		recordtime = "无"
		points = "无"
		id = ""
	Else
		id = Rs(0)
		createtime = ConvertTimeString(RestoreTime(Rs(2)))
		recordtime = ConvertTimeString(RestoreTime(Rs(3)))
		points = Rs(4)
	End If
	Rs.Close
	Set Rs = Nothing
	If id = "" Then
	%>
	<span color=gray>您从未参与挖金子.</span>
	<%
	Else
	%>
	最高分: <%=points%> / 创造时间: <%=recordtime%> / 参与时间: <%=createtime%>
	<%
	End If

	Set Rs = Con2.ExeCute("Select max(ID) from Plug_Flash_Gold")
	If Rs.Eof Then
		id = ""
	
	Else
		id = Rs(0)
	End If
	Rs.Close
	Set Rs = Nothing
	If cstr(id & "") = "" Then
	%>
	<br/>
	<span class=grayfont>目前还没有人参与挖金子.</font>
	<%
		Exit Sub
	Else
		%>
		<br />
		共有 <b><%=id%></b> 人参与了挖金子.
		<%
	End If

End Sub

Private Sub ViewData

	Dim GetData,n,count,Rs
	Set Rs = Con2.ExeCute("Select top 10 username,points from Plug_Flash_Gold order by points desc")
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		Exit Sub
	Else
		GetData = Rs.GetRows(10)
		Rs.Close
		Set Rs = Nothing
	End If
	
	count = Ubound(GetData,2)
	%>
	<div style="position: relative;width:100%;">
	<div style="top:0px;width:40%;float:left;">
		<div class=title>分数排名</div>
		<table class=table_in style="margin-right:45px;">
		<tr class=tbinhead>
		<td><div class=value>排名</div></td>
		<td><div class=value>用户</div></td>
		<td><div class=value>分数</div></td>
		</tr>
		<%
		For n = 0 to count
			%>
			<tr>
			<td class=tdbox><%=n+1%></td>
			<td class=tdbox><a href="<%=DEF_BBS_homeUrl%>User/<%=RW_User(0,"",GetData(0,n),"")%>" target=_blank><%=htmlencode(GetData(0,n))%></a></td>
			<td class=tdbox><%=GetData(1,n)%></td>
			</tr>
			<%
		Next
		%>
		</table>
	</div>
	<div style="top:0px;width:60%;float:right;">
	<%
	Set Rs = Con2.ExeCute("Select top 10 username,points,recordtime from Plug_Flash_Gold order by recordtime desc")
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		Exit Sub
	Else
		GetData = Rs.GetRows(10)
		Rs.Close
		Set Rs = Nothing
	End If
	
	count = Ubound(GetData,2)
	
	%>
		<div class=title>动态：</div>
		<table class=table_in style="width:100%;">
		<tr class=tbinhead>
		<td><div class=value>最新个人记录</div></td></tr>
		<tr>
		<td class=tdbox>
		<ul>
		<%
		For n = 0 to count
			%><li><a href="<%=DEF_BBS_homeUrl%>User/<%=RW_User(0,"",GetData(0,n),"")%>" target=_blank><b><%=htmlencode(GetData(0,n))%></b></a> 创造了自己的记录<%=GetData(1,n)%>分, (<span class=grayfont><em><%=ConvertTimeString(RestoreTime(GetData(2,n)))%></em></span>)</li>
			<%
		Next%>
		</ul>
		</td>
		</tr>
		</table>
	</div>
	</div>
	<%

End Sub

End Class

Dim Plug_FlashGold
Set Plug_FlashGold = New Plug_Flash_Gold
Plug_FlashGold.Main
Set Plug_FlashGold = Nothing
%>