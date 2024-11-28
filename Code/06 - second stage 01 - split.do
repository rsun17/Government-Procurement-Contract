// 1094.46.68s
cd "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data"

use "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/03-prepare data - type & merge.dta", replace

// sampling
//sample 1000, count

/*
	Section I: Identify and drop all missing observations
*/
timer clear
timer on 1
	// remove all HTML entity encodings with empty strings
foreach var in 主要标的名称 规格型号或服务要求 主要标的数量 主要标的单价{
	replace `var' = subinstr(`var', "&ldquo;", "", .)
	replace `var' = subinstr(`var', "&rdquo;", "", .)
	replace `var' = subinstr(`var', "&lsquo;", "", .)
	replace `var' = subinstr(`var', "&rsquo;", "", .)
	replace `var' = subinstr(`var', "&nbsp;", "", .)
	replace `var' = subinstr(`var', "&quot;", "", .)
	replace `var' = subinstr(`var', "&amp", "", .)
	replace `var' = subinstr(`var', "&amp;ldquo", "", .)
	replace `var' = subinstr(`var', "&amp;rdquo", "", .)
	replace `var' = subinstr(`var', "&middot;", "", .)
}

	// cond1: missing values
	// 可能存在的问题：local terms does not cover all cases that are counted as missing
	// / \
foreach var in 主要标的名称 规格型号或服务 主要标的数量 主要标的单价 {
    replace `var' = "." if `var' == "无"
	replace `var' = "." if `var' == "略"
	replace `var' = "." if `var' == "涉密不得公开"
	replace `var' = "." if `var' == "涉密单位不得公开"
	replace `var' = "." if `var' == "涉密单位不得公示"
	replace `var' = "." if `var' == "不涉及"
	replace `var' = "." if `var' == "不适用"
	replace `var' = "." if `var' == "无无"
	replace `var' = "." if `var' == "无无无"
	replace `var' = "." if `var' == "/"
	replace `var' = "." if `var' == "//"
	replace `var' = "." if `var' == "/////"
	replace `var' = "." if `var' == "//////"
	replace `var' = "." if `var' == "\\"
	replace `var' = "." if `var' == "-"
	replace `var' = "." if `var' == "--"
	replace `var' = "." if `var' == "null"
	replace `var' = "." if `var' == "nullnull"
	replace `var' = "." if `var' == "*"
	replace `var' = "." if `var' == "**"
	replace `var' = "." if `var' == "元"
	replace `var' = "." if `var' == "\"
	replace `var' = "." if `var' == "\\"
	replace `var' = "." if `var' == "\\\\\\"
	replace `var' = "." if `var' == "、"
	replace `var' = "." if `var' == "---"
	replace `var' = "." if `var' == "——"
	replace `var' = "." if `var' == "—"
	replace `var' = "." if `var' == "#"
	replace `var' = "." if `var' == ""
	replace `var' = "." if `var' == "。"
	replace `var' = "." if `var' == ".."
	replace `var' = "." if `var' == "N"
}
	// cond2: terms related to "详见合同"
