<!--#include file="../inc/BBSSetup.asp"-->
<!--#include file="../inc/User_Setup.ASP"-->
<!--#include file="../inc/Board_Popfun.asp"-->
<!--#include file="inc/UserTopic.asp"-->
<!--#include file="../inc/IncHtm/Top_BoardTop.asp"-->
<%
DEF_BBS_HomeUrl = "../"
GBL_CHK_PWdFlag = 0
initDatabase()

Dim Tmp_NavStr,Tmp_Para
Tmp_Para = Left(Request.ServerVariables("QUERY_STRING"),1)
Select Case Tmp_Para
	Case "S": Tmp_NavStr = DEF_PointsName(0) & "排行榜"
	Case "u": Tmp_NavStr = DEF_PointsName(4) & "排行榜"
	Case "p": Tmp_NavStr = "灌水排行榜"
	Case "e": Tmp_NavStr = "新入用户"
	Case "r": Tmp_NavStr = "查找用户"
	Case "b": Tmp_NavStr = "版面发帖排行"
	Case Else: Tmp_NavStr = DEF_PointsName(0) & "排行榜"
End Select

BBS_SiteHead DEF_SiteNameString & " - " & Tmp_NavStr,0,"" & Tmp_NavStr & ""
UpdateOnlineUserAtInfo 0,Tmp_NavStr

UserTopicTopInfo("forum")
UserTop_NavInfo()

Select Case Tmp_Para
	Case "S": DisplayUserPointsTop(DEF_MaxListNum)
	Case "u": DisplayUserOnlineTimeTop(DEF_MaxListNum)
	Case "p": DisplayUserAncTop(DEF_MaxListNum)
	Case "e": DisplayUserNewest(DEF_MaxListNum)
	Case "r": DisplayUserFind()
	Case "b": DisplayBoardTop()
	Case Else: DisplayUserPointsTop(DEF_MaxListNum)
End Select
UserTopicBottomInfo()
closeDataBase()
SiteBottom()

Sub UserTop_NavInfo

	Dim Evol
	Evol = Tmp_Para
	If Evol = "b" Then Exit Sub
	If inStr("Super",Evol) = 0 Then Evol = ""

	Response.Write "<div class='user_item_nav fire'><ul>"
	If Evol = "S" or Evol = "" Then
		Response.Write "	<li><div class=navactive>" & DEF_PointsName(0) & "排行榜</div></li>"
	Else
		Response.Write "	<li><a href=UserTop.asp?S>" & DEF_PointsName(0) & "排行榜</a></li>"
	End If
	If Evol = "u" Then
		Response.Write "	<li><div class=navactive>" & DEF_PointsName(4) & "排行榜</div></li>"
	Else
		Response.Write "	<li><a href=UserTop.asp?u>" & DEF_PointsName(4) & "排行榜</a></li>"
	End If
	If Evol = "p" Then
		Response.Write "	<li><div class=navactive>灌水排行榜</div></li>"
	Else
		Response.Write "	<li><a href=UserTop.asp?p>灌水排行榜</a></li>"
	End If
	If Evol = "e" Then
		Response.Write "	<li><div class=navactive>新入用户</div></li>"
	Else
		Response.Write "	<li><a href=UserTop.asp?e>新入用户</a></li>"
	End If
	If Evol = "r" Then
		Response.Write "	<li><div class=navactive>查找用户</div></li>"
	Else
		Response.Write "	<li><a href=UserTop.asp?r>查找用户</a></li>"
	End If
	Response.Write "</ul></div>"
	

End Sub

Sub DisplayUserPointsTop(Number)

	Dim Rs,SQL
	
	Rem Order by Points跟Order by LeadBBS_User.Points是不一样的(特指Access中),可恶的Access经常会将points为0的排到最前面
	Rem 还有,加上一个Where判断,可能有让Access重辨索引的效果
	SQL = sql_select("select LeadBBS_User.ID,LeadBBS_User.UserName,LeadBBS_User.Points,LeadBBS_User.ApplyTime,LeadBBS_User.Lastdoingtime,LeadBBS_User.UserLevel,LeadBBS_User.TrueName from LeadBBS_User Order by LeadBBS_User.Points DESC",Number)

	Set Rs = LDExeCute(SQL,0)
	If Not Rs.Eof Then%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class=table_in>
                    <tr class=tbinhead>
                    	<td width=8%><div class=value>排名</div></td>
                    	<td width=30%><div class=value>名称</div></td>
                    	<td width=15%><div class=value><%=DEF_PointsName(0)%></div></td>
                    	<td width=15%><div class=value>注册时间</div></td>
                    	<td width=15%><div class=value>最近光临</div></td>
                    	<td width=17%><div class=value><%=DEF_PointsName(3)%></div></td>
                    </tr>
