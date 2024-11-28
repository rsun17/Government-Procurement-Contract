timer clear
timer on 1

// merge dataset of multiple products from 01 and 02
// 11,421 observations in total
use "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/04-multiple.dta", replace
append using "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/04-multiple from single.dta"
save "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/04-multiple merged.dta", replace


/*
	Section I: product variable cleaning
	accuracy rate: 
	1. 
	
	可能存在的问题：
	1. 包含multiple product的情况
	count if regexm(主要标的单价,";|；|、") 1,514

	
*/
use "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/04-multiple merged.dta", replace
gen product_price = 主要标的单价
gen fix = 0
replace product_price = subinstr(product_price, "；", ";", .)
replace product_price = regexreplaceall(product_price, "？", "")


	// Step 1: basic data cleaning
	// 1.1: cases where product are split by 1./2./3./...; 112 cases in total
gen flag = regexm(product_price,"^1\..*2\.")
replace fix = 1 if flag ==1

replace product_price = regexreplaceall(product_price, "^1\.", "") if flag == 1

local delimiters "; , ， 。 . 、 元 台 只 支 箱 个 方 盒 本 张 包 把 套 )"
local numbers 2 3 4 5 6 7 8 9 10

foreach delimiter of local delimiters {
    foreach num of local numbers {
        local pattern = "`delimiter'`num'\."
		
        replace product_price = regexreplaceall(product_price, "`pattern'", ";") if flag == 1

    }
}

drop flag

	// 1.2: cases where product are split by 1、/2、/3、/...; 75 cases in total
gen flag = regexm(product_price,"^1、.*2、")
replace fix = 1 if flag ==1


replace product_price = regexreplaceall(product_price, "^1、", "") if flag == 1

local delimiters "; , ， 。 元 台 只 支 箱 个 方 盒 本 张 包 把 套 \) ）"
local numbers 2 3 4 5 6 7 8 9 10

foreach delimiter of local delimiters {
    foreach num of local numbers {
        local pattern = "`delimiter'`num'、"
        replace product_price = regexreplaceall(product_price, "`pattern'", ";") if flag == 1
    }
}

drop flag
	
	// 1.3 cases where product are split by 1：/2：/3：/...; 3 cases in total
gen flag = regexm(product_price,"^1：")
replace fix = 1 if flag ==1

replace product_price = regexreplaceall(product_price, "^1：", "") if flag == 1
replace product_price = regexreplaceall(product_price, ";2：", ";") if flag == 1
replace product_price = regexreplaceall(product_price, "。2：", ";") if flag == 1
replace product_price = regexreplaceall(product_price, "年2：", ";") if flag == 1
replace product_price = regexreplaceall(product_price, ";3：", ";") if flag == 1
replace product_price = regexreplaceall(product_price, "年3：", ";") if flag == 1
replace product_price = regexreplaceall(product_price, ";4：", ";") if flag == 1

drop flag

	// 1.4: cases where product are split by A:/B:/C:/...;
gen flag = regexm(product_price,"^A:.*B:")
replace fix = 1 if flag ==1

replace product_price = regexreplaceall(product_price, "^A:", "") if flag == 1
replace product_price = regexreplaceall(product_price, "；B:", ";") if flag == 1
replace product_price = regexreplaceall(product_price, "；C:", ";") if flag == 1
replace product_price = regexreplaceall(product_price, "；D:", ";") if flag == 1
replace product_price = regexreplaceall(product_price, "；E:", ";") if flag == 1
replace product_price = regexreplaceall(product_price, "；F:", ";") if flag == 1
drop flag

	// 1.5: cases where product are split by a:/b:/c:/...;
gen flag = regexm(product_price,"^a:.*b：")
replace fix = 1 if flag ==1

replace product_price = regexreplaceall(product_price, "^a:", "") if flag == 1
replace product_price = regexreplaceall(product_price, "、b：", ";") if flag == 1
replace product_price = regexreplaceall(product_price, "、c:", ";") if flag == 1
replace product_price = regexreplaceall(product_price, "、d：", ";") if flag == 1
drop flag

	// 1.6: cases with "、"
	// 可能存在的问题：
local patterns "[0-9]、[0-9] [0-9]、 元、 万、 个、 版、 条、 包、 盒、 套、 人、 株、 本、 份、 台、 块、 根、 件、 张、 样、 月、 瓶、 天、 吨、 块、 升、 千克、 公斤、 元次、 ）、"

foreach pattern of local patterns {
    replace product_price = regexreplaceall(product_price, "、", ";") if regexm(product_price, "`pattern'") & fix == 0
}	

gen flag = regexm(product_price, "/") & regexm(product_price, "、") & regexm(product_price, "/.*/") & fix == 0
replace product_price = regexreplaceall(product_price, "、", ";") if flag == 1
drop flag

	// 1.7: cases with "，"
	// 可能存在的问题：
	
local patterns "[0-9]，[0-9] [0-9]， ）， \)， 元， 万， 每个，.*每 每台，.*每 每套，.*每 每张，.*每 每本，.*每 每包，.*每 每米，.*每 每座，.*每 每箱，.*每"

foreach pattern of local patterns {
    replace product_price = regexreplaceall(product_price, "，", ";") if regexm(product_price, "`pattern'") & fix == 0
}
	
	// 对于用"，"分隔商品的observation, 大多数都是"/+quantifier"
gen flag = regexm(product_price, "/") & regexm(product_price, "，") & regexm(product_price, "/.*/") & fix == 0
replace product_price = regexreplaceall(product_price, "，", ";") if flag == 1 & fix == 0
drop flag
	
	// 1.8: cases with "。"
replace product_price = regexreplaceall(product_price, "。", ";") if regexm(product_price, "元。") & fix == 0

gen flag = regexm(product_price, "/") & regexm(product_price, "。") & regexm(product_price, "/.*/") & fix == 0
replace product_price = regexreplaceall(product_price, "。", ";") if flag == 1 & fix == 0
drop flag

//------------------------------------------------------------------------------
// Step 2: generate product variables from 主要标的单价

	// 2.1: clean price information [0-9]+\.[0-9]+

