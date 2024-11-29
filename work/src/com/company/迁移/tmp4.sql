drop table if exists dwt__regin_screen__radar__d;
create table if not exists dwt__regin_screen__radar__d(
    province_id bigint comment '省id',
    teacher_register_score decimal(10,6) comment '教师注册情况',
    student_register_score decimal(10,6) comment '学生注册情况',
    guardian_register_score decimal(10,6) comment '家长注册情况',
    area_activation_score decimal(10,6) comment '区域激活情况',
    school_activation_score decimal(10,6) comment '学校激活情况',
    teacher_verify_score decimal(10,6) comment '教师认证情况',
    area_manager_active_score decimal(10,6) comment '区域管理员活跃情况',
    area_pv_score decimal(10,6) comment '区域浏览情况-广度（PV）',
    register_pv_score decimal(10,6) comment '注册用户页面浏览情况（PV）-活跃度',
    resource_pv_score decimal(10,6) comment '注册用户浏览资源数量情况',
    resource_assessment_score decimal(10,6) comment '注册用户资源评价情况',
    class_group_score decimal(10,6) comment '班均群组情况',
    user_participate_score decimal(10,6) comment '注册用户参与活动情况',
    activity_publish_score decimal(10,6) comment '群组发布活动数',
    summer_special_activity_2022_score decimal(10,6) comment '暑期教师专项研修活动（2022年度）',
    summer_special_activity_2023_score decimal(10,6) comment '暑期教师专项研修活动（2023年度）',
    winter_special_activity_2023_score decimal(10,6) comment '寒假教师专项研修活动（2023年度）',
    teacher_app_score decimal(10,6) comment '教师应用',
    student_app_score decimal(10,6) comment '学生应用',
    stat_time string comment '统计时间-数据写入的当前时间'
) comment '民族司大屏-省级雷达图统计'
    partitioned by (dt string comment '分区-日期(yyyy-MM-dd)'
        ,type string comment '分区-统计类型')
    row format delimited null defined as '';


WITH
    -- 需要统计的省份数据
    nation_province_data as (
        select 594033008585 as province_id, 594033008585 as real_province_id, '西藏' as province_name
        union all
        select 594033008543 as province_id, 594033008543 as real_province_id, '内蒙古' as province_name
        union all
        select 594033008593 as province_id, 594033008593 as real_province_id, '宁夏' as province_name
        union all
        -- 新疆生产建设兵团
        select 594033008595 as province_id, 594033008597 as real_province_id, '新疆（含兵团）' as province_name
        union all
        select 594033008595 as province_id, 594033008595 as real_province_id, '新疆（含兵团）' as province_name
        union all
        select 594033008591 as province_id, 594033008591 as real_province_id, '青海' as province_name
        union ALL
        select 594033008575 as province_id, 594033008575 as real_province_id, '海南' as province_name
        union ALL
        select 594033008571 as province_id, 594033008571 as real_province_id, '广东' as province_name
        union ALL
        select 594033008589 as province_id, 594033008589 as real_province_id, '甘肃' as province_name
    )
    -- 地区基数
    ,user_cardinality AS (
        select npd.province_id
             , dauc.org_name                  as province
             , SUM(dauc.student_num) AS student_num
             , SUM(dauc.teacher_num) AS teacher_num
             , SUM(dauc.student_num) + SUM(dauc.teacher_num) as base_num
        from nddc.dim_area_user_cardinality dauc
        inner join nation_province_data  npd
        ON dauc.org_id=npd.real_province_id
        GROUP BY npd.province_id,dauc.org_name
    )

-- ====================== 注册情况 ======================
-- 注册用户数据：dwd__ur__user_info__d__full
    ,registe_data AS (
        SELECT province_id
             , count(DISTINCT IF(user_identity = 'STUDENT', account_id, NULL))  as student_user_cnts
             , count(DISTINCT IF(user_identity = 'TEACHER', account_id, NULL))  as teacher_user_cnts
             , count(DISTINCT IF(user_identity IN ('STUDENT','TEACHER'),account_id, NULL)) AS tea_stu_user_cnts
             , count(DISTINCT IF(user_identity = 'GUARDIAN', account_id, NULL)) as guardian_user_cnts
             , COUNT(DISTINCT account_id)                                       AS all_user_cnts
        FROM (
                 SELECT duuidf.account_id
                      , npd.province_id
                      , duuidf.user_identity
                 FROM nation_province_data  npd
                 INNER JOIN nddc.dwd__ur__user_info__d__full duuidf
                 on npd.real_province_id=duuidf.province_id
                 WHERE duuidf.dt = '${full_biz_date}'
                   -- 西藏          内蒙          宁夏          广西          新疆兵团       新疆自治区     青海
                   AND duuidf.app_id = 'zxx'
                   AND date_format(duuidf.registe_time, 'yyyy-MM-dd') <= '${biz_date}'
                   and duuidf.identity_delete_time is null
             ) uc
        GROUP BY province_id
    )
    -- 注册分数
    ,registe_data_score AS (
        SELECT uc.province_id
             ,uc.province
             , ROUND(IF((rd.teacher_user_cnts / teacher_num) > 1, 1, (rd.teacher_user_cnts / teacher_num)) * 4,
                     6) teacher_register_score
             , ROUND(IF((rd.student_user_cnts / student_num) > 1, 1, (rd.student_user_cnts / student_num)) * 4,
                     6) student_register_score
             , ROUND(IF((rd.guardian_user_cnts / student_num) > 1, 1, (rd.guardian_user_cnts / student_num)) * 2,
                     6) guardian_register_score
            ,rd.tea_stu_user_cnts/uc.base_num as tea_stu_register_score
            ,rd.all_user_cnts
            ,rd.tea_stu_user_cnts
        FROM user_cardinality uc
                 INNER JOIN registe_data rd
                            ON uc.province_id = rd.province_id
    )
