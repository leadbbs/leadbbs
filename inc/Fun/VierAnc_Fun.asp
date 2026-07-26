<!--#include file="../../inc/Upload_Fun.asp"-->
<%
Function Topic_AnnounceList(BoardID,ListNum,GoodAssort,NewWindow,PithFlag,newanc,img)

	Dim RewriteFlag,url
	If GetBinarybit(DEF_Sideparameter,16) = 0 Then
		RewriteFlag = 0
	else
		RewriteFlag = 1
	end if
	Dim StrLen
	StrLen = 52
	If isNumeric(ListNum) = False or ListNum = "" Then ListNum = 10
	If isNumeric(BoardID) = False Then BoardID = 0
	BoardID = Fix(cCur(BoardID))
	If isNumeric(GoodAssort) = False Then GoodAssort = 0
	GoodAssort = Fix(cCur(GoodAssort))

	ListNum = Fix(cCur(ListNum))
	If ListNum < 1 or ListNum > 100 Then ListNum = 10
	If GoodAssort < 1 Then GoodAssort = 0
	
	If NewWindow <> "yes" Then
		NewWindow = ""
	Else
		NewWindow = " target=""_blank"""
	End If

	Dim Rs,SQL

If PithFlag = "2" Then
	SQL = sql_select("select BoardID,BoardName,AnnounceNum from LeadBBS_Boards where HiddenFlag=0 and BoardID<>444 order by AnnounceNum DESC",ListNum)
ElseIf PithFlag = "3" Then
	SQL = sql_select("select BoardID,BoardName,AnnounceNum from LeadBBS_Boards where ParentBoard=" & BoardID & " and HiddenFlag=0 and BoardID<>444 order by OrderID ASC",ListNum)
Else
	If DEF_UsedDataBase = 1 Then
		SQL = "select T1.ID,T1.Title,T1.TitleStyle,T1.BoardID,T2.ForumPass,T2.BoardLimit,T2.OtherLimit,T2.HiddenFlag from LeadBBS_Topic as T1 left join LeadBBS_Boards as T2 on T1.BoardID=T2.BoardID Where"
		If GoodAssort > 0 Then
			SQL = SQL & " T1.GoodAssort=" & GoodAssort & " and T1.BoardID<>444 Order by ID DESC"
		Else
			If PithFlag = "1" Then
				If BoardID = 0 Then
					SQL = SQL & " T1.GoodFlag=1 and T1.BoardID<>444 Order by T1.ID DESC"
				Else
					SQL = SQL & " T1.GoodFlag=1 and T1.BoardID=" & BoardID & " Order by T1.ID DESC"
				End If
			Else
				If BoardID = 0 Then
					SQL = SQL & " T1.BoardID<>444 Order by T1.ID DESC"
				Else
					SQL = SQL & " T1.BoardID=" & BoardID & " Order by T1.RootID DESC"
				End If
			End If
		End If
		sql = sql_select(sql,ListNum)
	Else
	If newanc = "1" Then
		SQL = sql_select("select T1.ID,T1.Title,T1.TitleStyle,T1.BoardID,T2.ForumPass,T2.BoardLimit,T2.OtherLimit,T2.HiddenFlag from LeadBBS_Announce as T1 left join LeadBBS_Boards as T2 on T1.BoardID=T2.BoardID Where T1.BoardID<>444 Order by T1.ID DESC",ListNum)
	Else
		SQL = "select T1.ID,T1.Title,T1.TitleStyle,T1.BoardID,T2.ForumPass,T2.BoardLimit,T2.OtherLimit,T2.HiddenFlag from LeadBBS_Announce as T1 left join LeadBBS_Boards as T2 on T1.BoardID=T2.BoardID Where"
		If GoodAssort > 0 Then
			SQL = SQL & " T1.GoodAssort=" & GoodAssort & " and T1.BoardID<>444 Order by ID DESC"
		Else
			If PithFlag = "1" Then
				If BoardID = 0 Then
					SQL = SQL & " T1.GoodFlag=1 and T1.BoardID<>444 Order by T1.ID DESC"
				Else
					SQL = SQL & " T1.GoodFlag=1 and T1.BoardID=" & BoardID & " Order by T1.ID DESC"
				End If
			Else
				If BoardID = 0 Then
					SQL = SQL & " T1.ParentID=0 and T1.BoardID<>444 Order by T1.Rootidbak DESC"
				Else
					SQL = SQL & " T1.ParentID=0 and T1.BoardID=" & BoardID & " Order by T1.RootIDBak DESC"
				End If
			End If
		End If
		sql = sql_select(sql,ListNum)
	End If
	End If
