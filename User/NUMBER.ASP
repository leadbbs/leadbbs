<!-- #include file=../inc/BBSsetup.asp -->
<!-- #include file=inc/Canvassafecode.asp -->
<%
Response.Expires=0
DEF_BBS_HomeUrl = "../"
Dim RndNumber,RndNumberStr,Rs

Function Code_RndNumber(tp)

	Dim sCode
	Randomize
	Select Case tp
	Case 0:
		sCode = Fix(Rnd*9999)+1
	Case 1,2:
		Dim i,cCode,cAmount
		If tp = 1 Then
			cAmount = 23
			cCode = "ABCDEFGHJKLMNPQRSTUVWXY"
		Else
			cAmount = 30
			cCode = "3456789ABCDEFGHJKLMNPQRSTUVWXY"
		End If
		For i = 0 To 3
			sCode = sCode &""& Mid(cCode, Int(Rnd * cAmount) + 1, 1) 
		Next
	Case 3:
		sCode = Rnd_cn(2)
	End Select
	
	Session(DEF_MasterCookies & "RndNum") = sCode
	Session(DEF_MasterCookies & "RndNum_par") = ""
	Code_RndNumber = sCode

End Function

If (DEF_EnableAttestNumber = 1 or DEF_EnableAttestNumber = 3) Then
	'DisplayGflSDK_num
	'DisplayGflSDK
	'DisplayGflSDK_cn
	'DisplayBMP
	
	'DisplayCanvasCode
	RndNumber_Jpeg
Else
	DisplayCanvasCode
End If


Sub DisplayGflSDKgif

	Dim rndStr
	rndStr = Code_RndNumber(1)
	Dim MyObj
	Set MyObj = Server.CreateObject("GflAx190.GflAx")
	MyObj.EnableLZW = True
	MyObj.LoadBitmap(server.mappath(DEF_BBS_HomeUrl & "images/null.gif"))

	MyObj.NewBitmap 32, 12
	MyObj.FontBold = True
	MyObj.FontName = "ËÎÌå"
	MyObj.FontSize = 12
	
	Dim c,N
	For N = 1 to 4
		c = Rnd*255
		MyObj.TextOut Mid(rndStr,N,1),2+7*N-7,-1,c
	Next
	
	MyObj.UseTransparency = true
	MyObj.ChangeColorDepth 8
	Response.ContentType="image/gif"
	MyObj.SaveFormat = 2
	MyObj.MaskColor = 255*256*256+255*256+255
	Response.BinaryWrite MyObj.SendBinary
	Set MyObj = Nothing

End Sub

Sub DisplayGflSDK

	Dim rndStr
	rndStr = Code_RndNumber(1)
	Dim MyObj
	Set MyObj = Server.CreateObject("GflAx190.GflAx")
	MyObj.EnableLZW = True
	MyObj.LoadBitmap(server.mappath(DEF_BBS_HomeUrl & "images/null.jpg"))

	Dim fontName
	fontName = Array("Comic Sans MS","Arial Black","Century Gothic","Courier","Courier New","Times New Roman","Impact","Verdana")

	MyObj.NewBitmap 32, 12
	MyObj.FontBold = True
	Randomize
	MyObj.FontName = fontName(Fix(Rnd*7)+1)
	MyObj.FontSize = 15
	
	Dim c,N
	For N = 1 to 4
		c = Rnd*255
		MyObj.TextOut Mid(rndStr,N,1),2+7*N-7,-1,c
	Next
	
	MyObj.UseTransparency = true
	MyObj.ChangeColorDepth 8
	MyObj.SaveJPEGQuality = 20
	Response.ContentType="image/jpg"
	MyObj.SaveFormat = 1
	'MyObj.MaskColor = 255*256*256+255*256+255
	Response.BinaryWrite MyObj.SendBinary
	Set MyObj = Nothing

End Sub




Function Rnd_cn(num)

