<!--#include file="inc/BBSsetup.asp"-->
<!--#include file="inc/Board_Popfun.asp"-->
<%siteHead("     ")%>
<body class="tbframe">
<script type="text/javascript">
function assortswap(id,obj)
{
	if($id(id).style.display=="none")
	{
		obj.className = "swap_ol";
		$id(id).style.display="block"
	}
	else
	{
		obj.className = "swap_ol_close";
		$id(id).style.display="none"
	}
}
</script>
<div class="framecontent fire">
	<div class="title">论坛导航</div>
	<div class="chn" id="OUT0s" style="DISPLAY: none">
	</div>
	<%DisplayBoardList%>
	<br />
	<a href="#" onclick="top.location=parent.r_top.document.location;">退出架框浏览</a>
</div>
</body></html>


<%
Sub DisplayBoardList

	OpenDatabase()
	Dim Rs,GetData,BoardNum
	Set Rs = Server.CreateObject("ADODB.RecordSet")
	Set Rs = LDExeCute("Select BoardID,BoardAssort,BoardName,LeadBBS_Assort.AssortName from LeadBBS_Boards left join LeadBBS_Assort on LeadBBS_Assort.AssortID=LeadBBS_Boards.BoardAssort where LeadBBS_Boards.HiddenFlag = 0 order by LeadBBS_Assort.AssortID,LeadBBS_Boards.OrderID ASC",0)
	If Not Rs.Eof Then
		GetData = Rs.GetRows(-1)
		BoardNum = Ubound(GetData,2)
	Else
		BoardNum = -1
	End If
	Rs.Close
	Set Rs = Nothing

	If BoardNum = -1 Then
	Else
		Dim CurrentAssosrt,N
		CurrentAssosrt = -1183
		Dim LastAssosrt,WriteStr
		LastAssosrt = cCur(GetData(1,BoardNum))
		Dim LastFlag
		For N = 0 to BoardNum
			If CurrentAssosrt<>cCur(GetData(1,N)) Then
				CurrentAssosrt = cCur(GetData(1,N))
				If N > 0 Then
					Response.Write "</ul></div>"
				End If
				%>
			<div class="assort">
				<a onclick="assortswap('OUT<%=N+1%>s',this);return false;" class=swap_ol_close href="Boards.asp?Assort=<%=GetData(1,N)%>" target="r_top"><%=WriteStr & GetData(3,N)%></a>
			</div>
			<div id="OUT<%=N+1%>s" style="DISPLAY: none">
			<ul><%
			End If
			%>
         		<li><a href="b/<%=RW_b(GetData(0,N),0,"")%>" target="r_top"><%=WriteStr & GetData(2,N)%></a></li>
          	<%
		Next
		Response.Write "</ul></div>"
	End If
	CloseDatabase()

End Sub%>