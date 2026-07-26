<%
Const apiKey = "" 'APP ID,您需要从腾讯平台申请获取资料：(<a href=http://connect.qq.com/ target=_blank>点此申请</a>)
Const secretKey = "" 'APP KEY,您需要从腾讯平台申请获取
Const callback = "" 'CALL BACK,回调地址，注意只需要填写域名，不包括http及目录。

const tqq_apikey = "" '腾讯微博 API Key <a href=http://open.t.qq.com/apps_welcome.php target=_blank>http://open.t.qq.com/apps_welcome.php</a> 申请
const tqq_secretKey = "" '腾讯微博 secretKey

const weibo_apikey = "" '新浪微博 API Key <a href=http://open.weibo.com target=_blank>http://open.weibo.com</a> 申请
const weibo_secretKey = "" '新浪微博 secretKey

const baidu_apikey = "" '百度 API Key <a href=http://developer.baidu.com/ target=_blank>http://developer.baidu.com/</a> 申请
const baidu_secretKey = "" '百度 secretKey 注意在百度设置好正确的回调页(参考 http://developer.baidu.com/wiki/index.php?title=docs/oauth/redirect)，比如需要填写完整: http://www.leadbbs.com/app/qqlogin/login.asp

const renren_apikey = "" '人人网 API Key <a href=http://app.renren.com/developers/newapp target=_blank>http://app.renren.com/developers/newapp</a> 申请
const renren_secretKey = "" '人人网 secretKey

const kaixin_apikey = "" '开心网 API Key <a href=http://open.kaixin001.com/ target=_blank>http://open.kaixin001.com/</a> 申请
const kaixin_secretKey = "" '开心网 secretKey

const tianyi_apikey = "" '天翼 API Key <a href=http://open.189.cn/ target=_blank>http://open.189.cn/</a> 申请
const tianyi_secretKey = "" '天翼 secretKey

const youku_apikey = "" '优酷 API Key <a href=http://open.youku.com/ target=_blank>http://open.youku.com/</a> 申请
const youku_secretKey = "" '优酷 secretKey

const tudou_apikey = "" '土豆 API Key <a href=http://open.tudou.com/ target=_blank>http://open.tudou.com/</a> 申请
const tudou_secretKey = "" '土豆 secretKey

dim connect_list:connect_list = array("QQ帐号","腾讯微博帐号","微博帐号","百度帐号","支付宝帐号","人人网帐号","开心网帐号","电信天翼帐号","优酷帐号","土豆帐号")
dim connect_allow:connect_allow = array(1,1,1,1,0,0,0,0,0,0)
dim connect_apptype:connect_apptype = array(1,2,3,4,5,6,7,8,9,10)

Dim return_QueryString : return_QueryString = ""

' AxonASP compat: assigning to a module-level array element from inside a
' Class fails ("Object doesn't support this property or method"). Route the
' writes through this module-level Sub, called via Call, which works.
Sub SetConnectAllow(idx, val)
	connect_allow(idx) = val
End Sub