replace product_price = regexreplaceall(product_price, "单价[0-9]+\.[0-9]+万元整", "")
replace product_price = regexreplaceall(product_price, "单价[0-9]+万元整", "")
replace product_price = regexreplaceall(product_price, "单价[0-9]+\.[0-9]+万整", "")
replace product_price = regexreplaceall(product_price, "单价[0-9]+万整", "")
replace product_price = regexreplaceall(product_price, "单价[0-9]+\.[0-9]+元整", "")
replace product_price = regexreplaceall(product_price, "单价[0-9]+元整", "")
replace product_price = regexreplaceall(product_price, "单价[0-9]+\.[0-9]+万元", "")
replace product_price = regexreplaceall(product_price, "单价[0-9]+万元", "")
replace product_price = regexreplaceall(product_price, "单价[0-9]+\.[0-9]+万", "")
replace product_price = regexreplaceall(product_price, "单价[0-9]+万", "")
replace product_price = regexreplaceall(product_price, "单价[0-9]+\.[0-9]+元", "")
replace product_price = regexreplaceall(product_price, "单价[0-9]+元", "")
replace product_price = regexreplaceall(product_price, "人民币[0-9]+\.[0-9]+万元整", "")
replace product_price = regexreplaceall(product_price, "人民币[0-9]+万元整", "")
replace product_price = regexreplaceall(product_price, "人民币[0-9]+\.[0-9]+万整", "")
replace product_price = regexreplaceall(product_price, "人民币[0-9]+万整", "")
replace product_price = regexreplaceall(product_price, "人民币[0-9]+\.[0-9]+元整", "")
replace product_price = regexreplaceall(product_price, "人民币[0-9]+元整", "")
replace product_price = regexreplaceall(product_price, "人民币[0-9]+万元", "")
replace product_price = regexreplaceall(product_price, "人民币[0-9]+\.[0-9]+万元", "")
replace product_price = regexreplaceall(product_price, "人民币[0-9]+万", "")
replace product_price = regexreplaceall(product_price, "人民币[0-9]+\.[0-9]+万", "")
replace product_price = regexreplaceall(product_price, "人民币[0-9]+\.[0-9]+元", "")
replace product_price = regexreplaceall(product_price, "人民币[0-9]+元", "")
replace product_price = regexreplaceall(product_price, "[0-9]+\.[0-9]+万元整", "")
replace product_price = regexreplaceall(product_price, "[0-9]+万元整", "")
replace product_price = regexreplaceall(product_price, "[0-9]+\.[0-9]+万整", "")
replace product_price = regexreplaceall(product_price, "[0-9]+万整", "")
replace product_price = regexreplaceall(product_price, "[0-9]+\.[0-9]+元整", "")
replace product_price = regexreplaceall(product_price, "[0-9]+元整", "")
replace product_price = regexreplaceall(product_price, "[0-9]+\.[0-9]+万元", "")
replace product_price = regexreplaceall(product_price, "[0-9]+万元", "")
replace product_price = regexreplaceall(product_price, "[0-9]+\.[0-9]+万", "")
replace product_price = regexreplaceall(product_price, "[0-9]+万", "")
replace product_price = regexreplaceall(product_price, "为[0-9]+\.[0-9]+元", "")
replace product_price = regexreplaceall(product_price, "为[0-9]+元", "")
replace product_price = regexreplaceall(product_price, "[0-9]+\.[0-9]+元", "")
replace product_price = regexreplaceall(product_price, "[0-9]+元", "")
replace product_price = regexreplaceall(product_price, "RMB[0-9]+\.[0-9]+", "")
replace product_price = regexreplaceall(product_price, "RMB[0-9]+", "")
replace product_price = regexreplaceall(product_price, "[0-9]+\.[0-9]+RMB", "")
replace product_price = regexreplaceall(product_price, "[0-9]+RMB", "")
replace product_price = regexreplaceall(product_price, "人民币[0-9]+\.[0-9]+", "")
replace product_price = regexreplaceall(product_price, "人民币[0-9]+", "")
replace product_price = regexreplaceall(product_price, "[0-9]+\.[0-9]+人民币", "")
replace product_price = regexreplaceall(product_price, "[0-9]+人民币", "")
replace product_price = regexreplaceall(product_price, "单向总价：[0-9]+\.[0-9]+元", "")
replace product_price = regexreplaceall(product_price, "单向总价：[0-9]+元", "")
replace product_price = regexreplaceall(product_price, "单向总价：[0-9]+\.[0-9]+", "")
replace product_price = regexreplaceall(product_price, "单向总价：[0-9]+", "")
replace product_price = regexreplaceall(product_price, "（优惠价：[0-9]+\.[0-9]+）;", "")
replace product_price = regexreplaceall(product_price, "（优惠价：[0-9]+）;", "")
replace product_price = regexreplaceall(product_price, "（原价：[0-9]+\.[0-9]+,优惠价：[0-9]+\.[0-9]+）;", "")
replace product_price = regexreplaceall(product_price, "（原价：[0-9]+,优惠价：[0-9]+）;", "")
replace product_price = regexreplaceall(product_price, "各类项目合计[0-9]+\.[0-9]+", "")
replace product_price = regexreplaceall(product_price, "共计[0-9]+\.[0-9]+", "")
replace product_price = regexreplaceall(product_price, "共计[0-9]+", "")
replace product_price = regexreplaceall(product_price, "总计[0-9]+\.[0-9]+", "")
replace product_price = regexreplaceall(product_price, "总计[0-9]+", "")
replace product_price = regexreplaceall(product_price, "合计[0-9]+\.[0-9]+", "")
replace product_price = regexreplaceall(product_price, "合计[0-9]+", "")
replace product_price = regexreplaceall(product_price, "小计[0-9]+\.[0-9]+", "")
replace product_price = regexreplaceall(product_price, "小计[0-9]+", "")
replace product_price = regexreplaceall(product_price, "单价[0-9]+\.[0-9]+", "")
replace product_price = regexreplaceall(product_price, "单价[0-9]+", "")

replace product_price = regexreplaceall(product_price, "人民币（万元）", "")
replace product_price = regexreplaceall(product_price, "人民币（万）", "")
replace product_price = regexreplaceall(product_price, "人民币（元）", "")
replace product_price = regexreplaceall(product_price, "（万元）", "")
replace product_price = regexreplaceall(product_price, "（万）", "")
replace product_price = regexreplaceall(product_price, "（元）", "")
replace product_price = regexreplaceall(product_price, "（元/人）", "")
replace product_price = regexreplaceall(product_price, "（元/台）", "")
replace product_price = regexreplaceall(product_price, "（元/人月）", "")
replace product_price = regexreplaceall(product_price, "（元/年）;", "")
replace product_price = regexreplaceall(product_price, "各类项目合计", "")
replace product_price = regexreplaceall(product_price, "单价", "")
replace product_price = regexreplaceall(product_price, "小计", "")
replace product_price = regexreplaceall(product_price, "计", "")
replace product_price = regexreplaceall(product_price, "总金额", "")
replace product_price = regexreplaceall(product_price, "预算价", "")
replace product_price = regexreplaceall(product_price, "中标价", "")
replace product_price = regexreplaceall(product_price, "USD", "")
replace product_price = regexreplaceall(product_price, "EUR", "")
replace product_price = regexreplaceall(product_price, "$", "")
replace product_price = regexreplaceall(product_price, "￥", "")


	// 2.2: clean quantity information
	// 可能存在的问题： 1. 米 平米 平方 平方米 立方米 立方 包 可能会删掉原本商品信息 
