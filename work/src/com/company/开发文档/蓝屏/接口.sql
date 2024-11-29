-- 蓝屏-国家智慧教育平台运行数据实况
-- 页面浏览-上周新增[screen/v1/pvuv_week]
-- SELECT sum(pv) as pv,SUM(uv) as uv
-- from ads__platform_area_stat__d
-- WHERE period_type_code = 10
-- and end_date BETWEEN date_sub(curdate(), interval weekday(curdate()) + 7 day) and date_sub(curdate(), interval weekday(curdate()) + 1 day)
-- <if test="site_type !='all' and site_type !='' and site_type != null" >
-- and site_type = #{site_type}
-- </if>
-- and app_type ='all'
-- and identity='all'
-- and country='all'
-- and language='all'
-- SELECT SUM(pv) AS pv, SUM(uv) AS uv
-- FROM (
--          SELECT end_date,
--                 IF(end_date = DATE_SUB(curdate(), INTERVAL weekday(curdate()) + 8 DAY), -pv, pv) AS pv
--                  ,
--                 IF(end_date = DATE_SUB(curdate(), INTERVAL weekday(curdate()) + 8 DAY), -uv, pv) AS uv
--          FROM ads__platform_area_stat__d
--          WHERE period_type_code = 99
--            AND end_date IN (DATE_SUB(curdate(), INTERVAL weekday(curdate()) + 8 DAY) AND
--                             DATE_SUB(curdate(), INTERVAL weekday(curdate()) + 1 DAY))
--             <if test="site_type !='all' and site_type !='' and site_type != null" >
--             and site_type = #{site_type}
--             </if>
--            AND app_type = 'all'
--            AND identity = 'all'
--            AND country = 'all'
--            AND language = 'all'
--      ) a

--     pv&uv概览-v2
-- screen/v2/pvuv
select t.pv,t.uv,t.new_pv, t.new_uv, t.today_pv, t.today_pv - y.compare_yesterday_pv as compare_yesterday_pv,t.today_uv,t.today_uv-y.yesterday_uv as compare_yesterday_uv
,y.compare_yesterday_pv as yesterday_pv,y.yesterday_uv,ifnull(dh.today_to_last_hour_pv,0) as today_to_last_hour_pv
,ifnull(h.last_hour_pv,0) as last_hour_pv
,ifnull(h.last_hour_uv,0) as last_hour_uv
from (
                  SELECT SUM(pv)       AS pv,
                         SUM(uv)       AS uv,
                         SUM(new_pv)   AS new_pv,
                         SUM(new_uv)   AS new_uv,
                         SUM(new_pv)   AS today_pv,
                         SUM(today_uv) AS today_uv
                  FROM (
                           SELECT SUM(pv) AS pv, SUM(uv) AS uv, 0 AS new_pv, 0 AS new_uv, 0 AS today_uv
                           FROM ads__platform_area_stat__d
                           WHERE period_type_code = 99
                             AND end_date = DATE_SUB(curdate(), INTERVAL 1 DAY)
                      <if test="site_type !='all' and site_type !='' and site_type != null" >
                      and site_type = #{site_type}
                      </if>
                             AND app_type = 'all'
                             AND identity = 'all'
                             AND country = 'all'
                             AND language = 'all'
                           UNION ALL
                           SELECT SUM(visit_times)                                       AS pv,
                                  COUNT(DISTINCT device_id)                              AS uv,
                                  SUM(visit_times)                                       AS new_pv,
                                  COUNT(DISTINCT IF(is_new_device = 1, device_id, NULL)) AS new_uv,
                                  COUNT(DISTINCT device_id)                              AS today_uv
                           FROM dwm__pv__event_detail__id__incr
                           WHERE stat_date = curdate()
                      <if test="site_type !='all' and site_type !='' and site_type != null" >
                      and product_code = #{site_type}
                      </if>
                       ) a
              ) t
