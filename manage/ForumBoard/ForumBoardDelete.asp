<!-- #include file=../../inc/BBSsetup.asp -->
<!-- #include file=../../inc/Board_Popfun.asp -->
<!-- #include file=../inc/bbsmanage_Fun.asp -->
<!-- #include file=inc/ForumBoard_fun.asp -->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID,GBL_DELETEID
initDatabase
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass

Manage_sitehead DEF_SiteNameString & " - 管理员",""
GBL_CHK_TempStr = ""
frame_TopInfo
DisplayUserNavigate("删除论坛空版面")
GBL_DELETEID = Left(Request("GBL_DELETEID"),14)
If isNumeric(GBL_DELETEID)=0 Then GBL_DELETEID=0
GBL_DELETEID = cCur(GBL_DELETEID)
If GBL_CHK_Flag=1 Then
	If Request.Form("DeleteSuer")="E72ksiOkw2" Then
			GBL_BoardID = GBL_DELETEID
			If DeleteForumBoard(GBL_DELETEID)>0 Then
				Response.Write "<p><font color=008800 class=greenfont><b>已经成功删除ID为" & GBL_DELETEID & "的论坛版面！</b></font></p>"
			Else
				Response.Write "<p><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font></p>"
			End If
		Else
			%><p><form action=ForumBoardDelete.asp method=post>
			注意：删除论坛不删除一切论坛帖子和其它用户信息！<br>
			　　　在删除前务必确认此论坛已经为空。<br><br>
			<font color=Red class=redfont>警告</font>：在删除版面时将同时删除此版面的专区信息<br><br>
			<b><font color=ff0000 class=redfont>确认信息： 真的要删除此论坛版面吗？<br><br>
			<input type=hidden name=GBL_DELETEID value="<%=urlencode(GBL_DELETEID)%>">
			<input type=hidden name=DeleteSuer value="E72ksiOkw2">
			
			<input type=button value=返回 onclick="javascript:history.go(-1);" class=fmbtn>
			<input type=submit value=确定删除 class=fmbtn>
			</form>
		<%End If
Else
DisplayLoginForm
End If
closeDataBase
frame_BottomInfo
Manage_Sitebottom("none")
%>