local terms "详情请见附件。 详情请见附件。 见合同 详见合同 祥见合同 详见合同。 详见合同文本 详见合同文本。 详见采购合同 见采购合同 详见合同清单 见合同清单 详见合同附件 详见合同附件；详见合同书附件 详情请见合同 详见附件 详见附件合同 详见附件合同。 按照合同要求 见合同原文 详见施工承包合同 详见合同书 详见政府采购合同附件 详见附件清单 详见附件下载 见附件 详见文件 详见投标文件 详见谈判文件 详见招标文件 详见采购合同及采购文件 见合同附件 详见工程量清单 详见采购文件 见采购文件 详见采购公告 详见中标成交公告及合同附件 详见合同及成交公告 详见成交公告  见成交公告 详见合作协议 详见公告 详见磋商文件 详见投标细目报价一览表 详见中标公告 详见中标公示 详见附件。 详见政府采购合同 详见竞争性磋商文件 详见招标文件、投标文件 详见招标文件。 按招标文件 详见合同公告 详情见附件合同文本 详见附件合同扫描件 详见施工合同 按标书要求 按合同约定完成服务 详见合同内容 详见合同内容； 详情见合同 详见附件和中标公告 详见《招标文件》 详见合同条款 详见清单 详见上传附件 详见双方签订的合同 详见响应性文件 详见中标合同 详见合同文件 见具体合同 详见采购计划 详见招标公告 具体详见合同 详见具体合同 详见采购文件和合同公告 详见购置清单 详见采购清单 详见上传附件。 详见签订合同 详见供货合同 详见采购需求 详见政府采购合同。 详见合同协议 详见招投标文件 详见附件信息 详见补充合同附件 见响应文件 详见响应文件 详见标书 详见磋商文件及响应文件 具体内容，详见招标文件要求。 详见采购合同附件 详见附加 详见&ldquo;招标文件&rdquo; 详见公告附件 详见相关文件 详见中标公示附件和中标单位投标文件 详见中标公告附件招标文件 详见中标公告附件 详见竞争性谈判文件 详见&quot;竞争性谈判文件&rdquo; 详见购置合同 详见合同附件。 详见规划合同 详见采购文件。 详见合同正文 详见&ldquo;竞争性谈判&rdquo;文件 详见&ldquo;合同书&rdquo; 详见公告内容 详见询价文件 详见招标文件及投标文件； 详见&ldquo;政府采购购销合同&rdquo; 详见合同扫描件 详见磋商文件。 详见合同原件 详见询价通知书 详见《采购合同》 详见成交结果公告 详见附件采购合同 详见磋商文件要求 按合同要求执行 详见文件要求 详见附表 详见合同协议书 详见采购人与中标单位的采购合同 详见采购合同。 详见招标投标文件及工程量清单 详见供销合同 详见中标通知书附件 详见&ldquo;采购合同&rdquo; 详见投标文件。详见《采购需求》 详见合同公示 详见采购合同协议 详见技术服务合同内容 详见公示合同 详见采购文件要求 详见合同主要条款 详见开标一览明细表 详见政府采购网合同 详见招标文件要求 详见工程量清单及图纸 详见采购文件要求 详见购销合同附件 详见&ldquo;竞争性谈判文件&rdquo; 详见中标通知书 详见政府购买服务合同 详见竞争性谈判文件和响应性文件。 详见招标文件招标书 详见分项报价表 详见磋商文件及工程量清单 详见&ldquo;QYZJ2020-11-23&rdquo;竞争性谈判文件 详见合同明细 详见合同约定 详见本项目竞争性谈判文件 详见附件需求 详见文件。详见&ldquo;公开招标&rdquo;文件 详见招、投标文件及合同。详见采购需求书 详见竞争新磋商文件 详见具体技术需求 详见附件（采购合同） 详见标的信息 见合同文件 上传的合同上已注明 见附件合同 详看合同 详见供货合同附件一报价明细表 内容详见合同附件 详合同条款 按照甲方规定 按照实际约定 附合同 详见服务合同 详见补充 具体见明细 按合同规定 见文件 详见合同采购清单明细 详见附件标的信息 见清单 详见报价明细表 见合同详细信息 详见公开招标文件 详见附件供货合同 详见项目合同 详见办公设备采购清单 详见合同；见清单明细 见成交公告 详见投标供应商投标文件 详见招标文件以及中标公告 详见成交公告明细报价表 详见明细 详见中标公示及采购合同 详见合同中供货一览表 详见合同及中标公告 具体详见招标文件 具体内容详见招标文件 详见购销合同 详细内容见合同附件 详见招标 详见合同货物清单 详见政府供销合同 详见招标文件及工程量清单 详见投标文件技术参数表 详见招标项目合同 见投标文件 具体详见施工合同 具体详见工程量清单 具体详见中标单位投标文件 详见合同相关条款 （具体采购内容详见招标文件） 详见成交公示 详见竞争性磋商响应文件 见投标文件 详见政府采购供销合同 具体详见政府采购供销合同 详见附件一 详见投标文件及采购合同 见招标文件 见工程量清单 详见材料报价清单 见公告 具体详见中标公告 详见项目采购合同 详见标的附件信息 详见投标工程量清单报价表 详见成交公告及合同 （详见招标文件第四章工程量清单） 祥见附件 （具体内容及要求详见《竞争性磋商响应文件》） 详见成交价格 详见竞争磋商文件 详见上传的合同附件 详见已标价工程量清单 详见建设工程施工合同 详见磋商文件及合同 具体要求详见工程量清单 详见合同上传附件 见中标公告附件 见合同及文件 具体详见投标文件 详见施工合同书 详见监理合同 具体内容详见工程量清单 见附表一 详见附件文件 项见招标文件 详见纸质版合同 详见设计合同 （具体内容及参数详见《合同》） 详见滦州市人民医院服务合同 具体内容详见采购合同 具体内容详见合同文件 详见合格 具体内容详见报价清单 详见合同参数 （详见附件） 详见合同报价表 详见附件及合同 详见磋商响应文件 详见试验检测合同书 详细见响应性文件 详见已签订的合同 详见招标附件 详见合同条款货物清单73657. （详见附件合同） 单价详见合同 详见投标报价明细表 具体详见采购文件及采购合同 见合同明细清单 详见租赁清单 规格型号：详见附件 数量：详见附件 单价：详见附件 详细见合同 详见合同条款中货物清单 详见合同具体内容 详见维修明细 详见成交公告附件 详见本采购合同中供货一览表 见投标文件清单 具体详见合同采购清单 详见甘谷县第二中学购置教学设备及建设专业教室公开招标采购项目中标公告 详见附件（合同）； 详见附件（合同）； 详见供货一览表 详见合同货物内容 请详见合同清单 各类物品见附件 （祥见附件） 详见招标文件，本报价为折扣率报价 详见采购供销合同 详见合同第2页 具体参数详见中标公告 （具体内容详见合同） 详细见采购合同 具体内容详见采购订货合同 见合同清单明细 详见招标文件，本项目采用折扣率报价 按照品目订价，详见合同 详见政府采购合同标的 详见本项目政府采购合同标的 具体见合同清单 具体见合同详细信息 详见中标公告及合同 见参数表 详见合同或招标文件 详见供货合同附件 品目繁多详见合同 详见商品采购合同 见招标文件及合同 详见中标文件 详见附件！ （具体要求详见招标文件货物需求部分） 具体详见发票清单 见合同附页 详情见文件 具体详见合同文件 详见销售合同 详见采购合同中苗木供应一览表 详见货物清单 具体详见供货一览表 详见附件 详见附近 见合同及清单 详情见招标文件技术参数 具体详情见合同 详见框架协议 内容较多，见合同 见中标公告或采购文件 详见成交公告及附件 详见其他补充事宜 详见采购公告及合同 见方便食品表 见相关文件 详见《船舶备件采购（No.2004）项目报价表》 详见协议 详见招标文件投标文件 见附件分项报价表 详见响应文件最终报价清单 详见投标文件工程量清单 见附页 详见本合同对应的成交公告附件 详见投标书 具体见工程量清单 详见附件-合同 详见中标公告、招标文件及合同 详见附件合同内容 详见中标（成交）结果公告 见中标公告 详见附件合同文本 详见响应文件报价清单 详见附件招标文件 详见响应文件最后报价清单 详见招标文件、图纸及工程量清单 具体内容详见施工图纸和工程量清单 根据各台施工方案确定，详见投标文件 供应商名称货物名称品牌数量单价规格型号张掖市华云科技有限责任公司临泽县气象局新建国家气象观测站设备详见附件详见附件详见附件详见附件 详见本项目中标公告 详见施工图纸及《工程量清单》 详见纸质合同 见合同报价 详见合同报价 详见本合同对应的中标成交公告附件：最终报价 详见合同内服务费表 详见（技术支撑服务类）合同 见附件一 见附件二、三 具体见合同 详见合同附件投标报价表 详见合同条款第五条 详见本合同对应的中标公告附件：最终报价 168./年，详见采购合同 详见附件-监理合同 （具体内容详见招标文件;工程量清单且包括施工图纸所列的的全部工作内容） 详见成交合同 详见本合同对应的中标成交公告附件：开标一览表 详见附件合同条款 详见明细清单 详见采购合同取费标准 见合同书 详见合同附件二、合同清单及价格 见合同 详见分项报价 （详见合同） 祥见清单 详见附件内容 见中标通知书 见合同货物明细表 具体见合同扫描件 详见附件分项报价表 详见结果公告 祥见合同信息 见招标公告 见估计 详见扫描件 详见合同附件一、合同清单及价格 详见响应文件工程量清单 详见合同弄 （详见附件1） 见合同项目报价表 （详见附件分项报价表） 详见中标人投标文件工程量清单报价 详见2020年河北镇生态沟域建设项目中标公告 等详见分项报价表 详见合同附件《货物清单》 具体详见中标人投标文件 详见附件''分项报价表'' 详见中标人投标文件 详见投标分项报价表 具体内容详见附件下载 具体详见附件 （详见合同附件） 具体详见合同附件 详见附件 具体见招标文件 字数过多详见中标附件 详见中标附件 详见采购合同货物明细表 等详见报价表 由于系统原因，详见附件。 详见中标公示附件 分诊叫号系统，详见中标附件 详见中标信息 主要内容见合同 详情见合同原件 详见合同要求 具体请见合同附件扫描页 详见合同附件清单 详细见中标通知 见中标通知书中标服务清单 详见中标通知书清单 详细见附件 见合同附清单 详见报价清单 详细内容详见合同及附件 见合同内容 详见报价单 详见合同内容及招标投标文件 具体内容详见合同 见合同1.5.1 详见招标文件及中标公告 见合同详情 具体详见采购合同 见协商响应文件 详见协议（服务内容及报价） 祥见投标文件 详情请见招标文件 详见附表一 详见合同及附件 见分类工程清单计价表 具体详见磋商文件 见招标文件工程量清单 详见乙方投标报价表 详情请见工程量清单 见施工合同 详见以签订的合同 详情见招标文件 详见工程总承包合同 详见政府购买社会服务合同 详见补充协议 详见医疗设备销售合同 详见参数 详见附件详见附件及合同 各产品详见附件 详见附件报价表 见合同附件一 想见合同及附件 详情可见合同 详见附件D包 详见附件B包 详见附件F包 见附件报价清单 详见合同资料 详见附件包 详见标段一施工合同附件 详见标段二施工合同附件 详见正文 详见规划设计合同附件 详见附件C包 详情见附件 详见合同附件内容 详见附件A包 和政县2020年农村环境整治项目（详见招标文件） 详见白银市生态环境大数据平台项目（二次）中标结果公告 详见附件(合同） 详见采购合同附件供货一览表 详见竞争性谈判响应文件 祥见施工合同 见附表 详见施工文件 详见合同预算 详见投标文件技术参数 具体详见政府采购合同 具体详见附件合同 见细目 （详见合同内容） 详见甘肃省政采商城电子卖场平台采购合同（GSZCSC-HT-2020-223814） 详见合同补充协议 具体详见合同书 详见《政府采购合同》 （详见工程量清单） 具体详见合同内容 详见合同供货范围表内容 详见已标价工程量清单（中标公告附件） 详见项目合同书 详见招标文件规定 详见政府采购合同内容 见政府采购合同附件 具体详见附件-合同 内容详见合同 详见附件扫描件 见中标公示 详见附件供货一览表 （详见招标文件内工程量清单） 具体要求详见《招标文件》 详见采购合同附件 详见附件采购供货合同 服务类供应商名称名称服务时间服务要求服务标准服务范围兰州城关物业服务集团有限公司物业服务一年详见附件招标文件详见附件招标文件详见附件招标文件 具体详见招标文件及投标文件 详见谈判响应文件 服务类供应商名称名称服务时间服务要求服务标准服务范围兰州市城关区保安服务公司保安服务一年详见附件招标文件详见附件 详见招标文件及合同附件 详见OneNET检务服务合同 见合同明细 详见服务合同 具体内容详见合同扫描件 详见合同附件收费标准 详见采购合同报价明细 详见供货合同 纸质图书（详见合同） 见货物清单 详见中标公示附件资料 详见采购项目合同附件一 详见附件--合同 见货物清单表 详见合同（附件） 详见投标报价明细 详见招标文件;合同及投标文件 详见货物一览表 详见本项目采购合同附件 见扫描件 详见附件资料 见合同详细清单 详见销售合同书 详见产品销售合同 详情见采购文件 详见招标工程量清单 详见设备明细表 详见采购合同书 详见物业管理服务合同 详见建设工程造价咨询合同 详见采购合同约定 详见图斑服务合同 详见建设工程勘察合同 详见上传合同附件 详见采购文件及合同 详见建设工程合同 详见合同公示附件 具体内容详见附件 详见供货合同 具体内容详见投标文件 详见合同供货一览表 详见勘查合同书 详见开标一览表 见服务清单 详见明细报价表 详见招标及合同 详见设备清单 详见附件（合同金额详见附件） 详见招标文件技术规格及要求 详见中标公告 详见中标清单 具体内容详见响应文件 详见报价工程量清单 具体详见响应文件 详见货物明细表 具体详见投标文件及合同 详见合同书 详见合同附表详见供应商投标文件 祥见合同及附件 详见建筑工程施工合同 具体内容见《投标文件》报价文件 详见响应文件已标价工程量清单 详见工程施工合同 详见中标公示附表 详见《投标文件》 详见中标参数附件 详见投标文件及服务合同 详见附件· 见具体清单 详见投保文件 按合同要求交货 详见车辆租赁合同 详见技术服务合同 详见规划设计合同 详见中标内容 详见供货清单 详见勘察设计合同 详见本项目的招标文件及合同 详见加固工程承包合同 见合同附件清单 详见合同供货清单 详见中标通知书内容 详见公告分项报价表 详见一览表 详见投标文件明细 详见合同货物 详见合同附表 详见合同附件见 见供货合同 详见合同附件：货物清单 详见中标单位投标文件 具体内容详见中标公告 详见合同及清单 详见合同详细信息 详见附件及招标文件 详见合同及工程量清单 详见货物采购协议 详见合同报价明细表 其他详见合同 详见单一来源采购邀请书 详见附件投标货物数量;价格明细表 具体详见磋商文件第五章 详见中标公告及附件 见合同· 具体见附件 见合同公告 详见磋商文件第五章 详见合同附件报价表 详见施工合同及其附件 C包内容详见附件 详见 B包内容详见附件 详见项目施工合同 详见附件. 由于内容过多，具体详见磋商文件第五章 详见本合同对应的成交公告附件：开标一览表 详见附件合同公告 因内容较多，详见附件合同 详见附件中标结果公告 详见合同内取费标准 其余详见合同 详见第二包投标文件 详见成交公告及合同附件 见其他补充事宜 其余详见合同文本 详见上传附件. 其余详见所附中标公告文本 详见中标公告文本 详见招标文件采购需求 详见附件货物数量;价格明细表 详见附件合同公告其他补充事宜 详见采购设备清单 A包详见附件 详见合同原文 详见附件《中标货物明细》 见附加 详见本合同对应的成交公告附件：最终报价 详见结果公告附表 详见单一来源采购文件 见合同公告附件 详见合同公告附件 详见附件合同货物清单 详见文件附录 具体详见合同附件报价表 详见成交供应商响应文件工程量清单报价 详见投标文件投标分项报价表 详见中标投标文件工程量清单报价 详见附 详见招标文件;合同 详见成交供应商响应文件及最终报价 详见本公告附件 详见合同附件5：详细设备清单 见合同附表 见合同说明 详见投标文件明细表 详见本项目合同 见结果公告附件 详见应答人响应文件 详见工程量清单报价 详见合同签订内容 详见合同(优惠率90%) 见投标分项报价一览表 详见相关附件 一项，详见合同附件 详细见合同附件 详见采购合同！ （详见附件2：主要标的规格型号;数量;信息表） 详见公告原文 见公告原文 具体要求详见招标文件 详见图 相见招标文件及合同附件 具体内容详见磋商文件 见采购合同附件 具体内容详见成交公示 具体内容详见中标公示 详见投标文件已标价工程量清单 具体标的详见磋商响应文件 详见合同明细表 详见招标文件工程量清单 详见附件一、供货一览表 详见已标价的工程量清单 具体服务要求详见磋商响应文件 详见预算 详见保单 车维修保养和服务见合同详细信息 详见《招标文件》、《投标文件》、合同。 详见招标文件项目需求 见明细单 详见后附件 详见附见 详见合同附加 详见清单附件 详见补充合同 详见上传合同清单 详见中合同 （具体要求详见招标文件） 详见中标公告附 详见磋商文件及服务合同 详见详细供货清单 货物类序号供应商名称名称品牌数量投标单价规格型号1南通铁人运动用品有限公司详见附件详见附件详见附件详见附件详见附件 见详细信息 详见中标人供货清单 谪见实施合同 详见实施合同 详见采购与建设合同 详见项目实施合同 详见《物业服务合同》 详见医技设备购销合同 详见设备购销合同 具体内容详见《招标文件》及附件 详见《合同附件》 详见合同； 详见合同书附件 参考维修清单 具体内容详见招标文件。 详见合同约定。 详见中标方合同附件 详见中标方合同附件 按工程实际需求 图纸及工程量清单范围内所有内容 详见本项目招标文件及合同 详见附件规格型号（或服务要求）：详见附件主要标的数量：1批主要标的单价：A包：4344000元；B包：4391500元；C包：4803000元合同金额：1353.850000万元履约期限、地点等简要信息：详见附件采购方式：公开招标七、合同签订日期：2021-05-31八、合同公告日期：2021-06-02九、其他补充事宜：一、合同编号：HZ2021-1070、HZ2021-1071、HZ2021-1072二、合同名称：合同书三、项目编号：HZ2020-471四、项目名称：海口市应急医疗救治设备采购五、合同主体采购人（甲方）：海口市卫生健康委员会地址：海口市长滨路8号16号楼北联系方式：0898-68707026A包供应商（乙方）：国药控股海南鸿益有限公司地址：海口市金盘工业开发区建设路10号A段第二层东侧联系方式：0898-66865168B包供应商（乙方）：海南华健药业有限公司地址：海南省海口市国家高新区药谷工业园药谷一路11号二幢1楼联系方式：0898-66831221C包供应商（乙方）：海南华健药业有限公司地址：海南省海口市国家高新区药谷工业园药谷一路11号二幢1楼联系方式：0898-66831221六、合同主要信息主要标的名称：详见附件 详见附件规格型号（或服务要求）：详见附件主要标的数量：1批主要标的单价：5369600合同金额：536.960000万元履约期限、地点等简要信息：详见附件采购方式：公开招标七、合同签订日期：2020-12-09八、合同公告日期：2020-12-10九、其他补充事宜：一、合同编号：HZ2020-1447二、合同名称：海南省政府采购项目合同书三、项目编号：HZ2020-390四、项目名称：新冠肺炎疫情防控中央补助结算资金（直达资金）设备购置项目五、合同主体采购人（甲方）：海南省中医院地址：海南省海口市和平北路47号联系方式：0898-66239587E包供应商（乙方）：江西鹏铎贸易有限公司地址：江西省南昌市进贤县医科园创业大道鑫虹公司办公楼三楼306联系方式：0791-85636856六、合同主要信息主要标的名称：详见附件 包号货物名称数量/单位品牌规格型号服务要求中标单位中标单价/元中标总价/元名次1餐厨设备1批保温自选餐台详见招标文件海口康务厨具贸易有限公司10500.00(核心产品）2536220.001规格：1950×1150×1200（mm）（核心产品） 见中标公告？ 详见合同附件; 工作量根据实际情况确定 按合同约定 根据工作量确定 按实际数量 其他内容详见招标文件 具体详见图纸及工程量清单 不超过同类商品的价格 详见甲乙合同 按实结算 主要标的单价(元) 详见公开招标文件第三部分招标内容及要求 协议供货 以市场价为基础，下浮1% 以实际采购为准 不等 符合要求 各类物品单价见附件 为以当日酒店的挂牌价为基数;折扣率为82% 按照黄岛区范围内的麦德龙 按照合同成交价格 合同数量 以双方签订合同为准 详见响应文件。 根据甲方实际需求量 不定，以实际发生为准 不定，以实际发生为准 供方将合同签订收的5日内将符合国家质量标准的采购货物送至甲方指定地点。 其他服务 详尽合同 无规格型号 以合同内容为主 按照合同约定执行 见合同约定 符合同 详见图纸及工程量清单 具体承包范围以招标文件、招标答疑及发包人提供的施工图纸、工程量清单 按项目要求提供会务服务 工程量清单所含全部内容 见合同正文 0.0 详见上传合同 具体参数详见招标文件技术参数 严格按照招标文件和投标文件工程量清单内的全部内容执行交工。 详见合同内容及附件 按合同 见合同。 以合同为主 详见响应文件分项报价表 所有型号详见投标文件分项报价表 (具体详见招标文件及工程清单、图纸等) 见上传文件中分项报价表 详见《分项报价表》 详见投标文件分项报价表 详见标书文件 详见采购书目 详见技术服务合同书 详见采购文件及技术清单内容。 详见本项目招标文件及合同。 详见竞争性谈判文件要求 详见《施工合同》 详见合同及文件 详见《招标文件》要求 详见签订合同内容 具体详见附件。 详见测绘合同 详见公开招标文件及投标文件内容 详见采购清单。 详见报价一览表及采购合同 详见中标公告附件及合同附件 （详见谈判文件） 详见投标文件报价清单 主要标的规格型号详见招标文件 详情附合同 详见附件合同技术参数 见成交公示 详见招标文件和工程量控制价 具体标的规格型号详见磋商响应文件 按合同约定的规格型号 具体规格型号详见附件 依照合同 详见采购合同！ 详见标的 详见采购需求公示  详见附件最终报价和已标价工程量清单 主要标的规格型号：详见投标文件 详见合同附件投标报价明细表 详见公告正文 详见参数清单 详细清单见附件 详见采购项目清单表 详见货物详细参数 详见合同文本； 见安装图纸 规格型号详见合同协议书 以合同明细或投标文件为准。 详见合同报价表。 招标文件及合同中的全部要求 服务标准按合同执行。 满足采购人及文件要求，具体要求详见文件 符合招标文件要求，详见采购项目需求 详见合同文件内容  按具体项目合同约定，满足采购人要求。 按合同规定的具体要求。 符合招标文件要求，详见合同 详见成交供应商响应文件 服务要求详见合同 详见上传合同 详细型号见附件 详见政府采购购销合同 政府采购合同 (详见合同附件) 详见清单。 见合同。 详见竞争性谈判 合同为准 按合同约定执行 按合同约定认真履行要求 详见标讯正文 详见委托合同 具体参数见附件。 具体参数详见招标文件技术参数 按照合同约定 详见采购申请 合同要求 以合同为主 详见投标文件、合同附件 规格型号详见中标通知书清单 详见所附清单 以合同为准 详见公示 详见附件或正文。 详见正文。 见招标文件要求。 详见《采购文件》 详见附件表 详见响应文件等 合同约定 详见合同内容。 双方合同约定 相见附件 具体内容、数量及详细参数详见招标文件 本次施工招标工作，具体详见施工合同内容。 见明细 具体详见附件清单 按合同提供参数执行 按照合同约定的服务要求执行。 具体服务要求已签订合同为主。 履行合同约定 合同 按合同要求供货 按照合同履约 按合同要求 严格按照合同进行供货 按照合同执行 按照合同要求执行 详见投标啊文件 详见文件。 详见本项目《竞争性磋商文件》 依据合同约定 详见采购合同及文件 （详见采购文件） 具体采购内容及服务要求详见招标文件。 其余详见合同附件 详合同内容 见采购文件及合同 参见招标文件 详见方案 具体型号数量详见附件 参数见附件 具体详见服务合同 详见政府采购合同文件及投标文件 详见附件政府采购合同 详见采购需求书 详见附件：项目合同 详见《政府采购购销合同及基本条款》 详见招标文件清单及合同 详见招标文件《用户需求书》 详见《响应文件》 详见招标、合同文件； 具体规格型号详见投标文件。 具体详见签订合同 详见竞争性谈判文件。 具体内容详见文件 具体详见竞争性磋商文件 详见成交内容 详见协议书 具体详见采购文件 详见采购合同内容 具体详见竞争性谈判文件 详见详见竞争性谈判文件及响应文件 详见供应商投标文件 按合同执行 详见附加合同 详见合同附件！ 详见招标文件以及中标公告。 以招标人实际需求为准 详见采购需求表 具体详见施工合同内容 详见招标文件及合同 按招标文件要求 按照招标文件要求 详见招、投标文件 按需分批供货 具体内容见附件 详见合同中标清单 详见合同采购清单 详见合同中标清单 详见招标、中标文件； 详见投标文件。 套规格型号详见采购合同 祥见合同。 详见招标文件要求。 详见合合同 详见中标合同。 详见清单内容 详见投标供应商投标文件。 详见中评公示 具体型号，规格、数量、单价、生产厂家信息，详见合同附件。 中标公告  详见附件合同书 详见标讯正文， 依据合同 与合同内容一致 详见合同附件; 详见 详见附件“合同” “采购合同” 详见附件“附件” 详见附件“合同” 详见“采购合同” 详见“附件1” 详见“附件2” 详见“合同” 详见“合同书” 详见附件“合同书” 详见“附件” 详见“采购合同” 详见“技术咨询合同” 详见磋商文件第四章“项目需求” 详见附件“采购合同” 详见附件“分项报价表” 详见“智慧消防”系统项目合同书 “699采购合同” 详见附件及中标公告 详见响应文件详见响应文件 详见采购合同货物内容 详见附件货物数量、价格明细表 详见招标文件技术参数 详见采购施工合同 详见合同详见合同 详见设计采购合同 详见销售合同附件《采购清单》 详见合同. 详见《厅局接管设备维保合同》 详见投标报价一览表 详见中标公告及合同附件 详见招标文件设备清单 详见公告文本 详见招标文件。详见招标文件。 详见争性磋商文件 详见投标文件详见投标文件 详见招标文件和投标文件 详见合作协议书 详见《竞争性磋商文件》及政府采购合同 详见单一来源文件 详见产品明细表详见产品明细表 详见产品明细表 详见报价一览表 详见最终采购合同 详见公告附件合同书 详见本项目招标文件的第四章项目需求 详见本项目招标文件的第四章项目需求 详见附件1 详见附件2 详见试验检测合同书。 详见招标文件技术参数表 详见招标文件第四章技术需求书 详见GZHX-2107(SC037)竞争性谈判文件 详见乙方报价表 详见造价咨询合同 详见采购文件详见采购文件 详见附件中标公告 详见磋商文件详见磋商文件 详见项目中标公告 详见合同附件见合同附件 详见所附中标公告文本 详见所附中标公告 详见《招标文件》及政府采购合同 详见招标文件设备参数 详见磋商文件、采购合同 详见谈判文件第四章《采购内容及技术要求》 详见招标文件、合同 详见合同书。 详见工程量清单及施工图纸 详见合同及其附件 详见本项目成交公告 详见公告信息 详见合同附件一货物清单 详见本项目成交公告正文 详见已签订合同 详见GZHX2021-05-12竞争性谈判文件 详见公告合同 详见GZHX2021-05-11竞争性谈判文件 详见招标文家 详见参选文件 详见本项目招标文件的第四章项目需求详见本项目招标文件的第四章项目需求 详见附件投标货物数量、价格明细表 详见采购合同附件。 详见第三年合同 详见用户需求公示 详见附件包3 详见供货合同。 见设计和投标文件 见附见 见合同名称 见投标文件见投标文件 见合同供货一览表中设备的采购 见招标文件及合同内容 见招投标文件 见工程量清单和施工图纸 见标书见标书 见合同附件见合同附件 见合同后附件清单 见发票 见合同及采购需求参数 见附件清单 详见附件“699采购合同” 详见《分项报价表》详见《分项报价表》 详见《竞争性磋商文件》 按照招标文件要求进行加工生产，符合规格、颜色、材质、印刷工艺、防伪技术等要求，并与甲方认定的印刷品批样保持一致，版面文字排列标准规范。 详见技术咨询合同 按图纸内容施工 按需 按招标文件要求按招标文件要求 按采购人要求按采购人要求 按招标文件规定 按施工图施工 按设计要求 按文件要求按文件要求 按采购文件要求按采购文件要求 按招标文件服务按招标文件服务 详见竞争性磋商文件要求 详见“中标公告” 详见“竞争性磋商文件” 详见“竞争性谈判文件” 详见“询价文件”  详见5.货物说明一览表 详见A包政府采购合同 详见B包政府采购合同 详见CQKH2020-12-07竞争性谈判文件。 详见GZHX-2006（SC67）竞争性谈判文件 详见GZHX-2007（SC69）竞争性谈判文 详见GZHX-2012（SC112）竞争性谈判文件 详见GZHX-2012（SC115）竞争性谈判文件 详见HXH20200903竞争性谈判文件 详见HXH20201101公开招标文件 详见QYZJ-2020-27竞争性谈判文件 详见QYZJ2020-10-23竞争性谈判文件 详见QYZJ2020-11-23竞争性谈判文件 详见RTH20190704招标文件 详见RTH20201004公开招标文件 详见RTH20201006公开招标文件 详见《合同》 详见《合同》。 详见《工程量清单》 详见《建设工程施工合同》 详见《单一来源采购文件》“第五章项目采购需求书” 详见《单一来源采购文件》 详见“采购需求” 详见“采购文件第五部分” 详见“用户需求书” 详见“投标文件” 详见“投标文件”。 详见“技术服务合同” 详见“成交公告 ” 详见《竞争性谈判文件》 详见《询价文件》要求 详见《谈判文件》 详见《采购需求》 详见《附件》 详见上传合同电子件 详见上传电子合同 详见上传的合同电子件 详见上传的合同附件。 详见上传的附件内容。 详见下方协议书 详见中标供应商投标文件 详见中标公告。 详见中标公告原文 详见中标公告及中标标的 详见中标公告及中标标的。 详见中标单位投标文件及合同扫描件 详见中标合同清单 详见中标明细（附件）； 详见中标结果公告 详见中标通知书与合同明细表 详见中标通知书参数附件 详见中标通知书及合同 详见中标通知书后附表 详见中标通知书货物清单 详见中标通知书附件。 详见中标通知书附表 详见乙方报价表 详见产品属性 详见产品清单 详见产品购销和技术服务合同 详见任务书 详见供应商响应文件 详见供货协议。 详见供货服务合同 详见供需合同 详见入围协议 详见入围协议书 详见公告及文件 详见公开招标文件第二部分公开招标项目内容及要求 详见公开招标文件要求 详见公开招标文件要求。 详见公示公告 详见公示附件 详见六标段中标内容附件 详见其他附件 详见具体合同内容 详见分项价格表 详见协商文件 详见协议文件 详见协议相关条款 详见单一来源响应文件 详见单一来源谈判文件 详见单一来源谈判文件及响应文件 详见原招标公告 详见双方签订的供货合同 详见合同! 详见合同g 详见合同附件“货物清单”。 详见合同中要求 详见合同中采购清单 详见合同书内容  详见合同书内容。 详见合同书正文 详见合同书设备清单 详见合同件 详见合同供货明细表 详见合同信息 详见合同公告内容 详见合同公告和补充协议  详见合同公告附件：合同扫描件 详见合同具体内同 详见合同内 详见合同内容. 详见合同内容和招标文件 详见合同内容要求 详见合同内容附件。 详见合同及供应商响应文件 详见合同及供应商响应文件 详见合同及招标文件 详见合同及派遣协议 详见合同及派遣协议 详见合同及需求书。 详见合同后附表 详见合同和成交通知书 详见合同和招标文件 详见合同和采购文件 详见合同工 详见合同工程量清单 详见合同或标书 详见合同所示 详见合同扫描件第一条和第二条 详见合同投标报价明细 详见合同报价明细表。 详见合同招标文件 详见合同文件所示内容 详见合同文件；详见合同明细内容。 详见合同明细需求 详见合同服务质量标准 详见合同标底清单 详见合同标的清单 详见合同清单. 详见合同清单。 详见合同清单内容 详见合同清单和要求 详见合同清单明细 详见合同清单附件。 详见合同电子件 详见合同相关参数 详见合同相应条款 详见合同第4-5条 详见合同第一条和第二条 详见合同第三条服务内容与质量标准 详见合同第四条 详见合同第四条及附件 详见合同第四章 详见合同第四章节 详见合同管理内容要求 详见合同约束 详见合同设备清单 详见合同详细内容 详见合同配置清单 详见合同采购清单。 详见合同附件1 详见合同附件1工程量清单 详见合同附件一 详见合同附件中 详见合同附件中《服务一览表》 详见合同附件工程量清单 详见合同附件或招标文件 详见合同附件或磋商文件 详见合同附件扫描件 详见合同附件投标分项报价表 详见合同附件报价明细表 详见合同附件报价明细表。 详见合同附件采购清单。 详见合同附件采购货物清单 详见合同附件（工程量清单） 详见合同附件：设备清单 详见合同附件：设备清单及参数 详见合同附件； 详见合同附表1 详见合同附见 详见合同（附件）； 详见合同） 详见合同，投标文件 详见合同，按甲方要求 详见合同，详见附件。 详见合资合作协议 详见响应文件中采购内容及技术参数 详见响应文件，谈判文件 详见招标文件“第三章采购需求” 详见招标文件“第五章服务内容及要求” 详见招标文件“第五章采购需求以要求” 详见招标文件“第六部分采购人要求” 详见招标文件“采购需求书”部分。 详见商品采购合同及附件 详见图纸 详见图纸和工程量清单 详见图纸和工程量清单内全部内容 详见定点采购合同附件 详见审计服务合同 详见工程咨询合同 详见工程施工协议书 详见工程量清单、图纸 详见工程量清单、施工图纸。 详见工程量清单。 详见工程量清单。如需进一步了解详细内容，详见招标文件。 详见工程量清单全部内容 详见工程量清单内全部工程的施工 详见工程量清单及其他需要说明的问题。 详见工程量清单及图纸全部内容 详见工程量清单及图纸质量标准：合格 详见工程量清单及招标文件 详见工程量清单及磋商文件。 详见工程量清单及竞争性磋商文件 详见工程量清单及竞争性磋商文件要求 详见工程量清单和图纸 详见工程量清单和竞争性磋商文件 详见工程量清单所包含的全部施工内容 详见工程量清单所有内容。 详见工程量清单特征描述相关内容 详见开标一览表明细 详见成中标公告 详见成交供应商投标文件 详见成交公告、合同附件 详见成交公告中附件单一来源采购文件 详见成交公告内容及合同公示内容 详见成交公告附件。 详见成交公告！ 详见成交公示附件。 详见成交单位响应文件 详见成交合同（附件） 详见成交结果公示 详见成交结果公示附件 详见成交通知书 详见成交通知书附件 详见成交通知书附表 详见所附合同 详见所附招标文件文本 详见所附招标文件文本。 详见所附附件 详见承包合同 详见技术参数 详见技术参数要求及服务要求 详见技术合同 详见技术合同附件1 详见技术咨询合同 详见技术咨询服务合同 详见技术性能指标 详见技术要求 详见技术资料 详见技术附件 详见技术需求 详见投招标文件 详见投文件 详见投标内容 详见投标分项报价表明细、详见开标一览表明细、详见开标一览表明细、详见开标一览表明细详见投标分项报价表明细、详见开标一览表明细、详见开标一览表明细、详见开标一览表明细 详见投标工程量清单 详见投标报价清单 详见投标文 详见投标文件供货清单 详见投标文件内容 详见投标文件及合同 详见投标文件及招标文件 详见投标文件及施工图纸 详见投标文件及服务合同。 详见投标文件及清单图纸招标文件 详见投标文件及谈判文件要求 详见投标文件及采购文件 详见投标文件和合同 详见投标文件开 详见投标文件技术部分 详见投标文件投标分项报价表详见投标文件投标分项报价表 详见投标文件清单 详见投标文件设备清单 详见投标文件质量标准：符合现行国家或行业标准及规范要求。 详见投标文件资 详见投标文件，合同 详见投标清单 详见投标问价内容 详见报价明细 详见报价表 详见招、投标文件。 详见招、投标文件及合同。 详见招文件 详见招标代理合同 详见招标你文件 详见招标公告。 详见招标公告及中标标的。 详见招标公告及招标文件 详见招标公告采购需求 详见招标内容 详见招标合同 详见招标投文件附件 详见招标投标文件 详见招标招标文件 详见招标文件、合同、投标文件 详见招标文件、图纸及清单中包含的全部内容 详见招标文件、工程量清单及图纸、合同 详见招标文件、投标文件及合同 详见招标文件、投标文件及采购合同附件报价明细表。 详见招标文件、施工图纸及工程量清单所含全部内容。 详见招标文件《第五章技术标准和要求》 详见招标文件《采购需求书》 详见招标文件中招标内容及要求 详见招标文件中招标内容及要求。 详见招标文件中的采购需求 详见招标文件内容 详见招标文件内容。 详见招标文件内容要求 详见招标文件几工程量清单 详见招标文件参数 详见招标文件及中标人投标文件 详见招标文件及中标供应商投标文件 详见招标文件及中标单位投标文件 详见招标文件及乙方投标文件 详见招标文件及合同内容 详见招标文件及合同明细表 详见招标文件及合同约定 详见招标文件及合同要求 详见招标文件及图纸 详见招标文件及工程量清单,图纸 详见招标文件及工程量清单和图纸 详见招标文件及工程量清单范围内所包含的全部内容 详见招标文件及技术参数 详见招标文件及投标文件 详见招标文件及招标公告 详见招标文件及服务合同 详见招标文件及清单 详见招标文件及采购合同 详见招标文件及采购合同。 详见招标文件及附件 详见招标文件和中标供应商投标文件相关内容 详见招标文件和中标单位投标文件 详见招标文件和合同 详见招标文件和合同书 详见招标文件和工程量清单 详见招标文件和成交供应商响应文件 详见招标文件和采购合同 详见招标文件工程量清单内全部内容 详见招标文件工程量清单内的全部内容 详见招标文件或合同附件 详见招标文件技术参数或服务要求 详见招标文件技术清单 详见招标文件技术要求 详见招标文件技术规范及要求 详见招标文件技术部分 详见招标文件技术需求。详见招标文件服务要求 详见招标文件服务采购需求。 详见招标文件服务需求 详见招标文件清单 详见招标文件的要求 详见招标文件要求.。 详见招标文件货物清单 详见招标文件质量标准：合格 详见招标文件采购清单 详见招标文件采购要求 详见招标文件采购货物清单及技术参数要求 详见招标文件采购需求部分 详见招标文件附件 详见招标文件需求部分 详见招标文件！ 详见招标文件，响应文件及合同约定 详见招标文件，质量合格 详见招标文件，质量标准：符合国家设计规范要求 详见招标文件； 详见招标文件；质量标准：合格 详见招标标文件 详见招标清单 详见招标清单及图纸 详见招标磋商文件 详见招标要求 详见招标设备采购合同 详见招标通知采购需求 详见招标采购内容与技术规格书 详见招标需求 详见政府合同 详见政府采购合同书 详见政府采购合同及竞争性磋商文件 详见政府采购合同文件详见本招标文件“第五章采购内容及技术要求”。 详见本项目的成交公告和附件“采购合同” 见合同要求 详见招标文件第四章项目需求 详见合同中文 按实际需求提供 按实际结算 按磋商文件要求服务要求执行。 本工程图纸及工程量清单的全部内容。 竞争性磋商文件要求 见工程量 (具体要求详见《竞争性磋商文件》） 低于市场价格。 具体内容详见采购文件 乙方配送的产品，以甲方验收人员验货的品种、数量、重量为准。 乙方必须按照响应文件报价和承诺配送产品，在合同规定期间内，每季度双方核定价格一次，本季度内价格不做调整。 乙方配送的产品，以甲方验收人员验货的品种、数量、重量为准。 因本项目停放涉案车辆数为不确定因素，故按实际发生的移动、停放保管量进行结算支付。招标文件、投标文件及图纸全部内容 招标文件、投标文件及图纸全部内容按合同工期完成 （具体详见附件） 甲方实际制作数量 项目无法标记单价 固定单价合同 实际结算 标的单价不详，依据具体服务情况确定单价。 相加附件 工程量清单 （具体要求详见工程量清单及设计图纸） 施工设计图纸及工程量清单内全部内容。 详磋商文件 合同总额 合同附件 合同价 合同价 合同价格形势：总价合同 合同成交价格 合同中未注明 合同单价 合同规定的标价 合同价格 合同总价 合同金额 实际工作量 单价不超过市场价格 以任务数为准 以任务书为准 据实 数量有各种类型" 