local quantifiers "个 件 位 名 元/台 台 辆 支 根 条 把 瓶 盒 袋 张 盘 碗 罐 盆 箱 瓶 匹 双 层 次 团 批 桶 扎 网 角 粒 枚 回 扇 届 桩 层 屋 棵 趟 艘 滴 班 拨 段 炉 笼 群 行 轮 招 节 批 桩 排 档 桌 场 手 次 盘 局 盏 层 梯 座 回 轮 航 次 批 笔 次 局 届 次 回 项 本 吨 套 宗 尾 筒 公里 人/元/月 人/天 人 人份 cm/平方米 栋 页 间 升 千克 公斤 亩 千瓦 户 份 册 天 块 卷 组 付 令 株 日辆 车辆 工时 版 部 千印 门 个月 月 头 只 片 日 对 只 小时 具 台\1年 g kw ㎡ 副 平米 平方 平方米 立方米 立方 顶 M 延米 ug ml 间 斤"

foreach var in product_price {
    foreach quantifier of local quantifiers {
        local pattern1 "(约[0-9]+\.[0-9]+`quantifier')"
		local pattern2 "(约[0-9]+`quantifier')"
		local pattern3 "(约[0-9]+\.[0-9]+/`quantifier')"
		local pattern4 "(约[0-9]+/`quantifier')"
        local pattern5 "([0-9]+\.[0-9]+`quantifier')"
		local pattern6 "([0-9]+`quantifier')"
		local pattern7 "([0-9]+\.[0-9]+/`quantifier')"
		local pattern8 "([0-9]+/`quantifier')"
		local pattern9 "(\/`quantifier')"
		local pattern10 "(每`quantifier')"
		local pattern11 "(一`quantifier')"
		local pattern12 "(采购数量：[0-9]+)"
		
		
        replace `var' = regexreplaceall(`var', "`pattern1'", "")
		replace `var' = regexreplaceall(`var', "`pattern2'", "")
		replace `var' = regexreplaceall(`var', "`pattern3'", "")
		replace `var' = regexreplaceall(`var', "`pattern4'", "")
		replace `var' = regexreplaceall(`var', "`pattern5'", "")
		replace `var' = regexreplaceall(`var', "`pattern6'", "")
		replace `var' = regexreplaceall(`var', "`pattern7'", "")
		replace `var' = regexreplaceall(`var', "`pattern8'", "")
		replace `var' = regexreplaceall(`var', "`pattern9'", "")
		replace `var' = regexreplaceall(`var', "`pattern10'", "")
		replace `var' = regexreplaceall(`var', "`pattern11'", "")
		replace `var' = regexreplaceall(`var', "`pattern12'", "")
		replace `var' = "." if `var' == "`quantifier'"
		replace `var' = regexreplaceall(`var', "/米", "")
    }
}
replace product_price = "." if product_price == "一包"

	// 2.3 formatting
replace product_price = "." if regexm(product_price, "^[0-9\.，,;；/、\\]+$")
replace product_price = "." if regexm(product_price, "^[\.，,;；/、\\]+$")
replace product_price = "." if regexm(product_price, "^[0-9]+$")
replace product_price = regexreplaceall(product_price, "([0-9]+.;", "")

replace product_price = "." if product_price == ";"
	// cleanup potential multiple semicolons caused by replacements
replace product_price = regexreplaceall(product_price, ";;", ";")
replace product_price = regexreplaceall(product_price, ":;", ";")
replace product_price = regexreplaceall(product_price, ": ;", ";")
replace product_price = regexreplaceall(product_price, "：;", ";")
replace product_price = regexreplaceall(product_price, "： ;", ";")
replace product_price = regexr(product_price, "/;$", ";")
replace product_price = regexreplaceall(product_price, ",;", ";")
replace product_price = regexreplaceall(product_price, "，;", ";")
replace product_price = regexreplaceall(product_price, "/;", ";")
replace product_price = regexreplaceall(product_price, "[0-9]+\.[0-9]+;", ";")
replace product_price = regexreplaceall(product_price, "[0-9]+;", ";")
replace product_price = regexreplaceall(product_price, "\([0-9]+\.[0-9]+\);", ";")
replace product_price = regexreplaceall(product_price, "\([0-9]+.\);", ";")

replace product_price = regexreplaceall(product_price, "\（[0-9]+\.[0-9]+\）", "") 
replace product_price = regexreplaceall(product_price, "\([0-9]+\)", "") 
replace product_price = "." if product_price == "^[0-9]\.$"
replace product_price = regexreplaceall(product_price, "[0-9]+$", "") 
replace product_price = regexreplaceall(product_price, "[0-9]+\.$", "")
replace product_price = regexreplaceall(product_price, "（[0-9]+\.）", "")
replace product_price = regexreplaceall(product_price, "\([0-9]+\.\)", "")
replace product_price = regexreplaceall(product_price, "（[0-9]\.）", "")
replace product_price = regexreplaceall(product_price, "\([0-9]\.\)", "")

replace product_price = regexreplaceall(product_price, "（原价：优惠价：）", "")
replace product_price = regexreplaceall(product_price, "（优惠价：）", "")
replace product_price = regexreplaceall(product_price, "（）", "") 
replace product_price = regexreplaceall(product_price, "\(\)", "") 

replace product_price = regexr(product_price, "^;", "")
replace product_price = regexr(product_price, "^。", "")
replace product_price = regexr(product_price, "^，", "")   
replace product_price = regexr(product_price, "^,", "")  
replace product_price = regexr(product_price, "^：", "") 
replace product_price = regexr(product_price, "^:", "")
replace product_price = regexr(product_price, "^/", "")
replace product_price = regexr(product_price, "^、", "")
replace product_price = regexr(product_price, "^;+", "") 
replace product_price = regexr(product_price, "^\\+", "") 
replace product_price = regexr(product_price, "^;;;+", "") 

