<!--#include file="inc/BBSsetup.asp"-->
<!--#include file="inc/Board_Popfun.asp"-->
<%siteHead("     ")%>
<body class="tbframebutton">

<script type="text/javascript">
<!--
var flag = 1;
function changel(id){
	var inputid=id;
	var forum = window.parent.document.getElementById("forum");

	if(forum.cols != "0,10"){
		forum.cols = "0,10";
		$(forum).forceRedraw(true);
	}
	else{
		forum.cols = "150,*";
	}

	if(flag == 0)
	{
		$id(inputid).src="images/<%=GBL_DefineImage%>frame/arrow-l.gif";
		flag = 1;
	}else
	{
		$id(inputid).src="images/<%=GBL_DefineImage%>frame/arrow-r.gif";
		flag = 0;
	}

}
-->
</script>
<div id="frame_button" style="cursor:pointer;" onclick="changel('hideFrame-l')">
<table border="0" cellpadding="0" cellspacing="0" style="height:100%;">
<tr><td valign="middle">
      	<img id="hideFrame-l" height="22" src="images/<%=GBL_DefineImage%>frame/arrow-l.gif" width="9" alt="关闭/展开框架" />
      </td></tr></table>
</div>
<script type="text/javascript">
<!--
	if(document.documentElement)
	{
		$id("frame_button").style.height = document.documentElement.clientHeight + "px";
	}
	else
	{
		$id("frame_button").style.height = document.body.clientHeight + "px";
	}
-->
</script>
</body>
</html>
