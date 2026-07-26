<%
const DEF_UserEnableUserTitle = 1
const DEF_UserUserTitleNeedLevel = 0
const LMT_UserNameEnableEnglishWords = 1
const LMT_UserNameEnableChineseChar = 1
const LMT_UserNameEnableChineseWords = 1
const DEF_User_RegPoints = 0
const LMT_EnableRegNewUsers = 1
const DEF_ShortestUserName = 2
const DEF_RegNewUserTotalRestTime = 10
const DEF_UserNewRegAttestMode = 0
const DEF_UserActivationExpiresDay = 30
const DEF_User_GetPassMode = 4
Dim DEF_UserLevelString,DEF_UserLevelNum,DEF_UserLevelPoints
DEF_UserLevelString = Array("新手上路","论坛游民","论坛游侠","职业侠客","大侠","骑士","圣骑士","精灵","精灵王","风云使者","光明使者","天使","大天使","精灵使","法师","大法师","法王","老法王","天神","天王","法老")
DEF_UserLevelPoints = Array(0,12,25,50,80,150,250,400,700,1000,1500,2500,5000,8000,12000,20000,30000,40000,50000,60000,99999)
DEF_UserLevelNum = Ubound(DEF_UserLevelString,1)
Dim DEF_UserOfficerString,DEF_UserOfficerNum
DEF_UserOfficerString = Array("游侠|默认状态","退休官员|曾经的版主？","雷霆崖|雷霆二的成员","网站成员|","管理员|","妙音阁|","论坛十年纪念|你在论坛年龄已经十岁了，并且在10年后再次光临过这儿。","论坛妹子|","论坛五年纪念|从注册的那一天算起，时隔五年后还能记得再次登录","高级经验达人|经验突破525600（365天）","初级经验达人|经验突破21900（365小时）","梅开二度|这位版主曾经退休过，但又重新上任了")
DEF_UserOfficerNum = Ubound(DEF_UserOfficerString,1)
const DEF_FiltrateUserNameString = ""
const DEF_UserShortestPassword = 5
const DEF_UserShortestPasswordMaster = 8
const Def_UserTestNumber = 1
const DEF_seller_email = ""
const DEF_seller_minpoints = 1
const DEF_seller_exchangescale = 1
%>