<%	
		'Response.Write "" & VbCrLf & "s("""
		'Response.Write Rs.GetString(,,""",""",""");" & VbCrLf & "s(""","")
		dim getdata,n
		getdata = rs.getrows(-1)
		Rs.Close
		Set Rs = Nothing
		for n = 0 to ubound(getdata,2)
			%>
			<tr><td class=tdbox><%=n+1%></td><td class=tdbox>
			<a href=<%=RW_User(getdata(0,n),"","","")%>>
			<%=GetTrueName(getdata(1,n),getdata(6,n))%></a>
			</td><td class=tdbox><%=getdata(2,n)%></td>
        	<td class=tdbox><%=left(restoretime(getdata(3,n)),10)%></td>
			<td class=tdbox><%=left(restoretime(getdata(4,n)),10)%></td>
			<td class=tdbox><%=DEF_UserLevelString(ccur(getdata(5,n)))%></td></tr>
		<%	next
		'Response.Write ""","""","""","""");"
%>
                  </table>
	<%
	Else
		Rs.close
		Set Rs = Nothing
		Response.Write "<div class=alert>暂无相关内容.</div>" & VbCrLf
	End If

End Sub

Sub DisplayUserOnlineTimeTop(Number)

	Dim Rs,SQL
	SQL = sql_select("select LeadBBS_User.ID,LeadBBS_User.UserName,LeadBBS_User.OnlineTime,LeadBBS_User.ApplyTime,LeadBBS_User.Lastdoingtime,LeadBBS_User.UserLevel,LeadBBS_User.TrueName from LeadBBS_User Order by LeadBBS_User.OnlineTime DESC",Number)
	Set Rs = LDExeCute(SQL,0)
	Dim Num
	Dim GetData
	If Not Rs.Eof Then%>
                  <table width="100%" border="0" cellspacing="0" cellpadding="0" class=table_in>
                    <tr class=tbinhead>
                    	<td width=8%><div class=value>排名</div></td>
                    	<td width=30%><div class=value>名称</div></td>
                    	<td width=15%><div class=value><%=DEF_PointsName(4)%></div></td>
                    	<td width=15%><div class=value>注册时间</div></td>
                    	<td width=15%><div class=value>最近光临</div></td>
                    	<td width=17%><div class=value><%=DEF_PointsName(3)%></div></td>
                    </tr>
<%	
		dim n
		getdata = rs.getrows(-1)
		Rs.Close
		Set Rs = Nothing
		for n = 0 to ubound(getdata,2)
			%>
			<tr><td class=tdbox><%=n+1%></td><td class=tdbox>
			<a href=<%=RW_User(getdata(0,n),"","","")%>>
			<%=GetTrueName(getdata(1,n),getdata(6,n))%></a>
			</td><td class=tdbox><%=fix(ccur(getdata(2,n))/60)%></td>
        	<td class=tdbox><%=left(restoretime(getdata(3,n)),10)%></td>
			<td class=tdbox><%=left(restoretime(getdata(4,n)),10)%></td>
			<td class=tdbox><%=DEF_UserLevelString(ccur(getdata(5,n)))%></td></tr>
		<%	next
%>
                  </table>
	<%
	Else
		Rs.close
		Set Rs = Nothing
		Response.Write "<div class=alert>暂无相关内容.</div>" & VbCrLf
	End If

End Sub

