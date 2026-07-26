<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="../inc/Board_Popfun.asp"-->
<%
DEF_BBS_HomeUrl = "../"
siteHead("   选择头像")%>
<head>
	<script>
	function closeit()
	{
		setTimeout("self.close()",90000)
	}
	function MM_findObj(n, d)
	{ //v3.0
		var p,i,x;
		if(!d) d=document;
		if((p=n.indexOf("?"))>0&&parent.frames.length)
		{
			d=parent.frames[n.substring(p+1)].document; 
			n=n.substring(0,p);
		}
		if(!(x=d[n])&&d.all) x=d.all[n]; 
		for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
		for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document); 
		return x;
	}
	function MM_setTextOfTextfield(objName,x,newText)
	{ //v3.0
		var obj = MM_findObj(objName);
		if (obj) obj.value = newText;
		opener.document.LeadBBSFm.Form_userphoto.value=newText;
		opener.document.faceimg.src='<%=DEF_BBS_HomeUrl%>images/face/'+newText+'.gif'
		window.close();
	}

	function returnvalue(){
		window.returnValue = 1;
		window.close();
	}
	function cancelPost(){
		window.close();
	}
</script>
</head>
<%DisplayFacelist()%>
</body>
</html>
<%
Function DisplayFacelist

	Dim pagen,First,n
	pagen=10
	first = Left(Request.QueryString("first"),14)
	If isNumeric(first)=0 or isNull(first) then first=1
	first = Fix(cCur(first))
	If first<1 or first>DEF_faceMaxNum then first=1
	If first<>1 then first=cint(first)
	%>
	<center>论坛头像参考<table align=center cellpadding="0" cellspacing="5">
		<tr>
			<td colspan=4 bgcolor=000000>
				<img src=<%=DEF_BBS_HomeUrl%>images/Null.gif width=2 height=1></td>
		</tr>
		<tr align=left>
			<td colspan=4>
				<%
			If first-pagen>0 then
				Response.Write "<a href=facelist.asp?first=1><<首页</a>" & VbCrLf
				Response.Write "<a href=facelist.asp?first="&first-pagen&">上一页</a> " & VbCrLf
			Else
				Response.Write "<font color=999999 class=grayfont><<首页 上一页</font> " & VbCrLf
			End If

			If first+pagen<DEF_faceMaxNum then
				Response.Write "<a href=facelist.asp?first="&first+pagen&">下一页</a> <a href=facelist.asp?first="&DEF_faceMaxNum-pagen+1&">尾页>></a>" & VbCrLf
			Else
				Response.Write "<font color=999999 class=grayfont>下一页 尾页</font>" & VbCrLf
			End If%>
			</td>
		</tr>
		<%
		for n=first to first+pagen-1
			If n>DEF_faceMaxNum then exit for
			Response.Write "<tr align=center>" & VbCrLf
			Response.Write "	<td>" & VbCrLf
			Response.Write "		" & string(4-len(cstr(n)),"0") & n
			Response.Write "</td>" & VbCrLf
			Response.Write "	<td>" & VbCrLf
			Response.Write "		<a href=#1 onclick="&chr(34)&"MM_setTextOfTextfield('userface','','"&string(4-len(cstr(n)),"0")&n&"')"&chr(34)&"><img src=" & DEF_BBS_HomeUrl & "images/face/"&string(4-len(cstr(n)),"0")&n&".gif border=0 width=62 height=62></td>" & VbCrLf
			n=n+1
			if n>DEF_faceMaxNum then exit for
			Response.Write "<td>"&string(4-len(cstr(n)),"0")&n&"</td><td><a href=#1 onclick="&chr(34)&"MM_setTextOfTextfield('userface','','"&string(4-len(cstr(n)),"0")&n&"')"&chr(34)&"><img src=" & DEF_BBS_HomeUrl & "images/face/"&string(4-len(cstr(n)),"0")&n&".gif border=0 width=62 height=62></td></tr>" & VbCrLf
		next%>
		<tr>
			<td colspan=4>
				<hr size=1>
			</td>
		</tr>
	</table>
	</center>
	<center>
		<a href=#1 onclick='returnvalue();'>取消</a></center>
<%End Function%>