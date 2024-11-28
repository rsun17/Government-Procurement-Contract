use "02 - prepare data - province & central.dta", clear


/*
物品 - 只买东西不买服务
工程 - 涉及施工...
服务 - 凌杂

施工：
what's left: 如果同时采购 并安装，属于货物还是工程; 同时设计和施工属于什么->承包？
一个合同包括不同类型的商品（double check, when it is 承包）
检查所有金额为0 or 1的合同

安装：采购+安装


改造： 不太行

维修备件/维修零件
维修车？维修工作船，维修设备

锅炉，燃烧器，供暖系统的保养维修

维修&修缮 （工程vs服务， 大东西vs小东西）
房，屋，建筑，楼，文物
构筑物：围墙、道路、水坝、水井、隧道、水塔、桥梁、烟囱
栈桥、堤坝、蓄水池、水池、过滤池、澄清池、沼气池、挡土墙、囤仓
桥梁，堤坝，隧道，（纪念）碑，围墙，招牌框架、水泥杆

维修在前



设备采购

*/

gen type = "服务" if regexm(合同名称, "施工图")|regexm(合同名称, "监理")|regexm(合同名称, "造价")|regexm(合同名称, "鉴定")|regexm(合同名称, "承包")|(regexm(合同名称, "咨询") & !regexm(合同名称, "咨询中心"))|regexm(合同名称, "咨询有限公司")
replace type = "货物" if(regexm(合同名称, "施工升降机"))  & missing(type) 
replace type = "工程" if(regexm(合同名称, "施工"))  & missing(type) 
//accuracy rate>99%

/*
replace type = "服务" if(regexm(合同名称, "工程总承包")|regexm(合同名称, "工程承包"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "承包") & !regexm(合同名称, "承包经营"))  & missing(type) //承包在法律文件中只指工程，但是实际合同经常把服务承包出去
//accuracy rate>99%
*/


replace type = "工程" if(regexm(合同名称, "安装")|regexm(合同名称, "组装"))  & missing(type) //法律文件中其他分类下的已排除，但是有的情况货物购买和安装一起，不确定分类
//accuracy rate>99% accorrding to current standards
//装配属于工程，但是装配大多与物品采购一起（可能会采购物品附赠装配？）



replace type = "工程" if((regexm(合同名称, "装修") & regexm(合同名称, "改造"))|regexm(合同名称, "装修工程"))  & missing(type) //probably 95%? unsure

replace type = "工程" if(regexm(合同名称, "拆除")|regexm(合同名称, "修缮"))  & missing(type) //accuracy rate>99%


replace type = "服务" if(regexm(合同名称, "工程") & (regexm(合同名称, "监理")|regexm(合同名称, "设计")))  & missing(type) 

//keep if missing(type)
// Round1: general accuracy rate>99%





replace type = "服务" if(regexm(合同名称, "运维")|regexm(合同名称, "维保"))  & missing(type) // >99 加入维保前

replace type = "服务" if(regexm(合同名称, "设备提升改造") | regexm(合同名称, "设备改造") |regexm(合同名称, "设备升级"))  & missing(type) 
replace type = "货物" if regexm(合同名称, "改造") & (regexm(合同名称, "设备") |regexm(合同名称, "货物"))  & missing(type) 
//these two relatively lower, first one probably 90, second haven't tested
//第二个sample check中货物比服务多

replace type = "服务" if(regexm(合同名称, "改造") & regexm(合同名称, "热线系统"))  & missing(type) //>99
replace type = "工程" if(regexm(合同名称, "改造") & regexm(合同名称, "线系统"))  & missing(type) //>99
replace type = "服务" if(regexm(合同名称, "改造") & (regexm(合同名称, "系统")|regexm(合同名称, "软件")|regexm(合同名称, "信息化"))) & missing(type) ///high

replace type = "工程" if regexm(合同名称, "改造") & missing(type) 


replace type = "货物" if(regexm(合同名称, "货物")) & missing(type)   //surprisingly high accuracy
replace type = "货物" if(regexm(合同名称, "硬件采购")) & missing(type)