dim str
str = "°¡°¢°£°¤°¥°¦°§°¨°©°ª°«°¬°­°®°¯°°°²°³°´°µ°¶°·°¸°¹°º°»°¼°½°¾°À°Á°Â°Ã°Ä°Å°Ç°È°É°Ê°Ë°Ì°Í°Î°Ï°Ð°Ñ°Ó°Ô°Õ°Ö°×°Ø°Ù°Ú°Û°Ü°Ý°ß°à°á°â°ã°å°æ°ç°è°é°ê°ë°ì°í°î°ï°ñ°ò°ó°ô°õ°ö°ø°ù°ú°û°ü°ý°þ±¡±¢±£±¤±¥±¦±§±¨±©±ª±«±¬±­±®±¯±°±±±²±³±´±¶±·±¸±¹±»±¼±¾±¿±À±Á±Â±Ä±Å±Æ±Ç±È±É±Ê±Ë±Ì±Í±Î±Ï±Ð±Ò±Ó±Ô±Õ±Ö±×±Ø±Ù±Ú±Û±Ü±ß±à±á±ã±ä±æ±ç±è±é±ê±í±ï±ð±ò±ó±õ±ö±÷±ø±ù±ú±û±ü±ý±þ²¡²¢²£²¥²¦²¨²©²«²®²¯²°²±²²²³²´²µ²¶²·²¸²¹²»²¼²½²¾²¿²Á²Â²Ã²Ä²Å²Æ²Ç²È²É²Ê²Ë²Ì²Í²Î²Ï²Ð²Ñ²Ò²Ó²Ô²Õ²Ö²×²Ø²Ù²Ú²Û²Ü²Ý²Þ²ß²à²á²â²ã²ä²å²æ²è²é²ì²í²î²ï²ð²ñ²ò²ó²ô²õ²ö²÷²ø²ú²ü²ý²þ³¡³¢³£³¤³¥³¦³§³¨³©³ª³«³¬³­³®³¯³°³±³²³³³´³µ³¶³·³¹³º³¼³½³¾³¿³À³Á³Â³Ã³Ä³Å³Æ³Ç³È³É³Ê³Ë³Ì³Í³Î³Ï³Ð³Ñ³Ò³Ô³Õ³Ö³×³Ø³Ù³Ú³Û³Ü³Ý³Þ³ß³à³á³â³ã³ä³å³æ³ç³è³é³ê³í³î³ï³ð³ñ³ò³ó³ô³õ³ö³ø³ú³ý³þ´¡´¢´£´¤´¥´¦´§´¨´©´«´¬´­´®´°´±´²´³´´´µ´¶´·´¸´¹´¼´½´¿´À´Á´Â´Å´Æ´Ç´È´É´Ê´Ë´Ì´Í´Î´Ï´Ð´Ò´Ó´Ô´Õ´Ö´×´Ù´Ú´Ü´Ý´Þ´ß´à´á´â´ã´ä´å´æ´ç´è´é´ê´ë´ì´í´î´ï´ð´ò´ó´ô´õ´÷´ø´ú´û´ü´ý´þµ¡µ¢µ£µ¤µ¥µ§µ¨µ©µ«µ¬µ­µ®µ¯µ°µ±µ²µ³µ´µµµ¶µ·µ¸µ¹µºµ»µ¼µ½µ¾µ¿µÀµÁµÂµÃµÄµÅµÆµÇµÈµÉµÊµËµÌµÍµÎµÏµÐµÑµÒµÖµ×µØµÙµÚµÛµÜµÝµÞµßµàµãµäµæµçµéµêµëµìµíµîµïµðµñµòµóµôµõµöµ÷µøµùµúµûµüµýµþ¶¡¶¢¶£¶¥¶¦¶¨¶©¶ª¶«¶¬¶­¶®¶¯¶°¶±¶³¶´¶µ¶¶¶·¶¸¶¹¶º¶¼¶¾¶À¶Á¶Â¶Ã¶Ä¶Å¶Ç¶È¶É¶Ê¶Ë¶Ì¶Í¶Î¶Ï¶Ð¶Ñ¶Ò¶Ó¶Ô¶Ö¶×¶Ø¶Ù¶Ú¶Ü¶Ý¶Þ¶à¶á¶â¶ã¶ä¶å¶æ¶ç¶è¶é¶ê¶ë¶ì¶í¶î¶ï¶ð¶ñ¶ò¶ó¶ô¶õ¶ö¶÷¶ø¶ù¶ú¶û¶ü¶ý¶þ·¢·£·¤·¥·¦·§·¨·«·¬·­·±·²·³·´·µ·¶·¸·¹·º·»·¼·½·¿·À·Á·Â·Ã·Ä·Å·Æ·Ç·È·É·Ê·Ë·Ì·Í·Î·Ï·Ð·Ñ·Ò·Ô·Ö·×·Ø·Ù·Û·Ü·Ý·Þ·ß·à·á·â·ã·ä·å·æ·ç·è·é·ê·ë·ì·í·î·ï·ð·ñ·ò·ó·ô·ö·÷·ø·ù·û·ü·ý·þ¸¡¸£¸¥¸¦¸§¸¨¸©¸ª¸«¸¬¸­¸®¸¯¸°¸±¸²¸³¸´¸µ¸¶¸¸¸¹¸º¸»¸½¸¾¸¿¸À¸Â¸Ã¸Ä¸Æ¸Ç¸È¸É¸Ê¸Ë¸Ì¸Í¸Î¸Ï¸Ð¸Ñ¸Ò¸Ô¸Õ¸Ö¸×¸Ø¸Ù¸Ú¸Û¸Ü¸Ý¸ß¸à¸á¸â¸ã¸æ¸ç¸è¸é¸ê¸ë¸ì¸î¸ï¸ñ¸ó¸ô¸ö¸÷¸ø¸ù¸ú¸û¸ü¸ý¹¡¹¢¹£¹¤¹¥¹¦¹§¹¨¹©¹ª¹«¹¬¹­¹®¹°¹±¹²¹³¹´¹µ¹¶¹·¹¸¹¹¹º¹»¹¼¹½¹¾¹À¹Á¹Â¹Ã¹Ä¹Å¹Ç¹È¹É¹Ê¹Ë¹Ì¹Í¹Î¹Ï¹Ð¹Ñ¹Ò¹Ó¹Ô¹Õ¹Ö¹×¹Ø¹Ù¹Ú¹Û¹Ü¹Ý¹Þ¹ß¹à¹á¹â¹ã¹ä¹å¹æ¹ç¹è¹é¹ê¹ë¹ì¹í¹î¹ï¹ð¹ñ¹ò¹ó¹ô¹ö¹÷¹ø¹ù¹ú¹û¹ü¹ý¹þº¡º¢º£º¥º¦º§º¨º«º¬º­º®º¯º°º±º³º´ºµº¶º·º¸º¹ººº¼º½º¿ºÀºÁºÃºÄºÅºÆºÇºÉºÊºËºÌºÍºÎºÏºÐºÓº×ºØºÙºÚºÛºÜºÝºÞºßºàºáºâºãºäºåºæºçºèºéºêºëºìºíºîºïºðºñºòºóºôºõºöº÷ºøºùºúºûºüºýºþ»¡»¢»£»¤»¥»¦»§»¨»©»ª»«»¬»­»®»¯»°»²»³»´»µ»¶»·»¹»º»»»¼»½»¾»Ã»Ä»Å»Æ»É»Ê»Ë»Ì»Í»Î»Ð»Ñ»Ò»Ó»Ô»Õ»Ö»×»Ø»Ù»Ú»Û»Ý»Þ»ß»á»ã»ä»å»æ»è»é»ê»ë»ì»î»ï»ð»ñ»ò»ó»ô»õ»ö»÷»ø»ù»ú»û»ü»ý¼¡¼¢¼£¼¤¼¥¼¦¼§¼¨¼©¼ª¼«¼¬¼­¼®¼¯¼°¼±¼²¼³¼´¼µ¼¶¼·¼¸¼¹¼º¼¼¼¾¼À¼Á¼Â¼Ã¼Ä¼Å¼Æ¼Ç¼È¼É¼Ê¼Ë¼Ì¼Í¼Î¼Ð¼Ñ¼Ò¼Ó¼×¼Ø¼Ù¼Ú¼Û¼Ü¼Ý¼Þ¼ß¼à¼á¼â¼ã¼ä¼å¼æ¼ç¼è¼é¼ì¼í¼î¼ï¼ð¼ñ¼ò¼ó¼ô¼õ¼ö¼ø¼ù¼ú¼û¼ü¼ý¼þ½¡½¢½£½¥½¦½¨½©½ª½«½­½®½¯½±½²½³½´½µ½¶½·½¸½¹½º½»½¼½½½¾½¿½À½Á½Ä½Å½Æ½Ç½È½É½Ê½Ì½Í½Î½Ï½Ð½Ò½Ó½Ô½Ö½×½Ø½Ù½Ú¾¥¾¦¾§¾¨¾©¾ª¾«¾­¾®¾¯¾°¾±¾²¾³¾´¾µ¾¶¾¹¾º¾»¾½¾¾¾¿¾À¾Â¾Ã¾Ä¾Å¾Æ¾È¾É¾Ë¾Ì¾Í¾Î¾Ï¾Ð¾Ó¾Ô¾Õ¾Ö¾×¾Ø¾Ù¾Ú¾Û¾Ü¾Ý¾Þ¾ß¾á¾â¾ã¾ä¾å¾æ¾ç¾è¾é¾ê¾ë¾ì¾í¾î¾ñ¾ò¾ó¾ô½Û½Ü½Ý½Þ½ß½à½á½â½ã½ä½å½æ½ç½è½é½ì½í½î½ï½ð½ñ½ò½ó½ô½õ½ö½÷½ø½ù½ú½û½ü½ý½þ¾¡¾¢¾£¾¤¾õ¾ö¾÷¾ø¾ù¾ú¾û¾ü¾ý¾þ¿¡¿¤¿¥¿¨¿©¿ª¿«¿¬¿­¿®¿¯¿°¿±¿²¿³¿´¿µ¿¶¿·¿¸¿¹¿º¿»¿¼¿½¿¾¿¿¿À¿Á¿Â¿Ã¿Ä¿Å¿Æ¿Ç¿È¿É¿Ê¿Ë¿Ì¿Í¿Î¿Ï¿Ð¿Ñ¿Ò¿Ó¿Ô¿Õ¿Ö¿×¿Ø¿Ù¿Ú¿Û¿Ü¿Ý¿Þ¿ß¿à¿á¿â¿ã¿ä¿å¿æ¿ç¿è¿é¿ê¿ì¿í¿î¿ï¿ð¿ñ¿ò¿ó¿ô¿õ¿ö¿÷¿ø¿û¿ý¿þÀ¢À¤À¥À¦À§À¨À©À«À¬À­À¯À°À±À²À´ÀµÀ¶À·À¸À¹ÀºÀ»À¼À¿ÀÀÀÁÀÂÀÃÀÄÀÇÀÈÀÉÀÊÀËÀÌÀÍÀÎÀÏÀÐÀÑÀÒÀÓÀÔÀÕÀÖÀ×ÀÙÀÚÀÛÀÝÀÞÀàÀáÀâÀãÀäÀåÀæÀçÀèÀêÀëÀíÀîÀïÀðÀñÀòÀóÀôÀöÀ÷ÀøÀùÀúÀûÀýÁ¢Á£Á¥Á¦Á©ÁªÁ«Á¬Á­Á®Á¯Á°Á±Á²Á³Á´ÁµÁ¶Á·Á¸Á¹Á¼Á½Á¾Á¿ÁÀÁÁÁÂÁÃÁÄÁÅÁÆÁÇÁÈÁÉÁËÁÏÁÐÁÑÁÒÁÓÁÔÁÕÁÖÁ×ÁÙÁÚÁÛÁÜÁÝÁßÁàÁáÁâÁãÁäÁåÁæÁçÁèÁéÁêÁëÁìÁíÁîÁïÁñÁôÁõÁ÷ÁøÁùÁúÁûÁüÁýÂ¢Â£Â¤Â¥Â¦Â§Â©ÂªÂ«Â¬Â­Â®Â¯Â³ÂµÂ¶Â·Â¹Â¼Â½Â¿ÂÀÂÁÂÂÂÃÂÄÂÅÂÆÂÇÂÉÂÊÂËÂÌÂÑÂÒÂÓÂÔÂÕÂÖÂ×ÂØÂÙÂÚÂÛÂÜÂÝÂÞÂßÂàÂáÂâÂãÂäÂåÂæÂçÂèÂéÂêÂëÂìÂíÂîÂïÂðÂñÂòÂóÂôÂõÂöÂ÷ÂøÂùÂúÂûÂüÂýÂþÃ¡Ã¢Ã£Ã¤Ã¥Ã¦Ã§Ã¨Ã©Ã«Ã¬Ã°Ã±Ã²Ã³Ã´ÃµÃ¶Ã·Ã¸Ã¹ÃºÃ»Ã¼Ã½Ã¿ÃÀÃÁÃÃÃÄÃÅÃÆÃÇÃÈÃÉÃÊÃËÃÌÃÍÃÎÃÏÃÐÃÔÃÕÃÖÃ×ÃØÃÙÃÚÃÛÃÜÃÝÃÞÃßÃàÃâÃãÃæÃçÃèÃéÃêÃëÃìÃíÃîÃïÃðÃñÃòÃóÃôÃõÃöÃ÷ÃøÃùÃúÃûÃüÃýÃþÄ¡Ä¢Ä£Ä¤Ä¥Ä¦Ä§Ä¨Ä©ÄªÄ«Ä¬Ä­Ä®Ä¯Ä°Ä±Ä²Ä³Ä´ÄµÄ¶Ä·Ä¸Ä¹ÄºÄ»Ä¼Ä½Ä¾Ä¿ÄÀÄÁÄÂÄÃÄÄÄÅÄÆÄÇÄÈÄÉÄÊÄËÄÌÄÍÄÎÄÏÄÐÄÑÄÒÄÓÄÔÄÕÄÖÄ×ÄØÄÙÄÚÄÛÄÜÄÝÄÞÄßÄàÄáÄâÄãÄäÄåÄæÄçÄèÄéÄêÄëÄìÄíÄîÄïÄðÄñÄòÄóÄôÄõÄöÄ÷ÄøÄùÄúÄûÄüÄýÄþÅ¡Å¢Å£Å¤Å¥Å¦Å§Å¨Å©ÅªÅ«Å¬Å­Å®Å¯Å°Å±Å²Å³Å´ÅµÅ¶Å·Å¸Å¹ÅºÅ»Å¼Å½Å¾Å¿ÅÀÅÁÅÂÅÃÅÄÅÅÅÆÅÇÅÈÅÉÅÊÅËÅÌÅÍÅÎÅÏÅÐÅÑÅÒÅÓÅÔÅÕÅÖÅ×ÅØÅÙÅÚÅÛÅÜÅÝÅÞÅßÅàÅáÅâÅãÅäÅåÅæÅçÅèÅéÅêÅëÅìÅíÅîÅïÅðÅñÅòÅóÅôÅõÅöÅ÷ÅøÅùÅúÅûÅüÅýÅþÆ¡Æ¢Æ£Æ¤Æ¥Æ¦Æ§Æ¨Æ©ÆªÆ«Æ¬Æ­Æ®Æ¯Æ°Æ±Æ²Æ³Æ´ÆµÆ¶Æ·Æ¸Æ¹ÆºÆ»Æ¼Æ½Æ¾Æ¿ÆÀÆÁÆÂÆÃÆÄÆÅÆÆÆÇÆÈÆÉÆÊÆËÆÌÆÍÆÎÆÏÆÐÆÑÆÒÆÓÆÔÆÕÆÖÆ×ÆØÆÙÆÚÆÛÆÜÆÝÆÞÆßÆàÆáÆâÆãÆäÆåÆæÆçÆèÆéÆêÆëÆìÆíÆîÆïÆðÆñÆòÆóÆôÆõÆöÆ÷ÆøÆùÆúÆûÆüÆýÆþÇ¢Ç£Ç¤Ç¥Ç¦Ç§Ç¨Ç©ÇªÇ«Ç¬Ç­Ç®Ç¯Ç°Ç±Ç²Ç³Ç´ÇµÇ¶Ç·Ç¸Ç¹ÇºÇ»Ç¼Ç½Ç¾Ç¿ÇÀÇÁÇÂÇÃÇÄÇÅÇÆÇÇÇÈÇÉÇÊÇËÇÌÇÍÇÎÇÏÇÐÇÑÇÒÇÓÇÔÇÕÇÖÇ×ÇØÇÙÇÚÇÛÇÜÇÝÇÞÇßÇàÇáÇâÇãÇäÇåÇæÇçÇèÇéÇêÇëÇìÇíÇîÇïÇðÇñÇòÇóÇôÇõÇöÇ÷ÇøÇùÇúÇûÇüÇýÇþÈ¡È¢È£È¤È¥È¦È§È¨È©ÈªÈ«È¬È­È®È¯È°È±È²È³È´ÈµÈ¶È·È¸È¹ÈºÈ»È¼È½È¾È¿ÈÀÈÁÈÂÈÃÈÄÈÅÈÆÈÇÈÈÈÉÈÊÈËÈÌÈÍÈÎÈÏÈÐÈÑÈÒÈÓÈÔÈÕÈÖÈ×ÈØÈÙÈÚÈÛÈÜÈÝÈÞÈßÈàÈáÈâÈãÈäÈåÈæÈçÈèÈéÈêÈëÈìÈíÈîÈïÈðÈñÈòÈóÈôÈõÈöÈ÷ÈøÈùÈúÈûÈüÈýÈþÉ¡É¢É£É¤É¥É¦É§É¨É©ÉªÉ«É¬É­É®É¯É°É±É²É³É´ÉµÉ¶É·É¸É¹ÉºÉ»É¼É½É¾É¿ÉÀÉÁÉÂÉÃÉÄÉÅÉÆÉÇÉÈÉÉÉÊÉËÉÌÉÍÉÎÉÏÉÐÉÑÉÒÉÓÉÔÉÕÉÖÉ×ÉØÉÙÉÚÉÛÉÜÉÝÉÞÉßÉàÉáÉâÉãÉäÉåÉæÉçÉèÉéÉêÉëÉìÉíÉîÉïÉðÉñÉòÉóÉôÉõÉöÉ÷ÉøÉùÉúÉûÉüÉýÉþÊ¡Ê¢Ê£Ê¤Ê¥Ê¦Ê§Ê¨Ê©ÊªÊ«Ê¬Ê­Ê®Ê¯Ê°Ê±Ê²Ê³Ê´ÊµÊ¶Ê·Ê¸Ê¹ÊºÊ»Ê¼Ê½Ê¾Ê¿ÊÀÊÁÊÂÊÃÊÄÊÅÊÆÊÇÊÈÊÉÊÊÊËÊÌÊÍÊÎÊÏÊÐÊÑÊÒÊÓÊÔÊÕÊÖÊ×ÊØÊÙÊÚÊÛÊÜÊÝÊÞÊßÊàÊáÊâÊãÊäÊåÊæÊçÊèÊéÊêÊëÊìÊíÊîÊïÊðÊñÊòÊóÊôÊõÊöÊ÷ÊøÊùÊúÊûÊüÊýÊþË¡Ë¢Ë£Ë¤Ë¥Ë¦Ë§Ë¨Ë©ËªË«Ë¬Ë­Ë®Ë¯Ë°Ë±Ë²Ë³Ë´ËµË¶Ë·Ë¸Ë¹ËºË»Ë¼Ë½Ë¾Ë¿ËÀËÁËÂËÃËÄËÅËÆËÇËÈËÉËÊËËËÌËÍËÎËÏËÐËÑËÒËÓËÔËÕËÖË×ËØËÙËÚËÛËÜËÝËÞËßËàËáËâËãËäËåËæËçËèËéËêËëËìËíËîËïËðËñËòËóËôËõËöË÷ËøËùËúËûËüËýËþÌ¡Ì¢Ì£Ì¤Ì¥Ì¦Ì§Ì¨Ì©ÌªÌ«Ì¬Ì­Ì®Ì¯Ì°Ì±Ì²Ì³Ì´ÌµÌ¶Ì·Ì¸Ì¹ÌºÌ»Ì¼Ì½Ì¾Ì¿ÌÀÌÁÌÂÌÃÌÄÌÅÌÆÌÇÌÈÌÉÌÊÌËÌÌÌÍÌÎÌÏÌÐÌÑÌÒÌÓÌÔÌÕÌÖÌ×ÌØÌÙÌÚÌÛÌÜÌÝÌÞÌßÌàÌáÌâÌãÌäÌåÌæÌçÌèÌéÌêÌëÌìÌíÌîÌïÌðÌñÌòÌóÌôÌõÌöÌ÷ÌøÌùÌúÌûÌüÌýÌþÍ¡Í¢Í£Í¤Í¥Í¦Í§Í¨Í©ÍªÍ«Í¬Í­Í®Í¯Í°Í±Í²Í³Í´ÍµÍ¶Í·Í¸Í¹ÍºÍ»Í¼Í½Í¾Í¿ÍÀÍÁÍÂÍÃÍÄÍÅÍÆÍÇÍÈÍÉÍÊÍËÍÌÍÍÍÎÍÏÍÐÍÑÍÒÍÓÍÔÍÕÍÖÍ×ÍØÍÙÍÚÍÛÍÜÍÝÍÞÍßÍàÍáÍâÍãÍäÍåÍæÍçÍèÍéÍêÍëÍìÍíÍîÍïÍðÍñÍòÍóÍôÍõÍöÍ÷ÍøÍùÍúÍûÍüÍýÍþÎ¡Î¢Î£Î¤Î¥Î¦Î§Î¨Î©ÎªÎ«Î¬Î­Î®Î¯Î°Î±Î²Î³Î´ÎµÎ¶Î·Î¸Î¹ÎºÎ»Î¼Î½Î¾Î¿ÎÀÎÁÎÂÎÃÎÄÎÅÎÆÎÇÎÈÎÉÎÊÎËÎÌÎÍÎÎÎÏÎÐÎÑÎÒÎÓÎÔÎÕÎÖÎ×ÎØÎÙÎÚÎÛÎÜÎÝÎÞÎßÎàÎáÎâÎãÎäÎåÎæÎçÎèÎéÎêÎëÎìÎíÎîÎïÎðÎñÎòÎóÎôÎõÎöÎ÷ÎøÎùÎúÎûÎüÎýÎþÏ¡Ï¢Ï£Ï¤Ï¥Ï¦Ï§Ï¨Ï©ÏªÏ«Ï¬Ï­Ï®Ï¯Ï°Ï±Ï²Ï³Ï´ÏµÏ¶Ï·Ï¸Ï¹ÏºÏ»Ï¼Ï½Ï¾Ï¿ÏÀÏÁÏÂÏÃÏÄÏÅÏÆÏÇÏÈÏÉÏÊÏËÏÌÏÍÏÎÏÏÏÐÏÑÏÒÏÓÏÔÏÕÏÖÏ×ÏØÏÙÏÚÏÛÏÜÏÝÏÞÏßÏàÏáÏâÏãÏäÏåÏæÏçÏèÏéÏêÏëÏìÏíÏîÏïÏðÏñÏòÏóÏôÏõÏöÏ÷ÏøÏùÏúÏûÏüÏýÏþÐ¡Ð¢Ð£Ð¤Ð¥Ð¦Ð§Ð¨Ð©ÐªÐ«Ð¬Ð­Ð®Ð¯Ð°Ð±Ð²Ð³Ð´ÐµÐ¶Ð·Ð¸Ð¹ÐºÐ»Ð¼Ð½Ð¾Ð¿ÐÀÐÁÐÂÐÃÐÄÐÅÐÆÐÇÐÈÐÉÐÊÐËÐÌÐÍÐÎÐÏÐÐÐÑÐÒÐÓÐÔÐÕÐÖÐ×ÐØÐÙÐÚÐÛÐÜÐÝÐÞÐßÐàÐáÐâÐãÐäÐåÐæÐçÐèÐéÐêÐëÐìÐíÐîÐïÐðÐñÐòÐóÐôÐõÐöÐ÷ÐøÐùÐúÐûÐüÐýÐþÑ¡Ñ¢Ñ£Ñ¤Ñ¥Ñ¦Ñ§Ñ¨Ñ©ÑªÑ«Ñ¬Ñ­Ñ®Ñ¯Ñ°Ñ±Ñ²Ñ³Ñ´ÑµÑ¶Ñ·Ñ¸Ñ¹ÑºÑ»Ñ¼Ñ½Ñ¾Ñ¿ÑÀÑÁÑÂÑÃÑÄÑÅÑÆÑÇÑÈÑÉÑÊÑËÑÌÑÍÑÎÑÏÑÐÑÑÑÒÑÓÑÔÑÕÑÖÑ×ÑØÑÙÑÚÑÛÑÜÑÝÑÞÑßÑàÑáÑâÑãÑäÑåÑæÑçÑèÑéÑêÑëÑìÑíÑîÑïÑðÑñÑòÑóÑôÑõÑöÑ÷ÑøÑùÑúÑûÑüÑýÑþÒ¡Ò¢Ò£Ò¤Ò¥Ò¦Ò§Ò¨Ò©ÒªÒ«Ò¬Ò­Ò®Ò¯Ò°Ò±Ò²Ò³Ò´ÒµÒ¶Ò·Ò¸Ò¹ÒºÒ»Ò¼Ò½Ò¾Ò¿ÒÀÒÁÒÂÒÃÒÄÒÅÒÆÒÇÒÈÒÉÒÊÒËÒÌÒÍÒÎÒÏÒÐÒÑÒÒÒÓÒÔÒÕÒÖÒ×ÒØÒÙÒÚÒÛÒÜÒÝÒÞÒßÒàÒáÒâÒãÒäÒåÒæÒçÒèÒéÒêÒëÒìÒíÒîÒïÒðÒñÒòÒóÒôÒõÒöÒ÷ÒøÒùÒúÒûÒüÒýÒþÓ¡Ó¢Ó£Ó¤Ó¥Ó¦Ó§Ó¨Ó©ÓªÓ«Ó¬Ó­Ó®Ó¯Ó°Ó±Ó²Ó³Ó´ÓµÓ¶Ó»Ó¼Ó½Ó¾Ó¿ÓÀÓÁÓÂÓÃÓÄÓÅÓÆÓÇÓÈÓÉÓÊÓËÓÌÓÍÓÎÓÏÓÐÓÑÓÒÓÓÓÔÓÕÓÖÓ×ÓØÓÙÓÚÓÛÓÜÓÝÓÞÓßÓàÓáÓâÓãÓäÓåÓæÓçÓèÓéÓêÓëÓìÓíÓîÓïÓðÓñÓòÓóÓôÓõÓöÓ÷ÓøÓùÓúÓûÓüÓýÓþÔ¡Ô¢Ô£Ô¤Ô¥Ô¦Ô§Ô¨Ô©ÔªÔ«Ô¬Ô­Ô®Ô¯Ô°Ô±Ô²Ô³Ô´ÔµÔ¶Ô·Ô¸Ô¹ÔºÔ»Ô¼Ô½Ô¾Ô¿ÔÀÔÁÔÂÔÃÔÄÔÅÔÆÔÇÔÈÔÉÔÊÔËÔÌÔÍÔÎÔÏÔÐÔÑÔÒÔÓÔÔÔÕÔÖÔ×ÔØÔÙÔÚÔÛÔÜÔÝÔÞÔßÔàÔáÔâÔãÔäÔåÔæÔçÔèÔéÔêÔëÔìÔíÔîÔïÔðÔñÔòÔóÔôÔõÔöÔ÷ÔøÔùÔúÔûÔüÔýÔþÕ¡Õ¢Õ£Õ¤Õ¥Õ¦Õ§Õ¨Õ©ÕªÕ«Õ¬Õ­Õ®Õ¯Õ°Õ±Õ²Õ³Õ´ÕµÕ¶Õ·Õ¸Õ¹Õ»Õ¼Õ½Õ¾Õ¿ÕÀÕÁÕÂÕÃÕÄÕÅÕÆÕÇÕÈÕÉÕÊÕËÕÌÕÍÕÎÕÏÕÐÕÑÕÒÕÓÕÔÕÕÕÖÕ×ÕØÕÙÕÚÕÛÕÜÕÝÕÞÕßÕàÕáÕâÕãÕäÕåÕæÕçÕèÕéÕêÕëÕìÕíÕîÕïÕðÕñÕòÕóÕôÕõÕöÕ÷ÕøÕùÕúÕûÕüÕýÕþÖ¡Ö¢Ö£Ö¤Ö¥Ö¦Ö§Ö¨Ö©ÖªÖ«Ö¬Ö­Ö®Ö¯Ö°Ö±Ö²Ö³Ö´ÖµÖ¶Ö·Ö¸Ö¹ÖºÖ»Ö¼Ö½Ö¾Ö¿ÖÀÖÁÖÂÖÃÖÄÖÅÖÆÖÇÖÈÖÉÖÊÖËÖÌÖÍÖÎÖÏÖÐÖÑÖÒÖÓÖÔÖÕÖÖÖ×ÖØÖÙÖÚÖÛÖÜÖÝÖÞÖßÖàÖáÖâÖãÖäÖåÖæÖçÖèÖéÖêÖëÖìÖíÖîÖïÖðÖñÖòÖóÖôÖõÖöÖ÷ÖøÖùÖúÖûÖüÖýÖþ×¡×¢×£×¤×¥×¦×§×¨×©×ª×¬×­×®×¯×°×±×²×³×´×µ×¶×·×¸×¹×º×»×¼×½×¾×¿×À×Á×Â×Ã×Ä×Å×Æ×Ç×È×É×Ê×Ë×Ì×Î×Ï×Ð×Ñ×Ó×Ô×Õ×Ö×Ø×Ù×Ú×Û×Ü×Ý×Þ×ß×à×á×â×ã×ä×å×æ×ç×è×é×ê×ì×í×î×ï×ð×ñ×ò×ó×ô×ö×÷×ø×ù"

