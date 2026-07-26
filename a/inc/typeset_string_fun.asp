<%
function ld_clearfontstyle(str)

	dim T
	T = str

	T = Reg_Replace(T,"\[LINE\-HEIGHT=(normal|[\.\%ptx0-9]{1,5})\]","")
	T = Reg_Replace(T,"\[\/line\-height\]","")
	T = Reg_Replace(T,"\[align=(left|center|right|justify)\]","")
	
	T = Reg_Replace(T,"\[\/align\]","")
	T = Reg_Replace(T,"\[size=([0-9]{1,1})\]","")
	T = Reg_Replace(T,"\[size=([a-z0-9\-\%]{1,25})\]","")
	T = Reg_Replace(T,"\[face=(.+?)\]","")
	T = Reg_Replace(T,"\[\/(color|size|face|font|bgcolor)\]","")
	T = Reg_Replace(T,"\[color=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\]","")
	T = Reg_Replace(T,"\[BGCOLOR=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\]","")
	T = Reg_Replace(T,"\[BGCOLOR=([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\)),([#a-z0-9]{1,12}|rgb\([0-9\,\ ]{1,20}\))\]","")
	ld_clearfontstyle = T

end function

function ld_typeset(str,htmlflag)

			dim kill_headspace
			If request.form("kill_headspace") = "yes" then
				kill_headspace = 1
			else
				kill_headspace = 0
			end if
			dim kill_lineheight
			If request.form("kill_lineheight") = "yes" then
				kill_lineheight = 1
			else
				kill_lineheight = 0
			end if

			Dim NewTemp,N,I,moredataArray,tm,Tmp,fullstop,tm2,splitflag
			NewTemp = str
			fullstop = "|?|£¿|.|¡£|¡®|;|£»|!|:|£º|£¡|`|`£à|¡±|¡°|""|¡­|"
			If htmlflag = 2 Then
				if kill_lineheight = 1 then
					NewTemp = ld_clearfontstyle(NewTemp)
				end if
				NewTemp = Replace(NewTemp,"[p]","[P]")
			end if
			moredataArray = split(NewTemp,VbCrLf)
			I = Ubound(moredataArray,1)
			NewTemp = ""
			moredataArray(0) = Trim(moredataArray(0))
			If kill_headspace = 1 then
				moredataArray(0) = trim(moredataArray(0))
			else
				If Left(moredataArray(0),1) <> "¡¡" and (htmlflag <> 2 or Left(moredataArray(0),3) <> "[P]") Then
					If Left(moredataArray(0),2) <> "¡¡¡¡" Then
						moredataArray(0) = "¡¡¡¡" & moredataArray(0)
					Else
						moredataArray(0) = "¡¡" & moredataArray(0)
					End If
				End If
			end if
				
			NewTemp = moredataArray(0)
			splitflag = 0
			dim Rstr
			
			For N = 0 to I-1
				If kill_headspace = 1 then
					moredataArray(N) = "¡¡¡¡" & LD_RTrim(LD_Ltrim(moredataArray(N)))
				else
					Rstr = right(moredataArray(N),1)
					do While Rstr = "¡¡" or Rstr = " "
						moredataArray(N) = left(moredataArray(N),len(moredataArray(N))-1)
						Rstr = right(moredataArray(N),1)
					loop
				end if
				tm = clearUbbcode(Trim(Replace(moredataArray(N),chr(9),"      ")))
				Tmp = right(tm,1)
				If inStr(fullstop,"|" & Tmp & "|") or splitflag = 1 Then
					If inStr(fullstop,"|" & Tmp & "|") Then splitflag = 1
					tm2 = clearUbbcode(Trim(Replace(moredataArray(N+1),chr(9),"      ")))
					If kill_headspace = 1 then
						moredataArray(N) = "¡¡¡¡" & LD_RTrim(LD_Ltrim(moredataArray(N)))
					else
						Rstr = right(tm2,1)
						do While Rstr = "¡¡" or Rstr = " "
							tm2 = left(tm2,len(tm2)-1)
							Rstr = right(tm2,1)
						loop
					end if
					if tm2 <> "" Then
						splitflag = 0
						moredataArray(N+1) = Trim(moredataArray(N+1))
						If kill_headspace = 1 then
							moredataArray(N+1) = "¡¡¡¡" & LD_RTrim(LD_Ltrim(moredataArray(N+1)))
						else
							If Left(moredataArray(N+1),1) <> "¡¡" and (htmlflag <> 2 or Left(moredataArray(N+1),3) <> "[P]") Then
								If Left(moredataArray(N+1),2) <> "¡¡¡¡" Then
									moredataArray(N+1) = "¡¡¡¡" & moredataArray(N+1)
								Else
									moredataArray(N+1) = "¡¡" & moredataArray(N+1)
								End If
							End If
						end if
						If inStr(fullstop,"|" & Tmp & "|") Then NewTemp = NewTemp & VbCrLf
						If tm="" or isNull(tm) Then
							NewTemp = NewTemp & VbCrLf & moredataArray(N+1)
						Else
							NewTemp = Rtrim(NewTemp) & VbCrLf & moredataArray(N+1)
						End If
					Else
						NewTemp = NewTemp & VbCrLf & moredataArray(N+1)
					End If
				Else
					tm = Left(moredataArray(N+1),1)
					If tm <> " " and tm <> "¡¡" and tm <> chr(9) and tm <> "" and len(moredataArray(N)) > 25 Then
						NewTemp = NewTemp & moredataArray(N+1)
					Else
						moredataArray(N+1) = "¡¡¡¡" & LD_RTrim(LD_Ltrim(moredataArray(N+1)))
						If kill_headspace = 1 then
							moredataArray(N+1) = "¡¡¡¡" & trim(moredataArray(N+1))
						else
							If Left(moredataArray(N+1),1) <> "¡¡" and (htmlflag <> 2 or Left(moredataArray(N+1),3) <> "[P]") Then
								If Left(moredataArray(N+1),2) <> "¡¡¡¡" Then
									moredataArray(N+1) = "¡¡¡¡" & moredataArray(N+1)
								Else
									moredataArray(N+1) = "¡¡" & moredataArray(N+1)
								End If
							End If
						end if
						NewTemp = NewTemp & VbCrLf & moredataArray(N+1)
					End If
				End If
			Next
			
			If kill_lineheight = 1 then
				dim critBr
				critBr = instr(NewTemp,VbCrLf & VbCrLf)
				do while critBr > 0
					NewTemp = replace(NewTemp,VbCrLf & VbCrLf,VbCRLf)
					critBr = instr(NewTemp,VbCrLf & VbCrLf)
				Loop
			end if
			'split [p]
			If htmlflag = 2 Then
				moredataArray = split(Replace(NewTemp,"[p]","[P]"),"[P]")
				I = Ubound(moredataArray,1)
				NewTemp = ""
				Dim addflag
				For N = 0 to I
					tm = clearUbbcode(Replace(moredataArray(N),chr(9),"      "))
					Tmp = left(tm,2)
					
					addflag = 0
					If Replace(Replace(tm,"¡¡","")," ","") <> "" Then
						If kill_headspace = 1 then
							If N = 0 then
								NewTemp = NewTemp & "¡¡¡¡" & trim(moredataArray(N))
							else
								NewTemp = NewTemp & "[P]¡¡¡¡" & trim(moredataArray(N))
							end if
							addflag = 1
						else
							If Tmp <> "¡¡¡¡" and Tmp <> "  " and Tmp <> "¡¡ " and Tmp <> " ¡¡" Then
								If N = 0 Then
									NewTemp = NewTemp & "¡¡¡¡" & moredataArray(N)
								Else
									NewTemp = NewTemp & "[P]¡¡¡¡" & moredataArray(N)
								End If
								addflag = 1
							End If
						end if
					End If
					
					If addflag = 0 Then
						If N = 0 Then
							NewTemp = NewTemp & moredataArray(N)
						Else
							NewTemp = NewTemp & "[P]" & moredataArray(N)
						End If
					End If
				Next
			End If
			ld_typeset = NewTemp
			
end function

function LD_Rtrim(s)

	dim tm2,Rstr
	tm2 = s
	Rstr = right(tm2,1)
	do While Rstr = "¡¡" or Rstr = " " or Rstr = chr(9)
		tm2 = left(tm2,len(tm2)-1)
		Rstr = right(tm2,1)
	loop
	LD_Rtrim = tm2

end function

function LD_Ltrim(s)

	dim tm2,Rstr
	tm2 = s
	Rstr = left(tm2,1)
	do While Rstr = "¡¡" or Rstr = " " or Rstr = chr(9)
		tm2 = right(tm2,len(tm2)-1)
		Rstr = left(tm2,1)
	loop
	LD_Ltrim = tm2

end function
%>