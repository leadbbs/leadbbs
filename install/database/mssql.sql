
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_VoteUser]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_VoteUser](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](20) NOT NULL,
	[VoteItem] [varchar](255) NOT NULL,
	[AnnounceID] [bigint] NOT NULL,
 CONSTRAINT [PK_AsphouseBBS_VoteUser] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_VoteUser]') AND name = N'IX_LeadBBS_VoteUser_AnnounceID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_VoteUser_AnnounceID] ON [dbo].[LeadBBS_VoteUser] 
(
	[AnnounceID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_VoteUser]') AND name = N'IX_LeadBBS_VoteUser_UserName')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_VoteUser_UserName] ON [dbo].[LeadBBS_VoteUser] 
(
	[AnnounceID] ASC,
	[UserName] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_VoteItem]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_VoteItem](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[AnnounceID] [bigint] NOT NULL,
	[VoteType] [bit] NOT NULL,
	[VoteName] [nvarchar](50) NOT NULL,
	[ExpiresTime] [bigint] NOT NULL,
	[VoteNum] [bigint] NOT NULL,
 CONSTRAINT [PK_AsphouseBBS_VoteItem] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_VoteItem]') AND name = N'IX_AsphouseBBS_VoteItem_AnnounceID')
CREATE NONCLUSTERED INDEX [IX_AsphouseBBS_VoteItem_AnnounceID] ON [dbo].[LeadBBS_VoteItem] 
(
	[AnnounceID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_UserFace]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_UserFace](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [bigint] NOT NULL,
	[PhotoDir] [varchar](100) NOT NULL,
	[SPhotoDir] [varchar](100) NOT NULL,
	[NdateTime] [bigint] NOT NULL,
	[FileType] [tinyint] NOT NULL,
 CONSTRAINT [PK_LeadBBS_UserFace] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_UserFace]') AND name = N'IX_LeadBBS_UserFace_UserID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_UserFace_UserID] ON [dbo].[LeadBBS_UserFace] 
(
	[UserID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_User]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_User](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](20) NOT NULL,
	[Pass] [varchar](32) NOT NULL,
	[Mail] [varchar](60) NULL,
	[Address] [varchar](150) NULL,
	[Sex] [nvarchar](1) NULL,
	[Birthday] [bigint] NULL,
	[ApplyTime] [bigint] NOT NULL,
	[ICQ] [bigint] NULL,
	[OICQ] [bigint] NULL,
	[Sessionid] [bigint] NOT NULL,
	[Online] [int] NULL,
	[Prevtime] [bigint] NOT NULL,
	[Userphoto] [int] NULL,
	[IP] [varchar](15) NOT NULL,
	[UserLevel] [tinyint] NOT NULL,
	[Homepage] [varchar](160) NULL,
	[Underwrite] [varchar](255) NULL,
	[PrintUnderWrite] [varchar](1024) NULL,
	[Points] [bigint] NOT NULL,
	[Officer] [varchar](255) NOT NULL,
	[Login_ip] [varchar](15) NULL,
	[Login_oknum] [bigint] NOT NULL,
	[Login_falsenum] [bigint] NOT NULL,
	[Login_lastpass] [varchar](32) NULL,
	[Login_RightIP] [varchar](15) NULL,
	[OnlineTime] [bigint] NOT NULL,
	[AnnounceNum] [bigint] NOT NULL,
	[LastDoingTime] [bigint] NOT NULL,
	[FaceUrl] [varchar](250) NOT NULL,
	[FaceWidth] [tinyint] NOT NULL,
	[FaceHeight] [tinyint] NOT NULL,
	[UserLimit] [bigint] NOT NULL,
	[ShowFlag] [bit] NOT NULL,
	[MessageFlag] [bit] NOT NULL,
	[NongLiBirth] [bigint] NOT NULL,
	[AnnounceTopic] [bigint] NOT NULL,
	[AnnounceGood] [bigint] NOT NULL,
	[UploadNum] [bigint] NOT NULL,
	[CharmPoint] [bigint] NOT NULL,
	[CachetValue] [bigint] NOT NULL,
	[UserTitle] [varchar](20) NOT NULL,
	[NotSecret] [bit] NOT NULL,
	[Question] [varchar](20) NOT NULL,
	[Answer] [varchar](32) NOT NULL,
	[LockIP] [varchar](15) NOT NULL,
	[LastWriteTime] [bigint] NOT NULL,
	[ExtendFlag] [bigint] NOT NULL,
	[IDCard] [bigint] NOT NULL,
	[MobileTel] [bigint] NOT NULL,
	[Telephone] [varchar](20) NOT NULL,
	[TrueName] [varchar](50) NOT NULL,
	[LastAnnounceID] [bigint] NOT NULL,
	[AnnounceNum2] [bigint] NOT NULL,
	[remark] [text] NOT NULL,
 CONSTRAINT [PK_LeadBBS_User] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY],
 CONSTRAINT [IX_asphouse_User_username] UNIQUE NONCLUSTERED 
(
	[UserName] ASC,
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_User]') AND name = N'IX_asphouse_Points')
CREATE NONCLUSTERED INDEX [IX_asphouse_Points] ON [dbo].[LeadBBS_User] 
(
	[Points] DESC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_User]') AND name = N'IX_LeadBBS_User_AnnounceNum')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_User_AnnounceNum] ON [dbo].[LeadBBS_User] 
(
	[AnnounceNum] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_User]') AND name = N'IX_LeadBBS_User_LastDoingTime')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_User_LastDoingTime] ON [dbo].[LeadBBS_User] 
(
	[LastDoingTime] DESC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_User]') AND name = N'IX_LeadBBS_User_Mail')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_User_Mail] ON [dbo].[LeadBBS_User] 
(
	[Mail] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_User]') AND name = N'IX_LeadBBS_User_MobileTel')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_User_MobileTel] ON [dbo].[LeadBBS_User] 
(
	[MobileTel] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_User]') AND name = N'IX_LeadBBS_User_OnlineTime')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_User_OnlineTime] ON [dbo].[LeadBBS_User] 
(
	[OnlineTime] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_User]') AND name = N'IX_LeadBBS_User_Truename')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_User_Truename] ON [dbo].[LeadBBS_User] 
(
	[TrueName] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Upload]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Upload](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [bigint] NOT NULL,
	[PhotoDir] [varchar](100) NOT NULL,
	[SPhotoDir] [varchar](100) NOT NULL,
	[NdateTime] [bigint] NOT NULL,
	[FileType] [tinyint] NOT NULL,
	[FileName] [varchar](50) NOT NULL,
	[FileSize] [int] NOT NULL,
	[AnnounceID] [bigint] NOT NULL,
	[BoardID] [bigint] NOT NULL,
	[Info] [nvarchar](30) NOT NULL,
	[VisitIP] [varchar](50) NOT NULL,
	[Hits] [bigint] NOT NULL,
 CONSTRAINT [PK_LeadBBS_Upload] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Upload]') AND name = N'IX_LeadBBS_Upload_AnnounceID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Upload_AnnounceID] ON [dbo].[LeadBBS_Upload] 
(
	[AnnounceID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Upload]') AND name = N'IX_LeadBBS_Upload_BoardID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Upload_BoardID] ON [dbo].[LeadBBS_Upload] 
(
	[BoardID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Upload]') AND name = N'IX_LeadBBS_Upload_FileType')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Upload_FileType] ON [dbo].[LeadBBS_Upload] 
(
	[FileType] ASC,
	[ID] DESC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Upload]') AND name = N'IX_LeadBBS_Upload_FileType2')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Upload_FileType2] ON [dbo].[LeadBBS_Upload] 
(
	[FileType] ASC,
	[AnnounceID] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Upload]') AND name = N'IX_LeadBBS_Upload_NdateTime')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Upload_NdateTime] ON [dbo].[LeadBBS_Upload] 
(
	[NdateTime] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Upload]') AND name = N'IX_LeadBBS_Upload_UserID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Upload_UserID] ON [dbo].[LeadBBS_Upload] 
(
	[UserID] ASC,
	[ID] DESC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Upload]') AND name = N'IX_LeadBBS_Upload_UserIDFileType')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Upload_UserIDFileType] ON [dbo].[LeadBBS_Upload] 
(
	[UserID] ASC,
	[FileType] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_TopAnnounce]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_TopAnnounce](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[RootID] [bigint] NOT NULL,
	[BoardID] [int] NOT NULL,
	[TopType] [bigint] NOT NULL,
 CONSTRAINT [PK_AsphouseBBS_TopAnnounce] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_TopAnnounce]') AND name = N'IX_AsphouseBBS_TopAnnounce')
CREATE NONCLUSTERED INDEX [IX_AsphouseBBS_TopAnnounce] ON [dbo].[LeadBBS_TopAnnounce] 
(
	[BoardID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_TopAnnounce]') AND name = N'IX_LeadBBS_TopAnnounce_TopType')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_TopAnnounce_TopType] ON [dbo].[LeadBBS_TopAnnounce] 
(
	[TopType] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Tmp]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Tmp](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[tmpstr] [nvarchar](1024) NOT NULL,
 CONSTRAINT [PK_LeadBBS_Tmp] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Templet]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Templet](
	[ID] [int] NOT NULL,
	[TempletName] [nvarchar](50) NOT NULL,
	[TempletFlag] [bigint] NOT NULL,
	[TempletString0] [text] NOT NULL,
	[TempletString1] [text] NOT NULL,
	[TempletString2] [text] NOT NULL,
	[TempletString3] [text] NOT NULL,
 CONSTRAINT [PK_LeadBBS_Templet] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_SpecialUser]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_SpecialUser](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [bigint] NOT NULL,
	[UserName] [varchar](60) NOT NULL,
	[BoardID] [bigint] NOT NULL,
	[Assort] [tinyint] NOT NULL,
	[ndatetime] [bigint] NOT NULL,
	[ExpiresTime] [bigint] NOT NULL,
	[WhyString] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_LeadBBS_BoardMaster] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_SpecialUser]') AND name = N'IX_LeadBBS_BoardMaster_BoardID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_BoardMaster_BoardID] ON [dbo].[LeadBBS_SpecialUser] 
(
	[BoardID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_SpecialUser]') AND name = N'IX_LeadBBS_BoardMaster_UserID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_BoardMaster_UserID] ON [dbo].[LeadBBS_SpecialUser] 
(
	[Assort] ASC,
	[UserID] ASC,
	[BoardID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_SpecialUser]') AND name = N'IX_LeadBBS_SpecialUser')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_SpecialUser] ON [dbo].[LeadBBS_SpecialUser] 
(
	[Assort] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_SpecialUser]') AND name = N'IX_LeadBBS_SpecialUser_ExpiresTime')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_SpecialUser_ExpiresTime] ON [dbo].[LeadBBS_SpecialUser] 
(
	[ExpiresTime] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_SpecialUser]') AND name = N'IX_LeadBBS_SpecialUser_UserName')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_SpecialUser_UserName] ON [dbo].[LeadBBS_SpecialUser] 
(
	[UserName] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Skin]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Skin](
	[StyleID] [bigint] NOT NULL,
	[ScreenWidth] [varchar](255) NOT NULL,
	[DisplayTopicLength] [int] NOT NULL,
	[DefineImage] [tinyint] NOT NULL,
	[SiteHeadString] [text] NOT NULL,
	[SiteBottomString] [text] NOT NULL,
	[TableHeadString] [text] NOT NULL,
	[TableBottomString] [text] NOT NULL,
	[ShowBottomSure] [tinyint] NOT NULL,
	[SmallTableHead] [text] NOT NULL,
	[SmallTableBottom] [text] NOT NULL,
	[TempletID] [int] NOT NULL,
 CONSTRAINT [PK_LeadBBS_Skin] PRIMARY KEY CLUSTERED 
(
	[StyleID] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_SiteInfo]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_SiteInfo](
	[OnlineTime] [bigint] NOT NULL,
	[PageCount] [bigint] NOT NULL,
	[UserCount] [bigint] NOT NULL,
	[MaxOnline] [bigint] NOT NULL,
	[MaxolTime] [bigint] NOT NULL,
	[UploadNum] [bigint] NOT NULL,
	[MaxAnnounce] [bigint] NOT NULL,
	[MaxAncTime] [bigint] NOT NULL,
	[YesterdayAnc] [bigint] NOT NULL,
	[YesterDay] [bigint] NOT NULL,
	[SavePoints] [bigint] NOT NULL,
	[DBWrite] [bigint] NOT NULL,
	[DBNum] [bigint] NOT NULL,
	[Version] [varchar](20) NOT NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Setup]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Setup](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[RID] [int] NOT NULL,
	[ValueStr] [text] NULL,
	[ClassNum] [int] NOT NULL,
	[saveData] [text] NOT NULL,
 CONSTRAINT [PK_LeadBBS_Setup] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Setup]') AND name = N'IX_LeadBBS_Setup_ClassNum')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Setup_ClassNum] ON [dbo].[LeadBBS_Setup] 
(
	[ClassNum] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Setup]') AND name = N'IX_LeadBBS_Setup_RID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Setup_RID] ON [dbo].[LeadBBS_Setup] 
(
	[RID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Plugs]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Plugs](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[ClassID] [int] NOT NULL,
	[url] [varchar](255) NOT NULL,
	[width] [int] NOT NULL,
	[height] [int] NOT NULL,
	[intro] [text] NOT NULL,
	[sortid] [bigint] NOT NULL,
	[plugkey] [varchar](128) NOT NULL,
	[createtime] [bigint] NOT NULL,
	[remark] [ntext] NOT NULL,
 CONSTRAINT [PK_LeadBBS_Plugs] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Plugs]') AND name = N'IX_LeadBBS_Plugs_ClassID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Plugs_ClassID] ON [dbo].[LeadBBS_Plugs] 
(
	[ClassID] ASC,
	[sortid] ASC,
	[ID] DESC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Plugs]') AND name = N'IX_LeadBBS_Plugs_plugkey')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Plugs_plugkey] ON [dbo].[LeadBBS_Plugs] 