Randomize
Dim R,N,L
L = len(str)
For N = 1 to num
R = R & Mid(Str,Fix(Rnd*L),1)
Next
Rnd_cn = R


End Function

Sub DisplayGflSDK_cn

	Dim rndStr
	rndStr = Code_RndNumber(2)
	Dim MyObj
	Set MyObj = Server.CreateObject("GflAx190.GflAx")
	MyObj.EnableLZW = True
	MyObj.LoadBitmap(server.mappath(DEF_BBS_HomeUrl & "images/null.jpg"))

	Dim fontName
	fontName = Array("ËÎÌå","ºÚÌå")

	MyObj.NewBitmap 32, 26
	MyObj.FontBold = True
	Randomize
	MyObj.FontName = fontName(Fix(Rnd*1))
	MyObj.FontSize = 25
	
	Dim c,N
	For N = 1 to Len(rndStr)
		c = Rnd*255
		MyObj.TextOut Mid(rndStr,N,1),2+25*N-25,-1,c
	Next
	
	MyObj.UseTransparency = true
	MyObj.ChangeColorDepth 8
	MyObj.SaveJPEGQuality = 20
	Response.ContentType="image/jpg"
	MyObj.SaveFormat = 1
	'MyObj.MaskColor = 255*256*256+255*256+255
	Response.BinaryWrite MyObj.SendBinary
	Set MyObj = Nothing