//
foreach var in 主要标的名称 规格型号或服务要求 主要标的数量 主要标的单价{
	foreach term of local terms{
            replace `var' = "." if `var' == "`term'"
	}
}

	// cond 3: when values in 主要标的名称, 主要标的单价, and 主要标的数量 are the same, and does not contain any price/quantity info, mark price and quantity as missing 
gen flag = 主要标的名称==主要标的单价 & 主要标的单价==主要标的数量 & !regexm(主要标的名称, "[0-9]|一批|一台|一包|一套")
replace 主要标的数量 = "." if flag == 1
replace 主要标的单价 = "." if flag == 1
drop flag
	
	// cond 4: when values in 规格型号或服务, 主要标的单价, and 主要标的数量 are the same, and does not contain any price/quantity info, mark price and quantity as missing 
gen flag = 规格型号或服务==主要标的单价 & 主要标的单价==主要标的数量 & !regexm(规格型号或服务, "[0-9]|一批|一台|一包|一套")
replace 主要标的数量 = "." if flag == 1
replace 主要标的单价 = "." if flag == 1
drop flag

	// cond 5: when values in 主要标的单价 and 主要标的数量 are the same, and does not contain any price/quantity info, mark price and quantity as missing 
gen flag = 主要标的单价==主要标的数量 & !regexm(主要标的数量, "[0-9]|一批|一台|一包|一套")
replace 主要标的数量 = "." if flag == 1
replace 主要标的单价 = "." if flag == 1
drop flag

	// cond 6:
	// ？可能存在的问题：
	// 1. "^根据(甲方|实际|合同|招标|采购方|采购|用户|具体)" 会drop掉一些包含项目细节信息的observation
	// 2. 符合|招标 drop掉具体要求
