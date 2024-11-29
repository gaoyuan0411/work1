-- ==================================================================
-- 脚本名称： dws__md__teacher_verify__da__full.sql
-- 所属专题： 基础数据域
-- 实现功能： 认证教师时段统计表
-- 数据来源：
-- 统计周期： 日
-- 创建者：   188098
-- 创建日期： 2024-04-30
-- 脚本描述： 每天计算时段认证教师统计表
-- 任务流：03.CDM层数据清洗和计算--> 1021.基础数据域-汇总层数据清洗和计算 --> 教师认证统计表（dws__md__teacher_verify__da__full）
-- 参数： tenant_id = '01f59a9013ae46a1928eb098b25976e7'
-- ==================================================================


with
--- 处理累计日期周期维度表
date_period_tmp as (
    -- 获取周期维度数据
    select
        t.period_type_code
        ,period_start_date
        ,period_end_date
        ,date_code
        ,CASE
           WHEN t.period_type_code = 10 THEN '昨日'
           WHEN t.period_type_code = 21 THEN '过去7日'
           WHEN t.period_type_code = 22 THEN '过去14日'
           WHEN t.period_type_code = 31 THEN '过去30日'
           WHEN t.period_type_code = 99 THEN '至今'
           END period_type_text
    from nddc.dim__date_period t
    where t.period_type_code in (10)
    and t.period_end_date = '${biz_date}'
)
, exclude_province as (
    select area_id
    from nddc.dim__whole_area
    where dt = '${biz_date}'
    and area_tag in ('SUNSHINE', 'NCET')
    and area_level = 1
)
, teacher_verify_info as (
    select
        account_id
        ,school_id
        ,school_name
        ,grade_id
        ,grade_name
        ,class_id
        ,class_name
        ,school_section
        ,verify_status
        ,class_type
        ,created_date
        ,verify_date
        ,verifying_date
        ,join_date
        ,user_province_id as province_id
        ,user_province_name as province_name
        ,user_province_code
        ,user_province_short_name
        ,user_city_id as city_id
        ,user_city_name as city_name
        ,user_city_code
        ,user_city_short_name
        ,user_county_id as county_id
        ,user_county_name as county_name
        ,user_county_code
        ,user_county_short_name
        ,is_teacher
        ,is_zxx_user
        ,tenant_id
        ,register_channel
        ,acd.client_id
        ,row_number() over (partition by account_id, class_type order by join_date desc) num
    from nddc.dwd__md__teacher_verify__d__full tvi
    left join exclude_province ep
        on tvi.user_province_id = ep.area_id
    left join nddc.dim__app_client_id_def acd
        on tvi.register_channel = acd.client_id
    where dt = '${biz_date}'
    and created_date <= '${biz_date}'
    and ep.area_id is null
)

,reg_stat as (
    select
        period_start_date
        ,period_end_date
        ,period_type_code
        ,period_type_text
        ,nvl(province_id, 0) as province_id
        ,nvl(province_name, '全国') as province_name
        ,nvl(city_id, 0) as city_id
        ,nvl(city_name, '全市') as city_name
        ,nvl(county_id, 0) as county_id
        ,nvl(county_name, '全县') as county_name
        ,nvl(school_id, 0) as school_id
        ,nvl(school_name, '全校') as school_name
        ,nvl(school_section, 'all') as school_section
        ,count(distinct account_id) register_teacher_count
    from teacher_verify_info tvi
    join date_period_tmp dp
        on tvi.created_date = dp.date_code
    where 1 = 1
          and tenant_id = '${tenant_id}'
          and client_id is not null
    group by period_start_date
             ,period_end_date
             ,period_type_code
             ,period_type_text
             ,province_id
             ,province_name
             ,city_id
             ,city_name
             ,county_id
             ,county_name
             ,school_id
             ,school_name
             ,school_section
    grouping sets (
        (period_start_date,period_end_date,period_type_code,period_type_text),
        (period_start_date,period_end_date,period_type_code,period_type_text,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name,school_section)
    )
    union all
    select
        '${start_date}' as period_start_date
        ,'${biz_date}' as period_end_date
        ,99 as period_type_code
        ,'至今' as period_type_text
        ,nvl(province_id, 0) as province_id
        ,nvl(province_name, '全国') as province_name
        ,nvl(city_id, 0) as city_id
        ,nvl(city_name, '全市') as city_name
        ,nvl(county_id, 0) as county_id
        ,nvl(county_name, '全县') as county_name
        ,nvl(school_id, 0) as school_id
        ,nvl(school_name, '全校') as school_name
        ,nvl(school_section, 'all') as school_section
        ,count(distinct account_id) register_teacher_count
    from teacher_verify_info tvi
    where 1 = 1
          and tenant_id = '${tenant_id}'
          and client_id is not null
    group by province_id
             ,province_name
             ,city_id
             ,city_name
             ,county_id
             ,county_name
             ,school_id
             ,school_name
             ,school_section
    grouping sets (
        (),
        (school_section),
        (province_id,province_name),
        (province_id,province_name,school_section),
        (province_id,province_name,city_id,city_name),
        (province_id,province_name,city_id,city_name,school_section),
        (province_id,province_name,city_id,city_name,county_id,county_name),
        (province_id,province_name,city_id,city_name,county_id,county_name,school_section),
        (province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name),
        (province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name,school_section)
    )
)

