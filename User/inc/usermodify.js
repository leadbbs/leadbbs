	function user_setface(newText)
	{
		$id("LeadBBSFm").Form_userphoto.value=newText;
		$id("faceimg").src=user_DEF_BBS_HomeUrl + 'images/face/'+newText+'.gif'
		layer_hidelayer($id('anc_delbody'));
	}
	ValidationPassed = true;
	function isnum(str)
	{
		rset="";
		for(i=0;i<str.length;i++)
		{
			if(str.charAt(i)>="0" && str.charAt(i)<="9")
			{
			}
			else
			{
				return 0;
			}
		}
		return 1;
	}

	function changeface()
	{
		var temp;
		temp=$id("LeadBBSFm").Form_userphoto.value;
		if (temp!="" && isnum(temp)==1 && temp.length==4)
		{
			if (temp > 0 && temp <= user_DEF_faceMaxNum)
			{
				$id("faceimg").src=user_DEF_BBS_HomeUrl + 'images/face/'+temp+'.gif';
			}
			else
			{
				alert("错误!此图像代号不存在!");
				$id("faceimg").src=user_DEF_BBS_HomeUrl + 'images/blank.gif';
				$id("LeadBBSFm").Form_userphoto.value='';
				ValidationPassed = false;
			}
		}
		else
		{
			alert("错误!此图像代号不存在!\n图像代号必须是4位数" + (user_DEF_faceMaxNum.toString().length>4?"或以上":"") + ",比如 0001 ,最大为" + user_DEF_faceMaxNum);
			$id("faceimg").src=user_DEF_BBS_HomeUrl+'images/blank.gif';
			$id("LeadBBSFm").Form_userphoto.value='';
			ValidationPassed = false;
		}
	}
	function changeface2()
	{
		var temp,obj;
		obj=$id("LeadBBSFm");
		if(obj.Form_FaceWidth.value!="")
		{
			if (! isnum(obj.Form_FaceWidth.value))
			{
				obj.Form_FaceWidth.value = 120;
				return;
			}
			else
			{
				if(obj.Form_FaceWidth.value<20 || obj.Form_FaceWidth.value>user_DEF_AllFaceMaxWidth)
				{
					obj.Form_FaceWidth.value = 120;
					return;
				}
			}
		}

		if(obj.Form_FaceHeight.value!="")
		{
			if (! isnum(obj.Form_FaceHeight.value))
			{
				obj.Form_FaceHeight.value = 120;
				return;
			}
			else
			{
				if(obj.Form_FaceHeight.value<20 || obj.Form_FaceHeight.value>user_DEF_AllFaceMaxWidth*2)
				{
					obj.Form_FaceHeight.value = 120;
					return;
				}
			}
		}

		temp=$id("LeadBBSFm").Form_FaceUrl.value;
		if (temp!="")
		{
			$id("faceimg").src=temp;
			$id("faceimg").width=obj.Form_FaceWidth.value;
			$id("faceimg").height=obj.Form_FaceHeight.value;
		}
	}

	function form_onsubmit(obj)
	{
		if(obj.file)
		{
			if(obj.upload_step&&obj.upload_step.value!=""){}
		else
			{$('#file').attr("disabled",true);}
		}
		if(obj.oldpass&&obj.oldpass.value=="")
		{
			alert("必须填写旧的密码!\n");
			ValidationPassed = false;
			obj.oldpass.focus();
			return;
		}

		if(obj.Form_password1&&obj.Form_password1.value!=obj.Form_password2.value)
		{
			alert("你的两次密码输入不相同！\n");
			ValidationPassed = false;
			obj.Form_password1.focus();
			return;
		}

		if(obj.Form_icq&&obj.Form_icq.value!="")
		{
			if (! isnum(obj.Form_icq.value))
			{
				alert("喂,你填入了ICQ框中填入了东西,但你的ICQ号码怎么不是数字！\n");
				ValidationPassed = false;
				obj.Form_icq.focus();
				return;
			}
		}

		if(obj.Form_oicq&&obj.Form_oicq.value!="")
		{
			if (! isnum(obj.Form_oicq.value))
			{
				alert("喂,你填入了ＱＱ框中填入了东西,但你的ＱＱ号码怎么不是数字?\n");
				ValidationPassed = false;
				obj.Form_oicq.focus();
				return;
			}
		}

		if(obj.Form_byear&&obj.Form_byear.value!="")
		{
			if (! isnum(obj.Form_byear.value))
			{
				alert("喂,你填入了你的出生年,但你的年份怎么不是数字！\n");
				ValidationPassed = false;
				obj.Form_byear.focus();
				return;
			}
		}

		if(obj.Form_bmonth&&obj.Form_bmonth.value!="")
		{
			if (! isnum(obj.Form_bmonth.value))
			{
				alert("喂,你填入了你的出生月,但你的月份怎么不是数字！\n");
				ValidationPassed = false;
				obj.Form_bmonth.focus();
				return;
			}
		}

		if(obj.Form_bday&&obj.Form_bday.value!="")
		{
			if (! isnum(obj.Form_bday.value))
			{
				alert("喂,你填入了你的出生日,但你的出生日怎么不是数字！\n");
				ValidationPassed = false;
				obj.Form_bday.focus();
				return;
			}
		}

		if(obj.Form_userphoto&&obj.Form_userphoto.value!="")
		{
			if (obj.Form_bday&&! isnum(obj.Form_bday.value))
			{
				alert("用户图像,只能是0001-0318之间的数字！\n");
				ValidationPassed = false;
				obj.Form_bday.focus();
				return;
			}
		}
		
		if(obj.Form_Underwrite&&obj.Form_Underwrite.value.length>255)
		{
			alert("用户签名内容要小于255个字符!\n");
			ValidationPassed = false;
			obj.Form_Underwrite.focus();
			return;
		}

		if(user_DEF_AllDefineFace!=0 && user_DEF_AllDefineFace != 2)
		{
			if(obj.Form_FaceWidth&&obj.Form_FaceWidth.value!="")
			{
				if (! isnum(obj.Form_FaceWidth.value))
				{
					alert("自定义头像宽度必须是数字！\n");
					ValidationPassed = false;
					obj.Form_FaceWidth.focus();
					return;
				}
				else
				{
					if(obj.Form_FaceWidth.value<20 || obj.Form_FaceWidth.value>user_DEF_AllFaceMaxWidth)
					{
						alert("自定义头像宽度必须在20-" + user_DEF_AllFaceMaxWidth + "之间！\n");
						ValidationPassed = false;
						obj.Form_FaceWidth.focus();
						return;
					}
				}
			}
	
			if(obj.Form_FaceHeight&&obj.Form_FaceHeight.value!="")
			{
				if (! isnum(obj.Form_FaceHeight.value))
				{
					alert("自定义头像高度必须是数字！\n");
					ValidationPassed = false;
					obj.Form_FaceHeight.focus();
					return;
				}
				else
				{
					if(obj.Form_FaceHeight.value<20 || obj.Form_FaceHeight.value>user_DEF_AllFaceMaxWidth*2)
					{
						alert("自定义头像高度必须在20-" + user_DEF_AllFaceMaxWidth*2 + "之间！\n");
						ValidationPassed = false;
						obj.Form_FaceHeight.focus();
						return;
					}
				}
			}
		}
		
		ValidationPassed = true;
		return true;
	}

	function submitonce(theform)
	{
		if(ValidationPassed == false)return;
		submit_disable(theform);
	}

	function reg_checkinfo(item,str)
	{
		if(str.replace(/(^\s*)|(\s*$)/g,"")==""||str=="")
		{
			$id("reg_check_" + item).innerHTML="<span class=redfont>此项必须填写。</span>"
			return;
		}
		getAJAX(user_DEF_RegisterFile,"checkflag=1&checkitem=" + item + "&checkvalue=" + escape(str),"reg_check_" + item);
	}