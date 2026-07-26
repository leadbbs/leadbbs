<%

	Dim m_minyear
	Dim m_maxyear

	m_minyear		= 1950
	m_maxyear		= 2050

	Dim Cal_Dt(99,2)
	Cal_Dt(0,0)=&H2f
	Cal_Dt(0,1)=&H6c
	Cal_Dt(0,2)=&Ha0
	Cal_Dt(1,0)=&H24
	Cal_Dt(1,1)=&Hb5
	Cal_Dt(1,2)=&H50
	Cal_Dt(2,0)=&Hda
	Cal_Dt(2,1)=&H53
	Cal_Dt(2,2)=&H55
	Cal_Dt(3,0)=&H2c
	Cal_Dt(3,1)=&H4d
	Cal_Dt(3,2)=&Ha0
	Cal_Dt(4,0)=&H21
	Cal_Dt(4,1)=&Ha5
	Cal_Dt(4,2)=&Hb0
	Cal_Dt(5,0)=&H57
	Cal_Dt(5,1)=&H45
	Cal_Dt(5,2)=&H73
	Cal_Dt(6,0)=&Haa
	Cal_Dt(6,1)=&H52
	Cal_Dt(6,2)=&Hb0
	Cal_Dt(7,0)=&H1e
	Cal_Dt(7,1)=&Ha9
	Cal_Dt(7,2)=&Ha8
	Cal_Dt(8,0)=&H30
	Cal_Dt(8,1)=&He9
	Cal_Dt(8,2)=&H50
	Cal_Dt(9,0)=&H26
	Cal_Dt(9,1)=&H6a
	Cal_Dt(9,2)=&Ha0
	Cal_Dt(10,0)=&H9b
	Cal_Dt(10,1)=&Hae
	Cal_Dt(10,2)=&Ha6
	Cal_Dt(11,0)=&H2d
	Cal_Dt(11,1)=&Hab
	Cal_Dt(11,2)=&H50
	Cal_Dt(12,0)=&H23
	Cal_Dt(12,1)=&H4b
	Cal_Dt(12,2)=&H60
	Cal_Dt(13,0)=&H18
	Cal_Dt(13,1)=&Haa
	Cal_Dt(13,2)=&He4
	Cal_Dt(14,0)=&Hab
	Cal_Dt(14,1)=&Ha5
	Cal_Dt(14,2)=&H70
	Cal_Dt(15,0)=&H20
	Cal_Dt(15,1)=&H52
	Cal_Dt(15,2)=&H60
	Cal_Dt(16,0)=&H14
	Cal_Dt(16,1)=&Hf2
	Cal_Dt(16,2)=&H63
	Cal_Dt(17,0)=&H27
	Cal_Dt(17,1)=&Hd9
	Cal_Dt(17,2)=&H50
	Cal_Dt(18,0)=&H9d
	Cal_Dt(18,1)=&H5b
	Cal_Dt(18,2)=&H57
	Cal_Dt(19,0)=&H2f
	Cal_Dt(19,1)=&H56
	Cal_Dt(19,2)=&Ha0
	Cal_Dt(20,0)=&H24
	Cal_Dt(20,1)=&H96
	Cal_Dt(20,2)=&Hd0
	Cal_Dt(21,0)=&H1a
	Cal_Dt(21,1)=&H4d
	Cal_Dt(21,2)=&Hd5
	Cal_Dt(22,0)=&Had
	Cal_Dt(22,1)=&H4a
	Cal_Dt(22,2)=&Hd0
	Cal_Dt(23,0)=&H21
	Cal_Dt(23,1)=&Ha4
	Cal_Dt(23,2)=&Hd0
	Cal_Dt(24,0)=&H16
	Cal_Dt(24,1)=&Hd4
	Cal_Dt(24,2)=&Hd4
	Cal_Dt(25,0)=&H29
	Cal_Dt(25,1)=&Hd2
	Cal_Dt(25,2)=&H50
	Cal_Dt(26,0)=&H9e
	Cal_Dt(26,1)=&Hd5
	Cal_Dt(26,2)=&H58
	Cal_Dt(27,0)=&H30
	Cal_Dt(27,1)=&Hb5
	Cal_Dt(27,2)=&H40
	Cal_Dt(28,0)=&H25
	Cal_Dt(28,1)=&Hb6
	Cal_Dt(28,2)=&Ha0
	Cal_Dt(29,0)=&H5b
	Cal_Dt(29,1)=&H95
	Cal_Dt(29,2)=&Ha6
	Cal_Dt(30,0)=&Hae
	Cal_Dt(30,1)=&H95
	Cal_Dt(30,2)=&Hb0
	Cal_Dt(31,0)=&H23
	Cal_Dt(31,1)=&H49
	Cal_Dt(31,2)=&Hb0
	Cal_Dt(32,0)=&H18
	Cal_Dt(32,1)=&Ha9
	Cal_Dt(32,2)=&H74
	Cal_Dt(33,0)=&H2b
	Cal_Dt(33,1)=&Ha4
	Cal_Dt(33,2)=&Hb0
	Cal_Dt(34,0)=&Ha0
	Cal_Dt(34,1)=&Hb2
	Cal_Dt(34,2)=&H7a
	Cal_Dt(35,0)=&H32
	Cal_Dt(35,1)=&H6a
	Cal_Dt(35,2)=&H50
	Cal_Dt(36,0)=&H27
	Cal_Dt(36,1)=&H6d
	Cal_Dt(36,2)=&H40
	Cal_Dt(37,0)=&H1c
	Cal_Dt(37,1)=&Haf
	Cal_Dt(37,2)=&H46
	Cal_Dt(38,0)=&Haf
	Cal_Dt(38,1)=&Hab
	Cal_Dt(38,2)=&H60
	Cal_Dt(39,0)=&H24
	Cal_Dt(39,1)=&H95
	Cal_Dt(39,2)=&H70
	Cal_Dt(40,0)=&H1a
	Cal_Dt(40,1)=&H4a
	Cal_Dt(40,2)=&Hf5
	Cal_Dt(41,0)=&H2d
	Cal_Dt(41,1)=&H49
	Cal_Dt(41,2)=&H70
	Cal_Dt(42,0)=&Ha2
	Cal_Dt(42,1)=&H64
	Cal_Dt(42,2)=&Hb0
	Cal_Dt(43,0)=&H16
	Cal_Dt(43,1)=&H74
	Cal_Dt(43,2)=&Ha3
	Cal_Dt(44,0)=&H28
	Cal_Dt(44,1)=&Hea
	Cal_Dt(44,2)=&H50
	Cal_Dt(45,0)=&H1e
	Cal_Dt(45,1)=&H6b
	Cal_Dt(45,2)=&H58
	Cal_Dt(46,0)=&Hb1
	Cal_Dt(46,1)=&H5a
	Cal_Dt(46,2)=&Hc0
	Cal_Dt(47,0)=&H25
	Cal_Dt(47,1)=&Hab
	Cal_Dt(47,2)=&H60
	Cal_Dt(48,0)=&H1b
	Cal_Dt(48,1)=&H96
	Cal_Dt(48,2)=&Hd5
	Cal_Dt(49,0)=&H2e
	Cal_Dt(49,1)=&H92
	Cal_Dt(49,2)=&He0
	Cal_Dt(50,0)=&Ha3
	Cal_Dt(50,1)=&Hc9
	Cal_Dt(50,2)=&H60
	Cal_Dt(51,0)=&H17
	Cal_Dt(51,1)=&Hd9
	Cal_Dt(51,2)=&H54
	Cal_Dt(52,0)=&H2a
	Cal_Dt(52,1)=&Hd4
	Cal_Dt(52,2)=&Ha0
	Cal_Dt(53,0)=&H1f
	Cal_Dt(53,1)=&Hda
	Cal_Dt(53,2)=&H50
	Cal_Dt(54,0)=&H95
	Cal_Dt(54,1)=&H75
	Cal_Dt(54,2)=&H52
	Cal_Dt(55,0)=&H27
	Cal_Dt(55,1)=&H56
	Cal_Dt(55,2)=&Ha0
	Cal_Dt(56,0)=&H1c
	Cal_Dt(56,1)=&Hab
	Cal_Dt(56,2)=&Hb7
	Cal_Dt(57,0)=&H30
	Cal_Dt(57,1)=&H25
	Cal_Dt(57,2)=&Hd0
	Cal_Dt(58,0)=&Ha5
	Cal_Dt(58,1)=&H92
	Cal_Dt(58,2)=&Hd0
	Cal_Dt(59,0)=&H19
	Cal_Dt(59,1)=&Hca
	Cal_Dt(59,2)=&Hb5
	Cal_Dt(60,0)=&H2c
	Cal_Dt(60,1)=&Ha9
	Cal_Dt(60,2)=&H50
	Cal_Dt(61,0)=&H21
	Cal_Dt(61,1)=&Hb4
	Cal_Dt(61,2)=&Ha0
	Cal_Dt(62,0)=&H96
	Cal_Dt(62,1)=&Hba
	Cal_Dt(62,2)=&Ha4
	Cal_Dt(63,0)=&H28
	Cal_Dt(63,1)=&Had
	Cal_Dt(63,2)=&H50
	Cal_Dt(64,0)=&H1e
	Cal_Dt(64,1)=&H55
	Cal_Dt(64,2)=&Hd9
	Cal_Dt(65,0)=&H31
	Cal_Dt(65,1)=&H4b
	Cal_Dt(65,2)=&Ha0
	Cal_Dt(66,0)=&Ha6
	Cal_Dt(66,1)=&Ha5
	Cal_Dt(66,2)=&Hb0
	Cal_Dt(67,0)=&H5b
	Cal_Dt(67,1)=&H51
	Cal_Dt(67,2)=&H76
	Cal_Dt(68,0)=&H2e
	Cal_Dt(68,1)=&H52
	Cal_Dt(68,2)=&Hb0
	Cal_Dt(69,0)=&H23
	Cal_Dt(69,1)=&Ha9
	Cal_Dt(69,2)=&H30
	Cal_Dt(70,0)=&H98
	Cal_Dt(70,1)=&H79
	Cal_Dt(70,2)=&H54
	Cal_Dt(71,0)=&H2a
	Cal_Dt(71,1)=&H6a
	Cal_Dt(71,2)=&Ha0
	Cal_Dt(72,0)=&H1f
	Cal_Dt(72,1)=&Had
	Cal_Dt(72,2)=&H50
	Cal_Dt(73,0)=&H15
	Cal_Dt(73,1)=&H5b
	Cal_Dt(73,2)=&H52
	Cal_Dt(74,0)=&Ha8
	Cal_Dt(74,1)=&H4b
	Cal_Dt(74,2)=&H60
	Cal_Dt(75,0)=&H1c
	Cal_Dt(75,1)=&Ha6
	Cal_Dt(75,2)=&He6
	Cal_Dt(76,0)=&H2f
	Cal_Dt(76,1)=&Ha4
	Cal_Dt(76,2)=&He0
	Cal_Dt(77,0)=&H24
	Cal_Dt(77,1)=&Hd2
	Cal_Dt(77,2)=&H60
	Cal_Dt(78,0)=&H99
	Cal_Dt(78,1)=&Hea
	Cal_Dt(78,2)=&H65
	Cal_Dt(79,0)=&H2b
	Cal_Dt(79,1)=&Hd5
	Cal_Dt(79,2)=&H30
	Cal_Dt(80,0)=&H21
	Cal_Dt(80,1)=&H5a
	Cal_Dt(80,2)=&Ha0
	Cal_Dt(81,0)=&H16
	Cal_Dt(81,1)=&H76
	Cal_Dt(81,2)=&Ha3
	Cal_Dt(82,0)=&Ha9
	Cal_Dt(82,1)=&H96
	Cal_Dt(82,2)=&Hd0
	Cal_Dt(83,0)=&H1e
	Cal_Dt(83,1)=&H4a
	Cal_Dt(83,2)=&Hfb
	Cal_Dt(84,0)=&H31
	Cal_Dt(84,1)=&H4a
	Cal_Dt(84,2)=&Hd0
	Cal_Dt(85,0)=&H26
	Cal_Dt(85,1)=&Ha4
	Cal_Dt(85,2)=&Hd0
	Cal_Dt(86,0)=&Hdb
	Cal_Dt(86,1)=&Hd0
	Cal_Dt(86,2)=&Hb6
	Cal_Dt(87,0)=&H2d
	Cal_Dt(87,1)=&Hd2
	Cal_Dt(87,2)=&H50
	Cal_Dt(88,0)=&H22
	Cal_Dt(88,1)=&Hd5
	Cal_Dt(88,2)=&H20
	Cal_Dt(89,0)=&H17
	Cal_Dt(89,1)=&Hdd
	Cal_Dt(89,2)=&H45
	Cal_Dt(90,0)=&Haa
	Cal_Dt(90,1)=&Hb5
	Cal_Dt(90,2)=&Ha0
	Cal_Dt(91,0)=&H1f
	Cal_Dt(91,1)=&H56
	Cal_Dt(91,2)=&Hd0
	Cal_Dt(92,0)=&H15
	Cal_Dt(92,1)=&H55
	Cal_Dt(92,2)=&Hb2
	Cal_Dt(93,0)=&H28
	Cal_Dt(93,1)=&H49
	Cal_Dt(93,2)=&Hb0
	Cal_Dt(94,0)=&H9d
	Cal_Dt(94,1)=&Ha5
	Cal_Dt(94,2)=&H77
	Cal_Dt(95,0)=&H2f
	Cal_Dt(95,1)=&Ha4
	Cal_Dt(95,2)=&Hb0
	Cal_Dt(96,0)=&H24
	Cal_Dt(96,1)=&Haa
	Cal_Dt(96,2)=&H50
	Cal_Dt(97,0)=&H59
	Cal_Dt(97,1)=&Hb2
	Cal_Dt(97,2)=&H55
	Cal_Dt(98,0)=&Hac
	Cal_Dt(98,1)=&H6d
	Cal_Dt(98,2)=&H20
	Cal_Dt(99,0)=&H20
	Cal_Dt(99,1)=&Had
	Cal_Dt(99,2)=&Ha0


