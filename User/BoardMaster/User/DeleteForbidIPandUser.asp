<!--#include file="../../../inc/BBSsetup.asp"-->
<!--#include file="../../../inc/Board_popfun.asp"-->
<!--#include file="../../../inc/Limit_Fun.asp"-->
<!--#include file="../inc/BoardMaster_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../../"
initDatabase()
GBL_CHK_TempStr = ""
CheckisBoardMasterFlag()

SiteHead(DEF_SiteNameString & " - " & DEF_PointsName(6) & "管理")


UserTopicTopInfo()
DisplayUserNavigate("删除用户")
            
If GBL_CHK_Flag=1 and BDM_isBoardMasterFlag = 1 and BDM_SpecialPopedomFlag = 1 Then
	If GBL_CHK_TempStr="" Then
		If Request.Form("DeleteSure")="E72ksiOkw2" Then
			If DeleteForbidIPandUser() = 1 Then
				Response.Write "<p><font color=008800 class=greenfont><b>已经成功解除所有到期的特殊用户及屏蔽的ＩＰ地址！</b></font></p>"
			else
				Response.Write "<p><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font></p>"
			End If
		Else
			%>
			<p><form action=DeleteForbidIPandUser.asp method=post>
			<b><font color=ff0000 class=redfont>确认信息：今天是<%=year(DEF_Now)%>年<%=month(DEF_Now)%>月<%=day(DEF_Now)%>，此动作将清除今天前将到期的内容，包括如下：<br>
			&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 1.解除被屏蔽的IP地址<br>
			&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 2.解除被屏蔽发言内容的会员<br>
			&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 3.解除被禁言的会员<br>
			&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 4.解除被禁止修改的会员<br>
			&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 5.恢复到期了的<%=DEF_PointsName(5)%>到普通会员状态<br>
			&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 6.清除在到期时间以前仍然未激活的注册会员<br>
			<br>
			<input type=hidden name=DeleteSure value="E72ksiOkw2">
			
			<input type=submit value=当然清除 class=fmbtn>
			</form>
		<%End If
	Else%>
		<table width=96%>
		<tr>
			<td>
				<%Response.Write GBL_CHK_TempStr%>
			</td>
		</tr>
		</table>
	<%End If
Else%>
	<table width=96%>
	<tr>
	<td>
	<%
	If Request("submitflag")="" Then
		Response.Write "<br><b>请先登录</b>"
	Else
		Response.Write "<br><p align=left><font color=ff0000 class=redfont><b>" & GBL_CHK_TempStr & "</b></font>"
	End If
	DisplayLoginForm()
	Response.Write "</p>"%>
	</td>
	</tr>
	</table>
<%End If
UserTopicBottomInfo()
closeDataBase()
SiteBottom()
If GBL_ShowBottomSure = 1 Then Response.Write GBL_SiteBottomString

