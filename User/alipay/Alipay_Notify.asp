<!--#include file="../../inc/BBSSetup.asp"-->
<!--#include file="../../inc/Board_Popfun.asp"-->
<%
DEF_BBS_HomeUrl = "../../"

Main()

Sub Main

	Dim Key,partner,out_trade_no,total_fee,receive_name
	Dim receive_address,receive_zip,receive_phone,receive_mobile
	Dim alipayNotifyURL,Retrieval,ResponseTxt,varItem,mystr
	Dim Count,i,j,md5str,mysign,trade_status,returnTxt
	Dim TOEXCELLR
	dim strsss
	Dim minmax,minmaxSlot,mark,temp,value


	'功能：付款过程中服务器通知页面
	'版本：2.0
	'日期：2008-10-24
	'作者：支付宝公司销售部技术支持团队
	'联系：0571-26888888
	'版权：支付宝公司

	key=""         '支付宝安全教研码
	partner=""     '支付宝合作id 
 
	out_trade_no	=DelStr(Request.Form("out_trade_no"))      '获取定单号
	total_fee		=DelStr(Request.Form("total_fee"))         '获取支付的总价格
	'如需获取其它参数，可填写 参数 =DelStr(Request.Form("获取参数名"))
	
	'*******************判断消息是不是支付宝发出***********************
	alipayNotifyURL = "http://notify.alipay.com/trade/notify_query.do?"
	alipayNotifyURL = alipayNotifyURL &"partner=" & partner & "&notify_id=" & request.Form("notify_id")
		Set Retrieval = Server.CreateObject("Msxml2.ServerXMLHTTP.3.0")
	    Retrieval.setOption 2, 13056 
	    Retrieval.open "GET", alipayNotifyURL, False, "", "" 
	    Retrieval.send()
	    ResponseTxt = Retrieval.ResponseText
		Set Retrieval = Nothing
	'*******************************************************************
	
	'*******************获取支付宝POST过来通知消息**********************
	For Each varItem in Request.Form
		mystr=varItem&"="&Request.Form(varItem)&"^"&mystr
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
	
	'*************************交易状态返回处理*************************
	If mysign=request.Form("sign") And ResponseTxt="true" Then 	
		If request.Form("trade_status") = "TRADE_FINISHED" Then 
			'在此处添加：付款成功,更新数据库语句  
		 	returnTxt	= "success"
		 	CALL Alipay_UpdateSellList(out_trade_no,total_fee)
		Else
			returnTxt	= "fail"
		End If
		Response.Write returnTxt
	Else
	response.write "fail"
	End If 
	'*******************************************************************
	 '写文本，方便测试（看网站需求，也可以改成存入数据库）
	TOEXCELLR=TOEXCELLR&md5str&"MD5结果:"&mysign&"="&request.Form("sign")&"--ResponseTxt:"&ResponseTxt
	
	strsss = VbCrLf & "ResponseTxt:" & ResponseTxt & VbCrLf
	strsss = strsss & "mysign:" & mysign & VbCrLf
	strsss = strsss & "mysign_form:" & request.Form("sign") & VbCrLf
	strsss = strsss & "trade_status:" & request.Form("trade_status") & VbCrLf
	strsss = strsss & "time:" & DEF_Now & VbCrLf
	strsss = strsss & "out_trade_no:" & out_trade_no & VbCrLf
	strsss = strsss & "total_fee:" & total_fee & VbCrLf

	'CALL ADODB_SaveToFile(TOEXCELLR&strsss,"alipayto/Notify_DATA/"&replace(now(),":","")&".txt")

End Sub

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


Sub Alipay_UpdateSellList(out_trade_no,total_fee)

	OpenDatabase()
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
		GetPoints = 0
	End If
	
	If PayFlag = 0 and PayPoints = total_fee Then '金额对应,并且未支付的情况下更新订单及用户状态
		CALL LdExeCute("Update LeadBBS_SellList Set PayFlag=1 Where PID=" & out_trade_no,1)
		CALL LdExeCute("Update LeadBBS_User Set CharmPoint=CharmPoint+" & GetPoints & " Where UserName='" & Replace(UserName,"'","''") & "'",1)
	End If
	
	CloseDatabase()

End Sub
%>