replace type = "服务" if (regexm(合同名称, "开发") & regexm(合同名称, "软件"))|(regexm(合同名称, "开发") & regexm(合同名称, "技术"))& !(regexm(合同名称, "开发区") | regexm(合同名称, "开发办") | regexm(合同名称, "开发中心")| regexm(合同名称, "开发办公室")| regexm(合同名称, "开发局")) & missing(type)

replace type = "货物" if(regexm(合同名称, "软件") & missing(type))
//软件是货物 但是软件开发是服务

replace type = "货物" if(regexm(合同名称, "服务器") & !regexm(合同名称, "服务中心")) & missing(type) 
replace type = "工程" if(regexm(合同名称, "工程设备租赁"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "租赁"))  & missing(type) 

//keep if missing(type)
//Round2: 95%
//主要问题在改造，改造本身和改造相关的物品，改造网络到底算服务还是工程？涉及填线路之类的可以算是工程，但是也可以是系统改造服务
//不确定的： 马关县2018年城镇棚户区(城中村)改造项目(一期)政府购买服务合同，写着服务合同，但是我觉得性质是工程
//code的精简（我多打了一个括号在每一行，需不需要删除）






replace type = "服务" if regexm(合同名称, "保险") & !regexm(合同名称, "保险局")  & missing(type) 
replace type = "服务" if(regexm(合同名称, "保养")) & missing(type)  
replace type = "工程" if(regexm(合同名称, "维修")& (regexm(合同名称, "楼")|regexm(合同名称, "房")|regexm(合同名称, "工程")))  & missing(type)  
replace type = "服务" if(regexm(合同名称, "维修"))  & missing(type)  
replace type = "货物" if(regexm(合同名称, "通信设备")|regexm(合同名称, "系统采购"))  & missing(type) 

replace type = "服务" if(regexm(合同名称, "设计")) & missing(type)     //设计工程属于服务，放在工程关键词前

replace type = "服务" if regexm(合同名称, "开发")  & !(regexm(合同名称, "开发区") | regexm(合同名称, "开发办") | regexm(合同名称, "开发中心")| regexm(合同名称, "开发办公室")| regexm(合同名称, "开发局")) & missing(type) //more general than the previous condition

replace type = "服务" if(regexm(合同名称, "加油") &!regexm(合同名称, "加油车"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "云计算"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "互联网接入"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "维护"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "验收"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "调查")) & !(regexm(合同名称, "调查队") |regexm(合同名称, "调查规划院") |regexm(合同名称, "调查院") |regexm(合同名称, "调查中心")|regexm(合同名称, "调查指挥中心"))  & missing(type) 

//Round3: >95%
//主要问题：有一些维修很难区分工程，服务，和货物：可能只是工程材料之类的
//调查院之类的多种单位命名方式








replace type = "货物" if(regexm(合同名称, "计算机"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "复印机"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "打印机"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "扫描仪"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "投影仪"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "复印纸"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "胃镜"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "家具"))  & missing(type)
replace type = "工程" if(regexm(合同名称, "空调")&regexm(合同名称, "工程"))  & missing(type)  
replace type = "货物" if(regexm(合同名称, "空调"))  & missing(type) 
replace type = "工程" if(regexm(合同名称, "电梯")&regexm(合同名称, "工程")) & !(regexm(合同名称, "工程院")|regexm(合同名称, "工程管理建设局")|regexm(合同名称, "工程局")|regexm(合同名称, "工程职业学院"))  & missing(type)  
replace type = "货物" if(regexm(合同名称, "电梯"))  & missing(type) 
replace type = "工程" if(regexm(合同名称, "车")&regexm(合同名称, "工程"))  & missing(type)  
replace type = "服务" if(regexm(合同名称, "车")&regexm(合同名称, "服务")) &! (regexm(合同名称, "服务中心")|regexm(合同名称, "服务平台")) & missing(type)  
replace type = "工程" if(regexm(合同名称, "车棚")|regexm(合同名称, "车库"))  & missing(type)  
replace type = "服务" if(regexm(合同名称, "车")& (regexm(合同名称, "治理")|regexm(合同名称, "检查")|regexm(合同名称, "监控")))  & missing(type)  
replace type = "货物" if(regexm(合同名称, "车"))  & missing(type)