Sub DisplayUserAncTop(Number)

	Dim Rs,SQL
	
	SQL = sql_select("select LeadBBS_User.ID,LeadBBS_User.UserName,LeadBBS_User.AnnounceNum,LeadBBS_User.ApplyTime,LeadBBS_User.Lastdoingtime,LeadBBS_User.UserLevel,LeadBBS_User.TrueName from LeadBBS_User Order by LeadBBS_User.AnnounceNum DESC",Number)

	Set Rs = LDExeCute(SQL,0)
	If Not Rs.Eof Then%>

                  <table width="100%" border="0" cellspacing="0" cellpadding="0" class=table_in>
                    <tr class=tbinhead>
                    	<td width=8%><div class=value>排名</div></td>
                    	<td width=30%><div class=value>名称</div></td>
                    	<td width=15%><div class=value>发帖</div></td>
                    	<td width=15%><div class=value>注册时间</div></td>
                    	<td width=15%><div class=value>最近光临</div></td>
                    	<td width=17%><div class=value><%=DEF_PointsName(3)%></div></td>
                    </tr>
                    <%	
		dim n,getdata
		getdata = rs.getrows(-1)
		Rs.Close
		Set Rs = Nothing
		for n = 0 to ubound(getdata,2)
			%>
			<tr><td class=tdbox><%=n+1%></td><td class=tdbox>
			<a href=<%=RW_User(getdata(0,n),"","","")%>>
			<%=GetTrueName(getdata(1,n),getdata(6,n))%></a>
			</td><td class=tdbox><%=getdata(2,n)%></td>
        	<td class=tdbox><%=left(restoretime(getdata(3,n)),10)%></td>
			<td class=tdbox><%=left(restoretime(getdata(4,n)),10)%></td>
			<td class=tdbox><%=DEF_UserLevelString(ccur(getdata(5,n)))%></td></tr>
		<%	next
%>
                  </table>
	<%
	Else
		Rs.close
		Set Rs = Nothing
		Response.Write "<div class=alert>暂无相关内容.</div>" & VbCrLf
	End If

End Sub

Sub DisplayUserNewest(Number)

	Dim Rs,SQL
	SQL = sql_select("select ID,UserName,Points,OnlineTime,ApplyTime,Prevtime,TrueName from LeadBBS_User Order by ID DESC",Number)
	Set Rs = LDExeCute(SQL,0)
	Dim Num
	If Not Rs.Eof Then	
	%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class=table_in>
		<tr class=tbinhead>
			<td width=12%><div class=value>编号</div></td>
			<td width=24%><div class=value>名称</div></td>
			<td width=8%><div class=value><%=DEF_PointsName(0)%></div></td>
			<td width=8%><div class=value><%=DEF_PointsName(4)%></div></td>
			<td width=24%><div class=value>注册时间</div></td>
			<td width=24%><div class=value>最后登录</div></td>
		</tr>
<%	
		dim n,getdata
		getdata = rs.getrows(-1)
		Rs.Close
		Set Rs = Nothing
		for n = 0 to ubound(getdata,2)
			%>
			<tr><td class=tdbox><%=getdata(0,n)%></td><td class=tdbox>
			<a href=<%=RW_User(getdata(0,n),"","","")%>>
			<%=GetTrueName(getdata(1,n),getdata(6,n))%></a>
			</td><td class=tdbox><%=getdata(2,n)%></td>
			</td><td class=tdbox><%=clng(ccur(getdata(3,n))/60)%></td>
        	<td class=tdbox><%=left(restoretime(getdata(4,n)),10)%></td>
			<td class=tdbox><%=left(restoretime(getdata(5,n)),10)%></td></tr>
		<%	next
%>
	</table>
	<%
	Else
		Rs.Close
		Set Rs = Nothing
		Response.Write "<div class=alert>暂无相关内容.</div>" & VbCrLf
	End If

End Sub

Sub DisplayUserFind

Dim OkFlag
OkFlag = 1
Dim Form_SearchKey
Form_SearchKey = Request.Form("Form_SearchKey")
If Request("SubmitFlag")<>"kdWosoO9w2AXkHouseASP" Then OkFlag = 0

If Len(Form_SearchKey) < 1 Then OkFlag = 0
If OkFlag = 1 Then Form_SearchKey = Left(Form_SearchKey,20)

If OkFlag = 0 Then
	DisplaySearchForm()
Else
	Dim Rs,SQL
	SQL = sql_select("select ID,UserName,Points,ApplyTime,Prevtime,UserLevel from LeadBBS_User where UserName ='" & Replace(Form_SearchKey,"'","''") & "'",1)
	Set Rs = LDExeCute(SQL,0)
	Dim Num
	Dim GetData
	If Not Rs.Eof Then
		GetData = Rs.GetRows(1)
		Num = 0
	Else
		Num = -1
	End If
	Rs.close
	Set Rs = Nothing
	
	Dim i,N
	If Num>=0 Then
	%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class=table_in>
	<tr class=tbinhead>
		<td wdith=8%><div class=value>ID</div></td>
		<td wdith=30%><div class=value>名称</div></td>
		<td wdith=15%><div class=value><%=DEF_PointsName(0)%></div></td>
		<td wdith=15%><div class=value>注册时间</div></td>
		<td wdith=15%><div class=value>最后登录</div></td>
		<td wdith=17%><div class=value><%=DEF_PointsName(3)%></div></td>
	</tr>
