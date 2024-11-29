--原型 https://2ttbn8.axshare.com/#id=97zo33&p=01_%E7%A7%AF%E5%88%86%E5%88%86%E6%9E%90&g=1
--口径 https://docs.qq.com/sheet/DU3ZCdExQeW54d1hZ?tab=sh0rqg
--提测文档 https://zxxedu.yuque.com/xv0o5a/tac62c/xrhzbii5l74nbg37#CeGWs
-- 	https://zxxedu.yuque.com/xv0o5a/tac62c/md6od2nfzg5m1w38
-- 	https://zxxedu.yuque.com/xv0o5a/tac62c/kocce3h8w49h5m94

-- #认证教师部分原始表

-- 新旧表未修改指标校验
select 1,count(dt),sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from nddc.dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1)
union all
select 2,count(dt),sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from nddc_uat.dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1)


select * from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1) and tenant_id='01f59a9013ae46a1928eb098b25976e7'
select * from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1) and tenant_id='01f59a9013ae46a1928eb098b25976e7' and is_teacher !=1

select * from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1) and tenant_id='01f59a9013ae46a1928eb098b25976e7' and account_id in(452315611414,452315658460)
select*from dim__whole_area t where dt =date_sub(current_date,1) and area_level = 1 and area_tag in('NORMAL','SAR')
select distinct user_province_id,user_province_name from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1) and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in('980000','990000')

select*from dim__app_client_id_def t 
select*from dim__whole_area t where dt =date_sub(current_date,1) and area_level = 1 and area_tag in('NORMAL','SAR')
-- 校验同一个人是否出现在两个省，不会
select account_id,count(distinct user_province_id,user_province_name) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by account_id having count(distinct user_province_id,user_province_name)>1

# 用户会重复
select account_id,count(1) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1) and tenant_id='01f59a9013ae46a1928eb098b25976e7' group by account_id having count(1)>1
-- 从再上一层表算教师类总数 24948810
select count(distinct account_id) from dwd__md__person_account__d__full t where dt =date_sub(current_date,1) and is_canceled = 0 AND (is_teacher + is_manager + is_electric_teacher + is_academic_staff) > 0 and tenant_id='01f59a9013ae46a1928eb098b25976e7' and user_province_id not in(594036056566,594035816785) and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null)
-- 全国至今  分学段 教师类总数 24948810
select 'all' as school_section, count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) 
union all
select school_section,count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by school_section order by school_section desc
-- 全国30天  分学段 教师类总数
select 'all' as school_section, count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,30) and date_sub( current_date,1)  and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) 
union all
select school_section,count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,30) and date_sub( current_date,1) and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by school_section order by school_section desc
-- 全国14天  分学段 教师类总数
select 'all' as school_section, count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,14) and date_sub( current_date,1)  and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) 
union all
select school_section,count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,14) and date_sub( current_date,1) and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by school_section order by school_section desc
-- 全国7天  分学段 教师类总数
select 'all' as school_section, count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,7) and date_sub( current_date,1)  and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) 
union all
select school_section,count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,7) and date_sub( current_date,1) and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by school_section order by school_section desc
-- 全国昨天  分学段 教师类总数
select 'all' as school_section, count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,1) and date_sub( current_date,1)  and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) 
union all
select school_section,count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,1) and date_sub( current_date,1) and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by school_section order by school_section desc

