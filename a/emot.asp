<!-- #include file=../inc/BBSsetup.asp -->
<html>
<head>
<title>插入表情图标</title>
<meta http-equiv=Content-Type content="text/html; charset=gb2312">
<style type=text/css>
BODY {padding:5px}
IMG {CURSOR:hand;width:20px;height:20px;}
</style>
<script language=JavaScript>
function emotclick(n){
	if ("IMG"==event.srcElement.tagName.toUpperCase()) {
		if(!dialogArguments.edt_mode)
		{dialogArguments.addcontent(2,"<IMG SRC=" + event.srcElement.src + " border=0 emotid=\"" + n + "\">");}
		else
		{dialogArguments.addcontent(1,"[EM" + n + "]");}
		
		window.returnValue = null;
		//window.close();
	}
}
</script>
</head>

<body bgcolor="menu">
<table cellSpacing=5 border=0 align=center>
<%
Dim N,M
For N = 1 to DEF_UBBiconNumber
	Response.Write "<tr><td><IMG src=../images/UBBicon/em" & Right("0" & N,2) & ".GIF onclick='emotclick(""" & Right("0" & N,2) & """);'width=20 height=20 align=middle border=0></td>"
	For M = 1 to 9
		N = N + 1
		If N > DEF_UBBiconNumber Then Exit For
		Response.Write "<td><IMG src=../images/UBBicon/em" & Right("0" & N,2) & ".GIF onclick='emotclick(""" & Right("0" & N,2) & """);' width=20 height=20 align=middle border=0></td>"
	Next
	Response.Write "</tr>"
Next%>
   
</table></body></html>