replace 规格型号或服务要求 = "." if 主要标的名称!="." & regexm(规格型号或服务要求, "^(详见|见｜满足|具体)")
replace 规格型号或服务要求 = "." if 主要标的名称!="." & regexm(规格型号或服务要求, "^(按照|按|以|合同|参照)") & !regexm(规格型号或服务要求, "[0-9]+")
replace 规格型号或服务要求 = "." if 主要标的名称!="." & regexm(规格型号或服务要求,"按照|依据|符合|招标") & !regexm(规格型号或服务要求,"[0-9]")
replace 规格型号或服务要求 = "." if 主要标的名称!="." & regexm(规格型号或服务要求,"^根据(甲方|实际|合同|招标|采购方|采购|用户|具体)") & !regexm(规格型号或服务要求,"[0-9]")


replace 主要标的数量 = "." if (主要标的名称!="." | 规格型号或服务要求!= ".") & regexm(主要标的数量, "^(详见|见)")
replace 主要标的数量 = "." if (主要标的名称!="." | 规格型号或服务要求!= ".") & regexm(主要标的数量, "^(按照|按|以|根据|依据|实际|符合|招标)") & !regexm(主要标的数量, "[0-9]+")
replace 主要标的数量 = "." if regexm(主要标的数量, "^(具体|满足)")