,verify_stat as (
    select
        period_start_date
        ,period_end_date
        ,period_type_code
        ,period_type_text
        ,nvl(province_id, 0) as province_id
        ,nvl(province_name, '全国') as province_name
        ,nvl(city_id, 0) as city_id
        ,nvl(city_name, '全市') as city_name
        ,nvl(county_id, 0) as county_id
        ,nvl(county_name, '全县') as county_name
        ,nvl(school_id, 0) as school_id
        ,nvl(school_name, '全校') as school_name
        ,nvl(school_section, 'all') as school_section
        ,count(distinct account_id) certified_teacher_count
    from teacher_verify_info tvi
    join date_period_tmp dp
        on tvi.verify_date = dp.date_code
    where verify_status = '2'
    group by period_start_date
             ,period_end_date
             ,period_type_code
             ,period_type_text
             ,province_id
             ,province_name
             ,city_id
             ,city_name
             ,county_id
             ,county_name
             ,school_id
             ,school_name
             ,school_section
    grouping sets (
        (period_start_date,period_end_date,period_type_code,period_type_text),
        (period_start_date,period_end_date,period_type_code,period_type_text,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name,school_section)
    )
    union all
    select
        '${start_date}' as period_start_date
        ,'${biz_date}' as period_end_date
        ,99 as period_type_code
        ,'至今' as period_type_text
        ,nvl(province_id, 0) as province_id
        ,nvl(province_name, '全国') as province_name
        ,nvl(city_id, 0) as city_id
        ,nvl(city_name, '全市') as city_name
        ,nvl(county_id, 0) as county_id
        ,nvl(county_name, '全县') as county_name
        ,nvl(school_id, 0) as school_id
        ,nvl(school_name, '全校') as school_name
        ,nvl(school_section, 'all') as school_section
        ,count(distinct account_id) certified_teacher_count
    from teacher_verify_info tvi
    where verify_status = '2'
    group by province_id
             ,province_name
             ,city_id
             ,city_name
             ,county_id
             ,county_name
             ,school_id
             ,school_name
             ,school_section
    grouping sets (
        (),
        (school_section),
        (province_id,province_name),
        (province_id,province_name,school_section),
        (province_id,province_name,city_id,city_name),
        (province_id,province_name,city_id,city_name,school_section),
        (province_id,province_name,city_id,city_name,county_id,county_name),
        (province_id,province_name,city_id,city_name,county_id,county_name,school_section),
        (province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name),
        (province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name,school_section)
    )
)

