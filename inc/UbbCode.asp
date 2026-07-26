<!-- #include file=../inc/Ubbcode_Setup.asp -->
<%
Function clearUbbcode(str)

	Dim n,m,str2
	str2 = str
	str2 = trim(replace(replace(replace(replace(replace(replace(replace(replace(str,VbCrLf," "),chr(10)," "),chr(13)," "),"[/P][P]"," "),"[p]"," "),"[P]"," "),"[/P]"," "),"[/p]"," "))
	n = inStr(1,str2,"[",0)
	if n > 0 Then
		m = inStr(n + 1,str2,"]",0)
	Else
		m = 0
	End If
	Do while n > 0 and n < m and m > 0
		str2 = Left(str2,n-1) & Mid(str2,m+1)
		n = inStr(1,str2,"[",0)
		if n > 0 Then
			m = inStr(n + 1,str2,"]",0)
		Else
			m = 0
		End If
	Loop
	clearUbbcode = str2

End Function

Function UBB_FiltrateBadWords(tempStr)

	If CheckSupervisorUserName = 1 Then '管理员无需过滤
		UBB_FiltrateBadWords = tempStr
		Exit Function
	End If
	Dim re
	Set re = New RegExp
	re.Global = True
	re.IgnoreCase = True

	Dim Str
	Str = tempStr
	Dim FiltrateBadWordString_Temp,i,Temp_N
	FiltrateBadWordString_Temp = split(FiltrateBadWordString, "|")
	Temp_N = ubound(FiltrateBadWordString_Temp)
	For i = 0 to Temp_N
		'Str = Replace(Str, FiltrateBadWordString_Temp(i), string(len(FiltrateBadWordString_Temp(i)),"*"), 1,-1,0)
		If FiltrateBadWordString_Temp(i) <> "" Then
			re.Pattern="(" & FiltrateBadWordString_Temp(i) & ")"
			Str=re.Replace(Str,string(len(FiltrateBadWordString_Temp(i)),"*"))
		End If
	Next
	Set Re = Nothing
	UBB_FiltrateBadWords = Str

End Function
%>