Function ConvertToNongLi(m_gongli)
	Dim days
	Dim years
	Dim alldays
	Dim result
	
	days	= DaysFromNewYear(m_gongli)	
	alldays = GetDaysFromStart(Year(m_gongli))	
	years   = Year(m_gongli)	
	if days <= alldays Then		
		years = years - 1
		days  = days + GetGongYearDays(years)	
	end if
	days = days - GetDaysFromStart(years)
	result = CalNongDate(years,days)	
	ConvertToNongLi = result
end function


function CalNongDate(years,days)

	Dim resultday,resultyear,resultmonth
	dim caldays,IsRunyue,i
	caldays = 0
	
	resultyear = years
	IsRunyue = false

	for i=1 to 12
		caldays = caldays + GetNotRunNongMonthDays(years,i)	
		if caldays>=days then	
			caldays = caldays - GetNotRunNongMonthDays(years,i)
			resultmonth = i
			resultday = days - caldays
			IsRunyue = false
			exit for
		else
			if GetNongRunYue(years) = i then   
				caldays = caldays + GetNongRunYueDays(years)
				if caldays>=days then
					caldays = caldays - GetNongRunYueDays(years)
					resultmonth = i
					resultday = days - caldays
					IsRunyue = true
					exit for
				end if
			end if
		end if
	next
	CalNongDate=resultyear & "-" & resultmonth & "-" & resultday

