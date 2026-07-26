<!--#include file="../../inc/BBSSetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
Server.ScriptTimeOut = 600
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass()

Dim GBL_EXEString

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
DisplayUserNavigate("备份数据库")
If GBL_CHK_Flag=1 Then
	LoginAccuessFul()
Else
DisplayLoginForm()
End If
frame_BottomInfo()
closeDataBase()
Manage_Sitebottom("none")


function Copyfiles(tempsource,tempend)

    'on error resume next
    Dim fs
    Set fs = Server.CreateObject(DEF_FSOString)

    If fs.FileExists(tempend) then
       Response.Write "目标备份文件" & tempend & "已存在，请先删除!"
       Set fs=nothing
       Exit Function
    End If
    
    If fs.FileExists(tempsource) then
    Else
       Response.Write "要复制的源数据库文件"&tempsource&"不存在!"
       Set fs=nothing
       Exit Function
    End If
    fs.CopyFile tempsource,tempend
    Response.Write "已经成功复制文件"&tempsource&"到"&tempend&"!"
    Set fs = Nothing

end function

Function DeleteFiles(path)

	If DEF_FSOString = "" Then Exit Function
	on error resume next
	Dim fs
	Set fs = Server.CreateObject(DEF_FSOString)
	If err <> 0 Then
		Err.Clear
		Response.Write "<br>服务器不支持FSO，硬盘备份文件未删除．"
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

Function LoginAccuessFul

	If DEF_FSOString = "" Then
		Response.Write "<p><b>服务器不支持此功能!</b></p>"
		Exit Function
	End If
	If DEF_UsedDataBase = 2 Then
		Call LoginAccuessFul_MySQL()
		Exit Function
	End If
	If DEF_UsedDataBase <> 1 Then
		Response.Write "<p><b>此功能仅对 Access / MySQL 数据库有效!</b></p>"
		Exit Function
	End If
	Dim action
	action = Request.Form("action")
	If action <> "backup" and action <> "delbackup" and action <> "CompactDatabase" Then action = ""
	If action = "" Then
		DisplayStringForm()
	Else
		If action = "backup" Then
			Response.Write "<p><br><br>备份数据库开始，网站暂停一切用户的前台操作......<br>"
			Application.Lock
			application(DEF_MasterCookies & "SiteEnableFlagzoieiu") = 0
			application(DEF_MasterCookies & "SiteDisbleWhyszoieiu") = "论坛暂停中，请稍候几分钟后再来..."
			Application.UnLock
			CloseDatabase()
			Copyfiles Server.Mappath(DEF_BBS_HomeUrl & DEF_AccessDatabase),Server.Mappath(DEF_BBS_HomeUrl & DEF_AccessDatabase & ".BAK")
			OpenDatabase()
			Response.write "<p>备份完成..."
			Application.Lock
			application(DEF_MasterCookies & "SiteEnableFlagzoieiu") = 1
			application(DEF_MasterCookies & "SiteDisbleWhyszoieiu") = ""
			Application.UnLock
			Response.write "<p>网站恢复正常访问..."
		ElseIf action = "delbackup" Then
			Response.Write "<p><br><br>将删除备份数据为文件，如果存在将删除...<br>"
			Deletefiles(Server.Mappath(DEF_BBS_HomeUrl & DEF_AccessDatabase & ".temp"))
			If Deletefiles(Server.Mappath(DEF_BBS_HomeUrl & DEF_AccessDatabase & ".BAK")) = 1 Then
				Response.write "<p>成功删除..."
			Else
				Response.write "<p>备份文件不存在，不需要删除..."
			End If
		Else
			CompactDatabase()
		End If
		Response.Write "<p><br><b>操作完成，<a href=BackupDatabase.asp>点击这里返回</a></b>"
	End If

End Function

Function Deletefiles(path)

    on error resume next
    Dim fs
    Set fs=Server.CreateObject(DEF_FSOString)
    If fs.FileExists(path) Then
      fs.DeleteFile path,True
      deletefiles = 1
    Else
      deletefiles = 0
    End If
    Set fs = nothing
         
