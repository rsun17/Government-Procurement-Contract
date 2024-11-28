//date, 金额，采购方式，地点
//中央财政or地方财政，所属行业（不同threshold）, 采购type（货物，服务，工程）

********************************************************************************************
**Prepare Data
**Input: 
**Output: 
**Date:
********************************************************************************************

import excel "政府采购合同公告数据_python_edited.xlsx", sheet("Sheet1") firstrow clear

recast strL 合同名称 采购方式 采购人 采购人地址 详情链接 供应商 供应商地址 主要标的名称 规格型号或服务要求 主要标的数量 主要标的单价 所属地域 所属行业 代理机构 具体名称


/*
histogram 合同金额, bin(10) frequency
tab 合同金额 if 合同金额>10e+12   //value too large to be true
drop if 合同金额>10e+12 & 合同金额!=.
sum 合同金额
tab 合同金额 if 合同金额<0
drop if 合同金额<0
*/


 

***Comments from Xiaoxue
******Before cleaning individual variables, should try to extract information that are misplaced

foreach x in 主要标的名称 项目编号 合同编号 采购方式{
	replace 合同签订日期= date(substr(`x',strpos(`x',"七、合同签订日期")+27,10),"YMD",2050) if 合同签订日期==. &strpos(`x',"七、合同签订日期")!=0
	replace 合同公告日期= date(substr(`x',strpos(`x',"八、合同公告日期")+27,10),"YMD",2050) if 合同公告日期==. &strpos(`x',"八、合同公告日期")!=0
	}

foreach x in 合同编号 主要标的名称 项目编号{
	replace 采购方式= substr(`x',strpos(`x',"采购方式：")+15,15) if 采购方式=="" & strpos(`x',"采购方式：")!=0 &substr(`x',strpos(`x',"采购方式：")+15,3)!="七"
	}

g 合同金额1=""
foreach x in 合同编号 主要标的名称 项目编号{
	replace 合同金额1= substr(`x',strpos(`x',"合同金额：")+15,.) if 合同金额==. & strpos(`x',"合同金额")!=0
	}
drop if substr(合同金额1, 1, 12) == "履约期限"
replace 合同金额1= substr(合同金额1, 1, strpos(合同金额1,"万元")-1) if strpos(合同金额1,"万元")!=0
destring 合同金额1, replace
replace 合同金额1=合同金额1*10000
replace 合同金额 = 合同金额1 if 合同金额==. 
drop 合同金额1


//cleaning error in 采购方式
*** think of most efficient ways before correcting one by one

replace 采购方式=substr(采购方式, 1,12) if substr(采购方式, 1,6)=="公开"|substr(采购方式, 1,6)=="协议"
replace 采购方式=substr(采购方式, 1,15) if substr(采购方式, 1,6)=="竞争"
replace 采购方式 = "竞争性磋商" if (substr(合同编号, 1,13)=="HBLC-2020-075" & substr(合同名称, 1,6)!="应急")|substr(合同编号, 1,12)=="SGZC20210053"
replace 采购方式="公开招标" if substr(采购方式, 1,3)=="七"


//change date format
format 合同公告日期 %td
format 合同签订日期 %td
gen month_gonggao=month(合同公告日期)
gen yr_gonggao=year(合同公告日期)
gen month_qianding=month(合同签订日期)
gen yr_qianding=year(合同签订日期)



**************************** do not drop any observations before you finish cleaning


//keep observations after year 2019 or if 采购方式 is specified
/*
keep if yr_gonggao >= 2020 | 采购方式!=""  //会不会跟其他variable correlate
g 采购方式1 = 0
replace 采购方式1=1 if 采购方式!=""
reg 合同金额 采购方式1
*/


//cleaning and creating variable for purchasers' addresses

g code_prov = substr(项目编号,1,2)
g address_prov = substr(采购人地址,1,6)
g n_prov = substr(采购人,1,6)
g n_prov2 = substr(采购人,1,9)
g diyu_prov = substr(所属地域,1,6)
*/

**************it seems that code_prov is not a very accurate way to classify provinces
******as a general approach to cleaning: always double-check the changes you have made
******** for instance, you can inspect whether code_prov=="JH" includes only 辽宁 observations by the following codes
/*
gen a=1 if code_prov == "HB"
order a 项目编号 所属地域 采购人 采购人地址
sort a
drop a
*/
*** you can try using loop to write codes that involve repetition
**** for instance

g province = ""
foreach x in 所属地域 采购人 采购人地址{
	replace province= substr(`x', 1, 6) if province=="" &(substr(`x', 1, 6)=="北京"|substr(`x', 1, 6)=="上海"|substr(`x', 1, 6)=="天津"|substr(`x', 1, 6)=="重庆"|substr(`x', 1, 6)=="辽宁"|substr(`x', 1, 6)=="吉林" ///
		|substr(`x', 1, 6)=="河北"|substr(`x', 1, 6)=="云南"|substr(`x', 1, 6)=="四川"|substr(`x', 1, 6)=="宁夏"|substr(`x', 1, 6)=="安徽"|substr(`x', 1, 6)=="山东"|substr(`x', 1, 6)=="山西" ///
		|substr(`x', 1, 6)=="广东"|substr(`x', 1, 6)=="广西"|substr(`x', 1, 6)=="新疆"|substr(`x', 1, 6)=="江苏"|substr(`x', 1, 6)=="江西"|substr(`x', 1, 6)=="河南"|substr(`x', 1, 6)=="浙江" ///
		|substr(`x', 1, 6)=="海南"|substr(`x', 1, 6)=="湖北"|substr(`x', 1, 6)=="湖南"|substr(`x', 1, 6)=="澳门"|substr(`x', 1, 6)=="甘肃"|substr(`x', 1, 6)=="福建"|substr(`x', 1, 6)=="西藏" ///
		|substr(`x', 1, 6)=="贵州"|substr(`x', 1, 6)=="陕西"|substr(`x', 1, 6)=="青海"|substr(`x', 1, 6)=="香港")
	replace province = substr(`x', 1, 9) if province=="" &(substr(`x', 1, 9)=="黑龙江"|substr(`x', 1, 9)=="内蒙古")
}
foreach x in 采购人 采购人地址{
	replace province= "河北" if province=="" &(substr(`x', 1, 9)=="石家庄"|substr(`x', 1, 6)=="赵县" ///
		|substr(`x', 1, 6)=="邯郸"|substr(`x', 1, 6)=="承德"|substr(`x', 1, 9)=="秦皇岛"|substr(`x', 1, 6)=="丰宁"|substr(`x', 1, 6)=="唐山" ///
		|substr(`x', 1, 9)=="怀来县"|substr(`x', 1, 9)=="廊坊市"|substr(`x', 1, 6)=="保定"|substr(`x', 1, 6)=="邢台"|substr(`x', 1, 9)=="张家口"|substr(`x', 1, 6)=="沧州" ///
		|substr(`x', 1, 6)=="衡水")
}
foreach x in 采购人 采购人地址{
	replace province= "广东" if province=="" &(substr(`x', 1, 6)=="深圳"|substr(`x', 1, 6)=="广州"|substr(`x', 1, 6)=="韶关"|substr(`x', 1, 6)=="珠海"|substr(`x', 1, 6)=="汕头"|substr(`x', 1, 6)=="佛山" ///
		|substr(`x', 1, 6)=="江门"|substr(`x', 1, 6)=="湛江"|substr(`x', 1, 6)=="茂名"|substr(`x', 1, 6)=="肇庆"|substr(`x', 1, 6)=="惠州"|substr(`x', 1, 6)=="梅州"|substr(`x', 1, 6)=="汕尾" ///
		|substr(`x', 1, 6)=="河源"|substr(`x', 1, 6)=="阳江"|substr(`x', 1, 6)=="清远"|substr(`x', 1, 6)=="东莞"|substr(`x', 1, 6)=="中山"|substr(`x', 1, 6)=="潮州"|substr(`x', 1, 6)=="揭阳" ///
		|substr(`x', 1, 6)=="云浮")
}
foreach x in 采购人 采购人地址{
	replace province= "甘肃" if province=="" &(substr(`x', 1, 6)=="兰州"|substr(`x', 1, 9)=="嘉峪关"|substr(`x', 1, 6)=="金昌"|substr(`x', 1, 6)=="白银"|substr(`x', 1, 6)=="天水"|substr(`x', 1, 6)=="武威" ///
		|substr(`x', 1, 6)=="张掖"|substr(`x', 1, 6)=="平凉"|substr(`x', 1, 6)=="酒泉"|substr(`x', 1, 6)=="庆阳"|substr(`x', 1, 6)=="定西"|substr(`x', 1, 6)=="陇南"|substr(`x', 1, 6)=="临夏") 
}
foreach x in 采购人 采购人地址{
	replace province= "辽宁" if province=="" &(substr(`x', 1, 6)=="沈阳"|substr(`x', 1, 6)=="大连"|substr(`x', 1, 6)=="鞍山"|substr(`x', 1, 6)=="抚顺"|substr(`x', 1, 6)=="本溪"|substr(`x', 1, 6)=="丹东" ///
		|substr(`x', 1, 6)=="锦州"|substr(`x', 1, 6)=="营口"|substr(`x', 1, 6)=="阜新"|substr(`x', 1, 6)=="辽阳"|substr(`x', 1, 6)=="盘锦"|substr(`x', 1, 6)=="铁岭"|substr(`x', 1, 9)=="朝阳市" ///
		|substr(`x', 1, 9)=="葫芦岛")
}
foreach x in 采购人 采购人地址{
	replace province= "吉林" if province=="" &(substr(`x', 1, 6)=="长春"|substr(`x', 1, 9)=="四平市"|substr(`x', 1, 6)=="辽源"|substr(`x', 1, 6)=="通化"|substr(`x', 1, 9)=="白山市"|substr(`x', 1, 9)=="松原市" ///
		|substr(`x', 1, 9)=="白城市"|substr(`x', 1, 6)=="延边")
}
foreach x in 采购人 采购人地址{
	replace province= "云南" if province=="" &(substr(`x', 1, 6)=="昆明"|substr(`x', 1, 6)=="曲靖"|substr(`x', 1, 6)=="玉溪"|substr(`x', 1, 9)=="保山市"|substr(`x', 1, 9)=="昭通市"|substr(`x', 1, 9)=="丽江市" ///
		|substr(`x', 1, 6)=="普洱"|substr(`x', 1, 6)=="临沧"|substr(`x', 1, 6)=="楚雄"|substr(`x', 1, 6)=="红河"|substr(`x', 1, 6)=="文山"|substr(`x', 1, 12)=="西双版纳"|substr(`x', 1, 6)=="大理" ///
		|substr(`x', 1, 6)=="德宏"|substr(`x', 1, 6)=="怒江"|substr(`x', 1, 6)=="迪庆")
}
foreach x in 采购人 采购人地址{
	replace province= "四川" if province=="" &(substr(`x', 1, 6)=="成都"|substr(`x', 1, 6)=="自贡"|substr(`x', 1, 9)=="攀枝花"|substr(`x', 1, 6)=="泸州"|substr(`x', 1, 6)=="德阳"|substr(`x', 1, 6)=="绵阳" ///
		|substr(`x', 1, 9)=="广元市"|substr(`x', 1, 9)=="遂宁市"|substr(`x', 1, 9)=="内江市"|substr(`x', 1, 9)=="乐山市"|substr(`x', 1, 9)=="南充市"|substr(`x', 1, 9)=="眉山市"|substr(`x', 1, 9)=="宜宾市" ///
		|substr(`x', 1, 9)=="广安市"|substr(`x', 1, 9)=="达州市"|substr(`x', 1, 9)=="雅安市"|substr(`x', 1, 9)=="巴中市"|substr(`x', 1, 9)=="资阳市"|substr(`x', 1, 6)=="阿坝"|substr(`x', 1, 6)=="甘孜" ///
		|substr(`x', 1, 6)=="凉山")
}
foreach x in 采购人 采购人地址{
	replace province= "宁夏" if province=="" &(substr(`x', 1, 6)=="银川"|substr(`x', 1, 9)=="石嘴山"|substr(`x', 1, 9)=="吴忠市"|substr(`x', 1, 9)=="固原市"|substr(`x', 1, 9)=="中卫市")
}
foreach x in 采购人 采购人地址{
	replace province= "山东" if province=="" &(substr(`x', 1, 6)=="济南"|substr(`x', 1, 6)=="青岛"|substr(`x', 1, 9)=="淄博市"|substr(`x', 1, 9)=="枣庄市"|substr(`x', 1, 9)=="东营市"|substr(`x', 1, 9)=="烟台市" ///
		|substr(`x', 1, 9)=="潍坊市"|substr(`x', 1, 9)=="济宁市"|substr(`x', 1, 9)=="泰安市"|substr(`x', 1, 9)=="威海市"|substr(`x', 1, 9)=="日照市"|substr(`x', 1, 9)=="临沂市"|substr(`x', 1, 9)=="德州市" ///
		|substr(`x', 1, 9)=="聊城市"|substr(`x', 1, 9)=="滨州市"|substr(`x', 1, 9)=="菏泽市")
}
foreach x in 采购人 采购人地址{
	replace province= "山西" if province=="" &(substr(`x', 1, 6)=="太原"|substr(`x', 1, 9)=="大同市"|substr(`x', 1, 9)=="阳泉市"|substr(`x', 1, 9)=="长治市"|substr(`x', 1, 9)=="晋城市"|substr(`x', 1, 9)=="朔州市" ///
		|substr(`x', 1, 9)=="晋中市"|substr(`x', 1, 9)=="运城市"|substr(`x', 1, 9)=="忻州市"|substr(`x', 1, 9)=="临汾市"|substr(`x', 1, 9)=="吕梁市")
}
foreach x in 采购人 采购人地址{
	replace province= "广西" if province=="" &(substr(`x', 1, 6)=="南宁"|substr(`x', 1, 9)=="柳州市"|substr(`x', 1, 9)=="桂林市"|substr(`x', 1, 9)=="梧州市"|substr(`x', 1, 9)=="北海市"|substr(`x', 1, 9)=="防城港" ///
		|substr(`x', 1, 9)=="钦州市"|substr(`x', 1, 9)=="贵港市"|substr(`x', 1, 9)=="玉林市"|substr(`x', 1, 9)=="百色市"|substr(`x', 1, 9)=="贺州市"|substr(`x', 1, 9)=="河池市"|substr(`x', 1, 9)=="来宾市"|substr(`x', 1, 9)=="崇左市")
}
foreach x in 采购人 采购人地址{
	replace province= "新疆" if province=="" &(substr(`x', 1, 12)=="乌鲁木齐"|substr(`x', 1, 12)=="克拉玛依"|substr(`x', 1, 9)=="吐鲁番"|substr(`x', 1, 9)=="哈密市"|substr(`x', 1, 6)=="昌吉"|substr(`x', 1, 12)=="博尔塔拉" ///
		|substr(`x', 1, 12)=="巴音郭楞"|substr(`x', 1, 12)=="克孜勒苏"|substr(`x', 1, 6)=="伊犁"|substr(`x', 1, 9)=="阿克苏"|substr(`x', 1, 6)=="喀什"|substr(`x', 1, 6)=="和田"|substr(`x', 1, 6)=="塔城" ///
		|substr(`x', 1, 9)=="阿勒泰"|substr(`x', 1, 9)=="石河子"|substr(`x', 1, 9)=="阿拉尔"|substr(`x', 1, 12)=="图木舒克"|substr(`x', 1, 9)=="五家渠"|substr(`x', 1, 9)=="北屯市"|substr(`x', 1, 9)=="铁门关" ///
		|substr(`x', 1, 9)=="双河市"|substr(`x', 1, 12)=="可克达拉"|substr(`x', 1, 9)=="昆玉市"|substr(`x', 1, 9)=="胡杨河"|substr(`x', 1, 9)=="新星市")
}
foreach x in 采购人 采购人地址{
	replace province= "江苏" if province=="" &(substr(`x', 1, 6)=="南京"|substr(`x', 1, 6)=="无锡"|substr(`x', 1, 6)=="常州"|substr(`x', 1, 6)=="苏州"|substr(`x', 1, 6)=="南通"|substr(`x', 1, 9)=="连云港" ///
		|substr(`x', 1, 6)=="淮安"|substr(`x', 1, 6)=="盐城"|substr(`x', 1, 6)=="扬州"|substr(`x', 1, 6)=="镇江"|substr(`x', 1, 6)=="泰州"|substr(`x', 1, 6)=="宿迁")
}
foreach x in 采购人 采购人地址{
	replace province= "江西" if province=="" &(substr(`x', 1, 6)=="南昌"|substr(`x', 1, 9)=="景德镇"|substr(`x', 1, 9)=="萍乡市"|substr(`x', 1, 6)=="九江"|substr(`x', 1, 6)=="新余"|substr(`x', 1, 6)=="鹰潭" ///
		|substr(`x', 1, 6)=="赣州"|substr(`x', 1, 6)=="吉安"|substr(`x', 1, 6)=="宜春"|substr(`x', 1, 6)=="抚州"|substr(`x', 1, 6)=="上饶")
}
foreach x in 采购人 采购人地址{
	replace province= "河南" if province=="" &(substr(`x', 1, 6)=="郑州"|substr(`x', 1, 6)=="开封"|substr(`x', 1, 9)=="平顶山"|substr(`x', 1, 6)=="洛阳"|substr(`x', 1, 6)=="安阳"|substr(`x', 1, 6)=="鹤壁" ///
		|substr(`x', 1, 6)=="新乡"|substr(`x', 1, 6)=="焦作"|substr(`x', 1, 6)=="濮阳"|substr(`x', 1, 6)=="许昌"|substr(`x', 1, 6)=="漯河"|substr(`x', 1, 9)=="三门峡"|substr(`x', 1, 6)=="南阳" ///
		|substr(`x', 1, 6)=="商丘"|substr(`x', 1, 6)=="信阳"|substr(`x', 1, 6)=="周口"|substr(`x', 1, 9)=="驻马店"|substr(`x', 1, 9)=="济源市")
}
foreach x in 采购人 采购人地址{
	replace province= "浙江" if province=="" &(substr(`x', 1, 6)=="杭州"|substr(`x', 1, 6)=="宁波"|substr(`x', 1, 6)=="温州"|substr(`x', 1, 6)=="嘉兴"|substr(`x', 1, 6)=="湖州"|substr(`x', 1, 6)=="绍兴" ///
		|substr(`x', 1, 6)=="金华"|substr(`x', 1, 6)=="衢州"|substr(`x', 1, 6)=="舟山"|substr(`x', 1, 6)=="台州"|substr(`x', 1, 6)=="丽水")
}
foreach x in 采购人 采购人地址{
	replace province= "海南" if province=="" &(substr(`x', 1, 6)=="海口"|substr(`x', 1, 6)=="三亚"|substr(`x', 1, 6)=="三沙"|substr(`x', 1, 6)=="儋州"|substr(`x', 1, 9)=="五指山"|substr(`x', 1, 6)=="琼海" ///
		|substr(`x', 1, 6)=="文昌"|substr(`x', 1, 9)=="万宁市"|substr(`x', 1, 9)=="东方市"|substr(`x', 1, 6)=="澄迈")
}
foreach x in 采购人 采购人地址{
	replace province= "湖北" if province=="" &(substr(`x', 1, 6)=="武汉"|substr(`x', 1, 6)=="黄石"|substr(`x', 1, 6)=="十堰"|substr(`x', 1, 6)=="宜昌"|substr(`x', 1, 6)=="襄阳"|substr(`x', 1, 6)=="鄂州" ///
		|substr(`x', 1, 6)=="荆门"|substr(`x', 1, 9)=="随州市"|substr(`x', 1, 6)=="黄冈"|substr(`x', 1, 6)=="咸宁"|substr(`x', 1, 6)=="恩施"|substr(`x', 1, 6)=="仙桃"|substr(`x', 1, 6)=="潜江" ///
		|substr(`x', 1, 6)=="天门"|substr(`x', 1, 9)=="神农架")
}
foreach x in 采购人 采购人地址{
	replace province= "湖南" if province=="" &(substr(`x', 1, 6)=="长沙"|substr(`x', 1, 6)=="株洲"|substr(`x', 1, 6)=="湘潭"|substr(`x', 1, 6)=="衡阳"|substr(`x', 1, 6)=="邵阳"|substr(`x', 1, 6)=="岳阳" ///
		|substr(`x', 1, 6)=="常德"|substr(`x', 1, 9)=="张家界"|substr(`x', 1, 6)=="益阳"|substr(`x', 1, 6)=="郴州"|substr(`x', 1, 6)=="永州"|substr(`x', 1, 6)=="怀化"|substr(`x', 1, 6)=="娄底" ///
		|substr(`x', 1, 6)=="湘西")
}
foreach x in 采购人 采购人地址{
	replace province= "福建" if province=="" &(substr(`x', 1, 6)=="福州"|substr(`x', 1, 6)=="莆田"|substr(`x', 1, 9)=="三明市"|substr(`x', 1, 6)=="泉州"|substr(`x', 1, 6)=="漳州"|substr(`x', 1, 6)=="南平" ///
		|substr(`x', 1, 6)=="龙岩"|substr(`x', 1, 6)=="宁德"|substr(`x', 1, 6)=="厦门")
}
foreach x in 采购人 采购人地址{
	replace province= "西藏" if province=="" &(substr(`x', 1, 6)=="拉萨"|substr(`x', 1, 9)=="日喀则"|substr(`x', 1, 9)=="昌都市"|substr(`x', 1, 6)=="林芝"|substr(`x', 1, 9)=="山南市"|substr(`x', 1, 6)=="那曲" ///
		|substr(`x', 1, 6)=="阿里")
}
foreach x in 采购人 采购人地址{
	replace province= "贵州" if province=="" &(substr(`x', 1, 6)=="贵阳"|substr(`x', 1, 9)=="六盘水"|substr(`x', 1, 6)=="遵义"|substr(`x', 1, 9)=="安顺市"|substr(`x', 1, 6)=="毕节"|substr(`x', 1, 6)=="铜仁" ///
		|substr(`x', 1, 9)=="黔西南"|substr(`x', 1, 9)=="黔东南"|substr(`x', 1, 6)=="黔南")
}
foreach x in 采购人 采购人地址{
	replace province= "陕西" if province=="" &(substr(`x', 1, 6)=="西安"|substr(`x', 1, 6)=="铜川"|substr(`x', 1, 6)=="宝鸡"|substr(`x', 1, 6)=="咸阳"|substr(`x', 1, 6)=="渭南"|substr(`x', 1, 6)=="延安" ///
		|substr(`x', 1, 6)=="汉中"|substr(`x', 1, 6)=="榆林"|substr(`x', 1, 6)=="安康"|substr(`x', 1, 6)=="商洛")
}
foreach x in 采购人 采购人地址{
	replace province= "青海" if province=="" &(substr(`x', 1, 6)=="西宁"|substr(`x', 1, 9)=="海东市"|substr(`x', 1, 12)=="海北藏族"|substr(`x', 1, 9)=="黄南藏族"|substr(`x', 1, 12)=="海南藏族"|substr(`x', 1, 12)=="果洛藏族" ///
		|substr(`x', 1, 12)=="玉树藏族"|substr(`x', 1, 12)=="海西藏族")
}
foreach x in 采购人 采购人地址{
	replace province= "黑龙江" if province=="" &(substr(`x', 1, 9)=="哈尔滨"|substr(`x', 1, 12)=="齐齐哈尔"|substr(`x', 1, 6)=="鸡西"|substr(`x', 1, 6)=="鹤岗"|substr(`x', 1, 12)=="双鸭山"|substr(`x', 1, 6)=="大庆" ///
		|substr(`x', 1, 6)=="伊春"|substr(`x', 1, 9)=="佳木斯"|substr(`x', 1, 12)=="七台河"|substr(`x', 1, 12)=="牡丹江"|substr(`x', 1, 6)=="黑河"|substr(`x', 1, 6)=="绥化"|substr(`x', 1, 12)=="大兴安岭")
}
foreach x in 采购人 采购人地址{
	replace province= "内蒙古" if province=="" &(substr(`x', 1, 12)=="呼和浩特"|substr(`x', 1, 6)=="包头"|substr(`x', 1, 6)=="乌海"|substr(`x', 1, 6)=="赤峰"|substr(`x', 1, 12)=="通辽"|substr(`x', 1, 12)=="鄂尔多斯" ///
		|substr(`x', 1, 12)=="呼伦贝尔"|substr(`x', 1, 12)=="巴彦卓儿"|substr(`x', 1, 12)=="乌兰察布"|substr(`x', 1, 12)=="锡林格勒"|substr(`x', 1, 9)=="兴安盟"|substr(`x', 1, 9)=="阿拉善")
}
foreach x in 合同名称{
	replace province= substr(`x', 1, 6) if province=="" &(substr(`x', 1, 6)=="北京"|substr(`x', 1, 6)=="上海"|substr(`x', 1, 6)=="天津"|substr(`x', 1, 6)=="重庆"|substr(`x', 1, 6)=="辽宁"|substr(`x', 1, 6)=="吉林" ///
		|substr(`x', 1, 6)=="河北"|substr(`x', 1, 6)=="云南"|substr(`x', 1, 6)=="四川"|substr(`x', 1, 6)=="宁夏"|substr(`x', 1, 6)=="安徽"|substr(`x', 1, 6)=="山东"|substr(`x', 1, 6)=="山西" ///
		|substr(`x', 1, 6)=="广东"|substr(`x', 1, 6)=="广西"|substr(`x', 1, 6)=="新疆"|substr(`x', 1, 6)=="江苏"|substr(`x', 1, 6)=="江西"|substr(`x', 1, 6)=="河南"|substr(`x', 1, 6)=="浙江" ///
		|substr(`x', 1, 6)=="海南"|substr(`x', 1, 6)=="湖北"|substr(`x', 1, 6)=="湖南"|substr(`x', 1, 6)=="澳门"|substr(`x', 1, 6)=="甘肃"|substr(`x', 1, 6)=="福建"|substr(`x', 1, 6)=="西藏" ///
		|substr(`x', 1, 6)=="贵州"|substr(`x', 1, 6)=="陕西"|substr(`x', 1, 6)=="青海"|substr(`x', 1, 6)=="香港")
	replace province = substr(`x', 1, 9) if province=="" &(substr(`x', 1, 9)=="黑龙江"|substr(`x', 1, 9)=="内蒙古")
}
*/

g test = 0
replace test = 1 if province != ""
//tab n_prov if test == 0
//tab n_prov2 if test == 0
tab test
drop test
//

//central vs local
gen area=province
replace area="中央" if 中央==1
replace area = province if(regexm(采购人, "市国资委")) 
replace area = "中央" if(regexm(合同名称, "央资")) 
replace area = "中央" if(regexm(合同名称, "中央")) 
replace area = "中央" if(regexm(采购人, "中央")) 


tab 采购人 if(regexm(采购人, "国家")) & area != "中央" 
//manual check what may be missing
replace area = "中央" if(regexm(采购人, "国家卫星气象中心")|regexm(采购人, "国家卫星")) 
replace area = "中央" if(regexm(采购人, "中国合格评定国家认可中心")) 
replace area = "中央" if(regexm(采购人, "国家质检总局")|regexm(采购人, "国家质检")|regexm(采购人, "国家质量监督")) 
replace area = "中央" if(regexm(采购人, "中国国国家博物馆")|regexm(采购人, "中国国家话剧")) 
replace area = "中央" if(regexm(采购人, "国家卫生计生委")) 
replace area = "中央" if(regexm(采购人, "国家工商总局")|regexm(采购人, "国家工商行政管理总局")) 
replace area = "中央" if(regexm(采购人, "国家广播电影电视总局")) 
replace area = "中央" if(regexm(采购人, "国家旅游局")) 
replace area = "中央" if(regexm(采购人, "国家林业局")) 
replace area = "中央" if(regexm(采购人, "国家测绘局")) 
replace area = "中央" if(regexm(采购人, "国家海洋局")) 
replace area = "中央" if(regexm(采购人, "国家认证认可监督管理委员会信息中心")|regexm(采购人, "国家食品药品监督管理总局")) 


drop *prov
drop *prov2

save "02 - prepare data - province & central.dta", replace
