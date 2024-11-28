// 255,134 observations in total
// 765.85s
timer clear
timer on 1
use "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/04-single.dta", replace


/*
	Section I: product variable cleaning
	accuracy rate: 
	1. 
	
	可能存在的问题：
	1. 包含multiple product的情况
	count if regexm(主要标的单价,";|；|、") 1,514

	
*/
	// Since now the dataset only contains contract with single item procured, we obtain product information from 主要标的名称 and 规格型号或服务 directly.
gen product1 = ""

	// cond 1: if 主要标的名称 and 规格型号或服务要求 have the same entry, keep 主要标的名称 as product name 
	// 18,967 real changes made
replace product1 = 主要标的名称 if trim(主要标的名称) == trim(规格型号或服务要求)

	// cond 2: if 规格型号或服务要求 is missing, keep 主要标的名称 as product name only
	// 92,203 real changes made
replace product1 = 主要标的名称 if 规格型号或服务要求 == "."

	// cond 3: if 主要标的名称 is missing, keep 规格型号或服务要求 as product name only
	// 1,037 real changes made
replace product1 = 规格型号或服务要求 if 主要标的名称 == "."

	// cond 4: if 主要标的名称 and 规格型号或服务要求 are similar, take whichever is longer as product name
	// 16,864 real changes made	
gen match = regexm(主要标的名称, 规格型号或服务要求) | regexm(规格型号或服务要求, 主要标的名称)
replace product1 = cond(length(主要标的名称) > length(规格型号或服务要求), 主要标的名称, 规格型号或服务要求) if match == 1
drop match

	// cond 5: for remaining observations, product information is generated from the combination of 主要标的名称 and 规格型号或服务要求
gen product_spec = 规格型号或服务要求 // variable to store specification information

// product specification cleaning
local quantifiers "个 件 位 名 台 辆 支 根 条 把 瓶 盒 包 袋 张 盘 碗 罐 盆 箱 瓶 匹 双 层 次 团 批 桶 扎 网 角 面 粒 枚 回 扇 届 桩 层 屋 棵 趟 艘 滴 班 拨 段 炉 笼 群 行 轮 招 节 批 桩 排 档 桌 场 手 次 盘 局 盏 层 梯 座 回 轮 航 次 批 笔 次 局 届 次 回 项 本 吨 套 宗 尾 筒 公里 人 人份 人/天 cm/平方米 米 平米 平方 平方米 立方米 立方 栋 页 间 升 千克 公斤 亩 千瓦 户 份 册 天 块 卷 组 付 令 株 日辆 车辆 工时 计 版 部 千印 门 个月 月 头 只 片 日 对 只 小时 具 台\1年 kg g kw ㎡ 副"
foreach var in product_spec {
    foreach quantifier of local quantifiers {
		replace `var' = "." if `var' == "`quantifier'"
    }
}
	// 1,607 real changes made; 41 real changes made
foreach var in product_spec {
    replace `var' = "." if regexm(`var', "(^[0-9]+$)")
	replace `var' = "." if regexm(`var', "(^[0-9]+\.[0-9]+$)") 
}
	// 100,685 real changes made
replace product1 = 主要标的名称 + ": " + product_spec if missing(product1) & 主要标的名称 != "." & 规格型号或服务要求 != "."
drop product_spec

//------------------------------------------------------------------------------
/*
	Section II: quantity variable cleaning
	accuracy rate: 
	1. 
	
	可能存在的问题：
	1. multiple products
	
	notes:
	1. 在data cleaning过程中，把可能的multiple products的delimiter换成了;（但是可能只有一个quanitty）

	
*/
gen quantity1 = 主要标的数量
	// Step 1: remove price information from quantity variable
