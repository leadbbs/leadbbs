<!-- #include file=../../inc/BBSsetup.asp -->
<!-- #include file=../../inc/Board_popfun.asp -->
<!-- #include file=../inc/bbsmanage_Fun.asp -->
<%
DEF_BBS_HomeUrl = "../../"
Dim GBL_ID
initDatabase
GBL_CHK_TempStr = ""
GBL_ID = checkSupervisorPass

Manage_sitehead DEF_SiteNameString & " - 管理员",""
frame_TopInfo
DisplayUserNavigate("在线编辑其他文件")
If GBL_CHK_Flag=1 Then
	%>
	<p><ul>
	<li><a href=SiteEditFileContent.asp?file=-1>编辑新用户注册论坛协议内容</a><br>
	<li><a href=SiteEditFileContent.asp?file=-3>在线编辑联系我们（关于我们）内容</a><br>
	</ul>
	<ul>
	<%
	Dim N
	For N = 0 to DEF_BoardStyleStringNum%>
	<li><a href=SiteEditFileContent.asp?file=<%=N%>>编辑风格样式定义-<%=DEF_BoardStyleString(N)%></a> &nbsp; [<a href=DefineStyleParameter.asp?StyleID=<%=N%>>定义更多参数</a>]
	[<a href="../SiteManage/siteInfo.asp?action=upload&p_filepath=images/style/preview/&p_filename=style<%=N%>.jpg&p_fileinfo=<%=urlencode("上传风格 " & DEF_BoardStyleString(N) & " 的预览图片,必须是jpg文件，大小140x105")%>" target=_blank>
	上传风格预览图片</a>]
	<%Next%>
	</ul>
	注意，如果你的服务器不支持文件写入，将不能使用上述的任何功能，需要手动更改源程序来完成设置。
	<%
Else
DisplayLoginForm
End If
frame_BottomInfo
closeDataBase
Manage_Sitebottom("none")
%>