-- 分省至今  分学段 教师类总数
select user_province_id,user_province_name,'all' as school_section, count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by user_province_id,user_province_name
union all
select user_province_id,user_province_name,school_section,count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by user_province_id,user_province_name,school_section order by user_province_id,user_province_name,school_section desc
-- 分省30天  分学段 教师类总数
select user_province_id,user_province_name,'all' as school_section, count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,30) and date_sub( current_date,1)  and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by user_province_id,user_province_name
union all
select user_province_id,user_province_name,school_section,count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,30) and date_sub( current_date,1) and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by user_province_id,user_province_name,school_section order by user_province_id,user_province_name,school_section desc
-- 分省14天  分学段 教师类总数
select user_province_id,user_province_name,'all' as school_section, count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,14) and date_sub( current_date,1)  and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by user_province_id,user_province_name
union all
select user_province_id,user_province_name,school_section,count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,14) and date_sub( current_date,1) and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by user_province_id,user_province_name,school_section order by user_province_id,user_province_name,school_section desc
-- 分省7天  分学段 教师类总数
select user_province_id,user_province_name,'all' as school_section, count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,7) and date_sub( current_date,1)  and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by user_province_id,user_province_name
union all
select user_province_id,user_province_name,school_section,count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,7) and date_sub( current_date,1) and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by user_province_id,user_province_name,school_section order by user_province_id,user_province_name,school_section desc
-- 分省昨天  分学段 教师类总数
select user_province_id,user_province_name,'all' as school_section, count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,1) and date_sub( current_date,1)  and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by user_province_id,user_province_name
union all
select user_province_id,user_province_name,school_section,count(distinct account_id) from dwd__md__teacher_verify__d__full t where dt =date_sub(current_date,1)  and tenant_id='01f59a9013ae46a1928eb098b25976e7' and nvl(user_province_id,0) not in(594036056566,594035816785) and created_date between date_sub( current_date,1) and date_sub( current_date,1) and created_date <=dt and register_channel in(select client_id from dim__app_client_id_def where client_id is not null) group by user_province_id,user_province_name,school_section order by user_province_id,user_province_name,school_section desc


#认证教师部分dws、ads表

---- 全国至今 分学段 教师类总数
select*from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id =0 and period_type_code=99 order by school_section desc
---- 全国30天 分学段 教师类总数
select*from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id =0 and period_type_code=31 order by school_section desc
---- 全国14天 分学段 教师类总数
select*from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id =0 and period_type_code=22 order by school_section desc
---- 全国7天 分学段 教师类总数
select*from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id =0 and period_type_code=21 order by school_section desc
---- 全国昨天 分学段 教师类总数
select*from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id =0 and period_type_code=10 order by school_section desc

---- 分省至今 分学段 教师类总数
select*from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id =0 and period_type_code=99 order by province_id,school_section desc
select*from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id =0 and period_type_code=99 and school_section='all' order by province_id 
---- 分省30天 分学段 教师类总数
select*from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id =0 and period_type_code=31 order by province_id,school_section desc
---- 分省14天 分学段 教师类总数
select*from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id =0 and period_type_code=22 order by province_id,school_section desc
---- 分省7天 分学段 教师类总数
select*from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id =0 and period_type_code=21 order by province_id,school_section desc
---- 分省昨天 分学段 教师类总数
select*from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id =0 and period_type_code=10 order by province_id,school_section desc

--dws全部数据自洽 全国、省级、市级、县级、学校级
select 1,sum(register_teacher_count) register_teacher_count,sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(un_certified_teacher_count) un_certified_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id =0
union all
select 2,sum(register_teacher_count) register_teacher_count,sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(un_certified_teacher_count) un_certified_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id =0
union all
select 3,sum(register_teacher_count) register_teacher_count,sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(un_certified_teacher_count) un_certified_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id !=0 and county_id =0
union all
select 4,sum(register_teacher_count) register_teacher_count,sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(un_certified_teacher_count) un_certified_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id !=0 and county_id !=0 and school_id =0  
union all
select 5,sum(register_teacher_count) register_teacher_count,sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(un_certified_teacher_count) un_certified_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id !=0 and county_id !=0 and school_id !=0  


--ads 概览表
select*from ads__teacher_verify__overview_period_stat__da__full t where dt =date_sub(current_date,1) and province_id =0 and period_type_code=99 order by school_section desc
--概览表全国
select*from ads__teacher_verify__overview_period_stat__da__full t where dt =date_sub(current_date,1) and province_id =0 and city_id =0 and period_type_code=99 and school_section='all'
--概览表省份
select*from ads__teacher_verify__overview_period_stat__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id =0  and period_type_code=99 and school_section='all'
--概览表城市
select*from ads__teacher_verify__overview_period_stat__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id !=0 and area_id=0  and period_type_code=99 and school_section='all'
--概览表区县
select*from ads__teacher_verify__overview_period_stat__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id !=0 and area_id !=0 and school_id=0  and period_type_code=99 and school_section='all'
--概览表学校
select*from ads__teacher_verify__overview_period_stat__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id !=0 and area_id !=0 and school_id !=0  and period_type_code=99 and school_section='all'

