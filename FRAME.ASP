<!-- #include file=inc/BBSsetup.asp -->
<%

function LD_GetUrl(dir)

	dim d : d = Request.ServerVariables("server_name")
	dim p : p = Request.ServerVariables("SERVER_PORT")
	if p <> "80" Then d = d & Server.UrlEncode(p)
	
	if dir = 1 then '返回论坛安装目录
		d = d & DEF_Installdir
	elseif dir = 2 then '返回当前文件url
		d = d & Request.Servervariables("SCRIPT_NAME")
	else
		d = ""
	end if
	
	dim pl : pl = Request.ServerVariables("SERVER_PROTOCOL")
	dim t
	t = inStr(pl,"/")
	if t > 0 then
		pl = left(LCase(pl), t - 1)
	end if

	dim s
	if Request.ServerVariables("HTTPS") <> "on" then
		s = ""
	else
		s = "s"
	end if
	LD_GetUrl = pl & s & "://" & d

end function


function filterUrlstr(str)

	filterUrlstr = replace(replace(replace(str,"<","%3c"),"""","%22"),"'","%27")

End function

Dim GBL_FrameUrl
GBL_FrameUrl = filterUrlstr(Request.QueryString("u"))
If GBL_FrameUrl = "" Then
	GBL_FrameUrl = LD_GetUrl(1)
	If Left(LCase(Request.ServerVariables("HTTP_REFERER")),Len(GBL_FrameUrl)) = GBL_FrameUrl Then
		GBL_FrameUrl = filterUrlstr(Request.ServerVariables("HTTP_REFERER"))
	Else
		GBL_FrameUrl = "Boards.asp"
	End If
End If
//response.Write GBL_FrameUrl
//Response.End
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"  xml:lang="zh-CN" lang="zh-CN">
<title><%=DEF_SiteNameString%></title>
</head>
<script type="text/javascript">   
if(top.location != self.location)   
top.location=self.location;   
</script>
<frameset id="forum" name="forum" cols="150,*" frameborder="NO" border="0" framespacing="0">
	<frameset name="left" rows="0,*" cols="*" framespacing="0" frameborder="NO" border="0">
		<frame src="" name="topFrame" scrolling="NO" noresize marginwidth="0" marginheight="0">
		<frame src="BoardNav.asp" name="leftFrame" scrolling="NO" noresize marginwidth="0" marginheight="1">
	</frameset>
	<frameset cols="10,*" border="0" framespacing="0">
		<frame src="frame_button.asp" noresize name="button" scrolling="NO">
		<frame src="<%=GBL_FrameUrl%>" scrolling="auto" name="r_top" scrolling="yes">
	</frameset>
</frameset>
<noframes><body></body></noframes>
</html>