(
	[plugkey] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_plug_class]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_plug_class](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NULL,
	[ParentID] [bigint] NOT NULL,
	[Num] [int] NOT NULL,
	[remark] [ntext] NOT NULL,
	[sortid] [int] NOT NULL,
 CONSTRAINT [PK_LeadBBS_plug_class] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_plug_class]') AND name = N'IX_LeadBBS_plug_class_ParentID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_plug_class_ParentID] ON [dbo].[LeadBBS_plug_class] 
(
	[ParentID] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_plug_class]') AND name = N'IX_LeadBBS_plug_class_sortid')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_plug_class_sortid] ON [dbo].[LeadBBS_plug_class] 
(
	[sortid] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Plug_Card]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Plug_Card](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CardID] [bigint] NOT NULL,
	[CardType] [tinyint] NOT NULL,
	[ExpiresDate] [int] NOT NULL,
	[CardPoints] [int] NOT NULL,
 CONSTRAINT [PK_LeadBBS_plug_Card_CardID] PRIMARY KEY CLUSTERED 
(
	[CardID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Plug_Card]') AND name = N'IX_LeadBBS_Plug_Card_CardPoints')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Plug_Card_CardPoints] ON [dbo].[LeadBBS_Plug_Card] 
(
	[CardType] ASC,
	[CardPoints] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Plug_Card]') AND name = N'IX_LeadBBS_Plug_Card_CardType')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Plug_Card_CardType] ON [dbo].[LeadBBS_Plug_Card] 
(
	[CardType] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Plug_Card]') AND name = N'IX_LeadBBS_Plug_Card_ExpiresDate')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Plug_Card_ExpiresDate] ON [dbo].[LeadBBS_Plug_Card] 
(
	[ExpiresDate] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'LeadBBS_Plug_Card', N'COLUMN',N'CardID'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'卡号(N位数)' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LeadBBS_Plug_Card', @level2type=N'COLUMN',@level2name=N'CardID'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'LeadBBS_Plug_Card', N'COLUMN',N'CardType'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'1-充积分 2-充财富 3-充威望 4-充经验' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LeadBBS_Plug_Card', @level2type=N'COLUMN',@level2name=N'CardType'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'LeadBBS_Plug_Card', N'COLUMN',N'ExpiresDate'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'到期时间' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LeadBBS_Plug_Card', @level2type=N'COLUMN',@level2name=N'ExpiresDate'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'LeadBBS_Plug_Card', N'COLUMN',N'CardPoints'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'充值点数 分别有1 2 5 10 25 50 100 500 1000 10000' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LeadBBS_Plug_Card', @level2type=N'COLUMN',@level2name=N'CardPoints'
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Opinion]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Opinion](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](20) NOT NULL,
	[AnnounceID] [bigint] NOT NULL,
	[Num] [int] NOT NULL,
	[NumType] [tinyint] NOT NULL,
	[Opinion] [varchar](24) NOT NULL,
	[IP] [varchar](15) NOT NULL,
	[Ndatetime] [bigint] NOT NULL,
 CONSTRAINT [PK_LeadBBS_Opinion] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Opinion]') AND name = N'IX_LeadBBS_Opinion_AnnounceID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Opinion_AnnounceID] ON [dbo].[LeadBBS_Opinion] 
(
	[AnnounceID] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Opinion]') AND name = N'IX_LeadBBS_Opinion_AnnounceID2')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Opinion_AnnounceID2] ON [dbo].[LeadBBS_Opinion] 
(
	[AnnounceID] ASC,
	[UserName] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_onlineUser]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_onlineUser](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SessionID] [bigint] NOT NULL,
	[UserID] [bigint] NOT NULL,
	[LastDoingTime] [bigint] NOT NULL,
	[IP] [varchar](15) NOT NULL,
	[StartTime] [bigint] NOT NULL,
	[AtBoardID] [int] NOT NULL,
	[AtUrl] [nvarchar](255) NOT NULL,
	[AtInfo] [nvarchar](255) NOT NULL,
	[LastRndNumber] [int] NOT NULL,
	[Browser] [nvarchar](50) NOT NULL,
	[System] [nvarchar](50) NOT NULL,
	[UserName] [nvarchar](20) NOT NULL,
	[HiddenFlag] [bigint] NOT NULL,
 CONSTRAINT [PK_asphouse_onlineUser] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_onlineUser]') AND name = N'IX_asphouse_onlineUser_AtBoardID')
CREATE NONCLUSTERED INDEX [IX_asphouse_onlineUser_AtBoardID] ON [dbo].[LeadBBS_onlineUser] 
(
	[AtBoardID] ASC,
	[UserID] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_onlineUser]') AND name = N'IX_asphouse_onlineUser_LastDoingTime')
CREATE NONCLUSTERED INDEX [IX_asphouse_onlineUser_LastDoingTime] ON [dbo].[LeadBBS_onlineUser] 
(
	[LastDoingTime] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_onlineUser]') AND name = N'IX_asphouse_onlineUser_SessionID')
CREATE NONCLUSTERED INDEX [IX_asphouse_onlineUser_SessionID] ON [dbo].[LeadBBS_onlineUser] 
(
	[SessionID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_onlineUser]') AND name = N'IX_asphouse_onlineUser_UserID')
CREATE NONCLUSTERED INDEX [IX_asphouse_onlineUser_UserID] ON [dbo].[LeadBBS_onlineUser] 
(
	[UserID] ASC,
	[SessionID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_onlineUser]') AND name = N'IX_LeadBBS_onlineUser_IP')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_onlineUser_IP] ON [dbo].[LeadBBS_onlineUser] 
(
	[IP] ASC,
	[UserID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Log]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Log](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[LogType] [int] NOT NULL,
	[LogTime] [bigint] NOT NULL,
	[LogInfo] [nvarchar](255) NOT NULL,
	[UserName] [varchar](20) NOT NULL,
	[IP] [varchar](15) NOT NULL,
	[BoardID] [int] NOT NULL,
 CONSTRAINT [PK_LeadBBS_Log] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Log]') AND name = N'IX_LeadBBS_Log_BoardID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Log_BoardID] ON [dbo].[LeadBBS_Log] 
(
	[BoardID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Log]') AND name = N'IX_LeadBBS_Log_LogTime')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Log_LogTime] ON [dbo].[LeadBBS_Log] 
(
	[LogTime] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Log]') AND name = N'IX_LeadBBS_Log_LogType')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Log_LogType] ON [dbo].[LeadBBS_Log] 
(
	[LogType] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Log]') AND name = N'IX_LeadBBS_Log_UserName')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Log_UserName] ON [dbo].[LeadBBS_Log] 
(
	[UserName] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Link]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Link](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SiteName] [nvarchar](255) NOT NULL,
	[SiteUrl] [varchar](255) NOT NULL,
	[LogoUrl] [varchar](255) NOT NULL,
	[OrderID] [bigint] NOT NULL,
	[LogoWidth] [int] NOT NULL,
	[LogoHeight] [int] NOT NULL,
	[BreakFlag] [bit] NOT NULL,
	[LinkType] [tinyint] NOT NULL,
 CONSTRAINT [PK_LeadBBS_Link] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Link]') AND name = N'IX_LeadBBS_Link')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Link] ON [dbo].[LeadBBS_Link] 
(
	[LinkType] ASC,
	[OrderID] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_IPAddress]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_IPAddress](
	[ip1] [bigint] NOT NULL,
	[ip2] [bigint] NULL,
	[country] [nvarchar](13) NULL,
	[city] [nvarchar](47) NULL
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_IPAddress]') AND name = N'IX_LeadBBS_IPAddress')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_IPAddress] ON [dbo].[LeadBBS_IPAddress] 
(
	[ip1] ASC,
	[ip2] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_IPAddress]') AND name = N'IX_LeadBBS_IPAddress_1')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_IPAddress_1] ON [dbo].[LeadBBS_IPAddress] 
(
	[ip2] ASC,
	[ip1] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_InfoBox]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_InfoBox](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[FromUser] [varchar](20) NOT NULL,
	[ToUser] [varchar](20) NOT NULL,
	[Title] [varchar](100) NOT NULL,
	[Content] [text] NOT NULL,
	[IP] [varchar](15) NOT NULL,
	[SendTime] [bigint] NOT NULL,
	[ReadFlag] [tinyint] NOT NULL,
	[ExpiresDate] [int] NOT NULL,
 CONSTRAINT [PK_LeadBBS_InfoBox] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_InfoBox]') AND name = N'IX_Asphouse_InfoBox_FromUser')
CREATE NONCLUSTERED INDEX [IX_Asphouse_InfoBox_FromUser] ON [dbo].[LeadBBS_InfoBox] 
(
	[FromUser] ASC,
	[ID] DESC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_InfoBox]') AND name = N'IX_Asphouse_InfoBox_ToUser')
CREATE NONCLUSTERED INDEX [IX_Asphouse_InfoBox_ToUser] ON [dbo].[LeadBBS_InfoBox] 
(
	[ToUser] ASC,
	[ID] DESC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_InfoBox]') AND name = N'IX_LeadBBS_InfoBox_ExpiresDate')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_InfoBox_ExpiresDate] ON [dbo].[LeadBBS_InfoBox] 
(
	[ExpiresDate] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_InfoBox]') AND name = N'IX_LeadBBS_InfoBox_ReadFlag')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_InfoBox_ReadFlag] ON [dbo].[LeadBBS_InfoBox] 
(
	[ReadFlag] ASC,
	[FromUser] ASC,
	[ID] DESC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_InfoBox]') AND name = N'IX_LeadBBS_InfoBox_ReadFlag1')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_InfoBox_ReadFlag1] ON [dbo].[LeadBBS_InfoBox] 
(
	[ReadFlag] ASC,
	[ToUser] ASC,
	[ID] DESC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_GoodAssort]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_GoodAssort](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [bigint] NOT NULL,
	[BoardID] [int] NOT NULL,
	[AssortName] [nvarchar](255) NOT NULL,
	[GoodNum] [bigint] NOT NULL,
 CONSTRAINT [PK_LeadBBS_GoodAssort] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_GoodAssort]') AND name = N'IX_LeadBBS_GoodAssort_BoardID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_GoodAssort_BoardID] ON [dbo].[LeadBBS_GoodAssort] 