LEFT JOIN
    (
        SELECT SUM(pv) AS compare_yesterday_pv, SUM(uv) AS yesterday_uv
        FROM ads__platform_area_stat__d
        WHERE period_type_code = 10
          AND end_date = DATE_SUB(curdate(), INTERVAL 1 DAY)
                      <if test="site_type !='all' and site_type !='' and site_type != null" >
                      and site_type = #{site_type}
                      </if>
          AND app_type = 'all'
          AND identity = 'all'
          AND country = 'all'
        ) y
on 1=1
LEFT JOIN (
    SELECT SUM(visit_times)                                       AS today_to_last_hour_pv
    FROM dwm__pv__event_detail__ih__incr
    WHERE stat_date = curdate()
                      <if test="site_type !='all' and site_type !='' and site_type != null" >
                      and product_code = #{site_type}
                      </if>
      and event_hour != hour(now())
    ) dh
on 1=1
LEFT JOIN (
    SELECT SUM(visit_times)                                       AS last_hour_pv,
           COUNT(DISTINCT device_id)                              AS last_hour_uv
    FROM dwm__pv__event_detail__ih__incr
    WHERE stat_date = curdate()
                      <if test="site_type !='all' and site_type !='' and site_type != null" >
                      and product_code = #{site_type}
                      </if>
      and event_hour = hour(date_sub(now(),INTERVAL 1 hour))

    ) h
on 1=1;

--     screen/v2/home/province_per
SELECT v.province_id,
       p.province,
       v.pv       AS pv,
       v.uv       AS uv,
       v.tea_stu_pv as tea_stu_pv,
       v.tea_stu_uv as tea_stu_uv,
       p.base_num AS base_num
