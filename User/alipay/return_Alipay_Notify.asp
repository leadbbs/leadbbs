<!-- #include file=../../inc/BBSsetup.asp -->
<!-- #include file=../../inc/Board_Popfun.asp -->
<%
DEF_BBS_HomeUrl = "../../"
Dim Key,partner,out_trade_no,total_fee,receive_name
Dim receive_address,receive_zip,receive_phone,receive_mobile
Dim alipayNotifyURL,Retrieval,ResponseTxt,varItem,mystr
Dim Count,i,j,md5str,mysign
Dim minmax,minmaxSlot,temp,mark,Value

 key="o48habnndc8yr4jtyf9g1p02hlt7fs7h"    ' 支付宝安全教研码
 partner="2088002030498170"  '支付宝合作id


	out_trade_no		= DelStr(Request("out_trade_no")) '获取定单号
    total_fee		    = DelStr(Request("total_fee")) '获取支付的总价格
    receive_name    =DelStr(Request("receive_name"))   '获取收货人姓名
	receive_address =DelStr(Request("receive_address")) '获取收货人地址
	receive_zip     =DelStr(Request("receive_zip"))   '获取收货人邮编
	receive_phone   =DelStr(Request("receive_phone")) '获取收货人电话
	receive_mobile  =DelStr(Request("receive_mobile")) '获取收货人手机

'******************************************判断消息是不是支付宝发出
alipayNotifyURL = "http://notify.alipay.com/trade/notify_query.do?"
alipayNotifyURL = alipayNotifyURL &"partner=" & partner & "&notify_id=" & request("notify_id")
	Set Retrieval = Server.CreateObject("Msxml2.ServerXMLHTTP.3.0")
    Retrieval.setOption 2, 13056 
    Retrieval.open "GET", alipayNotifyURL, False, "", "" 
    Retrieval.send()
    ResponseTxt = Retrieval.ResponseText
	Set Retrieval = Nothing
'*****************************************
'获取支付宝GET过来通知消息,判断消息是不是被修改过
For Each varItem in Request.QueryString
mystr=varItem&"="&Request(varItem)&"^"&mystr
Next 
If mystr<>"" Then 
mystr=Left(mystr,Len(mystr)-1)
End If 

mystr = SPLIT(mystr, "^")
Count=ubound(mystr)
'对参数排序
For i = Count TO 0 Step -1
minmax = mystr( 0 )
minmaxSlot = 0
For j = 1 To i
mark = (mystr( j ) > minmax)
If mark Then 
minmax = mystr( j )
minmaxSlot = j
End If 
Next
    
If minmaxSlot <> i Then 
temp = mystr( minmaxSlot )
mystr( minmaxSlot ) = mystr( i )
mystr( i ) = temp
End If
Next
'构造md5摘要字符串
 For j = 0 To Count Step 1
 value = SPLIT(mystr( j ), "=")
 If  value(1)<>"" And value(0)<>"sign" And value(0)<>"sign_type"  Then
 If j=Count Then
 md5str= md5str&mystr( j )
 Else 
 md5str= md5str&mystr( j )&"&"
 End If 
 End If 
 Next
md5str=md5str&key
 mysign=md5(md5str)
'********************************************************

If mysign=Request("sign") and ResponseTxt="true"   Then 	

	'response.write "付款成功页面"        '这里可以指定你需要显示的内容
	Alipay_UpdateSellList
	Response.Redirect "payment.asp?act=done&str=" & server.urlencode("<font color=green class=greenfont>付款成功,可查看您的历史订单再次确认充值情况!</font>")

Else
	'response.write "跳转失败"          '这里可以指定你需要显示的内容
	Response.Redirect "payment.asp?act=done&str=" & server.urlencode("<font color=red class=redfont>付款失败,请返回起始页面重新提交或查询历史订单核对情况!</font>")
End If

Function DelStr(Str)

	If IsNull(Str) Or IsEmpty(Str) Then
		Str	= ""
	End If
	DelStr	= Replace(Str,";","")
	DelStr	= Replace(DelStr,"'","")
	DelStr	= Replace(DelStr,"&","")
	DelStr	= Replace(DelStr," ","")
	DelStr	= Replace(DelStr,"　","")
	DelStr	= Replace(DelStr,"%20","")
	DelStr	= Replace(DelStr,"--","")
	DelStr	= Replace(DelStr,"==","")
	DelStr	= Replace(DelStr,"<","")
	DelStr	= Replace(DelStr,">","")
	DelStr	= Replace(DelStr,"%","")

End Function

Sub Alipay_UpdateSellList

	InitDatabase
	If isNumeric(out_trade_no) = 0 Then out_trade_no = 0
	out_trade_no = Fix(cCur(out_trade_no))
	If isNumeric(total_fee) = 0 Then total_fee = 0
	total_fee = Fix(cCur(total_fee))
	
	Dim Rs,UserName,PayPoints,GetPoints,PayFlag
	Set Rs = LdExeCute(sql_select("Select UserName,PayPoints,GetPoints,PayFlag From LeadBBS_SellList Where PID=" & out_trade_no,1),0)
	If Not Rs.Eof Then
		UserName = Rs(0)
		PayPoints = cCur(Rs(1))
		GetPoints = cCur(Rs(2))
		PayFlag = cCur(Rs(3))
		Rs.Close
		Set Rs = Nothing
	Else
		Rs.Close
		Set Rs = Nothing
	End If
	
	If PayFlag = 0 and PayPoints = total_fee Then '金额对应,并且未支付的情况下更新订单及用户状态
		CALL LdExeCute("Update LeadBBS_SellList Set PayFlag=1 Where PID=" & out_trade_no,1)
		CALL LdExeCute("Update LeadBBS_User Set CharmPoint=CharmPoint+" & GetPoints & " Where UserName='" & Replace(UserName,"'","''") & "'",1)
	End If
	
	CloseDatabase

End Sub
%>