LeadBBS 社区明星官方改进版 for LeadBBS 3.14

改进：

1. 风格完全兼容
2. 主要是速度上的提升，在海量数据下仍然不会产生超时
3. 免FSO后台设置明星功能
4. 可设置首页是否显示第一行，第二行，或者两者都显示或两者都不显示
5. 使用缓存加快插件速度

注意：

1.步骤一必须执行，否则此插件仍然非常消耗资源．
2.为免改动用户表，去除男女明星的支持(一般也不需要)
3.此插件改自gafc的修改版本
4.因此插件对数据库有所改动，是否安装，请慎重
  其中专业版本添加索引名 IX_LeadBBS_Announce_NDateTime2
  免费版本添加索引 NDateTime
5.建议：日发帖高的论坛及大型论坛不要使用此插件
6.此插件仅允许放置于首页位置，并放置于版面列表以下位置
7.Boards.asp文件不要上传至插件目录，此文件为已经修改好的首页文件

关于删除已经安装的社区明星插件：

  1.以后如要删除此插件，需要删除数据库相应索引，专业版本可执行：
    DROP INDEX LeadBBS_Announce.IX_LeadBBS_Announce_NDateTime2
    免费版本需要执行：
    DROP INDEX NDateTime on LeadBBS_Announce
  2.恢复Boards.asp及删除plug-inc/HomePageStar目录

必须按以下办法进行安装，同时提免费版本及专业版本的安装办法：

======================================================================================
                                  免费版本用户安装：
======================================================================================

1.使用管理员登陆后台，在直接执行SQL语句中执行
CREATE INDEX NDateTime ON LeadBBS_Announce(NDateTime)

2.在论坛目录下面建立plug-ins (如果不存在此目录的话)

3.在plug-ins目录下面建立目录HomePageStar (如果不存在此目录的话)

4.将源代码目录文件全部上传至plug-ins/HomePageStar目录下面

5.打开Boards.asp文件，找到

%>
	<table width="<%=DEF_BBS_ScreenWidth%>" border="0" cellspacing="0" cellpadding="0" align="center">
	<tr align=center>
		<td>
<!-- #include file=inc/IncHtm/BoardLink.asp -->

修改为

LeadBBSHomePageStar
%>
	<table width="<%=DEF_BBS_ScreenWidth%>" border="0" cellspacing="0" cellpadding="0" align="center">
	<tr align=center>
		<td>
<!-- #include file=inc/IncHtm/BoardLink.asp -->

在Boards.asp程序中找到

<!-- #include file=inc/Board_Popfun.asp -->

在其下面加入

<!--#include file="plug-ins/HomePageStar/HomePageStar.asp"-->

======================================================================================
                                  专业版本用户安装：
======================================================================================

1.使用管理员登陆后台，在直接执行SQL语句中执行
CREATE INDEX IX_LeadBBS_Announce_NDateTime2 ON LeadBBS_Announce(NDateTime)

2.在论坛目录下面建立plug-ins (如果不存在此目录的话)

3.在plug-ins目录下面建立目录HomePageStar (如果不存在此目录的话)

4.将源代码目录文件全部上传至plug-ins/HomePageStar目录下面

5.打开Boards.asp文件，找到

%>
	<table width="<%=DEF_BBS_ScreenWidth%>" border="0" cellspacing="0" cellpadding="0" align="center">
	<tr align=center>
		<td>
<!-- #include file=inc/IncHtm/BoardLink.asp -->

修改为

LeadBBSHomePageStar
%>
	<table width="<%=DEF_BBS_ScreenWidth%>" border="0" cellspacing="0" cellpadding="0" align="center">
	<tr align=center>
		<td>
<!-- #include file=inc/IncHtm/BoardLink.asp -->

在Boards.asp程序中找到

<!-- #include file=inc/Board_Popfun.asp -->

在其下面加入

<!--#include file="plug-ins/HomePageStar/HomePageStar.asp"-->