End Function

Function CompactDatabase

	on error resume next
	CloseDatabase()
	Dim fs, Engine
	Set fs = CreateObject(DEF_FSOString)
	If fs.FileExists(Server.Mappath(DEF_BBS_HomeUrl & DEF_AccessDatabase)) Then
		Response.Write "<p><br><br>压缩数据库开始，网站暂停一切用户的前台操作......<br>"
		Application.Lock
		'Application.Contents.RemoveAll()
		FreeApplicationMemory()
		application(DEF_MasterCookies & "SiteEnableFlagzoieiu") = 0
		application(DEF_MasterCookies & "SiteDisbleWhyszoieiu") = "论坛暂停中，请稍候几分钟后再来..."
		Application.UnLock
		Set Engine = CreateObject("JRO.JetEngine")
		Engine.CompactDatabase "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & Server.Mappath(DEF_BBS_HomeUrl & DEF_AccessDatabase), "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & Server.Mappath(DEF_BBS_HomeUrl & DEF_AccessDatabase & ".temp")
		If Err Then
			Response.Write "<font color=red class=redfont>数据库压缩失败，可能空间不支持此操作！</font>"
			err.Clear
			Exit Function
		End If
		fs.CopyFile Server.Mappath(DEF_BBS_HomeUrl & DEF_AccessDatabase & ".temp"),Server.Mappath(DEF_BBS_HomeUrl & DEF_AccessDatabase)
		If Err Then
			Response.Write "<font color=red class=redfont>数据库压缩成功，但无法替换原数据库，压缩成功后的数据库名为 " &  Server.Mappath(DEF_BBS_HomeUrl & DEF_AccessDatabase) & ".temp </font>"
			err.Clear
			Exit Function
		End If
		fs.DeleteFile(Server.Mappath(DEF_BBS_HomeUrl & DEF_AccessDatabase & ".temp"))
		If Err Then
			Response.Write "<font color=red class=redfont>数据库压缩成功，并且替换原数据库成功，但删除临时文件失败，请手动删除数据库目录下面的.temp文件！</font>"
			err.Clear
			Exit Function
		End If
		Set fs = Nothing
		Set Engine = nothing
		Response.write "<p>压缩数据库完成..."
		Application.Lock
		application(DEF_MasterCookies & "SiteEnableFlagzoieiu") = 1
		application(DEF_MasterCookies & "SiteDisbleWhyszoieiu") = ""
		Application.UnLock
		Response.write "<p>网站恢复正常访问..."
	Else
		Set fs = Nothing
		Response.Write "<p><br><br>数据库名称或路径不正确. 压缩失败!" & vbCrLf
	End If
	OpenDatabase()

End Function

Function DisplayStringForm

%>
<p>
	数据库将自动备份成BAK文件，备份数据时将暂停网站的任何访问。<br>
	备份时间依数据库大小而定。如果服务器空间不足，可能会引起失败。<br>
	服务器目前的数据库存在于 <b><a href="<%=DEF_BBS_HomeUrl & DEF_AccessDatabase%>"><%=DEF_AccessDatabase%></a></b><br>
	点击备份，系统将自动备份到文件 <b><a href="<%=DEF_BBS_HomeUrl & DEF_AccessDatabase & ".BAK"%>"><%=DEF_AccessDatabase & ".BAK"%></a></b><br>
	<font color=red class=redfont>如果备份文件已经存在请先删除，否则不能开始备份。<br>
	请注意在备份后，下载数据库到本地，然后删除备份的数据库，以防被人恶意下载。</font>
	<p>
	<form action=BackupDatabase.asp method=post>
		<input type=hidden name=action value="backup">
		<input type=submit value=开始备份数据库 class=fmbtn>
	</form>	
	
	<form action=BackupDatabase.asp method=post>
		<input type=hidden name=action value="delbackup">
		<input type=submit value=删除备份数据库 class=fmbtn>
	</form>
	
	<form action=BackupDatabase.asp method=post>
		<input type=hidden name=action value="CompactDatabase">
		<input type=submit value=压缩并修复数据库 class=fmbtn>
	</form>
	
	
	<b><a href="<%=DEF_BBS_HomeUrl & DEF_AccessDatabase & ".BAK"%>">下载备份数据库<%=DEF_AccessDatabase & ".BAK"%></a>
	</b>
	<p>
	<font color=red class=redfont>注意，下载数据库必须选择“备份的数据库”。<br>
	当前网站在运行，下载当前使用的数据库可能将会是损坏的。</font>
	<p>ＰＳ：如果(备份)数据库并非放于WEB下面，是不能直接下载的，请登录ftp服务器进行下传。
	<p><font color=Red class=redfont>警告：<b>压缩并修改数据库</b>功能必然会导致论坛重新启动，并暂停论坛的运行，建议使用备份数据库功能，并下载备份好的数据库，在本地使用Access或其它软件压缩后再作上传替换数据库。期间操作，务必保证论坛处于关闭状态（使用论坛重启功能关闭，并且在其间不访问任何管理页面）。如果发现在压缩数据库后不能上传替换数据库文件，建议再次使用关闭论坛功能。
