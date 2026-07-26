<%
Function Constellation(Births)

	Dim Birth
	Birth = Births
	dim BirthDay,BirthMonth
	BirthDay=day(Birth)
	BirthMonth=month(Birth)
	Constellation = "<img src=""" & DEF_BBS_HomeUrl & "images/" & GBL_DefineImage & "cnstl/z"
	Select Case BirthMonth
	case 1
		if BirthDay>=21 then
			Constellation = Constellation & "11.gif"" title=""Ë®Æ¿×ù"" align=middle />"
		else
			Constellation = Constellation & "10.gif"" title=""Ä§ôÉ×ù"" align=middle />"
		end if
	case 2
		if BirthDay>=20 then
			Constellation = Constellation & "12.gif"" title=""Ë«Óã×ù"" align=middle />"
		else
			Constellation = Constellation & "11.gif"" title=""Ë®Æ¿×ù"" align=middle />"
		end if
	case 3
		if BirthDay>=21 then
			Constellation = Constellation & "1.gif"" title=""°×Ñò×ù"" align=middle />"
		else
			Constellation = Constellation & "12.gif"" title=""Ë«Óã×ù"" align=middle />"
		end if
	case 4
		if BirthDay>=21 then
			Constellation = Constellation & "2.gif"" title=""½ðÅ£×ù"" align=middle />"
		else
			Constellation = Constellation & "1.gif"" title=""°×Ñò×ù"" align=middle />"
		end if
	case 5
		if BirthDay>=22 then
			Constellation = Constellation & "3.gif"" title=""Ë«×Ó×ù"" align=middle />"
		else
			Constellation = Constellation & "2.gif"" title=""½ðÅ£×ù"" align=middle />"
		end if
	case 6
		if BirthDay>=22 then
			Constellation = Constellation & "4.gif"" title=""¾ÞÐ·×ù"" align=middle />"
		else
			Constellation = Constellation & "3.gif"" title=""Ë«×Ó×ù"" align=middle />"
		end if
	case 7
		if BirthDay>=23 then
			Constellation = Constellation & "5.gif"" title=""Ê¨×Ó×ù"" align=middle />"
		else
			Constellation = Constellation & "4.gif"" title=""¾ÞÐ·×ù"" align=middle />"
		end if
	case 8
		if BirthDay>=24 then
			Constellation = Constellation & "6.gif"" title=""´¦Å®×ù"" align=middle />"
		else
			Constellation = Constellation & "5.gif"" title=""Ê¨×Ó×ù"" align=middle />"
		end if
	case 9
		if BirthDay>=24 then
			Constellation = Constellation & "7.gif"" title=""Ìì³Ó×ù"" align=middle />"
		else
			Constellation = Constellation & "6.gif"" title=""´¦Å®×ù"" align=middle />"
		end if
	case 10
		if BirthDay>=24 then
			Constellation = Constellation & "8.gif"" title=""ÌìÐ«×ù"" align=middle />"
		else
			Constellation = Constellation & "7.gif"" title=""Ìì³Ó×ù"" align=middle />"
		end if
	case 11
		if BirthDay>=23 then
			Constellation = Constellation & "9.gif"" title=""ÉäÊÖ×ù"" align=middle />"
		else
			Constellation = Constellation & "8.gif"" title=""ÌìÐ«×ù"" align=middle />"
		end if
	case 12
		if BirthDay>=22 then
			Constellation = Constellation & "10.gif"" title=""Ä§ôÉ×ù"" align=middle />"
		else
			Constellation = Constellation & "9.gif"" title=""ÉäÊÖ×ù"" align=middle />"
		end if
	case else
		Constellation=""
	end select

End Function

Function DisplayBirthAnimal(BirthYear)

	Dim Temp,tmp
	Temp = BirthYear mod 12
	tmp = "<img src=""" & DEF_BBS_HomeUrl & "images/" & GBL_DefineImage & "snxa/sx"
	Select Case Temp
		Case 0: tmp=tmp & "9s.gif"" align=middle title=""Éêºï"" />"
		Case 1: tmp=tmp & "10s.gif"" align=middle title=""ÓÏ¼¦"" />"
		Case 2: tmp=tmp & "11s.gif"" align=middle title=""Ðç¹·"" />"
		Case 3: tmp=tmp & "12s.gif"" align=middle title=""º¥Öí"" />"
		Case 4: tmp=tmp & "1s.gif"" align=middle title=""×ÓÊó"" />"
		Case 5: tmp=tmp & "2s.gif"" align=middle title=""³óÅ£"" />"
		Case 6: tmp=tmp & "3s.gif"" align=middle title=""Òú»¢"" />"
		Case 7: tmp=tmp & "4s.gif"" align=middle title=""Ã®ÍÃ"" />"
		Case 8: tmp=tmp & "5s.gif"" align=middle title=""³½Áú"" />"
		Case 9: tmp=tmp & "6s.gif"" align=middle title=""ËÈÉß"" />"
		Case 10: tmp=tmp & "7s.gif"" align=middle title=""ÎçÂí"" />"
		Case 11: tmp=tmp & "8s.gif"" align=middle title=""Î´Ñò"" />"
		Case else: tmp = ""
	End Select
	
	DisplayBirthAnimal = tmp

End Function

%>