End If
	Set Rs = LDExeCute(SQL,0)
	Dim Num
	Dim GetData
	If Not rs.Eof Then
		GetData = Rs.GetRows(-1)
		Num = Ubound(GetData,2)
	Else
		Num = -1
	End If
	Rs.close
	Set Rs = Nothing
	If Num = -1 Then 
		Topic_AnnounceList = ""
		Exit Function
	End If
		

	img = Replace(Replace(Left(Request.QueryString("img"),100),"\",""),"""","")
	If img <> "" Then img = "<img src=""" & Replace(img,"\","\\") & " alt="""" />"
	'If img = "" Then img = "<img src=""" & DEF_BBS_HomeUrl & "images/style/0/slist.gif"" alt="""" />"
	Dim Str
	Str = "<ul>"
	For SQL = 0 to Num
		If PithFlag = "2" or PithFlag = "3" Then
			Str = Str & "<li>" & img & "<a href=""" & DEF_BBS_HomeUrl & "b/" & RW_b(GetData(0,SQL),0,"") & """" & NewWindow & "><span class=""word-break-all"">" & GetData(1,SQL) & ""
			If PithFlag = "2" Then Str = Str & " <em>" & GetData(2,SQL) & "</em>"
			Str = Str & "</span></a></li>"
		Else
			If GetData(2,SQL) = 1 Then GetData(1,SQL) = KillHTMLLabel(GetData(1,SQL))
			GetData(1,SQL) = Replace(htmlencode(GetData(1,SQL)),"\","\\")
			'GetData(1,SQL) = DisplayAnnounceTitle(GetData(1,SQL),GetData(2,SQL))
			If GBL_CheckLimitTitle(GetData(4,SQL),GetData(5,SQL),GetData(6,SQL),GetData(7,SQL)) = 1 Then
					GetData(1,SQL) = "此帖子标题已设置为隐藏"
					GetData(2,SQL) = 1
			End If

		if StrLen>0 Then
		If Len(GetData(1,SQL)) > StrLen/2 Then
			If StrLength(GetData(1,SQL)) > StrLen Then
				GetData(1,SQL) = LeftTrue(GetData(1,SQL),StrLen - 3) & "..."
			End If
		End If
		End If
			url = "a/" & RW_a(GetData(3,SQL),GetData(0,SQL),1,1,"")
			Str = Str & "<li>" & img & "<a href=""" & DEF_BBS_HomeUrl & url & """" & NewWindow & " title=""" & GetData(1,SQL) & """><span class=""word-break-all""><i style=""display:none"">.</i>" & GetData(1,SQL) & "</span></a></li>"
		End If
	Next
	Str = Str & "</ul>"
	Topic_AnnounceList = Str

End Function

Dim LMT_Pic_Index : LMT_Pic_Index = ""
Function Topic_PicInfo(Width,Height,Num)

	Dim SaveFile : SaveFile = DEF_BBS_HomeUrl & "inc/incHtm/Tmp_Pic" & LMT_Pic_Index & ".asp"
	Dim fileContent,tmpArr,savetime
	fileContent = ADODB_LoadFile(SaveFile)
	savetime = 0
	if fileContent <> "" Then
		tmpArr = split(fileContent,"~~~~split~~~~")
		if Ubound(tmpArr)>0 then
			savetime = toNum(tmpArr(0),0)
			fileContent = tmpArr(1)
		end if
	end if
	If savetime > 0 Then
		savetime = RestoreTime(savetime)
		dim t
		t = DateDiff("s",savetime,DEF_Now)
		'If (t < 0 or t > DEF_UpdateInterval) and Application(DEF_MasterCookies & "_UpdateSide") & "" <> "yes" Then
		If (t < 0 or t > DEF_UpdateInterval) Then
		else
			Topic_PicInfo = fileContent
			Exit Function
		end if
	End If

	'Application.Lock
	'Application(DEF_MasterCookies & "_UpdatePic" & LMT_Pic_Index) = "yes"
	'Application.UnLock
	'Const DEF_IMG_PlayWidth = 140
	Const DEF_IMG_PlayWidth = 168
	Const DEF_IMG_PlayHeight = 105
	
	Dim RewriteFlag,url
	If GetBinarybit(DEF_Sideparameter,16) = 0 Then
		RewriteFlag = 0
	else
		RewriteFlag = 1
	end if
	
	If isNumeric(Num) = 0 Then Num = 0
	If Num < 1 or Num > 50 Then Num = 6
	
	
	If isNumeric(Height) = 0 Then Height = Fix(DEF_UploadSwidth * (DEF_IMG_PlayHeight/DEF_IMG_PlayWidth))
	If isNumeric(Width) = 0 Then Width = DEF_UploadSwidth
	If Height < 1 Then Height=DEF_IMG_PlayHeight
	If Width < 1 Then Width=DEF_IMG_PlayWidth

	Dim Rs,SQL,GetData,sql2
	'sql2 = sql_select("select DISTINCT AnnounceID from LeadBBS_Upload where FileType=0 order by AnnounceID desc",Num)
	select Case DEF_UsedDataBase
		case 2:
			'sql2 = "select t.AnnounceID from (" & sql2 & ")as t"
		case else:
	end select

	'SQL = "Select U.ID,U.PhotoDir,U.SPhotoDir,U.NdateTime,A.Title,U.AnnounceID,A.BoardID from LeadBBS_Upload as U left Join LeadBBS_Announce As A on U.AnnounceID=A.ID where U.FileType=0 and U.AnnounceID in(" & sql2 & ") Order by U.AnnounceID DESC,U.ID ASC"
	Dim MaxNum : MaxNum = Num*DEF_UploadOnceNum
	If MaxNum > 1000 then MaxNum = 1000
	SQL = sql_select("Select U.ID,U.PhotoDir,U.SPhotoDir,U.NdateTime,A.Title,U.AnnounceID,A.BoardID from LeadBBS_Upload as U left Join LeadBBS_Announce As A on U.AnnounceID=A.ID where U.FileType=0 Order by U.AnnounceID DESC,U.ID ASC",Num*DEF_UploadOnceNum)
if request("a") = "1" then response.write "----------" & sql
	Set Rs = Con.ExeCute(SQL)
	If Not Rs.Eof Then
		GetData = Rs.GetRows(-1)
		Rs.Close
		Set Rs = Nothing
	Else
		Rs.Close
		Set Rs = Nothing
		Exit Function
	End If
	SQL = Ubound(GetData,2)

	Dim Str : str = ""
	Dim UrlData,UrlLink,TitleList
	Dim tmppage : tmppage = ""
	
	str = str & "<div class=""playimages_list"">"
	
	Dim udir,CurAid,AidNum
	CurAid = 0
	AidNum = 0
	For Rs = 0 To SQL
	GetData(5,Rs) = cCur(GetData(5,Rs))
	if CurAid <> GetData(5,Rs) and AidNum < Num then
		CurAid = GetData(5,Rs)
		AidNum = AidNum + 1
		If GetData(5,Rs) <> 0 Then
			url = "a/" & RW_a(GetData(6,Rs),GetData(5,Rs),1,1,"")
			UrlLink = DEF_BBS_HomeUrl & url
		Else
			UrlLink = DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl & Replace(GetData(1,Rs),"\","/")
		End If
		
		udir = DEF_BBS_HomeUrl & DEF_BBS_UploadPhotoUrl
		If GetData(2,Rs) <> "" and DEF_EnableGFL = 0 Then
			UrlData = udir & Replace(GetData(2,Rs),"\","/")
		Else
			UrlData = udir & Replace(GetData(1,Rs),"\","/")
		End If
		if DEF_EnableGFL = 1 then
			call SaveSmallPic(Server.Mappath(UrlData),Server.Mappath(DEF_BBS_HomeUrl & "images/temp/NewsPic_" & Rs & LMT_Pic_Index & ".jpg"),width,height,-1)
			UrlData = DEF_BBS_HomeUrl & "images/temp/NewsPic_" & Rs & LMT_Pic_Index & ".jpg?ver=" & Timer
		end if
		TitleList = htmlencode(GetData(4,Rs) & "")
		If Left(TitleList,3) = "re:" and len(TitleList) > 4 Then TitleList = Mid(TitleList,4)
		str = str & "<a href=""" & UrlLink & """ target=""_blank"""
		If Rs = 0 Then
			str = str & " style='z-index:100;background: url(""" & UrlData & """) center no-repeat" & "'"
		else
			str = str & " style='z-index:99;background: url(""" & UrlData & """) center no-repeat" & "'"
		end if
		str = str & " title=""" & TitleList & """"
		'str = str & "><img src=""" & UrlData & """ title=""" & TitleList & """ alt=""" & TitleList & """ /></a>"
		str = str & "></a>"
	End If
	Next
	str = str & "</div></div>"
	str = str & "<" & "script src=""" & DEF_BBS_HomeUrl & "inc/js/img.js" & DEF_Jer & """ type=""text/javascript""></script" & ">" & VbCrLf


	tmppage = "<div class=""playimages"">" &_
		"<div class=""playimages_bg""></div>" &_
		"<div class=""playimages_info""></div>" &_
		"<ul>" &_
		"<li class=""on"">1</li>"
	For Rs = 1 To AidNum-1
		tmppage = tmppage & "<li>" & Rs+1 & "</li>"
	Next
	tmppage = tmppage & "</ul>"
	
	Str = tmppage & Str

	Topic_PicInfo = Str

	ADODB_SaveToFile GetTimeValue(DEF_Now) & "~~~~split~~~~" & Str,SaveFile
	
	Application.Contents.Remove(DEF_MasterCookies & "_UpdatePic" & LMT_Pic_Index)

End Function
%>