<!--#include file="alipayto/Alipay_Payto.asp"-->
<%
   shijian=now()
   dingdan=year(shijian)&month(shijian)&day(shijian)&hour(shijian)&minute(shijian)&second(shijian)
    '客户网站订单号，（现取系统时间，可改成网站自己的变量）
	
	subject			=	"测试订单号"		'商品名称
	body			=	"a"		'body			商品描述
	out_trade_no    =   dingdan       
	price		    =	"0.01"				'price商品单价			0.01～50000.00
    quantity        =   "1"               '商品数量,如果走购物车默认为1
	discount        =   "0"               '商品折扣
    seller_email    =    seller_email   '卖家的支付宝帐号
	Set AlipayObj	= New creatAlipayItemURL
	itemUrl=AlipayObj.creatAlipayItemURL(subject,body,out_trade_no,price,quantity,seller_email)
%>
<table border="0" cellspacing="1" cellpadding="0" align="center" valign=absmiddle width=450>
<tr><td align=center width=50% height=120>
<a href="<%=itemUrl%>" target="_blank"><img src="alipayto/images/alipay_bwrx.gif" border="0"></a>
</td>
</tr>
<tr><td colspan=2 align=center>本站使用支付宝支付平台，在线实时支付<br><br>
<a href='http://www.alipay.com'  target="_blank"><img src='https://img.alipay.com/pimg/logo.gif' border=0></a>
</td></tr>
</table>	