replace type = "货物" if(regexm(合同名称, "显示"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "一体机"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "碎纸"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "电源"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "地膜"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "马铃薯"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "面料"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "校具"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "柴油"))   & missing(type) 
replace type = "货物" if(regexm(合同名称, "燃煤"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "印刷机"))   & missing(type) 
replace type = "服务" if(regexm(合同名称, "印刷"))  & missing(type)  //放在印刷机后面
replace type = "服务" if(regexm(合同名称, "印制"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "电脑"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "台式机"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "仪器"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "饮水机"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "墨粉"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "粉盒"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "硒鼓"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "路由器"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "考勤机"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "交换机"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "图书") & !regexm(合同名称, "图书馆"))  & missing(type)  //不能只用书
replace type = "服务" if(regexm(合同名称, "宣传"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "广告"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "传输服务"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "电视"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "闪光灯"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "硬盘"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "录音笔"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "相机"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "LED"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "显微镜"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "植物"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "屏"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "纸"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "商品采购"))  & missing(type) 
replace type = "工程" if(regexm(合同名称, "教室")&regexm(合同名称, "工程"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "教室"))  & missing(type) //一般是教室内需要的货物

//accuracy rate >95 overall, 货物 higher than total

//keep if missing(type)

replace type = "服务" if(regexm(合同名称, "勘测")|regexm(合同名称, "勘察")) & !(regexm(合同名称, "勘察局")|regexm(合同名称, "勘测院")|regexm(合同名称, "勘测局")|regexm(合同名称, "勘察院")|regexm(合同名称, "勘察研究院")|regexm(合同名称, "勘测规划院")|regexm(合同名称, "勘察实验室")|regexm(合同名称, "设备")) & missing(type) 
replace type = "货物" if(regexm(合同名称, "办公")&regexm(合同名称, "设备"))  & missing(type) 

replace type = "服务" if strrpos(合同名称, "办公")<strrpos(合同名称, "服务") &strrpos(合同名称, "服务")!=0 & !regexm(合同名称, "服务中心") & missing(type) 

replace type = "服务" if regexm(合同名称, "办公")& (regexm(合同名称, "检测")|regexm(合同名称, "评估"))  & missing(type) 


replace type = "工程" if strrpos(合同名称, "办公")<strrpos(合同名称, "工程") &strrpos(合同名称, "办公")!=0 & missing(type) 
replace type = "货物" if(regexm(合同名称, "办公"))  & missing(type) 


replace type = "工程" if(regexm(合同名称, "苗木")&regexm(合同名称, "扩建"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "苗木")&regexm(合同名称, "服务"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "苗木")&regexm(合同名称, "养护"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "苗木采购"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "苗木")& (regexm(合同名称, "拉运")|regexm(合同名称, "培育")|regexm(合同名称, "种植")|regexm(合同名称, "移植")|regexm(合同名称, "管理")|regexm(合同名称, "修复")))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "苗木"))  & missing(type) 


replace type = "服务" if(regexm(合同名称, "养护") & regexm(合同名称, "系统") & ((regexm(合同名称, "建筑工程")|(regexm(合同名称, "建设工程")| (regexm(合同名称, "电系统")|regexm(合同名称, "供暖系统")|regexm(合同名称, "照明系统")|regexm(合同名称, "广播系统"))))))  & missing(type)  

replace type = "货物" if(regexm(合同名称, "设备") & regexm(合同名称, "系统") & ((regexm(合同名称, "建筑工程")|(regexm(合同名称, "建设工程")| (regexm(合同名称, "电系统")|regexm(合同名称, "供暖系统")|regexm(合同名称, "照明系统")|regexm(合同名称, "广播系统"))))))  & missing(type)  


