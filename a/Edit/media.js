
// 只允许输入数字
function IsDigit(evt){
	//var evt = window.event?window.event:evt,target=evt.srcElement||evt.target;
  return ((evt.keyCode >= 48) && (evt.keyCode <= 57));
}
// 去空格，left,right,all可选
function BaseTrim(str){
	  lIdx=0;rIdx=str.length;
	  if (BaseTrim.arguments.length==2)
	    act=BaseTrim.arguments[1].toLowerCase()
	  else
	    act="all"
      for(var i=0;i<str.length;i++){
	  	thelStr=str.substring(lIdx,lIdx+1)
		therStr=str.substring(rIdx,rIdx-1)
        if ((act=="all" || act=="left") && thelStr==" "){
			lIdx++
        }
        if ((act=="all" || act=="right") && therStr==" "){
			rIdx--
        }
      }
	  str=str.slice(lIdx,rIdx)
      return str
}

// 转为数字型，并无前导0，不能转则返回""
function ToInt(str){
	str=BaseTrim(str);
	if (str!=""){
		var sTemp=parseFloat(str);
		if (isNaN(sTemp)){
			str="";
		}else{
			str=sTemp;
		}
	}
	return str;
}

function editor_Initmedia()
{
	$id("media_d_fromurl").value = "http://";
	$id("media_d_width").value = "";
	$id("media_d_height").value = "";
}

// 点确定时执行
function editor_mediasubmit(){
	// 数字型输入的有效性
	$id("media_d_width").value=ToInt($id("media_d_width").value);
	$id("media_d_height").value=ToInt($id("media_d_height").value);
	
	
	var sFromUrl = $id("media_d_fromurl").value;
	var sWidth = $id("media_d_width").value;
	var sHeight = $id("media_d_height").value;
	var sType = $id("media_d_type").options[$id("media_d_type").selectedIndex].value;
	var sAutoplay = $id("d_autoplay").checked?"1":"";

	if((sType=="FLV" || sType=="MP") && (sWidth=="" || sHeight==""))
	{
		alert("播放FLV或Media文件必须指定长和宽");
		return false;
	}

	if(sFromUrl!="http://" && sFromUrl!="")
	{
		var sHTML = "[" + sType
		if (sWidth!="" && sHeight!="")
		{
			sHTML+="="+sWidth+","+sHeight+"]";
		}
		else{sHTML+="]";}
		sHTML+=sFromUrl;
		var mName = $id("media_d_name").value.replace(/\|/gi,"%7C");
		var preview = $id("media_d_preview").value.replace(/\|/gi,"%7C");
		if(mName!="")
		{
				sHTML+="|"+mName;
				if(preview!="")sHTML+="|"+preview;
		}
		else
		{
				if(preview!="")
				{
						sHTML+="||"+preview;
				}
		}
		if(sAutoplay=="1")
		{
			if(mName=="")
			sAutoplay="|"+sAutoplay;
			if(preview=="")
			sAutoplay="|"+sAutoplay;
			sAutoplay="|"+sAutoplay;
			sHTML+=sAutoplay;
		}
		sHTML+="[/" + sType + "]";
	
		addcontent(1,sHTML);
		return true;
	}
	else
		{alert("请输入媒体地址");return false;}
}