-- ====================== 管理情况 ======================
-- 组织数据：dim__organization
-- 区域激活数据：dwd__edu_admin__node_active_d
-- 学校激活数据：dwd__edu_admin__school_d
-- 教师认证数据：dwd__md__teacher_verify__d__full
-- 管理员活跃数据：dwd__uc__manager_active_d,dwd__edu_admin__area_manager_active_d
-- 管理员明细数据：ods__edu_admin_manage_api__t_area_manager_full
-- 管理员登录数据：ods__e_area_api__t_area_app_role_full
    -- 区域激活
    ,org_data as (
      select
        org_id,
        node_name,
        parent_id,
        node_path,
      	node_type,
        level_1_org_id,
        level_2_org_id,
        level_3_org_id,
        level_4_org_id,
        org_level
      from nddc.dim__organization where dt = '${biz_date}' and node_type = 'NT_DISTRICT'
    ),
    role_d as (
      select role_id,role_name from (
    		select
    		    code as role_id,
    		    name as role_name,
    		    row_number() over (partition BY code ORDER BY update_time DESC) num
    		  from nddc.ods__rbac__role__full
    		  where dt = '${biz_date}' and deleted = false ) t where num = 1
    ),
    app_role as (
    	select distinct role_code
    	from nddc.ods__e_area_api__t_area_app_role_full where dt = '${biz_date}' and delete_timestamp = 0 and app_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
    	union all
    	select '0' role_code
    ),
    org_role_data as (
    	select
    		org_id,
    		role_code,
    		level_1_org_id,
        level_2_org_id,
        level_3_org_id,
        level_4_org_id
    	from org_data, app_role
    ),
    all_manager as (
    	select
        user_id,
        role_id,
        org_id,
        node_path org_path,
    	  active_status
    	from nddc.dwd__edu_admin__area_manager_active_d
    	where dt = '${biz_date}' and role_id is not null and delete_status = 0 and org_id <> 0
    ),
    all_level_data as (
      select b.org_id,
          b.role_code,
          a.active_status,
          a.role_id,
          a.user_id,
          b.level_1_org_id,
          b.level_2_org_id,
          b.level_3_org_id,
          b.level_4_org_id
      from org_role_data b
      left join all_manager a on a.org_id = b.org_id and b.role_code = a.role_id
      union all
      select b.org_id,
          b.role_code,
          a.active_status,
          a.role_id,
          a.user_id,
          b.level_1_org_id,
          b.level_2_org_id,
          b.level_3_org_id,
          b.level_4_org_id
      from (
      		select org_id,
    				role_code,
    				level_1_org_id,
    		    level_2_org_id,
    		    level_3_org_id,
    		    level_4_org_id
    		  from
    			  (select 0 as org_id,
    			  			 null level_1_org_id,
    			      null level_2_org_id,
    			      null level_3_org_id,
    			      null level_4_org_id) a, app_role
    	) b left join (select * from all_manager where org_id = 0) a on a.org_id = b.org_id and b.role_code = a.role_id
    ),
    role_count_data as (
    	select org_id,
    		max(directly_count) directly_count,
    		max(directly_active_count) directly_active_count,
    		max(directly_no_active_count) directly_no_active_count,
    		max(children_count) children_count,
    		max(children_active_count) children_active_count,
    		max(children_no_active_count) children_no_active_count,
    		case
    			when org_id = 0 then max(children_area_count)
    			when org_id != 0 then max(children_area_count) + 1
    			end as children_area_count,
    		case
    			when org_id = 0 or (org_id != 0 and max(directly_active_count) = 0) then max(children_area_active_count)
    			when org_id != 0 and max(directly_active_count) > 0 then max(children_area_active_count) + 1
    			end as children_area_active_count,
    		case
    			when org_id = 0 or (org_id != 0 and max(directly_active_count) > 0) then max(children_area_no_active_count)
    			when org_id != 0 and max(directly_active_count) = 0 then max(children_area_no_active_count) + 1
    			end as children_area_no_active_count
    	from (
    		-- 直属
    		select org_id,
    			count(user_id) directly_count,
    			count(if(active_status = 1, user_id, null)) directly_active_count,
    			count(if(active_status = 0, user_id, null))  directly_no_active_count,
    			0 children_count,
    			0 children_active_count,
    			0 children_no_active_count,
    			0 children_area_count,
    			0 children_area_active_count,
    			0 children_area_no_active_count
    		from all_level_data
                where role_code =0
    		group by org_id
    		union all

    		-- 一级下属
    		select level_1_org_id as org_id,
    			0 directly_count,
    			0 directly_active_count,
    			0 directly_no_active_count,
    			count(user_id) children_count,
    			count(if(active_status = 1, user_id, null)) children_active_count,
    			count(if(active_status = 0, user_id, null)) children_no_active_count,
    			count(distinct org_id) children_area_count,
    			count(distinct if(active_status = 1, org_id, null)) children_area_active_count,
    			count(distinct if(active_status = 0 or user_id is null, org_id, null)) children_area_no_active_count
    		from all_level_data where level_1_org_id is not null
    		and role_code =0
    		group by level_1_org_id
    	) t
--     	    INNER JOIN  nation_province_data npd
--     	on t.org_id=npd.real_province_id
    	group by org_id
    ),
    all_data as (
      select
        org_id,
        directly_count,
        directly_active_count,
        directly_no_active_count,
        children_count,
        children_active_count,
        children_no_active_count,
        if(directly_count = 0, 0, directly_active_count/directly_count)  as direct_activate_ratio,
        if(children_active_count = 0, 0, children_active_count/children_count) as children_active_ratio,
        children_area_count,
        children_area_active_count,
        (children_area_count - children_area_active_count) children_area_no_active_count,
        nvl(children_area_active_count/children_area_count, 0) area_active_ratio,
        if(directly_active_count>0, 1, 0) area_active_status
      from role_count_data
    )
    ,area_active_data AS (
        select npd.province_id
             , ROUND(if(sum(ad.children_area_active_count) / sum(ad.children_area_count) > 1, 1,
                        sum(ad.children_area_active_count) / sum(ad.children_area_count)) * 2, 6) AS area_activation_score
        from all_data ad inner join nation_province_data npd
        on ad.org_id=npd.real_province_id
        group by npd.province_id
    )
    --学校激活
    ,school_tmp as (
        select a.school_id,
               b.s_section,
               a.active_status,
               a.level_1_org_id,
               a.level_2_org_id,
               a.level_3_org_id,
               a.level_4_org_id,
               a.active_time
        from nddc.dwd__edu_admin__school_d a LATERAL VIEW explode(split(regexp_replace(school_section, '(\\[|\\]|\\"| \\")', ''), ',')) b AS s_section
        where dt = '${biz_date}'
          and a.level_1_org_id is not null
          and b.s_section != '$ORG'
          and a.school_name not like '%其他%'
    )
    -- 一级组织
    ,first_stat as (
        select  level_1_org_id  as                                                    province_id,
               'all'                       as                                                    school_section,
               count(distinct if(level_2_org_id is null, school_id, null))                       directly_count,
               count(distinct if(level_2_org_id is null and active_status = 1 , school_id, null)) directly_active_count,
               count(distinct
                     if(level_2_org_id is null and active_status = 0, school_id, null))          directly_no_active_count,
               count(distinct if(level_2_org_id is not null, school_id, null))                   children_count,
               count(distinct
                     if(level_2_org_id is not null and active_status = 1 , school_id, null))      children_active_count,
               count(distinct
                     if(level_2_org_id is not null and active_status = 0, school_id, null))      children_no_active_count
        from school_tmp
        group by level_1_org_id
    )
    ,school_active_data AS (
        SELECT npd.province_id
             , IF((SUM(directly_active_count) + SUM(children_active_count)) /
                  (SUM(directly_count) + SUM(children_count)) > 1, 1,
                  (SUM(directly_active_count) + SUM(children_active_count)) /
                  (SUM(directly_count) + SUM(children_count))
                   ) * 3 as school_activation_score
        FROM first_stat fs
        inner join nation_province_data npd
        on fs.province_id=npd.real_province_id
        GROUP BY npd.province_id
    )
    --教师认证
    ,verify_teacher as (
        select npd.province_id
             , COUNT(DISTINCT dttcvif.account_id) verify_teacher_count
        from nddc.dwd__md__teacher_verify__d__full dttcvif
        INNER JOIN nation_province_data  npd
        ON npd.real_province_id=dttcvif.user_province_id
        where dttcvif.dt = '${biz_date}'
          and dttcvif.verify_status in ('1', '2') -- 认证+认证中
          and dttcvif.school_section not in
              ('$UNIVERSITY', '$OTHERS_EDU', '$SECONDARY_VOCATION', '$HIGHER_VOCATION', '$ORG',
               '-2')                      --高等教育、其他教育类、中职、高职、机构、未知
        group by npd.province_id
    )
    ,verify_teacher_data AS (
        SELECT vt.province_id
             , ROUND(
                    if((vt.verify_teacher_count / uc.teacher_num) > 1, 1, vt.verify_teacher_count / uc.teacher_num) * 3,
                    6) as teacher_verify_score
        FROM verify_teacher vt
                 JOIN user_cardinality uc
                      ON vt.province_id = uc.province_id
    )
    --区域管理员活跃情况
    ,manager_login as (
        select account_id,
               create_time,
               event_time
        from nddc.dwd__uc__manager_active_d
        where dt <= date_add(last_day('${biz_date}'), 1)
    )
    ,all_manager2 as (
        SELECT user_id,
               org_id,
               nvl(role_code, 0)                      role_id,
               create_time,
               if(delete_timestamp = 0, 0, 1) as      delete_status,
               if(delete_timestamp = 0, null,
                  date_format(FROM_UTC_TIMESTAMP(cast(delete_timestamp as bigint) * 1000, 'GMT+8'),
                              'yyyy-MM-dd HH:mm:ss')) delete_time
        FROM nddc.ods__edu_admin_manage_api__t_area_manager_full
        where dt = '${biz_date}'
    )
    ,org_data2 as (
    select
      org_id,
      node_name as org_name,
      level_1_org_id province_id,
      level_2_org_id city_id,
      level_3_org_id area_id,
--       level_1_org_name province_name,
--       level_2_org_name city_name,
--       level_3_org_name area_name,
      parent_id
    from nddc.dim__organization where dt = '${biz_date}' and node_type = 'NT_DISTRICT'
    )
    ,app_role2 as (
        select distinct role_code
        from nddc.ods__e_area_api__t_area_app_role_full
        where dt = '${biz_date}'
          and delete_timestamp = 0
          and app_id = 'e5649925-441d-4a53-b525-51a2f1c4e0a8'
        union all
        select '0' role_code
    )
    ,org_role_data2 as (
        select org_id,
               org_name,
               if(parent_id = 0, org_id, province_id)           province_id,
--                if(parent_id = 0, org_name, province_name)       province_name,
               if(parent_id = province_id, org_id, city_id)     city_id,
--                if(parent_id = province_id, org_name, city_name) city_name,
               if(parent_id = city_id, org_id, area_id)         area_id,
--                if(parent_id = city_id, org_name, area_name)     area_name,
               role_code as                                     role_id
        from org_data2
                 join app_role2
    )
    ,area_manager as (
        select a.user_id,
               a.org_id,
               b.role_id,
               a.create_time,
               a.delete_status,
               a.delete_time,
               b.province_id,
--                b.province_name,
               b.city_id,
--                b.city_name,
               b.area_id,
--                b.area_name,
               c.event_time
        from org_role_data2 b
                 left join all_manager2 a on a.org_id = b.org_id and a.role_id = b.role_id
                 left join manager_login c on a.user_id = c.account_id
    )
    ,dws_d as (
        select province_id,CEILING(avg(t.month_uv)) avg_month_uv
        from (
                          select province_id,
                                 date_format(event_time, 'yyyy-MM') m,
                                 count(distinct
                                       if(create_time <= event_time
                                              and (delete_status = 0 or event_time < delete_time)
                                              and area_id is null, city_id, null))
                                     + count(distinct
                                             if(create_time <= event_time
                                                    and (delete_status = 0 or event_time < delete_time), area_id, null))
                                     + max(
                                         if(create_time <= event_time
                                                and (delete_status = 0 or event_time < delete_time)
                                                and area_id is null
                                                and city_id is null, 1, 0))
                                     as                             month_uv
                          from area_manager
                          where province_id is not null
                            and date_format(event_time, 'yyyy-MM') >= '2022-08'
                          group by province_id, date_format(event_time, 'yyyy-MM')
                      ) t
        group by province_id
    )
    ,area_manager_data AS (
        select npd.province_id
        ,round(if((sum(dd.avg_month_uv)/sum(ad.children_area_count))>1,1,(sum(dd.avg_month_uv)/sum(ad.children_area_count))) * 2,6) area_manager_active_score
        from nation_province_data npd
        inner join dws_d dd on npd.real_province_id=dd.province_id
        inner join all_data ad on npd.real_province_id=ad.org_id
        group by npd.province_id
    )