FROM (
         SELECT org_id                              AS province_id
              , org_name                            AS province
              , dauc.student_num + dauc.teacher_num AS base_num
              , dauc.student_num                    AS base_student_num
              , dauc.teacher_num                    AS base_teacher_num
         FROM dim_area_user_cardinality dauc
         WHERE org_id != 0
     ) p
         INNER JOIN
     (
         SELECT province_id
              , SUM(pv)         AS pv
              , SUM(uv)         AS uv
              , SUM(tea_stu_pv) AS tea_stu_pv
              , SUM(tea_stu_uv) AS tea_stu_uv
         FROM (
                  SELECT IF(province_id = '594033008597', '594033008595', province_id) AS province_id
                       , SUM(CASE WHEN identity = 'all' THEN uv ELSE 0 END)            AS uv
                       , SUM(CASE WHEN identity = 'all' THEN pv ELSE 0 END)            AS pv
                       , SUM(CASE WHEN identity != 'all' THEN pv ELSE 0 END)           AS tea_stu_pv
                       , SUM(CASE WHEN identity != 'all' THEN uv ELSE 0 END)           AS tea_stu_uv
                  FROM ads__platform_area_stat__d
                  WHERE period_type_code = 99
                    AND end_date = DATE_SUB(#{stat_date}, INTERVAL 1 DAY)
                    AND app_type = 'all'
                    AND identity IN ('all', 'STUDENT', 'TEACHER')
                    AND country = '中国'
                    AND language = 'all'
                    and city_id='all'
                  GROUP BY IF(province_id = '594033008597', '594033008595', province_id)
                  UNION ALL
                  SELECT IF(province_id = '594033008597', '594033008595', province_id)           AS province_id,
                         COUNT(DISTINCT device_id)                                               AS uv,
                         SUM(visit_times)                                                        AS pv,
                         SUM(IF(identity IN ('STUDENT', 'TEACHER'), visit_times, 0))             AS tea_stu_pv,
                         COUNT(DISTINCT IF(identity IN ('STUDENT', 'TEACHER'), device_id, NULL)) AS tea_stu_uv
                  FROM dwm__pv__event_detail__id__incr
                  WHERE stat_date = #{stat_date}
                  GROUP BY IF (province_id = '594033008597', '594033008595', province_id)
              ) t
         GROUP BY province_id
     ) v
     ON 1 = 1
         AND v.province_id = p.province_id
;
--     screen/v1/home/province_per
select b.*,a.base_num
FROM (
         SELECT org_id as province_id,student_num+teacher_num as base_num
         FROM dim_area_user_cardinality dauc
         WHERE org_id != 0
     ) a
         INNER JOIN
     (
         SELECT province_id
              ,province_name
              , SUM(pv)         AS pv
              , SUM(uv)         AS uv
         FROM (
                  SELECT IF(province_id = '594033008597', '594033008595', province_id) AS province_id
                       , IF(province_id = '594033008597', '新疆维吾尔自治区', province_name) AS province_name
                       , SUM(uv)            AS uv
                       , SUM(pv)            AS pv
                  FROM ads__platform_area_stat__d
                  WHERE period_type_code = 99
                    AND end_date = DATE_SUB(curdate(), INTERVAL 1 DAY)
                    AND app_type = 'all'
                    AND identity ='all'
                    AND country = '中国'
                    AND language = 'all'
                    and city_id='all'
                  GROUP BY IF(province_id = '594033008597', '594033008595', province_id),IF(province_id = '594033008597', '新疆维吾尔自治区', province_name)
                  UNION ALL
                  SELECT IF(province_id = '594033008597', '594033008595', province_id)           AS province_id,
           IF(province_id = '594033008597', '新疆维吾尔自治区', province_name) AS province_name,
                         COUNT(DISTINCT device_id)                                               AS uv,
                         SUM(visit_times)                                                        AS pv
                  FROM dwm__pv__event_detail__id__incr
                  WHERE stat_date = curdate()
                    and country_name='中国'
                  GROUP BY IF (province_id = '594033008597', '594033008595', province_id),IF(province_id = '594033008597', '新疆维吾尔自治区', province_name)
              ) t
         GROUP BY province_id,province_name
     ) b
     ON 1 = 1
         AND a.province_id = b.province_id
         order by b.province_id
;

--screen/v1/home/province  不对

SELECT province_id
     ,province_name
     , SUM(pv)         AS pv
     , SUM(uv)         AS uv
,sum(incr_pv) as incr_pv
       ,sum(incr_uv) as incr_uv
FROM (
         SELECT IF(province_id = '594033008597', '594033008595', province_id) AS province_id
              , IF(province_id = '594033008597', '新疆维吾尔自治区', province_name) AS province_name
              , SUM(uv)            AS uv
              , SUM(pv)            AS pv
         ,0 as incr_uv
              ,0 as incr_pv
         FROM ads__platform_area_stat__d
         WHERE period_type_code = 99
           AND end_date = DATE_SUB(curdate(), INTERVAL 1 DAY)
           AND app_type = 'all'
           AND identity ='all'
           AND country = '中国'
           AND language = 'all'
           and city_id='all'
         GROUP BY IF(province_id = '594033008597', '594033008595', province_id),IF(province_id = '594033008597', '新疆维吾尔自治区', province_name)
         UNION ALL
         SELECT IF(province_id = '594033008597', '594033008595', province_id)           AS province_id,
  IF(province_id = '594033008597', '新疆维吾尔自治区', province_name) AS province_name,
                  COUNT(DISTINCT device_id)           AS uv,
                  SUM(visit_times)                     AS pv,
                COUNT(DISTINCT device_id)                                               AS incr_uv,
                SUM(visit_times)                                                        AS incr_pv
         FROM dwm__pv__event_detail__id__incr
         WHERE stat_date = curdate()
         and country_name='中国'
         GROUP BY IF (province_id = '594033008597', '594033008595', province_id),IF(province_id = '594033008597', '新疆维吾尔自治区', province_name)
     ) t
GROUP BY province_id,province_name
;
-- v2/platform/visit/trend
SELECT IF(province_id = '594033008597', '594033008595', province_id) AS province_id
     , IF(province_id = '594033008597', '新疆维吾尔自治区', province_name) AS province_name
     , SUM(uv)            AS uv
     , SUM(pv)            AS pv
,0 as incr_uv
     ,0 as incr_pv
FROM ads__platform_area_stat__d
WHERE period_type_code = 10
  AND end_date  between #{period_start_date} and #{period_end_date}
  and t.site_type = #{site_type}
<if test="app_type=='' or app_type==null or app_type=='all'">
	and app_type = 'all'
</if>
<if test="app_type!='' and app_type!=null and app_type!='all'">
	and if(app_type='web','web-all') = #{app_type}
</if>
<if test="identity=='' or identity==null">
	and t.identity = 'all'
</if>
<if test="identity!='' and identity!=null">
	and t.identity = #{identity}
</if>
  AND country = '中国'
  AND language = 'all'
  and city_id='all'
GROUP BY IF(province_id = '594033008597', '594033008595', province_id),IF(province_id = '594033008597', '新疆维吾尔自治区', province_name)
;
--     screen/v2/smart/special

-- screen/v2/visit/hour
SELECT identity,
       event_hour,
       uv,
       pv
FROM dws__pv__event_hour_stat__dy__incr
WHERE product_code = 'zxx'
  AND identity != 'all'
  AND country_name = '全球'
  AND language = 'all'
  AND module_code = 'all'
UNION ALL
SELECT identity
     , CAST(event_hour AS INT)      event_hour
     , COUNT(DISTINCT device_id) AS uv
     , SUM(visit_times)          AS pv
FROM dwm__pv__event_detail__ih__incr
WHERE stat_date = curdate()
  AND product_code =#{site_type}
          event_hour, stat_date

CREATE TABLE `ads__zxx_app_analysis_operations_retention_d`
(
    `stat_time`        VARCHAR(50)   DEFAULT NULL COMMENT '统计时间：天(yyyy-MM-dd)',
    `fromDate`         DATE        NOT NULL COMMENT '统计周期开始日期：天(yyyy-MM-dd)',
    `toDate`           DATE        NOT NULL COMMENT '统计周期结束日期：天(yyyy-MM-dd)',
    `device_type`      VARCHAR(50) NOT NULL COMMENT '设备类型：1 新增设备,0 活跃设备',
    `system_type`      VARCHAR(50) NOT NULL COMMENT '系统类型：1 WEB端,0 移动端,2 PC端,3 HD端',
    `date_dim`         VARCHAR(50) NOT NULL COMMENT '日期维度：day,week,month',
    `retention_date`   DATE        NOT NULL COMMENT '留存日期(yyyy-MM-dd)',
    `retained_days`    VARCHAR(50) NOT NULL COMMENT '几天、几周、几月后留存编码,按日：1、2、3、4、5、6、7、14、30,按周：1、2、3、4、5、6、7、8',
    `retention_rate`   DECIMAL(6, 2) DEFAULT NULL COMMENT '留存率',
    `retention_number` BIGINT(10)    DEFAULT NULL COMMENT '留存数',
    `update_time`      TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`fromDate`, `toDate`, `device_type`, `system_type`, `date_dim`, `retention_date`, `retained_days`),
    KEY `device_type_index` (`device_type`),
    KEY `date_dim_index` (`date_dim`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ads-运营分析-留存分析';
select pv,
      channel_code,
    province_id,
row_number() over(PARTITION BY channel_code order by pv desc) as rk
from (
  select
 sum(pv) as pv,
      channel_code,
    province_id
from (
    SELECT
      sum(pv) as pv,
      if(module_code in ('syncClassroom','prepare_lesson','course','basicWork','exercises','experiment'),'syncClassroom',module_code) as channel_code,
    province_id
    FROM
      ads__platform_tag_stat__d
    where
      1 = 1
      and module_code in('sedu','sport','art','labourEdu','schoolService','teacherTraining','family','eduReform','tchMaterial','localChannel',
                         'syncClassroom','prepare_lesson','course','basicWork','exercises','experiment')
      and period_type_code = '50'
      and date_format(end_date,'%Y') = date_format(CURDATE(),'%Y')
      and app_type = 'all'
      and site_type = 'zxx'
      and identity = 'all'
      and tag_code_1 = 'all'
      and country = '中国'
      <if test="region == 'region_1' " >
  -- 试点地区1
      and province_id in (594033008575,594033008571,594033008589,594033008597,594033008595,594033008543,594033008591,594033008585,594033008593)
     </if>
      <if test="region == 'region_2' " >
  -- 试点地区2
      and province_id in (594033008575,594033008571,594033008589)
     </if>
      and city_id = 'all'
      GROUP by if(module_code in ('syncClassroom','prepare_lesson','course','basicWork','exercises','experiment'),'syncClassroom',module_code),province_id
      UNION ALL
     select
       sum(pv) as pv,
       if(module_code in ('syncClassroom','prepare_lesson','course','basicWork','exercises','experiment'),'syncClassroom',module_code) as channel_code,
       province_id
     from
       dws__pv__event_stat__dy__incr t
     where
       1 = 1
       and stat_year = date_format(CURDATE(),'%Y')
       and module_code in('sedu','sport','art','labourEdu','schoolService','teacherTraining','family','eduReform','tchMaterial','localChannel',
                         'syncClassroom','prepare_lesson','course','basicWork','exercises','experiment')
       <if test="region == 'region_1' " >
  -- 试点地区1
      and province_id in (594033008575,594033008571,594033008589,594033008597,594033008595,594033008543,594033008591,594033008585,594033008593)
     </if>
      <if test="region == 'region_2' " >
  -- 试点地区2
      and province_id in (594033008575,594033008571,594033008589)
     </if>
       and product_code = 'zxx'
       and country_name = '中国'
       GROUP by if(module_code in ('syncClassroom','prepare_lesson','course','basicWork','exercises','experiment'),'syncClassroom',module_code),province_id
       UNION ALL
       select
        sum(visit_times) as pv,
        if(module_code in ('syncClassroom','prepare_lesson','course','basicWork','exercises','experiment'),'syncClassroom',module_code) as channel_code,
         province_id
      from
        dwm__pv__event_detail__id__incr
      where
        1 = 1
        and stat_date = CURDATE()
        and module_code in('sedu','sport','art','labourEdu','schoolService','teacherTraining','family','eduReform','tchMaterial','localChannel',
                   'syncClassroom','prepare_lesson','course','basicWork','exercises','experiment')
       <if test="region == 'region_1' " >
   -- 试点地区1
       and province_id in (594033008575,594033008571,594033008589,594033008597,594033008595,594033008543,594033008591,594033008585,594033008593)
      </if>
       <if test="region == 'region_2' " >
   -- 试点地区2
       and province_id in (594033008575,594033008571,594033008589)
       </if>
        and product_code = 'zxx'
        and country_name = '中国'
        GROUP by if(module_code in ('syncClassroom','prepare_lesson','course','basicWork','exercises','experiment'),'syncClassroom',module_code),province_id
  ) t1 GROUP by channel_code,province_id
  ) t2
;
select os,if(get_json_object(platform, '$.ios')='true' ,'iOS',get_json_object(platform, '$.name') )platform
,get_json_object(platform, '$.name') as platform2
,CASE when get_json_object(platform, '$.name') is null then os
when get_json_object(platform, '$.name') ='Android' and get_json_object(os, '$.name')  is null and os != 'Android' then os
 when get_json_object(platform, '$.ios')='true' THEN 'iOS'
     else get_json_object(platform, '$.name') end as os
,count(1) from nddc.ods__event_data_detail_v2 t
where dt = '${biz_date}' and event_type = 'pageEvent'
group by os,if(get_json_object(platform, '$.ios')='true' ,'iOS',get_json_object(platform, '$.name') )
,CASE when get_json_object(platform, '$.name') is null then os
when get_json_object(platform, '$.name') ='Android' and get_json_object(os, '$.name')  is null and os != 'Android' then os
 when get_json_object(platform, '$.ios')='true' THEN 'iOS'
     else get_json_object(platform, '$.name') end
     ,get_json_object(platform, '$.name')