Rem 检测某用户名是否存在
Function DeleteForbidIPandUser

	Server.ScriptTimeOut = 6000
	'If UserName <> "" and inStr(UserName,",") = 0 and inStr(Lcase(DEF_SupervisorUserName),"," & Lcase(UserName) & ",") > 0 Then
	'	GBL_CHK_TempStr = "错误，用户名" & htmlencode(UserName) & "不存在！"
	'	DeleteForbidIPandUser = 0
	'	Exit Function
	'End If
	
	Response.Write "<br><p>正在更新中．．．<p>"
	Dim ExpiresTime
	ExpiresTime = GetTimeValue(year(DEF_Now) & "-" & Month(DEF_Now) & "-" & Day(DEF_Now))
	Dim Rs
	Set Rs = LDExeCute("Select T2.ID,T2.UserLimit,T2.UserName,T1.Assort from LeadBBS_SpecialUser as T1 Left join LeadBBS_User As T2 on T1.UserID=T2.ID where T1.ExpiresTime>0 and T1.ExpiresTime<" & ExpiresTime,0)
	If Rs.Eof Then
		DeleteForbidIPandUser = 1
		Response.Write "<br>无任何到期的特殊用户，不需要更新．．"
	End If
	Dim GBL_UserName_UserID,GBL_UserName_UserLimit,GBL_UserName,GBL_Assort
	Do while Not Rs.Eof
		GBL_UserName_UserLimit = cCur(Rs(1))
		GBL_UserName_UserID = cCur(Rs(0))
		GBL_UserName = Rs(2)
		GBL_Assort = cCur(Rs(3))
		
		',0-认证会员,1-版主,2-总版主,3-屏蔽会员,4-禁言会员,5-禁修改会员,6-非正式会员
		Select Case GBL_Assort
			Case 0:
					If GetBinarybit(GBL_UserName_UserLimit,2) = 1 Then
						Response.Write "<br>用户" & htmlencode(GBL_UserName) & "已经解除" & DEF_PointsName(5) & "状态！"
						GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,2,0)
						CALL LDExeCute("Update LeadBBS_User Set UserLimit=" & GBL_UserName_UserLimit & " where ID=" & GBL_UserName_UserID,1)
						CALL LDExeCute("Delete from LeadBBS_SpecialUser Where Assort=" & GBL_Assort & " and UserID=" & GBL_UserName_UserID,1)
					End If
			Case 3:
					If GetBinarybit(GBL_UserName_UserLimit,7) = 1 Then
						Response.Write "<br>用户" & htmlencode(GBL_UserName) & "已经解除屏蔽发言内容及签名！"
						GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,7,0)
						CALL LDExeCute("Update LeadBBS_User Set UserLimit=" & GBL_UserName_UserLimit & " where ID=" & GBL_UserName_UserID,1)
						CALL LDExeCute("Delete from LeadBBS_SpecialUser Where Assort=" & GBL_Assort & " and UserID=" & GBL_UserName_UserID,1)
					End If
			Case 4:
					If GetBinarybit(GBL_UserName_UserLimit,3) = 1 Then
						Response.Write "<br>用户" & htmlencode(GBL_UserName) & "已经解除禁言及发送短消息！"
						GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,3,0)
						CALL LDExeCute("Update LeadBBS_User Set UserLimit=" & GBL_UserName_UserLimit & " where ID=" & GBL_UserName_UserID,1)
						CALL LDExeCute("Delete from LeadBBS_SpecialUser Where Assort=" & GBL_Assort & " and UserID=" & GBL_UserName_UserID,1)
					End If
			Case 5:
					If GetBinarybit(GBL_UserName_UserLimit,4) = 1 Then
						Response.Write "<br>用户" & htmlencode(GBL_UserName) & "已经解除禁止修改帖子及自我资料！"
						GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,4,0)
						CALL LDExeCute("Update LeadBBS_User Set UserLimit=" & GBL_UserName_UserLimit & " where ID=" & GBL_UserName_UserID,1)
						CALL LDExeCute("Delete from LeadBBS_SpecialUser Where Assort=" & GBL_Assort & " and UserID=" & GBL_UserName_UserID,1)
					End If
			Case 6:
					If GetBinarybit(GBL_UserName_UserLimit,1) = 1 Then
						Response.Write "<br>未激活用户" & htmlencode(GBL_UserName) & "已经被成功删除！"
						GBL_UserName_UserLimit = SetBinaryBit(GBL_UserName_UserLimit,1,0)
						CALL LDExeCute("delete from LeadBBS_User where ID=" & GBL_UserName_UserID,1)
						CALL LDExeCute("Update LeadBBS_SiteInfo Set UserCount=UserCount-1",1)
						UpdateStatisticDataInfo -1,1,1
						CALL LDExeCute("Delete from LeadBBS_SpecialUser Where Assort=" & GBL_Assort & " and UserID=" & GBL_UserName_UserID,1)
					End If
			Case Else:
		End Select
		Rs.MoveNext
	Loop
	Rs.Close
	Set Rs = Nothing
	Response.Write "<br><font color=Green Class=greenfont>到期特殊用户更新完成．</font>"
	Set Rs = LDExeCute("Delete From LeadBBS_ForbidIP where ExpiresTime>0 and ExpiresTime<" & ExpiresTime,0)
	Response.Write "<br><font color=Green Class=greenfont>开启到期的被屏蔽ＩＰ地址已经成功完成．</font>"
	DeleteForbidIPandUser = 1

End Function%>