-- ====================== 资源应用 ======================
-- 省级pv/uv数据：ads__platform_area_stat__d
-- 省级频道pv/uv数据：ads__platform_tag_stat__d
-- 资源评价数据：dws__ri__area_assessment_stat__dd__full
-- 资源收藏数据：dws__ri__area_favorite_stat__dd__full
-- 资源分享数据：dws__ri__area_share_stat__da__full_v2
-- 资源点赞数据：dws__ri__area_like_stat__dd__full_v2

    --区域浏览情况-广度（pv）  注册用户页面浏览情况（PV）-活跃度
    --   2024-05-18 调整增加*（该地区注册师生数/该地区学生教师基数）
   ,area_pv AS (
            SELECT IF(province_id = '594033008597', '594033008595', province_id) AS province_id
                 ,  SUM(pv) AS pv
            FROM nddc.ads__platform_area_stat__d
            WHERE bd = '${biz_date}'
              and site_type='zxx'
              AND ptc = 99
              AND end_date = '${biz_date}'
              AND identity = 'all'
              AND app_type ='all'
              AND province_id IN('594033008575','594033008571','594033008589','594033008597','594033008595','594033008543','594033008591','594033008585','594033008593')
       and city_id='all'
       and language='all'
   GROUP BY IF(province_id = '594033008597', '594033008595', province_id)
   )
    ,area_pv_data_tmp AS (
        SELECT rd.province_id
             , ap.pv / rd.all_user_cnts * rd.tea_stu_register_score     as all_data
             , ap.pv / rd.tea_stu_user_cnts * rd.tea_stu_register_score as tea_stu_data
        FROM area_pv ap
                 JOIN registe_data_score rd ON ap.province_id = rd.province_id
    )
    ,area_pv_data as (
        SELECT province_id
             , ROUND((tea_stu_data / m_tea_stu_data) * 3, 6) AS area_pv_score
             , ROUND((all_data / m_all_data) * 3, 6)         AS register_pv_score
        FROM (
              SELECT
              province_id
              ,all_data
              ,tea_stu_data
              ,max(all_data) OVER() m_all_data
              ,max(tea_stu_data) OVER() m_tea_stu_data
             from area_pv_data_tmp
                 ) a

    )
    --注册用户浏览资源数量情况
    --   2024-05-18 调整增加*（该地区注册师生数/该地区学生教师基数）
    ,resours_pv AS (
        select azc.province_id,
               SUM(azc.pv) pv
        from (

                 SELECT IF(province_id = '594033008597', '594033008595', province_id) AS province_id
                      , module_code                                                   AS channel_code
                      , module_name                                                   AS channel_name
                      , SUM(pv) AS pv
                 FROM nddc.ads__platform_tag_stat__d
                 WHERE bd = '${biz_date}'
                   and site_type='zxx'
                   AND ptc = 99
                   AND end_date = '${biz_date}'
                   AND identity = 'all'
                   AND app_type ='all'
                   and tag_code_1 ='all'
                   AND province_id in ('594033008575','594033008571','594033008589','594033008597','594033008595','594033008543','594033008591','594033008585','594033008593')
            and city_id='all'
        GROUP BY IF(province_id = '594033008597', '594033008595', province_id), module_code, module_name
             ) azc
                 inner join nddc.dim__visit_channel_group dvcg on dvcg.platform_code = 'zxx'
            and azc.channel_code = dvcg.channel_code
        WHERE dvcg.group_code = 'resource'
        group by azc.province_id
    )
    ,resours_pv_data_tmp AS (
        SELECT rd.province_id
             , rp.pv / rd.all_user_cnts  * rd.tea_stu_register_score as all_data
        FROM resours_pv rp
                 JOIN registe_data_score rd ON rp.province_id = rd.province_id
    )
    ,resours_pv_data AS (
        SELECT province_id
             , ROUND((all_data / m_all_data) * 2, 6) AS resource_pv_score
        FROM (
             SELECT
                 province_id
             ,all_data
             ,max(all_data) OVER () as m_all_data
            from resours_pv_data_tmp
                 ) a
    )
    --注册用户资源评价情况
    --   2024-05-18 调整增加*（该地区注册师生数/该地区学生教师基数）
   , ri_data_tmp AS (
    SELECT rdt.province_id
         , rdt.ri_count / rd.all_user_cnts  * rd.tea_stu_register_score AS ri_rate
    FROM (
             SELECT npd.province_id
                  , SUM(nvl(assessment_total_count,0)) + sum(nvl(favorite_total_count,0)) + sum(nvl(share_total_count,0)) +
                    sum(nvl(like_total_like_count,0)) ri_count
             FROM nation_province_data npd
                      LEFT JOIN (SELECT province_id, assessment_total_count
                                  FROM nddc.dws__ri__area_assessment_stat__dd__full t
                                  where dt = '${biz_date}'
                                    and city_id = 0
                                    and x_product_code = 'zxx'
                                    and content_channel_code = 'ALL') assessment
                                 ON npd.real_province_id = assessment.province_id
                      LEFT JOIN (SELECT province_id, favorite_total_count
                                  FROM nddc.dws__ri__area_favorite_stat__dd__full t
                                  where dt = '${biz_date}'
                                    and t.city_id = 0
                                    and x_product_code = 'zxx'
                                    and content_channel_code = 'ALL') favorite
                                 ON npd.real_province_id = favorite.province_id
                      LEFT JOIN (SELECT province_id, share_total_count
                                  FROM nddc.dws__ri__area_share_stat__da__full_v2 t
                                  where dt = '${biz_date}'
                                    and t.city_id = 0
                                    and x_product_code = 'zxx'
                                    and share_object_type = 'resource'
                                    and share_object_internal_type = 'ALL'
                                    AND t.period_type_code = 99) share ON npd.real_province_id = share.province_id
                      LEFT JOIN (select province_id, sum(like_total_like_count) as like_total_like_count
                                  from nddc.dws__ri__area_like_stat__dd__full_v2
                                  where dt = '${biz_date}'
                                    and city_id = 0
                                    AND x_product_code = 'zxx'
                                  group by province_id) like_data on npd.real_province_id = like_data.province_id
             GROUP BY npd.province_id
         ) rdt
             INNER JOIN registe_data_score rd on rdt.province_id = rd.province_id
)
    ,ri_data AS (
        SELECT rdt2.province_id
             , ROUND((rdt2.ri_rate / rdt2.m_ri_rate) * 2, 6) resource_assessment_score
        FROM (select province_id
        ,ri_rate
        ,max(ri_rate) OVER () as m_ri_rate
        from ri_data_tmp) rdt2

    )
