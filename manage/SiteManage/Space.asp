<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Upload_Setup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = GBL_UserID

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("论坛空间占用情况")
If GBL_CHK_Flag=1 Then
	LoginAccuessFul()
Else
DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")

Function LoginAccuessFul%>

<table width="97%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td>
	<%If CheckSupervisorUserName() = 1 Then%>
              <%DisplaySystemInfo()%>
              <br><br>
	<%Else%>
	       <p><br>
              已经成功登录！<br></p>
              <br><br>
              
	<%End If%>
	<br><br>
            </td>
        </tr>
      </table>

<%End Function

Function DisplaySystemInfo

	If Request.QueryString("need") = "1" and DEF_UsedDataBase = 0 Then
		DisplaySQLDatabaseSize()
		Exit Function
	End If

	Dim BBS_Space,Upload_Space,Database_Space,FS

	'On Error Resume Next
	Dim FSFlag
	FSFlag = 1
	If DEF_FSOString <> "" Then
		Set fs = CreateObject(DEF_FSOString)
		If err <> 0 Then
			Err.Clear
			FSFlag = 0
		End If
		Set Fs = Nothing
	End If
	If DEF_FSOString <> "" and FSFlag = 1 Then
		dim f,fso
		Set fso = CreateObject(DEF_FSOString) 
	'	Set f = fso.GetFolder(Server.Mappath(DEF_BBS_HomeUrl)) 
	'	BBS_Space = f.Size
	'	Set f = Nothing
	'	Set f = fso.GetFolder(Server.Mappath(Replace(Replace(DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl,"/","\"),"\\","\"))) 
	'	Upload_Space = f.Size
	'	Set f = Nothing
		If DEF_UsedDataBase = 1 Then
			Set f = fso.GetFile(Server.Mappath(Replace(Replace(DEF_BBS_HomeUrl & DEF_AccessDatabase,"/","\"),"\\","\")))
			Database_Space = f.Size
			Set f = Nothing
		End If
		Set fso = Nothing
	Else
		Response.Write "<br><br><font color=Red class=redfont>论坛关闭FSO功能，查看占用空间失败．</font><br>" & VbCrLf
		BBS_Space = 0
		Upload_Space = 0
		Database_Space = 0
		Exit Function
	End If

	'Response.Write "论坛目录总占用空间：<font color=red class=redfont>" & PrintSpaceValue(BBS_Space) & "</font> [" & BBS_Space & " Bytes]<br>"
	'Response.Write "上传文件总占用空间：<font color=red class=redfont>" & PrintSpaceValue(Upload_Space) & "</font> [" & Upload_Space & " Bytes]<br>"
	select case DEF_UsedDataBase
		case 1:
			Response.Write "<div class=frameline>论坛数据库文件大小：<span class=redfont>" & PrintSpaceValue(Database_Space) & "</span> [" & Database_Space & " Bytes]</div>"
		case 0:
			DisplaySQLDatabaseSize()
		case 2:
			DisplayMySQLDatabaseSize()
	End select

End Function

Function DisplaySQLDatabaseSize

		Dim Rs,Count,SQL,DBName
		
		SQL = "Select DB_NAME(DB_ID())"
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			DBName = ""
		Else
			DBName = Rs(0)
		End If
		Rs.Close
		Set Rs = Nothing
		Set Rs = Server.CreateObject("ADODB.RecordSet")
		Set Rs = LDExeCute("exec sp_databases",0)
		%>
		<div class="frameline">服务器各数据库占用空间如下：</div>
		<%
		Count = 0
		Do while Not Rs.Eof
			If Rs(0) = DBName Then
				%>
				<div class="frameline">数据库<span class=bluefont><%=Rs(0)%></span>，占用空间<span class=greenfont><%=Rs(1)%></span>KB</div>
				<%
				Count = cCur(Rs(1))
				Exit Do
			End If
			Rs.MoveNext
		Loop
		Rs.Close
		Set Rs = Nothing%>
		<div class="frameline">总共占用空间<%=Count%>KB</div><%

End Function

Sub DisplayMySQLDatabaseSize

		Dim Rs,Count,SQL,DBName
		SQL = "Select database()"
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			DBName = ""
		Else
			DBName = Rs(0)
		End If
		Rs.Close
		Set Rs = Nothing

		SQL = "use information_schema "
		call LDExeCute(SQL,1)
		Set Rs = LDExeCute("SELECT TABLE_NAME,DATA_LENGTH FROM  TABLES  WHERE table_schema='" & replace(DBName,"'","''") & "'",0)
		%>
		<div class="frameline">数据库各表占用空间如下：</div>
		<%
		Count = 0
		dim size
		Do while Not Rs.Eof
			size = ccur(Rs(1))/1024/1024
			If Size < 1 Then
				size = "<1"
			Else
				size = FormatNumber(size,0,-1)
			End If
			%>
			<div class="frameline"><span class=bluefont><%=Rs(0)%></span>，占用空间 <span class=greenfont><%=size%> </span>MB</div>
			<%
			Count = Count + cCur(Rs(1))
			Rs.MoveNext
		Loop
		Rs.Close
		Set Rs = Nothing%>
		<div class="frameline">总共占用空间 <%=FormatNumber(Count/1024/1024,0,-1)%> MB</div><%

End Sub

Function PrintSpaceValue(vv)

	Dim v
	v = vv
	If v > 1024*1024 Then
		v = v/1024/1024
		If inStr(v,".") Then
			v = Left(v,inStr(v,".")+2)
		End If
		v = v & " M"
	Else
		v = Fix(v/1024) & " K"
	End If
	PrintSpaceValue = v

End Function
%>