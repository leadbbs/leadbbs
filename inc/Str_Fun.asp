<%
Dim BinaryData,BinaryDataNum
BinaryData = Array(1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,2097152,4194304,8388608,16777216,33554432,67108864,134217728,268435456,536870912,1073741824,2147483648)
BinaryDataNum = 32
	
Function GetBinarybit(Number,bit)

	if isNull(Number) Then
		GetBinarybit = 0
		Exit Function
	Else
		Number = cCur(Number)
	End If
	If bit = BinaryDataNum Then
		If Number = BinaryData(bit) Then
			GetBinarybit = 1
		Else
			GetBinarybit = 0
		End If
	Else
		If (cCur(Number) mod BinaryData(bit)) >= BinaryData(bit-1) Then
			GetBinarybit = 1
		Else
			GetBinarybit = 0
		End If
	End if

End Function

Function CodeCookie(str)

	Dim i
	Dim StrRtn
	For i = Len(Str) to 1 Step -1
		StrRtn = StrRtn & Ascw(Mid(Str,i,1))
		If (i <> 1) Then StrRtn = StrRtn & "a"
	Next
	CodeCookie = StrRtn

End Function

Function DecodeCookie(Str)

	Dim i
	Dim StrArr,StrRtn
	StrArr = Split(Str,"a")
	For i = UBound(StrArr) - LBound(StrArr) to 0 Step -1
		If isNumeric(StrArr(i)) = True Then
			StrRtn = StrRtn & Chrw(CLng(StrArr(i)))   ' AxonASP: ChrW does not coerce a numeric STRING; force a number
		Else
			StrRtn = Str
			Exit Function
		End If
	Next
	DecodeCookie = StrRtn

End Function

' README §36: LeadBBS parses its own on-disk data files with Split(content, VbCrLf),
' which silently returns a SINGLE element for an LF-only file — every record collapses
' into one and the trailing field swallows the rest of the file. The port normalised the
' whole tree's line endings to LF, and any Linux editor writing one of these files does
' the same, so the split must not care. Splits on any of CRLF / CR / LF.
Function SplitLines(ByVal S)

	S = Replace(S, VbCrLf, VbLf)
	S = Replace(S, VbCr, VbLf)
	SplitLines = Split(S, VbLf)

End Function

' AxonASP renders a large numeric Double (e.g. a BIGINT id from a GetRows array)
' in scientific notation ("2.26097e+06") when concatenated to a string, which
' corrupts ids embedded in links/URLs. Format such values as a plain integer string.
Function LngStr(v)
	If IsNull(v) Then
		LngStr = ""
	ElseIf IsNumeric(v) Then
		' AxonASP (#26): FormatNumber does NOT coerce a numeric STRING (returns "0"),
		' so convert explicitly first.
		LngStr = Replace(FormatNumber(CDbl(v), 0), ",", "")
	Else
		LngStr = CStr(v)
	End If
End Function

Function RestoreTime(ByVal DateString)

	If isNull(DateString) Then Exit Function
	' AxonASP returns MySQL BIGINT columns as Doubles, so CStr() yields scientific
	' notation (2.026e+13) that breaks the 14-digit YYYYMMDDHHMMSS parse below.
	' Check IsNumeric on the ORIGINAL value (a Double is numeric; its CStr string
	' with e+13 is NOT recognized by IsNumeric) and format it as a plain integer.
	If IsNumeric(DateString) Then
		' AxonASP (#26): FormatNumber returns "0" for a numeric STRING -> CDbl first.
		DateString = Replace(FormatNumber(CDbl(DateString), 0), ",", "")
	Else
		DateString = cstr(DateString)
	End If
	If len(DateString)<8 then
		RestoreTime=DateString
	Else
		If len(DateString)<14 then
			RestoreTime = Mid(DateString,1,4) & "-" & Mid(DateString,5,2) & "-" & Mid(DateString,7,2)
		Else
			RestoreTime = Mid(DateString,1,4) & "-" & Mid(DateString,5,2) & "-" & Mid(DateString,7,2) & " " & Mid(DateString,9,2) & ":" & Mid(DateString,11,2) & ":" & Mid(DateString,13,2)
		End If
	End If