,verifying_stat as (
    select
        period_start_date
        ,period_end_date
        ,period_type_code
        ,period_type_text
        ,nvl(province_id, 0) as province_id
        ,nvl(province_name, '全国') as province_name
        ,nvl(city_id, 0) as city_id
        ,nvl(city_name, '全市') as city_name
        ,nvl(county_id, 0) as county_id
        ,nvl(county_name, '全县') as county_name
        ,nvl(school_id, 0) as school_id
        ,nvl(school_name, '全校') as school_name
        ,nvl(school_section, 'all') as school_section
        ,count(distinct account_id) certified_process_teacher_count
    from teacher_verify_info tvi
    join date_period_tmp dp
        on tvi.verifying_date = dp.date_code
    where verify_status = '1'
    group by period_start_date
             ,period_end_date
             ,period_type_code
             ,period_type_text
             ,province_id
             ,province_name
             ,city_id
             ,city_name
             ,county_id
             ,county_name
             ,school_id
             ,school_name
             ,school_section
    grouping sets (
        (period_start_date,period_end_date,period_type_code,period_type_text),
        (period_start_date,period_end_date,period_type_code,period_type_text,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name,school_section)
    )
    union all
    select
        '${start_date}' as period_start_date
        ,'${biz_date}' as period_end_date
        ,99 as period_type_code
        ,'至今' as period_type_text
        ,nvl(province_id, 0) as province_id
        ,nvl(province_name, '全国') as province_name
        ,nvl(city_id, 0) as city_id
        ,nvl(city_name, '全市') as city_name
        ,nvl(county_id, 0) as county_id
        ,nvl(county_name, '全县') as county_name
        ,nvl(school_id, 0) as school_id
        ,nvl(school_name, '全校') as school_name
        ,nvl(school_section, 'all') as school_section
        ,count(distinct account_id) certified_process_teacher_count
    from teacher_verify_info tvi
    where verify_status = '1'
    group by province_id
             ,province_name
             ,city_id
             ,city_name
             ,county_id
             ,county_name
             ,school_id
             ,school_name
             ,school_section
    grouping sets (
        (),
        (school_section),
        (province_id,province_name),
        (province_id,province_name,school_section),
        (province_id,province_name,city_id,city_name),
        (province_id,province_name,city_id,city_name,school_section),
        (province_id,province_name,city_id,city_name,county_id,county_name),
        (province_id,province_name,city_id,city_name,county_id,county_name,school_section),
        (province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name),
        (province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name,school_section)
    )
)

,class_stat as (
    select
        period_start_date
        ,period_end_date
        ,period_type_code
        ,period_type_text
        ,nvl(province_id, 0) as province_id
        ,nvl(province_name, '全国') as province_name
        ,nvl(city_id, 0) as city_id
        ,nvl(city_name, '全市') as city_name
        ,nvl(county_id, 0) as county_id
        ,nvl(county_name, '全县') as county_name
        ,nvl(school_id, 0) as school_id
        ,nvl(school_name, '全校') as school_name
        ,nvl(school_section, 'all') as school_section
        ,count(distinct account_id) class_teacher_count
    from teacher_verify_info tvi
    join date_period_tmp dp
        on tvi.join_date = dp.date_code
    where num = '1' and class_type = 'CLASS'
      and is_teacher = 1
      and tenant_id = '${tenant_id}'
      and client_id is not null
    group by period_start_date
             ,period_end_date
             ,period_type_code
             ,period_type_text
             ,province_id
             ,province_name
             ,city_id
             ,city_name
             ,county_id
             ,county_name
             ,school_id
             ,school_name
             ,school_section
    grouping sets (
        (period_start_date,period_end_date,period_type_code,period_type_text),
        (period_start_date,period_end_date,period_type_code,period_type_text,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name,school_section)
    )
    union all
    select
        '${start_date}' as period_start_date
        ,'${biz_date}' as period_end_date
        ,99 as period_type_code
        ,'至今' as period_type_text
        ,nvl(province_id, 0) as province_id
        ,nvl(province_name, '全国') as province_name
        ,nvl(city_id, 0) as city_id
        ,nvl(city_name, '全市') as city_name
        ,nvl(county_id, 0) as county_id
        ,nvl(county_name, '全县') as county_name
        ,nvl(school_id, 0) as school_id
        ,nvl(school_name, '全校') as school_name
        ,nvl(school_section, 'all') as school_section
        ,count(distinct account_id) class_teacher_count
    from teacher_verify_info tvi
    where num = '1' and class_type = 'CLASS'
        and is_teacher = 1
        and tenant_id = '${tenant_id}'
        and client_id is not null
    group by province_id
             ,province_name
             ,city_id
             ,city_name
             ,county_id
             ,county_name
             ,school_id
             ,school_name
             ,school_section
    grouping sets (
        (),
        (school_section),
        (province_id,province_name),
        (province_id,province_name,school_section),
        (province_id,province_name,city_id,city_name),
        (province_id,province_name,city_id,city_name,school_section),
        (province_id,province_name,city_id,city_name,county_id,county_name),
        (province_id,province_name,city_id,city_name,county_id,county_name,school_section),
        (province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name),
        (province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name,school_section)
    )
)

