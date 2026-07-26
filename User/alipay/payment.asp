<!--#include file="../../inc/BBSsetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<!--#include file="../../inc/Limit_Fun.asp"-->
<!--#include file="../inc/UserTopic.asp"-->
<!--#include file="alipayto/alipay_payto.asp"-->
<%
DEF_BBS_HomeUrl = "../../"
Main()

Sub Main

	initDatabase()
	GBL_CHK_TempStr = ""
	
	BBS_SiteHead DEF_SiteNameString & " - " & DEF_PointsName(1) & "充值",0,"" & DEF_PointsName(1) & "充值"
	
	UserTopicTopInfo("user")
	If GBL_CHK_Flag = 1 Then
		LoginAccuessFul()
	Else
		If Request("submitflag")="" Then
			DisplayLoginForm("请先登录")
		Else
			DisplayLoginForm(GBL_CHK_TempStr)
		End If
	End If
	closeDataBase()
	UserTopicBottomInfo()
	SiteBottom()

End Sub

Function LoginAccuessFul

              Dim act
              act = Left(Request.QueryString("act"),20)
              Payment_nav(act)
              
              Select Case act
              	Case "done":
              		Response.Write "<b>" & Request.QueryString("str") & "</b>"
              	Case "list":
              		Alipay_SellList()
              	Case Else
              		DisplayPaymentForm()
              End Select
    
End Function

Sub Payment_nav(Evol)

	Response.Write "<div class='user_item_nav fire'><ul>"
	Response.Write "<li><div class=name>" & DEF_PointsName(1) & "充值</div></li>"
	If Evol = "list" Then
		%><li><div class=navactive>历史订单</div></li>
		<li><a href="payment.asp">立即充值</a></li><%
	Else%>
		<li><a href="payment.asp?act=list">历史订单</a></li>
		<li><div class=navactive>立即充值</div></li><%
	End If
	Response.Write "</ul></div>"
	

End Sub

Dim shijian,dingdan,subject,body,out_trade_no,price,quantity,discount,AlipayObj,itemUrl