replace product_price = regexr(product_price, ";+$", "")
replace product_price = regexr(product_price, ";$", "")
replace product_price = regexr(product_price, "。+$", "")
replace product_price = regexr(product_price, "，+$", "")   
replace product_price = regexr(product_price, ",+$", "")  
replace product_price = regexr(product_price, "：$", "") 
replace product_price = regexr(product_price, ":$", "")
replace product_price = regexr(product_price, "\*$", "")
replace product_price = regexr(product_price, "/$", "")
replace product_price = regexr(product_price, "、$", "")
replace product_price = regexr(product_price, "\\+$", "")
replace product_price = regexreplaceall(product_price, "\(）", "")


replace product_price = regexreplaceall(product_price, "(\*;)", ";")
replace product_price = regexreplaceall(product_price, "(：;)", ";")
replace product_price = regexreplaceall(product_price, "(:;)", ";")
replace product_price = regexreplaceall(product_price, "($;)", ";")
replace product_price = regexreplaceall(product_price, "(;;)", ";")
replace product_price = regexreplaceall(product_price, "(\.;)", ";")
replace product_price = regexreplaceall(product_price, "(;、)", ";")
replace product_price = regexreplaceall(product_price, "(：-;)", ";")
replace product_price = regexreplaceall(product_price, "(：/)", "")
replace product_price = regexreplaceall(product_price, "(--)", "")

	// 2.4 special cases
replace product_price = "." if !regexm(product_price, ";")
replace product_price = regexr(product_price, "等$", "")

local terms "，合 ，本 \.月 ≤ （以下） （/年） （/元） （人民币：） （1） （2） （3） （4） （5） ▲ /包 每包 美元;美元 不超 ：米 /车 （米）"
foreach term of local terms{
	replace product_price = regexreplaceall(product_price, "`term'", "") 
}


replace product_price = regexreplaceall(product_price, "6\.5\*;4\.7\*;5.45\*0\.4=6\.66\*1600=", "")
replace product_price = regexreplaceall(product_price, ";总$", "")
replace product_price = regexreplaceall(product_price, ";合$", "")
replace product_price = regexreplaceall(product_price, ";共$", "")
replace product_price = regexreplaceall(product_price, "^产品名称规格型号数量", "")


replace product_price = regexreplaceall(product_price, "、2、", ";")
replace product_price = regexreplaceall(product_price, "，;", ";")

replace product_price = regexreplaceall(product_price, "粉盒/", "粉盒")
replace product_price = regexreplaceall(product_price, "A4复印纸;8K;A", "A4复印纸;8K;A3")


replace product_price = "A3;A4;A5" if product_price =="A;A;A"
replace product_price = "." if product_price =="和|总价|共"
replace product_price = "." if regexm(product_price, "^一、工程竣工财务决算审：1.送审金额在以下的")
replace product_price = "." if regexm(product_price, "^付;套;架")
replace product_price = "." if regexm(product_price, "^付;套;架")
replace product_price = "." if regexm(product_price, "^①;②;③")
replace product_price = "." if regexm(product_price, "^粉盒：京瓷6118:数量：（：）;")



replace product_price = "传承红色基因赓续精神血脉印刷" if regexm(product_price, "^印数;：总价：")

replace product_price = 主要标的名称 if regexm(product_price, "^ADCP无锡海鹰RIV")
replace product_price = 主要标的名称 if regexm(product_price, "^（1）套间;单间;标准间")
replace product_price = 主要标的名称 if regexm(product_price, "^陇南市重点")
replace product_price = 主要标的名称 if regexm(product_price, "^为1年的养护费用")
replace product_price = 主要标的名称 if regexm(product_price, "^工程费用下浮率1.02%")
replace product_price = 主要标的名称 if regexm(product_price, "^每年合同为;三年")


replace product_price = "机油;机滤;空气滤;变速箱及后桥油;冷媒;压缩机皮带;门扣手;压缩机涨紧轮;蒸发箱;更换马达开关" if regexm(product_price, "^机油\*6=;机滤\*3=;空气滤\*1=;")
replace product_price = "." if regexm(product_price, "^年租金年;月租金;超过月;不足整月的天数;按正常日租价收费")
replace product_price = "硒鼓兄弟DR-2350;硒鼓兄弟DR-2250;硒鼓懿品惠普CC388A黑鼓;懿品惠普2612A黑鼓;复印纸，鑫特A4" if regexm(product_price, "^硒鼓兄弟DR-;数量;")
replace product_price = "硒鼓兄弟DR-2350;硒鼓兄弟DR-2250;硒鼓懿品惠普CC388A黑鼓;懿品惠普2612A黑鼓;复印纸，鑫特A4" if regexm(product_price, "^硒鼓兄弟DR-;数量;")
replace product_price = "54座车;45座车;35座车;19座车" if regexm(product_price, "^车;车;车;车")
replace product_price = "A3;A4" if regexm(product_price, "^A;A4$")
replace product_price = "A3;16开;A3" if regexm(product_price, "^其中A;16开;$")
replace product_price = "PVC文化墙3.91*1.4;PVC文化墙4.2*1.5;PVCuv4.8*4.8*0.15" if regexm(product_price, "^PVC文化墙3.91;")
replace product_price = "得力复印纸A3;得力复印纸A3;A4硒鼓;A4粉盒;A3彩色打印机;单反相机;蜡纸;8K试卷纸" if regexm(product_price, "^得力复印纸A;")
replace product_price = "1.2*0.8m壁挂宣传栏;2.4*1.2m壁挂宣传栏;3.6*1.2*2.6m直线简易式集中投放设施" if regexm(product_price, "^生活垃圾分类基础设施（1.2")
replace product_price = "摄像头;硬盘录像机、交换机; 零星材料及其它：网线50米、水晶头、线钉1个、安装费等" if regexm(product_price, "^摄像头：2")
replace product_price = "V领制式背心;制式毛背心;制式毛裤（第1包）;制式短袖T恤衫;特警战训短袖T恤（第2包）;特警夏袜;特警冬袜（第4包）" if regexm(product_price, "^（第1包）;（第2包）;（第4包）")
replace product_price = "第一包精梳毛涤单面哔叽;第二包毛涤素花呢;第三包精梳毛涤缎背哔叽;第四包交织绸、精梳涤棉混纺染色斜纹布" if regexm(product_price, "^每米、每米、每米")
replace product_price = "A3;A4;硒鼓;硒鼓;墨粉;粉盒" if regexm(product_price, "^A;A;硒鼓;硒鼓;墨粉;粉盒")
replace product_price = "拆除砖木;拆除砖混;拆除简易及其他结构（包括彩钢;砖简等结构）" if regexm(product_price, "^拆除砖木（大写：米柒拾陆元整）")
replace product_price = "A3打印纸;A4打印纸;试卷纸" if regexm(product_price, "^A;A4打印纸;试卷纸")
replace product_price = "A4打印纸;A5打印纸;1043/88A/12A型号的硒鼓;1043/88A/12A型号的碳粉" if regexm(product_price, "^A;A5打印纸;1043/88A/12A型号的硒鼓")
replace product_price = "笔;固体胶;文件盒" if regexm(product_price, "^笔;固体胶\*4=")
replace product_price = "硒鼓，技美CRG-328;复印纸，佳印A3;复印纸;佳印A4;粉盒;佳能2530i" if regexm(product_price, "^硒鼓，技美CRG-328，，240")
replace product_price = "录音笔;摄像机;便携式计算机;CA数字证书;辐射巡测仪（进口产品已论证审批）;表面污染检测仪（进口产品已论证审批）" if regexm(product_price, "^1;16;7;35;40000.00")
replace product_price = "录音笔;摄像机;便携式计算机;CA数字证书;辐射巡测仪（进口产品已论证审批）;表面污染检测仪（进口产品已论证审批）" if regexm(product_price, "^1;16;7;35;40000.00")
replace product_price = "A4;试卷纸" if regexm(product_price, "^A;试卷纸$")
replace product_price = "无、浙江博世华环保科技有限公司、广西博世科环保科技股份有限公司" if regexm(product_price, "^5.3831897E;5.3831897E;5.3831897E$")
replace product_price = "得力A4复印纸;A3复印纸" if regexm(product_price, "^得力A;A3复印纸均$")
replace product_price = "A3;A4;A4牛皮纸" if regexm(product_price, "^A;A;A4牛皮纸$")
replace product_price = "A4;A3" if regexm(product_price, "^A;A$")



