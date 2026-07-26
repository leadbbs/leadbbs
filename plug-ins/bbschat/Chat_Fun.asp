<%
Chat_init_Application
Chat_init_session

Sub Chat_init_Application

	'If Application(DEF_MasterCookies & "_Chat_Load") <> "1" Then
	'	Response.Write "错误，聊天系统需要虚拟目录或独立站点支持才能正常运行．"
	'	Response.End
	'End If
	
	If Application(DEF_MasterCookies & "_Chat_Load") <> "1" Then
		Dim Temp
		Redim Temp(Chat_MaxCache)

		Application.Lock
		Application(DEF_MasterCookies & "_Chat_World") = Temp
		Application(DEF_MasterCookies & "_Chat_World_Index") = 0
		Application(DEF_MasterCookies & "_Chat_Load") = "1"
		Application.UnLock
	End If

End Sub

Sub Chat_init_session

	If isArray(Session(DEF_MasterCookies & "UDT")) Then
		If Session(DEF_MasterCookies & "_Chat_GetTime") & "" = "" Then
			Session(DEF_MasterCookies & "_Chat_World_Index") = cCur(Application(DEF_MasterCookies & "_Chat_World_Index"))
			Session(DEF_MasterCookies & "_Chat_GetTime") = Timer - Chat_GetDelay * 1000
			Session(DEF_MasterCookies & "_Chat_SendTime") = Timer - Chat_WorldDelay * 1000
			Session(DEF_MasterCookies & "_Chat_5_Index") = Application(DEF_MasterCookies & "_Chat_S_Index_" & Session(DEF_MasterCookies & "UDT")(1))
		End If
	End If

End Sub

Sub Chat_Appand(User,Str,Channel,ToUser)

	Dim Temp,Index
	
	Dim f,f_Str
	f = Channel
	
	If User = "SpiderMan" and left(Str,4) = "/公告 " and Str <> "/公告 " Then
		f = 4
		f_Str = "<font style='font-size:9pt;' color=red class=redfont><b>" & Mid(Str,5) & "</b></font>"
	End If
	
	If User = "SpiderMan" and left(Str,5) = "/cmd " and Str <> "/cmd " Then
		Select Case LCase(Mid(Str,6))
			Case "reset":	f_Str = "reset"
					f = 9
		End Select
	End If
	
	Dim FaceFlag
	FaceFlag = 0
	If Trim(Str) = "$N" Then Str = "$N无语…"
	If f <> 4 and f <> 9 Then
		If inStr(Str,"$N") Then
			f_Str = Replace("<u>" & PrintTrueText(Str) & "</u>","$N","<span onclick=c_sc(this.innerHTML) style=cursor:hand class=c_name>" & User & "</span>",1,3,0)
			If ToUser <> "" Then f_Str = Replace(f_Str,"$P","<span onclick=c_sc(this.innerHTML) style=cursor:hand class=c_name2>" & ToUser & "</span>",1,3,0)
			FaceFlag = 1
		Else
			If Channel = 5 Then
				f_Str = PrintTrueText(Str)
			Else
				f_Str = "<span onclick=c_sc(this.innerHTML) style=cursor:hand class=c_name>" & User & "</span>: " & PrintTrueText(Str)
			End If
		End If
	End If
	If Channel <> 5 Then f_Str = f & " " & f_Str

	Select Case f
		Case 5:
			If FaceFlag = 1 Then f_Str = f & " " & f_Str
			'If ToUser <> User Then
			If FaceFlag = 0 or ToUser <> User Then
				Temp =  Application(DEF_MasterCookies & "_Chat_S_Data_" & User)
				Index = Application(DEF_MasterCookies & "_Chat_S_Index_" & User)
				Index = Index + 1
				If Index > Chat_MaxSessionCache - 1 Then Index = 0
				If FaceFlag = 0 Then
					Temp(Index) = "6 你悄悄的对<span onclick=c_sc(this.innerHTML) style=cursor:hand class=c_name>" & ToUser & "</span>说: " & f_Str
				Else
					Temp(Index) = f_Str
				End If
				
				Application.Lock
				Application(DEF_MasterCookies & "_Chat_S_Index_" & User) = Index
				Application(DEF_MasterCookies & "_Chat_S_Data_" & User) = Temp
				Application.UnLock
			End If
			'End If

			Temp =  Application(DEF_MasterCookies & "_Chat_S_Data_" & ToUser)
			Index = Application(DEF_MasterCookies & "_Chat_S_Index_" & ToUser)
			Index = Index + 1
			If Index > Chat_MaxSessionCache - 1 Then Index = 0
			If FaceFlag = 0 Then
				Temp(Index) = "5 <span onclick=c_sc(this.innerHTML) style=cursor:hand class=c_name>" & User & "</span>悄悄的对你说: " & f_Str
			Else
				Temp(Index) = f_Str
			End If
			
			Application.Lock
			Application(DEF_MasterCookies & "_Chat_S_Index_" & ToUser) = Index
			Application(DEF_MasterCookies & "_Chat_S_Data_" & ToUser) = Temp
			Application.UnLock
		Case Else
			Temp =  Application(DEF_MasterCookies & "_Chat_World")
			Index = Application(DEF_MasterCookies & "_Chat_World_Index")
			Index = Index + 1
			If Index > Chat_MaxCache - 1 Then Index = 0
			Temp(Index) = f_Str
			
			Application.Lock
			Application(DEF_MasterCookies & "_Chat_World_Index") = Index
			Application(DEF_MasterCookies & "_Chat_World") = Temp
			Application.UnLock
	End Select

