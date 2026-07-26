function topic_img_geData()
{
	if(!$id("topic_imgUrlData"))return;
	if(!$id("topic_imgUrlLink"))return;
	var url = $id("topic_imgUrlData").innerHTML;
	ImgName = url.split(":::");
	topic_n = ImgName.length - 1;

	var lnk = $id("topic_imgUrlLink").innerText;
	ImgName_Open = lnk.split(":::");
	topic_n = ImgName_Open.length - 1 >topic_n?topic_n:ImgName_Open.length - 1;
	
	
	var title = $id("topic_imgTitleList").innerHTML;
	Img_Title = title.split(":::");
	topic_n = Img_Title.length - 1 >topic_n?topic_n:Img_Title.length - 1;
	
	var jumpString = "";
	for(var n = 0;n <= topic_n;n++)
	{
		if(n >= 3 && topic_n > 4)
		{
			jumpString+="<a href=\"javascript:;\" onclick=\"topic_selimg(" + topic_n + ")\" id=\"selimg" + topic_n + "\">.." + (topic_n+1) + "</a>";
			break;
		}
		jumpString+="<a href=\"javascript:;\" onclick=\"topic_selimg(" + n + ")\" id=\"selimg" + n + "\">" + (n+1) + "</a>";
	}
	$id("topic_imgSel").innerHTML = jumpString;
	if($id("topic_imgWidth"))topic_imgWidth = $id("topic_imgWidth").innerHTML;
	if($id("topic_imgHeight"))topic_imgHeight = $id("topic_imgHeight").innerHTML;
	topic_imgWidth = isNaN(topic_imgWidth)?parseInt(topic_imgWidth):topic_imgWidth=612;
	topic_imgHeight = isNaN(topic_imgHeight)?parseInt(topic_imgHeight):topic_imgHeight=171;
	topic_imgWidth=612;
	topic_imgHeight=171
}
function GetImageWidth(oImage)
{
	if(TmpImg.src.substring(TmpImg.src.length-oImage.length,TmpImg.src.length)!=oImage){TmpImg.src=oImage;return false;}
	if(TmpImg.complete==false){return(false)};
	return TmpImg.width;
}
function GetImageHeight(oImage)
{
	if(TmpImg.src.substring(TmpImg.src.length-oImage.length,TmpImg.src.length)!=oImage){TmpImg.src=oImage;return false;}
	if(TmpImg.complete==false)return(false);
	return TmpImg.height;
}

function topic_selimg(sel)
{
	//if(topic_exchange==1)return;
	clearTimeout(mytimeout);
	topic_playImg(sel)
}

function topic_playImg(sel,start)
{
	var oldindex = topic_index;
	if(sel==999){}
	else
	if(isUndef(sel))
	{
		if(playflag==0){clearTimeout(mytimeout);return;}
		if(topic_index==topic_n)
		{
		topic_index=0;
		}
		else
		{
			topic_index++;
		}
	}
	else
	{
	topic_index=sel;
	}
	if(sel!=999)
	{
		var w = GetImageWidth(ImgName[topic_index]),h = GetImageHeight(ImgName[topic_index]);
		if(w==false||h==false)
		{
			topic_index = oldindex;
			clearTimeout(mytimeout);
			mytimeout=setTimeout("topic_playImg(" + sel + ")",300);
			return;
		}
		if(Browser.is_ie){
			var img = $id('topic_IMG');
			img.style.filter="blendTrans(Duration=duration)";
			img.filters[0].apply();
			img.src=ImgName[topic_index];
			topic_IMG.filters[0].play();
			$id('topic_imgUrl2').href=$id('topic_imgUrl').href=ImgName_Open[topic_index];
		}
		else
		{
			topic_curDiv = (topic_curDiv==2)?1:2;
			var img = (topic_curDiv==2)?$id('topic_IMG2'):$id('topic_IMG');
			var OutDiv = (topic_curDiv==2)?$id('topic_div_1'):$id('topic_div_2');
			var InDiv = (topic_curDiv==2)?$id('topic_div_2'):$id('topic_div_1');
			img.src=ImgName[topic_index];
			topic_exchange = 1;
			$(OutDiv).fadeOut(300)
			$(InDiv).fadeIn(300)
			//setTimeout("layer_viewtimer('" + OutDiv.id + "',100,0,-10,50,'','1');",50);
			//setTimeout("layer_viewtimer2('" + InDiv.id + "',0,100,10,50,'topic_exchange=0;','1');",50);
			$id('topic_imgUrl2').href=$id('topic_imgUrl').href=ImgName_Open[topic_index];
		}
		if($id('selimg' + oldindex))$id('selimg' + oldindex).className='';
		if($id('selimg' + topic_index))$id('selimg' + topic_index).className='select';
		$id('topic_imgTitle').innerHTML = Img_Title[topic_index];
		if (w>topic_imgWidth&&(w/topic_imgWidth)>=(h/topic_imgHeight))
		{
			var oldVW = w,oldVH=h*(topic_imgWidth /oldVW);
			img.width=topic_imgWidth;
			img.height = oldVH;
		}
		if (h>topic_imgHeight&&(h/topic_imgHeight)>=(w/topic_imgWidth))
		{
			var oldVH = h,oldVW=w*(topic_imgHeight /oldVH);
			img.height=topic_imgHeight; img.width = oldVW;
		}
		if(w<=topic_imgWidth&&h<=topic_imgHeight)
		{
			img.height=h; img.width = w;
		}
		img.width=612
		img.height=171
	}
	//if(!sel || sel==999)
	//{
		clearTimeout(mytimeout);
		mytimeout=setTimeout("topic_playImg()",topic_time);
	//}
}

var topic_time = 5000,playflag=1;//设定的时间间隔
var topic_index;//目前显示的图片编号
var topic_n = -1;//总共的图片量
var duration = 3;//blendTrans滤镜使用的一个参数值，后面会有说明
var topic_imgWidth = 140
var topic_imgHeight = 105
var topic_imgstart = 1;
//图片集数组对象
　　function ImgArray(len)
　　{
　　　this.length=len;
　 }

var ImgName,ImgName_Open,Img_Title;

topic_index=-1;
var mytimeout;
var TmpImg=new Image(),topic_curDiv=1,topic_exchange=0;

function p_side_imgstart()
{
	topic_img_geData();
	if(topic_n >= 0)
	{
		topic_playImg();
		topic_imgstart = 0;
	}
}
p_side_imgstart();