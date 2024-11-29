--学校信息
select * from nddc.dim__school t
where dt='${dt}'
and school_name in (
'北京宏志中学'
,'北京市第八中学'
,'北京市第八十中学'
,'北京市海淀区中关村第三小学'
,'北京市第十二中学'
,'北京理工大学附属实验学校'
,'天津市南开中学滨海生态城学校'
,'天津市南开大学附属中学'
,'天津市实验小学'
,'天津市第一中学'
,'天津市汇文中学'
,'天津市实验中学津南学校'
,'石家庄市第四十四中学'
,'唐山市开平小学'
,'河北衡水中学'
,'邢台市第二中学'
,'邯郸市肥乡区第二中学'
,'雄安容和兴贤初级中学'
,'太原市第十二中学校'
,'运城中学'
,'山西省实验小学'
,'吕梁汾阳市禹门河小学'
,'阳泉市第十一中学校'
,'大同市实验中学'
,'呼伦贝尔市海拉尔区南开路中学'
,'赤峰市红旗中学'
,'鄂尔多斯市康巴什区实验小学'
,'北京八中乌兰察布分校'
,'兴安盟乌兰浩特第一中学'
,'锡林郭勒盟蒙古族中学'
,'沈阳市尚品东越学校'
,'大连市中山区中心小学'
,'锦州市第十八中学'
,'丹东市实验小学'
,'辽阳市第十一中学'
,'盘锦市辽东湾实验中学'
,'东北师范大学附属中学'
,'吉林省实验中学'
,'长春市实验中学'
,'长春汽车经济技术开发区第二实验学校'
,'吉林市第一中学'
,'四平市第一中学'
,'哈尔滨市第三中学校'
,'齐齐哈尔市朝鲜族学校'
,'佳木斯市第一中学'
,'大庆第一中学'
,'哈尔滨市继红小学校'
,'集贤县二九一农场小学'
,'复旦大学第二附属学校'
,'上海市浦东新区张江高科实验小学'
,'上海市卢湾高级中学'
,'上海市位育中学'
,'中科院上海实验学校'
,'上海市虹口区曲阳第四小学'
,'南京市金陵中学实验小学'
,'无锡市尚贤万科小学'
,'苏州工业园区独墅湖学校'
,'江苏省南通中学附属实验学校'
,'江苏省扬州中学'
,'江苏省靖江高级中学'
,'浙江师范大学附属中学'
,'杭州市瓶窑中学'
,'温州市第二十二中学'
,'温岭市九龙小学'
,'绍兴市快阁苑小学'
,'舟山市定海小学'
,'合肥市师范附属小学'
,'合肥一六八玫瑰园学校南校'
,'合肥市第七中学'
,'蚌埠市蓝天路小学'
,'芜湖市中江小学'
,'安徽师范大学附属外国语学校'
,'福建省福州第一中学'
,'福州屏东中学'
,'厦门英才学校'
,'泉州第一中学'
,'宁化滨江实验中学'
,'龙岩市实验小学'
,'南昌师范附属实验小学'
,'南昌市第三中学'
,'南昌市第二十八中学'
,'南昌市第二十三中学'
,'江西省高安中学'
,'瑞昌市实验小学'
,'济南实验高级中学'
,'青岛西海岸新区双语小学'
,'东营市东营区英才小学'
,'潍坊市实验学校'
,'威海市第一中学'
,'临沂沂州实验学校'
,'河南省实验中学'
,'郑州市第二高级中学'
,'郑州市第八十四初级中学'
,'南阳市实验学校'
,'洛阳市西工区西下池小学'
,'孟州市韩愈小学'
,'湖北省武昌水果湖第二小学'
,'武汉经济技术开发区湖畔小学'
,'武汉市第四十九中学'
,'宜昌市实验小学'
,'荆门市掇刀区军马场学校'
,'潜江市田家炳实验小学'
,'长沙高新区雷锋新城实验小学'
,'岳阳市第一中学'
,'新邵县第八中学'
,'常德市武陵区第一小学'
,'南县第一中学'
,'永州市蘋洲小学'
,'广东实验中学'
,'深圳市深中南山创新学校'
,'广东华侨中学'
,'华南师范大学附属小学'
,'湛江市第十七中学'
,'清远市华侨中学'
,'柳州铁一中学'
,'柳州市第八中学'
,'南宁市位子渌小学'
,'柳州市东环路小学'
,'桂林市清风实验学校'
,'广西师范大学附属中学'
,'海南省农垦中学'
,'海南中学'
,'西南大学东方实验中学'
,'武进区实验小学教育集团琼海小学'
,'重庆市第二十九中学校'
,'重庆市沙坪坝区树人景瑞小学'
,'重庆师范大学附属小学'
,'重庆市铜梁区巴川初级中学校'
,'重庆市永川区实验小学校'
,'重庆两江新区礼嘉实验小学'
,'西大附小'
,'四川省成都市第七中学'
,'成都市双林小学'
,'四川省成都市第七中学初中学校'
,'攀枝花市花城外国语学校'
,'北京第二外国语学院成都附属小学'
,'四川省德阳市第五中学'
,'贵州省实验中学'
,'贵阳市第三中学'
,'遵义市第一中学'
,'六盘水市第四中学'
,'毕节四小'
,'都匀市第二中学'
,'云南省保山第一中学'
,'蒙自市第一高级中学'
,'昆明市第三中学'
,'临沧市第一中学'
,'宁洱哈尼族彝族自治县宁洱镇第二小学'
,'玉溪聂耳小学'
,'西安高新区实验小学'
,'西安交通大学附属小学'
,'咸阳市实验学校'
,'铜川市朝阳实验小学'
,'陕西石油普通教育管理移交中心长庆八中'
,'西安市铁一中学'
,'陇南市第一中学'
,'西北师范大学附属中学'
,'武威第十中学'
,'兰州市城关区通渭路小学'
,'甘肃省靖远师范学校附属小学'
,'高台县解放街小学'
,'西宁市城西区文逸小学'
,'西宁市城中区沈家寨学校'
,'西宁市城北区朝阳学校'
,'西宁市第二中学'
,'青海师大附属实验中学'
,'果洛西宁民族中学'
,'银川市金凤区实验小学'
,'吴忠市朝阳小学'
,'中卫市第十一小学'
,'石嘴山市实验中学'
,'银川市第十五中学'
,'宁夏回族自治区银川一中'
,'乌鲁木齐市第一中学'
,'北京师范大学克拉玛依附属学校'
,'巴音郭楞蒙古自治州石油第一中学'
,'阿勒泰市实验小学'
,'阿克苏市天杭实验学校'
,'乌鲁木齐八一中学'
,'塔里木高级中学'
,'北屯高级中学'
,'石河子第八中学'
,'第七师高级中学'
,'第三师五十一团第二中学'
,'第二师博古其中学'
,'上海市浦东新区张江高科实验小学'
,'陕西西安高新区第十八小学'
,'福建漳州市芗城实验小学'
,'山东济南高新区瀚阳学校'
,'湖南省中南大学第二附属小学'
,'黑龙江七台河市第九小学'
,'湖南师大附小'
,'雨花区长塘里阳光小学'
,'雨花区长塘里小学'
,'长沙市长郡中学（外国语校区）'
,'四川凉山州冕宁县泸沽镇巴姑小学校'
,'云南省怒江州福贡县省定民族完小'
,'怒江民族中学'
,'怒江泸水第一中学'
,'那曲班戈县中学'
,'西藏拉萨中学'
,'甘肃临夏中学'
,'临夏州积石山县中咀岭小学'
,'临夏市八坊小学'
,'青龙县一小'
,'青龙县满族中学'
,'青龙县第四小学'
,'青龙县三星口中学'
,'青龙县双山子初级中学'
,'青龙县大巫岚总校'
,'柳州市融水苗族自治县民族高级中学'
,'紫云县第一小学'
,'紫云县民族高级中学'
,'紫云县第一中学'
,'紫云县第三小学'
,'紫云县第二中学'
,'紫云县白石岩小学'
,'紫云县第四小学'
,'紫云县格凸河小学'
,'紫云县第四小学'
,'紫云县大营镇大营中学'
,'紫云县板当镇板当小学'
,'紫云县大营镇大营希望小学'
,'云南省大理州实验小学'
,'大理市特殊教育学校'
,'雄安新区边村中学'
,'人大附小雄安校区'
,'新疆师大附中'
,'新疆塔城地区第一高级中学'
,'伊宁县第四中学'
,'阿图什市第一中学'
,'和硕县第二中学'
,'尼勒克县克令小学'
,'青海师大附属玉树实验学校'
,'湖南湘江新区真人桥小学'
,'山东潍坊北海教育集团'
,'福州市网龙星纪园学校'
,'广州市荔湾区康有为纪念小学'
,'北师大广州实验学校'
,'广州市铁一中学'
,'广州中学'
)
;
--学校信息-模糊查询
select t.school_id,t.school_name,t.province_name,t.city_name,t.county_name from nddc.dim__school t
LATERAL VIEW EXPLODE(ARRAY(
'南开大学附属中学'
,'肥乡区第二中学'
,'运城'
,'山西省'
,'门河小学'
,'红旗中学'
,'乌兰察布'
,'乌兰浩特第一中学'
,'中山区中心小学'
,'四平市'
,'朝鲜族学校'
,'定海小学'
,'附属外国语学校'
,'屏东中学'
,'英才学校'
,'泉州'
,'济南'
,'第八十四初级中学'
,'西下池小学'
,'宜昌市'
,'田家炳实验小学'
,'新邵县'
,'南山创新学校'
,'琼海小学'
,'景瑞小学'
,'重庆师范大学'
,'礼嘉实验小学'
,'西大'
,'四川省成都市'
,'四川省德阳市'
,'聂耳小学'
,'长庆八中'
,'沈家寨学校'
,'青海师大'
,'石油第一中学'
,'北屯'
,'第三师五十一团'
,'博古其中学'
,'高科实验小学'
,'陕西西安高新区'
,'芗城实验小学'
,'瀚阳学校'
,'湖南省中南大学'
,'黑龙江七台河'
,'湖南师大'
,'雨花区长塘里'
,'长沙市长郡'
,'巴姑'
,'民族完'
,'怒江'
,'怒江'
,'那曲'
,'拉萨'
,'临夏'
,'咀岭小学'
,'青龙县'
,'柳州市融水'
,'紫云县'
,'云南省大理'
,'边村中学'
,'雄安校区'
,'新疆师大'
,'新疆塔城'
,'伊宁县'
,'和硕县'
,'尼勒克县'
,'玉树实验学校'
,'真人桥小学'
,'山东潍坊北海'
,'星纪园学校'
,'北师大广州'
)) tmp1 AS school
where t.dt='${dt}'
and t.school_name like concat('%',school,'%')