--ads 概览全部数据自洽 全国、省级、市级、县级、学校级
select 1,sum(register_teacher_count) register_teacher_count,sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(un_certified_teacher_count) un_certified_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from ads__teacher_verify__overview_period_stat__da__full t where dt =date_sub(current_date,1) and province_id =0
union all
select 2,sum(register_teacher_count) register_teacher_count,sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(un_certified_teacher_count) un_certified_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from ads__teacher_verify__overview_period_stat__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id =0
union all
select 3,sum(register_teacher_count) register_teacher_count,sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(un_certified_teacher_count) un_certified_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from ads__teacher_verify__overview_period_stat__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id !=0 and area_id =0
union all
select 4,sum(register_teacher_count) register_teacher_count,sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(un_certified_teacher_count) un_certified_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from ads__teacher_verify__overview_period_stat__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id !=0 and area_id !=0 and school_id =0  
union all
select 5,sum(register_teacher_count) register_teacher_count,sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(un_certified_teacher_count) un_certified_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from ads__teacher_verify__overview_period_stat__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id !=0 and area_id !=0 and school_id !=0  
--ads 趋势全部数据自洽 全国、省级、市级、县级、学校级
select 1,sum(register_teacher_count) register_teacher_count,sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(un_certified_teacher_count) un_certified_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from ads__teacher_verify__overview_stat_daily__d t where dt =date_sub(current_date,1) and province_id =0 and school_section ='all'
union all
select 2,sum(register_teacher_count) register_teacher_count,sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(un_certified_teacher_count) un_certified_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from ads__teacher_verify__overview_stat_daily__d t where dt =date_sub(current_date,1) and province_id !=0 and city_id =0 and school_section ='all'
union all
select 3,sum(register_teacher_count) register_teacher_count,sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(un_certified_teacher_count) un_certified_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from ads__teacher_verify__overview_stat_daily__d t where dt =date_sub(current_date,1) and province_id !=0 and city_id !=0 and area_id =0 and school_section ='all'
union all
select 4,sum(register_teacher_count) register_teacher_count,sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(un_certified_teacher_count) un_certified_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from ads__teacher_verify__overview_stat_daily__d t where dt =date_sub(current_date,1) and province_id !=0 and city_id !=0 and area_id !=0 and school_id =0  and school_section ='all' 
union all
select 5,sum(register_teacher_count) register_teacher_count,sum(certified_teacher_count) certified_teacher_count,sum(certified_process_teacher_count) certified_process_teacher_count,sum(un_certified_teacher_count) un_certified_teacher_count,sum(class_teacher_count) class_teacher_count,sum(networkclass_teacher_count) networkclass_teacher_count from ads__teacher_verify__overview_stat_daily__d t where dt =date_sub(current_date,1) and province_id !=0 and city_id !=0 and area_id !=0 and school_id !=0  and school_section ='all'

--全国30天趋势
select*from ads__teacher_verify__overview_stat_daily__d t where dt between date_sub(current_date,30)  and date_sub(current_date,1) and province_id =0 and period_type_code=99 and school_section ='all'



#教师积分部分原始表
-- 抽查积分老数据
-- 2024年概览 全国
set tez.queue.name=nddc;

select count(distinct(b.user_id)) incentive_number,sum(cast(b.amount as decimal(20,6))) incentive_score, sum((cast(b.amount as decimal(20,6))))/count(distinct(a.account_id)) incentive_avg_score	from 
(select * from dwd__md__person_account__d__full t where dt ='2024-11-13' and is_canceled = 0 AND (is_teacher + is_manager + is_electric_teacher + is_academic_staff) > 0 and user_province_id not in(594035816785)) a left join
(select * from nddc.dwd__incentive__teacher__incentive_detail__d__full t  where dt ='2024-11-13' and version=2024 and type ='income' and tenant_id ='416') b  on b.user_id =a.account_id 