(
	[BoardID] ASC,
	[OrderID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[HBTrigger_EnglishNews]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[HBTrigger_EnglishNews](
	[Serial] [bigint] IDENTITY(1,1) NOT NULL,
	[Id] [int] NOT NULL,
	[Opr] [char](16) NULL,
	[Fields] [nvarchar](4000) NULL,
PRIMARY KEY CLUSTERED 
(
	[Serial] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[article_upload]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[article_upload](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [bigint] NOT NULL,
	[PhotoDir] [varchar](100) NOT NULL,
	[SPhotoDir] [varchar](100) NOT NULL,
	[NdateTime] [bigint] NOT NULL,
	[FileType] [tinyint] NOT NULL,
	[FileName] [varchar](50) NOT NULL,
	[FileSize] [int] NOT NULL,
	[AnnounceID] [bigint] NOT NULL,
	[BoardID] [bigint] NOT NULL,
	[Info] [nvarchar](255) NOT NULL,
	[VisitIP] [varchar](50) NOT NULL,
	[Hits] [bigint] NOT NULL,
 CONSTRAINT [PK_article_upload] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_upload]') AND name = N'IX_article_upload_AnnounceID')
CREATE NONCLUSTERED INDEX [IX_article_upload_AnnounceID] ON [dbo].[article_upload] 
(
	[AnnounceID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_upload]') AND name = N'IX_article_upload_BoardID')
CREATE NONCLUSTERED INDEX [IX_article_upload_BoardID] ON [dbo].[article_upload] 
(
	[BoardID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_upload]') AND name = N'IX_article_upload_FileType')
CREATE NONCLUSTERED INDEX [IX_article_upload_FileType] ON [dbo].[article_upload] 
(
	[FileType] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_upload]') AND name = N'IX_article_upload_FileType2')
CREATE NONCLUSTERED INDEX [IX_article_upload_FileType2] ON [dbo].[article_upload] 
(
	[FileType] ASC,
	[AnnounceID] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_upload]') AND name = N'IX_article_upload_NdateTime')
CREATE NONCLUSTERED INDEX [IX_article_upload_NdateTime] ON [dbo].[article_upload] 
(
	[NdateTime] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_upload]') AND name = N'IX_article_upload_UserID')
CREATE NONCLUSTERED INDEX [IX_article_upload_UserID] ON [dbo].[article_upload] 
(
	[UserID] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_upload]') AND name = N'IX_article_upload_UserIDFileType')
CREATE NONCLUSTERED INDEX [IX_article_upload_UserIDFileType] ON [dbo].[article_upload] 
(
	[UserID] ASC,
	[FileType] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[article_newsclass]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[article_newsclass](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[classname] [varchar](255) NOT NULL,
	[listflag] [tinyint] NOT NULL,
	[orderflag] [bigint] NOT NULL,
	[liststyle] [bigint] NOT NULL,
	[listNum] [int] NOT NULL,
	[parentid] [bigint] NOT NULL,
	[classname_side] [varchar](255) NOT NULL,
 CONSTRAINT [PK_jd_newsclass] PRIMARY KEY CLUSTERED 
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_newsclass]') AND name = N'IX_article_newsclass_listflag')
CREATE NONCLUSTERED INDEX [IX_article_newsclass_listflag] ON [dbo].[article_newsclass] 
(
	[listflag] ASC,
	[id] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_newsclass]') AND name = N'IX_article_newsclass_listflag2')
CREATE NONCLUSTERED INDEX [IX_article_newsclass_listflag2] ON [dbo].[article_newsclass] 
(
	[listflag] ASC,
	[orderflag] ASC,
	[id] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_newsclass]') AND name = N'IX_article_newsclass_parentid')
CREATE NONCLUSTERED INDEX [IX_article_newsclass_parentid] ON [dbo].[article_newsclass] 
(
	[parentid] ASC,
	[orderflag] ASC,
	[id] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_newsclass]') AND name = N'IX_jd_newsclass_listflag')
CREATE NONCLUSTERED INDEX [IX_jd_newsclass_listflag] ON [dbo].[article_newsclass] 
(
	[listflag] ASC,
	[id] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_newsclass]') AND name = N'IX_jd_newsclass_listflag2')
CREATE NONCLUSTERED INDEX [IX_jd_newsclass_listflag2] ON [dbo].[article_newsclass] 
(
	[listflag] ASC,
	[orderflag] ASC,
	[id] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[article_newsarticle_hide]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[article_newsarticle_hide](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](255) NOT NULL,
	[content] [text] NOT NULL,
	[classid] [bigint] NOT NULL,
	[ndatetime] [bigint] NOT NULL,
	[modifytime] [bigint] NOT NULL,
	[author] [nvarchar](50) NOT NULL,
	[fromauthor] [nvarchar](50) NOT NULL,
	[Hits] [bigint] NOT NULL,
	[parentid] [bigint] NOT NULL,
	[ChildNum] [int] NOT NULL,
	[htmlflag] [tinyint] NOT NULL,
 CONSTRAINT [PK_article_newsarticle_hide] PRIMARY KEY CLUSTERED 
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_newsarticle_hide]') AND name = N'IX_article_newsarticle_hide_classid')
CREATE NONCLUSTERED INDEX [IX_article_newsarticle_hide_classid] ON [dbo].[article_newsarticle_hide] 
(
	[classid] ASC,
	[id] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_newsarticle_hide]') AND name = N'IX_article_newsarticle_hide_parentid')
CREATE NONCLUSTERED INDEX [IX_article_newsarticle_hide_parentid] ON [dbo].[article_newsarticle_hide] 
(
	[parentid] ASC,
	[id] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[article_newsarticle]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[article_newsarticle](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[title] [nvarchar](255) NOT NULL,
	[content] [text] NOT NULL,
	[classid] [bigint] NOT NULL,
	[ndatetime] [bigint] NOT NULL,
	[modifytime] [bigint] NOT NULL,
	[author] [nvarchar](50) NOT NULL,
	[fromauthor] [nvarchar](50) NOT NULL,
	[Hits] [bigint] NOT NULL,
	[parentid] [bigint] NOT NULL,
	[ChildNum] [int] NOT NULL,
	[htmlflag] [tinyint] NOT NULL,
 CONSTRAINT [PK_jd_news] PRIMARY KEY CLUSTERED 
(
	[id] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_newsarticle]') AND name = N'IX_article_news_classid')
CREATE NONCLUSTERED INDEX [IX_article_news_classid] ON [dbo].[article_newsarticle] 
(
	[classid] ASC,
	[id] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_newsarticle]') AND name = N'IX_article_newsarticle_parentid')
CREATE NONCLUSTERED INDEX [IX_article_newsarticle_parentid] ON [dbo].[article_newsarticle] 
(
	[parentid] ASC,
	[id] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[article_newsarticle]') AND name = N'IX_jd_news_classid')
CREATE NONCLUSTERED INDEX [IX_jd_news_classid] ON [dbo].[article_newsarticle] 
(
	[classid] ASC,
	[id] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'article_newsarticle', N'COLUMN',N'ndatetime'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'发表时间' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'article_newsarticle', @level2type=N'COLUMN',@level2name=N'ndatetime'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'article_newsarticle', N'COLUMN',N'modifytime'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'整理时间' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'article_newsarticle', @level2type=N'COLUMN',@level2name=N'modifytime'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'article_newsarticle', N'COLUMN',N'Hits'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'最后访问IP' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'article_newsarticle', @level2type=N'COLUMN',@level2name=N'Hits'
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_FriendUser]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_FriendUser](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [bigint] NOT NULL,
	[FriendUserID] [bigint] NOT NULL,
 CONSTRAINT [PK_LeadBBS_FriendUser] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_FriendUser]') AND name = N'IX_LeadBBS_FriendUser_FriendUserID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_FriendUser_FriendUserID] ON [dbo].[LeadBBS_FriendUser] 
(
	[FriendUserID] ASC,
	[UserID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_FriendUser]') AND name = N'PK_LeadBBS_FriendUser_UserID')
CREATE NONCLUSTERED INDEX [PK_LeadBBS_FriendUser_UserID] ON [dbo].[LeadBBS_FriendUser] 
(
	[UserID] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_ForbidIP]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_ForbidIP](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[IPStart] [bigint] NOT NULL,
	[IPEnd] [bigint] NOT NULL,
	[IPNumber] [bigint] NOT NULL,
	[ExpiresTime] [bigint] NOT NULL,
	[WhyString] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_LeadBBS_ForbidIP] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_ForbidIP]') AND name = N'IX_LeadBBS_ForbidIP')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_ForbidIP] ON [dbo].[LeadBBS_ForbidIP] 
(
	[IPEnd] DESC,
	[IPStart] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_ForbidIP]') AND name = N'IX_LeadBBS_ForbidIP_1')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_ForbidIP_1] ON [dbo].[LeadBBS_ForbidIP] 
(
	[IPStart] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_ForbidIP]') AND name = N'IX_LeadBBS_ForbidIP_2')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_ForbidIP_2] ON [dbo].[LeadBBS_ForbidIP] 
(
	[IPEnd] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_ForbidIP]') AND name = N'IX_LeadBBS_ForbidIP_ExpiresTime')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_ForbidIP_ExpiresTime] ON [dbo].[LeadBBS_ForbidIP] 
(
	[ExpiresTime] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_extend]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_extend](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ClassType] [int] NOT NULL,
	[extendID] [bigint] NOT NULL,
	[extent_title] [nvarchar](255) NOT NULL,
	[extent_content] [text] NOT NULL,
	[extent_num] [bigint] NOT NULL,
	[extent_num2] [bigint] NOT NULL,
	[extent_level] [int] NOT NULL,
 CONSTRAINT [PK_LeadBBS_extend] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_extend]') AND name = N'IX_LeadBBS_extend_ClassType')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_extend_ClassType] ON [dbo].[LeadBBS_extend] 
(
	[ClassType] ASC,
	[ID] DESC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_extend]') AND name = N'IX_LeadBBS_extend_extentID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_extend_extentID] ON [dbo].[LeadBBS_extend] 
(
	[ClassType] ASC,
	[extendID] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_extend]') AND name = N'IX_LeadBBS_extend_level')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_extend_level] ON [dbo].[LeadBBS_extend] 
(
	[ClassType] ASC,
	[extent_level] ASC,
	[extendID] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Download]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Download](
	[ID] [bigint] NOT NULL,
	[DownName] [varchar](50) NOT NULL,
	[DownCount] [bigint] NOT NULL,
	[FileUrl] [varchar](255) NOT NULL,
	[LastIP] [varchar](15) NOT NULL,
 CONSTRAINT [PK_LeadBBS_Download] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY],
 CONSTRAINT [IX_LeadBBS_Download_DownName] UNIQUE NONCLUSTERED 
(
	[DownName] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_CollectAnc]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_CollectAnc](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[AnnounceID] [bigint] NOT NULL,
	[UserID] [bigint] NOT NULL,
 CONSTRAINT [PK_LeadBBS_CollectAnc] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_CollectAnc]') AND name = N'IX_LeadBBS_CollectAnc')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_CollectAnc] ON [dbo].[LeadBBS_CollectAnc] 
(
	[AnnounceID] ASC,
	[UserID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_CollectAnc]') AND name = N'IX_LeadBBS_CollectAnc_UserID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_CollectAnc_UserID] ON [dbo].[LeadBBS_CollectAnc] 
(
	[UserID] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Boards]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Boards](
	[BoardID] [int] NOT NULL,
	[BoardAssort] [int] NOT NULL,
	[BoardName] [varchar](250) NOT NULL,
	[BoardIntro] [varchar](500) NOT NULL,
	[LastWriter] [varchar](50) NOT NULL,
	[LastWriteTime] [bigint] NOT NULL,
	[TopicNum] [bigint] NOT NULL,
	[AnnounceNum] [bigint] NOT NULL,
	[ForumPass] [nvarchar](20) NOT NULL,
	[HiddenFlag] [tinyint] NOT NULL,
	[LastAnnounceID] [bigint] NOT NULL,
	[LastTopicName] [varchar](255) NOT NULL,
	[MasterList] [nvarchar](255) NOT NULL,
	[BoardLimit] [int] NOT NULL,
	[AllMinRootID] [bigint] NOT NULL,
	[AllMaxRootID] [bigint] NOT NULL,
	[TodayAnnounce] [bigint] NOT NULL,
	[GoodNum] [bigint] NOT NULL,
	[OrderID] [bigint] NOT NULL,
	[BoardStyle] [tinyint] NOT NULL,
	[StartTime] [bigint] NOT NULL,
	[EndTime] [bigint] NOT NULL,
	[BoardHead] [text] NOT NULL,
	[BoardBottom] [text] NOT NULL,
	[BoardImgUrl] [varchar](255) NOT NULL,
	[BoardImgWidth] [int] NOT NULL,
	[BoardImgHeight] [int] NOT NULL,
	[ParentBoard] [int] NOT NULL,
	[LowerBoard] [varchar](255) NOT NULL,
	[ParentBoardStr] [varchar](100) NOT NULL,
	[BoardLevel] [tinyint] NOT NULL,
	[TopicNum_All] [bigint] NOT NULL,
	[AnnounceNum_All] [bigint] NOT NULL,
	[TodayAnnounce_All] [bigint] NOT NULL,
	[GoodNum_All] [bigint] NOT NULL,
	[OtherLimit] [bigint] NOT NULL,
	[BoardIntro2] [text] NOT NULL,
 CONSTRAINT [PK_Forum_Boards_BoardID] PRIMARY KEY CLUSTERED 
(
	[BoardID] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Boards]') AND name = N'IX_AsphouseBBS_Boards')
CREATE NONCLUSTERED INDEX [IX_AsphouseBBS_Boards] ON [dbo].[LeadBBS_Boards] 
(
	[ParentBoard] ASC,
	[HiddenFlag] ASC,
	[BoardAssort] ASC,
	[OrderID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Boards]') AND name = N'IX_AsphouseBBS_Boards_BoardAssort')
CREATE NONCLUSTERED INDEX [IX_AsphouseBBS_Boards_BoardAssort] ON [dbo].[LeadBBS_Boards] 
(
	[BoardAssort] ASC,
	[OrderID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Boards]') AND name = N'IX_AsphouseBBS_Boards_BoardName')
CREATE NONCLUSTERED INDEX [IX_AsphouseBBS_Boards_BoardName] ON [dbo].[LeadBBS_Boards] 
(
	[BoardName] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Boards]') AND name = N'IX_AsphouseBBS_Boards2')
CREATE NONCLUSTERED INDEX [IX_AsphouseBBS_Boards2] ON [dbo].[LeadBBS_Boards] 
(
	[HiddenFlag] ASC,
	[BoardAssort] ASC,
	[OrderID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Boards]') AND name = N'IX_LeadBBS_Boards_HiddenFlag')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Boards_HiddenFlag] ON [dbo].[LeadBBS_Boards] 
(
	[HiddenFlag] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Boards]') AND name = N'IX_LeadBBS_Boards_ParentBoard')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Boards_ParentBoard] ON [dbo].[LeadBBS_Boards] 
(
	[ParentBoard] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Assort]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Assort](
	[AssortID] [int] NOT NULL,
	[AssortName] [varchar](250) NOT NULL,
	[AssortMaster] [nvarchar](250) NOT NULL,
	[AssortLimit] [bigint] NOT NULL,
 CONSTRAINT [PK_BBS_Assort_AssortID] PRIMARY KEY CLUSTERED 
(
	[AssortID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Assort]') AND name = N'IX_AsphouseBBS_Assort_AssortName')
CREATE NONCLUSTERED INDEX [IX_AsphouseBBS_Assort_AssortName] ON [dbo].[LeadBBS_Assort] 
(
	[AssortName] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'LeadBBS_Assort', N'COLUMN',N'AssortID'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'分类ID号，ID号可以由站长输入' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LeadBBS_Assort', @level2type=N'COLUMN',@level2name=N'AssortID'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'LeadBBS_Assort', N'COLUMN',N'AssortName'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'分类名称，可以使用HTML' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LeadBBS_Assort', @level2type=N'COLUMN',@level2name=N'AssortName'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'LeadBBS_Assort', N'COLUMN',N'AssortMaster'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'区版主名单' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LeadBBS_Assort', @level2type=N'COLUMN',@level2name=N'AssortMaster'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'LeadBBS_Assort', N'COLUMN',N'AssortLimit'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'分类限制参数' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LeadBBS_Assort', @level2type=N'COLUMN',@level2name=N'AssortLimit'
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Assessor]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Assessor](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[BoardID] [bigint] NOT NULL,
	[Title] [varchar](255) NOT NULL,
	[UserName] [varchar](20) NOT NULL,
	[NDateTime] [bigint] NOT NULL,
	[AnnounceID] [bigint] NOT NULL,
	[Content] [text] NOT NULL,
	[HTMLFlag] [tinyint] NOT NULL,
	[TypeFlag] [tinyint] NOT NULL,
 CONSTRAINT [PK_LeadBBS_Assessor] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Assessor]') AND name = N'IX_LeadBBS_Assessor_AnnounceID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Assessor_AnnounceID] ON [dbo].[LeadBBS_Assessor] 
(
	[AnnounceID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Assessor]') AND name = N'IX_LeadBBS_Assessor_BoardID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Assessor_BoardID] ON [dbo].[LeadBBS_Assessor] 
(
	[BoardID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Assessor]') AND name = N'IX_LeadBBS_Assessor_TypeFlag')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Assessor_TypeFlag] ON [dbo].[LeadBBS_Assessor] 
(
	[TypeFlag] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_AppLogin]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_AppLogin](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserID] [bigint] NOT NULL,
	[appid] [varchar](64) NOT NULL,
	[GuestName] [varchar](20) NOT NULL,
	[appType] [int] NOT NULL,
	[ndatetime] [bigint] NOT NULL,
	[IPAddress] [varchar](50) NOT NULL,
	[Token] [varchar](128) NOT NULL,
	[ExpiresTime] [bigint] NOT NULL,
	[Retention1] [varchar](64) NOT NULL,
 CONSTRAINT [PK_LeadBBS_AppLogin] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_AppLogin]') AND name = N'IX_LeadBBS_AppLogin_appid')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_AppLogin_appid] ON [dbo].[LeadBBS_AppLogin] 
(
	[appType] ASC,
	[appid] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_AppLogin]') AND name = N'IX_LeadBBS_AppLogin_UserID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_AppLogin_UserID] ON [dbo].[LeadBBS_AppLogin] 
(
	[UserID] ASC,
	[appType] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'LeadBBS_AppLogin', N'COLUMN',N'UserID'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'参应_user编号,若未绑定为0' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LeadBBS_AppLogin', @level2type=N'COLUMN',@level2name=N'UserID'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'LeadBBS_AppLogin', N'COLUMN',N'appid'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'相应平台对应登录用户的标识' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LeadBBS_AppLogin', @level2type=N'COLUMN',@level2name=N'appid'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'LeadBBS_AppLogin', N'COLUMN',N'GuestName'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'获取的默认用户名' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LeadBBS_AppLogin', @level2type=N'COLUMN',@level2name=N'GuestName'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'LeadBBS_AppLogin', N'COLUMN',N'appType'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'对应集成的平台,比如QQ登录为100' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LeadBBS_AppLogin', @level2type=N'COLUMN',@level2name=N'appType'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'LeadBBS_AppLogin', N'COLUMN',N'ndatetime'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'绑定时间' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LeadBBS_AppLogin', @level2type=N'COLUMN',@level2name=N'ndatetime'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_Description' , N'USER',N'dbo', N'TABLE',N'LeadBBS_AppLogin', N'COLUMN',N'IPAddress'))
EXEC dbo.sp_addextendedproperty @name=N'MS_Description', @value=N'操作IP' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LeadBBS_AppLogin', @level2type=N'COLUMN',@level2name=N'IPAddress'
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Announce_Hide](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentID] [bigint] NOT NULL,
	[TopicSortID] [int] NOT NULL,
	[BoardID] [int] NOT NULL,
	[RootID] [bigint] NOT NULL,
	[ChildNum] [int] NOT NULL,
	[Layer] [int] NOT NULL,
	[Title] [varchar](255) NOT NULL,
	[Content] [text] NOT NULL,
	[Opinion] [varchar](50) NOT NULL,
	[FaceIcon] [tinyint] NOT NULL,
	[ndatetime] [bigint] NOT NULL,
	[LastTime] [bigint] NOT NULL,
	[Hits] [bigint] NOT NULL,
	[Length] [int] NOT NULL,
	[UserName] [varchar](20) NOT NULL,
	[UserID] [bigint] NOT NULL,
	[HTMLFlag] [tinyint] NOT NULL,
	[UnderWriteFlag] [tinyint] NOT NULL,
	[NotReplay] [tinyint] NOT NULL,
	[IPAddress] [varchar](15) NOT NULL,
	[LastUser] [varchar](50) NOT NULL,
	[GoodFlag] [tinyint] NOT NULL,
	[TopicType] [tinyint] NOT NULL,
	[NeedValue] [bigint] NOT NULL,
	[PollNum] [bigint] NOT NULL,
	[OtherInfo] [varchar](100) NOT NULL,
	[RootMaxID] [bigint] NOT NULL,
	[RootMinID] [bigint] NOT NULL,
	[TitleStyle] [tinyint] NOT NULL,
	[LastInfo] [varchar](50) NOT NULL,
	[GoodAssort] [int] NOT NULL,
	[RootIDBak] [bigint] NOT NULL,
	[VisitIP] [varchar](15) NOT NULL,
 CONSTRAINT [PK_LeadBBS_Announce_Hide_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND name = N'IX_LeadBBS_Announce_Hide_1')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_Hide_1] ON [dbo].[LeadBBS_Announce_Hide] 