<%

End Function

Function FreeApplicationMemory

	Response.Write "<p><b>释放论坛数据列表：</b><table>" & VbCrLf
	Dim Thing
	For Each Thing in Application.Contents
		If Left(Thing,Len(DEF_MasterCookies)) = DEF_MasterCookies Then
			Response.Write "<tr><td><font color=Gray class=grayfont>" & thing & "</font></td><td>&nbsp;"
			If isObject(Application.Contents(Thing)) Then
				Application.Contents(Thing).close
				' AxonASP: `Set <indexed> = Nothing` on Application.Contents(x) won't compile; null-assign instead
				Application.Contents(Thing) = null
				Response.Write "对象成功关闭"
			ElseIf isArray(Application.Contents(Thing)) Then
				Application.Contents(Thing) = null
				Response.Write "数组成功释放"
			Else
				Response.Write htmlencode(Application.Contents(Thing))
				Application.Contents(Thing) = null
			End If
			Response.Write "</td></tr>"
		End If
	Next
	Response.Write "</table>"

End Function

' ===================== MySQL / MariaDB backup (AxonASP adaptation) =====================
' The original page only knows how to copy/compact an Access .mdb. On the MySQL/MariaDB
' backend we instead export a plain SQL dump (SHOW CREATE TABLE + escaped INSERTs) with a
' pure-ASP mini-mysqldump, written to data/backup/ and offered for download.

Function LoginAccuessFul_MySQL

	Dim action : action = Request.Form("action")
	If action = "sqlbackup" Then
		Call Backup_MySQL()
		Response.Write "<p><br><b>操作完成，<a href=BackupDatabase.asp>点击这里返回</a></b>"
	ElseIf action = "delsqlbackup" Then
		Call Delete_MySQL_Backup(Request.Form("f"))
		Response.Write "<p><br><b>操作完成，<a href=BackupDatabase.asp>点击这里返回</a></b>"
	Else
		Call DisplayMySQLForm()
	End If

End Function

Function MySQL_BackupDir
	MySQL_BackupDir = Server.MapPath(DEF_BBS_HomeUrl & "data/backup")
End Function