replace quantity1 = regexreplaceall(quantity1, "单价([0-9]+\.[0-9]+)万元整", "")
replace quantity1 = regexreplaceall(quantity1, "单价([0-9]+\.[0-9]+)万整", "")
replace quantity1 = regexreplaceall(quantity1, "单价([0-9]+\.[0-9]+)元整", "")
replace quantity1 = regexreplaceall(quantity1, "单价([0-9]+\.[0-9]+)万元", "")
replace quantity1 = regexreplaceall(quantity1, "单价([0-9]+\.[0-9]+)万", "")
replace quantity1 = regexreplaceall(quantity1, "单价([0-9]+\.[0-9]+)元", "")
replace quantity1 = regexreplaceall(quantity1, "人民币([0-9]+\.[0-9]+)万元整", "")
replace quantity1 = regexreplaceall(quantity1, "人民币([0-9]+\.[0-9]+)万整", "")
replace quantity1 = regexreplaceall(quantity1, "人民币([0-9]+\.[0-9]+)元整", "")
replace quantity1 = regexreplaceall(quantity1, "人民币([0-9]+\.[0-9]+)万元", "")
replace quantity1 = regexreplaceall(quantity1, "人民币([0-9]+\.[0-9]+)万", "")
replace quantity1 = regexreplaceall(quantity1, "人民币([0-9]+\.[0-9]+)元", "")
replace quantity1 = regexreplaceall(quantity1, "总金额([0-9]+\.[0-9]+)万", "")
replace quantity1 = regexreplaceall(quantity1, "总金额([0-9]+\.[0-9]+)元", "")
replace quantity1 = regexreplaceall(quantity1, "([0-9]+\.[0-9]+)万元整", "")
replace quantity1 = regexreplaceall(quantity1, "([0-9]+\.[0-9]+)万整", "")
replace quantity1 = regexreplaceall(quantity1, "([0-9]+\.[0-9]+)元整", "")
replace quantity1 = regexreplaceall(quantity1, "([0-9]+\.[0-9]+)万元", "")
replace quantity1 = regexreplaceall(quantity1, "([0-9]+\.[0-9]+)元", "")
replace quantity1 = regexreplaceall(quantity1, "RMB([0-9]+\.[0-9]+)", "")
replace quantity1 = regexreplaceall(quantity1, "([0-9]+\.[0-9]+)RMB", "")
replace quantity1 = regexreplaceall(quantity1, "人民币([0-9]+\.[0-9]+)", "")
replace quantity1 = regexreplaceall(quantity1, "([0-9]+\.[0-9]+)人民币", "")
replace quantity1 = regexreplaceall(quantity1, "单项总价：([0-9]+\.[0-9]+)元", "")
replace quantity1 = regexreplaceall(quantity1, "单项总价：[([0-9]+\.[0-9]+)", "")
replace quantity1 = regexreplaceall(quantity1, "（原价：([0-9]+\.[0-9]+),优惠价：([0-9]+\.[0-9]+)）;", "")
replace quantity1 = regexreplaceall(quantity1, "￥", "")
replace quantity1 = regexreplaceall(quantity1, "共计([0-9]+\.[0-9]+)", "")
replace quantity1 = regexreplaceall(quantity1, "总计([0-9]+\.[0-9]+)", "")
replace quantity1 = regexreplaceall(quantity1, "合计([0-9]+\.[0-9]+)", "")
replace quantity1 = regexreplaceall(quantity1, "小计([0-9]+\.[0-9]+)", "")
replace quantity1 = regexreplaceall(quantity1, "单价([0-9]+\.[0-9]+)", "")

