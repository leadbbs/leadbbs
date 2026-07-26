
	var p_url,p_para,p_command,p_type;
	
	function p_once(id,noconfm)
	{
		var tstr = p_para;
		if(!isUndef(id))tstr+=id;
		if(noconfm==1)
		getAJAX(p_url,tstr,p_command,p_type);
		else
		{
			if (confirm("\u786e\u5b9a\u64cd\u4f5c\u6b64\u8bb0\u5f55\u5417\uff1f"))
			getAJAX(p_url,tstr,p_command,p_type);
		}
	}
	
	function p_getselected()
	{
		var id="";
		var n = 100;
		for(var i=0;i<=n;i++)
		{
			if($id("ids" + i))
			{
				if($id("ids" + i).checked)
				{
					if(id=="")
					id=$id("ids" + i).value;
					else
					id+=","+$id("ids" + i).value;
				}
			}
		}
		return(id);
	}

	function pchoose(s,noconfm)
	{
		var id=p_getselected();
		if(id=="")
		{
			alert("\u60a8\u672a\u9009\u62e9\u4efb\u4f55\u8bb0\u5f55\u3002");
			return;
		}

		var tstr = p_para;
		tstr+=id;
		if(!isUndef(s))tstr+=s;
		if(noconfm==1)
		getAJAX(p_url,tstr,p_command,p_type);
		else
		{	if (confirm('\u786e\u5b9a\u6279\u91cf\u64cd\u4f5c\u6240\u9009\u7684\u8bb0\u5f55\u5417\uff1f'))
			getAJAX(p_url,tstr,p_command,p_type);
		}
        }
	function achoose(tp)
	{
		var tp;
		if($id('selmsg').checked)
		tp=0;
		else
		tp=1;
		var n = 100;
		if(tp==1)		
		for(i=0;i<=n;i++)
		{
			if($id("ids" + i))
			{
				if($id("ids" + i).checked)
				{
				$id("ids" + i).checked = ""
				}
			}
		}
		else
		for(i=0;i<=n;i++)
		{
			if($id("ids" + i))
			{
				if(!$id("ids" + i).checked)
				{
				$id("ids" + i).checked = "checked"
				}
			}
		}
		if($id('layer_selectnum'))$id('layer_selectnum').innerHTML=p_getnum();
        }
        
        function p_getnum()
        {
		var n = 100,p_count=0;	
		for(i=0;i<=n;i++)
		{
			if($id("ids" + i))
			{
				if($id("ids" + i).checked)p_count++;
			}
		}
		return(p_count);
	}