end function

function RunYueIsLarge(years)

	RunYueIsLarge = Cal_Dt(years-m_minyear,0) AND &H40

end function

function GetGongYearDays(years)

	if YearIsRunNian(years) then
		GetGongYearDays = 366
	else
		GetGongYearDays = 365
	end if
end function

function GetNongRunYueDays(years)
	if GetNongRunYue(years) =0 then
		GetNongRunYueDays = 0
		exit function
	end if
	if RunYueIsLarge(years) then
		GetNongRunYueDays = 30
	else
		GetNongRunYueDays = 29
	end if
end function

function GetGongMonthDays(years,months)

	GetGongMonthDays = 30
	if months = 2 then
		if YearIsRunNian(years) Then
			GetGongMonthDays = 29
		else
			GetGongMonthDays = 28
		end if
	else
		if GongMonthIsLarge(months) Then
			GetGongMonthDays = 31
		else
			GetGongMonthDays = 30
		end if
	end if

end function

function GetNotRunNongMonthDays(years,months)

	if NongMonthIsLarge(years,months) Then
		GetNotRunNongMonthDays = 30
	else
		GetNotRunNongMonthDays = 29
	end if

end function



function DaysFromNewYear(m_day)

	Dim days,i
	days = 0
	for i=1 to Month(m_day) - 1
		days = days + GetGongMonthDays(year(m_day),i)
	next
	days = days + Day(m_day)
	DaysFromNewYear = days