,network_stat as (
    select
        period_start_date
        ,period_end_date
        ,period_type_code
        ,period_type_text
        ,nvl(province_id, 0) as province_id
        ,nvl(province_name, '全国') as province_name
        ,nvl(city_id, 0) as city_id
        ,nvl(city_name, '全市') as city_name
        ,nvl(county_id, 0) as county_id
        ,nvl(county_name, '全县') as county_name
        ,nvl(school_id, 0) as school_id
        ,nvl(school_name, '全校') as school_name
        ,nvl(school_section, 'all') as school_section
        ,count(distinct account_id) networkClass_teacher_count
    from teacher_verify_info tvi
    join date_period_tmp dp
        on tvi.join_date = dp.date_code
    where num = 1 and class_type = 'NETWORK_CLASS'
        and is_teacher = 1
        and tenant_id = '${tenant_id}'
        and client_id is not null
    and not exists (
        select 1 from teacher_verify_info c
        where 1=1
        and c.class_type = 'CLASS'
        and tvi.account_id = c.account_id
        and tvi.province_id = c.province_id
        and tvi.city_id = c.city_id
        and tvi.county_id = c.county_id
        and tvi.school_id = c.school_id
    )
    group by period_start_date
             ,period_end_date
             ,period_type_code
             ,period_type_text
             ,province_id
             ,province_name
             ,city_id
             ,city_name
             ,county_id
             ,county_name
             ,school_id
             ,school_name
             ,school_section
    grouping sets (
        (period_start_date,period_end_date,period_type_code,period_type_text),
        (period_start_date,period_end_date,period_type_code,period_type_text,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name,school_section),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name),
        (period_start_date,period_end_date,period_type_code,period_type_text,province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name,school_section)
    )
    union all
    select
        '${start_date}' as period_start_date
        ,'${biz_date}' as period_end_date
        ,99 as period_type_code
        ,'至今' as period_type_text
        ,nvl(province_id, 0) as province_id
        ,nvl(province_name, '全国') as province_name
        ,nvl(city_id, 0) as city_id
        ,nvl(city_name, '全市') as city_name
        ,nvl(county_id, 0) as county_id
        ,nvl(county_name, '全县') as county_name
        ,nvl(school_id, 0) as school_id
        ,nvl(school_name, '全校') as school_name
        ,nvl(school_section, 'all') as school_section
        ,count(distinct account_id) networkClass_teacher_count
    from teacher_verify_info tvi
    where num = 1 and class_type = 'NETWORK_CLASS'
        and is_teacher = 1
        and tenant_id = '${tenant_id}'
        and client_id is not null
    and not exists (
        select 1 from teacher_verify_info c
        where 1=1
        and c.class_type = 'CLASS'
        and tvi.account_id = c.account_id
        and tvi.province_id = c.province_id
        and tvi.city_id = c.city_id
        and tvi.county_id = c.county_id
        and tvi.school_id = c.school_id
    )
    group by province_id
             ,province_name
             ,city_id
             ,city_name
             ,county_id
             ,county_name
             ,school_id
             ,school_name
             ,school_section
    grouping sets (
        (),
        (school_section),
        (province_id,province_name),
        (province_id,province_name,school_section),
        (province_id,province_name,city_id,city_name),
        (province_id,province_name,city_id,city_name,school_section),
        (province_id,province_name,city_id,city_name,county_id,county_name),
        (province_id,province_name,city_id,city_name,county_id,county_name,school_section),
        (province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name),
        (province_id,province_name,city_id,city_name,county_id,county_name,school_id,school_name,school_section)
    )
)
,merge_data as (
    select
        period_start_date
        ,period_end_date
        ,period_type_code
        ,period_type_text
        ,province_id
        ,province_name
        ,city_id
        ,city_name
        ,county_id
        ,county_name
        ,school_id
        ,school_name
        ,school_section
        ,max(register_teacher_count) as register_teacher_count
        ,max(certified_teacher_count) as certified_teacher_count
        ,max(certified_process_teacher_count) as certified_process_teacher_count
        ,max(class_teacher_count) as class_teacher_count
        ,max(networkClass_teacher_count) as networkClass_teacher_count
    from (
        select
            period_start_date
            ,period_end_date
            ,period_type_code
            ,period_type_text
            ,province_id
            ,province_name
            ,city_id
            ,city_name
            ,county_id
            ,county_name
            ,school_id
            ,school_name
            ,school_section
            ,0 register_teacher_count
            ,0 certified_teacher_count
            ,0 certified_process_teacher_count
            ,0 class_teacher_count
            ,networkClass_teacher_count
        from network_stat
        union all
        select
            period_start_date
            ,period_end_date
            ,period_type_code
            ,period_type_text
            ,province_id
            ,province_name
            ,city_id
            ,city_name
            ,county_id
            ,county_name
            ,school_id
            ,school_name
            ,school_section
            ,0 register_teacher_count
            ,0 certified_teacher_count
            ,0 certified_process_teacher_count
            ,class_teacher_count
            ,0 networkClass_teacher_count
        from class_stat
        union all
        select
            period_start_date
            ,period_end_date
            ,period_type_code
            ,period_type_text
            ,province_id
            ,province_name
            ,city_id
            ,city_name
            ,county_id
            ,county_name
            ,school_id
            ,school_name
            ,school_section
            ,0 register_teacher_count
            ,0 certified_teacher_count
            ,certified_process_teacher_count
            ,0 class_teacher_count
            ,0 networkClass_teacher_count
        from verifying_stat
        union all
        select
            period_start_date
            ,period_end_date
            ,period_type_code
            ,period_type_text
            ,province_id
            ,province_name
            ,city_id
            ,city_name
            ,county_id
            ,county_name
            ,school_id
            ,school_name
            ,school_section
            ,register_teacher_count
            ,0 certified_teacher_count
            ,0 certified_process_teacher_count
            ,0 class_teacher_count
            ,0 networkClass_teacher_count
        from reg_stat
        union all
        select
            period_start_date
            ,period_end_date
            ,period_type_code
            ,period_type_text
            ,province_id
            ,province_name
            ,city_id
            ,city_name
            ,county_id
            ,county_name
            ,school_id
            ,school_name
            ,school_section
            ,0 register_teacher_count
            ,certified_teacher_count
            ,0 certified_process_teacher_count
            ,0 class_teacher_count
            ,0 networkClass_teacher_count
        from verify_stat
    ) t
    group by  period_start_date
             ,period_end_date
             ,period_type_code
             ,period_type_text
             ,province_id
             ,province_name
             ,city_id
             ,city_name
             ,county_id
             ,county_name
             ,school_id
             ,school_name
             ,school_section
)



insert overwrite table dws__md__teacher_verify__da__full partition(dt = '${biz_date}')
select
    period_start_date
    ,period_end_date
    ,period_type_code
    ,period_type_text
    ,province_id
    ,province_name
    ,city_id
    ,city_name
    ,county_id
    ,county_name
    ,school_id
    ,school_name
    ,school_section
    ,register_teacher_count
    ,certified_teacher_count
    ,certified_process_teacher_count
    ,register_teacher_count - certified_teacher_count - certified_process_teacher_count as un_certified_teacher_count
    ,class_teacher_count
    ,networkClass_teacher_count
    ,current_timestamp() stat_time
from merge_data