replace product_price = "." if regexm(product_price, "^办公桌4\*9001\*;")





replace product_price = "." if product_price ==";;;"
replace product_price = "." if product_price ==";;"
replace product_price = "." if product_price ==";"

replace product_price = "." if product_price == ""


drop fix

//------------------------------------------------------------------------------
// Step 3: get product information from 主要标的数量
// notes: 1. 3 observations have "1、/2、/3、/..." as the indicator of number of products

gen flag = product_price=="."
gen product_quantity = ""
replace product_quantity = 主要标的数量 if flag == 1

replace product_quantity = subinstr(product_quantity, "；", ";", .)

	// 3.1: cases where products are listed by "1、/2、/3、/..."
gen indicator = regexm(product_quantity,"^1、.*2、")
gen fix = 0
replace fix = 1 if indicator ==1

replace product_quantity = regexreplaceall(product_quantity, "^1、", "") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ";2、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ";3、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ";4、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ";5、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ";6、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ";7、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ";8、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ";9、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ";10、", ";") if indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "^1、", "") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "；2、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "；3、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "；4、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "；5、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "；6、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "；7、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "；8、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "；9、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "；10、", ";") if indicator == 1

replace product_quantity = regexreplaceall(product_quantity, ",2、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ",3、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ",4、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ",5、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ",6、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ",7、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ",8、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ",9、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, ",10、", ";") if indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "、2、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "、3、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "、4、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "、5、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "、6、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "、7、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "、8、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "、9、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "、10、", ";") if indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "，2、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "，3、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "，4、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "，5、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "，6、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "，7、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "，8、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "，9、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "，10、", ";") if indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "。2、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "。3、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "。4、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "。5、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "。6、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "。7、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "。8、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "。9、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "。10、", ";") if indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "元2、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "元3、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "元4、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "元5、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "元6、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "元7、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "元8、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "元9、", ";") if indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "元10、", ";") if indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, "台2、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, "台3、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, "台4、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, "台5、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, "台6、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, "台7、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, "台8、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, "台9、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, "台10、")& indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, "只2、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, "只3、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, "只4、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, "只5、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, "只6、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, "只7、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, "只8、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, "只9、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, "只10、")& indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, "支2、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, "支3、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, "支4、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, "支5、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, "支6、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, "支7、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, "支8、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, "支9、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, "支10、")& indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, "箱2、、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, "箱3、、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, "箱4、、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, "箱5、、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, "箱6、、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, "箱7、、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, "箱8、、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, "箱9、、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, "箱10、、")& indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, "个2、、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, "个3、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, "个4、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, "个5、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, "个6、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, "个7、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, "个8、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, "个9、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, "个10、")& indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, "方2、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, "方3、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, "方4、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, "方5、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, "方6、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, "方7、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, "方8、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, "方9、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, "方10、")& indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, "盒2、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, "盒3、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, "盒4、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, "盒5、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, "盒6、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, "盒7、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, "盒8、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, "盒9、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, "盒10、")& indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, "本2、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, "本3、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, "本4、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, "本5、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, "本6、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, "本7、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, "本8、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, "本9、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, "本10、")& indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, "张2、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, "张3、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, "张4、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, "张5、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, "张6、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, "张7、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, "张8、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, "张9、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, "张10、")& indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, "包2、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, "包3、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, "包4、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, "包5、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, "包6、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, "包7、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, "包8、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, "包9、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, "包10、")& indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, "把2、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, "把3、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, "把4、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, "把5、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, "把6、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, "把7、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, "把8、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, "把9、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, "把10、")& indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, "套2、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, "套3、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, "套4、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, "套5、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, "套6、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, "套7、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, "套8、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, "套9、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, "套10、")& indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, "㎡2、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, "㎡3、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, "㎡4、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, "㎡5、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, "㎡6、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, "㎡7、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, "㎡8、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, "㎡9、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, "㎡10、")& indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, "m2、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, "m3、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, "m4、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, "m5、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, "m6、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, "m7、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, "m8、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, "m9、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, "m10、")& indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, ")2、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, ")3、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, ")4、")& indicator== 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, ")5、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, ")6、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, ")7、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, ")8、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, ")9、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, ")10、")& indicator == 1