(
	[GoodFlag] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND name = N'IX_LeadBBS_Announce_Hide_GoodAssort')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_Hide_GoodAssort] ON [dbo].[LeadBBS_Announce_Hide] 
(
	[GoodAssort] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND name = N'IX_LeadBBS_Announce_Hide_GoodFlag2')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_Hide_GoodFlag2] ON [dbo].[LeadBBS_Announce_Hide] 
(
	[GoodFlag] ASC,
	[BoardID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND name = N'IX_LeadBBS_Announce_Hide_GoodFlag3')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_Hide_GoodFlag3] ON [dbo].[LeadBBS_Announce_Hide] 
(
	[GoodFlag] ASC,
	[UserID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND name = N'IX_LeadBBS_Announce_Hide_IPAddress')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_Hide_IPAddress] ON [dbo].[LeadBBS_Announce_Hide] 
(
	[IPAddress] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND name = N'IX_LeadBBS_Announce_Hide_lastTime')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_Hide_lastTime] ON [dbo].[LeadBBS_Announce_Hide] 
(
	[ParentID] ASC,
	[BoardID] ASC,
	[LastTime] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND name = N'IX_LeadBBS_Announce_Hide_ndatetime')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_Hide_ndatetime] ON [dbo].[LeadBBS_Announce_Hide] 
(
	[BoardID] ASC,
	[ndatetime] DESC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND name = N'IX_LeadBBS_Announce_Hide_ndatetime2')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_Hide_ndatetime2] ON [dbo].[LeadBBS_Announce_Hide] 
(
	[ndatetime] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND name = N'IX_LeadBBS_Announce_Hide_ParentID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_Hide_ParentID] ON [dbo].[LeadBBS_Announce_Hide] 
(
	[ParentID] ASC,
	[BoardID] ASC,
	[RootID] DESC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND name = N'IX_LeadBBS_Announce_Hide_ParentID2')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_Hide_ParentID2] ON [dbo].[LeadBBS_Announce_Hide] 
(
	[ParentID] ASC,
	[BoardID] ASC,
	[RootIDBak] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND name = N'IX_LeadBBS_Announce_Hide_RootIDBak')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_Hide_RootIDBak] ON [dbo].[LeadBBS_Announce_Hide] 
(
	[RootIDBak] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND name = N'IX_LeadBBS_Announce_Hide_RootIDBak2')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_Hide_RootIDBak2] ON [dbo].[LeadBBS_Announce_Hide] 
(
	[ParentID] ASC,
	[RootIDBak] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND name = N'IX_LeadBBS_Announce_Hide_TopicType')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_Hide_TopicType] ON [dbo].[LeadBBS_Announce_Hide] 