replace quantity1 = regexreplaceall(quantity1, "单价[0-9]+万元整", "")
replace quantity1 = regexreplaceall(quantity1, "单价[0-9]+万整", "")
replace quantity1 = regexreplaceall(quantity1, "单价[0-9]+元整", "")
replace quantity1 = regexreplaceall(quantity1, "单价[0-9]+万元", "")
replace quantity1 = regexreplaceall(quantity1, "单价[0-9]+万", "")
replace quantity1 = regexreplaceall(quantity1, "单价[0-9]+元", "")
replace quantity1 = regexreplaceall(quantity1, "人民币[0-9]+万元整", "")
replace quantity1 = regexreplaceall(quantity1, "人民币[0-9]+万整", "")
replace quantity1 = regexreplaceall(quantity1, "人民币[0-9]+元整", "")
replace quantity1 = regexreplaceall(quantity1, "人民币[0-9]+万元", "")
replace quantity1 = regexreplaceall(quantity1, "人民币[0-9]+万", "")
replace quantity1 = regexreplaceall(quantity1, "人民币[0-9]+元", "")
replace quantity1 = regexreplaceall(quantity1, "总金额[0-9]+万", "")
replace quantity1 = regexreplaceall(quantity1, "总金额[0-9]+元", "")
replace quantity1 = regexreplaceall(quantity1, "[0-9]+万元整", "")
replace quantity1 = regexreplaceall(quantity1, "[0-9]+万整", "")
replace quantity1 = regexreplaceall(quantity1, "[0-9]+元整", "")
replace quantity1 = regexreplaceall(quantity1, "[0-9]+万元", "")
replace quantity1 = regexreplaceall(quantity1, "[0-9]+元", "")
replace quantity1 = regexreplaceall(quantity1, "RMB[0-9]+", "")
replace quantity1 = regexreplaceall(quantity1, "[0-9]+RMB", "")
replace quantity1 = regexreplaceall(quantity1, "人民币[0-9]+", "")
replace quantity1 = regexreplaceall(quantity1, "[0-9]+人民币", "")
replace quantity1 = regexreplaceall(quantity1, "单项总价：[0-9]+元", "")
replace quantity1 = regexreplaceall(quantity1, "单项目总价：[0-9]+", "")
replace quantity1 = regexreplaceall(quantity1, "人民币（万元）", "")
replace quantity1 = regexreplaceall(quantity1, "人民币（万）", "")
replace quantity1 = regexreplaceall(quantity1, "人民币（元）", "")
replace quantity1 = regexreplaceall(quantity1, "（万元）", "")
replace quantity1 = regexreplaceall(quantity1, "（万）", "")
replace quantity1 = regexreplaceall(quantity1, "（元）", "")
replace quantity1 = regexreplaceall(quantity1, "（元/人）", "")
replace quantity1 = regexreplaceall(quantity1, "（元/台）", "")
replace quantity1 = regexreplaceall(quantity1, "（元/人月）", "")
replace quantity1 = regexreplaceall(quantity1, "（元/年）;", "")
replace quantity1 = regexreplaceall(quantity1, "（原价：[0-9]+,优惠价：[0-9]+）;", "")
replace quantity1 = regexreplaceall(quantity1, "￥", "")
replace quantity1 = regexreplaceall(quantity1, "共计[0-9]+", "")
replace quantity1 = regexreplaceall(quantity1, "总计[0-9]+", "")
replace quantity1 = regexreplaceall(quantity1, "合计[0-9]+", "")
replace quantity1 = regexreplaceall(quantity1, "小计[0-9]+", "")
replace quantity1 = regexreplaceall(quantity1, "单价[0-9]+.", "")
replace quantity1 = regexreplaceall(quantity1, "单价[0-9]+", "")
replace quantity1 = regexreplaceall(quantity1, "单价", "")

	// Step 2: formatting
replace quantity = regexreplaceall(quantity, "\(\)", "") 
replace quantity = regexr(quantity, "^;+", "")  
replace quantity = regexr(quantity, ";+$", "")
replace quantity = regexr(quantity, "。+$", "")
replace quantity = regexr(quantity, "，+$", "")   
replace quantity = regexr(quantity, ",+$", "")  
replace quantity = regexr(quantity, "：$", "") 
replace quantity = regexr(quantity, ":$", "")
replace quantity = subinstr(quantity, "，", ";", .)
replace quantity = subinstr(quantity, ",", ";", .)

	// Step 3: keep quantity information only