End Sub

Sub DisplayGflSDK_num

	Dim MyObj
	Set MyObj = Server.CreateObject("GflAx190.GflAx")
	MyObj.EnableLZW = True
	MyObj.LoadBitmap(server.mappath(DEF_BBS_HomeUrl & "images/null.jpg"))


	Dim SafeCode,a,b,b1,tp
	Randomize
	tp = Fix(Rnd*5)
	Randomize
	a = Fix(Rnd*13)
	Randomize
	b = Fix(Rnd*9)
	b1 = Fix(Rnd*9)
	
	Dim numName
	fontName = Array("£°","£±","¶þ","Èý","ËÄ","5","£¶","£·","°Ë","¾Å","Ê®","£±£±","12","£±£³")

	Select Case tp
	case 0:
		SafeCode = "" & (a * b +b1)
		Session(DEF_MasterCookies & "RndNum") = SafeCode
		Session(DEF_MasterCookies & "RndNum_par") = ""
		RndNumberStr = fontName(a) & "³Ë" & fontName(b) & "¼Ó" & fontName(b1) & "£½£¿"
	Case 1:
		SafeCode = "" & (a*a)
		Session(DEF_MasterCookies & "RndNum") = SafeCode
		Session(DEF_MasterCookies & "RndNum_par") = ""
		RndNumberStr = "¼ÆËã" & fontName(a) & "µÄÆ½·½£½£¿"
	Case 2:
		SafeCode = "" & (a*a+b1)
		Session(DEF_MasterCookies & "RndNum") = SafeCode
		Session(DEF_MasterCookies & "RndNum_par") = ""
		RndNumberStr = "" & fontName(a) & "Æ½·½¼Ó" & fontName(b1) & "£½£¿"
	case 3:
		SafeCode = "" & (a * b)
		Session(DEF_MasterCookies & "RndNum") = SafeCode
		Session(DEF_MasterCookies & "RndNum_par") = ""
		RndNumberStr = fontName(b) & "¡Á" & fontName(a) & "£½£¿"
	case 4:
		SafeCode = "" & Rnd_cn(1)
		Session(DEF_MasterCookies & "RndNum") = SafeCode
		Session(DEF_MasterCookies & "RndNum_par") = ""
		RndNumberStr = "ÇëÊäÈë:" & SafeCode
		
	End Select

	Dim fontName
	fontName = Array("ËÎÌå","ºÚÌå")

	MyObj.NewBitmap len(RndNumberStr)*21, 26
	MyObj.FontBold = True
	Randomize
	MyObj.FontName = fontName(Fix(Rnd*2))
	MyObj.FontSize = 18+rnd*3
	
	
	Dim r,g,blue,N,pos,color
	For N = 1 to len(RndNumberStr)
		
		Randomize
		tp = Fix(Rnd*2)
		Select Case tp
		Case 0:
			Randomize
			r = Rnd*55
			Randomize
			g=rnd*55
			Randomize
			blue=rnd*55
			pos = rnd*5
			color = r*256*256+g*256+blue
			'MyObj.TextOut Mid(RndNumberStr,N,1),2+18*N-18,-1+pos+rnd*2-rnd*2,222*256*256+222*256+255
			MyObj.TextOut Mid(RndNumberStr,N,1),2+18*N-18,-1+pos+1,color
			MyObj.TextOut Mid(RndNumberStr,N,1),2+18*N-18+1,-1+pos,color
			MyObj.TextOut Mid(RndNumberStr,N,1),2+18*N-18+1,-1+pos+1,color
			MyObj.TextOut Mid(RndNumberStr,N,1),2+18*N-18-1,-1+pos,color
			MyObj.TextOut Mid(RndNumberStr,N,1),2+18*N-18,-1+pos-1,color
			MyObj.TextOut Mid(RndNumberStr,N,1),2+18*N-18-1,-1+pos-1,color
			MyObj.TextOut Mid(RndNumberStr,N,1),2+18*N-18+1,-1+pos-1,color
			MyObj.TextOut Mid(RndNumberStr,N,1),2+18*N-18-1,-1+pos+1,color
			MyObj.TextOut Mid(RndNumberStr,N,1),2+18*N-18,-1+pos,255*256*256+255*256+255
		Case 1:
			Randomize
			r = Rnd*55
			Randomize
			g=rnd*55
			Randomize
			blue=rnd*55
			pos = rnd*5
			color = r*256*256+g*256+blue
			MyObj.TextOut Mid(RndNumberStr,N,1),2+18*N-18,-1+pos,color
		End Select
	Next
	
	MyObj.UseTransparency = true
	MyObj.ChangeColorDepth 8
	MyObj.SaveJPEGQuality = 58
	Response.ContentType="image/jpg"
	MyObj.SaveFormat = 1
	'MyObj.MaskColor = 255*256*256+255*256+255
	Response.BinaryWrite MyObj.SendBinary
	Set MyObj = Nothing

End Sub

Sub RndNumber_Jpeg

	Dim Jpeg
	Set Jpeg = Server.CreateObject("Persits.Jpeg")
	Jpeg.New 50,21,0
	Jpeg.Canvas.Font.Color = &HFFFFFF
	Jpeg.Canvas.Font.Family = "Impact"
	'Jpeg.Canvas.Font.Family = "SharKbait Regular"
	Jpeg.Canvas.Font.Bold = false
	Jpeg.Canvas.Font.Size = 19
	Jpeg.Canvas.Font.Quality = 4
	Jpeg.Canvas.PrintText 6, 1, Code_RndNumber(1)
	response.binarywrite jpeg.Binary
	jpeg.Close
	Set Jpeg = Nothing

End Sub

%>f