-- ====================== 群组互动 ======================
-- 群组数据：dwd__sc__group_info__d__full_v2
-- 群组活动发布数据：dwd__tala__group_activity__d__full
-- 群组活动提交数据：dwd__tala__user_activity_submit__d__full
-- 群组活动触达数据：dwd__tala__user_activity_read__d__full
-- 群组数据（师生群+家校群）
    --班均群组情况
    ,group_data_count as (
        select t2.province_id,
               count(*) as group_count
        from nddc.dwd__sc__group_info__d__full_v2 t
                 inner join nation_province_data t2 on t.group_province_id = t2.real_province_id
        where t.dt = '${biz_date}'
          and t.group_type in (8, 9)
          and t.group_deleted = 0
          and t.x_product_code='zxx'
        group by t2.province_id
    )
    ,group_data_tmp as (
    select gdc.province_id, gdc.group_count / ac.class_num as group_rate
    from group_data_count gdc
             join (select npd.province_id, SUM(dacc.class_num) class_num
                   from nddc.dim__area_class_cardinality dacc
                            INNER JOIN nation_province_data npd
                                       ON dacc.org_id = npd.real_province_id
                   where dacc.data_year = 2021
                   GROUP BY npd.province_id
    ) ac
                  on gdc.province_id = ac.province_id
    )
    ,group_data as (
        select gdt.province_id
             , ROUND(gdt.group_rate / gdt.m_group_rate * 4, 6) AS class_group_score
        from (select province_id
        ,group_rate
        , max(group_rate) OVER () as m_group_rate
        from group_data_tmp) gdt
    )
    --群组发布活动数
    ,publish_activity_user AS (
        SELECT activity_id, activity_original_id, activity_created_by, activity_type, group_type, group_province_id
        FROM nddc.dwd__tala__group_activity__d__full
        WHERE dt = '${biz_date}'
          and activity_publish_date <= '${biz_date}'
          AND activity_deleted = 0
          AND activity_original_id <> '-1'
        AND x_product_code='zxx'
        group by activity_id, activity_original_id, activity_created_by, activity_type, group_type, group_province_id
    )
    ,publish_activity_user_cnt AS (
        SELECT npd.province_id, count(distinct pau.activity_created_by) as publish_user_cnt
        FROM publish_activity_user pau
                 INNER JOIN nation_province_data npd
                            ON pau.group_province_id = npd.real_province_id
        WHERE pau.group_type IN ('8', '9', '11') --师生群、家校群、教研群
        GROUP BY npd.province_id
    )
    ,publish_activity_data_tmp AS (
        SELECT pauc.province_id, (pauc.publish_user_cnt / rd.all_user_cnts) as publish_user_rate
        FROM publish_activity_user_cnt pauc
                 inner join registe_data rd
                            on pauc.province_id = rd.province_id
    )
    ,publish_activity_data AS (
        SELECT padt.province_id
             , ROUND((padt.publish_user_rate / padt.m_publish_user_rate) * 2, 6) as activity_publish_score
        FROM (SELECT province_id
                   ,publish_user_rate
        ,max(publish_user_rate) OVER () as m_publish_user_rate
            FROM publish_activity_data_tmp) padt
    )
    --注册用户参与活动情况
    ,participant_activity_user AS (
        SELECT npd.province_id, COUNT(DISTINCT pa.user_id) participant_user_cnt
        FROM (
                 SELECT user_id, activity_id, activity_original_id, activity_type
                 FROM nddc.dwd__tala__user_activity_submit__d__full
                 WHERE dt = '${biz_date}'
                   and event_date <= '${biz_date}'
                   and activity_deleted = 0
                   and activity_original_id <> '-1'
                   AND x_product_code='zxx'
                 GROUP BY user_id, activity_id, activity_original_id, activity_type
                 UNION ALL
                 SELECT user_id, activity_id, activity_original_id, activity_type
                 FROM nddc.dwd__tala__user_activity_read__d__full
                 WHERE dt = '${biz_date}'
                   and event_date <= '${biz_date}'
                   and activity_deleted = 0
                   and activity_original_id <> '-1'
                   AND x_product_code='zxx'
                 GROUP BY user_id, activity_id, activity_original_id, activity_type
             ) pa
                 INNER JOIN publish_activity_user pau
                            ON pa.activity_id = pau.activity_id AND pau.activity_type = pa.activity_type
                 inner join nation_province_data npd
                            ON pau.group_province_id = npd.real_province_id
        WHERE pau.group_type IN ('8', '9', '11') --师生群、家校群、教研群
        GROUP BY npd.province_id
    )
    ,participant_activity_data_tmp AS (
        SELECT pau.province_id, (pau.participant_user_cnt / rd.all_user_cnts) participant_user_rate
        FROM participant_activity_user pau
                 JOIN registe_data rd
                      ON pau.province_id = rd.province_id
    )
    ,participant_activity_data AS (
        SELECT padt.province_id
             , ROUND((padt.participant_user_rate / padt.m_participant_user_rate) * 4, 6) AS user_participate_score
        FROM (SELECT province_id
        ,participant_user_rate
        ,max(participant_user_rate) OVER () as m_participant_user_rate
        FROM participant_activity_data_tmp) padt
    )