Function SqlEscape(v)
	If IsNull(v) Then
		SqlEscape = "NULL"
	ElseIf IsNumeric(v) And InStr(TypeName(v),"String") = 0 And InStr(TypeName(v),"Date") = 0 Then
		' AxonASP returns MySQL BIGINT as Double -> avoid scientific notation for whole numbers
		If v = Int(v + 0) Then
			SqlEscape = Replace(FormatNumber(v, 0), ",", "")
		Else
			SqlEscape = CStr(v)
		End If
	Else
		Dim s : s = CStr(v)
		s = Replace(s, "\", "\\")
		s = Replace(s, "'", "\'")
		s = Replace(s, Chr(13), "\r")
		s = Replace(s, Chr(10), "\n")
		s = Replace(s, Chr(0), "")
		SqlEscape = "'" & s & "'"
	End If
End Function

Sub Backup_MySQL

	On Error Resume Next
	Dim fso : Set fso = Server.CreateObject(DEF_FSOString)
	Dim d : d = MySQL_BackupDir()
	If Not fso.FolderExists(d) Then fso.CreateFolder(d)
	Dim ts : ts = Replace(FormatNumber(GetTimeValue(DEF_Now), 0), ",", "")
	Dim fname : fname = "leadbbs_" & ts & ".sql"
	Dim fpath : fpath = d & "/" & fname

	Dim Rs, tables(), nt
	nt = -1
	ReDim tables(500)
	Set Rs = LDExeCute("SHOW TABLES", 0)
	Do While Not Rs.Eof
		nt = nt + 1
		tables(nt) = Rs(0) & ""
		Rs.MoveNext
	Loop
	Rs.Close : Set Rs = Nothing

	Response.Write "<p><br>开始备份 MySQL/MariaDB 数据库（共 " & (nt + 1) & " 张表）...<br>"

	Dim S : Set S = Server.CreateObject("ADODB.Stream")
	S.Type = 2 : S.Charset = "utf-8" : S.Open
	S.WriteText "-- LeadBBS MySQL/MariaDB backup " & Now & VbCrLf
	S.WriteText "SET NAMES utf8mb4;" & VbCrLf
	S.WriteText "SET FOREIGN_KEY_CHECKS=0;" & VbCrLf & VbCrLf

	Dim i, RsC, RsD, line, j, nc, rows
	For i = 0 To nt
		S.WriteText "-- ---------- Table `" & tables(i) & "` ----------" & VbCrLf
		S.WriteText "DROP TABLE IF EXISTS `" & tables(i) & "`;" & VbCrLf
		Set RsC = LDExeCute("SHOW CREATE TABLE `" & tables(i) & "`", 0)
		If Not RsC.Eof Then S.WriteText (RsC(1) & "") & ";" & VbCrLf
		RsC.Close : Set RsC = Nothing

		Set RsD = LDExeCute("SELECT * FROM `" & tables(i) & "`", 0)
		nc = -1
		If Not RsD.Eof Then nc = RsD.Fields.Count - 1
		rows = 0
		Do While Not RsD.Eof
			line = "INSERT INTO `" & tables(i) & "` VALUES ("
			For j = 0 To nc
				If j > 0 Then line = line & ","
				line = line & SqlEscape(RsD.Fields(j).Value)
			Next
			S.WriteText line & ");" & VbCrLf
			rows = rows + 1
			RsD.MoveNext
		Loop
		RsD.Close : Set RsD = Nothing
		S.WriteText VbCrLf
		Response.Write "&nbsp;&nbsp;" & tables(i) & " (" & rows & " 行)<br>"
	Next
	S.WriteText "SET FOREIGN_KEY_CHECKS=1;" & VbCrLf
	S.SaveToFile fpath, 2
	S.Close : Set S = Nothing

	If Err Then
		Response.Write "<font color=red class=redfont>备份出错：" & Err.Description & "</font>"
		Err.Clear
	Else
		Call Backup_ManifestAdd(fname)
		Response.Write "<p><b>备份完成</b>，已保存到 <b>data/backup/" & fname & "</b>"
	End If
	Set fso = Nothing

End Sub

Function DisplayMySQLForm
	%>
	<p>将当前 MySQL/MariaDB 数据库导出为一个 SQL 文件（含建表语句与数据），可下载到本地保存或用于恢复。<br>
	备份文件保存在服务器的 <b>data/backup/</b> 目录下。<br>
	<font color=red class=redfont>请在备份后及时下载并删除服务器上的备份文件，以防被恶意下载。</font>
	<p>
	<form action=BackupDatabase.asp method=post>
		<input type=hidden name=action value="sqlbackup">
		<input type=submit value="导出备份 SQL 文件" class=fmbtn>
	</form>
	<p><b>已有的备份文件：</b>
	<%
	Dim fso2 : Set fso2 = Server.CreateObject(DEF_FSOString)
	Dim d2 : d2 = MySQL_BackupDir()
	Dim any2 : any2 = 0
	Dim names2 : names2 = Backup_FileNames()
	If names2 <> "" Then
		Dim nm, arr2, i2
		arr2 = Split(names2, "|")
		For i2 = 0 To UBound(arr2)
			nm = arr2(i2)
			If nm <> "" Then
				any2 = 1
				Dim sz2 : sz2 = 0
				If fso2.FileExists(d2 & "/" & nm) Then sz2 = fso2.GetFile(d2 & "/" & nm).Size
				%><br><a href="<%=DEF_BBS_HomeUrl%>data/backup/<%=nm%>"><%=nm%></a> (<%=sz2%> 字节)
				<form action=BackupDatabase.asp method=post style="display:inline;margin-left:8px;">
				<input type=hidden name=action value="delsqlbackup"><input type=hidden name=f value="<%=nm%>">
				<input type=submit value="删除" class=fmbtn></form><%
			End If
		Next
	End If
	If any2 = 0 Then Response.Write "<br>（暂无备份文件）"
	Set fso2 = Nothing
	%>
	<%
End Function


' ---------------------------------------------------------------------------
' AxonASP #33: FileSystemObject caches a folder's listing. GetFolder(dir).Files
' returns the snapshot taken at the first enumeration, so a dump written during
' this server lifetime is INVISIBLE to the listing until a restart — you could
' create a backup and then neither download nor delete it. FileExists/GetFile
' are NOT affected, so keep our own manifest and stat each entry live.
' ---------------------------------------------------------------------------
Function Backup_ManifestPath
	Backup_ManifestPath = MySQL_BackupDir() & "/index.txt"
End Function

Sub Backup_ManifestAdd(fname)
	On Error Resume Next
	Dim fso : Set fso = Server.CreateObject(DEF_FSOString)
	Dim f : Set f = fso.OpenTextFile(Backup_ManifestPath(), 8, True)
	f.WriteLine fname
	f.Close
	Set fso = Nothing
End Sub

' Names from the manifest that still exist on disk, newest first, plus anything the
' (possibly stale) folder listing knows about that the manifest does not.
Function Backup_FileNames
	On Error Resume Next
	Dim fso : Set fso = Server.CreateObject(DEF_FSOString)
	Dim seen : seen = "|"
	Dim outp : outp = ""
	Dim mp : mp = Backup_ManifestPath()
	If fso.FileExists(mp) Then
		Dim f : Set f = fso.OpenTextFile(mp, 1)
		Dim line
		Do While Not f.AtEndOfStream
			line = Trim(f.ReadLine)
			If line <> "" And InStr(seen, "|" & line & "|") = 0 Then
				If fso.FileExists(MySQL_BackupDir() & "/" & line) Then
					seen = seen & line & "|"
					outp = line & "|" & outp
				End If
			End If
		Loop
		f.Close
	End If
	Dim d : d = MySQL_BackupDir()
	If fso.FolderExists(d) Then
		Dim f3
		For Each f3 In fso.GetFolder(d).Files
			If LCase(f3.Name) <> "index.txt" And InStr(seen, "|" & f3.Name & "|") = 0 Then
				seen = seen & f3.Name & "|"
				outp = outp & f3.Name & "|"
			End If
		Next
	End If
	Set fso = Nothing
	Backup_FileNames = outp
End Function

Sub Delete_MySQL_Backup(fname)
	On Error Resume Next
	' guard against path traversal - only a bare filename in the backup dir
	If fname = "" Or InStr(fname, "..") > 0 Or InStr(fname, "/") > 0 Or InStr(fname, "\") > 0 Then Exit Sub
	Dim fso : Set fso = Server.CreateObject(DEF_FSOString)
	Dim p : p = MySQL_BackupDir() & "/" & fname
	If fso.FileExists(p) Then
		fso.DeleteFile p, True
		Response.Write "<p>已删除备份文件 " & fname
	End If
	Set fso = Nothing
End Sub
%>