replace product_quantity = regexreplaceall(product_quantity, "2、", ";") if regexm(product_quantity, "）2、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "3、", ";") if regexm(product_quantity, "）3、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "4、", ";") if regexm(product_quantity, "）4、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "5、", ";") if regexm(product_quantity, "）5、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "6、", ";") if regexm(product_quantity, "）6、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "7、", ";") if regexm(product_quantity, "）7、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "8、", ";") if regexm(product_quantity, "）8、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "9、", ";") if regexm(product_quantity, "）9、")& indicator == 1
replace product_quantity = regexreplaceall(product_quantity, "10、", ";") if regexm(product_quantity, "）10、")& indicator == 1

drop indicator

	// 3.2 cases with "，"
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "斤，")& fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "个，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "版，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "条，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "包，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "盒，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "套，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "人，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "株，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "本，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "份，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "台，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "块，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "根，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "件，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "张，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "样，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "月，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "瓶，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "天，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "吨，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "块，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "升，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "辆，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "项，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "箱，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "张，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "把，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "组，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "份，")& fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "支，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "座，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "千克，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "只，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "机，") & fix == 0


replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "个.*，") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "，", ";") if regexm(product_quantity, "台.*，.*台") & fix == 0


	// 3.3 cases with ","
replace product_quantity = regexreplaceall(product_quantity, ",", ";") if regexm(product_quantity, "只,") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, ",", ";") if regexm(product_quantity, "个,") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, ",", ";") if regexm(product_quantity, "台,") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, ",", ";") if regexm(product_quantity, "本,") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, ",", ";") if regexm(product_quantity, "张,") & fix == 0

	// 3.4 cases with "、"
	// 可能存在的问题：1. 对于没有quantity的observation，product直接用“、”隔开的无法recognize
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "套、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "条、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "张、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "个、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "）、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "箱、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "盒、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "块、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "支、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "双、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "页、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "艘、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "组合、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "台、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "床、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "项、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "本、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "份、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "株、") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "个、") & fix == 0

replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "台.*、.*台") & fix == 0
replace product_quantity = regexreplaceall(product_quantity, "、", ";") if regexm(product_quantity, "辆.*、.*辆") & fix == 0

	// 3.5 clean the price info from the product info