-- ====================== 专项活动 ======================
-- 教师培训数据：dws__tt__area_stat__dd__full

    ,special_activity_tmp as (
        select npd.province_id
             , sum(if(training_id = 'bb042e69-9a11-49a1-af22-0c3fab2e92b9', sa.finish_study_num,
                      0)) summer_22_finish_study_num
             , sum(if(training_id = 'bdbe4c1e-f540-4e9f-9fae-855ab44e2d32', sa.finish_study_num,
                      0)) winter_23_finish_study_num
             , sum(if(training_id = '71a83441-6d45-4644-80f0-00efa40df164', sa.finish_study_num,
                      0)) summer_23_finish_study_num
        from (
                 select train_id           as training_id,
                        province_id,
                        finish_study_count as finish_study_num
                        -- *
                 from nddc.dws__tt__area_stat__dd__full a
                 where a.dt = '${biz_date}'
                   and city_id = 0
                   and grade_section = 'all'
                   and a.subject_code = 'all'
                   and a.head_teacher = 'all'
                   and a.mental_health_teacher = 'all'
                   and a.user_biz_type = 'all'
                   and a.user_type = 'all'
                   and a.include_unverified = 1
                   and a.train_id in ('bdbe4c1e-f540-4e9f-9fae-855ab44e2d32', 'bb042e69-9a11-49a1-af22-0c3fab2e92b9',
                                      '71a83441-6d45-4644-80f0-00efa40df164')
             ) sa
                 inner join nation_province_data npd
                            on sa.province_id = npd.real_province_id
        group by npd.province_id
    )
    ,special_activity_data AS (
        SELECT sat.province_id
             , ROUND(if((sat.winter_23_finish_study_num / uc.teacher_num) > 1, 1,
                        (sat.winter_23_finish_study_num / uc.teacher_num)) * 3.33,
                     6)                                                               as winter_special_activity_2023_score
             , ROUND(if((sat.summer_22_finish_study_num / uc.teacher_num) > 1, 1,
                        (sat.summer_22_finish_study_num / uc.teacher_num)) * 3.33,
                     6)                                                               as summer_special_activity_2022_score
             , ROUND(if((sat.summer_23_finish_study_num / uc.teacher_num) > 1, 1,
                        (sat.summer_23_finish_study_num / uc.teacher_num)) * 3.33,
                     6)                                                               as summer_special_activity_2023_score
        FROM special_activity_tmp sat
                 JOIN user_cardinality uc
                      ON sat.province_id = uc.province_id
    )

-- ====================== 工具应用 ======================
-- 活动发布数据：dwd__tala__group_activity__d__full
-- 活动参与数据：dwd__tala__user_activity_read__d__full（触达数据，触达只算一次参与）
-- 活动参与数据：dwd__tala__user_activity_submit__d__full（提交数据，提交可以多次参与）
-- 授课参考：dws__talr__teaching_stat__full
-- 备课参考：dws__talr__prepare_lesson_stat__full
-- 触控（白板）数据：ads__zxx__white_plate_event_area_stat__d
-- 群组数据：dwd__sc__group_info__d__full_v2