Class QqConnet

	Private QQ_CALLBACK_URL
	Private cur_SCOPE
	public cur_apptype
	public cur_apiKey
	private cur_secretKey
	private token_string
	private apenid_string
        
	Private Sub Class_Initialize
    
    	if apiKey = "" then
    		Call SetConnectAllow(0, 0)
    	else
    		Call SetConnectAllow(0, 1)
    	end if
    	
    	if tqq_apikey = "" then
    		Call SetConnectAllow(1, 0)
    	else
    		Call SetConnectAllow(1, 1)
    	end if
    	
    	if weibo_apikey = "" then
    		Call SetConnectAllow(2, 0)
    	else
    		Call SetConnectAllow(2, 1)
    	end if
    	
    	if baidu_apikey = "" then
    		Call SetConnectAllow(3, 0)
    	else
    		Call SetConnectAllow(3, 1)
    	end if
    	
    	if renren_apikey = "" then
    		Call SetConnectAllow(5, 0)
    	else
    		Call SetConnectAllow(5, 1)
    	end if
    	
    	if kaixin_apikey = "" then
    		Call SetConnectAllow(6, 0)
    	else
    		Call SetConnectAllow(6, 1)
    	end if
    	
    	if tianyi_apikey = "" then
    		Call SetConnectAllow(7, 0)
    	else
    		Call SetConnectAllow(7, 1)
    	end if
    	
    	if youku_apikey = "" then
    		Call SetConnectAllow(8, 0)
    	else
    		Call SetConnectAllow(8, 1)
    	end if
    	
    	if tudou_apikey = "" then
    		Call SetConnectAllow(9, 0)
    	else
    		Call SetConnectAllow(9, 1)
    	end if

		cur_apptype = toNum(request.querystring("apptype"),0)
		class_getCur_appKey(cur_apptype)
		QQ_CALLBACK_URL = connect_getback(cur_apptype)
		'授权项 例如：cur_SCOPE=get_user_info,list_album,upload_pic,do_like,add_t 
                                                '不传则默认请求对接口get_user_info进行授权。
                                                '建议控制授权项的数量，只传入必要的接口名称，因为授权项越多，用户越可能拒绝进行任何授权。
	End Sub

	private function class_getCur_appKey(ctype)
		cur_apptype = ctype
		select case ctype
			case 0,1:
				cur_apptype = 1
				cur_apiKey = apiKey
				cur_secretKey = secretKey
				cur_SCOPE ="get_user_info,add_t,add_share,get_info,add_topic"
			case 2:
				cur_apiKey = tqq_apiKey
				cur_secretKey = tqq_secretKey
			case 3:
				cur_apiKey = weibo_apiKey
				cur_secretKey = weibo_secretKey
			case 4:
				cur_apiKey = baidu_apiKey
				cur_secretKey = baidu_secretKey
			case 6:
				cur_apiKey = renren_apiKey
				cur_secretKey = renren_secretKey
				cur_SCOPE ="read_user_blog,publish_blog"
			case 7:
				cur_apiKey = kaixin_apiKey
				cur_secretKey = kaixin_secretKey
				cur_SCOPE = "create_records"
			case 8:
				cur_apiKey = tianyi_apiKey
				cur_secretKey = tianyi_secretKey
			case 9:
				cur_apiKey = youku_apiKey
				cur_secretKey = youku_secretKey
			case 10:
				cur_apiKey = tudou_apiKey
				cur_secretKey = tudou_secretKey
			case else:
				cur_apptype = 1
				cur_apiKey = apiKey
				cur_secretKey = secretKey
		end select
		class_getCur_appKey = cur_apiKey
	
	end function

    Property Get APP_ID()    
        APP_ID = cur_apiKey    
    End Property

	'生成Session("State")数据.
	Public Function MakeRandNum()
		Randomize
		Dim width : width = 6 '随机数长度,默认6位
		width = 10 ^ (width - 1)
		MakeRandNum = Int((width*10 - width) * Rnd() + width)
	End Function


	private function connect_getback(apptype)
	
		dim url
		select case cur_apptype
			'case 1: url = ""
			case 1,2,3,4,6,7,8,9,10: url = "http://"
		end select
		url = url & callback & Request.Servervariables("SCRIPT_NAME")
	   url = url & "?apptype=" & apptype
	   If request.queryString("u") <> "" then url = url & urlencode("&u=" & filterUrlstr(left(request.queryString("u"),50)))
	   connect_getback = urlencode(url)
	
	end function

	
	Private Function CheckXml()
        Dim oxml,Getxmlhttp
        On Error Resume Next
        oxml=array("Microsoft.XMLHTTP","Msxml2.ServerXMLHTTP.6.0","Msxml2.ServerXMLHTTP.5.0","Msxml2.ServerXMLHTTP.4.0","Msxml2.ServerXMLHTTP.3.0","Msxml2.ServerXMLHTTP","Msxml2.XMLHTTP.6.0","Msxml2.XMLHTTP.5.0","Msxml2.XMLHTTP.4.0","Msxml2.XMLHTTP.3.0","Msxml2.XMLHTTP")
        For i=0 to ubound(oxml)
           Set Getxmlhttp = Server.CreateObject(oxml(i))
           If Err Then
              Err.Clear
              CheckXml = False
           Else
              CheckXml = oxml(i) :Exit Function
           End if
       Next
     End Function
     
	private Function BytesToBstr(body) 
	
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
	
	'Get方法请求url,获取请求内容
	Private Function RequestUrl(url)
		dim XmlObj
		'Set XmlObj = Server.CreateObject(CheckXml())
		
		Set XmlObj = Server.CreateObject("Msxml2.ServerXMLHTTP.3.0")
		'Set XmlObj = Server.CreateObject("Msxml2.ServerXMLHTTP.5.0")
		'Response.Charset = "utf-8"
		'Session.CodePage=65001
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
	
	
	Private Function CheckData(data,str)
		If Instr(data,str)>0 Then
		   CheckData = True
		Else
		   CheckData = False
		End If
	End Function
	

	
	'生成登录地址
	Public Function GetAuthorization_Code()
		Dim url, params
			
		Response.WRite "url: " & url
		select case cur_apptype
		case 1:
			url = "https://graph.qq.com/oauth2.0/authorize"
			params = "client_id=" & cur_apiKey
			params = params & "&redirect_uri=" & QQ_CALLBACK_URL
			params = params & "&response_type=code"
			params = params & "&scope="&cur_SCOPE
			params = params & "&state="&Session("State")
			url = url & "?" & params
		case 2:
			url = "https://open.t.qq.com/cgi-bin/oauth2/authorize?client_id=" & cur_apiKey &_
			"&response_type=code&state="&Session("State") & "&redirect_uri=" & QQ_CALLBACK_URL
		case 3:
			url = "https://api.weibo.com/oauth2/authorize?client_id=" & cur_apiKey & "&response_type=code&redirect_uri=" & QQ_CALLBACK_URL
		case 4:
			url = "https://openapi.baidu.com/oauth/2.0/authorize?client_id=" & cur_apiKey &_
				"&response_type=code&redirect_uri=" & QQ_CALLBACK_URL &_
				"&state="&Session("State")
		case 6:
			url = "https://graph.renren.com/oauth/authorize?client_id=" & cur_apiKey & "&redirect_uri=" & QQ_CALLBACK_URL & "&response_type=code"&_
					"&scope=" & cur_SCOPE
		case 7:
			url = "http://api.kaixin001.com/oauth2/authorize?response_type=code"&_
				"&client_id=" & cur_apiKey &_
				"&redirect_uri=" & QQ_CALLBACK_URL &_
				"&state="&Session("State")&_
				"&scope=" & cur_SCOPE
		case 8:
			'url = "https://oauth.api.189.cn/emp/oauth2/v2/authorize"&_
			'"?response_type=token" &_
			'"&app_id=" & cur_apiKey &_
			'"&app_secret=" & cur_secretKey &_
			'"&redirect_uri=" & QQ_CALLBACK_URL &_
			'"&state="&Session("State")
			url = "https://oauth.api.189.cn/emp/oauth2/v2/authorize?response_type=code"&_
			"&app_id=" & cur_apiKey &_
			"&redirect_uri=" & QQ_CALLBACK_URL &_
			"&state="&Session("State")
		case 9:
			url = "https://openapi.youku.com/v2/oauth2/authorize?client_id=" & cur_apiKey&_
			"&response_type=code" &_
			"&redirect_uri=" & QQ_CALLBACK_URL&_
			"&state="&Session("State")
		case 10:
			url = "https://api.tudou.com/oauth2/authorize" &_
			"?client_id=" & cur_apiKey&_
			"&state="&Session("State")&_
			"&redirect_uri=" & QQ_CALLBACK_URL
		end select
		GetAuthorization_Code = (url)
	End Function
	
	
	'获取 access_token
	'获取到的access token具有3个月有效期，用户再次登录时自动刷新。
	'第三方网站可存储access token信息，以便后续调用OpenAPI访问和修改用户信息时使用。
	Public Function GetAccess_Token()
		Dim url, params,Temp,dd
		select case cur_apptype
			case 1:
				Url="https://graph.qq.com/oauth2.0/token"
			    params = "client_id=" & cur_apiKey
				params = params & "&client_secret=" & cur_secretKey
				params = params & "&redirect_uri=" & QQ_CALLBACK_URL
				params = params & "&grant_type=authorization_code"
				params = params & "&code="&Session("Code")
				params = params & "&state="&Session("State")
				url = Url & "?" & params
				Temp=RequestUrl(url)
				token_string = Temp
				If CheckData(Temp,"access_token=") = True Then
		           GetAccess_Token=CutStr(Temp,"access_token=","&")
				End If
			case 2:
				url = "https://open.t.qq.com/cgi-bin/oauth2/access_token?client_id=" & cur_apiKey&_
				"&client_secret=" & cur_secretKey&_
				"&grant_type=authorization_code&code=" & Session("Code") &_
				"&redirect_uri=" & QQ_CALLBACK_URL &_
				"&state="&Session("State")
				
				Temp=RequestUrl(url)
				token_string = Temp
				If CheckData(Temp,"access_token=") = True Then
		           GetAccess_Token=CutStr(Temp,"access_token=","&")
				End If
			case 3:
				url = "https://api.weibo.com/oauth2/access_token?client_id=" & cur_apiKey &_
				"&client_secret=" & cur_secretKey & "&grant_type=authorization_code"&_
				"&redirect_uri=" & QQ_CALLBACK_URL &_
				"&code=" & Session("Code")
				dd = "client_id=" & cur_apiKey &_
				"&client_secret=" & cur_secretKey & "&grant_type=authorization_code"&_
				"&redirect_uri=" & QQ_CALLBACK_URL &_
				"&code=" & Session("Code")
				'Temp=RequestUrl(url)
				Temp = RequestUrl_post(url,dd)
				token_string = Temp
				
				GetAccess_Token = CutStr(token_string, "access_token"":""",""",")
				if GetAccess_Token = "" then
					GetAccess_Token = CutStr(token_string, "access_token"": """,""",")
				end if
			case 4:
				url = "https://openapi.baidu.com/oauth/2.0/token"
				dd = "grant_type=authorization_code" &_
					"&code=" & Session("Code") &_
					"&client_id=" & cur_apiKey &_
					"&client_secret=" & cur_secretKey &_
					"&redirect_uri=" & QQ_CALLBACK_URL
				Temp = RequestUrl_post(url,dd)
				token_string = Temp
				
				GetAccess_Token = CutStr(token_string, "access_token"":""",""",")
				if GetAccess_Token = "" then GetAccess_Token = CutStr(token_string, "access_token"": """,""",")

			case 6:
				url = "https://graph.renren.com/oauth/token"
				dd = "grant_type=authorization_code" &_
					"&code=" & Session("Code") &_
					"&client_id=" & cur_apiKey &_
					"&client_secret=" & cur_secretKey &_
					"&redirect_uri=" & QQ_CALLBACK_URL &_
					"&x_renew=true"
				Temp = RequestUrl_post(url,dd)
				token_string = Temp
				
				GetAccess_Token = CutStr(token_string, "access_token"":""","""")
				if GetAccess_Token = "" then GetAccess_Token = CutStr(token_string, "access_token"": ""","""")

			case 7:
				url = "https://api.kaixin001.com/oauth2/access_token"
				dd = "grant_type=authorization_code"&_
				"&code=" & Session("Code") &_
				"&client_id=" & cur_apiKey &_
				"&client_secret=" & cur_secretKey &_
				"&redirect_uri=" & QQ_CALLBACK_URL
				Temp = RequestUrl_post(url,dd)
				token_string = replace(Temp," ","")
				GetAccess_Token = unJsString(CutStr(token_string, "access_token"":""",""""))
			case 8:
				url = "https://oauth.api.189.cn/emp/oauth2/v2/access_token"
				dd = "grant_type=authorization_code"&_
				"&code=" & Session("Code") &_
				"&app_id=" & cur_apiKey &_
				"&app_secret=" & cur_secretKey &_
				"&redirect_uri=" & QQ_CALLBACK_URL
				Temp = RequestUrl_post(url,dd)
				token_string = replace(Temp," ","")
				GetAccess_Token = unJsString(CutStr(token_string, "access_token"":""",""""))
			case 9:
				url = "https://openapi.youku.com/v2/oauth2/token"
				dd = "client_id=" & cur_apiKey &_
				"&client_secret=" & cur_secretKey &_
				"&redirect_uri=" & QQ_CALLBACK_URL &_
				"&grant_type=authorization_code"&_
				"&code=" & Session("Code")
				token_string = replace(RequestUrl_post(url,dd)," ","")
				GetAccess_Token = CutStr(token_string, "access_token"":""","""")
			case 10:
				url = "https://api.tudou.com/oauth2/access_token"
				dd = "client_id=" & cur_apiKey &_
				"&client_secret=" & cur_secretKey &_
				"&redirect_uri=" & QQ_CALLBACK_URL &_
				"&grant_type=authorization_code"&_
				"&code=" & Session("Code")
				token_string = replace(RequestUrl_post(url,dd)," ","")
				GetAccess_Token = CutStr(token_string, "access_token"":""","""")
		end select
		If GetAccess_Token = "" Then
			Call ErrorJump("获取 access_token 时发生错误，错误代码："&Temp)
		End If
	End Function
	
	'检测是否合法登录！
	Public Function CheckLogin()
		Dim Code,mState
		select case cur_apptype
			case 1,2,4,7,8,9,10:
				Code=Trim(Request.QueryString("code"))
				mState=Trim(Request.QueryString("state"))
				'Response.Write "<br>Code:" & Code
				'Response.Write "<br>mState:" & mState
				'Response.Write "<br>sessmState:" & Session("State")
				'response.end
				If Code<>"" and Session("State") & "" = mState & "" Then
					CheckLogin = True
					Session("Code") = Code
				Else
					CheckLogin = False
				End If
			case 3,6:				
				Code=Trim(Request.QueryString("code"))
				If Code<>"" Then
					CheckLogin = True
					Session("Code") = Code
				Else
					CheckLogin = False
				End If
		end select
	End Function
	
	'获取openid
	Public Function Getopenid()
		Dim url, params,Temp
		select case cur_apptype
		case 1:
			url = "https://graph.qq.com/oauth2.0/me"
			params = "access_token="&Session("Access_Token")
			url = Url & "?" & params
			Temp=RequestUrl(url)
			If Instr(Temp,"openid")>0 Then
			   Getopenid=CutStr(Temp,"openid"":""","""}")
			Else
			   Call ErrorJump("获取 Openid 时发生错误，错误代码："&CutStr(Temp,"{""error"":",",")) 
			End If
		case 2:
			Getopenid = left(trim(request.querystring("openid")),32)
		case 3:
			Getopenid = CutStr(token_string, "uid"":""","""")
			if Getopenid = "" then
				Getopenid = CutStr(token_string, "uid"": ""","""")
			end if
		case 4:			
			url = "https://openapi.baidu.com/rest/2.0/passport/users/getInfo?access_token=" & Session("Access_Token")
			Temp = RequestUrl(url)
			apenid_string = Temp
			If CheckData(apenid_string,"userid") = False Then
				  Call ErrorJump("获取用户信息时发生错误，错误代码："&GetUserInfo) 
			End If
			
			Getopenid = CutStr(apenid_string, "userid"":""","""")
			if Getopenid = "" then
				Getopenid = CutStr(apenid_string, "userid"": ""","""")
			end if
			'百度的openid以uid来作为唯一识别
		case 6:
			Getopenid = CutStr(token_string, "id"":""","""")
			if Getopenid = "" then Getopenid = CutStr(token_string, "id"": ""","""")
			if Getopenid = "" then Getopenid = CutStr(token_string, "id"":",",")
			if Getopenid = "" then Getopenid = CutStr(token_string, "id"": ",",")
		case 7:		
			url = "https://api.kaixin001.com/users/me.json?access_token=" & Session("Access_Token")
			Temp = clearJson(RequestUrl(url))
			apenid_string = Temp
			Getopenid = unJsString(CutStr(apenid_string, """uid"":""",""""))
		case 8:
			Getopenid = CutStr(token_string, "open_id"":""","""")
		case 9:
			url = "https://openapi.youku.com/v2/users/myinfo.json"
			params = "client_id=" & cur_apiKey &_
			"&access_token="&Session("Access_Token")
			Temp = clearJson(RequestUrl_post(url,params))
			apenid_string = Temp
			Getopenid = unJsString(CutStr(apenid_string, """id"":""",""""))
			if Getopenid = "" then Getopenid = CutStr(apenid_string, """id"":",",")
		case 10:
			Getopenid = CutStr(token_string, "uid"":""","""")
			if Getopenid = "" then Getopenid = CutStr(token_string, "uid"":","}")
			if Getopenid = "" then Getopenid = CutStr(token_string, "uid"":",",")
		end select
		If Getopenid = "" Then
			  Call ErrorJump("获取openid时发生错误.") 
		End If

	End Function
	
	'发送一条微博
	Public Function Post_Webo(content,Access_Token,Access_Openid)
		Dim url, params, Tk,Oid
		Tk = Access_Token
		Oid = Access_Openid
		if Tk = "" then Tk = Session("Access_Token")
		if Oid = "" then Oid = Session("Openid")
		url = "https://graph.qq.com/t/add_t"
		params = "oauth_consumer_key=" & cur_apiKey
		params = params & "&access_token=" & Tk
		params = params & "&openid=" & Oid
		params = params & "&content="&sim_urlencode(content)
        params = params & "&format=json"
		Post_Webo = RequestUrl_post(url,params)
	End Function
	
	private function sim_urlencode(str)
	
		sim_urlencode = replace(replace(replace(str,"&","%26"),"=","%3D"),VbCrLf," ")
	
	end function
	
	'分享内容到QQ空间
	Public Function Post_Share(apptype,title,turl,comment,summary,images,nswb,Access_Token,Access_Openid,video,ExpiresTime)
	
		dim this_apiKey
		this_apiKey = class_getCur_appKey(apptype)
		Dim url, params, Tk,Oid
		Tk = Access_Token
		Oid = Access_Openid
		if Tk = "" then Tk = Session("Access_Token")
		if Oid = "" then Oid = Session("Openid")
		select case apptype
			case 1:
				url = "https://graph.qq.com/share/add_share"
				params = "oauth_consumer_key=" & this_apiKey
				params = params & "&access_token=" & Tk
				params = params & "&openid=" & Oid
				params = params & "&title="&sim_urlencode(title)
				params = params & "&url="&sim_urlencode(turl)
				params = params & "&comment="&sim_urlencode(comment)
				params = params & "&summary="&sim_urlencode(summary)
				params = params & "&images="&sim_urlencode(images)
				params = params & "&nswb="&sim_urlencode(nswb)
				params = params & "&format=json"
				params = params & "&site="&sim_urlencode(DEF_SiteNameString & DEF_BBS_Name)
				params = params & "&fromurl="&sim_urlencode(LD_GetUrl(0))
				if video <> "" Then
					params = params & "&type=5"
					params = params & "&playurl="&sim_urlencode(video)
				end if		
				Post_Share = RequestUrl_post(url,params)
			case 2:
				url = "https://open.t.qq.com/api/t/add_multi"
				params = "oauth_consumer_key=" & this_apiKey
				params = params & "&access_token=" & Tk
				params = params & "&openid=" & Oid
				params = params & "&clientip=" & GBL_IPAddress
				params = params & "&oauth_version=2.a"
				params = params & "&scope=all"
				params = params & "&format=json"
				params = params & "&content=" & sim_urlencode(title) & " , " & sim_urlencode(summary)
				if images <> "" then params = params & "&pic_url=" & sim_urlencode(images)
				if video <> "" then params = params & "&video_url=" & sim_urlencode(video_url)
				params = params & "&syncflag=1"
				Post_Share = RequestUrl_post(url,params)
			case 3:
				url = "https://api.weibo.com/2/statuses/update.json"
				params = "source =" & this_apiKey
				params = params & "&access_token=" & Tk
				params = params & "&status=" & sim_urlencode(left(title &" , " & summary,137) & "...")
				params = params & "&rip=" & GBL_IPAddress
				Post_Share = RequestUrl_post(url,params)
			case 6:
				url = "https://api.renren.com/v2/blog/put"
				params = "access_token=" & Tk&_
					"&title=" & sim_urlencode(title) &_
					"&AccessControl=PUBLIC" &_
					"&content=" & sim_urlencode(summary)
				Post_Share = RequestUrl_post(url,params)
			case 7:
				url = "https://api.kaixin001.com/records/add"
				params = params & "content=" & sim_urlencode(leftTrue(title &" , " & summary,255) & "...")
				params = params & "&access_token=" & Tk
				if images <> "" then params = params & "&picurl=" & sim_urlencode(images)
				Post_Share = RequestUrl_post(url,params)
		end select
		

	End Function
	
	'获取用户信息,得到一个json格式的字符串
	Public Function GetUserInfo()
		Dim url, params, result
		select case cur_apptype
			case 1:
				url = "https://graph.qq.com/user/get_user_info"
				params = "oauth_consumer_key=" & cur_apiKey
				params = params & "&access_token=" & Session("Access_Token")
				params = params & "&openid=" & Session("Openid")
				url = url & "?" & params
				GetUserInfo = RequestUrl(url)
				If CheckData(GetUserInfo,"nickname") = False Then
				   Call ErrorJump("获取用户信息时发生错误，错误代码："&CutStr(GetUserInfo,"{""ret"":",",")) 
				End If
			case 2:
				GetUserInfo = token_string
			case 3:
				url = "https://api.weibo.com/2/users/show.json?source=" & cur_apiKey &_
				"&access_token=" & Session("Access_Token") &_
				"&uid=" & Session("Openid")
				GetUserInfo = RequestUrl(url)
				If CheckData(GetUserInfo,"screen_name") = False Then
				   Call ErrorJump("获取用户信息时发生错误，错误代码："&CutStr(GetUserInfo,"{""error"":","""")) 
				End If
			case 4:
				GetUserInfo = apenid_string
			case 6,8:
				GetUserInfo = token_string
			case 7:
				GetUserInfo = apenid_string
			case 8:
				'需要189有用户属性类，为了保护隐私，其中论坛只获取相应的性别，其它资料并不获取
			case 9:
				GetUserInfo = apenid_string
			case 10:
				url = "https://api.tudou.com/v6/user/info"&_
				"?app_key=" & cur_apiKey&_
				"&user=" & Session("Openid")
				GetUserInfo = RequestUrl(url)
		end select
	End Function
	
	private function clearJson(str)
	
		clearJson = replace(replace(replace(str," ",""),chr(10),""),chr(13),"")
	
	end function
	
	'获取腾讯微博登录用户的用户资料,得到一个json格式的字符串
	Public Function Get_Info()
		Dim url, params, result
		url = "https://graph.qq.com/user/get_info"
		params = "oauth_consumer_key=" & cur_apiKey
		params = params & "&access_token=" & Session("Access_Token")
		params = params & "&openid=" & Session("Openid")
		params = params & "&format=json"
		url = url & "?" & params
		Get_Info = RequestUrl(url)
	End Function

	
	'获取用户名字,性别,从json字符串里截取相关字符
	Public Function GetUserName(json)
		Dim nickname,sex,icon,ExpiresTime,MobileTel
		ExpiresTime = 0
		MobileTel = 0
		dim tmp,url
		select case cur_apptype
			case 1:
				nickname = CutStr(json, "nickname"":""",""",")
				if nickname = "" then
					nickname = CutStr(json, "nickname"": """,""",")
				end if
				sex=CutStr(json, "gender"":""","""")
				if sex = "" then
					sex = CutStr(json, "gender"": """,""",")
				end if
				icon=CutStr(json, "figureurl_qq_2"":""","""")
				if icon = "" then
					icon = CutStr(json, "figureurl_qq_2"": """,""",")
				end if
				if icon = "" then
					icon=CutStr(json, "figureurl_2"":""","""")
					if icon = "" then
						icon = CutStr(json, "figureurl_2"": """,""",")
					end if
				end if
				icon = replace(icon,"\","")

				If CheckData(token_string,"expires_in=") = True Then
					ExpiresTime=trim(CutStr(token_string,"expires_in=","&"))
				end if
			case 2:
				If CheckData(token_string,"nick=") = True Then
		           nickname=trim(CutStr(token_string,"nick=","&"))
				end if
				If nickname = "" and CheckData(token_string,"name=") = True Then
					nickname=CutStr(token_string,"name=","&")
				end if
				sex = ""
				icon = LD_GetUrl(1) & "images/app/face_2.png"
				
				If CheckData(token_string,"expires_in=") = True Then
					ExpiresTime=trim(CutStr(token_string,"expires_in=","&"))
				end if
			case 3:
				nickname = CutStr(json, "name"":""",""",")
				if nickname = "" then
					nickname = CutStr(json, "name"": """,""",")
				end if
				if nickname = "" then nickname = CutStr(json, "screen_name"":""",""",")
				if nickname = "" then nickname = CutStr(json, "screen_name"": """,""",")
				sex=CutStr(json, "gender"":""","""")
				if sex = "" then
					sex = CutStr(json, "gender"": """,""",")
				end if
				if sex = "m" then
					sex = "男"
				elseif sex = "f" then
					sex = "女"
				else
					sex = "密"
				end if
				icon=CutStr(json, "profile_image_url"":""","""")
				if icon = "" then
					icon = CutStr(json, "profile_image_url"": """,""",")
				end if
				if icon <> "" then icon = replace(icon,"/50/","/180/")

				If CheckData(token_string,"expires_in") = True Then	
					ExpiresTime=CutStr(token_string, "expires_in"":",",")
					if ExpiresTime = "" then
						ExpiresTime = CutStr(token_string, "expires_in: ",",")
					end if
					if ExpiresTime = "" then ExpiresTime=CutStr(token_string, "remind_in"":""","""")
					if ExpiresTime = "" then
						ExpiresTime = CutStr(token_string, "remind_in"": ""","""")
					end if
				end if
			case 4:
				nickname = CutStr(apenid_string, "username"":""","""")
				if nickname = "" then nickname = CutStr(apenid_string, "username"": ""","""")

				sex=CutStr(json, "sex"":""","""")
				if sex = "" then
					sex = CutStr(json, "sex"": """,""",")
				end if
				if sex = "1" then
					sex = "男"
				elseif sex = "0" then
					sex = "女"
				else
					sex = "密"
				end if
					
				icon = CutStr(apenid_string, "portrait"":""","""")
				if icon = "" then icon = CutStr(apenid_string, "portrait"": ""","""")

				icon = "http://tb.himg.baidu.com/sys/portrait/item/" & icon
				If CheckData(token_string,"expires_in") = True Then
					ExpiresTime=CutStr(token_string, "expires_in"":",",")
					if ExpiresTime = "" then ExpiresTime = CutStr(token_string, "expires_in"": ",",")
				
					if ExpiresTime = "" then ExpiresTime=CutStr(token_string, "expires_in"":""","""")
					if ExpiresTime = "" then ExpiresTime = CutStr(token_string, "expires_in"": ""","""")

				end if
			case 6:
				token_string = replace(token_string," ","")
				nickname = CutStr(token_string, """name"":""","""")
				icon = CutStr(token_string, """type"":""main"",""url"":""","""")
				if icon = "" then icon = CutStr(token_string, """type"":""tiny"",""url"":""","""")
				sex = "密"
				ExpiresTime=CutStr(token_string, "expires_in"":",",")
				if ExpiresTime = "" then ExpiresTime=CutStr(token_string, "expires_in"":""","""")
			case 7:
				nickname = unJsString(CutStr(apenid_string, """name"":""",""""))
				sex = unJsString(CutStr(apenid_string, """gender"":""",""""))
				if sex = "0" then
					sex = "男"
				elseif sex = "1" then
					sex = "女"
				else
					sex = "密"
				end if
				icon = CutStr(apenid_string, """logo120"":""","""")
				if icon = "" then icon = CutStr(apenid_string, """logo50"":""","""")
				if icon <> "" then icon = unJsString(icon)
				ExpiresTime=CutStr(token_string, "expires_in"":",",")
				if ExpiresTime = "" then ExpiresTime=CutStr(token_string, "expires_in"":""","""")
			case 8:
				url = "http://api.189.cn/upc/real/age_and_sex?app_id=" & cur_apiKey &_
				"&access_token=" & Session("Access_Token")&_
				"&type=json"
				tmp = RequestUrl(url)

				sex = unJsString(CutStr(tmp, """real_gender"":""",""""))
				
				if sex = "男" then
					sex = "男"
				elseif sex = "女" then
					sex = "女"
				else
					sex = "密"
				end if

				'189.cn还需要虚拟形象类来获得昵称,头像暂不获取，只使用默认
				url = "http://api.189.cn/upc/vitual_identity/user_network_info?app_id=" & cur_apiKey &_
				"&access_token=" & Session("Access_Token")&_
				"&type=json"
				tmp = RequestUrl(url)
				response.write "<br>tmp:"& tmp	
				nickname = unJsString(CutStr(tmp, """user_nickname"":""",""""))
				
				'联系号码，默认不获取，可能是电话，不一定是手机
				'url = "http://api.189.cn/upc/real/cellphone_and_province?app_id=" & cur_apiKey &_
				'"&access_token=" & Session("Access_Token")&_
				'"&type=json"
				'tmp = RequestUrl(url)
				'MobileTel = toNum(unJsString(CutStr(tmp, """cellphone"":""","""")),0)

				icon = LD_GetUrl(1) & "images/app/face_8.png"
				ExpiresTime=CutStr(token_string, "expires_in"":",",")
				if ExpiresTime = "" then ExpiresTime=CutStr(token_string, "expires_in"":""","""")
			case 9:
				nickname = unJsString(CutStr(apenid_string, """name"":""",""""))
				icon = unJsString(CutStr(apenid_string, """avatar_large"":""",""""))
				sex=unJsString(CutStr(apenid_string, "gender"":""",""""))
				if sex = "m" then
					sex = "男"
				elseif sex = "f" then
					sex = "女"
				else
					sex = "密"
				end if
				ExpiresTime=CutStr(token_string, "expires_in"":",",")
				if ExpiresTime = "" then ExpiresTime=CutStr(token_string, "expires_in"":""","""")
			case 10:				
				nickname = CutStr(json, """nickName"":""","""")
				if nickname = "" then nickname = CutStr(json, """userName"":""","""")
				icon = CutStr(json, """userPicUrl"":""","""")
				sex=lcase(CutStr(json, "gender"":""",""""))
				if sex = "m" then
					sex = "男"
				elseif sex = "f" then
					sex = "女"
				else
					sex = "密"
				end if
				ExpiresTime=CutStr(token_string, "expires_in"":",",")
				if ExpiresTime = "" then ExpiresTime=CutStr(token_string, "expires_in"":""","""")
		end select
		ExpiresTime = fix(toNum(ExpiresTime,0))
		if ExpiresTime > 0 then ExpiresTime = dateadd("s",ExpiresTime,DEF_Now)
		GetUserName = Array(nickname,sex,icon,ExpiresTime,MobileTel)
	End Function
	
	Public Function CutStr(data,s_str,e_str)
	    If Instr(data,s_str)>0 and Instr(data,e_str)>0 Then
		   CutStr = Split(data,s_str)(1)
		   CutStr = Split(CutStr,e_str)(0)
		Else
		   CutStr = ""
		End If
	End Function
	
End Class
%>