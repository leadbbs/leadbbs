<%
'jmail.message方式发送
const DEF_MAIL_smtpUser = "" '当邮件服务器使用SMTP发信验证时设置的登录帐户。
const DEF_MAIL_smtpPass = "" '使用SMTP发信验证时设置的登录密码。
const DEF_MAIL_smtpHost = "" '邮件服务器地址(IP或域名)
const DEF_MAIL_FromName = "LeadBBS" '发件人的名称，可以填写您网站的名称

const DEF_SMS_UID = "" '中国189电信天翼的Appid或网建手机短信发送UID，天翼申请: <a href=http://open.189.cn/ target=_blank>http://open.189.cn/</a>, 网建申请: <a href=http://sms.webchinese.cn/ target=_blank>http://sms.webchinese.cn/</a>
const DEF_SMS_KEY = "" '189天翼的App Secret 或 网建手机短信发送KEY (若是中国天翼，确保自己有短信验证码能力)

if len(DEF_SMS_UID)>15 and len(DEF_SMS_KEY) = 32 then
%>
<!--#include file="../../inc/sha1.asp"-->
<%
end if

class tianyi_send_class

	public function tianyi_send(phone,randcode)
	
		dim access_token,tmp 'client_credentials获取的access_token，无需openid
		dim tmp_token '短信验证码发送3分内有效的token
		dim timestamp '时间戳，格式为：yyyy-MM-dd hh:mm:ss
		timestamp = restoretime(getTimeValue(DEF_Now))
		
		tmp = getaccesstoken(0)
		if tmp(1) = 0 then
			tianyi_send = -1
			Response.Write " send error:" & htmlencode(tmp(0))
			exit function
		end if
		access_token = tmp(0)
		
		dim tmp2		
		tmp2 = get_tmp_token(access_token,timestamp)
		if tmp2(1) = 0 then
			tianyi_send = -1
			Response.Write " send error:" & htmlencode(tmp2(0))
			exit function
		end if
		tmp_token = tmp2(0)
		
		dim tmp3
		tmp3 = sending(access_token,tmp_token,phone,randcode,timestamp)
		if tmp3(1) = 0 then
			tianyi_send = -1
			Response.Write " send error:" & htmlencode(tmp3(0))
		else
			tianyi_send = 1
		end if
	
	end function
	
	private function sending(access_token,token,phone,randcode,timestamp)
	
		dim url,dd
		url = "http://api.189.cn/v2/dm/randcode/sendSms"
		dim par,sign
		
		dim exp_time : exp_time = 600
		
		par = "access_token=" & access_token &_
			"&app_id=" & DEF_SMS_UID&_
			"&exp_time=" & exp_time &_
			"&phone=" & phone &_
			"&randcode=" & randcode &_
			"&timestamp=" & timestamp &_
			"&token=" & token
		sign = b64_hmac_sha1(DEF_SMS_KEY,par)

		par = "access_token=" & access_token &_
			"&app_id=" & DEF_SMS_UID&_
			"&exp_time=" & exp_time &_
			"&phone=" & phone &_
			"&randcode=" & randcode &_
			"&timestamp=" & urlencode(timestamp) &_
			"&token=" & token
		dim tmp
		
		dd = par & "&sign=" & urlencode(sign)
		tmp = RequestUrl_post(url,dd)
		if inStr(tmp,"identifier")>0 and inStr(tmp,"create_at") > 0 then
			sending = array(tmp,1)
		else
			sending = array(tmp,0)
		end if
	
	end function
	
	private function getaccesstoken(ty)
	
		dim url,dd,tmp		
		dim access_token
		
		access_token = Application(DEF_MasterCookies & "_tianyiatoken") & ""
		if len(access_token) > 20 and ty = 0 then
			getaccesstoken = array(access_token,1)
			exit function
		end if

		
		url = "https://oauth.api.189.cn/emp/oauth2/v3/access_token"
		dd = "grant_type=client_credentials"&_
			"&app_id=" & DEF_SMS_UID &_
			"&app_secret=" & DEF_SMS_KEY
		tmp = RequestUrl_post(url,dd)
		access_token = CutStr(tmp, """access_token"":""","""")
		
		if len(access_token) <= "" then
			getaccesstoken = array(tmp,0)
		else
			Application.Lock
			Application(DEF_MasterCookies & "_tianyiatoken") = access_token
			Application.UnLock
			getaccesstoken = array(access_token,1)
		end if
	
	end function
	
	private function get_tmp_token(token,t)
	
		dim url,par
		url = "http://api.189.cn/v2/dm/randcode/token?"
		'par = "access_token=" & token &_
		'		"&app_id=" & DEF_SMS_UID &_
		'		"&timestamp=" & urlencode(t)
		
		dim tt
		tt = t
		tt = "2014-04-09 23:35:00"
		par = "access_token=" & token &_
				"&app_id=" & DEF_SMS_UID &_
				"&timestamp=" & t

				
		dim sign
		sign = b64_hmac_sha1(DEF_SMS_KEY,par)
		
		par = "access_token=" & token &_
				"&app_id=" & DEF_SMS_UID &_
				"&timestamp=" & urlencode(t)
		url = url & par & "&sign=" & urlencode(sign)
		
		dim tmp
		tmp = RequestUrl(url)
		
		dim toke
		toke = CutStr(tmp, """token"":""","""")
		
		if len(toke) <= "" then
			get_tmp_token = array(tmp,0)
		else
			get_tmp_token = array(toke,1)
		end if
		
	end function
	
	
	private Function CutStr(data,s_str,e_str)
	
		    If Instr(data,s_str)>0 and Instr(data,e_str)>0 Then
			   CutStr = Split(data,s_str)(1)
			   CutStr = Split(CutStr,e_str)(0)
			Else
			   CutStr = ""
			End If
	
	End Function
	
end class




Function SendJmail_Message(Email,Topic,MailBody)

	Dim msg
	set msg = Server.CreateOBject( "JMail.Message" )
	msg.Logging = true
	msg.silent = false
	msg.From = DEF_MAIL_smtpUser
	msg.FromName = DEF_MAIL_FromName
	msg.AddRecipient Email
	msg.Subject = Topic
	msg.Charset="utf-8"
	msg.ContentType = "text/html"
	msg.Body = MailBody
	msg.Priority = 1
	msg.MailServerUserName = DEF_MAIL_smtpUser
	msg.MailServerPassword = DEF_MAIL_smtpPass
	if not msg.Send( DEF_MAIL_smtpHost ) then 'mail server
		Response.write "<pre>" & msg.log & "</pre>"
		SendJmail_Message = 0
	else
		SendJmail_Message = 1
	end if
	Set msg = Nothing

End Function

'发送sms短信
Function SendSMS_Message(stel,MailBody,AttestNumber,resetcode)

	dim tel : tel = stel
	
	if CheckMobilePhone(tel) = false then
		SendSMS_Message = -7777 '号码错误
		exit function
	end if
	tel = fix(ccur(tel))

	'天翼只能发送一个验证码
	if len(DEF_SMS_UID)>15 and len(DEF_SMS_KEY) = 32 then
		dim tianyisend_class
		set tianyisend_class = new tianyi_send_class
		dim code : code = resetcode
		if code = 0 then code = AttestNumber
		if code = 0 then
			SendSMS_Message = -5555
			set tianyisend_class = nothing
			exit function
		end if
		SendSMS_Message = tianyisend_class.tianyi_send(tel,code)
		set tianyisend_class = nothing
		exit function
	end if

	'网建允许自定义，可任意发送
	dim url
	if DEF_SMS_UID = "" then
		SendSMS_Message = -9999 '未设置SMS
		exit function
	end if
	if len(MailBody)>70 then
		SendSMS_Message = -8888 '短信内容过长
		exit function
	end if
		
	url = "http://gbk.sms.webchinese.cn/?" &_
	"Uid=" & urlencode(DEF_SMS_UID) &_
	"&Key=" & urlencode(DEF_SMS_KEY) &_
	"&smsMob=" & urlencode(tel) &_
	"&smsText=" & urlencode(MailBody)
	
	SendSMS_Message = toNum(RequestUrl(url),-10000)

End Function


Function RequestUrl(url)

		dim XmlObj		
		Set XmlObj = Server.CreateObject("Msxml2.ServerXMLHTTP.3.0")
		XmlObj.open "GET",url, false
		XmlObj.send
		On Error Resume Next
		RequestUrl = XmlObj.responseText
		if err then
			err.clear
			RequestUrl = BytesToBstr(XmlObj.responseBody)
		end if
		Set XmlObj = nothing

End Function

	'Post方法请求url,获取请求内容
	Private Function RequestUrl_post(url,data)
		dim XmlObj
		'Set XmlObj = Server.CreateObject(CheckXml())
		Set XmlObj = Server.CreateObject("Msxml2.ServerXMLHTTP.3.0")
		XmlObj.open "POST", url, false
		'XmlObj.setrequestheader "POST"," /t/add_t HTTP/1.1"
		'XmlObj.setrequestheader "Host"," graph.qq.com"
		XmlObj.setrequestheader "content-length",len(data)  
      XmlObj.setRequestHeader "Content-Type"," application/x-www-form-urlencoded "
		XmlObj.setrequestheader "Connection"," Keep-Alive"
        XmlObj.setrequestheader "Cache-Control"," no-cache"
        XmlObj.send(data)
		On Error Resume Next
		RequestUrl_post = XmlObj.responseText
		if err then
			err.clear
			RequestUrl_post = BytesToBstr(XmlObj.responseBody)
		end if
		Set XmlObj = nothing
	End Function

Function BytesToBstr(body) 
	
		'on error resume next
		dim objstream
		set objstream = Server.CreateObject("adodb.stream")
		with objstream
		.Type = 1
		.Mode = 3
		.Open
		.Write body 
		.Position = 0
		.Type = 2
		.Charset = "utf-8"
		
		if request.querystring("utf8") = "1" then
			Response.Charset="UTF-8"
			response.codepage = 65001
			.Charset = "UTF-8"
		end if
		BytesToBstr = .ReadText
		.Close
		end with
		set objstream = nothing
	
End Function

'jmail.smtpmail发送
Function SendJmail(Email,Topic,MailBody)

	If DEF_MAIL_smtpUser <> "" Then
		SendJmail = SendJmail_Message(Email,Topic,MailBody)
		exit function
	end if
	Dim JMail
	'on error resume next
	Set JMail = Server.CreateObject("JMail.SMTPMail")
	JMail.LazySend = true
	JMail.silent = false
	JMail.Charset = "utf-8"
	JMail.ContentType = "text/html"
	JMail.Sender = "mail377234@yourmail.com" '改为你的邮箱
	JMail.ReplyTo = "mail377234@yourmail.com" '改为你的邮箱
	JMail.SenderName = "LeadBBS邮件发送"
	JMail.Subject = Topic
	JMail.SimpleLayout = true
	JMail.Body = MailBody
	JMail.Priority = 1
	JMail.AddRecipient Email
	JMail.AddHeader "Originating-IP", GBL_IPAddress
	If JMail.Execute() = false Then
		SendJmail = 0
	Else
		SendJmail = 1
	End If
	JMail.Close
	Set JMail = Nothing

End Function

Function SendEasyMail(Email,Topic,MailBody,TextBody)

	'on error resume next
	dim Mailsend
	set Mailsend = Server.CreateObject("easymail.Mailsend")
	Dim Tid,Un
	Un = "qfy@yp.cn"  '您的邮件服务器登录名，不需要密码

	Dim EI
	Set EI = server.CreateObject("easymail.Users")
	Tid = EI.Login(un)
	Set EI = Nothing
	Mailsend.createnew Un,Tid '邮箱账号,临时ID
	Mailsend.CharSet = "utf-8"  '编码
	Mailsend.MailName = "LeadBBS"  '发件人名

	Mailsend.EM_BackAddress = "" '邮件回复地址
	Mailsend.EM_Bcc = "" '暗送地址
	Mailsend.EM_Cc = "" '抄送地址
	Mailsend.EM_OrMailName = "" '原邮件名
	Mailsend.EM_Priority = "Normal" '邮件重要度	
	Mailsend.EM_ReadBack = false '是否读取确认,挂号信(限本系统内用户)	
	Mailsend.EM_SignNo = -1  '使用签名的序号
	
	Mailsend.EM_Subject = Topic '主题
	Mailsend.EM_Text = TextBody '内容
	Mailsend.EM_HTML_Text = MailBody 'HTML邮件内容
	Mailsend.useRichEditer = true '发送的是否为HTML格式邮件

	Mailsend.EM_TimerSend = ""  '定时发送的时间
	Mailsend.EM_To = Email '收件人地址
	Mailsend.ForwardAttString = "" '转发邮件时的原附件

	Mailsend.AddFromAttFileString = "" '添加自网络存储中的文件名

	Mailsend.SystemMessage = false '是否是系统邮件

	Mailsend.SendBackup = false '是否保存发送邮件
	
	If Mailsend.Send() = false Then
		SendEasyMail = 0
	Else
		SendEasyMail = 1
	End If
	Set Mailsend = nothing

End Function

Function SendCDOMail(Email,Topic,TextBody)

	dim  objCDOMail
	Set objCDOMail = Server.CreateObject("CDONTS.NewMail")
	objCDOMail.From ="mail377234@yourmail.com" '改为你的邮箱
	objCDOMail.To = Email
	objCDOMail.Subject = Topic

	objCDOMail.Body = TextBody

	objCDOMail.Send
	Set objCDOMail = Nothing
	SendCDOMail = 1

End Function
%>