-- 教师应用
--   2024-05-18 调整增加*（该地区注册师生数/该地区学生教师基数）
    ,teacher_app_score_data as (
        select t4.province_id,
               round(t4.activity_publish_count / t5.group_count * rd.tea_stu_register_score, 6) as teacher_app_rate
        from (
                 select tmp.province_id,
                        sum(tmp.activity_publish_count) as activity_publish_count
                 from (
                          -- 教师发布活动数
                          select t1.province_id,
                                 count(distinct t3.activity_id) as activity_publish_count
                          from nation_province_data t1
                                   inner join nddc.dwd__md__person_account__d__full t2
                                              on t2.user_province_id = t1.real_province_id
                                   inner join nddc.dwd__tala__group_activity__d__full t3
                                              on t3.activity_created_by = t2.account_id
                          where t2.dt = '${biz_date}'
                            and t2.is_teacher = 1
                            and t3.dt = '${biz_date}'
                            and t3.activity_deleted = 0
                            AND t3.x_product_code='zxx'
                            and t3.activity_deleted = 0
                            and t3.activity_original_id <> '-1'
                            and t2.is_teacher = 1
                          group by t1.province_id

                                   -- 授课数据
                          union all
                          select t1.province_id,
                                 count(*) as activity_publish_count
                          from nation_province_data t1
                                   inner join nddc.dws__talr__teaching_stat__full t2
                                              on t1.real_province_id = t2.province_id
                          WHERE t2.identity='TEACHER'
                                and t2.dt = '${biz_date}'
                          group by t1.province_id

                                   -- 备课数据
                          union all
                          select t1.province_id,
                                 count(*) as activity_publish_count
                          from nation_province_data t1
                                   inner join nddc.dws__talr__prepare_lesson_stat__full t2
                                              on t1.real_province_id = t2.province_id
                          where t2.identity='TEACHER'
                            and t2.dt = '${biz_date}'
                          group by t1.province_id
                                   -- 触控（白板）数据
                          union all
                          select t1.province_id, sum(t.click_num) as activity_publish_count
                          from nation_province_data t1
                               inner join nddc.ads__zxx__white_plate_event_area_stat__d t
                          on t1.real_province_id=t.province_id
                          where t.dt = '${biz_date}'
                            and t.period_type_code = 99
                            and t.channel_code = 'all'
                            and t.subject_code = 'all'
                            and t.hour_code = 'all'
                            and t.weeks_code = 'all'
                            and t.area_type = 'province'
                     group by t1.province_id
                      ) tmp
                 group by tmp.province_id
             ) t4
                 inner join group_data_count t5 on t5.province_id = t4.province_id
                 INNER JOIN registe_data_score rd on t4.province_id = rd.province_id
    )
    ,teacher_app_score AS (
        SELECT tasd.province_id
             , ROUND((tasd.teacher_app_rate / tasd.m_teacher_app_rate) * 5, 6) teacher_app_score
        FROM (select province_id
        ,teacher_app_rate
        ,max(teacher_app_rate) OVER () as m_teacher_app_rate
        from teacher_app_score_data) tasd

    )

-- 学生应用
--   2024-05-18 调整增加*（该地区注册师生数/该地区学生教师基数）
   , student_app_score_data as (
        select t4.province_id,
               round(t4.participate_count / t5.group_count * rd.tea_stu_register_score, 6) as student_app_rate
        from (
                 select tmp.province_id,
                        sum(tmp.participate_count) as participate_count
                 from (
                          select coalesce(sbt.province_id, rd.province_id)             as province_id,
                                 coalesce(sbt.participate_count, rd.participate_count) as participate_count
                          from (
                                   -- 提交数据
                                   select t3.province_id,
                                          t1.user_id,
                                          t1.activity_id,
                                          count(DISTINCT t1.event_id, t1.activity_id) as participate_count
                                   from nation_province_data t3
                                            inner join nddc.dwd__tala__group_activity__d__full t2
                                                       on t2.group_province_id = t3.real_province_id
                                            inner join nddc.dwd__tala__user_activity_submit__d__full t1
                                                       on t1.activity_id = t2.activity_id and t1.activity_type = t2.activity_type
                                   where t1.dt = '${biz_date}'
                                     and t2.dt = '${biz_date}'
                                     and t1.user_is_student = 1
                                     AND t2.x_product_code='zxx'
                                     AND t1.x_product_code='zxx'
                                     and t1.event_date <= '${biz_date}'
                                     and t1.activity_deleted = 0
                                     and t1.activity_original_id <> '-1'
                                   and t1.user_is_student = 1
                                   group by t3.province_id, t1.user_id, t1.activity_id
                               ) sbt
                                   full outer join(
                              -- 触达数据
                              select t3.province_id,
                                     t1.user_id,
                                     t1.activity_id,
                                     1 as participate_count
                              from nation_province_data t3
                                       inner join nddc.dwd__tala__group_activity__d__full t2
                                                  on t2.group_province_id = t3.real_province_id
                                       inner join nddc.dwd__tala__user_activity_read__d__full t1
                                                  on t1.activity_id = t2.activity_id and t1.activity_type = t2.activity_type
                              where t1.dt = '${biz_date}'
                                and t2.dt = '${biz_date}'
                                and t1.user_is_student = 1
                                AND t2.x_product_code='zxx'
                                AND t1.x_product_code='zxx'
                                and t1.event_date <= '${biz_date}'
                                and t1.activity_deleted = 0
                                and t1.activity_original_id <> '-1'
                              and t1.user_is_student = 1
                              group by t3.province_id, t1.user_id, t1.activity_id
                          ) rd on sbt.province_id = rd.province_id and sbt.user_id = rd.user_id and
                                  sbt.activity_id = rd.activity_id
                      ) tmp
                 group by tmp.province_id
             ) t4
                 inner join group_data_count t5 on t4.province_id = t5.province_id
                 inner join registe_data_score rd on t4.province_id = rd.province_id
    )
,student_app_score AS (
        SELECT sasd.province_id
             , ROUND((sasd.student_app_rate / sasd.m_student_app_rate) * 5, 6) student_app_score
        FROM (select province_id
        ,student_app_rate
        ,max(student_app_rate) OVER () as m_student_app_rate
        from student_app_score_data) sasd
    )