<%
		for n= 0 to Num
			%>
	<tr>
		<td class=tdbox><%=GetData(0,n)%></td>
		<td class=tdbox>
			<a href=<%=RW_User(getdata(0,n),"","","")%>><%=htmlencode(GetData(1,n))%></a></td>
		<td class=tdbox><%=GetData(2,n)%></td>
		<td class=tdbox><%=RestoreTime(Left(GetData(3,n),8))%></td>
		<td class=tdbox><%=RestoreTime(Left(GetData(4,n),8))%></td>
		<td class=tdbox><%=DEF_UserLevelString(GetData(5,n))%></td>
		</tr><%
		next
%>
	</table>
	<%
		DisplaySearchForm()
	Else%>
		<div class=title>查找用户： <span class=redfont><%=htmlencode(Form_SearchKey)%></span></div><%
		Response.Write "<div class=alert>暂无相关内容.</div>"
		DisplaySearchForm()
	End If
End If

End Sub

Sub DisplayBoardTop

	Dim t
	t = DateDiff("s",Top_BoardTop_UpdateTime,DEF_Now)
	If t >= 0 and t <= DEF_UpdateInterval Then
		Top_BoardTop_View()
		Exit Sub
	End If
	
	Dim Rs,SQL
	SQL = sql_select("select BoardID,BoardName,AnnounceNum from LeadBBS_Boards where HiddenFlag=0 and BoardID<>444 order by AnnounceNum DESC",DEF_MaxListNum)
	Set Rs = LDExeCute(SQL,0)
	Dim Num
	Dim GetData
	If Not Rs.Eof Then
		GetData = Rs.GetRows(DEF_MaxListNum)
		Num = Ubound(GetData,2)
	Else
		Num = -1
	End If
	Rs.close
	Set Rs = Nothing
	
	Dim i,N,Str
	If Num>=0 Then
Str = "	<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" class=""table_in"">" & VbCrLf &_
"	<tr class=tbinhead>" & VbCrLf &_
"		<td wdith=8% ><div class=value>&nbsp;</div></td>" & VbCrLf &_
"		<td width=77% ><div class=value>版面</div></td>" & VbCrLf &_
"		<td wdith=15% ><div class=value>发帖</div></td>" & VbCrLf &_
"	</tr>" & VbCrLF
		for n= 0 to Num
Str = Str & "	<tr>" & VbCrLf &_
"		<td class=tdbox>" & N+1 & "</td>" & VbCrLf &_
"		<td class=tdbox>" & VbCrLf &_
"			<a href=" & DEF_BBS_HomeUrl & "b/" & RW_b(GetData(0,n),0,"") & ">" & KillHTMLLabel(GetData(1,n)) & "</a></td>" & VbCrLf &_
"		<td class=tdbox>" & GetData(2,n) & "</td>" & VbCrLf &_
"		</tr>"
		next
Str = Str & "	</table>" & VbCrLf
	Else
		Str = "<div class=alert>暂无版面.</div>"
	End If
	Response.Write Str	
	
	Str = "<" & "%" & VbCrLf &_
	"Dim Top_BoardTop_UpdateTime" & VbCrLf &_
	"Top_BoardTop_UpdateTime = """ & htmlencode(DEF_Now) & """" & VbCrLf &_
	"" & VbCrLf &_
	"Sub Top_BoardTop_View" & VbCrLf &_
	"" & VbCrLf &_
	"%" & ">" & VbCrLf &_
	Str &_
	"<" & "%" & VbCrLf &_
	"" & VbCrLf &_
	"End Sub" & VbCrLf &_
	"%" & ">" & VbCrLf
	CALL ADODB_SaveToFile(Str,DEF_BBS_HomeUrl & "inc/IncHtm/Top_BoardTop.asp")

End Sub

Sub DisplaySearchForm

	Dim Form_SearchKey
	Form_SearchKey = Request.Form("Form_SearchKey")
%>
	<form action="UserTop.asp?r" onSubmit="submit_disable(this);" method="post">
	<div class="title">请输入完整用户名: </div>
	<div class="value2">
	<input name="Form_SearchKey" type="text" value="<%=Htmlencode(Form_SearchKey)%>" class="fminpt input_2">
	<input name="SubmitFlag" value="kdWosoO9w2AXkHouseASP" type="hidden">
	</div>
	<div class="value2">
	<input type="submit" value="查找" class="fmbtn btn_2">
	</div>
	</Form>
<%
End Sub%>