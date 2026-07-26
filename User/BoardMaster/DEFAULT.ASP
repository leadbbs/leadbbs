<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="inc/BoardMaster_Fun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase()
GBL_CHK_TempStr = ""
GBL_ID = GBL_UserID
closeDataBase()

BBS_SiteHead DEF_SiteNameString & " - 注册新用户",0,"" & DEF_PointsName(6) & "管理"

UserTopicTopInfo(0)
If GBL_CHK_Flag=1 Then
	LoginAccuessFul()
Else
	If Request("submitflag")="" Then
		DisplayLoginForm("请先登录")
	Else
		DisplayLoginForm("<span class=""redfont"">" & GBL_CHK_TempStr & "</span>")
	End If
End If
UserTopicBottomInfo()
SiteBottom()
If GBL_ShowBottomSure = 1 Then Response.Write GBL_SiteBottomString

Function LoginAccuessFul

If BDM_isBoardMasterFlag = 1 Then%>
		<div class="value2">
		<%=GBL_CHK_User%>，您好：)
		</div>
              <div class="value2">
              <%DisplaySystemInfo()%>
              </div>
	<%Else%>
	       <p><br>
              已经成功登录！<br></p>
              <br><br>
              
	<%End If
    
End Function

Sub DisplaySystemInfo

	%><div class="title">基本信息</div>
	<div class="value2">服务器时间：<%=now()%>，论坛(计算时差)时间<%=DEF_Now%></div>
	<div class="value2">总在线人数： <b><%=application(DEF_MasterCookies & "ActiveUsers")%></b> 人</div>
	<div class="value2">是否有扩展权限：<b><%If BDM_SpecialPopedomFlag = 0 Then
		Response.Write "<span class=""redfont"">无</span>"
	Else
		Response.Write "<span class=""greenfont"">有</span>"
	End If%></b>
	[ 扩展权限包括封用户ＩＰ，屏蔽用户发言，禁止发言等 ]</div>
	<%

End Sub
%>