replace 主要标的单价 = "." if regexm(主要标的单价, "^(详见|见|具体|满足)") & !regexm(主要标的单价, "合同金额：¥")
replace 主要标的单价 = "." if regexm(主要标的单价, "^(按照|按|以|根据|固定|依据|实际|综合|符合|招标)") & !regexm(主要标的单价, "[0-9]+")

**# Bookmark #1
	// cond 7: observations where only price and quantity information are available 
gen flag = .
replace flag = 1 if regexm(主要标的名称, "^详见附件规格型号（或服务要求）：详见附件")
replace flag = 1 if regexm(主要标的名称, "^详见合同附件规格型号（或服务要求）：详见合同")
replace flag = 1 if regexm(主要标的名称, "^详见采购合同规格型号（或服务要求）：详见采购合同")
replace flag = 1 if regexm(主要标的名称, "^详见附件合同规格型号（或服务要求）：详见附件合同")
replace flag = 1 if regexm(主要标的名称, "^详见标段一施工合同附件规格型号（或服务要求）：详见标段一施工合同附件")
replace flag = 1 if regexm(主要标的名称,"^详见标段二施工合同附件规格型号（或服务要求）：详见标段二施工合同附件")
replace flag = 1 if regexm(主要标的名称, "^详见绿化管养合同附件规格型号（或服务要求）：")