local quantifiers "个 件 位 名 台 辆 支 根 条 把 瓶 盒 包 袋 张 盘 碗 罐 盆 箱 瓶 匹 双 层 次 团 批 桶 扎 网 角 面 粒 枚 回 扇 届 桩 层 屋 棵 趟 艘 滴 班 拨 段 炉 笼 群 行 轮 招 节 批 桩 排 档 桌 场 手 次 盘 局 盏 层 梯 座 回 轮 航 次 批 笔 次 局 届 次 回 项 本 吨 套 宗 尾 筒 公里 人 人份 人/天 cm/平方米 平方米 米 平米 平方  立方米 立方 栋 页 间 升 千克 公斤 亩 千瓦 户 份 册 天 块 卷 组 付 令 株 日辆 车辆 工时 计 版 部 千印 门 个月 月 头 只 片 日 对 只 小时 具 台\1年 g kw ㎡ 副 部"
foreach var in quantity1{
	foreach quantifier of local quantifiers {
		replace `var' = regexs(1) if regexm(`var', "([0-9]+(\.[0-9]+)?/?`quantifier')")
	}
}
foreach var in quantity1{
		replace `var' = regexs(1) if regexm(`var', "\([0-9]+\)$")
}

local patterns "一个 一台 一辆 一支 一把 一套 一张 一门 一组 一块 一份 一间 一栋 一宗 一批 一本 一项 一次 一座 一场 一艘 一匹 一批 一年 一整套 一部 一幢"

foreach pattern of local patterns {
    replace quantity1 = regexreplaceall(quantity1, "一", "1") if regexm(quantity1, "`pattern'")
}

replace quantity1 = regexreplaceall(quantity1, "一", "1") if quantity1 == "一包"    
replace quantity1 = regexreplaceall(quantity1, "一", "1") if quantity1 == "一"             

//------------------------------------------------------------------------------
/*
	Section III: price variable cleaning
	accuracy rate: 
	
	可能存在的问题：
	1. 当product name跟价格之间没有分隔符，无法extract price information
	2. 当标点符号是用于分割句子而不是product的时候，the price variables generated does not make sense
	2. price是繁体字中文
	3. 有多个商品且价格单位为万元时
	4. 句号有时候用来分隔product
*/
 
gen price1 = 主要标的单价

	// Step 1: basic data cleaning
	// 540 real changes made
replace price1 = regexreplaceall(price, "￥", "")
replace price1 = regexreplaceall(price, "人民币", "")
replace price1 = regexreplaceall(price, "RMB", "")
replace price1 = regexreplaceall(price, "CNY", "")
// replace price = regexreplaceall(price, "元", "")

	// Step 2: remove quantity information from the price variable
local quantifiers "个 件 位 名 台 辆 支 根 条 把 瓶 盒 包 袋 张 盘 碗 罐 盆 箱 瓶 匹 双 层 次 团 批 桶 扎 网 角 面 粒 枚 回 扇 届 桩 层 屋 棵 趟 艘 滴 班 拨 段 炉 笼 群 行 轮 招 节 批 桩 排 档 桌 场 手 次 盘 局 盏 层 梯 座 回 轮 航 次 批 笔 次 局 届 次 回 项 本 吨 套 宗 尾 筒 公里 人 人份 人/天 cm/平方米 平方米 米 平米 平方  立方米 立方 栋 页 间 升 千克 公斤 亩 千瓦 户 份 册 天 块 卷 组 付 令 株 日辆 车辆 工时 计 版 部 千印 门 个月 月 头 只 片 日 对 只 小时 具 台\1年 g kw ㎡ 副 部"