Sub PaymentSubmit

	If DEF_seller_email = "" Then
		Response.Write "<div class=alert>网站未开通此项服务.</div>"
		Exit Sub
	End If

	GBL_CHK_TempStr = ""
	If CheckUserAnnounceLimit() = 0 Then
		Response.Write "<div class=alert>" & GBL_CHK_TempStr & "</div>"
		Exit Sub
	End If
	Dim Rs,PreSellTime
	Set Rs = LdExeCute(sql_select("Select PID,SellTime,UserName from LeadBBS_SellList where UserName='" & Replace(GBL_CHK_User,"'","''") & "' and PayFlag = 0 Order by ID DESC",1),0)
	If Not Rs.Eof Then
		PreSellTime = cCur(Rs(1))
	Else
		PreSellTime = 0
	End If
	Rs.Close
	Set Rs = Nothing
	
	If PreSellTime > 0 Then
		If DateDiff("s",RestoreTime(GBL_UDT(13)),DEF_Now) < 5 Then
			GBL_CHK_TempStr = "订单提交太频,请稍候再提交."
			Exit Sub
		End If
	End If
	
	'删除旧未付款订单(7天前)
	CALL LdExeCute("Delete from LeadBBS_SellList where UserName='" & Replace(GBL_CHK_User,"'","''") & "' and PayFlag = 0 and SellTime<" & GetTimeValue(DateAdd("d",-7,DEF_Now)) & "",1)

	Dim PayPoints
	PayPoints = Left(Request.Form("PayPoints"),14)
	If isNumeric(PayPoints) = False Then PayPoints = 0
	PayPoints = Fix(cCur(PayPoints))
	If PayPoints < DEF_seller_minpoints Then
		GBL_CHK_TempStr = "本次充值数额不能少于 " & DEF_seller_minpoints & " 点"
		Exit Sub
	End If
	
	shijian=now()
	dingdan= GetTimeValue(DEF_Now)
	'客户网站订单号，（现取系统时间，可改成网站自己的变量）
	
	Dim LoopN
	LoopN = 0
	For LoopN = 0 To 9
		Set Rs = LdExeCute(sql_select("Select ID from LeadBBS_SellList where PID=" & dingdan & Right("00" & LoopN,1),1),0)
		If Rs.Eof Then
			dingdan = cCur(dingdan & Right("00" & LoopN,1))
			Rs.Close
			Set Rs = Nothing
			Exit For
		Else
			Rs.Close
			Set Rs = Nothing
		End If
	Next
		
	
	'subject			=	DEF_PointsName(1) & "充值"		'商品名称
	'body			=	"论坛" & DEF_PointsName(1) & "充值，共" & PayPoints*DEF_seller_exchangescale & "点"		'body			商品描述
	subject			=	dingdan		'商品名称
	body			=	"value" & PayPoints*DEF_seller_exchangescale & ""		'body			商品描述
	out_trade_no    =   dingdan
	price		    =	PayPoints				'price商品单价			0.01～50000.00
	quantity        =   "1"               '商品数量,如果走购物车默认为1
	discount        =   "0"               '商品折扣
	Set AlipayObj	= New creatAlipayItemURL
	itemUrl=AlipayObj.creatAlipayItemURL(subject,body,out_trade_no,price,quantity,seller_email)
	
	'添加保存订单
	CALL LdExeCute("insert into LeadBBS_SellList(PID,UserName,PayPoints,GetPoints,SellTime,PayFlag) Values(" &_
		dingdan &_
		",'" & Replace(GBL_CHK_User,"'","''") & "'" &_
		"," & PayPoints & "" &_
		"," & PayPoints*DEF_seller_exchangescale & "" &_
		"," & GetTimeValue(DEF_Now) & "" &_
		",0)",1)
	%>
	<form id="PaymentForm" method="post" action="<%=itemUrl%>" method=get target="_blank">
	<table cellspacing="0" cellpadding="0" class=blanktable>
	<tr>
	<td><b>充入账户</b></td>
	<td><%=htmlencode(GBL_CHK_User)%></td>
	</tr>
	<tr>
	<td><b>充值金额</b></td>
	<td><%=PayPoints%>元</td>
	</tr>
	<tr>
	<td><b>购买<%=DEF_PointsName(1)%>点数</b></td>
	<td><%=PayPoints*DEF_seller_exchangescale%>点</td>
	</tr>
	<tr>
	<td><b>订单号</b></td>
	<td><%=dingdan%></td>
	</tr>
	<tr>
	<td colspan=2><br/>请确认以上信息，点击以下按钮提交订单支付
	<br><br>
	<input type="submit" value=立即支付 class="fmbtn btn_3" />
	</td></tr></table>
	</form>
	<%

End Sub

Sub DisplayPaymentForm

	GBL_CHK_TempStr = ""
	If Request.Form("action") = "submitpayment" Then
		PaymentSubmit()
		If GBL_CHK_TempStr <> "" Then
			Response.Write "<div class=alert>错误提示：" & GBL_CHK_TempStr & "</div>"
		Else
			Exit Sub
		End If
	End If
	%>
	<form id="PaymentForm" method="post" action="payment.asp">
	<input type="hidden" name="action" value="submitpayment">
	<table cellspacing="0" cellpadding="0" class=blanktable>
	<tr>
	<td><b>充值<%=DEF_PointsName(1)%>规则</b></td>
	<td>
	人民币现金 <b>1</b> 元 = <%=DEF_PointsName(1)%> <b><%=1*DEF_seller_exchangescale%></b> 点	<br>本次最低充值 <%=DEF_PointsName(1)%> <b><%=DEF_seller_minpoints%></b> 点
	</td>
	</tr>
	<tr>
	<td><b>充值人民币金额</b></td>
	<td>
	<script>
	function $id(id)
	{
		return(document.getElementById(id));
	}
	function refreshMoney()
	{
		var PayPoints = parseInt($id('PayPoints').value);
		if(isNaN(PayPoints))
		{
			PayPoints = 0;
			alert("充值金额请使用数字.");
			$id('PayPoints').value="";
		}
		else
		{
			$id('PayPoints').value=PayPoints;
		}
		$id('payment_money').innerHTML = PayPoints;
		$id('payment_points').innerHTML = PayPoints*<%=DEF_seller_exchangescale%>;
	}
	</script>
	<input name=PayPoints id=PayPoints onchange="refreshMoney()" class="fminpt input_2" /> 元</td>
	</tr>

	<tr>
	<td><b>您共需要在线支付</b></td>
	<td>人民币 <span id="payment_money">0</span> 元 可购得<%=DEF_PointsName(1)%>点数 <span id="payment_points">0</span> 点</td>
	</tr>

	<tr>
	<td></td>
	<td>
	<div class=value2>
	此项充值服务以人民币现金在线支付，购买论坛各方面使用的虚拟币：<%=DEF_PointsName(1)%><br>
	积分充值不能撤销或退款，请您在充值前确定并仔细核对充值的金额。
	</div>
	<br />
	<div class=value2>
	您成功支付后系统可能需要几分钟的时间等待支付结果，因此可能无法瞬间入账。<br>
	如果超过48小时仍未收到通知短消息，请与论坛管理员联系。
	</div></td>
	</tr>
	<tr class="btns">
		<td>&nbsp;</td>
		<td>
			<input type="submit" value=提交 class="fmbtn btn_2" /></td>
	</tr>
	</table>

	</form>
	<%