replace type = "工程" if(regexm(合同名称, "系统") & ((regexm(合同名称, "建筑工程")|(regexm(合同名称, "建设工程")| (regexm(合同名称, "电系统")|regexm(合同名称, "供暖系统")|regexm(合同名称, "照明系统")|regexm(合同名称, "广播系统"))))))  & missing(type)  
replace type = "服务" if(regexm(合同名称, "系统") & (regexm(合同名称, "服务")|regexm(合同名称, "提升")|regexm(合同名称, "维保")|regexm(合同名称, "评测")|regexm(合同名称, "测评")|(regexm(合同名称, "升级"))))  & missing(type)  
replace type = "货物" if(regexm(合同名称, "系统"))  & missing(type)  //工程之后，有监控系统工程

//Round 4: accuracy rate: >95
//by this round, half of the whole sample has been cleaned with high accuracy.






replace type = "服务" if strrpos(合同名称, "设备")<strrpos(合同名称, "维保") &strrpos(合同名称, "设备")!=0 & missing(type) 
replace type = "服务" if strrpos(合同名称, "设备")<strrpos(合同名称, "提升") &strrpos(合同名称, "设备")!=0 & missing(type) 
replace type = "货物" if(regexm(合同名称, "设备"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "机") &! regexm(合同名称, "国家机关"))    & missing(type) 
replace type = "货物" if(regexm(合同名称, "器材"))    & missing(type) 
replace type = "货物" if(regexm(合同名称, "仪"))   & missing(type) 
replace type = "货物" if(regexm(合同名称, "装备"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "供货"))  & missing(type)  
//《中央国家机关政府集中采购工作规程（试行）》规定，协议供货，是指对小批量标准化商品的采购
//approximately 95%

//keep if missing(type)


replace type = "工程" if strrpos(合同名称, "路")<strrpos(合同名称, "工程") &strrpos(合同名称, "路")!=0 & missing(type) 
replace type = "工程" if strrpos(合同名称, "运输")<strrpos(合同名称, "工程") &strrpos(合同名称, "运输")!=0 & missing(type) 

replace type = "货物" if strrpos(合同名称, "养护")<strrpos(合同名称, "材料") &strrpos(合同名称, "养护")!=0 & missing(type) 

replace type = "服务" if((regexm(合同名称, "运输")|regexm(合同名称, "养护")|regexm(合同名称, "检测"))& (regexm(合同名称, "车")|regexm(合同名称, "铁路")|regexm(合同名称, "路"))) &!((regexm(合同名称, "运输局")|regexm(合同名称, "运输厅")|regexm(合同名称, "运输管理局")|regexm(合同名称, "运输学校"))) & missing(type)  


replace type = "服务" if(regexm(合同名称, "检测")|regexm(合同名称, "检验") &regexm(合同名称, "服务")|regexm(合同名称, "维保")|regexm(合同名称, "管理服务")) &!(regexm(合同名称, "检测研究院")|regexm(合同名称, "检测室")|regexm(合同名称, "检测所")|regexm(合同名称, "检测中心")|regexm(合同名称, "试剂")|regexm(合同名称, "耗材")|regexm(合同名称, "药品")|regexm(合同名称, "检测站")|regexm(合同名称, "检测实验室")) & missing(type) 

//approx 95%
//keep if missing(type)

replace type = "工程" if(regexm(合同名称, "能力建设"))  & missing(type) //具体合同看起来一般包含较多事项，属于工程？

replace type = "工程" if(regexm(合同名称, "扩建") & regexm(合同名称, "工程"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "抽检")|regexm(合同名称, "检测")|regexm(合同名称, "检验")) &! (regexm(合同名称, "耗材")|regexm(合同名称, "试剂")) & missing(type) 
replace type = "服务" if(regexm(合同名称, "文印"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "影视剧"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "造林"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "物业"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "编制"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "评估"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "管理") & ustrlen(合同名称)-5<ustrrpos(合同名称, "管理"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "管理平台")|regexm(合同名称, "信息平台"))  & missing(type) 


replace type = "工程" if(regexm(合同名称, "加固")|regexm(合同名称, "扩建"))  & missing(type)
replace type = "服务" if(regexm(合同名称, "建设") & regexm(合同名称, "网站"))  & missing(type) 
replace type = "工程" if(regexm(合同名称, "建设"))  & missing(type) //误差大
replace type = "服务" if(regexm(合同名称, "工程") & (regexm(合同名称, "检测")|regexm(合同名称, "测试")|regexm(合同名称, "监测")))  & missing(type) 
replace type = "工程" if(regexm(合同名称, "工程"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "订购"))  & missing(type) 
//没有服务，工程类以及其他关键词，很多订购会是货物

