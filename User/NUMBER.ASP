<!--#include file="../inc/BBSsetup.asp"-->
<!--#include file="inc/Canvassafecode.asp"-->
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
	RndNumber_Jpeg()
Else
	DisplayCanvasCode()
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
	MyObj.FontName = "宋体"
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
str = "啊阿埃挨哎唉哀皑癌蔼矮艾碍爱隘鞍安俺按暗岸胺案肮昂盎凹敖熬袄傲奥懊澳芭扒叭吧笆八疤巴拔跋靶把坝霸罢爸白柏百摆佰败拜斑班搬扳般板版扮拌伴瓣半办绊邦帮榜膀绑棒磅蚌傍谤苞胞包褒剥薄雹保堡饱宝抱报暴豹鲍爆杯碑悲卑北辈背贝倍狈备惫被奔本笨崩绷甭蹦迸逼鼻比鄙笔彼碧蓖蔽毕毙币庇痹闭敝弊必辟壁臂避边编贬便变辨辩辫遍标表憋别彬斌滨宾摈兵冰柄丙秉饼炳病并玻播拨波博搏伯帛舶脖膊渤泊驳捕卜哺补不布步簿部擦猜裁材才财睬踩采彩菜蔡餐参蚕残惭惨灿苍舱仓沧藏操糙槽曹草厕策侧册测层蹭插叉茶查察岔差诧拆柴豺搀掺蝉馋谗缠产颤昌猖场尝常长偿肠厂敞畅唱倡超抄钞朝嘲潮巢吵炒车扯撤彻澈臣辰尘晨忱沉陈趁衬撑称城橙成呈乘程惩澄诚承逞骋吃痴持匙池迟弛驰耻齿侈尺赤翅斥炽充冲虫崇宠抽酬稠愁筹仇绸瞅丑臭初出厨锄除楚础储矗搐触处揣川穿传船喘串窗幢床闯创吹炊捶锤垂醇唇纯蠢戳绰磁雌辞慈瓷词此刺赐次聪葱匆从丛凑粗醋促蹿窜摧崔催脆瘁粹淬翠村存寸磋撮搓措挫错搭达答打大呆歹戴带代贷袋待逮怠耽担丹单掸胆旦但惮淡诞弹蛋当挡党荡档刀捣蹈倒岛祷导到稻悼道盗德得的蹬灯登等瞪凳邓堤低滴迪敌笛狄抵底地蒂第帝弟递缔颠掂点典垫电甸店惦奠淀殿碉叼雕凋刁掉吊钓调跌爹碟蝶迭谍叠丁盯叮顶鼎定订丢东冬董懂动栋侗冻洞兜抖斗陡豆逗都毒独读堵睹赌杜肚度渡妒端短锻段断缎堆兑队对吨蹲敦顿囤盾遁掇多夺垛躲朵跺舵剁惰堕蛾峨鹅俄额讹娥恶厄扼遏鄂饿恩而儿耳尔饵洱二发罚筏伐乏阀法帆番翻繁凡烦反返范犯饭泛坊芳方房防妨仿访纺放菲非啡飞肥匪诽吠肺废沸费芬吩分纷坟焚粉奋份忿愤粪丰封枫蜂峰锋风疯烽逢冯缝讽奉凤佛否夫敷肤扶拂辐幅符伏俘服浮福弗甫抚辅俯釜斧脯腑府腐赴副覆赋复傅付父腹负富附妇缚咐嘎该改钙盖溉干甘杆柑竿肝赶感秆敢冈刚钢缸肛纲岗港杠篙高膏羔糕搞告哥歌搁戈鸽胳割革格阁隔个各给根跟耕更庚埂耿梗工攻功恭龚供躬公宫弓巩拱贡共钩勾沟苟狗垢构购够辜菇咕估沽孤姑鼓古骨谷股故顾固雇刮瓜剐寡挂褂乖拐怪棺关官冠观管馆罐惯灌贯光广逛瑰规圭硅归龟闺轨鬼诡癸桂柜跪贵刽滚棍锅郭国果裹过哈骸孩海亥害骇酣韩含涵寒函喊罕撼捍旱憾悍焊汗汉杭航嚎豪毫好耗号浩呵荷菏核禾和何合盒河鹤贺嘿黑痕很狠恨哼亨横衡恒轰哄烘虹鸿洪宏弘红喉侯猴吼厚候后呼乎忽瑚壶葫胡蝴狐糊湖弧虎唬护互沪户花哗华猾滑画划化话徊怀淮坏欢环还缓换患唤痪幻荒慌黄簧皇凰惶煌晃恍谎灰挥辉徽恢蛔回毁悔慧惠晦贿会汇讳诲绘昏婚魂浑混活伙火获或惑霍货祸击圾基机畸稽积肌饥迹激讥鸡姬绩缉吉极棘辑籍集及急疾汲即嫉级挤几脊己技季祭剂悸济寄寂计记既忌际妓继纪嘉夹佳家加甲钾假稼价架驾嫁歼监坚尖笺间煎兼肩艰奸检柬碱硷拣捡简俭剪减荐鉴践贱见键箭件健舰剑渐溅建僵姜将江疆蒋奖讲匠酱降蕉椒礁焦胶交郊浇骄娇嚼搅侥脚狡角饺缴绞教酵轿较叫揭接皆街阶截劫节茎睛晶鲸京惊精经井警景颈静境敬镜径竟竞净窘揪究纠韭久灸九酒救旧舅咎就疚鞠拘居驹菊局咀矩举沮聚拒据巨具踞锯俱句惧炬剧捐鹃娟倦眷卷绢抉掘倔爵桔杰捷睫竭洁结解姐戒藉芥界借介届巾筋斤金今津襟紧锦仅谨进靳晋禁近烬浸尽劲荆兢觉决诀绝均菌钧军君峻俊郡骏卡咯开揩楷凯慨刊堪勘坎砍看康慷糠扛抗亢炕考拷烤靠坷苛柯棵磕颗科壳咳可渴克刻客课肯啃垦恳坑吭空恐孔控抠口扣寇枯哭窟苦酷库裤夸垮挎跨胯块筷快宽款匡筐狂框矿眶旷况亏盔葵魁傀愧坤昆捆困括扩阔垃拉蜡腊辣啦来赖蓝婪栏拦篮阑兰揽览懒缆烂滥狼廊郎朗浪捞劳牢老佬姥酪烙涝勒乐雷蕾磊累垒擂类泪棱楞冷厘梨犁黎狸离理李里鲤礼莉荔吏丽厉励砾历利例立粒隶力俩联莲连镰廉怜涟帘敛脸链恋炼练粮凉良两辆量晾亮谅撩聊僚疗燎寥辽了料列裂烈劣猎琳林磷临邻鳞淋凛吝拎玲菱零龄铃伶羚凌灵陵岭领另令溜榴留刘流柳六龙聋咙笼垄拢陇楼娄搂漏陋芦卢颅庐炉鲁碌露路鹿录陆驴吕铝侣旅履屡缕虑律率滤绿卵乱掠略抡轮伦仑沦纶论萝螺罗逻锣箩骡裸落洛骆络妈麻玛码蚂马骂嘛吗埋买麦卖迈脉瞒馒蛮满蔓曼慢漫谩芒茫盲氓忙莽猫茅毛矛冒帽貌贸么玫枚梅酶霉煤没眉媒每美昧妹媚门闷们萌蒙檬盟锰猛梦孟眯迷谜弥米秘觅泌蜜密幂棉眠绵免勉面苗描瞄藐秒渺庙妙蔑灭民抿皿敏悯闽明螟鸣铭名命谬摸摹蘑模膜磨摩魔抹末莫墨默沫漠寞陌谋牟某拇牡亩姆母墓暮幕募慕木目睦牧穆拿哪呐钠那娜纳氖乃奶耐奈南男难囊挠脑恼闹淖呢馁内嫩能妮霓倪泥尼拟你匿腻逆溺蔫拈年碾撵捻念娘酿鸟尿捏聂孽啮镊镍涅您柠狞凝宁拧泞牛扭钮纽脓浓农弄奴努怒女暖虐疟挪懦糯诺哦欧鸥殴藕呕偶沤啪趴爬帕怕琶拍排牌徘湃派攀潘盘磐盼畔判叛乓庞旁耪胖抛咆刨炮袍跑泡呸胚培裴赔陪配佩沛喷盆砰抨烹澎彭蓬棚硼篷膨朋鹏捧碰坯砒霹批披劈琵毗啤脾疲皮匹痞僻屁譬篇偏片骗飘漂瓢票撇瞥拼频贫品聘乒坪苹萍平凭瓶评屏坡泼颇婆破魄迫粕剖扑铺仆莆葡菩蒲埔朴圃普浦谱曝瀑期欺栖戚妻七凄漆柒沏其棋奇歧畦崎脐齐旗祈祁骑起岂乞企启契砌器气迄弃汽泣讫掐洽牵扦钎铅千迁签仟谦乾黔钱钳前潜遣浅谴堑嵌欠歉枪呛腔羌墙蔷强抢橇锹敲悄桥瞧乔侨巧鞘撬翘峭俏窍切茄且怯窃钦侵亲秦琴勤芹擒禽寝沁青轻氢倾卿清擎晴氰情顷请庆琼穷秋丘邱球求囚酋泅趋区蛆曲躯屈驱渠取娶龋趣去圈颧权醛泉全痊拳犬券劝缺炔瘸却鹊榷确雀裙群然燃冉染瓤壤攘嚷让饶扰绕惹热壬仁人忍韧任认刃妊纫扔仍日戎茸蓉荣融熔溶容绒冗揉柔肉茹蠕儒孺如辱乳汝入褥软阮蕊瑞锐闰润若弱撒洒萨腮鳃塞赛三叁伞散桑嗓丧搔骚扫嫂瑟色涩森僧莎砂杀刹沙纱傻啥煞筛晒珊苫杉山删煽衫闪陕擅赡膳善汕扇缮墒伤商赏晌上尚裳梢捎稍烧芍勺韶少哨邵绍奢赊蛇舌舍赦摄射慑涉社设砷申呻伸身深娠绅神沈审婶甚肾慎渗声生甥牲升绳省盛剩胜圣师失狮施湿诗尸虱十石拾时什食蚀实识史矢使屎驶始式示士世柿事拭誓逝势是嗜噬适仕侍释饰氏市恃室视试收手首守寿授售受瘦兽蔬枢梳殊抒输叔舒淑疏书赎孰熟薯暑曙署蜀黍鼠属术述树束戍竖墅庶数漱恕刷耍摔衰甩帅栓拴霜双爽谁水睡税吮瞬顺舜说硕朔烁斯撕嘶思私司丝死肆寺嗣四伺似饲巳松耸怂颂送宋讼诵搜艘擞嗽苏酥俗素速粟僳塑溯宿诉肃酸蒜算虽隋随绥髓碎岁穗遂隧祟孙损笋蓑梭唆缩琐索锁所塌他它她塔獭挞蹋踏胎苔抬台泰酞太态汰坍摊贪瘫滩坛檀痰潭谭谈坦毯袒碳探叹炭汤塘搪堂棠膛唐糖倘躺淌趟烫掏涛滔绦萄桃逃淘陶讨套特藤腾疼誊梯剔踢锑提题蹄啼体替嚏惕涕剃屉天添填田甜恬舔腆挑条迢眺跳贴铁帖厅听烃汀廷停亭庭挺艇通桐酮瞳同铜彤童桶捅筒统痛偷投头透凸秃突图徒途涂屠土吐兔湍团推颓腿蜕褪退吞屯臀拖托脱鸵陀驮驼椭妥拓唾挖哇蛙洼娃瓦袜歪外豌弯湾玩顽丸烷完碗挽晚皖惋宛婉万腕汪王亡枉网往旺望忘妄威巍微危韦违桅围唯惟为潍维苇萎委伟伪尾纬未蔚味畏胃喂魏位渭谓尉慰卫瘟温蚊文闻纹吻稳紊问嗡翁瓮挝蜗涡窝我斡卧握沃巫呜钨乌污诬屋无芜梧吾吴毋武五捂午舞伍侮坞戊雾晤物勿务悟误昔熙析西硒矽晰嘻吸锡牺稀息希悉膝夕惜熄烯溪汐犀檄袭席习媳喜铣洗系隙戏细瞎虾匣霞辖暇峡侠狭下厦夏吓掀锨先仙鲜纤咸贤衔舷闲涎弦嫌显险现献县腺馅羡宪陷限线相厢镶香箱襄湘乡翔祥详想响享项巷橡像向象萧硝霄削哮嚣销消宵淆晓小孝校肖啸笑效楔些歇蝎鞋协挟携邪斜胁谐写械卸蟹懈泄泻谢屑薪芯锌欣辛新忻心信衅星腥猩惺兴刑型形邢行醒幸杏性姓兄凶胸匈汹雄熊休修羞朽嗅锈秀袖绣墟戌需虚嘘须徐许蓄酗叙旭序畜恤絮婿绪续轩喧宣悬旋玄选癣眩绚靴薛学穴雪血勋熏循旬询寻驯巡殉汛训讯逊迅压押鸦鸭呀丫芽牙蚜崖衙涯雅哑亚讶焉咽阉烟淹盐严研蜒岩延言颜阎炎沿奄掩眼衍演艳堰燕厌砚雁唁彦焰宴谚验殃央鸯秧杨扬佯疡羊洋阳氧仰痒养样漾邀腰妖瑶摇尧遥窑谣姚咬舀药要耀椰噎耶爷野冶也页掖业叶曳腋夜液一壹医揖铱依伊衣颐夷遗移仪胰疑沂宜姨彝椅蚁倚已乙矣以艺抑易邑屹亿役臆逸肄疫亦裔意毅忆义益溢诣议谊译异翼翌绎茵荫因殷音阴姻吟银淫寅饮尹引隐印英樱婴鹰应缨莹萤营荧蝇迎赢盈影颖硬映哟拥佣踊蛹咏泳涌永恿勇用幽优悠忧尤由邮铀犹油游酉有友右佑釉诱又幼迂淤于盂榆虞愚舆余俞逾鱼愉渝渔隅予娱雨与屿禹宇语羽玉域芋郁吁遇喻峪御愈欲狱育誉浴寓裕预豫驭鸳渊冤元垣袁原援辕园员圆猿源缘远苑愿怨院曰约越跃钥岳粤月悦阅耘云郧匀陨允运蕴酝晕韵孕匝砸杂栽哉灾宰载再在咱攒暂赞赃脏葬遭糟凿藻枣早澡蚤躁噪造皂灶燥责择则泽贼怎增憎曾赠扎喳渣札轧铡闸眨栅榨咋乍炸诈摘斋宅窄债寨瞻毡詹粘沾盏斩辗崭展栈占战站湛绽樟章彰漳张掌涨杖丈帐账仗胀瘴障招昭找沼赵照罩兆肇召遮折哲蛰辙者锗蔗这浙珍斟真甄砧臻贞针侦枕疹诊震振镇阵蒸挣睁征狰争怔整拯正政帧症郑证芝枝支吱蜘知肢脂汁之织职直植殖执值侄址指止趾只旨纸志挚掷至致置帜峙制智秩稚质炙痔滞治窒中盅忠钟衷终种肿重仲众舟周州洲诌粥轴肘帚咒皱宙昼骤珠株蛛朱猪诸诛逐竹烛煮拄瞩嘱主著柱助蛀贮铸筑住注祝驻抓爪拽专砖转赚篆桩庄装妆撞壮状椎锥追赘坠缀谆准捉拙卓桌琢茁酌啄着灼浊兹咨资姿滋孜紫仔籽子自渍字棕踪宗综总纵邹走奏揍租足卒族祖诅阻组钻嘴醉最罪尊遵昨左佐做作坐座"

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
	fontName = Array("宋体","黑体")

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
	fontName = Array("０","１","二","三","四","5","６","７","八","九","十","１１","12","１３")

	Select Case tp
	case 0:
		SafeCode = "" & (a * b +b1)
		Session(DEF_MasterCookies & "RndNum") = SafeCode
		Session(DEF_MasterCookies & "RndNum_par") = ""
		RndNumberStr = fontName(a) & "乘" & fontName(b) & "加" & fontName(b1) & "＝？"
	Case 1:
		SafeCode = "" & (a*a)
		Session(DEF_MasterCookies & "RndNum") = SafeCode
		Session(DEF_MasterCookies & "RndNum_par") = ""
		RndNumberStr = "计算" & fontName(a) & "的平方＝？"
	Case 2:
		SafeCode = "" & (a*a+b1)
		Session(DEF_MasterCookies & "RndNum") = SafeCode
		Session(DEF_MasterCookies & "RndNum_par") = ""
		RndNumberStr = "" & fontName(a) & "平方加" & fontName(b1) & "＝？"
	case 3:
		SafeCode = "" & (a * b)
		Session(DEF_MasterCookies & "RndNum") = SafeCode
		Session(DEF_MasterCookies & "RndNum_par") = ""
		RndNumberStr = fontName(b) & "×" & fontName(a) & "＝？"
	case 4:
		SafeCode = "" & Rnd_cn(1)
		Session(DEF_MasterCookies & "RndNum") = SafeCode
		Session(DEF_MasterCookies & "RndNum_par") = ""
		RndNumberStr = "请输入:" & SafeCode
		
	End Select

	Dim fontName
	fontName = Array("宋体","黑体")

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

%>