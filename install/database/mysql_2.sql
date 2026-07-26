/*
Navicat MySQL Data Transfer

Source Server         : mysql56
Source Server Version : 50610
Source Host           : localhost:3307
Source Database       : leadbbs

Target Server Type    : MYSQL
Target Server Version : 50610
File Encoding         : 65001

Date: 2013-03-12 01:03:38
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for `hbtrigger_englishnews`
-- ----------------------------
DROP TABLE IF EXISTS `hbtrigger_englishnews`;
CREATE TABLE `hbtrigger_englishnews` (
  `Serial` bigint(20) NOT NULL AUTO_INCREMENT,
  `Id` int(11) NOT NULL DEFAULT '0',
  `Opr` varchar(16) CHARACTER SET utf8 DEFAULT '',
  `Fields` text CHARACTER SET utf8,
  PRIMARY KEY (`Serial`),
  KEY `ITriggerOprSerial` (`Opr`,`Serial`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of hbtrigger_englishnews
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_announce`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_announce`;
CREATE TABLE `leadbbs_announce` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `ParentID` bigint(20) NOT NULL DEFAULT '0',
  `TopicSortID` int(11) NOT NULL DEFAULT '1',
  `BoardID` int(11) NOT NULL DEFAULT '0',
  `RootID` bigint(20) NOT NULL DEFAULT '0',
  `ChildNum` int(11) NOT NULL DEFAULT '0',
  `Layer` int(11) NOT NULL DEFAULT '1',
  `Title` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `Content` mediumtext CHARACTER SET utf8 NOT NULL,
  `Opinion` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `FaceIcon` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `ndatetime` bigint(20) NOT NULL DEFAULT '0',
  `LastTime` bigint(20) NOT NULL DEFAULT '0',
  `Hits` bigint(20) NOT NULL DEFAULT '0',
  `Length` int(11) NOT NULL DEFAULT '0',
  `UserName` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `UserID` bigint(20) NOT NULL DEFAULT '0',
  `HTMLFlag` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `UnderWriteFlag` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `NotReplay` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `IPAddress` varchar(15) CHARACTER SET ascii NOT NULL DEFAULT '',
  `LastUser` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `GoodFlag` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `TopicType` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `NeedValue` bigint(20) NOT NULL DEFAULT '0',
  `PollNum` bigint(20) NOT NULL DEFAULT '0',
  `OtherInfo` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `RootMaxID` bigint(20) NOT NULL DEFAULT '0',
  `RootMinID` bigint(20) NOT NULL DEFAULT '0',
  `TitleStyle` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `LastInfo` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `GoodAssort` int(11) NOT NULL DEFAULT '0',
  `RootIDBak` bigint(20) NOT NULL DEFAULT '0',
  `VisitIP` varchar(15) CHARACTER SET ascii NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`),
  KEY `IX_AsphouseBBS_Announce_UserID` (`UserID`,`ParentID`) USING BTREE,
  KEY `IX_LeadBBS_Announce_1` (`GoodFlag`) USING BTREE,
  KEY `IX_LeadBBS_Announce_GoodAssort` (`GoodAssort`) USING BTREE,
  KEY `IX_LeadBBS_Announce_GoodFlag2` (`GoodFlag`,`BoardID`) USING BTREE,
  KEY `IX_LeadBBS_Announce_GoodFlag3` (`GoodFlag`,`UserID`) USING BTREE,
  KEY `IX_LeadBBS_Announce_IPAddress` (`IPAddress`) USING BTREE,
  KEY `IX_LeadBBS_Announce_lastTime` (`ParentID`,`BoardID`,`LastTime`) USING BTREE,
  KEY `IX_LeadBBS_Announce_ndatetime` (`BoardID`,`ndatetime`) USING BTREE,
  KEY `IX_LeadBBS_Announce_ndatetime2` (`ndatetime`) USING BTREE,
  KEY `IX_LeadBBS_Announce_ParentID` (`ParentID`,`BoardID`,`RootID`) USING BTREE,
  KEY `IX_LeadBBS_Announce_ParentID2` (`ParentID`,`BoardID`,`RootIDBak`) USING BTREE,
  KEY `IX_LeadBBS_Announce_RootIDBak` (`RootIDBak`) USING BTREE,
  KEY `IX_LeadBBS_Announce_RootIDBak2` (`ParentID`,`RootIDBak`) USING BTREE,
  KEY `IX_LeadBBS_Announce_TopicType` (`TopicType`,`NeedValue`) USING BTREE,
  KEY `IX_LeadBBS_Announce_UserID2` (`UserID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2260954 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_announce
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_applogin`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_applogin`;
CREATE TABLE `leadbbs_applogin` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `UserID` bigint(20) NOT NULL DEFAULT '0',
  `appid` varchar(64) CHARACTER SET ascii NOT NULL DEFAULT '',
  `GuestName` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `appType` int(11) NOT NULL DEFAULT '0',
  `ndatetime` bigint(20) NOT NULL DEFAULT '0',
  `IPAddress` varchar(50) CHARACTER SET ascii NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`),
  KEY `IX_LeadBBS_AppLogin_appid` (`appType`,`appid`) USING BTREE,
  KEY `IX_LeadBBS_AppLogin_UserID` (`appid`,`UserID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=226 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_applogin
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_assessor`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_assessor`;
CREATE TABLE `leadbbs_assessor` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `BoardID` bigint(20) NOT NULL DEFAULT '0',
  `Title` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `UserName` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `NDateTime` bigint(20) NOT NULL DEFAULT '0',
  `AnnounceID` bigint(20) NOT NULL DEFAULT '0',
  `Content` mediumtext CHARACTER SET utf8 NOT NULL,
  `HTMLFlag` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `TypeFlag` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IX_LeadBBS_Assessor_AnnounceID` (`AnnounceID`) USING BTREE,
  KEY `IX_LeadBBS_Assessor_BoardID` (`BoardID`) USING BTREE,
  KEY `IX_LeadBBS_Assessor_TypeFlag` (`TypeFlag`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=71030 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_assessor
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_assort`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_assort`;
CREATE TABLE `leadbbs_assort` (
  `AssortID` int(11) NOT NULL,
  `AssortName` varchar(250) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `AssortMaster` varchar(250) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `AssortLimit` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`AssortID`),
  KEY `IX_AsphouseBBS_Assort_AssortName` (`AssortName`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_assort
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_boards`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_boards`;
CREATE TABLE `leadbbs_boards` (
  `BoardID` int(11) NOT NULL,
  `BoardAssort` int(11) NOT NULL DEFAULT '0',
  `BoardName` varchar(250) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `BoardIntro` text CHARACTER SET utf8 NOT NULL,
  `LastWriter` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `LastWriteTime` bigint(20) NOT NULL DEFAULT '0',
  `TopicNum` bigint(20) NOT NULL DEFAULT '0',
  `AnnounceNum` bigint(20) NOT NULL DEFAULT '0',
  `ForumPass` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `HiddenFlag` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `LastAnnounceID` bigint(20) NOT NULL DEFAULT '0',
  `LastTopicName` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `MasterList` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `BoardLimit` int(11) NOT NULL DEFAULT '0',
  `AllMinRootID` bigint(20) unsigned NOT NULL DEFAULT '0',
  `AllMaxRootID` bigint(20) NOT NULL DEFAULT '0',
  `TodayAnnounce` bigint(20) NOT NULL DEFAULT '0',
  `GoodNum` bigint(20) NOT NULL DEFAULT '0',
  `OrderID` bigint(20) NOT NULL DEFAULT '0',
  `BoardStyle` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `StartTime` bigint(20) NOT NULL DEFAULT '0',
  `EndTime` bigint(20) NOT NULL DEFAULT '0',
  `BoardHead` mediumtext CHARACTER SET utf8 NOT NULL,
  `BoardBottom` mediumtext CHARACTER SET utf8 NOT NULL,
  `BoardImgUrl` varchar(255) NOT NULL DEFAULT '',
  `BoardImgWidth` int(11) NOT NULL DEFAULT '0',
  `BoardImgHeight` int(11) NOT NULL DEFAULT '0',
  `ParentBoard` int(11) NOT NULL DEFAULT '0',
  `LowerBoard` varchar(255) CHARACTER SET ascii NOT NULL DEFAULT '',
  `ParentBoardStr` varchar(100) CHARACTER SET ascii NOT NULL DEFAULT '',
  `BoardLevel` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `TopicNum_All` bigint(20) NOT NULL DEFAULT '0',
  `AnnounceNum_All` bigint(20) NOT NULL DEFAULT '0',
  `TodayAnnounce_All` bigint(20) NOT NULL DEFAULT '0',
  `GoodNum_All` bigint(20) NOT NULL DEFAULT '0',
  `OtherLimit` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`BoardID`),
  KEY `IX_AsphouseBBS_Boards` (`ParentBoard`,`HiddenFlag`,`BoardAssort`,`OrderID`) USING BTREE,
  KEY `IX_AsphouseBBS_Boards_BoardAssort` (`BoardAssort`,`OrderID`) USING BTREE,
  KEY `IX_AsphouseBBS_Boards_BoardName` (`BoardName`) USING BTREE,
  KEY `IX_AsphouseBBS_Boards2` (`HiddenFlag`,`BoardAssort`,`OrderID`) USING BTREE,
  KEY `IX_LeadBBS_Boards_HiddenFlag` (`HiddenFlag`) USING BTREE,
  KEY `IX_LeadBBS_Boards_ParentBoard` (`ParentBoard`) USING BTREE,
  FULLTEXT KEY `BoardName` (`BoardName`),
  FULLTEXT KEY `BoardName_2` (`BoardName`),
  FULLTEXT KEY `BoardName_3` (`BoardName`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_boards
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_collectanc`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_collectanc`;
CREATE TABLE `leadbbs_collectanc` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `AnnounceID` bigint(20) NOT NULL DEFAULT '0',
  `UserID` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IX_LeadBBS_CollectAnc` (`AnnounceID`,`UserID`) USING BTREE,
  KEY `IX_LeadBBS_CollectAnc_UserID` (`UserID`,`ID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=40390 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_collectanc
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_download`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_download`;
CREATE TABLE `leadbbs_download` (
  `ID` bigint(20) NOT NULL,
  `DownName` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `DownCount` bigint(20) NOT NULL DEFAULT '0',
  `FileUrl` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `LastIP` varchar(15) CHARACTER SET ascii NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `IX_LeadBBS_Download_DownName` (`DownName`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_download
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_forbidip`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_forbidip`;
CREATE TABLE `leadbbs_forbidip` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `IPStart` bigint(20) NOT NULL DEFAULT '0',
  `IPEnd` bigint(20) NOT NULL DEFAULT '0',
  `IPNumber` bigint(20) NOT NULL DEFAULT '0',
  `ExpiresTime` bigint(20) NOT NULL DEFAULT '0',
  `WhyString` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`),
  KEY `IX_LeadBBS_ForbidIP` (`IPEnd`,`IPStart`) USING BTREE,
  KEY `IX_LeadBBS_ForbidIP_1` (`IPStart`) USING BTREE,
  KEY `IX_LeadBBS_ForbidIP_2` (`IPEnd`) USING BTREE,
  KEY `IX_LeadBBS_ForbidIP_ExpiresTime` (`ExpiresTime`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_forbidip
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_frienduser`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_frienduser`;
CREATE TABLE `leadbbs_frienduser` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `UserID` bigint(20) NOT NULL DEFAULT '0',
  `FriendUserID` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IX_LeadBBS_FriendUser_FriendUserID` (`FriendUserID`,`UserID`) USING BTREE,
  KEY `PK_LeadBBS_FriendUser_UserID` (`UserID`,`ID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11706 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_frienduser
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_goodassort`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_goodassort`;
CREATE TABLE `leadbbs_goodassort` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `OrderID` bigint(20) NOT NULL DEFAULT '0',
  `BoardID` int(11) NOT NULL DEFAULT '0',
  `AssortName` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `GoodNum` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IX_LeadBBS_GoodAssort_BoardID` (`BoardID`,`OrderID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_goodassort
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_infobox`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_infobox`;
CREATE TABLE `leadbbs_infobox` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `FromUser` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `ToUser` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `Title` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `Content` mediumtext CHARACTER SET utf8 NOT NULL,
  `IP` varchar(15) CHARACTER SET ascii NOT NULL DEFAULT '',
  `SendTime` bigint(20) NOT NULL DEFAULT '0',
  `ReadFlag` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `ExpiresDate` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IX_Asphouse_InfoBox_FromUser` (`FromUser`,`ID`) USING BTREE,
  KEY `IX_Asphouse_InfoBox_ToUser` (`ToUser`,`ID`) USING BTREE,
  KEY `IX_LeadBBS_InfoBox_ExpiresDate` (`ExpiresDate`) USING BTREE,
  KEY `IX_LeadBBS_InfoBox_ReadFlag` (`ReadFlag`,`FromUser`,`ID`) USING BTREE,
  KEY `IX_LeadBBS_InfoBox_ReadFlag1` (`ReadFlag`,`ToUser`,`ID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=253749 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_infobox
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_ipaddress`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_ipaddress`;
CREATE TABLE `leadbbs_ipaddress` (
  `ip1` bigint(20) NOT NULL DEFAULT '0',
  `ip2` bigint(20) NOT NULL DEFAULT '0',
  `country` varchar(13) CHARACTER SET utf8 DEFAULT '',
  `city` varchar(47) CHARACTER SET utf8 DEFAULT '',
  KEY `IX_LeadBBS_IPAddress` (`ip1`,`ip2`) USING BTREE,
  KEY `IX_LeadBBS_IPAddress_1` (`ip2`,`ip1`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_ipaddress
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_link`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_link`;
CREATE TABLE `leadbbs_link` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `SiteName` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `SiteUrl` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `LogoUrl` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `OrderID` bigint(20) NOT NULL DEFAULT '0',
  `LogoWidth` int(11) NOT NULL DEFAULT '0',
  `LogoHeight` int(11) NOT NULL DEFAULT '0',
  `BreakFlag` tinyint(1) NOT NULL DEFAULT '0',
  `LinkType` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IX_LeadBBS_Link` (`LinkType`,`OrderID`,`ID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=743 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_link
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_log`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_log`;
CREATE TABLE `leadbbs_log` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `LogType` int(11) NOT NULL DEFAULT '0',
  `LogTime` bigint(20) NOT NULL DEFAULT '0',
  `LogInfo` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `UserName` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `IP` varchar(15) CHARACTER SET ascii NOT NULL DEFAULT '',
  `BoardID` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IX_LeadBBS_Log_BoardID` (`BoardID`) USING BTREE,
  KEY `IX_LeadBBS_Log_LogTime` (`LogTime`) USING BTREE,
  KEY `IX_LeadBBS_Log_LogType` (`LogType`) USING BTREE,
  KEY `IX_LeadBBS_Log_UserName` (`UserName`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=184542 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_log
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_onlineuser`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_onlineuser`;
CREATE TABLE `leadbbs_onlineuser` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `SessionID` bigint(20) NOT NULL DEFAULT '0',
  `UserID` bigint(20) NOT NULL DEFAULT '0',
  `LastDoingTime` bigint(20) NOT NULL DEFAULT '0',
  `IP` varchar(15) CHARACTER SET ascii NOT NULL DEFAULT '',
  `StartTime` bigint(20) NOT NULL DEFAULT '0',
  `AtBoardID` int(11) NOT NULL DEFAULT '0',
  `AtUrl` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `AtInfo` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `LastRndNumber` int(11) NOT NULL DEFAULT '0',
  `Browser` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `System` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `UserName` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `HiddenFlag` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IX_asphouse_onlineUser_AtBoardID` (`AtBoardID`,`UserID`,`ID`) USING BTREE,
  KEY `IX_asphouse_onlineUser_LastDoingTime` (`LastDoingTime`) USING BTREE,
  KEY `IX_asphouse_onlineUser_SessionID` (`SessionID`) USING BTREE,
  KEY `IX_asphouse_onlineUser_UserID` (`UserID`,`SessionID`) USING BTREE,
  KEY `IX_LeadBBS_onlineUser_IP` (`IP`,`UserID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2360893 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_onlineuser
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_opinion`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_opinion`;
CREATE TABLE `leadbbs_opinion` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `UserName` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `AnnounceID` bigint(20) NOT NULL DEFAULT '0',
  `Num` int(11) NOT NULL DEFAULT '0',
  `NumType` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `Opinion` varchar(24) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `IP` varchar(15) CHARACTER SET ascii NOT NULL DEFAULT '',
  `Ndatetime` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IX_LeadBBS_Opinion_AnnounceID` (`AnnounceID`,`ID`) USING BTREE,
  KEY `IX_LeadBBS_Opinion_AnnounceID2` (`AnnounceID`,`UserName`,`ID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=782 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_opinion
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_plug_card`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_plug_card`;
CREATE TABLE `leadbbs_plug_card` (
  `ID` bigint(20) DEFAULT NULL,
  `CardID` bigint(20) DEFAULT NULL,
  `CardType` int(11) DEFAULT NULL,
  `ExpiresDate` int(11) DEFAULT NULL,
  `CardPoints` int(11) DEFAULT NULL,
  KEY `CardType` (`CardType`,`CardPoints`) USING BTREE,
  KEY `CardType_2` (`CardType`) USING BTREE,
  KEY `ExpiresDate` (`ExpiresDate`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_plug_card
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_selllist`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_selllist`;
CREATE TABLE `leadbbs_selllist` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `PID` bigint(20) NOT NULL DEFAULT '0',
  `UserName` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `PayPoints` int(11) NOT NULL DEFAULT '0',
  `GetPoints` int(11) NOT NULL DEFAULT '0',
  `SellTime` bigint(20) NOT NULL DEFAULT '0',
  `PayFlag` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IX_LeadBBS_SellList_PayFlag` (`PayFlag`) USING BTREE,
  KEY `IX_LeadBBS_SellList_PID` (`PID`) USING BTREE,
  KEY `IX_LeadBBS_SellList_SellTime` (`SellTime`) USING BTREE,
  KEY `IX_LeadBBS_SellList_UserName` (`UserName`) USING BTREE,
  KEY `IX_LeadBBS_SellList_UserNamePayFlag` (`UserName`,`PayFlag`,`ID`) USING BTREE,
  KEY `IX_LeadBBS_SellList_UserSellTime` (`UserName`,`PayFlag`,`SellTime`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=679 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_selllist
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_setup`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_setup`;
CREATE TABLE `leadbbs_setup` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `RID` int(11) NOT NULL DEFAULT '0',
  `ValueStr` text CHARACTER SET utf8,
  `ClassNum` int(11) NOT NULL DEFAULT '0',
  `saveData` mediumtext CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `IX_LeadBBS_Setup_ClassNum` (`ClassNum`) USING BTREE,
  KEY `IX_LeadBBS_Setup_RID` (`RID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_setup
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_siteinfo`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_siteinfo`;
CREATE TABLE `leadbbs_siteinfo` (
  `OnlineTime` bigint(20) NOT NULL DEFAULT '0',
  `PageCount` bigint(20) NOT NULL DEFAULT '0',
  `UserCount` bigint(20) NOT NULL DEFAULT '0',
  `MaxOnline` bigint(20) NOT NULL DEFAULT '0',
  `MaxolTime` bigint(20) NOT NULL DEFAULT '0',
  `UploadNum` bigint(20) NOT NULL DEFAULT '0',
  `MaxAnnounce` bigint(20) NOT NULL DEFAULT '0',
  `MaxAncTime` bigint(20) NOT NULL DEFAULT '0',
  `YesterdayAnc` bigint(20) NOT NULL DEFAULT '0',
  `YesterDay` bigint(20) NOT NULL DEFAULT '0',
  `SavePoints` bigint(20) NOT NULL DEFAULT '0',
  `DBWrite` bigint(20) NOT NULL DEFAULT '0',
  `DBNum` bigint(20) NOT NULL DEFAULT '0',
  `Version` varchar(20) CHARACTER SET ascii NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_siteinfo
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_skin`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_skin`;
CREATE TABLE `leadbbs_skin` (
  `StyleID` bigint(20) NOT NULL DEFAULT '0',
  `ScreenWidth` varchar(255) CHARACTER SET utf8 DEFAULT '770',
  `DisplayTopicLength` int(11) NOT NULL DEFAULT '56',
  `DefineImage` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `SiteHeadString` text CHARACTER SET utf8 NOT NULL,
  `SiteBottomString` text CHARACTER SET utf8 NOT NULL,
  `TableHeadString` text CHARACTER SET utf8 NOT NULL,
  `TableBottomString` text CHARACTER SET utf8 NOT NULL,
  `ShowBottomSure` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `SmallTableHead` text CHARACTER SET utf8 NOT NULL,
  `SmallTableBottom` text CHARACTER SET utf8 NOT NULL,
  `TempletID` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`StyleID`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_skin
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_specialuser`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_specialuser`;
CREATE TABLE `leadbbs_specialuser` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `UserID` bigint(20) NOT NULL DEFAULT '0',
  `UserName` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `BoardID` bigint(20) NOT NULL DEFAULT '0',
  `Assort` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `ndatetime` bigint(20) NOT NULL DEFAULT '0',
  `ExpiresTime` bigint(20) NOT NULL DEFAULT '0',
  `WhyString` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  PRIMARY KEY (`ID`),
  KEY `IX_LeadBBS_BoardMaster_BoardID` (`BoardID`) USING BTREE,
  KEY `IX_LeadBBS_BoardMaster_UserID` (`Assort`,`UserID`,`BoardID`) USING BTREE,
  KEY `IX_LeadBBS_SpecialUser` (`Assort`,`ID`) USING BTREE,
  KEY `IX_LeadBBS_SpecialUser_ExpiresTime` (`ExpiresTime`) USING BTREE,
  KEY `IX_LeadBBS_SpecialUser_UserName` (`UserName`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=20994 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_specialuser
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_templet`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_templet`;
CREATE TABLE `leadbbs_templet` (
  `ID` int(11) NOT NULL DEFAULT '0',
  `TempletName` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `TempletFlag` bigint(20) NOT NULL DEFAULT '0',
  `TempletString0` text CHARACTER SET utf8 NOT NULL,
  `TempletString1` text CHARACTER SET utf8 NOT NULL,
  `TempletString2` text CHARACTER SET utf8 NOT NULL,
  `TempletString3` text CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_templet
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_tmp`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_tmp`;
CREATE TABLE `leadbbs_tmp` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `tmpstr` text CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_tmp
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_topannounce`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_topannounce`;
CREATE TABLE `leadbbs_topannounce` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `RootID` bigint(20) NOT NULL DEFAULT '0',
  `BoardID` int(11) NOT NULL DEFAULT '0',
  `TopType` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IX_AsphouseBBS_TopAnnounce` (`BoardID`) USING BTREE,
  KEY `IX_LeadBBS_TopAnnounce_TopType` (`TopType`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=572 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_topannounce
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_upload`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_upload`;
CREATE TABLE `leadbbs_upload` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `UserID` bigint(20) NOT NULL DEFAULT '0',
  `PhotoDir` varchar(100) CHARACTER SET ascii NOT NULL DEFAULT '',
  `SPhotoDir` varchar(100) CHARACTER SET ascii NOT NULL DEFAULT '',
  `NdateTime` bigint(20) NOT NULL DEFAULT '0',
  `FileType` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `FileName` varchar(50) NOT NULL DEFAULT '',
  `FileSize` int(11) NOT NULL DEFAULT '0',
  `AnnounceID` bigint(20) NOT NULL DEFAULT '0',
  `BoardID` bigint(20) NOT NULL DEFAULT '0',
  `Info` varchar(30) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `VisitIP` varchar(50) CHARACTER SET ascii NOT NULL DEFAULT '',
  `Hits` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IX_LeadBBS_Upload_AnnounceID` (`AnnounceID`) USING BTREE,
  KEY `IX_LeadBBS_Upload_BoardID` (`BoardID`) USING BTREE,
  KEY `IX_LeadBBS_Upload_FileType` (`FileType`,`ID`) USING BTREE,
  KEY `IX_LeadBBS_Upload_FileType2` (`FileType`,`AnnounceID`,`ID`) USING BTREE,
  KEY `IX_LeadBBS_Upload_NdateTime` (`NdateTime`) USING BTREE,
  KEY `IX_LeadBBS_Upload_UserID` (`UserID`,`ID`) USING BTREE,
  KEY `IX_LeadBBS_Upload_UserIDFileType` (`UserID`,`FileType`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=14526 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_upload
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_user`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_user`;
CREATE TABLE `leadbbs_user` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `UserName` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `Pass` varchar(32) CHARACTER SET ascii NOT NULL DEFAULT '',
  `Mail` varchar(60) CHARACTER SET utf8 DEFAULT '',
  `Address` varchar(150) CHARACTER SET utf8 DEFAULT '',
  `Sex` varchar(2) CHARACTER SET utf8 DEFAULT '',
  `Birthday` bigint(20) DEFAULT '0',
  `ApplyTime` bigint(20) NOT NULL DEFAULT '0',
  `ICQ` bigint(20) DEFAULT '0',
  `OICQ` bigint(20) DEFAULT '0',
  `Sessionid` bigint(20) NOT NULL DEFAULT '0',
  `Online` int(11) DEFAULT '0',
  `Prevtime` bigint(20) NOT NULL DEFAULT '0',
  `Userphoto` int(11) DEFAULT '1',
  `IP` varchar(15) CHARACTER SET ascii NOT NULL DEFAULT '',
  `UserLevel` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `Homepage` varchar(160) CHARACTER SET utf8 DEFAULT '',
  `Underwrite` varchar(255) CHARACTER SET utf8 DEFAULT '',
  `PrintUnderWrite` text CHARACTER SET utf8,
  `Points` bigint(20) NOT NULL DEFAULT '0',
  `Officer` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `Login_ip` varchar(15) CHARACTER SET ascii DEFAULT '',
  `Login_oknum` bigint(20) NOT NULL DEFAULT '0',
  `Login_falsenum` bigint(20) NOT NULL DEFAULT '0',
  `Login_lastpass` varchar(32) CHARACTER SET ascii DEFAULT '',
  `Login_RightIP` varchar(15) CHARACTER SET ascii DEFAULT '',
  `OnlineTime` bigint(20) NOT NULL DEFAULT '0',
  `AnnounceNum` bigint(20) NOT NULL DEFAULT '0',
  `LastDoingTime` bigint(20) NOT NULL DEFAULT '0',
  `FaceUrl` varchar(250) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `FaceWidth` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `FaceHeight` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `UserLimit` bigint(20) NOT NULL DEFAULT '0',
  `ShowFlag` tinyint(1) NOT NULL DEFAULT '0',
  `MessageFlag` tinyint(1) NOT NULL DEFAULT '0',
  `NongLiBirth` bigint(20) NOT NULL DEFAULT '0',
  `AnnounceTopic` bigint(20) NOT NULL DEFAULT '0',
  `AnnounceGood` bigint(20) NOT NULL DEFAULT '0',
  `UploadNum` bigint(20) NOT NULL DEFAULT '0',
  `CharmPoint` bigint(20) NOT NULL DEFAULT '0',
  `CachetValue` bigint(20) NOT NULL DEFAULT '0',
  `UserTitle` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `NotSecret` tinyint(1) NOT NULL DEFAULT '0',
  `Question` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `Answer` varchar(32) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `LockIP` varchar(15) CHARACTER SET ascii NOT NULL DEFAULT '',
  `LastWriteTime` bigint(20) NOT NULL DEFAULT '0',
  `ExtendFlag` bigint(20) NOT NULL DEFAULT '0',
  `IDCard` bigint(20) NOT NULL DEFAULT '0',
  `MobileTel` bigint(20) NOT NULL DEFAULT '0',
  `Telephone` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `TrueName` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `LastAnnounceID` bigint(20) NOT NULL DEFAULT '0',
  `AnnounceNum2` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `IX_asphouse_User_username` (`UserName`,`ID`) USING BTREE,
  KEY `IX_asphouse_Points` (`Points`,`ID`) USING BTREE,
  KEY `IX_LeadBBS_User_AnnounceNum` (`AnnounceNum`) USING BTREE,
  KEY `IX_LeadBBS_User_LastDoingTime` (`LastDoingTime`,`ID`) USING BTREE,
  KEY `IX_LeadBBS_User_Mail` (`Mail`) USING BTREE,
  KEY `IX_LeadBBS_User_OnlineTime` (`OnlineTime`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=199080 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_user
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_userface`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_userface`;
CREATE TABLE `leadbbs_userface` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `UserID` bigint(20) NOT NULL DEFAULT '0',
  `PhotoDir` varchar(100) CHARACTER SET ascii NOT NULL DEFAULT '',
  `SPhotoDir` varchar(100) CHARACTER SET ascii NOT NULL DEFAULT '',
  `NdateTime` bigint(20) NOT NULL DEFAULT '0',
  `FileType` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IX_LeadBBS_UserFace_UserID` (`UserID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2962 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_userface
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_voteitem`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_voteitem`;
CREATE TABLE `leadbbs_voteitem` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `AnnounceID` bigint(20) NOT NULL DEFAULT '0',
  `VoteType` tinyint(1) NOT NULL DEFAULT '0',
  `VoteName` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `ExpiresTime` bigint(20) NOT NULL DEFAULT '0',
  `VoteNum` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IX_AsphouseBBS_VoteItem_AnnounceID` (`AnnounceID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6674 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_voteitem
-- ----------------------------

-- ----------------------------
-- Table structure for `leadbbs_voteuser`
-- ----------------------------
DROP TABLE IF EXISTS `leadbbs_voteuser`;
CREATE TABLE `leadbbs_voteuser` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `UserName` varchar(20) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `VoteItem` varchar(255) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `AnnounceID` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `IX_LeadBBS_VoteUser_AnnounceID` (`AnnounceID`) USING BTREE,
  KEY `IX_LeadBBS_VoteUser_UserName` (`AnnounceID`,`UserName`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=68882 DEFAULT CHARSET=gbk ROW_FORMAT=COMPACT;

-- ----------------------------
-- Records of leadbbs_voteuser
-- ----------------------------
INSERT INTO `leadbbs_assort` VALUES ('100', 'Default', '', '0') ON DUPLICATE KEY update assortname=assortname;
INSERT INTO `leadbbs_boards` VALUES ('100', '100', 'Default Forum', '', '', '20130319023854', '0', '0', '', '0', '0', '', '', '0', '0', '0', '0', '0', '0', '0', '0', '0', '', '', '', '0', '0', '0', '', '100', '1', '0', '0', '0', '0', '0') ON DUPLICATE KEY update boardid=boardid;
INSERT INTO `leadbbs_boards` VALUES ('444', '100', 'Recycle', '', '', '20130319024028', '0', '0', '', '0', '0', '', '', '92', '0', '0', '0', '0', '0', '0', '0', '0', '', '', '', '0', '0', '0', '', '444', '1', '0', '0', '0', '0', '0') ON DUPLICATE KEY update boardid=boardid;
INSERT INTO `leadbbs_skin` VALUES ('1000', 'style1000', '66', '0', '', '', '', '', '1', '', 'abc', '0') ON DUPLICATE KEY update StyleID=StyleID;
INSERT INTO `leadbbs_skin` VALUES ('1001', 'LeadBBS 7.0', '80', '0', '', '', '', '', '1', '', 'abc', '0') ON DUPLICATE KEY update StyleID=StyleID;
INSERT INTO `leadbbs_setup` VALUES ('72', '1002', '20130314002', '0', 'ÄÚ²¿°æ±¾ºÅ') ON DUPLICATE KEY update valuestr='20130314001';