End Sub

Sub Alipay_SellList

	Dim Rs,payflag,SQL
	payflag = Request.QueryString("payflag")
	If CheckSupervisorUserName() = 0 Then
		If payflag = "0" Then
			payflag = 0
			SQL = " where UserName='" & Replace(GBL_CHK_User,"'","''") & "' and PayFlag=0"
		ElseIf payflag = "1" Then
			payflag = 1
			SQL = " where UserName='" & Replace(GBL_CHK_User,"'","''") & "' and PayFlag=1"
		Else
			payflag = -1
			SQL = " where UserName='" & Replace(GBL_CHK_User,"'","''") & "'"
		End If
	Else
		If payflag = "0" Then
			payflag = 0
			SQL = " where PayFlag=0"
		ElseIf payflag = "1" Then
			payflag = 1
			SQL = " where PayFlag=1"
		Else
			payflag = -1
			SQL = ""
		End If
	End If
	Dim GetData,Count
	SQL = sql_select("Select ID,PID,UserName,PayPoints,GetPoints,SellTime,PayFlag From LeadBBS_SellList" & SQL & " Order by ID DESC",150)
	Set Rs = LdExeCute(SQL,0)
	If Not Rs.Eof Then
		GetData = Rs.GetRows(-1)
		Count = Ubound(GetData,2)
	Else
		Count = -1
	End If
	Rs.Close
	Set Rs = Nothing
	%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class=table_in>
	<tr class=tbinhead>
		<td><div class=value>订单号</div></td>
		<td><div class=value>用户</div></td>
		<td><div class=value>额(元)</div></td>
		<td><div class=value>兑换值</div></td>
		<td><div class=value>时间</div></td>
		<td><div class=value>状态</div></td>
	</tr>
	<%
	Dim N
	If Count >= 0 Then
	For N = 0 to Count
		%>
	<tr>
		<td class=tdbox><%=GetData(1,N)%></td>
		<td class=tdbox><%=htmlencode(GetData(2,N))%></td>
		<td class=tdbox><%=GetData(3,N)%></td>
		<td class=tdbox><%=GetData(4,N)%></td>
		<td class=tdbox><%=RestoreTime(GetData(5,N))%></td>
		<td class=tdbox><%If GetData(6,N) = 0 Then
			Response.Write "未付款"
		Else
			Response.Write "<span class=greenfont>已付款</span>"
		End If%></td>
	</tr>
		<%
	Next
	End If

	Response.Write "<tr><td class=tdbox colspan=6><div class=j_page>"
	If payflag = -1 Then
		Response.Write "<b>全部订单</b>"
	Else
		Response.Write "<a href=""payment.asp?act=list"">全部订单</a>"
	End If
	If payflag = 1 Then
		Response.Write "<b>已付款</b>"
	Else
		Response.Write "<a href=""payment.asp?act=list&payflag=1"">已付款</a>"
	End If
	If payflag = 0 Then
		Response.Write "<b>未付款</b>"
	Else
		Response.Write "<a href=""payment.asp?act=list&payflag=0"">未付款</a>"
	End If
	If CheckSupervisorUserName() = 1 Then Response.Write " <b><span class=gray>您是管理员,以下显示为全部用户订单信息</span></b>"
	%>
	</div>
	</td>
	</tr>
	</table>
	<%

End Sub
%>