end function

function Cal2N(n)
	Dim i
	Cal2N = 1
	for i=0 to n - 1
		Cal2N = Cal2N * 2
	next
end function

function YearIsRunNian(years)

	YearIsRunNian = Cal_Dt(years-m_minyear,0) AND &H80

end function

function GetDaysFromStart(years)

	GetDaysFromStart = (Cal_Dt(years-m_minyear,0) AND &H3f)

end function

function NongMonthIsLarge(years,months)

	Dim ch
	NongMonthIsLarge = false
	if(months<9) then
		if(Cal_Dt(years-m_minyear,1) AND Cal2N(8 - months)) then
			NongMonthIsLarge = true
		end if
	else
		ch=Cal2N(12 - months)
		ch=MoveBit(ch)
		if(Cal_Dt(years-m_minyear,2) AND ch) then NongMonthIsLarge = true
	end if
 
end function

function GetNongRunYue(years)

	GetNongRunYue = (Cal_Dt(years-m_minyear,2) AND &H0f)

end function

function GongMonthIsLarge(months)

	GongMonthIsLarge = false
	if months < 8 then
		if (months mod 2) <> 0 then
			GongMonthIsLarge = true
		end if
	else
		if ((months mod 2) = 0) then
			GongMonthIsLarge = true
		end if
	end if

