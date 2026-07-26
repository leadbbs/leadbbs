<!--#include file="../../inc/BBSSetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass()

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("查看数据库表结构")
If GBL_CHK_Flag=1 Then
	LoginAccuessFul()
Else
DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

Sub LoginAccuessFul

	Dim TBName
	TBName = Request("TB")

	' The page shipped MSSQL-only (SP_SpaceUsed / COL_NAME / OBJECT_ID) and, worse, computed
	' its "unsupported" message into GBL_CHK_TempStr without ever printing it — so on this
	' MariaDB deployment it rendered a completely BLANK page, table index and all. It now
	' reads information_schema on MySQL/MariaDB, always shows the table index, and says
	' something when it cannot answer.
	If TBName <> "" and Len(TBName) <= 255 Then
		If DEF_UsedDataBase = 0 Then
			DisplayTableColInfo_MSSQL(TBName)
		ElseIf DEF_UsedDataBase = 2 Then
			DisplayTableColInfo_MySQL(TBName)
		Else
			Response.Write "<div class=alert>Access数据库不支持查看表结构!</div>"
		End If
	ElseIf TBName <> "" Then
		Response.Write "<div class=alert>此表不存在!</div>"
	End If
	DisplayTableList()

End Sub

' MySQL / MariaDB: information_schema answers both halves of what SP_SpaceUsed and
' COL_NAME/COL_LENGTH answered on MSSQL.
Function DisplayTableColInfo_MySQL(Name)

	Dim Rs,SQL,GetData,N
	Response.Write "<div class=frametitle>数据库表" & htmlencode(Name) & "结构</div>"
	SQL = "select TABLE_NAME,TABLE_ROWS,DATA_LENGTH,INDEX_LENGTH,DATA_FREE,ENGINE" &_
	      " from information_schema.tables where TABLE_SCHEMA=database() and TABLE_NAME='" &_
	      Replace(LCase(Name),"'","''") & "'"
	Set Rs = LDExeCute(SQL,0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		Response.Write "<div class=alert>此表不存在!</div>"
		Exit Function
	End If
	Response.Write "<div class=frameline>表名：" & htmlencode(Rs(0) & "") & "<br>"
	Response.Write "现有的行数：" & Rs(1) & "<br>"
	Response.Write "表中的数据所使用的空间量：" & Rs(2) & " 字节<br>"
	Response.Write "表中的索引所使用的空间量：" & Rs(3) & " 字节<br>"
	Response.Write "表中未用的空间量：" & Rs(4) & " 字节<br>"
	Response.Write "存储引擎：" & htmlencode(Rs(5) & "") & "</div>"
	Rs.Close
	Set Rs = Nothing

	SQL = "select COLUMN_NAME,COLUMN_TYPE,IFNULL(CHARACTER_MAXIMUM_LENGTH,0)" &_
	      " from information_schema.columns where TABLE_SCHEMA=database() and TABLE_NAME='" &_
	      Replace(LCase(Name),"'","''") & "' order by ORDINAL_POSITION"
	Set Rs = LDExeCute(SQL,0)
	If Not Rs.Eof Then GetData = Rs.GetRows(-1)
	Rs.Close
	Set Rs = Nothing
	Response.Write "<table border=0 cellpadding=0 cellspacing=0 width=100% class=frame_table>"
	If isArray(GetData) = True Then
		For N = 0 to Ubound(GetData,2)
			Response.Write "<tr><td class=tdbox width=200>" & htmlencode(GetData(0,N) & "") &_
				"</td><td class=tdbox>" & htmlencode(GetData(1,N) & "") & "</td></tr>"
		Next
	End If
	Response.Write "</table>"

End Function

Function DisplayTableColInfo_MSSQL(Name)

	Dim Rs,SQL
	Dim N,Tmp,Tmp2
	Response.Write "<div class=frametitle>数据库表" & Name & "结构</div>"
	SQL = "exec SP_SpaceUsed '" & Replace(Name,"'","''") & "'"
	Set Rs = LDExeCute(SQL,0)
	If Not Rs.Eof Then Tmp = Rs.GetRows(-1)
	Rs.Close
	Set Rs = Nothing
	If isArray(Tmp) = True Then
		Response.Write "<div class=frameline>表名：" & Tmp(0,0) & "<br>"
		Response.Write "现有的行数：" & Tmp(1,0) & "<br>"
		Response.Write "保留的空间总量：" & Tmp(2,0) & "<br>"
		Response.Write "表中的数据所使用的空间量：" & Tmp(3,0) & "<br>"
		Response.Write "表中的索引所使用的空间量：" & Tmp(4,0) & "<br>"
		Response.Write "表中未用的空间量：" & Tmp(5,0) & "</div>"
	End If
	Set Tmp = Nothing
	Response.Write "<table border=0 cellpadding=0 cellspacing=0 width=100% class=frame_table>"
	N = 1
	SQL = "Select COL_NAME( OBJECT_ID('" & Replace(Name,"'","''") & "')," & N & "),COL_LENGTH('" & Replace(Name,"'","''") & "',COL_NAME( OBJECT_ID('" & Replace(Name,"'","''") & "') ," & N & "))"
	Set Rs = LDExeCute(SQL,0)
	Tmp = Rs(0)
	Tmp2 = Rs(1)
	Rs.Close
	Set Rs = Nothing
	Do While Not(IsNull(Tmp)) and Len(Tmp) > 0
		Response.Write "<tr><td class=tdbox width=200>" & htmlencode(Tmp) & "</td><td class=tdbox>" & Tmp2 & "</td>"
		N = N + 1
		SQL = "Select COL_NAME( OBJECT_ID('" & Replace(Name,"'","''") & "')," & N & "),COL_LENGTH('" & Replace(Name,"'","''") & "',COL_NAME( OBJECT_ID('" & Replace(Name,"'","''") & "') ," & N & "))"
		Set Rs = LDExeCute(SQL,0)
		Tmp = Rs(0)
		Tmp2 = Rs(1)
		Rs.Close
		Set Rs = Nothing
	Loop
	Response.Write "</table>"

End Function

Function DisplayTableList

	Response.Write "<div class=frameline><a href=TableInfo.asp?tb=LeadBBS_Announce>点击这里查看表LeadBBS_Announce信息</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_Assort>点击这里查看表LeadBBS_Assort</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_Boards>点击这里查看表LeadBBS_Boards</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_CollectAnc>点击这里查看表LeadBBS_CollectAnc</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_ForbidIP>点击这里查看表LeadBBS_ForbidIP</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_FriendUser>点击这里查看表LeadBBS_FriendUser</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_GoodAssort>点击这里查看表LeadBBS_GoodAssort</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_InfoBox>点击这里查看表LeadBBS_InfoBox</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_IPAddress>点击这里查看表LeadBBS_IPAddress</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_Link>点击这里查看表LeadBBS_Link</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_onlineUser>点击这里查看表LeadBBS_onlineUser</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_Setup>点击这里查看表LeadBBS_Setup</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_SiteInfo>点击这里查看表LeadBBS_SiteInfo</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_SpecialUser>点击这里查看表LeadBBS_SpecialUser</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_TopAnnounce>点击这里查看表LeadBBS_TopAnnounce</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_Upload>点击这里查看表LeadBBS_Upload</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_User>点击这里查看表LeadBBS_User</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_UserFace>点击这里查看表LeadBBS_UserFace</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_VoteItem>点击这里查看表LeadBBS_VoteItem</a>"
	Response.Write "<br><a href=TableInfo.asp?tb=LeadBBS_VoteUser>点击这里查看表LeadBBS_VoteUser</a></div>"

End Function%>