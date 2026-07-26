
var C_IOfun,C_Level=0,c_GetDelay=10000,c_reset=0;

function C_IO(ur,lb,id)
{
	
	function processAJAX(lb)
	{
		if (HR.readyState == 4)
		{
			if (HR.status == 200)
			{
				if(HR.responseText=="busy")
				{
					//addMessage("2","<b>注意: </b>请求过频，此窗口已暂停处理，若开启多窗口，请关闭其它窗口再<a href=# onclick=\"top.window.location.reload();\" >[刷新].</a>");
					window.clearTimeout(C_IOfun);
					return;
				}
				C_IO_processor(HR.responseText);
			}
			else
			{
				window.clearTimeout(C_IOfun);
				return;
				//document.getElementById(lb).innerHTML="<p>网页错误: " + HR.statusText +"<\/p>";
			}
			delete HR ; 
			HR=null;
			if(Browser.is_ie)CollectGarbage;
		}
	}
try
	{
	C_Level += 1;
	delete HR ;
	var HR = getHttp();
	HR.onreadystatechange = function() {processAJAX(lb);};
	HR.open("POST", c_homeurl + "Chat_IO_pub.asp" , true);
	HR.setRequestHeader("Content-Type","application/x-www-form-urlencoded;charset=utf-8");
	HR.send("user=" + c_User);

	window.clearTimeout(C_IOfun);
	if(C_Level<2)C_IOfun = window.setTimeout(C_IO,c_GetDelay);
	C_Level -= 1;
	}
	catch(e)
	{
		window.clearTimeout(C_IOfun);
	}
}

function C_IO_processor(str)
{
	var n,tmp1,tmp = str.split("\n"); 
	for(n=0;n<tmp.length;n++)
	{
		tmp1 = tmp[n].indexOf(" ");
		if(tmp1>-1)
		{
			c=tmp[n].substring(0,tmp1)
			tmp[n]=tmp[n].substring(tmp1+1,tmp[n].length)
			addMessage(c + "",tmp[n]);
		}
	}
}

function addMessage(pos,mes)
{
	if(c_reset==1)return;
	var c,tp="";
	mes = mes.replace(/\n/g,"");
	mes = mes.replace(/\r/g,"");
	switch(pos)
	{
		case "1":
			tp = "c_pub_mes";
			break;
		case "9":
			tp = "";
			switch(mes)
			{
				case "stop":
						window.clearTimeout(C_IOfun);
						break;
				case "guest":
						window.clearTimeout(C_IOfun);
						break;
				case "reset":
						window.clearTimeout(C_IOfun);
						c_reset = 1;
						break;
				case "mess":
						tp = "c_pub_mes";
						$id(tp+"_txt").innerHTML = "您有新的消息";
						$id(tp).href = c_home + "User/MyInfoBox.asp";
						$id(tp).style.display = "";
						c_infoflag = 1;
						tp = "";
						break;
				case "none":
						tp = "c_pub_mes";
						if(c_infoflag==1)
						{
							$id(tp+"_txt").innerHTML = "您有新的消息";
							$id(tp).href = c_home + "User/MyInfoBox.asp";
							$id(tp).style.display = "";
						}
						else
						{
							//$id(tp).style.display = "none";
							$id(tp+"_txt").innerHTML = "收件箱";
						}
						tp = "";
						break;
				case "null":
						tp = "c_pub_mes";
						//$id(tp).style.display = "none";
						$id(tp+"_txt").innerHTML = "收件箱";
						c_infoflag = 0;
						tp = "";
						break;
			}
			break;
	}
	if(tp!="")
	{
		$id(tp+"_txt").innerHTML = mes;
		$id(tp).href = c_homeurl + "?c=2";
		$id(tp).style.display = "";
	}
}

function getHttp()
{
	var oT = false;
	try
	{
		oT=new XMLHttpRequest;
	}
	catch(e)
	{
		try
		{
			oT=new ActiveXObject("MSXML2.XMLHTTP");
		}
		catch(e2)
		{
			try
			{
				oT=new ActiveXObject("Microsoft.XMLHTTP");
			}
			catch(e3)
			{
				oT=false;
			}
		}
	}
	return(oT);
}
C_IOfun = window.setTimeout(C_IO,c_GetDelay);