end function

	
Function MoveBit(num)

	MoveBit= num * (2^4)

End Function

Function Constellation(Birth)

	Dim NewBirth
	If Year(NewBirth) <1951 or Year(NewBirth) > 2049 Then Exit Function
	NewBirth = ConvertToNongLi(Birth)
	dim BirthDay,BirthMonth
	BirthDay=day(NewBirth)
	BirthMonth=month(NewBirth)
	Constellation = "<img align=""middle"" src=""../images/" & GBL_DefineImage & "cnstl/z"
	Select Case BirthMonth
	case 1
		if BirthDay>=21 then
			Constellation = Constellation & "11.gif"" title=""水瓶座" & Birth & """ />"
		else
			Constellation = Constellation & "10.gif"" title=""魔羯座" & Birth & """ />"
		end if
	case 2
		if BirthDay>=20 then
			Constellation = Constellation & "12.gif"" title=""双鱼座" & Birth & """ />"
		else
			Constellation = Constellation & "11.gif"" title=""水瓶座" & Birth & """ />"
		end if
	case 3
		if BirthDay>=21 then
			Constellation = Constellation & "1.gif"" title=""白羊座" & Birth & """ />"
		else
			Constellation = Constellation & "12.gif"" title=""双鱼座" & Birth & """ />"
		end if
	case 4
		if BirthDay>=21 then
			Constellation = Constellation & "2.gif"" title=""金牛座" & Birth & """ />"
		else
			Constellation = Constellation & "1.gif"" title=""白羊座" & Birth & """ />"
		end if
	case 5
		if BirthDay>=22 then
			Constellation = Constellation & "3.gif"" title=""双子座" & Birth & """ />"
		else
			Constellation = Constellation & "2.gif"" title=""金牛座" & Birth & """ />"
		end if
	case 6
		if BirthDay>=22 then
			Constellation = Constellation & "4.gif"" title=""巨蟹座" & Birth & """ />"
		else
			Constellation = Constellation & "3.gif"" title=""双子座" & Birth & """ />"
		end if
	case 7
		if BirthDay>=23 then
			Constellation = Constellation & "5.gif"" title=""狮子座" & Birth & """ />"
		else
			Constellation = Constellation & "4.gif"" title=""巨蟹座" & Birth & """ />"
		end if
	case 8
		if BirthDay>=24 then
			Constellation = Constellation & "6.gif"" title=""处女座" & Birth & """ />"
		else
			Constellation = Constellation & "5.gif"" title=""狮子座" & Birth & """ />"
		end if
	case 9
		if BirthDay>=24 then
			Constellation = Constellation & "7.gif"" title=""天秤座" & Birth & """ />"
		else
			Constellation = Constellation & "6.gif"" title=""处女座" & Birth & """ />"
		end if
	case 10
		if BirthDay>=24 then
			Constellation = Constellation & "8.gif"" title=""天蝎座" & Birth & """ />"
		else
			Constellation = Constellation & "7.gif"" title=""天秤座" & Birth & """ />"
		end if
	case 11
		if BirthDay>=23 then
			Constellation = Constellation & "9.gif"" title=""射手座" & Birth & """ />"
		else
			Constellation = Constellation & "8.gif"" title=""天蝎座" & Birth & """ />"
		end if
	case 12
		if BirthDay>=22 then
			Constellation = Constellation & "10.gif"" title=""魔羯座" & Birth & """ />"
		else
			Constellation = Constellation & "9.gif"" title=""射手座" & Birth & """ />"
		end if
	case else
		Constellation=""
	end select
	
	Constellation = Constellation & " " & DisplayBirthAnimal(year(NewBirth))