End Sub

Sub Chat_ViewWorldMsg(User)

	Dim Index,World_Index,Temp,n
	Index = Session(DEF_MasterCookies & "_Chat_World_Index")
	World_Index = Application(DEF_MasterCookies & "_Chat_World_Index")
	If Index <> World_Index and Index <> -1 Then
		Session(DEF_MasterCookies & "_Chat_World_Index") = Application(DEF_MasterCookies & "_Chat_World_Index")
		Temp = Application(DEF_MasterCookies & "_Chat_World")
		'Response.Write "<script>"
		If Index > World_Index Then
			For n = Index to Chat_MaxCache-1
				Response.Write "addMessage('" & Left(Temp(n),1) & "',""" & Mid(Temp(n),3) & """);" & VbCrLf
			Next
			For n = 0 to World_Index
				Response.Write "addMessage('" & Left(Temp(n),1) & "',""" & Mid(Temp(n),3) & """);" & VbCrLf
			Next
		Else
			For n = Index + 1 to World_Index
				Response.Write "addMessage('" & Left(Temp(n),1) & "',""" & Mid(Temp(n),3) & """);" & VbCrLf
			Next
		End If
		'Response.Write "</script>" & VbCrLf
	End If

	Index = Session(DEF_MasterCookies & "_Chat_5_Index")
	World_Index = Application(DEF_MasterCookies & "_Chat_S_Index_" & User)
	If Index <> World_Index and Index <> -1 Then
		Session(DEF_MasterCookies & "_Chat_5_Index") = Application(DEF_MasterCookies & "_Chat_S_Index_" & User)
		Temp = Application(DEF_MasterCookies & "_Chat_S_Data_" & User)
		'Response.Write "<script>"
		If Index > World_Index Then
			For n = Index to Chat_MaxSessionCache-1
				Response.Write "addMessage('" & Left(Temp(n),1) & "',""" & Mid(Temp(n),3) & """);" & VbCrLf
			Next
			For n = 0 to World_Index
				Response.Write "addMessage('" & Left(Temp(n),1) & "',""" & Mid(Temp(n),3) & """);" & VbCrLf
			Next
		Else
			For n = Index + 1 to World_Index
				Response.Write "addMessage('" & Left(Temp(n),1) & "',""" & Mid(Temp(n),3) & """);" & VbCrLf
			Next
		End If
		'Response.Write "</script>" & VbCrLf
	End If

End Sub

Function PrintTrueText(tempString)

	If tempString<>"" Then
		PrintTrueText=Replace(Replace(Replace(Replace(Replace(htmlEncode(tempString),VbCrLf & " ","<br>" & "&nbsp;"),VbCrLf,"<br>" & VbCrLf),"   "," &nbsp; "),"  "," &nbsp;"),chr(9)," &nbsp; &nbsp; &nbsp;")

		If Left(PrintTrueText,1) = chr(32) Then
			PrintTrueText = "&nbsp;" & Mid(PrintTrueText,2)
		End If
	Else
		PrintTrueText=""
	End If

End Function
%>