(
	[TopicType] ASC,
	[NeedValue] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND name = N'IX_LeadBBS_Announce_Hide_UserID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_Hide_UserID] ON [dbo].[LeadBBS_Announce_Hide] 
(
	[UserID] ASC,
	[ParentID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce_Hide]') AND name = N'IX_LeadBBS_Announce_Hide_UserID2')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_Hide_UserID2] ON [dbo].[LeadBBS_Announce_Hide] 
(
	[UserID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[LeadBBS_Announce](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentID] [bigint] NOT NULL,
	[TopicSortID] [int] NOT NULL,
	[BoardID] [int] NOT NULL,
	[RootID] [bigint] NOT NULL,
	[ChildNum] [int] NOT NULL,
	[Layer] [int] NOT NULL,
	[Title] [varchar](255) NOT NULL,
	[Content] [text] NOT NULL,
	[Opinion] [varchar](50) NOT NULL,
	[FaceIcon] [tinyint] NOT NULL,
	[ndatetime] [bigint] NOT NULL,
	[LastTime] [bigint] NOT NULL,
	[Hits] [bigint] NOT NULL,
	[Length] [int] NOT NULL,
	[UserName] [varchar](20) NOT NULL,
	[UserID] [bigint] NOT NULL,
	[HTMLFlag] [tinyint] NOT NULL,
	[UnderWriteFlag] [tinyint] NOT NULL,
	[NotReplay] [tinyint] NOT NULL,
	[IPAddress] [varchar](15) NOT NULL,
	[LastUser] [varchar](50) NOT NULL,
	[GoodFlag] [tinyint] NOT NULL,
	[TopicType] [tinyint] NOT NULL,
	[NeedValue] [bigint] NOT NULL,
	[PollNum] [bigint] NOT NULL,
	[OtherInfo] [varchar](100) NOT NULL,
	[RootMaxID] [bigint] NOT NULL,
	[RootMinID] [bigint] NOT NULL,
	[TitleStyle] [tinyint] NOT NULL,
	[LastInfo] [varchar](50) NOT NULL,
	[GoodAssort] [int] NOT NULL,
	[RootIDBak] [bigint] NOT NULL,
	[VisitIP] [varchar](15) NOT NULL,
 CONSTRAINT [PK_AsphouseBBS_Announce_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_AsphouseBBS_Announce_UserID')
CREATE NONCLUSTERED INDEX [IX_AsphouseBBS_Announce_UserID] ON [dbo].[LeadBBS_Announce] 
(
	[UserID] ASC,
	[ParentID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_LeadBBS_Announce_1')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_1] ON [dbo].[LeadBBS_Announce] 
(
	[GoodFlag] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_LeadBBS_Announce_GoodAssort')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_GoodAssort] ON [dbo].[LeadBBS_Announce] 
(
	[GoodAssort] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_LeadBBS_Announce_GoodFlag2')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_GoodFlag2] ON [dbo].[LeadBBS_Announce] 
(
	[GoodFlag] ASC,
	[BoardID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_LeadBBS_Announce_GoodFlag3')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_GoodFlag3] ON [dbo].[LeadBBS_Announce] 
(
	[GoodFlag] ASC,
	[UserID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_LeadBBS_Announce_IPAddress')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_IPAddress] ON [dbo].[LeadBBS_Announce] 
(
	[IPAddress] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_LeadBBS_Announce_lastTime')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_lastTime] ON [dbo].[LeadBBS_Announce] 
(
	[ParentID] ASC,
	[BoardID] ASC,
	[LastTime] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_LeadBBS_Announce_ndatetime')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_ndatetime] ON [dbo].[LeadBBS_Announce] 
(
	[BoardID] ASC,
	[ndatetime] DESC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_LeadBBS_Announce_ndatetime2')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_ndatetime2] ON [dbo].[LeadBBS_Announce] 
(
	[ndatetime] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_LeadBBS_Announce_OnlyTopicUser')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_OnlyTopicUser] ON [dbo].[LeadBBS_Announce] 
(
	[RootIDBak] ASC,
	[UserID] ASC,
	[ID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_LeadBBS_Announce_ParentID')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_ParentID] ON [dbo].[LeadBBS_Announce] 
(
	[ParentID] ASC,
	[BoardID] ASC,
	[RootID] DESC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_LeadBBS_Announce_ParentID2')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_ParentID2] ON [dbo].[LeadBBS_Announce] 
(
	[ParentID] ASC,
	[BoardID] ASC,
	[RootIDBak] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_LeadBBS_Announce_RootIDBak')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_RootIDBak] ON [dbo].[LeadBBS_Announce] 
(
	[RootIDBak] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_LeadBBS_Announce_RootIDBak2')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_RootIDBak2] ON [dbo].[LeadBBS_Announce] 
(
	[ParentID] ASC,
	[RootIDBak] DESC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_LeadBBS_Announce_TopicType')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_TopicType] ON [dbo].[LeadBBS_Announce] 
(
	[TopicType] ASC,
	[NeedValue] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysindexes WHERE id = OBJECT_ID(N'[dbo].[LeadBBS_Announce]') AND name = N'IX_LeadBBS_Announce_UserID2')
CREATE NONCLUSTERED INDEX [IX_LeadBBS_Announce_UserID2] ON [dbo].[LeadBBS_Announce] 
(
	[UserID] ASC
) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[leadbbs_friendinfo]') AND OBJECTPROPERTY(id, N'IsView') = 1)
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[leadbbs_friendinfo]
AS
SELECT TOP 100 PERCENT a.ID, a.Title, a.UserID, a.UserName, f.UserID AS myid
FROM dbo.LeadBBS_Announce a INNER JOIN
      dbo.LeadBBS_FriendUser f ON a.UserID = f.FriendUserID
ORDER BY myid, a.ID DESC
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'USER',N'dbo', N'VIEW',N'leadbbs_friendinfo', NULL,NULL))
EXEC dbo.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 109
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "f"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 95
               Right = 392
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 240
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'leadbbs_friendinfo'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'USER',N'dbo', N'VIEW',N'leadbbs_friendinfo', NULL,NULL))
EXEC dbo.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'USER',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'leadbbs_friendinfo'
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[leadbbs_fulltext]') AND OBJECTPROPERTY(id, N'IsView') = 1)
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dbo].[leadbbs_fulltext]
AS
SELECT     dbo.LeadBBS_Announce.ID, dbo.LeadBBS_Announce.BoardID, dbo.LeadBBS_Boards.BoardName, dbo.LeadBBS_Announce.LastTime, 
                      dbo.LeadBBS_Announce.UserID, dbo.LeadBBS_Announce.Title, dbo.LeadBBS_Announce.[Content], dbo.LeadBBS_Announce.UserName, 
                      dbo.LeadBBS_Announce.ndatetime, dbo.LeadBBS_Boards.BoardLimit, dbo.LeadBBS_Boards.OtherLimit, dbo.LeadBBS_Boards.HiddenFlag, 
                      dbo.LeadBBS_Boards.ForumPass, dbo.LeadBBS_Announce.ParentID, dbo.LeadBBS_Announce.ChildNum, dbo.LeadBBS_Announce.Hits, 
                      dbo.LeadBBS_Announce.GoodFlag, dbo.LeadBBS_Announce.TopicType, dbo.LeadBBS_Announce.NeedValue, dbo.LeadBBS_Announce.TitleStyle, 
                      dbo.LeadBBS_Announce.GoodAssort, dbo.LeadBBS_GoodAssort.AssortName, dbo.LeadBBS_User.TrueName
FROM         dbo.LeadBBS_Announce LEFT OUTER JOIN
                      dbo.LeadBBS_Boards ON dbo.LeadBBS_Announce.BoardID = dbo.LeadBBS_Boards.BoardID LEFT OUTER JOIN
                      dbo.LeadBBS_GoodAssort ON dbo.LeadBBS_Announce.GoodAssort = dbo.LeadBBS_GoodAssort.ID LEFT OUTER JOIN
                      dbo.LeadBBS_User ON dbo.LeadBBS_Announce.UserID = dbo.LeadBBS_User.ID
'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPane1' , N'USER',N'dbo', N'VIEW',N'leadbbs_fulltext', NULL,NULL))
EXEC dbo.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "LeadBBS_Announce"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 109
               Right = 202
            End
            DisplayFlags = 280
            TopColumn = 14
         End
         Begin Table = "LeadBBS_Boards"
            Begin Extent = 
               Top = 6
               Left = 240
               Bottom = 109
               Right = 427
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "LeadBBS_GoodAssort"
            Begin Extent = 
               Top = 96
               Left = 329
               Bottom = 199
               Right = 469
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "LeadBBS_User"
            Begin Extent = 
               Top = 143
               Left = 54
               Bottom = 251
               Right = 213
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'USER',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'leadbbs_fulltext'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'MS_DiagramPaneCount' , N'USER',N'dbo', N'VIEW',N'leadbbs_fulltext', NULL,NULL))
EXEC dbo.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'USER',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'leadbbs_fulltext'
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_jd_news_title]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_jd_news_title]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle] ADD  CONSTRAINT [DF_jd_news_title]  DEFAULT ('') FOR [title]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_jd_news_content]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_jd_news_content]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle] ADD  CONSTRAINT [DF_jd_news_content]  DEFAULT ('') FOR [content]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_jd_news_classid]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_jd_news_classid]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle] ADD  CONSTRAINT [DF_jd_news_classid]  DEFAULT (0) FOR [classid]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_ndatetime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_ndatetime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle] ADD  CONSTRAINT [DF_article_newsarticle_ndatetime]  DEFAULT (0) FOR [ndatetime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_modifytime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_modifytime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle] ADD  CONSTRAINT [DF_article_newsarticle_modifytime]  DEFAULT (0) FOR [modifytime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_author]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_author]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle] ADD  CONSTRAINT [DF_article_newsarticle_author]  DEFAULT ('') FOR [author]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_fromauthor]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_fromauthor]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle] ADD  CONSTRAINT [DF_article_newsarticle_fromauthor]  DEFAULT ('') FOR [fromauthor]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_VisitIP]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_VisitIP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle] ADD  CONSTRAINT [DF_article_newsarticle_VisitIP]  DEFAULT (0) FOR [Hits]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_parentid]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_parentid]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle] ADD  CONSTRAINT [DF_article_newsarticle_parentid]  DEFAULT (0) FOR [parentid]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_ChildNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_ChildNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle] ADD  CONSTRAINT [DF_article_newsarticle_ChildNum]  DEFAULT (0) FOR [ChildNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_htmlflag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_htmlflag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle] ADD  CONSTRAINT [DF_article_newsarticle_htmlflag]  DEFAULT ((2)) FOR [htmlflag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_hide_title]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_hide_title]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle_hide] ADD  CONSTRAINT [DF_article_newsarticle_hide_title]  DEFAULT ('') FOR [title]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_hide_content]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_hide_content]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle_hide] ADD  CONSTRAINT [DF_article_newsarticle_hide_content]  DEFAULT ('') FOR [content]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_hide_classid]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_hide_classid]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle_hide] ADD  CONSTRAINT [DF_article_newsarticle_hide_classid]  DEFAULT (0) FOR [classid]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_hide_ndatetime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_hide_ndatetime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle_hide] ADD  CONSTRAINT [DF_article_newsarticle_hide_ndatetime]  DEFAULT (0) FOR [ndatetime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_hide_modifytime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_hide_modifytime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle_hide] ADD  CONSTRAINT [DF_article_newsarticle_hide_modifytime]  DEFAULT (0) FOR [modifytime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_hide_author]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_hide_author]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle_hide] ADD  CONSTRAINT [DF_article_newsarticle_hide_author]  DEFAULT ('') FOR [author]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_hide_fromauthor]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_hide_fromauthor]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle_hide] ADD  CONSTRAINT [DF_article_newsarticle_hide_fromauthor]  DEFAULT ('') FOR [fromauthor]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_hide_VisitIP]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_hide_VisitIP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle_hide] ADD  CONSTRAINT [DF_article_newsarticle_hide_VisitIP]  DEFAULT (0) FOR [Hits]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_hide_parentid]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_hide_parentid]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle_hide] ADD  CONSTRAINT [DF_article_newsarticle_hide_parentid]  DEFAULT (0) FOR [parentid]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_hide_ChildNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_hide_ChildNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle_hide] ADD  CONSTRAINT [DF_article_newsarticle_hide_ChildNum]  DEFAULT (0) FOR [ChildNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsarticle_hide_htmlflag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsarticle_hide_htmlflag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsarticle_hide] ADD  CONSTRAINT [DF_article_newsarticle_hide_htmlflag]  DEFAULT ((2)) FOR [htmlflag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_jd_newsclass_classname]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_jd_newsclass_classname]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsclass] ADD  CONSTRAINT [DF_jd_newsclass_classname]  DEFAULT ('') FOR [classname]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_jd_newsclass_listflag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_jd_newsclass_listflag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsclass] ADD  CONSTRAINT [DF_jd_newsclass_listflag]  DEFAULT (0) FOR [listflag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_jd_newsclass_orderflag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_jd_newsclass_orderflag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsclass] ADD  CONSTRAINT [DF_jd_newsclass_orderflag]  DEFAULT (0) FOR [orderflag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsclass_liststyle]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsclass_liststyle]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsclass] ADD  CONSTRAINT [DF_article_newsclass_liststyle]  DEFAULT (0) FOR [liststyle]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsclass_listNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsclass_listNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsclass] ADD  CONSTRAINT [DF_article_newsclass_listNum]  DEFAULT (0) FOR [listNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsclass_parentid]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsclass_parentid]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsclass] ADD  CONSTRAINT [DF_article_newsclass_parentid]  DEFAULT (0) FOR [parentid]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_newsclass_classname_side]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_newsclass_classname_side]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_newsclass] ADD  CONSTRAINT [DF_article_newsclass_classname_side]  DEFAULT ('') FOR [classname_side]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_upload_UserID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_upload_UserID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_upload] ADD  CONSTRAINT [DF_article_upload_UserID]  DEFAULT (0) FOR [UserID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_upload_PhotoDir]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_upload_PhotoDir]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_upload] ADD  CONSTRAINT [DF_article_upload_PhotoDir]  DEFAULT ('') FOR [PhotoDir]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_upload_SPhotoDir]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_upload_SPhotoDir]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_upload] ADD  CONSTRAINT [DF_article_upload_SPhotoDir]  DEFAULT ('') FOR [SPhotoDir]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_upload_NdateTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_upload_NdateTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_upload] ADD  CONSTRAINT [DF_article_upload_NdateTime]  DEFAULT (0) FOR [NdateTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_upload_FileType]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_upload_FileType]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_upload] ADD  CONSTRAINT [DF_article_upload_FileType]  DEFAULT (0) FOR [FileType]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_upload_FileName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_upload_FileName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_upload] ADD  CONSTRAINT [DF_article_upload_FileName]  DEFAULT ('') FOR [FileName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_upload_FileSize]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_upload_FileSize]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_upload] ADD  CONSTRAINT [DF_article_upload_FileSize]  DEFAULT (0) FOR [FileSize]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_upload_AnnounceID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_upload_AnnounceID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_upload] ADD  CONSTRAINT [DF_article_upload_AnnounceID]  DEFAULT (0) FOR [AnnounceID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_upload_BoardID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_upload_BoardID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_upload] ADD  CONSTRAINT [DF_article_upload_BoardID]  DEFAULT (0) FOR [BoardID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_upload_Info]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_upload_Info]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_upload] ADD  CONSTRAINT [DF_article_upload_Info]  DEFAULT ('') FOR [Info]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_upload_VisitIP]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_upload_VisitIP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_upload] ADD  CONSTRAINT [DF_article_upload_VisitIP]  DEFAULT ('') FOR [VisitIP]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_article_upload_Hits]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_article_upload_Hits]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[article_upload] ADD  CONSTRAINT [DF_article_upload_Hits]  DEFAULT (0) FOR [Hits]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_ParentID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_ParentID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_ParentID]  DEFAULT (0) FOR [ParentID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_TopicSortID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_TopicSortID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_TopicSortID]  DEFAULT (1) FOR [TopicSortID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_BoardID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_BoardID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_BoardID]  DEFAULT (0) FOR [BoardID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_RootID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_RootID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_RootID]  DEFAULT (0) FOR [RootID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_ChildNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_ChildNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_ChildNum]  DEFAULT (0) FOR [ChildNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_Layer]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_Layer]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_Layer]  DEFAULT (1) FOR [Layer]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_Title]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_Title]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_Title]  DEFAULT ('') FOR [Title]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_Content]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_Content]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_Content]  DEFAULT ('') FOR [Content]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_PrintContent]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_PrintContent]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_PrintContent]  DEFAULT ('') FOR [Opinion]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_FaceIcon]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_FaceIcon]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_FaceIcon]  DEFAULT (0) FOR [FaceIcon]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_Hits]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_Hits]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_Hits]  DEFAULT (0) FOR [Hits]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_Length]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_Length]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_Length]  DEFAULT (0) FOR [Length]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_UserName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_UserName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_LeadBBS_Announce_UserName]  DEFAULT ('') FOR [UserName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_UserID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_UserID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_LeadBBS_Announce_UserID]  DEFAULT (0) FOR [UserID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_HTMLFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_HTMLFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_HTMLFlag]  DEFAULT (0) FOR [HTMLFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_UnderWriteFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_UnderWriteFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_UnderWriteFlag]  DEFAULT (0) FOR [UnderWriteFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_NotReplay]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_NotReplay]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_NotReplay]  DEFAULT (0) FOR [NotReplay]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_IP]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_IP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_IP]  DEFAULT ('') FOR [IPAddress]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_LastUser]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_LastUser]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_LastUser]  DEFAULT ('') FOR [LastUser]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_GoodFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_GoodFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_GoodFlag]  DEFAULT (0) FOR [GoodFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_TopicType]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_TopicType]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_TopicType]  DEFAULT (0) FOR [TopicType]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_NeedValue]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_NeedValue]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_NeedValue]  DEFAULT (0) FOR [NeedValue]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Announce_PollNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Announce_PollNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_AsphouseBBS_Announce_PollNum]  DEFAULT (0) FOR [PollNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_OtherInfo]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_OtherInfo]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_LeadBBS_Announce_OtherInfo]  DEFAULT ('') FOR [OtherInfo]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_RootMaxID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_RootMaxID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_LeadBBS_Announce_RootMaxID]  DEFAULT (0) FOR [RootMaxID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_RootMinID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_RootMinID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_LeadBBS_Announce_RootMinID]  DEFAULT (0) FOR [RootMinID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_TitleStyle]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_TitleStyle]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_LeadBBS_Announce_TitleStyle]  DEFAULT (0) FOR [TitleStyle]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_LastInfo]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_LastInfo]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_LeadBBS_Announce_LastInfo]  DEFAULT ('') FOR [LastInfo]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_GoodAssort]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_GoodAssort]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_LeadBBS_Announce_GoodAssort]  DEFAULT (0) FOR [GoodAssort]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_RootIDBak]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_RootIDBak]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_LeadBBS_Announce_RootIDBak]  DEFAULT (0) FOR [RootIDBak]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_VisitIP]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_VisitIP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce] ADD  CONSTRAINT [DF_LeadBBS_Announce_VisitIP]  DEFAULT ('') FOR [VisitIP]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_ParentID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_ParentID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_ParentID]  DEFAULT (0) FOR [ParentID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_TopicSortID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_TopicSortID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_TopicSortID]  DEFAULT (1) FOR [TopicSortID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_BoardID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_BoardID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_BoardID]  DEFAULT (0) FOR [BoardID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_RootID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_RootID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_RootID]  DEFAULT (0) FOR [RootID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_ChildNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_ChildNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_ChildNum]  DEFAULT (0) FOR [ChildNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_Layer]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_Layer]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_Layer]  DEFAULT (1) FOR [Layer]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_Title]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_Title]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_Title]  DEFAULT ('') FOR [Title]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_Content]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_Content]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_Content]  DEFAULT ('') FOR [Content]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_PrintContent]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_PrintContent]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_PrintContent]  DEFAULT ('') FOR [Opinion]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_FaceIcon]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_FaceIcon]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_FaceIcon]  DEFAULT (0) FOR [FaceIcon]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_Hits]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_Hits]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_Hits]  DEFAULT (0) FOR [Hits]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_Length]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_Length]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_Length]  DEFAULT (0) FOR [Length]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_UserName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_UserName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_UserName]  DEFAULT ('') FOR [UserName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_UserID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_UserID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_UserID]  DEFAULT (0) FOR [UserID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_HTMLFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_HTMLFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_HTMLFlag]  DEFAULT (0) FOR [HTMLFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_UnderWriteFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_UnderWriteFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_UnderWriteFlag]  DEFAULT (0) FOR [UnderWriteFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_NotReplay]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_NotReplay]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_NotReplay]  DEFAULT (0) FOR [NotReplay]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_IP]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_IP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_IP]  DEFAULT ('') FOR [IPAddress]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_LastUser]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_LastUser]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_LastUser]  DEFAULT ('') FOR [LastUser]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_GoodFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_GoodFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_GoodFlag]  DEFAULT (0) FOR [GoodFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_TopicType]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_TopicType]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_TopicType]  DEFAULT (0) FOR [TopicType]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_NeedValue]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_NeedValue]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_NeedValue]  DEFAULT (0) FOR [NeedValue]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_PollNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_PollNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_PollNum]  DEFAULT (0) FOR [PollNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_OtherInfo]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_OtherInfo]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_OtherInfo]  DEFAULT ('') FOR [OtherInfo]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_RootMaxID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_RootMaxID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_RootMaxID]  DEFAULT (0) FOR [RootMaxID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_RootMinID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_RootMinID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_RootMinID]  DEFAULT (0) FOR [RootMinID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_TitleStyle]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_TitleStyle]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_TitleStyle]  DEFAULT (0) FOR [TitleStyle]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_LastInfo]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_LastInfo]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_LastInfo]  DEFAULT ('') FOR [LastInfo]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_GoodAssort]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_GoodAssort]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_GoodAssort]  DEFAULT (0) FOR [GoodAssort]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_RootIDBak]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_RootIDBak]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_RootIDBak]  DEFAULT (0) FOR [RootIDBak]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Announce_Hide_VisitIP]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Announce_Hide_VisitIP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Announce_Hide] ADD  CONSTRAINT [DF_LeadBBS_Announce_Hide_VisitIP]  DEFAULT ('') FOR [VisitIP]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_AppLogin_UserID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_AppLogin_UserID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_AppLogin] ADD  CONSTRAINT [DF_LeadBBS_AppLogin_UserID]  DEFAULT ((0)) FOR [UserID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_AppLogin_appid]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_AppLogin_appid]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_AppLogin] ADD  CONSTRAINT [DF_LeadBBS_AppLogin_appid]  DEFAULT ('') FOR [appid]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_AppLogin_GuestName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_AppLogin_GuestName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_AppLogin] ADD  CONSTRAINT [DF_LeadBBS_AppLogin_GuestName]  DEFAULT ('') FOR [GuestName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_AppLogin_appType]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_AppLogin_appType]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_AppLogin] ADD  CONSTRAINT [DF_LeadBBS_AppLogin_appType]  DEFAULT ((0)) FOR [appType]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_AppLogin_ndatetime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_AppLogin_ndatetime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_AppLogin] ADD  CONSTRAINT [DF_LeadBBS_AppLogin_ndatetime]  DEFAULT ((0)) FOR [ndatetime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_AppLogin_IPAddress]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_AppLogin_IPAddress]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_AppLogin] ADD  CONSTRAINT [DF_LeadBBS_AppLogin_IPAddress]  DEFAULT ('') FOR [IPAddress]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_AppLogin_Token]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_AppLogin_Token]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_AppLogin] ADD  CONSTRAINT [DF_LeadBBS_AppLogin_Token]  DEFAULT ('') FOR [Token]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_AppLogin_ExpiresTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_AppLogin_ExpiresTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_AppLogin] ADD  CONSTRAINT [DF_LeadBBS_AppLogin_ExpiresTime]  DEFAULT ((0)) FOR [ExpiresTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_AppLogin_Retention1]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_AppLogin_Retention1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_AppLogin] ADD  CONSTRAINT [DF_LeadBBS_AppLogin_Retention1]  DEFAULT ('') FOR [Retention1]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Assessor_BoardID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Assessor_BoardID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Assessor] ADD  CONSTRAINT [DF_LeadBBS_Assessor_BoardID]  DEFAULT (0) FOR [BoardID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Assessor_Title]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Assessor_Title]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Assessor] ADD  CONSTRAINT [DF_LeadBBS_Assessor_Title]  DEFAULT ('') FOR [Title]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Assessor_UserName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Assessor_UserName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Assessor] ADD  CONSTRAINT [DF_LeadBBS_Assessor_UserName]  DEFAULT ('') FOR [UserName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Assessor_NDateTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Assessor_NDateTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Assessor] ADD  CONSTRAINT [DF_LeadBBS_Assessor_NDateTime]  DEFAULT (0) FOR [NDateTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Assessor_AnnounceID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Assessor_AnnounceID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Assessor] ADD  CONSTRAINT [DF_LeadBBS_Assessor_AnnounceID]  DEFAULT (0) FOR [AnnounceID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Assessor_Content]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Assessor_Content]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Assessor] ADD  CONSTRAINT [DF_LeadBBS_Assessor_Content]  DEFAULT ('') FOR [Content]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Assessor_HTMLFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Assessor_HTMLFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Assessor] ADD  CONSTRAINT [DF_LeadBBS_Assessor_HTMLFlag]  DEFAULT (0) FOR [HTMLFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Assessor_TypeFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Assessor_TypeFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Assessor] ADD  CONSTRAINT [DF_LeadBBS_Assessor_TypeFlag]  DEFAULT ('') FOR [TypeFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Assort_AssortMaster]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Assort_AssortMaster]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Assort] ADD  CONSTRAINT [DF_LeadBBS_Assort_AssortMaster]  DEFAULT ('') FOR [AssortMaster]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Assort_AssortLimit]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Assort_AssortLimit]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Assort] ADD  CONSTRAINT [DF_LeadBBS_Assort_AssortLimit]  DEFAULT (0) FOR [AssortLimit]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Forum_Boards_BoardAssort]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Forum_Boards_BoardAssort]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_Forum_Boards_BoardAssort]  DEFAULT (0) FOR [BoardAssort]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_BoardIntro]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_BoardIntro]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_BoardIntro]  DEFAULT ('') FOR [BoardIntro]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_LastWriter]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_LastWriter]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_LastWriter]  DEFAULT ('') FOR [LastWriter]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Forum_Boards_LastWriteTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Forum_Boards_LastWriteTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_Forum_Boards_LastWriteTime]  DEFAULT (0) FOR [LastWriteTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Forum_Boards_TopicNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Forum_Boards_TopicNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_Forum_Boards_TopicNum]  DEFAULT (0) FOR [TopicNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Forum_Boards_AnnounceNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Forum_Boards_AnnounceNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_Forum_Boards_AnnounceNum]  DEFAULT (0) FOR [AnnounceNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Boards_ForumPass]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Boards_ForumPass]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_AsphouseBBS_Boards_ForumPass]  DEFAULT ('') FOR [ForumPass]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Boards_HiddenFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Boards_HiddenFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_AsphouseBBS_Boards_HiddenFlag]  DEFAULT (0) FOR [HiddenFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Boards_LastAnnounceID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Boards_LastAnnounceID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_AsphouseBBS_Boards_LastAnnounceID]  DEFAULT (0) FOR [LastAnnounceID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Boards_LastAnnounceName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Boards_LastAnnounceName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_AsphouseBBS_Boards_LastAnnounceName]  DEFAULT ('') FOR [LastTopicName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Boards_MasterList]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Boards_MasterList]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_AsphouseBBS_Boards_MasterList]  DEFAULT ('') FOR [MasterList]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_Boards_BoardLimit]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_Boards_BoardLimit]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_AsphouseBBS_Boards_BoardLimit]  DEFAULT (0) FOR [BoardLimit]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_AllMinRootID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_AllMinRootID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_AllMinRootID]  DEFAULT (0) FOR [AllMinRootID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_AllMaxRootID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_AllMaxRootID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_AllMaxRootID]  DEFAULT (0) FOR [AllMaxRootID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_TodayAnnounce]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_TodayAnnounce]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_TodayAnnounce]  DEFAULT (0) FOR [TodayAnnounce]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_GoodNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_GoodNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_GoodNum]  DEFAULT (0) FOR [GoodNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_OrderID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_OrderID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_OrderID]  DEFAULT (0) FOR [OrderID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_BoardStyle]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_BoardStyle]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_BoardStyle]  DEFAULT (0) FOR [BoardStyle]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_StartTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_StartTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_StartTime]  DEFAULT (0) FOR [StartTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_EndTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_EndTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_EndTime]  DEFAULT (0) FOR [EndTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_BoardHead]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_BoardHead]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_BoardHead]  DEFAULT ('') FOR [BoardHead]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_BoardBottom]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_BoardBottom]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_BoardBottom]  DEFAULT ('') FOR [BoardBottom]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_BoardImgUrl]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_BoardImgUrl]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_BoardImgUrl]  DEFAULT ('') FOR [BoardImgUrl]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_BoardImgWidth]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_BoardImgWidth]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_BoardImgWidth]  DEFAULT (0) FOR [BoardImgWidth]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_BoardImgHeight]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_BoardImgHeight]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_BoardImgHeight]  DEFAULT (0) FOR [BoardImgHeight]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_ParentBoard]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_ParentBoard]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_ParentBoard]  DEFAULT (0) FOR [ParentBoard]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_LowerBoard]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_LowerBoard]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_LowerBoard]  DEFAULT ('') FOR [LowerBoard]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_ParentBoardStr]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_ParentBoardStr]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_ParentBoardStr]  DEFAULT ('') FOR [ParentBoardStr]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_BoardLevel]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_BoardLevel]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_BoardLevel]  DEFAULT (0) FOR [BoardLevel]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_TopicNum_All]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_TopicNum_All]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_TopicNum_All]  DEFAULT (0) FOR [TopicNum_All]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_AnnounceNum_All]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_AnnounceNum_All]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_AnnounceNum_All]  DEFAULT (0) FOR [AnnounceNum_All]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_TodayAnnounce_All]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_TodayAnnounce_All]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_TodayAnnounce_All]  DEFAULT (0) FOR [TodayAnnounce_All]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_GoodNum_All]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_GoodNum_All]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_GoodNum_All]  DEFAULT (0) FOR [GoodNum_All]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_OtherLimit]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_OtherLimit]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_OtherLimit]  DEFAULT (0) FOR [OtherLimit]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Boards_BoardIntro2]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Boards_BoardIntro2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Boards] ADD  CONSTRAINT [DF_LeadBBS_Boards_BoardIntro2]  DEFAULT ('') FOR [BoardIntro2]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_CollectAnc_AnnounceID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_CollectAnc_AnnounceID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_CollectAnc] ADD  CONSTRAINT [DF_LeadBBS_CollectAnc_AnnounceID]  DEFAULT (0) FOR [AnnounceID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_CollectAnc_UserID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_CollectAnc_UserID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_CollectAnc] ADD  CONSTRAINT [DF_LeadBBS_CollectAnc_UserID]  DEFAULT (0) FOR [UserID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Download_DownName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Download_DownName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Download] ADD  CONSTRAINT [DF_LeadBBS_Download_DownName]  DEFAULT ('') FOR [DownName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Download_Count]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Download_Count]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Download] ADD  CONSTRAINT [DF_LeadBBS_Download_Count]  DEFAULT (0) FOR [DownCount]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Download_FileUrl]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Download_FileUrl]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Download] ADD  CONSTRAINT [DF_LeadBBS_Download_FileUrl]  DEFAULT ('') FOR [FileUrl]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Download_LastIP]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Download_LastIP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Download] ADD  CONSTRAINT [DF_LeadBBS_Download_LastIP]  DEFAULT ('') FOR [LastIP]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_extend_ClassType]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_extend_ClassType]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_extend] ADD  CONSTRAINT [DF_LeadBBS_extend_ClassType]  DEFAULT ((0)) FOR [ClassType]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_extend_extendID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_extend_extendID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_extend] ADD  CONSTRAINT [DF_LeadBBS_extend_extendID]  DEFAULT ((0)) FOR [extendID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_extend_extent_title]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_extend_extent_title]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_extend] ADD  CONSTRAINT [DF_LeadBBS_extend_extent_title]  DEFAULT ('') FOR [extent_title]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_extend_extent_content]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_extend_extent_content]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_extend] ADD  CONSTRAINT [DF_LeadBBS_extend_extent_content]  DEFAULT ('') FOR [extent_content]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_extend_extent_num]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_extend_extent_num]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_extend] ADD  CONSTRAINT [DF_LeadBBS_extend_extent_num]  DEFAULT ((0)) FOR [extent_num]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_extend_extent_num2]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_extend_extent_num2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_extend] ADD  CONSTRAINT [DF_LeadBBS_extend_extent_num2]  DEFAULT ((0)) FOR [extent_num2]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_extend_extent_level]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_extend_extent_level]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_extend] ADD  CONSTRAINT [DF_LeadBBS_extend_extent_level]  DEFAULT ((0)) FOR [extent_level]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_ForbidIP_IPStart]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_ForbidIP_IPStart]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_ForbidIP] ADD  CONSTRAINT [DF_LeadBBS_ForbidIP_IPStart]  DEFAULT (0) FOR [IPStart]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_ForbidIP_IPEnd]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_ForbidIP_IPEnd]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_ForbidIP] ADD  CONSTRAINT [DF_LeadBBS_ForbidIP_IPEnd]  DEFAULT (0) FOR [IPEnd]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_ForbidIP_IPNumber]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_ForbidIP_IPNumber]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_ForbidIP] ADD  CONSTRAINT [DF_LeadBBS_ForbidIP_IPNumber]  DEFAULT (0) FOR [IPNumber]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_ForbidIP_ExpiresTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_ForbidIP_ExpiresTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_ForbidIP] ADD  CONSTRAINT [DF_LeadBBS_ForbidIP_ExpiresTime]  DEFAULT (0) FOR [ExpiresTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_ForbidIP_WhyString]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_ForbidIP_WhyString]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_ForbidIP] ADD  CONSTRAINT [DF_LeadBBS_ForbidIP_WhyString]  DEFAULT ('') FOR [WhyString]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_FriendUser_UserID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_FriendUser_UserID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_FriendUser] ADD  CONSTRAINT [DF_LeadBBS_FriendUser_UserID]  DEFAULT (0) FOR [UserID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_FriendUser_FriendUserID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_FriendUser_FriendUserID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_FriendUser] ADD  CONSTRAINT [DF_LeadBBS_FriendUser_FriendUserID]  DEFAULT (0) FOR [FriendUserID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_GoodAssort_OrderID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_GoodAssort_OrderID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_GoodAssort] ADD  CONSTRAINT [DF_LeadBBS_GoodAssort_OrderID]  DEFAULT (0) FOR [OrderID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_GoodAssort_BoardID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_GoodAssort_BoardID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_GoodAssort] ADD  CONSTRAINT [DF_LeadBBS_GoodAssort_BoardID]  DEFAULT (0) FOR [BoardID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_GoodAssort_AssortName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_GoodAssort_AssortName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_GoodAssort] ADD  CONSTRAINT [DF_LeadBBS_GoodAssort_AssortName]  DEFAULT ('') FOR [AssortName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_GoodAssort_GoodNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_GoodAssort_GoodNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_GoodAssort] ADD  CONSTRAINT [DF_LeadBBS_GoodAssort_GoodNum]  DEFAULT (0) FOR [GoodNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Asphouse_InfoBox_ToUser]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Asphouse_InfoBox_ToUser]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_InfoBox] ADD  CONSTRAINT [DF_Asphouse_InfoBox_ToUser]  DEFAULT ('') FOR [ToUser]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Asphouse_InfoBox_Content]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Asphouse_InfoBox_Content]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_InfoBox] ADD  CONSTRAINT [DF_Asphouse_InfoBox_Content]  DEFAULT ('') FOR [Content]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Asphouse_InfoBox_IP]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Asphouse_InfoBox_IP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_InfoBox] ADD  CONSTRAINT [DF_Asphouse_InfoBox_IP]  DEFAULT ('') FOR [IP]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Asphouse_InfoBox_SendTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Asphouse_InfoBox_SendTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_InfoBox] ADD  CONSTRAINT [DF_Asphouse_InfoBox_SendTime]  DEFAULT (0) FOR [SendTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_Asphouse_InfoBox_ReadFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_Asphouse_InfoBox_ReadFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_InfoBox] ADD  CONSTRAINT [DF_Asphouse_InfoBox_ReadFlag]  DEFAULT (0) FOR [ReadFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_InfoBox_ExpiresDate]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_InfoBox_ExpiresDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_InfoBox] ADD  CONSTRAINT [DF_LeadBBS_InfoBox_ExpiresDate]  DEFAULT (0) FOR [ExpiresDate]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Link_SiteName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Link_SiteName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Link] ADD  CONSTRAINT [DF_LeadBBS_Link_SiteName]  DEFAULT ('') FOR [SiteName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Link_SiteUrl]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Link_SiteUrl]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Link] ADD  CONSTRAINT [DF_LeadBBS_Link_SiteUrl]  DEFAULT ('') FOR [SiteUrl]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Link_LogoUrl]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Link_LogoUrl]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Link] ADD  CONSTRAINT [DF_LeadBBS_Link_LogoUrl]  DEFAULT ('') FOR [LogoUrl]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Link_OrderID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Link_OrderID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Link] ADD  CONSTRAINT [DF_LeadBBS_Link_OrderID]  DEFAULT (0) FOR [OrderID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Link_BreadFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Link_BreadFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Link] ADD  CONSTRAINT [DF_LeadBBS_Link_BreadFlag]  DEFAULT (0) FOR [BreakFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Link_LinkType]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Link_LinkType]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Link] ADD  CONSTRAINT [DF_LeadBBS_Link_LinkType]  DEFAULT (0) FOR [LinkType]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Log_LogType]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Log_LogType]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Log] ADD  CONSTRAINT [DF_LeadBBS_Log_LogType]  DEFAULT (0) FOR [LogType]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Log_LogTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Log_LogTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Log] ADD  CONSTRAINT [DF_LeadBBS_Log_LogTime]  DEFAULT (0) FOR [LogTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Log_LogInfo]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Log_LogInfo]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Log] ADD  CONSTRAINT [DF_LeadBBS_Log_LogInfo]  DEFAULT ('') FOR [LogInfo]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Log_UserName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Log_UserName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Log] ADD  CONSTRAINT [DF_LeadBBS_Log_UserName]  DEFAULT ('') FOR [UserName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Log_IP]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Log_IP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Log] ADD  CONSTRAINT [DF_LeadBBS_Log_IP]  DEFAULT ('') FOR [IP]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Log_BoardID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Log_BoardID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Log] ADD  CONSTRAINT [DF_LeadBBS_Log_BoardID]  DEFAULT (0) FOR [BoardID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_onlineUser_UserID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_onlineUser_UserID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_onlineUser] ADD  CONSTRAINT [DF_asphouse_onlineUser_UserID]  DEFAULT (0) FOR [UserID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_onlineUser_LastDoing]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_onlineUser_LastDoing]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_onlineUser] ADD  CONSTRAINT [DF_asphouse_onlineUser_LastDoing]  DEFAULT (0) FOR [LastDoingTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_onlineUser_AtBoardID_1]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_onlineUser_AtBoardID_1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_onlineUser] ADD  CONSTRAINT [DF_asphouse_onlineUser_AtBoardID_1]  DEFAULT (0) FOR [AtBoardID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_onlineUser_AtBoardID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_onlineUser_AtBoardID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_onlineUser] ADD  CONSTRAINT [DF_asphouse_onlineUser_AtBoardID]  DEFAULT (0) FOR [AtUrl]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_onlineUser_AtBoardName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_onlineUser_AtBoardName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_onlineUser] ADD  CONSTRAINT [DF_asphouse_onlineUser_AtBoardName]  DEFAULT ('') FOR [AtInfo]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_onlineUser_LastRndNumber]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_onlineUser_LastRndNumber]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_onlineUser] ADD  CONSTRAINT [DF_LeadBBS_onlineUser_LastRndNumber]  DEFAULT (0) FOR [LastRndNumber]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_onlineUser_Browser]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_onlineUser_Browser]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_onlineUser] ADD  CONSTRAINT [DF_LeadBBS_onlineUser_Browser]  DEFAULT ('') FOR [Browser]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_onlineUser_System]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_onlineUser_System]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_onlineUser] ADD  CONSTRAINT [DF_LeadBBS_onlineUser_System]  DEFAULT ('') FOR [System]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_onlineUser_UserName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_onlineUser_UserName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_onlineUser] ADD  CONSTRAINT [DF_LeadBBS_onlineUser_UserName]  DEFAULT ('') FOR [UserName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_onlineUser_HiddenFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_onlineUser_HiddenFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_onlineUser] ADD  CONSTRAINT [DF_LeadBBS_onlineUser_HiddenFlag]  DEFAULT (0) FOR [HiddenFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Opinion_UserID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Opinion_UserID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Opinion] ADD  CONSTRAINT [DF_LeadBBS_Opinion_UserID]  DEFAULT ('') FOR [UserName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Opinion_AnnounceID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Opinion_AnnounceID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Opinion] ADD  CONSTRAINT [DF_LeadBBS_Opinion_AnnounceID]  DEFAULT (0) FOR [AnnounceID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Opinion_Num]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Opinion_Num]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Opinion] ADD  CONSTRAINT [DF_LeadBBS_Opinion_Num]  DEFAULT (0) FOR [Num]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Opinion_NumType]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Opinion_NumType]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Opinion] ADD  CONSTRAINT [DF_LeadBBS_Opinion_NumType]  DEFAULT (0) FOR [NumType]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Opinion_Opinion]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Opinion_Opinion]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Opinion] ADD  CONSTRAINT [DF_LeadBBS_Opinion_Opinion]  DEFAULT ('') FOR [Opinion]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Opinion_IP]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Opinion_IP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Opinion] ADD  CONSTRAINT [DF_LeadBBS_Opinion_IP]  DEFAULT ('') FOR [IP]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Opinion_Ndatetime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Opinion_Ndatetime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Opinion] ADD  CONSTRAINT [DF_LeadBBS_Opinion_Ndatetime]  DEFAULT (0) FOR [Ndatetime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Plug_Card_CardID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Plug_Card_CardID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Plug_Card] ADD  CONSTRAINT [DF_LeadBBS_Plug_Card_CardID]  DEFAULT (0) FOR [CardID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Plug_Card_CardType]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Plug_Card_CardType]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Plug_Card] ADD  CONSTRAINT [DF_LeadBBS_Plug_Card_CardType]  DEFAULT (0) FOR [CardType]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Plug_Card_ExpiresDate]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Plug_Card_ExpiresDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Plug_Card] ADD  CONSTRAINT [DF_LeadBBS_Plug_Card_ExpiresDate]  DEFAULT (0) FOR [ExpiresDate]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Plug_Card_CardPoints]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Plug_Card_CardPoints]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Plug_Card] ADD  CONSTRAINT [DF_LeadBBS_Plug_Card_CardPoints]  DEFAULT (0) FOR [CardPoints]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_plug_class_Name]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_plug_class_Name]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_plug_class] ADD  CONSTRAINT [DF_LeadBBS_plug_class_Name]  DEFAULT ('') FOR [Name]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_plug_class_ParentID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_plug_class_ParentID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_plug_class] ADD  CONSTRAINT [DF_LeadBBS_plug_class_ParentID]  DEFAULT ((0)) FOR [ParentID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_plug_class_Num]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_plug_class_Num]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_plug_class] ADD  CONSTRAINT [DF_LeadBBS_plug_class_Num]  DEFAULT ((0)) FOR [Num]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_plug_class_remark]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_plug_class_remark]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_plug_class] ADD  CONSTRAINT [DF_LeadBBS_plug_class_remark]  DEFAULT ('') FOR [remark]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_plug_class_sortid]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_plug_class_sortid]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_plug_class] ADD  CONSTRAINT [DF_LeadBBS_plug_class_sortid]  DEFAULT ((0)) FOR [sortid]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Plugs_ClassID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Plugs_ClassID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Plugs] ADD  CONSTRAINT [DF_LeadBBS_Plugs_ClassID]  DEFAULT ((0)) FOR [ClassID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Plugs_width]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Plugs_width]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Plugs] ADD  CONSTRAINT [DF_LeadBBS_Plugs_width]  DEFAULT ((0)) FOR [width]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Plugs_height]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Plugs_height]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Plugs] ADD  CONSTRAINT [DF_LeadBBS_Plugs_height]  DEFAULT ((0)) FOR [height]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Plugs_intro]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Plugs_intro]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Plugs] ADD  CONSTRAINT [DF_LeadBBS_Plugs_intro]  DEFAULT ('') FOR [intro]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Plugs_sortid]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Plugs_sortid]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Plugs] ADD  CONSTRAINT [DF_LeadBBS_Plugs_sortid]  DEFAULT ((0)) FOR [sortid]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Plugs_plugkey]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Plugs_plugkey]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Plugs] ADD  CONSTRAINT [DF_LeadBBS_Plugs_plugkey]  DEFAULT ('') FOR [plugkey]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Plugs_createtime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Plugs_createtime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Plugs] ADD  CONSTRAINT [DF_LeadBBS_Plugs_createtime]  DEFAULT ((0)) FOR [createtime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Plugs_remark]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Plugs_remark]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Plugs] ADD  CONSTRAINT [DF_LeadBBS_Plugs_remark]  DEFAULT ('') FOR [remark]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Setup_RID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Setup_RID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Setup] ADD  CONSTRAINT [DF_LeadBBS_Setup_RID]  DEFAULT (0) FOR [RID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Setup_ClassNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Setup_ClassNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Setup] ADD  CONSTRAINT [DF_LeadBBS_Setup_ClassNum]  DEFAULT (0) FOR [ClassNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Setup_saveData]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Setup_saveData]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Setup] ADD  CONSTRAINT [DF_LeadBBS_Setup_saveData]  DEFAULT ('') FOR [saveData]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_SiteInfo_AllOnlineTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_SiteInfo_AllOnlineTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SiteInfo] ADD  CONSTRAINT [DF_asphouse_SiteInfo_AllOnlineTime]  DEFAULT (0) FOR [OnlineTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_SiteInfo_PageCount]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_SiteInfo_PageCount]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SiteInfo] ADD  CONSTRAINT [DF_asphouse_SiteInfo_PageCount]  DEFAULT (0) FOR [PageCount]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_SiteInfo_UserCount]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_SiteInfo_UserCount]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SiteInfo] ADD  CONSTRAINT [DF_LeadBBS_SiteInfo_UserCount]  DEFAULT (0) FOR [UserCount]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_SiteInfo_MaxOnline]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_SiteInfo_MaxOnline]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SiteInfo] ADD  CONSTRAINT [DF_LeadBBS_SiteInfo_MaxOnline]  DEFAULT (0) FOR [MaxOnline]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_SiteInfo_MaxolTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_SiteInfo_MaxolTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SiteInfo] ADD  CONSTRAINT [DF_LeadBBS_SiteInfo_MaxolTime]  DEFAULT (0) FOR [MaxolTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_SiteInfo_UploadNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_SiteInfo_UploadNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SiteInfo] ADD  CONSTRAINT [DF_LeadBBS_SiteInfo_UploadNum]  DEFAULT (0) FOR [UploadNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_SiteInfo_MaxAnnounce]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_SiteInfo_MaxAnnounce]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SiteInfo] ADD  CONSTRAINT [DF_LeadBBS_SiteInfo_MaxAnnounce]  DEFAULT (0) FOR [MaxAnnounce]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_SiteInfo_MaxAncTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_SiteInfo_MaxAncTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SiteInfo] ADD  CONSTRAINT [DF_LeadBBS_SiteInfo_MaxAncTime]  DEFAULT (0) FOR [MaxAncTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_SiteInfo_YesterdayAnc]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_SiteInfo_YesterdayAnc]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SiteInfo] ADD  CONSTRAINT [DF_LeadBBS_SiteInfo_YesterdayAnc]  DEFAULT (0) FOR [YesterdayAnc]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_SiteInfo_YesterDay]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_SiteInfo_YesterDay]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SiteInfo] ADD  CONSTRAINT [DF_LeadBBS_SiteInfo_YesterDay]  DEFAULT (0) FOR [YesterDay]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_SiteInfo_SavePoints]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_SiteInfo_SavePoints]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SiteInfo] ADD  CONSTRAINT [DF_LeadBBS_SiteInfo_SavePoints]  DEFAULT (0) FOR [SavePoints]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_SiteInfo_DBWrite]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_SiteInfo_DBWrite]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SiteInfo] ADD  CONSTRAINT [DF_LeadBBS_SiteInfo_DBWrite]  DEFAULT (0) FOR [DBWrite]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_SiteInfo_DBNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_SiteInfo_DBNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SiteInfo] ADD  CONSTRAINT [DF_LeadBBS_SiteInfo_DBNum]  DEFAULT (0) FOR [DBNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_SiteInfo_Version]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_SiteInfo_Version]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SiteInfo] ADD  CONSTRAINT [DF_LeadBBS_SiteInfo_Version]  DEFAULT ('') FOR [Version]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Skin_ScreenWidth]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Skin_ScreenWidth]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Skin] ADD  CONSTRAINT [DF_LeadBBS_Skin_ScreenWidth]  DEFAULT (770) FOR [ScreenWidth]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Skin_DisplayTopicLength]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Skin_DisplayTopicLength]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Skin] ADD  CONSTRAINT [DF_LeadBBS_Skin_DisplayTopicLength]  DEFAULT (56) FOR [DisplayTopicLength]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Skin_DefineImage]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Skin_DefineImage]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Skin] ADD  CONSTRAINT [DF_LeadBBS_Skin_DefineImage]  DEFAULT (0) FOR [DefineImage]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Skin_SiteHead]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Skin_SiteHead]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Skin] ADD  CONSTRAINT [DF_LeadBBS_Skin_SiteHead]  DEFAULT ('') FOR [SiteHeadString]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Skin_SiteBottom]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Skin_SiteBottom]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Skin] ADD  CONSTRAINT [DF_LeadBBS_Skin_SiteBottom]  DEFAULT ('') FOR [SiteBottomString]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Skin_TableHead]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Skin_TableHead]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Skin] ADD  CONSTRAINT [DF_LeadBBS_Skin_TableHead]  DEFAULT ('') FOR [TableHeadString]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Skin_TableBottom]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Skin_TableBottom]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Skin] ADD  CONSTRAINT [DF_LeadBBS_Skin_TableBottom]  DEFAULT ('') FOR [TableBottomString]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Skin_ShowBottomSure]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Skin_ShowBottomSure]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Skin] ADD  CONSTRAINT [DF_LeadBBS_Skin_ShowBottomSure]  DEFAULT (0) FOR [ShowBottomSure]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Skin_SmallTableHead]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Skin_SmallTableHead]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Skin] ADD  CONSTRAINT [DF_LeadBBS_Skin_SmallTableHead]  DEFAULT ('') FOR [SmallTableHead]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Skin_小局表格尾部代码]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Skin_小局表格尾部代码]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Skin] ADD  CONSTRAINT [DF_LeadBBS_Skin_小局表格尾部代码]  DEFAULT ('') FOR [SmallTableBottom]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Skin_TempletID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Skin_TempletID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Skin] ADD  CONSTRAINT [DF_LeadBBS_Skin_TempletID]  DEFAULT (0) FOR [TempletID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_BoardMaster_UserID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_BoardMaster_UserID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SpecialUser] ADD  CONSTRAINT [DF_LeadBBS_BoardMaster_UserID]  DEFAULT (0) FOR [UserID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_BoardMaster_UserName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_BoardMaster_UserName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SpecialUser] ADD  CONSTRAINT [DF_LeadBBS_BoardMaster_UserName]  DEFAULT ('') FOR [UserName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_BoardMaster_BoardID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_BoardMaster_BoardID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SpecialUser] ADD  CONSTRAINT [DF_LeadBBS_BoardMaster_BoardID]  DEFAULT (0) FOR [BoardID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_SpecialUser_ndatetime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_SpecialUser_ndatetime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SpecialUser] ADD  CONSTRAINT [DF_LeadBBS_SpecialUser_ndatetime]  DEFAULT (0) FOR [ndatetime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_SpecialUser_ExpiresTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_SpecialUser_ExpiresTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SpecialUser] ADD  CONSTRAINT [DF_LeadBBS_SpecialUser_ExpiresTime]  DEFAULT (0) FOR [ExpiresTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_SpecialUser_WhyString]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_SpecialUser_WhyString]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_SpecialUser] ADD  CONSTRAINT [DF_LeadBBS_SpecialUser_WhyString]  DEFAULT ('') FOR [WhyString]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Templet_TempletName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Templet_TempletName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Templet] ADD  CONSTRAINT [DF_LeadBBS_Templet_TempletName]  DEFAULT ('') FOR [TempletName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Templet_TempletFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Templet_TempletFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Templet] ADD  CONSTRAINT [DF_LeadBBS_Templet_TempletFlag]  DEFAULT (0) FOR [TempletFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Templet_Boards_Simple]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Templet_Boards_Simple]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Templet] ADD  CONSTRAINT [DF_LeadBBS_Templet_Boards_Simple]  DEFAULT ('') FOR [TempletString0]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Templet_Boards_Full]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Templet_Boards_Full]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Templet] ADD  CONSTRAINT [DF_LeadBBS_Templet_Boards_Full]  DEFAULT ('') FOR [TempletString1]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Templet_Board_Simple]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Templet_Board_Simple]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Templet] ADD  CONSTRAINT [DF_LeadBBS_Templet_Board_Simple]  DEFAULT ('') FOR [TempletString2]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Templet_Board_Full]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Templet_Board_Full]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Templet] ADD  CONSTRAINT [DF_LeadBBS_Templet_Board_Full]  DEFAULT ('') FOR [TempletString3]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Tmp_tmpstr]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Tmp_tmpstr]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Tmp] ADD  CONSTRAINT [DF_LeadBBS_Tmp_tmpstr]  DEFAULT ('') FOR [tmpstr]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_TopAnnounce_TopType]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_TopAnnounce_TopType]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_TopAnnounce] ADD  CONSTRAINT [DF_LeadBBS_TopAnnounce_TopType]  DEFAULT (0) FOR [TopType]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Upload_UserID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Upload_UserID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Upload] ADD  CONSTRAINT [DF_LeadBBS_Upload_UserID]  DEFAULT (0) FOR [UserID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Upload_PhotoDir]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Upload_PhotoDir]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Upload] ADD  CONSTRAINT [DF_LeadBBS_Upload_PhotoDir]  DEFAULT ('') FOR [PhotoDir]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Upload_SPhotoDir]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Upload_SPhotoDir]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Upload] ADD  CONSTRAINT [DF_LeadBBS_Upload_SPhotoDir]  DEFAULT ('') FOR [SPhotoDir]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Upload_NdateTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Upload_NdateTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Upload] ADD  CONSTRAINT [DF_LeadBBS_Upload_NdateTime]  DEFAULT (0) FOR [NdateTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Upload_FileType]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Upload_FileType]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Upload] ADD  CONSTRAINT [DF_LeadBBS_Upload_FileType]  DEFAULT (0) FOR [FileType]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Upload_FileName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Upload_FileName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Upload] ADD  CONSTRAINT [DF_LeadBBS_Upload_FileName]  DEFAULT ('') FOR [FileName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Upload_FileSize]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Upload_FileSize]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Upload] ADD  CONSTRAINT [DF_LeadBBS_Upload_FileSize]  DEFAULT (0) FOR [FileSize]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Upload_AnnounceID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Upload_AnnounceID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Upload] ADD  CONSTRAINT [DF_LeadBBS_Upload_AnnounceID]  DEFAULT (0) FOR [AnnounceID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Upload_BoardID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Upload_BoardID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Upload] ADD  CONSTRAINT [DF_LeadBBS_Upload_BoardID]  DEFAULT (0) FOR [BoardID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Upload_Info]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Upload_Info]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Upload] ADD  CONSTRAINT [DF_LeadBBS_Upload_Info]  DEFAULT ('') FOR [Info]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Upload_VisitIP]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Upload_VisitIP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Upload] ADD  CONSTRAINT [DF_LeadBBS_Upload_VisitIP]  DEFAULT ('') FOR [VisitIP]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_Upload_Hits]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_Upload_Hits]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_Upload] ADD  CONSTRAINT [DF_LeadBBS_Upload_Hits]  DEFAULT (0) FOR [Hits]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_sex]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_sex]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_sex]  DEFAULT ('密') FOR [Sex]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_Sessionid]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_Sessionid]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_Sessionid]  DEFAULT (0) FOR [Sessionid]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_online]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_online]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_online]  DEFAULT (0) FOR [Online]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_prevtime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_prevtime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_prevtime]  DEFAULT (0) FOR [Prevtime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_userphoto]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_userphoto]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_userphoto]  DEFAULT (1) FOR [Userphoto]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_IP]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_IP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_IP]  DEFAULT ('3u7s9_d9299Xls') FOR [IP]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_userlevel]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_userlevel]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_userlevel]  DEFAULT (0) FOR [UserLevel]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_Homepage]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_Homepage]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_Homepage]  DEFAULT (' ') FOR [Homepage]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_Underwrite]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_Underwrite]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_Underwrite]  DEFAULT ('') FOR [Underwrite]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_PrintUnderWrite]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_PrintUnderWrite]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_PrintUnderWrite]  DEFAULT ('') FOR [PrintUnderWrite]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_Points]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_Points]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_Points]  DEFAULT (0) FOR [Points]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_Officer]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_Officer]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_Officer]  DEFAULT ('0') FOR [Officer]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_Login_ip]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_Login_ip]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_Login_ip]  DEFAULT ('3u7s9_d9299Xls') FOR [Login_ip]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_Login_oknum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_Login_oknum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_Login_oknum]  DEFAULT (0) FOR [Login_oknum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_Login_falsenum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_Login_falsenum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_Login_falsenum]  DEFAULT (0) FOR [Login_falsenum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_Login_RightIP]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_Login_RightIP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_Login_RightIP]  DEFAULT ('3u7s9_d9299Xls') FOR [Login_RightIP]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_Onlinetime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_Onlinetime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_Onlinetime]  DEFAULT (0) FOR [OnlineTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_AnnounceNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_AnnounceNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_AnnounceNum]  DEFAULT (0) FOR [AnnounceNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_LastDoingTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_LastDoingTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_LastDoingTime]  DEFAULT (0) FOR [LastDoingTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_FaceUrl]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_FaceUrl]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_FaceUrl]  DEFAULT ('') FOR [FaceUrl]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_FaceWidth]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_FaceWidth]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_FaceWidth]  DEFAULT (0) FOR [FaceWidth]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_FaceHeight]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_FaceHeight]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_FaceHeight]  DEFAULT (0) FOR [FaceHeight]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_UserLimit]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_UserLimit]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_UserLimit]  DEFAULT (0) FOR [UserLimit]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_asphouse_User_ShowFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_asphouse_User_ShowFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_asphouse_User_ShowFlag]  DEFAULT (0) FOR [ShowFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_MessageFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_MessageFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_MessageFlag]  DEFAULT (0) FOR [MessageFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_NongLiBirth]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_NongLiBirth]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_NongLiBirth]  DEFAULT (0) FOR [NongLiBirth]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_AnnounceTopic]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_AnnounceTopic]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_AnnounceTopic]  DEFAULT (0) FOR [AnnounceTopic]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_精华数]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_精华数]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_精华数]  DEFAULT (0) FOR [AnnounceGood]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_UploadNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_UploadNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_UploadNum]  DEFAULT (0) FOR [UploadNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_CharmPoint]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_CharmPoint]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_CharmPoint]  DEFAULT (0) FOR [CharmPoint]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_CachetValue]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_CachetValue]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_CachetValue]  DEFAULT (0) FOR [CachetValue]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_UserTitle]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_UserTitle]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_UserTitle]  DEFAULT ('') FOR [UserTitle]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_NotSecret]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_NotSecret]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_NotSecret]  DEFAULT (0) FOR [NotSecret]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_Question]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_Question]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_Question]  DEFAULT ('') FOR [Question]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_Answer]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_Answer]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_Answer]  DEFAULT ('') FOR [Answer]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_LockIP]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_LockIP]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_LockIP]  DEFAULT ('') FOR [LockIP]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_LastWriteTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_LastWriteTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_LastWriteTime]  DEFAULT (19810303030303) FOR [LastWriteTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_ExtendFlag]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_ExtendFlag]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_ExtendFlag]  DEFAULT (0) FOR [ExtendFlag]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_IDCard]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_IDCard]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_IDCard]  DEFAULT (0) FOR [IDCard]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_MobileTel]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_MobileTel]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_MobileTel]  DEFAULT (0) FOR [MobileTel]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_Telephone]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_Telephone]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_Telephone]  DEFAULT ('') FOR [Telephone]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_TrueName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_TrueName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_TrueName]  DEFAULT ('') FOR [TrueName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_LastAnnounceID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_LastAnnounceID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_LastAnnounceID]  DEFAULT (0) FOR [LastAnnounceID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_AnnounceNum2]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_AnnounceNum2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_AnnounceNum2]  DEFAULT (0) FOR [AnnounceNum2]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_User_remark]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_User_remark]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_User] ADD  CONSTRAINT [DF_LeadBBS_User_remark]  DEFAULT ('') FOR [remark]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_UserFace_UserID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_UserFace_UserID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_UserFace] ADD  CONSTRAINT [DF_LeadBBS_UserFace_UserID]  DEFAULT (0) FOR [UserID]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_UserFace_PhotoDir]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_UserFace_PhotoDir]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_UserFace] ADD  CONSTRAINT [DF_LeadBBS_UserFace_PhotoDir]  DEFAULT ('') FOR [PhotoDir]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_UserFace_SPhotoDir]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_UserFace_SPhotoDir]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_UserFace] ADD  CONSTRAINT [DF_LeadBBS_UserFace_SPhotoDir]  DEFAULT ('') FOR [SPhotoDir]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_UserFace_NdateTime]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_UserFace_NdateTime]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_UserFace] ADD  CONSTRAINT [DF_LeadBBS_UserFace_NdateTime]  DEFAULT (0) FOR [NdateTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_LeadBBS_UserFace_FileType]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_LeadBBS_UserFace_FileType]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_UserFace] ADD  CONSTRAINT [DF_LeadBBS_UserFace_FileType]  DEFAULT (0) FOR [FileType]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_VoteItem_VoteType]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_VoteItem_VoteType]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_VoteItem] ADD  CONSTRAINT [DF_AsphouseBBS_VoteItem_VoteType]  DEFAULT (0) FOR [VoteType]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_VoteItem_VoteName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_VoteItem_VoteName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_VoteItem] ADD  CONSTRAINT [DF_AsphouseBBS_VoteItem_VoteName]  DEFAULT ('') FOR [VoteName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_VoteItem_ExpiresDay]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_VoteItem_ExpiresDay]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_VoteItem] ADD  CONSTRAINT [DF_AsphouseBBS_VoteItem_ExpiresDay]  DEFAULT (0) FOR [ExpiresTime]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_VoteItem_VoteNum]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_VoteItem_VoteNum]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_VoteItem] ADD  CONSTRAINT [DF_AsphouseBBS_VoteItem_VoteNum]  DEFAULT (0) FOR [VoteNum]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_VoteUser_UserName]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_VoteUser_UserName]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_VoteUser] ADD  CONSTRAINT [DF_AsphouseBBS_VoteUser_UserName]  DEFAULT ('') FOR [UserName]
END


END
GO
IF Not EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF_AsphouseBBS_VoteUser_AnnounceID]') AND type = 'D')
BEGIN
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_AsphouseBBS_VoteUser_AnnounceID]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[LeadBBS_VoteUser] ADD  CONSTRAINT [DF_AsphouseBBS_VoteUser_AnnounceID]  DEFAULT (0) FOR [AnnounceID]
END


END
GO
if not exists (select * from leadbbs_setup where RID=1002 and ClassNum=0)
begin
INSERT INTO leadbbs_setup(RID,ValueStr,ClassNum,saveData) VALUES (1002, '20140422004', 0, '内部版本号') 
end