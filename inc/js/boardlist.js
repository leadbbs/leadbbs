LD.blist = {
	a:function(){alert("blist")},
	assort_disable:function(s)
	{
		var obj = $id("b_assort_" + s);
		if(obj.style.display=='none')
		{
			obj.style.display='block';
			$id('b_assort_img_'+s).className = "b_assort_close";
			this.memoryDisable(s,1);
		}
		else
		{
			obj.style.display='none';
			$id('b_assort_img_'+s).className = "b_assort_close_swap";
			this.memoryDisable(s,0);
		}
	},


	memoryDisable: function(s,tp)
	{
		var dis_assort = DEF_MasterCookies + "dis_assort"
		var dis_assortValue = LD.Cookie.Get(dis_assort);
		if(!tp)
		{
			if(dis_assortValue.indexOf("," + s + ",")==-1)
			{
				if(dis_assortValue=="")dis_assortValue=",";
				dis_assortValue += s + ",";
				LD.Cookie.Add(dis_assort,dis_assortValue)
			}
		}
		else
		{
			if(dis_assortValue.indexOf("," + s + ",")!=-1)
			{
				dis_assortValue = $replace(dis_assortValue,"," + s + ",",",");
				LD.Cookie.Add(dis_assort,dis_assortValue)
			}
		}
	},

	assort_click: function(s,tp,view)
	{
		var openName = DEF_MasterCookies + "openassort"
		var closeName = DEF_MasterCookies + "clsassort"
		var openValue = LD.Cookie.Get(openName);
		var closeValue = LD.Cookie.Get(closeName);
		if(tp)
		{
			if(openValue.indexOf("," + s + ",")==-1)
			{
				if(openValue=="")openValue=",";
				openValue += s + ",";
				LD.Cookie.Add(openName,openValue);
			}
			if(closeValue.indexOf("," + s + ",")!=-1)
			{
				closeValue = $replace(closeValue,"," + s + ",",",");
				LD.Cookie.Add(closeName,closeValue);
			}
		}
		else
		{
			if(closeValue.indexOf("," + s + ",")==-1)
			{
				if(closeValue=="")closeValue=",";
				closeValue += s + ",";
				LD.Cookie.Add(closeName,closeValue);
			}
			if(openValue.indexOf("," + s + ",")!=-1)
			{
				openValue = $replace(openValue,"," + s + ",",",");
				LD.Cookie.Add(openName,openValue);
			}
		}
		if(view&&view!="none")
		{
			var obj = $id("b_assort_" + s);
			if(obj.style.display=='none')
			{
				obj.style.display='block';
				$id('b_assort_img_'+s).className = "b_assort_close";
			}
			else
			{
				obj.style.display='none';
				$id('b_assort_img_'+s).className = "b_assort_close_swap";
			}
		}
		else
		{
			if(view!="none")document.location.reload();
		}
	}
};