-- 2024年概览 全国 分教师类型
select verify_status,count(distinct(b.user_id)) incentive_number,sum(cast(b.amount as decimal(20,6))) incentive_score, sum(cast(b.amount as decimal(20,6))) /24697677 from 
(select * from dwd__md__person_account__d__full t where dt ='2024-11-13' and is_canceled = 0 AND (is_teacher + is_manager + is_electric_teacher + is_academic_staff) > 0 and user_province_id not in(594035816785)) a left join
(select * from nddc.dwd__incentive__teacher__incentive_detail__d__full t  where dt ='2024-11-13' and version=2024 and type ='income' and tenant_id ='416') b  on b.user_id =a.account_id left join
(select distinct account_id,verify_status from dwd__md__teacher_verify__d__full t where dt ='2024-11-13' and verify_status IN ('2','1')) c on a.account_id=c.account_id group by verify_status order by verify_status

-- 2024年概览 分省
select user_province_id,user_province_name,count(distinct(b.user_id)) incentive_number,sum(cast(b.amount as decimal(20,6))) incentive_score, sum(cast(b.amount as decimal(20,6)))/count(distinct(a.account_id)) incentive_avg_score from 
(select * from dwd__md__person_account__d__full t where dt ='2024-11-13' and is_canceled = 0 AND (is_teacher + is_manager + is_electric_teacher + is_academic_staff) > 0 and user_province_id not in(594035816785)) a left join
(select * from nddc.dwd__incentive__teacher__incentive_detail__d__full t  where dt ='2024-11-13' and version=2024 and type ='income' and tenant_id ='416') b  on b.user_id =a.account_id 
group by user_province_id,user_province_name order by user_province_id

-- 2024 全国趋势总量 分教师类型 
select verify_status,count(distinct(b.user_id)) incentive_number,sum(cast(b.amount as decimal(20,6))) incentive_score from 
(select * from dwd__md__person_account__d__full t where dt ='2024-11-13' and is_canceled = 0 AND (is_teacher + is_manager + is_electric_teacher + is_academic_staff) > 0 and user_province_name ='黑龙江省') a left join
(select *, DATE_FORMAT(biz_time, 'yyyy-MM-dd') AS biz_date from nddc.dwd__incentive__teacher__incentive_detail__d__full t  where dt ='2024-11-13' and  DATE_FORMAT(biz_time, 'yyyy-MM-dd') <='2024-11-13' and version=2024 and type ='income' and tenant_id ='416') b  on b.user_id =a.account_id left join
(select distinct account_id,verify_status from dwd__md__teacher_verify__d__full t where dt ='2024-11-13' and verify_status IN ('2','1')) d on a.account_id=d.account_id group by verify_status order by verify_status


#教师积分部分ads表验算
--概览表 全国 全部教师类型 全部积分类型 pass 24948810
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2023 and province_id =0  and verify_status='0' and type_code='all' 
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and province_id =0 and verify_status='0'and type_code='all'
--教师基数总数 24948810
select sum(teacher_base_num) teacher_base_num from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and area_type ='province' and type_code ='all' and verify_status =0 
--概览表和积分类型 全国 分教师类型 pass
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2023 and province_id =0 and verify_status !='0' and type_code='all' order by type_level,verify_status,parent_type,type_code_1,type_code_2
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and province_id =0 and verify_status !='0' and type_code='all' order by type_level,verify_status,parent_type,type_code_2,type_code_1
--教师基数总数 24948810
select sum(teacher_base_num) teacher_base_num  from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and province_id =0 and verify_status !='0' and type_code='all' 

