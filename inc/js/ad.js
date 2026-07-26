function ad_start()
{
	var ad_select,ad_content;
	var bbsad_html = new Array();
	var ad_idArray = "ad_hometop|ad_homebottom|ad_boardtop|ad_boardbottom|ad_topictop|ad_topicbottom|bottom_ad".split("|");
	var adsync_data=[];
bbsad_html[0] = ""
adsync_data[0] = 0;
bbsad_html[1] = ""
adsync_data[1] = 0;
bbsad_html[2] = ""
adsync_data[2] = 0;
bbsad_html[3] = ""
adsync_data[3] = 0;
bbsad_html[4] = ""
adsync_data[4] = 0;
bbsad_html[5] = ""
adsync_data[5] = 0;
	if($id("bottom_ad"))
	bbsad_html[6] = $id("bottom_ad").innerHTML.replace(/<!--/,"").replace(/-->/,"");
	else
	bbsad_html[6] = "";
	$id('bottom_ad').innerHTML="";
	for(var i=0;i<=ad_idArray.length;i++)
	if($id(ad_idArray[i]))
	{
	ad_select = bbsad_html[i].split("------leadbbs-split--------");
	ad_content = ad_select[parseInt(Math.random()*ad_select.length)];
	if(adsync_data[i]==0)
	$('#'+ad_idArray[i]).html(ad_content);
	else
	$('#'+ad_idArray[i]).writeCapture().html(ad_content);
	if($.trim($('#'+ad_idArray[i]).html())!="")$('#'+ad_idArray[i]).show();
	}
	}
	ad_start();