INSERT OVERWRITE  TABLE dwt__regin_screen__radar__d PARTITION (dt,type)
SELECT t.province_id,
       t.teacher_register_score,
       t.student_register_score,
       t.guardian_register_score,
       NULL              AS area_activation_score,
       NULL              AS school_activation_score,
       NULL              AS teacher_verify_score,
       NULL              AS area_manager_active_score,
       NULL              AS area_pv_score,
       NULL              AS register_pv_score,
       NULL              AS resource_pv_score,
       NULL              AS resource_assessment_score,
       NULL              AS class_group_score,
       NULL              AS user_participate_score,
       NULL              AS activity_publish_score,
       NULL              AS summer_special_activity_2022_score,
       NULL              AS summer_special_activity_2023_score,
       NULL              AS winter_special_activity_2023_score,
       NULL              AS teacher_app_score,
       NULL              AS student_app_score,
       CURRENT_TIMESTAMP AS stat_time,
       '${biz_date}'     AS dt,
       'registe_data_score'    AS type
FROM registe_data_score t
UNION ALL
SELECT t.province_id,
       NULL              AS teacher_register_score,
       NULL              AS student_register_score,
       NULL              AS guardian_register_score,
       t.area_activation_score,
       NULL              AS school_activation_score,
       NULL              AS teacher_verify_score,
       NULL              AS area_manager_active_score,
       NULL              AS area_pv_score,
       NULL              AS register_pv_score,
       NULL              AS resource_pv_score,
       NULL              AS resource_assessment_score,
       NULL              AS class_group_score,
       NULL              AS user_participate_score,
       NULL              AS activity_publish_score,
       NULL              AS summer_special_activity_2022_score,
       NULL              AS summer_special_activity_2023_score,
       NULL              AS winter_special_activity_2023_score,
       NULL              AS teacher_app_score,
       NULL              AS student_app_score,
       CURRENT_TIMESTAMP AS stat_time,
       '${biz_date}'     AS dt,
       'area_active_data'     AS type
FROM area_active_data t
UNION ALL
SELECT t.province_id,
       NULL              AS teacher_register_score,
       NULL              AS student_register_score,
       NULL              AS guardian_register_score,
       NULL              AS area_activation_score,
       t.school_activation_score,
       NULL              AS teacher_verify_score,
       NULL              AS area_manager_active_score,
       NULL              AS area_pv_score,
       NULL              AS register_pv_score,
       NULL              AS resource_pv_score,
       NULL              AS resource_assessment_score,
       NULL              AS class_group_score,
       NULL              AS user_participate_score,
       NULL              AS activity_publish_score,
       NULL              AS summer_special_activity_2022_score,
       NULL              AS summer_special_activity_2023_score,
       NULL              AS winter_special_activity_2023_score,
       NULL              AS teacher_app_score,
       NULL              AS student_app_score,
       CURRENT_TIMESTAMP AS stat_time,
       '${biz_date}'     AS dt,
       'school_active_data'   AS type
FROM school_active_data t
UNION ALL
SELECT t.province_id,
       NULL              AS teacher_register_score,
       NULL              AS student_register_score,
       NULL              AS guardian_register_score,
       NULL              AS area_activation_score,
       NULL              AS school_activation_score,
       t.teacher_verify_score,
       NULL              AS area_manager_active_score,
       NULL              AS area_pv_score,
       NULL              AS register_pv_score,
       NULL              AS resource_pv_score,
       NULL              AS resource_assessment_score,
       NULL              AS class_group_score,
       NULL              AS user_participate_score,
       NULL              AS activity_publish_score,
       NULL              AS summer_special_activity_2022_score,
       NULL              AS summer_special_activity_2023_score,
       NULL              AS winter_special_activity_2023_score,
       NULL              AS teacher_app_score,
       NULL              AS student_app_score,
       CURRENT_TIMESTAMP AS stat_time,
       '${biz_date}'     AS dt,
       'verify_teacher_data'  AS type
FROM verify_teacher_data t
UNION ALL
SELECT t.province_id,
       NULL              AS teacher_register_score,
       NULL              AS student_register_score,
       NULL              AS guardian_register_score,
       NULL              AS area_activation_score,
       NULL              AS school_activation_score,
       NULL              AS teacher_verify_score,
       t.area_manager_active_score,
       NULL              AS area_pv_score,
       NULL              AS register_pv_score,
       NULL              AS resource_pv_score,
       NULL              AS resource_assessment_score,
       NULL              AS class_group_score,
       NULL              AS user_participate_score,
       NULL              AS activity_publish_score,
       NULL              AS summer_special_activity_2022_score,
       NULL              AS summer_special_activity_2023_score,
       NULL              AS winter_special_activity_2023_score,
       NULL              AS teacher_app_score,
       NULL              AS student_app_score,
       CURRENT_TIMESTAMP AS stat_time,
       '${biz_date}'     AS dt,
       'area_manager_data'    AS type
FROM area_manager_data t
UNION ALL
SELECT t.province_id,
       NULL              AS teacher_register_score,
       NULL              AS student_register_score,
       NULL              AS guardian_register_score,
       NULL              AS area_activation_score,
       NULL              AS school_activation_score,
       NULL              AS teacher_verify_score,
       NULL              AS area_manager_active_score,
       t.area_pv_score,
       t.register_pv_score,
       NULL              AS resource_pv_score,
       NULL              AS resource_assessment_score,
       NULL              AS class_group_score,
       NULL              AS user_participate_score,
       NULL              AS activity_publish_score,
       NULL              AS summer_special_activity_2022_score,
       NULL              AS summer_special_activity_2023_score,
       NULL              AS winter_special_activity_2023_score,
       NULL              AS teacher_app_score,
       NULL              AS student_app_score,
       CURRENT_TIMESTAMP AS stat_time,
       '${biz_date}'     AS dt,
       'area_pv_data'         AS type
FROM area_pv_data t
UNION ALL
SELECT t.province_id,
       NULL              AS teacher_register_score,
       NULL              AS student_register_score,
       NULL              AS guardian_register_score,
       NULL              AS area_activation_score,
       NULL              AS school_activation_score,
       NULL              AS teacher_verify_score,
       NULL              AS area_manager_active_score,
       NULL              AS area_pv_score,
       NULL              AS register_pv_score,
       t.resource_pv_score,
       NULL              AS resource_assessment_score,
       NULL              AS class_group_score,
       NULL              AS user_participate_score,
       NULL              AS activity_publish_score,
       NULL              AS summer_special_activity_2022_score,
       NULL              AS summer_special_activity_2023_score,
       NULL              AS winter_special_activity_2023_score,
       NULL              AS teacher_app_score,
       NULL              AS student_app_score,
       CURRENT_TIMESTAMP AS stat_time,
       '${biz_date}'     AS dt,
       'resours_pv_data'      AS type