End Function

Function StrLength(str)

	If isNull(str) or Str = "" Then
		StrLength = 0
		Exit function
	End If
	If len("例子") = 2 then
		Dim l,t,c,i
		l=len(str)
		t=l
		for i=1 to l
			c=asc(mid(str,i,1))
			If c<0 then c=c+65536
			If c>255 then
				t=t+1
			End If
		next
		StrLength=t
	Else 
		StrLength=len(str)
	End If
End Function

Function GetTimeValue(DateString)

	Dim Temp,TempStr
	If isNull(DateString) or isTrueDate(DateString) = 0 Then
		GetTimeValue = 0
		Exit Function
	End If
	Temp = CsTr(Year(DateString))
	If Len(temp)<3 Then
		Temp = Left(year(DEF_Now),2) & Temp
	End If
	TempStr = Temp
	
	Temp = CsTr(month(DateString))
	If Len(temp)<2 Then Temp = "0" & Temp
	TempStr = TempStr & Temp

	Temp = CsTr(day(DateString))
	If Len(Temp) < 2 Then Temp = "0" & Temp
	TempStr = TempStr & Temp

	Temp = csTr(Hour(DateString))
	If Len(Temp) < 2 Then Temp = "0" & Temp
	TempStr = TempStr & Temp

	Temp = CsTr(Minute(DateString))
	If Len(Temp) < 2 Then Temp = "0" & Temp
	TempStr = TempStr & Temp

	Temp = CsTr(Second(DateString))
	If Len(Temp) < 2 Then Temp = "0" & Temp
	TempStr = TempStr & Temp

	GetTimeValue = cCur(TempStr)

End Function