foreach var in 主要标的名称 规格型号或服务 主要标的数量 主要标的单价{
	replace `var' = "." if flag ==1
	
}
drop flag


	// remove all missing variables
	// 537,794 observations deleted, 255,134 observations remained
	// 6min 8s
drop if 主要标的名称 =="." & 规格型号或服务要求 =="." & 主要标的数量 =="." & 主要标的单价 =="."

save "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/04-noNA cleaned.dta", replace

//--------------------------------------------------------------------------------------------
/*
	Section II: Split dataset by number of product: single and multiple
	可能存在的问题：
	1. 当主要标的数量中没有分隔符的时候，即使有多个product，会被识别成single product4-product55
	
	notes:
	1. "各"开头可能意味着multiple product, ex. 各一个
*/
use "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/04-noNA cleaned.dta", replace

gen flag = .

replace flag = 1 if regexm(主要标的数量,"^1\..*2\.")
replace flag = 1 if regexm(主要标的数量,"^1、.*2、")
replace flag = 1 if regexm(主要标的数量,"^1：.*2：")
replace flag = 1 if regexm(主要标的数量,"^:1：.*2：")
replace flag = 1 if regexm(主要标的数量,"^\(1\).*\(2\)")
replace flag = 1 if regexm(主要标的数量,"^（1）.*（2）")
replace flag = 1 if regexm(主要标的数量,"^1）.*2）")
replace flag = 1 if regexm(主要标的数量,"^1\）.*2\）")
replace flag = 1 if regexm(主要标的数量,"^（一）.*（二）")
replace flag = 1 if regexm(主要标的数量,"^①.*②")
replace flag = 1 if regexm(主要标的数量,"^★1、.*★2、")

replace flag = 1 if regexm(主要标的数量,"^[0-9]+、[0-9]+") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"^[0-9]+.*、[0-9]+.*") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"台、.*台") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"、.*、.*、") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+.*、.*[0-9]+.*、") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+.*、.*[0-9]+.*") & missing(flag) & regexm(主要标的数量, "、") 
replace flag = 1 if regexm(主要标的数量,"一.*、.*一.*") & missing(flag)
replace flag = 1 if regexm(主要标的数量, "、") & regexm(主要标的单价, "、|，") & missing(f)

replace flag = 1 if regexm(主要标的数量,"^[0-9]+；[0-9]+") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"^[0-9]+.*；[0-9]+.*") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"^[0-9]+个；[0-9]+个") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+个；.*[0-9]+个") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"^[0-9]+台；[0-9]+台") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"台，.*台") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+.*；[0-9]+.*") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+.*；.*[0-9]+.*；") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+.*；.*[0-9]+.*") & missing(flag)


replace flag = 1 if regexm(主要标的数量,"^[0-9]+;[0-9]+") & missing(flag)

replace flag = 1 if regexm(主要标的数量,"^[0-9]+/[0-9]+") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"^[0-9]+.*/[0-9]+.*") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+.*/.*[0-9]+.*/.*[0-9]+.*") & missing(flag)

replace flag = 1 if regexm(主要标的数量,"^[0-9]+\\[0-9]+") & missing(flag)


replace flag = 1 if regexm(主要标的数量,"^[0-9]+,[0-9]") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+,[0-9]+,[0-9]") & missing(flag)


replace flag = 1 if regexm(主要标的数量,"^[0-9]+，[0-9]+，") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"^[0-9]+.*，[0-9]+.*") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+，.*[0-9]+") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"^[0-9]+\+[0-9]+") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+.*，.*[0-9]+") & regexm(主要标的单价, "、|；|;|，|,") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+个，.*[0-9]+个") & missing(flag)

replace flag = 1 if regexm(主要标的数量,"）[0-9]+.*）[0-9]+") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"\([0-9]+\).*\([0-9]+\)") & missing(flag)


replace flag = 1 if regexm(主要标的数量,".*：.*：") & missing(flag)
replace flag = 1 if regexm(主要标的数量,".*:.*:") & missing(flag)
replace flag = 1 if regexm(主要标的数量,".*：.*:") & missing(flag)

replace flag = 1 if regexm(主要标的数量,"[0-9]+.*。[0-9]+.*") & missing(flag)

replace flag = 1 if regexm(主要标的数量,"^[0-9]+\.[0-9]+") & missing(flag)



replace flag = 1 if regexm(主要标的数量,"[0-9]+.*和[0-9]+.*") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+.*及[0-9]+.*") & missing(flag)


replace flag = 1 if regexm(主要标的数量,"[0-9]+台.*[0-9]+台") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+箱.*[0-9]+箱") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+个.*[0-9]+个") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+套.*[0-9]+套") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+件.*[0-9]+件") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"一批.*一批") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"一套.*一套") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"一台.*一台") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+本.*[0-9]+本") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+瓶.*[0-9]+瓶") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+组.*[0-9]+组") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+袋.*[0-9]+袋") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+辆.*[0-9]+辆") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+张.*[0-9]+张") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+株[0-9]+株") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+㎡[0-9]+㎡") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+座.*[0-9]+座") & missing(flag)


replace flag = 1 if regexm(主要标的数量,"机[0-9]+.*机[0-9]+") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"套[0-9]+.*套[0-9]+") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"椅[0-9]+.*椅[0-9]+") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"人[0-9]+.*人[0-9]+") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"盒[0-9]+.*盒[0-9]+") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"个[0-9]+.*个[0-9]+") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"床[0-9]+.*桌[0-9]+") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"台[0-9]+.*台[0-9]+") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"只[0-9]+.*台[0-9]+") & missing(flag)


replace flag = 1 if regexm(主要标的数量,"[0-9]+/套.*[0-9]+/套") & missing(flag)

replace flag = 1 if regexm(主要标的数量,"[0-9]+个.*[0-9]+盒") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+个.*[0-9]+台") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+张.*[0-9]+把") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+张.*[0-9]+本") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+包.*[0-9]+箱") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+个.*[0-9]+把") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+个.*[0-9]+套") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+支.*[0-9]+瓶") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+支.*[0-9]+个") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+套.*[0-9]+台") & missing(flag)


replace flag = 1 if regexm(主要标的数量,"[0-9]+箱.*[0-9]+个") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+箱.*[0-9]+台") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+箱.*[0-9]+支") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+块.*[0-9]+份") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+座.*[0-9]+辆") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+把.*[0-9]+个") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"[0-9]+把.*[0-9]+组") & missing(flag)

replace flag = 1 if regexm(主要标的数量,"一台.*[0-9]+个") & missing(flag)
replace flag = 1 if regexm(主要标的数量,"L1.*L1") & missing(flag)

replace flag = 1 if regexm(主要标的单价,"[0-9]+元.*[0-9]+元") & missing(flag)


	// 可能存在的问题： 1. 数量是单个produect， 但是单价是多个product
local quantifiers "个 年 床 架 件 位 名 台 辆 支 根 条 把 瓶 盒 包 袋 张 盘 碗 罐 盆 箱 瓶 匹 双 层 次 团 批 桶 扎 网 角 面 粒 枚 回 扇 届 桩 层 屋 棵 趟 艘 滴 班 拨 段 炉 笼 群 行 轮 招 节 批 桩 排 档 桌 场 手 次 盘 局 盏 层 梯 座 回 轮 航 次 批 笔 次 局 届 次 回 项 本 吨 套 宗 尾 筒 公里 人 人份 人/天 cm/平方米 米 平米 平方 平方米 立方米 立方 栋 页 间 升 千克 公斤 亩 千瓦 户 份 册 天 块 卷 组 付 令 株 日辆 车辆 工时 计 版 部 千印 门 个月 月 头 只 片 日 对 只 小时 具 台\1年 kg g kw ㎡ 副 单 整套 整套服务 万毫升 期"

foreach quantifier of local quantifiers {
    local pattern1 "^[0-9]+\.[0-9]+`quantifier'$"
    local pattern2 "^[0-9]\.[0-9]+`quantifier'$"
    local pattern3 "^[0-9]+`quantifier'$"
    local pattern4 "^[0-9]`quantifier'$"
    local pattern5 "^一`quantifier'$"
    
    replace flag = 0 if regexm(主要标的数量, "`pattern1'")
    replace flag = 0 if regexm(主要标的数量, "`pattern2'")
    replace flag = 0 if regexm(主要标的数量, "`pattern3'")
    replace flag = 0 if regexm(主要标的数量, "`pattern4'")
    replace flag = 0 if regexm(主要标的数量, "`pattern5'")
}

