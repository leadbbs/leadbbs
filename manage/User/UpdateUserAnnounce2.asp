<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../inc/bbsmanage_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Rem -------------------------------------------------------
Rem ------------重算所有用户帖子数量-----------------------
Rem -------------------------------------------------------
initDatabase()
Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo()
UpdateUserAnnounce()
CloseDatabase()
frame_BottomInfo()
Manage_Sitebottom("none")

Function UpdateUserAnnounce()

	If CheckSupervisorUserName() = 0 or GBL_UserID = 0 Then Exit Function

	If Request.Form("SureFlag") <> "E72ksiOkw2" Then
		%>
			<p><form action=UpdateUserAnnounce2.asp method=post>
			<b><font color=ff0000 class=redfont>确定此操作吗?<br>
			<br>
			<input type=hidden name=SureFlag value="E72ksiOkw2">
			<input type=hidden name=ID value="<%=Left(Request("ID"),14)%>">
			
			<input type=submit value=确定进行 class=fmbtn>
			</form>
		<%
	Else
	
		Dim NowID,EndFlag,Temp
		NowID = Left(Request("ID"),14)
		If isNumeric(NowID) = 0 Then NowID = 0
		NowID = Fix(cCur(NowID))
		If NowID < 1 Then Exit Function
		EndFlag = 0
		Dim Rs,SQL
		Dim AnnounceNum,AnnounceTopic,AnnounceGood,UploadNum,UserName
		
		SQL = sql_select("Select ID,UserName from LeadBBS_User where ID=" & NowID,1)
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			Rs.Close
			Set Rs = Nothing
			Response.Write "错误，不存在的用户"
			Exit Function
		Else
			UserName = Rs(1)
			Rs.Close
			Set Rs = Nothing
		End If
		
		SQL = "select count(*) from leadbbs_Upload where UserID=" & NowID
		Set Rs = LDExeCute(SQL,0)
		If Not Rs.Eof Then
			UploadNum = Rs(0)
			If isNull(UploadNum) then UploadNum = 0
			UploadNum = ccur(UploadNum)
		Else
			UploadNum = 0
		End If
		Rs.Close
		Set Rs = Nothing
	
		SQL = "select count(*) from leadbbs_announce where UserID=" & NowID
		Set Rs = LDExeCute(SQL,0)
		If Not Rs.Eof Then
			AnnounceNum = Rs(0)
			If isNull(AnnounceNum) then AnnounceNum = 0
			AnnounceNum = ccur(AnnounceNum)
		Else
			AnnounceNum = 0
		End If
		Rs.Close
		Set Rs = Nothing
		
		SQL = "select count(*) from leadbbs_announce where UserID=" & NowID & " and ParentID=0"
		Set Rs = LDExeCute(SQL,0)
		If Not Rs.Eof Then
			AnnounceTopic = Rs(0)
			If isNull(AnnounceTopic) then AnnounceTopic = 0
			AnnounceTopic = ccur(AnnounceTopic)
		Else
			AnnounceTopic = 0
		End If
		Rs.Close
		Set Rs = Nothing

		SQL = "select count(*) from leadbbs_announce where GoodFlag=1 and UserID=" & NowID
		Set Rs = LDExeCute(SQL,0)
		If Not Rs.Eof Then
			AnnounceGood = Rs(0)
			If isNull(AnnounceGood) then AnnounceGood = 0
			AnnounceGood = ccur(AnnounceGood)
		Else
			AnnounceGood = 0
		End If
		Rs.Close
		Set Rs = Nothing
		'If DEF_EnableSpecialTopic = 1 Then
			CALL LDExeCute("Update LeadBBS_User Set AnnounceNum=" & AnnounceNum & ",AnnounceTopic=" & AnnounceTopic & ",AnnounceGood=" & AnnounceGood & ",UploadNum=" & UploadNum & " Where ID=" & NowID,1)
		'Else
		'	CALL LDExeCute("Update LeadBBS_User Set AnnounceNum=" & AnnounceNum & ",AnnounceTopic=" & AnnounceTopic & ",AnnounceGood=" & AnnounceGood & ",UploadNum=" & UploadNum & ",points=" & DEF_BBS_AnnouncePoints*(AnnounceNum+AnnounceTopic)+AnnounceGood*5 & " Where ID=" & NowID,1)
		'End If
		'GetUserLevel(NowID)
	
		SQL = sql_select("Select ID from LeadBBS_InfoBox where ReadFlag=0 and ToUser='" & Replace(UserName,"'","''") & "'",1)
		Set Rs = LDExeCute(SQL,0)
		If Rs.Eof Then
			Rs.Close
			Set Rs = Nothing
			CALL LDExeCute("Update LeadBBS_User Set MessageFlag=0 where ID=" & NowID,1)
		Else
			Rs.Close
			Set Rs = Nothing
			CALL LDExeCute("Update LeadBBS_User Set MessageFlag=1 where ID=" & NowID,1)
		End If
		Response.Write "完成用户" & htmlencode(UserName) & "修复！"
	End If

End Function


Function GetUserLevel(GBL_ID)

	Dim Temp_N,UserLevel,IP,SessionID,AnnounceNum,Online,Prevtime,OnlineTime,Points
	Dim Rs
	Set Rs = LDExeCute(sql_select("Select UserLevel,AnnounceNum,OnlineTime from LeadBBS_User where id=" & GBL_ID,1),0)
	If Rs.Eof Then
		Rs.Close
		Set Rs = Nothing
		Exit Function
	End If
	UserLevel = Rs(0)
	Points = cCur(Rs(1))
	OnlineTime = cCur(Rs(2))
	Rs.Close
	Set Rs = Nothing

	For Temp_N = 0 To DEF_UserLevelNum
		If Points >= DEF_UserLevelPoints(Temp_N) Then UserLevel = Temp_N
	Next

	GetUserLevel = UserLevel
	CALL LDExeCute("Update LeadBBS_User Set UserLevel=" & UserLevel & " Where ID=" & GBL_ID,1)

End Function
%>