Function htmlEncode(str)

	If str & "" <> "" Then
		htmlEncode=Replace(Replace(Replace(Replace(Replace(str,">","&gt;"),"<","&lt;"),"""","&quot;"),"""","&quot;"),"'","&#39;")
		'htmlEncode = server.htmlencode(str)
	Else
		htmlEncode=str
	End If

End Function

Function UrlEncode(str)

	If str & "" <> "" Then
		urlencode = Server.UrlEncode(str)
	Else
		UrlEncode = str
	End If

End Function



rem 显示左边的n个字符(自动识别汉字)
Function LeftTrue(str,n)

	If len(str) <= n/2 Then
		LeftTrue = str
	Else
		Dim TStr,l,t,c,i
		l = len(str)
		TStr = ""
		t = 0
		For i=1 To l
			c = asc(mid(str,i,1))
			If c < 0 then c=c+65536
			If c > 255 then
				t = t+2
			Else
				t = t+1
			End If
			If t > n Then exit for
			TStr = TStr&(mid(str,i,1))
		Next
		LeftTrue = TStr
	End If

End Function

Function isTrueDate(TStr)

	Dim T
	T = TStr
	If isNull(T) Then T = ""
	T = Replace(Replace(Replace(Replace(Replace(Replace(Replace(T,"年","-"),"月","-"),"日"," "),"上午"," "),"下午"," "),"  "," "),"  "," ")
	
	Dim N1,N2
	N1 = inStr(T,"-")
	If N1>0 Then N2 = inStrRev(T,"-")
	If N1 = N2 and N1 >0 Then
		isTrueDate = 0
		Exit Function
	End If

	N1 = inStr(T,":")
	If N1>0 Then N2 = inStrRev(T,"-")
	If N1 = N2 and N1 >0 Then
		isTrueDate = 0
		Exit Function
	End If

	If isDate(TStr) Then
		isTrueDate = 1
	Else
		isTrueDate = 0
	End If

End Function



Function KillHTMLLabel(str)

	Dim n,m,str2
	m = 0
	n = inStr(str,"<")
	if n > 0 Then m = inStr(n,str,">")
	str2 = str
	Do while n > 0 and n < m
		str2 = Left(str2,n-1) & Mid(str2,m+1)
		n = inStr(str2,"<")
		if n > 0 Then m = inStr(n,str2,">")
	Loop
	KillHTMLLabel = str2

End Function

Function LeftTrueHTML(str,Ln)

	Dim n,m,str2,str3,htm,tmp,flag,tmp2,tmp3
	str3 = ""
	htm = ""
	tmp = ""
	flag = 0
	tmp2 = ""
	tmp3 = ""
	n = inStr(Str,"<")
	m = inStr(Str,">")
	str2 = str
	Dim s
	s = 0
	do while(n >= 1 and n < m)
		s=s+1
		if s>100 then exit do
		tmp = Mid(str2,1,n-1)
		If flag = 0 Then
			If StrLength(str3 & tmp) > Ln Then
				flag = 1
				tmp2 = LeftTrue(tmp,Ln-strlength(str3))
				tmp2 = tmp2 & "..."
			Else
				tmp2 = tmp
				str3 = str3 & tmp
			End If
		Else
			tmp2 = ""
		End If
		If flag = 0 Then
			htm = htm & tmp & Mid(str2,n,m-n+1)
		Else
			htm = htm & tmp2 & Mid(str2,n,m-n+1)
		End If
		tmp3 = Mid(str2,m+1)
		str2 = tmp3
		n = inStr(Str2,"<")
		m = inStr(Str2,">")
	Loop
	
	If flag = 0 Then
		If strlength(str3 & tmp3)>Ln Then
			flag = 1
			tmp2 = LeftTrue(tmp3,Ln-strlength(str3))
			tmp2 = tmp2 & "..."
		Else
			tmp2 = tmp3
		End If
	Else
		tmp2 = ""
	End If
	htm = htm + tmp2
	LeftTrueHTML = htm

End Function

Function ADODB_LoadFile(ByVal File)

	On Error Resume Next
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

	On Error Resume Next
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

Function GetSBInfo(Flag)

	Dim Brs,Sys,I,N,Tmp,Str
	Sys = "Unknown"
	Brs = "Unknown"
	Str = Request.ServerVariables("HTTP_USER_AGENT")
	Tmp = LCase(Str)
	'If inStr(Tmp,"http://") > 0 Then
	'	Brs = "Spider"
	'	Sys = "Spider"
	'Else
		I = inStr(Tmp,"msie")
		If I > 0 Then
			N = inStr(I,Tmp,";")
			If N > 0 Then
				Brs = Mid(Str,I,N-i)
				I = inStr(N+1,Tmp,";")
				If I > 0 Then
					Sys = Trim(Mid(Str,N + 1,I-N-1))
				End If
			End If
		Else
			I = inStr(Tmp,"opera")
			If I > 0 Then
				N = inStr(i,Tmp," ")
				If N > 0 Then Brs = Replace(Mid(Str,i,n-i),"/"," ")
				I = inStr(Tmp,"(")
				N = inStr(Tmp,";")
				If N > I and I > 0 Then
					Sys = Mid(Str,I+1,N-I-1)
				End If
			ElseIf inStr(Tmp,"safari") > 0 Then
				I = inStr(Tmp,"version")
				If I > 0 Then
					If inStr(i,Tmp," ")-I-7 > 0 Then Brs = "Safari " & Replace(Mid(Tmp,I + 7,inStr(I,Tmp," ")-I-7),"/","")
				Else
					I = inStr(Tmp,"chrome")
					If I > 0 Then
						If inStr(I,Tmp," ") > I Then
							Brs = Replace(Mid(Tmp,I,inStr(I,Tmp," ")-I),"/"," ")
						End If
					End If
				End If
			ElseIf inStr(Tmp,"wap") > 0 Then
				Brs = "Wap"
				Sys = "Wap"
			Else
				If inStr(Tmp,";")>0 then
					Dim T
					N = split(Str,";")
					
					I = inStr(Tmp,"firefox")
					If I > 0 and Ubound(N) >=2 Then
						Sys = Trim(N(2))
						Brs = Replace(Mid(Str,I,20),"/"," ")
					Else
						If Ubound(N) >=2 Then
							N(2) = Trim(replace(N(2),")",""))
							Brs = Replace(N(2),"/"," ")
						End If
						If Ubound(N) >=1 Then
							N(1) = Trim(N(1))
							Sys = N(1)
						End If
					End If
				End If
			End If
		End If
	'End If
	if lcase(Brs) = "trident 7.0" Then Brs = "IE 11.0"
	If Brs = "Unknown" and inStr(Tmp,"http://") > 0 Then Brs = "Spider"
	If Sys <> "" Then
		If inStr(Tmp,"windows nt 5.0") Then
			Sys = "Windows 2000" 
		Elseif inStr(Tmp,"windows nt 5.1") Then
			Sys = "Windows XP" 
		Elseif inStr(Tmp,"windows nt 5.2") Then
			Sys = "Windows 2003"
		Elseif inStr(Tmp,"windows nt 6.0") Then
			Sys = "Windows Vista" 
		Elseif inStr(Tmp,"windows nt 6.1") Then
			Sys = "Windows 7" 
		Elseif inStr(Tmp,"windows nt 6.2") Then
			Sys = "Windows 8" 
		Elseif inStr(Tmp,"windows vista") Then
			Sys = "Windows Vista" 
		Elseif inStr(Tmp,"windows 4.10") Then
			Sys = "Windows 98" 
		Elseif inStr(Tmp,"windows 98") Then
			Sys = "Windows 98" 
		Elseif inStr(Tmp,"windows me") Then
			Sys = "Windows Me" 
		Elseif inStr(Tmp,"ipad") Then
			Sys = "iPad" 
		Elseif inStr(Tmp,"windows 3.") Then
			Sys = "Windows 3.1" 
		elseif inStr(Tmp,"android") Then	
			I = inStr(Tmp,"android")	
			N = inStr(I,Tmp,";")
			If N > 0 Then
				Sys = Mid(Str,I,N-i)
				Sys = Replace(Replace(Sys,"_","."),";","")
			Else
			Sys = "Android" 
			End If
		Elseif inStr(Tmp,"iphone") Then
			Sys = "iPhone" 
		elseif inStr(Tmp,"mac os x") Then	
			I = inStr(Tmp,"mac os")	
			N = inStr(I,Tmp,";")
			If N > 0 Then
				Sys = Mid(Str,I,N-i)
				Sys = Replace(Replace(Sys,"_","."),";","")
			Else
				Sys = "Mac OS" 
			End If
		End If		
	End If
	
	If Flag = 1 Then
		GetSBInfo = Brs
	Else
		GetSBInfo = Sys
	End If

End Function

Function ConvertTimeString(t)

	Dim Tmp,M
	M = Datediff("n",t,DEF_Now)
	If M > 2880 Then
	ElseIf M > 720 Then
		Select Case Datediff("d",t,DEF_Now)
			Case 0: Tmp = "今天 " & Mid(t,12,5)
			Case 1: Tmp = "昨天 " & Mid(t,12,5)
			Case 2: Tmp = "前天 " & Mid(t,12,5)
			Case Else: Tmp = t
		End Select
	ElseIf M >= 60 Then
		Dim M1
		M1 = M mod 60
		If M1 = 0 Then
			Tmp = Fix(M/60) & "时前"
		Else
			Tmp = Fix(M/60) & "时" & M1 & "分前"
		End If
	ElseIf M >= 1 Then
		Tmp = M & "分前"
	Else
		M = Datediff("s",t,DEF_Now)
		If M >= 0 Then Tmp = M & "秒前"
	End If

	If Tmp = "" Then Tmp = t		
	ConvertTimeString = Tmp

End Function


Function ConvertSimTimeString(t)

	Dim Tmp,M
	M = Datediff("n",t,DEF_Now)
	If M > 2880 Then
		If year(t) <> year(DEF_Now) then
			Tmp = Mid(t,1,10)
		Else
			Tmp = Mid(t,6,11)
		End if
	ElseIf M > 720 Then
		Select Case Datediff("d",t,DEF_Now)
			Case 0: Tmp = "今天 " & Mid(t,12,5)
			Case 1: Tmp = "昨天 " & Mid(t,12,5)
			Case 2: Tmp = "前天 " & Mid(t,12,5)
			Case Else: Tmp = t
		End Select
	ElseIf M >= 60 Then
		Dim M1
		M1 = M mod 60
		If M1 = 0 Then
			Tmp = Fix(M/60) & "时前"
		Else
			Tmp = Fix(M/60) & "时" & M1 & "分前"
		End If
	ElseIf M >= 1 Then
		Tmp = M & "分前"
	Else
		M = Datediff("s",t,DEF_Now)
		If M >= 0 Then Tmp = M & "秒前"
	End If

	If Tmp = "" Then Tmp = t		
	ConvertSimTimeString = Tmp

End Function


Function toNum(s,default)

	if isNumeric(s) = 0 Then
		toNum = default
	else
		toNum = ccur(s)
	end if

End Function

function filterUrlstr(str)

	filterUrlstr = replace(replace(replace(str,"<","%3c"),"""","%22"),"'","%27")

End function

function cCurBit(v)

	if v = true then
		cCurBit = 1
	elseif v = false then
		cCurBit = 0
	end if
	if isNumeric(v) then
		if ccur(v) <> 0 then
			cCurBit = 1
		else
			cCurBit = 0
		end if
	end if

end function

Function CheckSystem

	If Request.QueryString("homesel") = "1" Then
		CheckSystem = 0
		Response.Cookies(DEF_MasterCookies & "homesel") = "1"
		Response.Cookies(DEF_MasterCookies & "homesel").Expires = DateAdd("d",30,DEF_Now)
		Response.Cookies(DEF_MasterCookies & "homesel").Domain = DEF_AbsolutHome
		Exit Function
	End If
	If Request.Cookies(DEF_MasterCookies & "homesel") = "1" then
		CheckSystem = 0
		Exit Function
	End If
	dim sys
	sys = GetSBInfo(0)
	If sys = "iPhone" or left(sys,7) = "Android" Then
		CheckSystem = 1
	Else
		CheckSystem = 0
	End If

End Function

Function GetTrueName(username,truename)

	if truename & "" <> "" then
		GetTrueName = truename
	else
		GetTrueName = username
	end if

End Function

Function GetTrueNameID(username,truename,uid)

	if truename & "" <> "" then
		GetTrueNameID = truename & "#" & uid
	else
		GetTrueNameID = username
	end if

End Function

function convertTrueName(str)

		dim re
		set re = New RegExp
		re.Global = True
		re.IgnoreCase = True
		re.Pattern="\[(.{1,20}?)\#([0-9]{1,20})\]"
		if LMT_EnableRewrite = 0 then
			convertTrueName = re.Replace(str," <a href=" & DEF_BBS_HomeUrl & "User/lookuserinfo.asp?id=$2>$1</a> ")
		else
			convertTrueName = re.Replace(str," <a href=" & DEF_BBS_HomeUrl & "User/$2-a.html>$1</a> ")
		end if
		set re = nothing

end function

function uniDecode(enStr) 

	dim str2 : str2 = enStr
	str2 = split(str2,"\u")
	dim length,i,l
	length = ubound(str2)
	dim s : s = ""
	if length >= 0 then s = str2(0)
	for i = 1 to length
		l = Len(str2(i))
		if l>0 then
			if l<=4 then
				s = s & unescape("%u"&str2(i))
			else
				s = s & unescape("%u"&mid(str2(i),1,4))
				s = s & mid(str2(i),5)
			end if
		end if
	next
	if s <> "" then
		uniDecode = server.htmlencode(s) '特殊转义字符转义
	else
		uniDecode = ""
	end if

end function 

Function GetBinaryString(Number)

	Dim Temp1,Temp2,TempN
	Temp2 = Number
	Temp1 = ""
	For TempN = BinaryDataNum+1 to 1 step -1
		If Temp2 >= BinaryData(TempN-1) Then
			Temp1 = Temp1 & "1"
			Temp2 = Temp2 - BinaryData(TempN-1)
		Else
			Temp1 = Temp1 & "0"
		End If
	Next
	GetBinaryString = Temp1

End Function

Function SetBinarybit(Number,bit,value)

	Dim Temp
	Temp = GetBinarybit(Number,bit)

	If Temp = value Then
		SetBinarybit = Number
	ElseIf Temp = 1 and  value = 0 Then
		SetBinarybit = cCur(Number) - BinaryData(Bit-1)
	ElseIf Temp = 0 and  value = 1 Then
		SetBinarybit = cCur(Number) + BinaryData(Bit-1)
	End If

End Function

Function getUnicode_fun(hanzi)

	Dim str,t,l,tmp,i
	l = len(hanzi)
	t = ""
	for i = 1 to l
		str = mid(hanzi,i,1)
		tmp = Hex(AscW(str))
		if len(tmp)<3 then
			t = t & str
		else
			t = t & "\u" & tmp
		end if
	next
	getUnicode_fun = lcase(t)

End Function

function toJSstrinig(str)

	toJSstrinig = replace(replace(replace(replace(replace(replace(str,"\","\\"),"""","\"""),"script","s\x63ript"),VbCrLf,"\n"),chr(10),""),chr(13),"")

end function

rem js编码转换
function unJsString(str)

	unJsString = replace(unescape(replace(str,"\u","%u")),"\","")

end function

function Reg_Replace(str,patrn,tostr)

	dim regEx,strng
	strng = str
	Set regEx = New RegExp
	regEx.IgnoreCase = True
	regEx.Global = True
	patrn = patrn
	regEx.Pattern = patrn
	strng = regEx.replace(strng,"")
	set regEx = nothing
	Reg_Replace = strng

end function

function LD_GetUrl(dir)

	dim d : d = Request.ServerVariables("server_name")
	dim port : port = Request.ServerVariables("SERVER_PORT")
	if port <> "80" Then d = d & ":" & Server.UrlEncode(port)
	
	if dir = 1 then '返回论坛安装目录
		d = d & DEF_Installdir
	elseif dir = 2 then '返回当前文件url
		dim i : i = Request.ServerVariables("PATH_INFO")
		if i <> "" then
			d = d & i
		else
			d = d & Request.Servervariables("SCRIPT_NAME")
		end if
	else
		d = ""
	end if
	
	dim pl : pl = Request.ServerVariables("SERVER_PROTOCOL")
	dim t
	t = inStr(pl,"/")
	if t > 0 then
		pl = left(LCase(pl), t - 1)
	end if

	' README §52: behind a TLS-terminating reverse proxy (nginx, BunkerWeb, Caddy, a load
	' balancer) AxonASP sees a plain HTTP request -- ServerVariables("HTTPS") is "off" and
	' SERVER_PROTOCOL is HTTP/1.0 -- so every absolute URL the forum handed out came back as
	' http:// on an https:// site: @-mention private messages, RSS, "copy this post's address".
	' The proxy states the real scheme in X-Forwarded-Proto; honour it when it is present, and
	' fall back to the original behaviour when it is not.
	dim s, xfp
	xfp = LCase(Request.ServerVariables("HTTP_X_FORWARDED_PROTO") & "")
	if Request.ServerVariables("HTTPS") = "on" or xfp = "https" then
		s = "s"
	else
		s = ""
	end if
	LD_GetUrl = pl & s & "://" & d

end function

function RW_boards(id)
	if LMT_EnableRewrite = 1 then
		if ccur("0" & id) <1 then
			RW_boards = "boards.html"
		else
			RW_boards = "boards-" & id & ".html"
		end if
	else
		RW_boards = "boards.asp"
		if ccur("0" & id) > 0 then RW_boards = RW_boards & "?assort=" & id
	end if

end function

function RW_b(b,p,more)

	dim s
	dim page : page = p
	if isNumeric(page) then
		if ccur(page) < 1 then page = 1
	end if
	dim m
	m = more
	if left(m,1) = "&" or left(m,1) = "?" then m = mid(m,2)
	if LMT_EnableRewrite = 1 then
		s = "forum-" & b & "-" & page & ".html"
		if m <> "" and m <> "&" then
			s = s & "?" & m
		end if
	else
		if m <> "" then m = "&" & m
		s = "b.asp?b=" & b
		if isNumeric(page) then
			if page > 1 then s = s & "&page=" & page
		else
			s = s & "&page=" & page
		end if
		s = s & m
	end if
	RW_b = s

end function

function RW_a(b,ByVal id,page,bpage,more)

	dim s
	dim m
	id = LngStr(id)   ' AxonASP: a BIGINT id from a GetRows array renders in scientific notation; force plain integer (ByVal so we don't mutate the caller)
	m = more
	if left(m,1) = "&" or left(m,1) = "?" then m = mid(m,2)
	if LMT_EnableRewrite = 1 then
		s = "topic-" & b & "-" & id & "-" & page
		if bpage > 1 then s = s & "-" & bpage
		s =s & ".html"
		if m <> "" then
			s = s & "?" & m
		end if
	else
		s = "a.asp?b=" & b & "&id=" & id
		if isNumeric(page) then
			if page > 1 then s = s & "&page=" & page
		else
			s = s & "&page=" & page
		end if
		if bpage > 1 then s = s & "&q=" & bpage
		if more <> "" then
			s = s & "&" & m
		end if
	end if
	RW_a = s

end function

function RW_User(uid,act,username,more)

	dim userid : userid = ccur("0" & uid)
	dim s
	if LMT_EnableRewrite = 1 then
		if username <> "" and userid < 1 then
			s = "my-a.html?name=" & urlencode(username)
		else
			if userid < 1 then
				s = "my-"
			else
				s = userid & "-"
			end if
			if act = "" then
				s = s & "a"
			else
				s = s & act
			end if
			s = s & ".html"
		end if
		if more <> "" then
			if left(more,1) = "&" then
				s = s & "?" & mid(more,2)
			else
				s = s & "?" & more
			end if
		end if
	else
		if username <> "" and userid < 1 then
			s = "lookuserinfo.asp?name=" & urlencode(username)
		else
			if userid < 1 then
				s = "lookuserinfo.asp"
				if act <> "" then s = s & "?evol=" & act
			else
				s = "lookuserinfo.asp?id=" & userid
				if act <> "" then s = s & "&evol=" & act
			end if
		end if
		if more <> "" then
			dim m
			m = more
			if left(m,1) = "&" then m = mid(m,2)
			if instr(s,"?") > 0 then
				s = s & "&" & m
			else
				s = s & "?" & m
			end if	
		end if
	end if
	RW_User = s

end function


'国内手机号码验证
Function CheckMobilePhone(sPhone)

	Dim regEx
	Set regEx = New RegExp
	regEx.Pattern = "^1(([3458]\d)|(5[123467890]))\d{8}$"
	regEx.Pattern = "^(13[0-9]|15[01237890]|147|18[0569])\d{8}$"
	regEx.IgnoreCase = False
	CheckMobilePhone = regEx.Test(sPhone)
	Set regEx = Nothing

End Function

' ---------------------------------------------------------------------------
' AxonASP (#30): Recordset.GetString IGNORES its ColumnDelimiter / RowDelimiter /
' NullExpr arguments and always emits TAB between columns and a newline between rows.
' LeadBBS uses those delimiters to build JavaScript row callbacks, so the affected
' lists rendered nothing at all. Build the string ourselves, matching ADO: the row
' delimiter is appended after EVERY row, including the last.
Function RsGetString(Rs, ColDelim, RowDelim, NullExpr)
	Dim s, i, v, n
	s = ""
	n = Rs.Fields.Count - 1
	Do While Not Rs.Eof
		For i = 0 To n
			v = Rs(i)
			If IsNull(v) Then v = NullExpr
			s = s & CStr(v)
			If i < n Then s = s & ColDelim
		Next
		s = s & RowDelim
		Rs.MoveNext
	Loop
	RsGetString = s
End Function
%>