replace flag = 0 if 主要标的单价=="." & ! regexm(主要标的数量, "元")
replace flag = 0 if regexm(主要标的数量, "^[0-9]+\.[0-9]+$")
replace flag = 0 if regexm(主要标的数量, "^[0-9]+$")
replace flag = 0 if regexm(主要标的数量, "^[0-9]\.[0-9]+$")
replace flag = 0 if regexm(主要标的单价, "^[0-9]+\.[0-9]+$")
replace flag = 0 if regexm(主要标的单价, "^[0-9]+$")
replace flag = 0 if regexm(主要标的单价, "^[0-9]\.[0-9]+$")
replace flag = 0 if regexm(主要标的单价, "^[0-9]+$")
replace flag = 0 if regexm(主要标的单价, "^[0-9]+\.[0-9]+$")
replace flag = 0 if regexm(主要标的单价, "^[0-9]+元$")
replace flag = 0 if regexm(主要标的单价, "^[0-9]+\.[0-9]+元$")
replace flag = 0 if regexm(主要标的单价, "^[0-9]+万元$")
replace flag = 0 if regexm(主要标的单价, "^[0-9]+\.[0-9]+万元$")
replace flag = 0 if regexm(主要标的单价, "^[0-9]+万$")
replace flag = 0 if regexm(主要标的单价, "^[0-9]+\.[0-9]+万$")