foreach var in price1 {
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


	// Step 3: price1 information cleaning
	// 3.1: case with "万元"/“万”, convert to numeric values
gen temp_price1 = real(regexr(price1, "万", "")) if regexm(price1, "万")
replace temp_price1 = temp_price1 * 10000 if regexm(price1, "万")
tostring temp_price1, replace format(%20.0g)
replace price1 = temp_price1 if temp_price1 != "."
drop temp_* 

gen temp_price1 = real(regexr(price1, "万元", "")) if regexm(price1, "万元")
replace temp_price1 = temp_price1 * 10000 if regexm(price1, "万元")
tostring temp_price1, replace format(%20.0g)
replace price1 = temp_price1 if temp_price1 != "."
drop temp_* 

	// 3.2: remove comma used for separating numbers; different format enumerated
gen flag = regexm(主要标的单价, "^[0-9][0-9][0-9]\,[0-9][0-9][0-9]\,[0-9][0-9][0-9]")
replace price1 = regexreplaceall(price1, ",", "", .) if flag
drop flag

gen flag = regexm(主要标的单价, "^[0-9][0-9]\,[0-9][0-9][0-9]\,[0-9][0-9][0-9]")
replace price1 = regexreplaceall(price1, ",", "", .) if flag
drop flag

gen flag = regexm(主要标的单价, "^[0-9]\,[0-9][0-9][0-9]\,[0-9][0-9][0-9]")
replace price1 = regexreplaceall(price1, ",", "", .) if flag
drop flag

gen flag = regexm(主要标的单价, "^[0-9][0-9][0-9]\,[0-9][0-9][0-9]")
replace price1 = regexreplaceall(price1, ",", "", .) if flag
drop flag

gen flag = regexm(主要标的单价, "^[0-9][0-9]\,[0-9][0-9][0-9]")
replace price1 = regexreplaceall(price1, ",", "", .) if flag
drop flag

gen flag = regexm(主要标的单价, "^[0-9]\,[0-9][0-9][0-9]")
replace price1 = regexreplaceall(price1, ",", "", .) if flag
drop flag
	
gen flag = regexm(主要标的单价, "[0-9][0-9][0-9]\,[0-9][0-9][0-9]\,[0-9][0-9][0-9]\.[0-9][0-9]")
replace price1 = regexreplaceall(price1, ",", "", .) if flag
drop flag

gen flag = regexm(主要标的单价, "[0-9][0-9]\,[0-9][0-9][0-9]\,[0-9][0-9][0-9]\.[0-9][0-9]")
replace price1 = regexreplaceall(price1, ",", "", .) if flag
drop flag

gen flag = regexm(主要标的单价, "[0-9]\,[0-9][0-9][0-9]\,[0-9][0-9][0-9]\.[0-9][0-9]")
replace price1 = regexreplaceall(price1, ",", "", .) if flag
drop flag

gen flag = regexm(主要标的单价, "[0-9][0-9][0-9]\,[0-9][0-9][0-9]\.[0-9][0-9]")
replace price1 = regexreplaceall(price1, ",", "", .) if flag
drop flag

gen flag = regexm(主要标的单价, "[0-9][0-9]\,[0-9][0-9][0-9]\.[0-9][0-9]")
replace price1 = regexreplaceall(price1, ",", "", .) if flag
drop flag

gen flag = regexm(主要标的单价, "[0-9]\,[0-9][0-9][0-9]\.[0-9][0-9]")
replace price1 = regexreplaceall(price1, ",", "", .) if flag
drop flag

	//3.3: data formatting
replace price1 = regexreplaceall(price1, "元", "") if regexm(price1, "[0-9]+元")
replace price1 = regexreplaceall(price1, "元", "") if regexm(price1, "[0-9]+\.[0-9]+元")
replace price1 = regexreplaceall(price1, "元", "") if regexm(price1, "[0-9]+（元）")
replace price1 = regexreplaceall(price1, "元", "") if regexm(price1, "[0-9]+\.[0-9]+（元）")
replace price1 = regexreplaceall(price1, ";", ";") if regexm(price1, "[0-9]+;")
replace price1 = regexreplaceall(price1, ";", ";") if regexm(price1, "[0-9]+$")
replace price1 = regexreplaceall(price1, ";", ";") if regexm(price1, "[0-9]+\.[0-9]+;")
replace price1 = regexreplaceall(price1, ";", ";") if regexm(price1, "[0-9]+\.[0-9]+$")
replace price1 = subinstr(price1, "；", ";", .)
replace price1 = subinstr(price1, "、", ";", .) if !regexm(price1, "^1、|一、")
replace price1 = subinstr(price1, "，", ";", .)
replace price1 = subinstr(price1, ",", ";", .)

replace price1 = regexr(price1, "^;", "")
replace price1 = regexr(price1, "^。", "")
replace price1 = regexr(price1, "^，", "")   
replace price1 = regexr(price1, "^,", "")  
replace price1 = regexr(price1, "^：", "") 
replace price1 = regexr(price1, "^:", "")
replace price1 = regexr(price1, "^/", "")
replace price1 = regexr(price1, "^、", "")
replace price1 = regexr(price1, "^;+", "") 
replace price1 = regexr(price1, "^\\+", "") 

replace price1 = regexr(price1, ";+$", "")
replace price1 = regexr(price1, ";$", "")
replace price1 = regexr(price1, "。+$", "")
replace price1 = regexr(price1, "，+$", "")   
replace price1 = regexr(price1, ",+$", "")  
replace price1 = regexr(price1, "：$", "") 
replace price1 = regexr(price1, ":$", "")
replace price1 = regexr(price1, "/$", "")
replace price1 = regexr(price1, "、$", "")
replace price1 = regexr(price1, "\\+$", "")
replace price1 = regexreplaceall(price1, "(,*)", "")
replace price1 = regexreplaceall(price1, "(*;)", ";")
replace price1 = regexreplaceall(price1, "(：;)", ";")
replace price1 = regexreplaceall(price1, "(:;)", ";")
replace price1 = regexreplaceall(price1, "($;)", ";")
replace price1 = regexreplaceall(price1, "(;;)", ";")
replace price1 = regexreplaceall(price1, "(：-;)", ";")
replace price1 = regexreplaceall(price1, "(--;)", ";")
replace price1 = regexreplaceall(price1, "(--;)", ";")
replace price1 = regexreplaceall(price1, "\(\)", ";")

replace price1 = regexreplaceall(price1, "（）", "")
replace price1 = regexreplaceall(price1, "\(\)", "")
replace price1 = regexreplaceall(price1, "（\)", "")
replace price1 = regexreplaceall(price1, "---", "")
replace price1 = regexreplaceall(price1, "等$", "")

	// 3.4 extract price information only
foreach var in price1{
		local pattern1 "([0-9]+元)"
		local pattern2 "([0-9]+)\.([0-9]+元)"
		local pattern3 "[0-9]+$"
		local pattern4 "([0-9]+)\.([0-9]+)$"


        replace `var' = regexs(1) if regexm(`var', "pattern1'")
		replace `var' = regexs(1) if regexm(`var', "pattern2'")
		replace `var' = regexs(1) if regexm(`var', "pattern3'")
		replace `var' = regexs(1) if regexm(`var', "pattern4'")
}

//------------------------------------------------------------------------------
/*
	Section IV: Extrac cases for multiple product cases
	accuracy rate: 
	
	可能存在的问题：
	1. 
*/
gen flag = .
	
	// 4.1 pattern of multiple products
	// 4.1.1 cases which list items in a sequence using numbers 
replace flag = 1 if regexm(price1,"^1\..*2\.")& missing(flag)
replace flag = 1 if regexm(price1,"^1、.*2、")& missing(flag)
replace flag = 1 if regexm(price1,"^（1）.*（2）")& missing(flag)
replace flag = 1 if regexm(price1,"^一、.*二、")& missing(flag)

	// 4.1.2 cases with "："
replace flag = 1 if regexm(price1, "：.*：") & regexm(主要标的数量, "：.*：") & missing(flag)
replace flag = 1 if regexm(price1,".*：.*：") & missing(flag)
replace flag = 1 if regexm(price1,".*:.*:") & missing(flag)
replace flag = 1 if regexm(price1,".*：.*:") & missing(flag)
replace flag = 1 if regexm(price1,".*：.*：") & missing(flag)
replace flag = 1 if regexm(price1,".*：.*:") & missing(flag)

	// 4.1.3 cases with ":"
replace flag = 1 if regexm(price1, ":[0-9]+.*:[0-9]+") & regexm(主要标的数量, ".*[0-9]+.*[0-9]+") & missing(flag)
replace flag = 1 if regexm(price1,".*:.*:") & missing(flag)

	// 4.1.4 cases with "/"
replace flag = 1 if regexm(price1, "^[0-9]+/[0-9]+") & regexm(主要标的数量, "^[0-9]+/[0-9]+") & missing(flag)
replace flag = 1 if regexm(price1, "^[0-9]+\.[0-9]+/[0-9]+[0-9]+\.[0-9]") & missing(flag)
replace flag = 1 if regexm(price1, "^[0-9]+\.[0-9]+/[0-9]+[0-9]+\.[0-9]") & missing(flag)

replace flag = 1 if regexm(price1, "[0-9]+(\.[0-9]+)?/[0-9]+(\.[0-9]+)?") & missing(flag)
replace flag = 1 if regexm(price1, "[0-9]+(\.[0-9]+)?/.*[0-9]+$") & regexm(主要标的数量, "[0-9]+(\.[0-9]+)?/.*[0-9]+$") & missing(flag)
replace flag = 5 if regexm(price1,"^[0-9]+.*/[0-9]+.*") & missing(flag)
replace flag = 5 if regexm(price1,"[0-9]+.*/.*[0-9]+.*/.*[0-9]+.*") & missing(flag)

	// 4.1.5 cases with "." and "。"
replace flag = 1 if regexm(price1, "[0-9]+\.[0-9]+") & regexm(主要标的数量, "[0-9]+、[0-9]+") & missing(flag)
replace flag = 5 if regexm(price1, "[0-9]+。.*[0-9]+") & regexm(主要标的数量, "[0-9]+、[0-9]+") & missing(flag)

	// 4.1.6 cases with "、" and ";"
replace flag = 1 if regexm(price1, "^[0-9]+、[0-9]+") & regexm(主要标的数量, "^[0-9]+、[0-9]+") & missing(flag)
replace flag = 1 if regexm(price1, "[0-9]+、[0-9]+") & regexm(主要标的数量, "[0-9]+、.*[0-9]+") & missing(flag)

replace flag = 1 if regexm(price1, "^[0-9]+(\.[0-9]+);.*[0-9]+(\.[0-9]+)?$") & missing(flag)
replace flag = 1 if regexm(price1, "[0-9]+(\.[0-9]+)万元;[0-9]+(\.[0-9]+)?万元") & regexm(主要标的数量, "^[0-9]+.*、[0-9]+") & missing(flag)

replace flag = 1 if regexm(price1, "^[0-9]+;[0-9]+") & regexm(主要标的数量, "^[0-9]+(\.[0-9]+)?(；|、)[0-9]+(\.[0-9]+)?") & missing(flag)
replace flag = 1 if regexm(price1, "[0-9]+;.*[0-9]+") & regexm(主要标的数量, "^[0-9]+(\.[0-9]+)?(；|、).*[0-9]+(\.[0-9]+)?") & missing(flag)
replace flag = 1 if regexm(price1, "[0-9]+;.*[0-9]+") & regexm(主要标的数量, "[0-9]+(\.[0-9]+)?(；|、).*[0-9]+(\.[0-9]+)?") & missing(flag)
replace flag = 1 if regexm(price1, "[0-9]+;.*[0-9]+") & regexm(主要标的数量, "[0-9]+(\.[0-9]+)?(；|、).*[0-9]+(\.[0-9]+)?") & missing(flag)
replace flag = 1 if regexm(price1, "[0-9]+;.*[0-9]+") & regexm(主要标的数量, "[0-9]+(\.[0-9]+)?(；|、).*[0-9]+(\.[0-9]+)?") & missing(flag)
replace flag = 1 if regexm(price1, "[0-9]+;.*[0-9]+") & regexm(主要标的数量, "[0-9]+(\.[0-9]+)?.*(；|、).*[0-9]+(\.[0-9]+)?") & missing(flag)
replace flag = 1 if regexm(price1,"^[0-9]+;[0-9]+") & missing(flag)

	// 4.1.7 cases with "，"
replace flag = 1 if regexm(price1,"^[0-9]+，[0-9]+，") & missing(flag)
	
	// 4.1.8 cases with ")" and "）"
replace flag = 1 if regexm(price1,"）[0-9]+.*）[0-9]+") & missing(flag)
replace flag = 1 if regexm(price1,"\([0-9]+\).*\([0-9]+\)") & missing(flag)

replace flag = 1 if regexm(price1,"（[0-9]+）.*（[0-9]+）") & missing(flag)
replace flag = 1 if regexm(price1,"（[0-9]+\.[0-9]+）.*（[0-9]+\.[0-9]+）") & missing(flag)

	// 4.1.9 cases with "。" and "."
replace flag = 1 if regexm(price1,"[0-9]+.*。[0-9]+.*") & missing(flag)


	// 4.1.10 special cases
replace flag = 1 if regexm(price1, "机[0-9]+.*机)?$") & missing(flag)
replace flag = 5 if regexm(price1,"机.*[0-9]+.*机[0-9]+") & missing(flag)
replace flag = 5 if regexm(price1,"器[0-9]+.*器[0-9]+") & missing(flag)
replace flag = 5 if regexm(price1,"单价[0-9]+.*单价[0-9]+") & missing(flag)
replace flag = 5 if regexm(price1,"纸[0-9]+.*纸[0-9]+") & missing(flag)
replace flag = 5 if regexm(price1,"椅[0-9]+.*椅[0-9]+") & missing(flag)


replace flag = 5 if regexm(price1,"单[0-9]+.*册[0-9]+") & missing(flag)
replace flag = 5 if regexm(price1,"机[0-9]+.*柜[0-9]+") & missing(flag)


	// 4.2 pattern  of single product
replace flag = 0 if regexm(price1, "^[0-9]+(\.[0-9]+)?$") & missing(flag)
replace flag = 0 if regexm(主要标的数量, "^[0-9]+(\.[0-9]+)?$") & missing(flag)
replace flag = 0 if !regexm(主要标的数量, "；|/|、|,|.") & missing(flag)
replace flag = 0 if !regexm(主要标的数量, "；|/|、|,|^1\..*2\.") & missing(flag)
replace flag = 0 if price1 == "." & missing(flag)
replace flag = 0 if !regexm(price1, "[0-9]+(\.[0-9]+)?") & !regexm(price1, ";") & missing(flag)
replace flag = 0 if regexm(price1, "^（.*）$") & missing(flag)

replace flag = 0 if regexm(price1, "^[0-9]+(万元|元|年|份)$") & missing(flag)
replace flag = 0 if regexm(price1, "^[0-9]+(万元|元|年|份)$") & missing(flag)

replace flag = 0 if regexm(price1, "：[0-9]+(\.[0-9]+)?.*$")& !regexm(price1, ";")& missing(flag)

	// 4.3 final adjustments
replace flag = 0 if regexm(主要标的数量, "^[0-9]+(\.[0-9]+)?$") & flag == 5
replace flag = 0 if regexm(price1, "^[0-9]+(\.[0-9]+)?$") & flag == 1
replace flag = 0 if regexm(主要标的数量, "^[0-9]+(批|包|台。|台|套|辆|年|个标|个|支|项|部。)$") & flag == 5
replace flag = 0 if regexm(主要标的数量, "^一(批|包|台。|台|套|辆|项)$") & flag == 5
replace flag = 0 if regexm(主要标的数量, "^(总共|共|共计|总计|数量)[0-9]+(件。|台|盒)$") & flag == 5
replace flag = 0 if regexm(主要标的数量, "^(g)[0-9]+(件。|台|盒)$") & flag == 5
replace flag = 1 if flag ==5

replace flag = 1 if regexm(price1, ";") & regexm(主要标的数量,"；|/|;|,|、|，") & missing(flag)
replace flag = 0 if missing(flag)

	// 4.3 export data
preserve
keep if flag == 0
drop flag
save "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/04-single cleaned.dta", replace
restore


preserve
keep if flag == 1
drop flag product1 quantity1 price1 
save "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/04-multiple from single.dta", replace
restore


timer off 1
timer list
timer clear