//能力建设和造林到底属于什么
//should be 80-90%
//keep if missing(type)



//供应商
replace type = "工程" if(regexm(供应商, "工程"))   & missing(type) 
replace type = "工程" if(regexm(供应商, "建工"))   & missing(type) 
replace type = "工程" if(regexm(供应商, "建设"))   & missing(type) 
replace type = "工程" if(regexm(供应商, "建筑"))   & missing(type) 

replace type = "货物" if(regexm(供应商, "装饰品"))  & missing(type) 
replace type = "货物" if(regexm(供应商, "服装"))  & missing(type) 
replace type = "货物" if(regexm(供应商, "服饰"))  & missing(type) 
replace type = "货物" if(regexm(供应商, "纺织品"))  & missing(type) 
replace type = "货物" if(regexm(供应商, "仪器"))  & missing(type) 
replace type = "货物" if(regexm(供应商, "乐器"))   & missing(type) 
replace type = "货物" if(regexm(供应商, "器械"))   & missing(type) 
replace type = "货物" if(regexm(供应商, "家具"))   & missing(type) 
replace type = "货物" if(regexm(供应商, "锦纺"))   & missing(type) 
replace type = "货物" if(regexm(供应商, "蔬菜"))   & missing(type) 
replace type = "货物" if(regexm(供应商, "蔬果"))   & missing(type) 

//further check
replace type = "货物" if(regexm(合同名称, "询价"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "服装"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "制服"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "生活用品"))  & missing(type) 
replace type = "工程" if(regexm(合同名称, "监测项目")|regexm(合同名称, "检测项目"))   & missing(type) 
replace type = "货物" if(regexm(合同名称, "CT"))  & missing(type) 
replace type = "服务" if(regexm(合同名称, "资产清查"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "教具"))  & missing(type) 
replace type = "货物" if(regexm(合同名称, "材料"))  & missing(type) 
replace type = "服务" if(regexm(所属行业, "印刷"))   & missing(type) 
replace type = "货物" if(regexm(合同名称, "器械"))  & missing(type) 
replace type = "货物" if(regexm(所属行业, "煤"))   & missing(type) 
replace type = "服务" if(regexm(所属行业, "培训"))   & missing(type) 
replace type = "服务" if(regexm(所属行业, "种植"))   & missing(type) 
replace type = "货物" if(regexm(所属行业, "种子"))   & missing(type) 
replace type = "服务" if(regexm(所属行业, "技术服务"))   & missing(type) 
replace type = "货物" if(regexm(所属行业, "床"))   & missing(type) 
replace type = "货物" if(regexm(所属行业, "窗"))   & missing(type) 
replace type = "服务" if(regexm(所属行业, "期刊"))   & missing(type) //期刊出版服务
replace type = "货物" if(regexm(所属行业, "器"))   & missing(type) 



//In total, the procedure leaves 655,985 observations, which is 82.7% of all observations, have a certain type.
//random sample check of 100: about 90-95% accuracy overall.


rename yr_qianding year
//remember to change years of certain specific thresholds (check threshold remarks)


save "merge1.dta", replace //can use local or macro to prevent saving

import excel "Bidding Threshold.xlsx", sheet("Sheet1") firstrow clear
drop G remark

gen id = _n
//change thresholdforgoods and thresholdforengineringprojec to integers
replace Threshold货物 ="." if Threshold货物 ==""
replace Threshold工程 ="." if Threshold工程 ==""
destring Threshold货物 Threshold工程, replace force

reshape long Threshold, i(id) j(type, string)

rename Area area
rename Year year

merge m:m year area type using "merge1.dta"
drop if _merge==1
drop _merge

gen threshold2=Threshold*10000

gen open=1 if 采购方式=="公开招标"
replace open=0 if 采购方式!="公开招标" & 采购方式!=""

drop if year==1899

save "03-prepare data - type & merge", replace