replace flag = 0 if 规格型号或服务要求 == "." & 主要标的数量 == "." & !regexm(主要标的单价, "[0-9]") & missing(flag)
replace flag = 0 if regexm(主要标的数量, "^[0-9]") & !regexm(主要标的单价, "、|；|;|，|,") & missing(flag)

**# Bookmark #2 ?? 单价 20,298
replace flag = 0 if 主要标的数量 =="." & 主要标的单价 =="."

	// 可能存在的问题：=0其中有多个product的可能，但无法提取regular expression
replace flag = 0 if missing(flag)


	// Step 1: Extract observations with single product
	// 244,952 observations remained
preserve
keep if flag == 0
drop flag
save "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/04-single.dta", replace
restore

	// Step 2: Extract observations with multiple product
	// 10,182 observations remained
preserve
keep if flag == 1
drop flag
save "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/04-multiple.dta", replace
restore

timer off 1
timer list
timer clear






// 	// Step 1: Extract observations with multiple product
// 	// 10,380 observations remained
// use "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/04-cleaned_noNA.dta", replace
// keep if regexm(主要标的数量, ",|，|;|；|、")| regexm(主要标的数量, "^[0-9]+/[0-9]+") | regexm(主要标的数量, ".*?/.*?/") | regexm(主要标的数量,"^1\..*2\.") |  |  | !regexm(主要标的数量, "[0-9]|一批|一台|一包|一套")
// save "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/04-cleaned_noNA_multiple.dta", replace
//	
// 	// Step 2: Extract observations with single product only
// 	// 245,014 observations remained
// use "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/04-cleaned_noNA.dta", replace
// drop if regexm(主要标的数量, ",|，|;|；|、")| regexm(主要标的数量, "^[0-9]+/[0-9]+") | regexm(主要标的数量, ".*?/.*?/") | regexm(主要标的数量,"^1\..*2\.") | regexm(主要标的数量,"^1、.*2、") | regexm(主要标的数量,"^1：.*2：")
// save "/Users/rsun/Desktop/Wes/24 QAC Apprenticeship/Data/04-cleaned_noNA_single.dta", replace
// timer off 1	
// timer list
// timer clear