End Function

Function DisplayBirthAnimal(BirthYear)

	Dim Temp,tmp
	Temp = BirthYear mod 12
	tmp = "<img align=""middle"" src=""../images/" & GBL_DefineImage & "snxa/sx"
	Select Case Temp
		Case 0: tmp=tmp & "2s.gif"" title=""申猴"" />"
		Case 1: tmp=tmp & "10s.gif"" title=""酉鸡"" />"
		Case 2: tmp=tmp & "11s.gif"" title=""戌狗"" />"
		Case 3: tmp=tmp & "12s.gif"" title=""亥猪"" />"
		Case 4: tmp=tmp & "1s.gif"" title=""子鼠"" />"
		Case 5: tmp=tmp & "2s.gif"" title=""丑牛"" />"
		Case 6: tmp=tmp & "2s.gif"" title=""寅虎"" />"
		Case 7: tmp=tmp & "2s.gif"" title=""卯兔"" />"
		Case 8: tmp=tmp & "2s.gif"" title=""辰龙"" />"
		Case 9: tmp=tmp & "2s.gif"" title=""巳蛇"" />"
		Case 10: tmp=tmp & "2s.gif"" title=""午马"" />"
		Case 11: tmp=tmp & "2s.gif"" title=""未羊"" />"
		Case else: tmp = ""
	End Select

	DisplayBirthAnimal = tmp

End Function

Function GetNongLiTimeValue(DateString)

	Dim Temp,TempStr
	If isNumeric(Replace(DateString,"-","")) = False Then
		GetNongLiTimeValue = 0
		Exit Function
	End If
	Temp = Split(DateString,"-")
	If Ubound(Temp) <> 2 Then
		GetNongLiTimeValue = 0
		Exit Function
	End If
	TempStr = Temp(0)

	If Len(Temp(1)) < 2 Then Temp(1) = "0" & Temp(1)
	TempStr = TempStr & Temp(1)

	If Len(Temp(2)) < 2 Then Temp(2) = "0" & Temp(2)
	TempStr = TempStr & Temp(2)

	GetNongLiTimeValue = cCur(TempStr & "000000")

End Function

%>