--概览表 分省  全部教师类型 全部积分类型 pass
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2023 and area_type ='province' and type_code ='all' and verify_status =0 order by province_id,verify_status
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and area_type ='province' and type_code ='all' and verify_status =0 order by province_id,verify_status
--教师基数总数 24948810
select sum(teacher_base_num) teacher_base_num from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and area_type ='province' and type_code ='all' and verify_status =0 
--概览表和积分类型 分省 分教师类型 pass
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2023 and  area_type ='province' and verify_status !='0' and type_code='all' order by province_id,type_level,verify_status,parent_type,type_code_1,type_code_2
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and  area_type ='province' and verify_status !='0' and type_code='all' order by province_id,type_level,verify_status,parent_type,type_code_2,type_code_1
--教师基数总数 24948810
select sum(teacher_base_num) teacher_base_num from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and  area_type ='province' and verify_status !='0' and type_code='all' 

--概览表 分城市  全部教师类型 全部积分类型 pass
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2023 and area_type ='city' and type_code ='all' and verify_status =0 order by province_id,city_id,verify_status
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and area_type ='city' and type_code ='all' and verify_status =0 order by province_id,city_id,verify_status
--教师基数总数 24948809
select sum(teacher_base_num) teacher_base_num from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and area_type ='city' and type_code ='all' and verify_status =0 
--有注册教师基数，没有积分
select * from
(select*from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id !=0 and county_id =0 and period_type_code=99 and school_section='all') a left join
(select * from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and area_type ='city' and type_code ='all' and verify_status =0 ) b on a.province_id =b.province_id and a.city_id=b.city_id where b.province_id is null
--概览表和积分类型 分城市 分教师类型 pass
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2023 and  area_type ='city' and verify_status !='0' and type_code='all' order by province_id,city_id,type_level,verify_status,parent_type,type_code_1,type_code_2
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and  area_type ='city' and verify_status !='0' and type_code='all' order by province_id,city_id,type_level,verify_status,parent_type,type_code_2,type_code_1
--注册教师基数总数 24948809
select sum(teacher_base_num) teacher_base_num from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and  area_type ='city' and verify_status !='0' and type_code='all' 

--概览表 分区县  全部教师类型 全部积分类型 pass
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2023 and area_type ='area' and type_code ='all' and verify_status =0 order by province_id,city_id,area_id,verify_status
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and area_type ='area' and type_code ='all' and verify_status =0 order by province_id,city_id,area_id,verify_status
--有积分区域注册教师基数总数 24948790
select sum(teacher_base_num) teacher_base_num from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and area_type ='area' and type_code ='all' and verify_status =0 
--有注册教师基数，没有积分
select * from
(select*from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id !=0 and county_id !=0 and school_id =0 and period_type_code=99 and school_section='all') a left join
(select * from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and area_type ='area' and type_code ='all' and verify_status =0 ) b on a.province_id =b.province_id and a.city_id=b.city_id and a.county_id =b.area_id where b.province_id is null
--概览表和积分类型 分区县 分教师类型 pass
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2023 and  area_type ='area' and verify_status !='0' and type_code='all' order by province_id,city_id,area_id,type_level,verify_status,parent_type,type_code_1,type_code_2
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and  area_type ='area' and verify_status !='0' and type_code='all' order by province_id,city_id,area_id,type_level,verify_status,parent_type,type_code_2,type_code_1
--有积分区域注册教师基数总数 24948762
select sum(teacher_base_num) teacher_base_num from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and  area_type ='area' and verify_status !='0' and type_code='all' 

--概览表 学校 全部教师类型 全部积分类型 pass
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2023 and area_type ='school' and type_code ='all' and verify_status =0 order by province_id,city_id,area_id,school_id
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and area_type ='school' and type_code ='all' and verify_status =0 and school_id=594034096106
--有积分区域注册教师基数总数 24879340
select sum(teacher_base_num) teacher_base_num from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and area_type ='school' and type_code ='all' and verify_status =0 and school_id !=0
--有注册教师基数，没有积分
select * from
(select*from dws__md__teacher_verify__da__full t where dt =date_sub(current_date,1) and province_id !=0 and city_id !=0 and county_id !=0 and school_id !=0 and period_type_code=99 and school_section='all') a left join
(select * from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and area_type ='school' and type_code ='all' and verify_status =0 ) b on a.province_id =b.province_id and a.city_id=b.city_id and a.county_id =b.area_id and a.school_id=b.school_id where b.province_id is null
--概览表和积分类型 分学校 分教师类型 pass
select * from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and  area_type ='school' and verify_status !='0' and type_code='all' and school_id=594035274110 order by province_id,city_id,area_id,type_level,verify_status,parent_type,type_code_1,type_code_2
--有积分区域注册教师基数总数 24641161
select sum(teacher_base_num) teacher_base_num from ads__incentive__teacher__overview_period_stat__d t where dt =2024 and  area_type ='school' and verify_status !='0' and type_code='all' 