replace product_quantity = regexreplaceall(product_quantity, "单价[0-9]+\.[0-9]+万元整", "")
replace product_quantity = regexreplaceall(product_quantity, "单价[0-9]+万元整", "")
replace product_quantity = regexreplaceall(product_quantity, "单价[0-9]+\.[0-9]+万整", "")
replace product_quantity = regexreplaceall(product_quantity, "单价[0-9]+万整", "")
replace product_quantity = regexreplaceall(product_quantity, "单价[0-9]+\.[0-9]+元整", "")
replace product_quantity = regexreplaceall(product_quantity, "单价[0-9]+元整", "")
replace product_quantity = regexreplaceall(product_quantity, "单价[0-9]+\.[0-9]+万元", "")
replace product_quantity = regexreplaceall(product_quantity, "单价[0-9]+万元", "")
replace product_quantity = regexreplaceall(product_quantity, "单价[0-9]+\.[0-9]+万", "")
replace product_quantity = regexreplaceall(product_quantity, "单价[0-9]+万", "")
replace product_quantity = regexreplaceall(product_quantity, "单价[0-9]+\.[0-9]+元", "")
replace product_quantity = regexreplaceall(product_quantity, "单价[0-9]+元", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币[0-9]+\.[0-9]+万元整", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币[0-9]+万元整", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币[0-9]+\.[0-9]+万整", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币[0-9]+万整", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币[0-9]+\.[0-9]+元整", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币[0-9]+元整", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币[0-9]+万元", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币[0-9]+\.[0-9]+万元", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币[0-9]+万", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币[0-9]+\.[0-9]+万", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币[0-9]+\.[0-9]+元", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币[0-9]+元", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+\.[0-9]+万元整", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+万元整", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+\.[0-9]+万整", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+万整", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+\.[0-9]+元整", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+元整", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+\.[0-9]+万元", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+万元", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+\.[0-9]+万", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+万", "")
replace product_quantity = regexreplaceall(product_quantity, "为[0-9]+\.[0-9]+元", "")
replace product_quantity = regexreplaceall(product_quantity, "为[0-9]+元", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+\.[0-9]+元", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+元", "")
replace product_quantity = regexreplaceall(product_quantity, "RMB[0-9]+\.[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "RMB[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+\.[0-9]+RMB", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+RMB", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币[0-9]+\.[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+\.[0-9]+人民币", "")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+人民币", "")
replace product_quantity = regexreplaceall(product_quantity, "单向总价：[0-9]+\.[0-9]+元", "")
replace product_quantity = regexreplaceall(product_quantity, "单向总价：[0-9]+元", "")
replace product_quantity = regexreplaceall(product_quantity, "单向总价：[0-9]+\.[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "单向总价：[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "（优惠价：[0-9]+\.[0-9]+）;", "")
replace product_quantity = regexreplaceall(product_quantity, "（优惠价：[0-9]+）;", "")
replace product_quantity = regexreplaceall(product_quantity, "（原价：[0-9]+\.[0-9]+,优惠价：[0-9]+\.[0-9]+）;", "")
replace product_quantity = regexreplaceall(product_quantity, "（原价：[0-9]+,优惠价：[0-9]+）;", "")
replace product_quantity = regexreplaceall(product_quantity, "各类项目合计[0-9]+\.[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "共计[0-9]+\.[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "共计[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "总计[0-9]+\.[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "总计[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "合计[0-9]+\.[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "合计[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "小计[0-9]+\.[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "小计[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "单价[0-9]+\.[0-9]+", "")
replace product_quantity = regexreplaceall(product_quantity, "单价[0-9]+", "")

replace product_quantity = regexreplaceall(product_quantity, "人民币（万元）", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币（万）", "")
replace product_quantity = regexreplaceall(product_quantity, "人民币（元）", "")
replace product_quantity = regexreplaceall(product_quantity, "（万元）", "")
replace product_quantity = regexreplaceall(product_quantity, "（万）", "")
replace product_quantity = regexreplaceall(product_quantity, "（元）", "")
replace product_quantity = regexreplaceall(product_quantity, "（元/人）", "")
replace product_quantity = regexreplaceall(product_quantity, "（元/台）", "")
replace product_quantity = regexreplaceall(product_quantity, "（元/人月）", "")
replace product_quantity = regexreplaceall(product_quantity, "（元/年）;", "")
replace product_quantity = regexreplaceall(product_quantity, "各类项目合计", "")
replace product_quantity = regexreplaceall(product_quantity, "单价", "")
replace product_quantity = regexreplaceall(product_quantity, "小计", "")
replace product_quantity = regexreplaceall(product_quantity, "总金额", "")
replace product_quantity = regexreplaceall(product_quantity, "预算价", "")
replace product_quantity = regexreplaceall(product_quantity, "中标价", "")
replace product_quantity = regexreplaceall(product_quantity, "USD", "")
replace product_quantity = regexreplaceall(product_quantity, "EUR", "")
replace product_quantity = regexreplaceall(product_quantity, "$", "")
replace product_quantity = regexreplaceall(product_quantity, "￥", "")

	// 3.6 clear the quantity information from the product variable
local quantifiers "个 件 位 名 元/台 台 辆 支 根 条 把 瓶 盒 袋 张 盘 碗 罐 盆 箱 瓶 匹 双 层 次 团 批 桶 扎 网 角 粒 枚 回 扇 届 桩 层 屋 棵 趟 艘 滴 班 拨 段 炉 笼 群 行 轮 招 节 批 桩 排 档 桌 场 手 次 盘 局 盏 层 梯 座 回 轮 航 次 批 笔 次 局 届 次 回 项 本 吨 套 宗 尾 筒 公里 人/元/月 人/天 人 人份 cm/平方米 栋 页 间 升 千克 公斤 亩 千瓦 户 份 册 天 块 卷 组 付 令 株 日辆 车辆 工时 版 部 千印 门 个月 月 头 只 片 日 对 只 小时 具 台\1年 g kw ㎡ 副 平米 平方 平方米 立方米 立方 顶 M 延米 ug ml 间 斤"

foreach var in product_quantity {
    foreach quantifier of local quantifiers {
        local pattern1 "(约[0-9]+\.[0-9]+`quantifier')"
		local pattern2 "(约[0-9]+`quantifier')"
		local pattern3 "(约[0-9]+\.[0-9]+/`quantifier')"
		local pattern4 "(约[0-9]+/`quantifier')"
        local pattern5 "([0-9]+\.[0-9]+`quantifier')"
		local pattern6 "([0-9]+`quantifier')"
		local pattern7 "([0-9]+\.[0-9]+/`quantifier')"
		local pattern8 "([0-9]+/`quantifier')"
		local pattern9 "(\/`quantifier')"
		local pattern10 "(每`quantifier')"
		local pattern11 "(一`quantifier')"
		local pattern12 "(采购数量：[0-9]+)"
		
		
        replace `var' = regexreplaceall(`var', "`pattern1'", "")
		replace `var' = regexreplaceall(`var', "`pattern2'", "")
		replace `var' = regexreplaceall(`var', "`pattern3'", "")
		replace `var' = regexreplaceall(`var', "`pattern4'", "")
		replace `var' = regexreplaceall(`var', "`pattern5'", "")
		replace `var' = regexreplaceall(`var', "`pattern6'", "")
		replace `var' = regexreplaceall(`var', "`pattern7'", "")
		replace `var' = regexreplaceall(`var', "`pattern8'", "")
		replace `var' = regexreplaceall(`var', "`pattern9'", "")
		replace `var' = regexreplaceall(`var', "`pattern10'", "")
		replace `var' = regexreplaceall(`var', "`pattern11'", "")
		replace `var' = regexreplaceall(`var', "`pattern12'", "")
		replace `var' = "." if `var' == "`quantifier'"
		replace `var' = regexreplaceall(`var', "/米", "")
    }
}
replace product_quantity = "." if product_quantity == "一包"

	// 3.7 formatting
replace product_quantity = regexr(product_quantity, "等$", "")

replace product_quantity = "." if regexm(product_quantity, "^[0-9\.，,;；/、\\]+$")
replace product_quantity = "." if regexm(product_quantity, "^[\.，,;；/、\\]+$")
replace product_quantity = "." if regexm(product_quantity, "^[0-9]+$")

replace product_price = regexreplaceall(product_quantity, "([0-9]+.;", "")

replace product_quantity = "." if product_quantity == ";"
	// cleanup potential multiple semicolons caused by replacements
replace product_quantity = regexreplaceall(product_quantity, ";;+", ";")
replace product_quantity = regexreplaceall(product_quantity, ":;", ";")
replace product_quantity = regexreplaceall(product_quantity, ": ;", ";")
replace product_quantity = regexreplaceall(product_quantity, "：;", ";")
replace product_quantity = regexreplaceall(product_quantity, "： ;", ";")
replace product_quantity = regexr(product_quantity, "/;$", ";")
replace product_quantity = regexreplaceall(product_quantity, ",;", ";")
replace product_quantity = regexreplaceall(product_quantity, "，;", ";")
replace product_quantity = regexreplaceall(product_quantity, "/;", ";")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+\.[0-9]+;", ";")
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+;", ";")
replace product_quantity = regexreplaceall(product_quantity, "\([0-9]+\.[0-9]+\);", ";")
replace product_quantity = regexreplaceall(product_quantity, "\([0-9]+.\);", ";")

replace product_quantity = regexreplaceall(product_quantity, "\（[0-9]+\.[0-9]+\）", "") 
replace product_quantity = regexreplaceall(product_quantity, "\([0-9]+\)", "") 
replace product_quantity = "." if product_quantity == "^[0-9].$"
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+$", "") 
replace product_quantity = regexreplaceall(product_quantity, "[0-9]+\.$", "")
replace product_quantity = regexreplaceall(product_quantity, "（[0-9]+\.）", "")
replace product_quantity = regexreplaceall(product_quantity, "\([0-9]+\.\)", "")
replace product_quantity = regexreplaceall(product_quantity, "（[0-9]\.）", "")
replace product_quantity = regexreplaceall(product_quantity, "\([0-9]\.\)", "")

replace product_quantity = regexreplaceall(product_quantity, "（原价：优惠价：）", "")
replace product_quantity = regexreplaceall(product_quantity, "（优惠价：）", "")
replace product_quantity = regexreplaceall(product_quantity, "（）", "") 
replace product_quantity = regexreplaceall(product_quantity, "\(\)", "") 

replace product_quantity = regexr(product_quantity, "^;", "")
replace product_quantity = regexr(product_quantity, "^。", "")
replace product_quantity = regexr(product_quantity, "^，", "")   
replace product_quantity = regexr(product_quantity, "^,", "")  
replace product_quantity = regexr(product_quantity, "^：", "") 
replace product_quantity = regexr(product_quantity, "^:", "")
replace product_quantity = regexr(product_quantity, "^/", "")
replace product_quantity = regexr(product_quantity, "^、", "")
replace product_quantity = regexr(product_quantity, "^;+", "") 
replace product_quantity = regexr(product_quantity, "^\\+", "") 

replace product_quantity = regexr(product_quantity, ";+$", "")
replace product_quantity = regexr(product_quantity, ";$", "")
replace product_quantity = regexr(product_quantity, "。+$", "")
replace product_quantity = regexr(product_quantity, "，+$", "")   
replace product_quantity = regexr(product_quantity, ",+$", "")  
replace product_quantity = regexr(product_quantity, "：$", "") 
replace product_quantity = regexr(product_quantity, ":$", "")
replace product_quantity = regexr(product_quantity, "/$", "")
replace product_quantity = regexr(product_quantity, "、$", "")
replace product_quantity = regexr(product_quantity, "\\+$", "")
replace product_quantity = regexreplaceall(product_quantity, "(,*)", "")
replace product_quantity = regexreplaceall(product_quantity, "(*;)", ";")
replace product_quantity = regexreplaceall(product_quantity, "(：;)", ";")
replace product_quantity = regexreplaceall(product_quantity, "(:;)", ";")
replace product_quantity = regexreplaceall(product_quantity, "($;)", ";")
replace product_quantity = regexreplaceall(product_quantity, "(;;)", ";")
replace product_quantity = regexreplaceall(product_quantity, "(：-;)", ";")
replace product_quantity = regexreplaceall(product_quantity, "(--;)", ";")

replace product_price = product_quantity if regexm(product_quantity, ";")

drop flag fix product_quantity

//--------------
// Step 3: get product information from 主要标的名称 and 规格型号或服务要求
gen product = ""


// if 主要标的名称 and 规格型号或服务要求 have the same entry, keep 主要标的名称 as product name 
replace product = 主要标的名称 if trim(主要标的名称) == trim(规格型号或服务要求) & product_price == "."

// if 规格型号或服务要求 is missing, keep 主要标的名称 as product name only
replace product = 主要标的名称 if 规格型号或服务要求 == "." & product_price == "."

// if 主要标的名称 is missing, keep 规格型号或服务要求 as product name only
replace product = 规格型号或服务要求 if 主要标的名称 == "." & product_price == "."

// if 主要标的名称 and 规格型号或服务要求 are similar, take whichever is longer as product name 
gen match = regexm(主要标的名称, 规格型号或服务要求) | regexm(规格型号或服务要求, 主要标的名称)
replace product = cond(length(主要标的名称) > length(规格型号或服务要求), 主要标的名称, 规格型号或服务要求) if match == 1 & product_price == "."
drop match

// if 主要标的名称 and 规格型号或服务要求 are the same, keep  主要标的名称 as product name only
replace product = 主要标的名称 if 主要标的名称 == 规格型号或服务要求 & product_price == "."

// generate a flag variable to catch entries in 主要标的单价 contain only punctuation and product and product_price are missing
//？
gen flag = regexm(主要标的数量, "[,;/、]") & product =="." & product_price == "."

sort(flag)

// if the price variable contains the information for one product only, replace entries in product with a combination of 主要标的名称 and 规格型号或服务要求
replace product = 主要标的名称 + ": " + 规格型号或服务要求 if product_price == "." & missing(product) & 主要标的名称 != "." & 规格型号或服务要求 != "." & flag == 0

replace product = subinstr(product, "、", ";", .) if regexm(trim(主要标的数量), "[,;/、]")==0
replace product = subinstr(product, ";",  , .) if regexm(trim(主要标的数量), "[,;/、]")==0

replace product = regexr(product, "^;+", "")  
replace product = regexr(product, ";+$", "")
replace product = regexr(product, "。+$", "")
replace product = regexr(product, "，+$", "")   
replace product = regexr(product, ",+$", "")  
replace product = regexr(product, "：$", "") 
replace product = regexr(product, ":$", "")
replace product = regexr(product, "等$", "")

// ? after running sampling for 10 times, no flag == 1 showed up
// so does not replace punctuation with ; later on
drop flag

// remove quantity info from the product variable
local quantifiers "个 件 位 名 台 辆 支 根 条 把 瓶 盒 包 袋 张 盘 碗 罐 盆 箱 瓶 匹 双 层 次 团 批 桶 扎 网 角 粒 枚 回 扇 届 桩 层 屋 棵 趟 艘 滴 班 拨 段 炉 笼 群 行 轮 招 节 批 桩 排 档 桌 场 手 次 盘 局 盏 层 梯 座 回 轮 航 次 批 笔 次 局 届 次 回 项 本 吨 套 宗 尾 筒 公里 人 人份 人/天 cm/平方米 米 平米 平方 平方米 立方米 立方 栋 页 间 升 千克 公斤 亩 千瓦 户 份 册 天 块 卷 组 付 令 株 日辆 车辆 工时 版 部 千印 门 个月 月 头 只 片 日 对 只 小时 具 台\1年 g kw ㎡ 副 顶"

foreach var in product {
    foreach quantifier of local quantifiers {
        local pattern1 "(约[0-9]+`quantifier')"
		local pattern2 "(约[0-9]+/`quantifier')"
        local pattern3 "([0-9]+`quantifier')"
		local pattern4 "([0-9]+/`quantifier')"
		local pattern5 "(/`quantifier')"
		local pattern6 "(每`quantifier')"
		local pattern7 "(一`quantifier')"
		local pattern8 "(采购数量：[0-9]+)"
		
		
        replace `var' = regexreplaceall(`var', "`pattern1'", "")
		replace `var' = regexreplaceall(`var', "`pattern2'", "")
		replace `var' = regexreplaceall(`var', "`pattern3'", "")
		replace `var' = regexreplaceall(`var', "`pattern4'", "")
		replace `var' = regexreplaceall(`var', "`pattern5'", "")
		replace `var' = regexreplaceall(`var', "`pattern6'", "")
		replace `var' = regexreplaceall(`var', "`pattern7'", "")
		replace `var' = regexreplaceall(`var', "`pattern8'", "")
		replace `var' = "." if `var' == "`quantifier'"
    }
}

replace product = product_price if missing(product)
drop product_price

// Step 4: split the product
split product, parse(";") generate(product)