FROM resours_pv_data t
UNION ALL
SELECT t.province_id,
       NULL              AS teacher_register_score,
       NULL              AS student_register_score,
       NULL              AS guardian_register_score,
       NULL              AS area_activation_score,
       NULL              AS school_activation_score,
       NULL              AS teacher_verify_score,
       NULL              AS area_manager_active_score,
       NULL              AS area_pv_score,
       NULL              AS register_pv_score,
       NULL              AS resource_pv_score,
       t.resource_assessment_score,
       NULL              AS class_group_score,
       NULL              AS user_participate_score,
       NULL              AS activity_publish_score,
       NULL              AS summer_special_activity_2022_score,
       NULL              AS summer_special_activity_2023_score,
       NULL              AS winter_special_activity_2023_score,
       NULL              AS teacher_app_score,
       NULL              AS student_app_score,
       CURRENT_TIMESTAMP AS stat_time,
       '${biz_date}'     AS dt,
       'ri_data'         AS type
FROM ri_data t
-- UNION ALL
-- SELECT t.province_id,
--        NULL              AS teacher_register_score,
--        NULL              AS student_register_score,
--        NULL              AS guardian_register_score,
--        NULL              AS area_activation_score,
--        NULL              AS school_activation_score,
--        NULL              AS teacher_verify_score,
--        NULL              AS area_manager_active_score,
--        NULL              AS area_pv_score,
--        NULL              AS register_pv_score,
--        NULL              AS resource_pv_score,
--        NULL              AS resource_assessment_score,
--        t.class_group_score,
--        NULL              AS user_participate_score,
--        NULL              AS activity_publish_score,
--        NULL              AS summer_special_activity_2022_score,
--        NULL              AS summer_special_activity_2023_score,
--        NULL              AS winter_special_activity_2023_score,
--        NULL              AS teacher_app_score,
--        NULL              AS student_app_score,
--        CURRENT_TIMESTAMP AS stat_time,
--        '${biz_date}'     AS dt,
--        'group_data'         AS type
-- FROM group_data t
-- UNION ALL
-- SELECT t.province_id,
--        NULL              AS teacher_register_score,
--        NULL              AS student_register_score,
--        NULL              AS guardian_register_score,
--        NULL              AS area_activation_score,
--        NULL              AS school_activation_score,
--        NULL              AS teacher_verify_score,
--        NULL              AS area_manager_active_score,
--        NULL              AS area_pv_score,
--        NULL              AS register_pv_score,
--        NULL              AS resource_pv_score,
--        NULL              AS resource_assessment_score,
--        NULL              AS class_group_score,
--        NULL              AS user_participate_score,
--        t.activity_publish_score,
--        NULL              AS summer_special_activity_2022_score,
--        NULL              AS summer_special_activity_2023_score,
--        NULL              AS winter_special_activity_2023_score,
--        NULL              AS teacher_app_score,
--        NULL              AS student_app_score,
--        CURRENT_TIMESTAMP AS stat_time,
--        '${biz_date}'     AS dt,
--        'publish_activity_data'         AS type
-- FROM publish_activity_data t
-- UNION ALL
-- SELECT t.province_id,
--        NULL              AS teacher_register_score,
--        NULL              AS student_register_score,
--        NULL              AS guardian_register_score,
--        NULL              AS area_activation_score,
--        NULL              AS school_activation_score,
--        NULL              AS teacher_verify_score,
--        NULL              AS area_manager_active_score,
--        NULL              AS area_pv_score,
--        NULL              AS register_pv_score,
--        NULL              AS resource_pv_score,
--        NULL              AS resource_assessment_score,
--        NULL              AS class_group_score,
--        t.user_participate_score,
--        NULL              AS activity_publish_score,
--        NULL              AS summer_special_activity_2022_score,
--        NULL              AS summer_special_activity_2023_score,
--        NULL              AS winter_special_activity_2023_score,
--        NULL              AS teacher_app_score,
--        NULL              AS student_app_score,
--        CURRENT_TIMESTAMP AS stat_time,
--        '${biz_date}'     AS dt,
--        'participant_activity_data'         AS type
-- FROM participant_activity_data t
-- UNION ALL
-- SELECT t.province_id,
--        NULL              AS teacher_register_score,
--        NULL              AS student_register_score,
--        NULL              AS guardian_register_score,
--        NULL              AS area_activation_score,
--        NULL              AS school_activation_score,
--        NULL              AS teacher_verify_score,
--        NULL              AS area_manager_active_score,
--        NULL              AS area_pv_score,
--        NULL              AS register_pv_score,
--        NULL              AS resource_pv_score,
--        NULL              AS resource_assessment_score,
--        NULL              AS class_group_score,
--        NULL              AS user_participate_score,
--        NULL              AS activity_publish_score,
--        t.summer_special_activity_2022_score,
--        t.summer_special_activity_2023_score,
--        t.winter_special_activity_2023_score,
--        NULL              AS teacher_app_score,
--        NULL              AS student_app_score,
--        CURRENT_TIMESTAMP AS stat_time,
--        '${biz_date}'     AS dt,
--        'special_activity_data'         AS type
-- FROM special_activity_data t
-- UNION ALL
-- SELECT t.province_id,
--        NULL              AS teacher_register_score,
--        NULL              AS student_register_score,
--        NULL              AS guardian_register_score,
--        NULL              AS area_activation_score,
--        NULL              AS school_activation_score,
--        NULL              AS teacher_verify_score,
--        NULL              AS area_manager_active_score,
--        NULL              AS area_pv_score,
--        NULL              AS register_pv_score,
--        NULL              AS resource_pv_score,
--        NULL              AS resource_assessment_score,
--        NULL              AS class_group_score,
--        NULL              AS user_participate_score,
--        NULL              AS activity_publish_score,
--        NULL              AS summer_special_activity_2022_score,
--        NULL              AS summer_special_activity_2023_score,
--        NULL              AS winter_special_activity_2023_score,
--        t.teacher_app_score,
--        NULL              AS student_app_score,
--        CURRENT_TIMESTAMP AS stat_time,
--        '${biz_date}'     AS dt,
--        'teacher_app_score'         AS type
-- FROM teacher_app_score t
-- UNION ALL
-- SELECT t.province_id,
--        NULL              AS teacher_register_score,
--        NULL              AS student_register_score,
--        NULL              AS guardian_register_score,
--        NULL              AS area_activation_score,
--        NULL              AS school_activation_score,
--        NULL              AS teacher_verify_score,
--        NULL              AS area_manager_active_score,
--        NULL              AS area_pv_score,
--        NULL              AS register_pv_score,
--        NULL              AS resource_pv_score,
--        NULL              AS resource_assessment_score,
--        NULL              AS class_group_score,
--        NULL              AS user_participate_score,
--        NULL              AS activity_publish_score,
--        NULL              AS summer_special_activity_2022_score,
--        NULL              AS summer_special_activity_2023_score,
--        NULL              AS winter_special_activity_2023_score,
--        NULL              AS teacher_app_score,
--        t.student_app_score,
--        CURRENT_TIMESTAMP AS stat_time,
--        '${biz_date}'     AS dt,
--        'student_app_score'         AS type
-- FROM student_app_score t