--老数据自洽
select 0,sum(incentive_number),sum(incentive_score),max(max_incentive_score) from nddc_uat.ads__incentive__teacher__overview_period_stat__d t where dt =2024 and province_id =0  and type_code ='all' 
union all
select 1,sum(incentive_number),sum(incentive_score),max(max_incentive_score) from nddc_uat.ads__incentive__teacher__overview_period_stat__d t where dt =2024 and province_id !=0 and city_id =0 and type_code ='all'  
union all
select 2,sum(incentive_number),sum(incentive_score),max(max_incentive_score) from nddc_uat.ads__incentive__teacher__overview_period_stat__d t where dt =2024 and province_id !=0 and city_id !=0 and area_id =0 and type_code ='all'
union all
select 3,sum(incentive_number),sum(incentive_score),max(max_incentive_score) from nddc_uat.ads__incentive__teacher__overview_period_stat__d t where dt =2024 and province_id !=0 and city_id !=0 and area_id !=0 and school_id =0 and type_code ='all' 
union all
select 4,sum(incentive_number),sum(incentive_score),max(max_incentive_score) from nddc_uat.ads__incentive__teacher__overview_period_stat__d t where dt =2024 and province_id !=0 and city_id !=0 and area_id !=0 and school_id !=0 and type_code ='all'
union all
select 5,2*count(user_id) ,2*sum(incentive_score) ,max(incentive_score) from nddc_uat.ads__incentive__teacher__user_period_stat__d t where dt ='2024'

--趋势数据和异常趋势
select*from ads__incentive__teacher__trend_stat__d t where dt=date_sub(current_date,1) and province_id =0
select*from ads__incentive__teacher__trend_stat__d t where dt=date_sub(current_date,1) and area_type ='province' and teacher_base_num<=0
select*from ads__incentive__teacher__trend_stat__d t where dt=date_sub(current_date,1) and area_type ='city' and teacher_base_num<=0
select*from ads__incentive__teacher__trend_stat__d t where dt=date_sub(current_date,1) and area_type ='area' and teacher_base_num<=0
select*from ads__incentive__teacher__trend_stat__d t where dt=date_sub(current_date,1) and area_type ='school' and teacher_base_num<=0
--教师类基数和上面概览表的求和自洽,概览积分总数>=趋势积分总数
select 1,sum(teacher_base_num) teacher_base_num,sum(total_incentive_score) total_incentive_score from ads__incentive__teacher__trend_stat__d t where dt=date_sub(current_date,1) and province_id =0 and verify_status !=0
union all
select 2,sum(teacher_base_num) teacher_base_num,sum(total_incentive_score) total_incentive_score from ads__incentive__teacher__trend_stat__d t where dt=date_sub(current_date,1) and area_type ='province' and verify_status !=0
union all
select 3,sum(teacher_base_num) teacher_base_num,sum(total_incentive_score) total_incentive_score from ads__incentive__teacher__trend_stat__d t where dt=date_sub(current_date,1) and area_type ='city' and verify_status !=0
union all
select 4,sum(teacher_base_num) teacher_base_num,sum(total_incentive_score) total_incentive_score from ads__incentive__teacher__trend_stat__d t where dt=date_sub(current_date,1) and area_type ='area' and verify_status !=0
union all
select 5,sum(teacher_base_num) teacher_base_num,sum(total_incentive_score) total_incentive_score from ads__incentive__teacher__trend_stat__d t where dt=date_sub(current_date,1) and area_type ='school' and verify_status !=0
