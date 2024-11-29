-- 全局参数：biz_date=$[yyyy-MM-dd-1]
--  任务流名称：区域看板&学校看板-应用分析
--  ads__region_app_activity_area__overview_stat_d
--  ###################################################################################################
--  表说明与统计周期： ADS-区域看板-应用分析-区域-活动概览分析
--  统计说明：维度：周期、地区（省级、市级、区县级）、学段
--  ###################################################################################################
--  依赖：dwd__md__class__d__full
--          dwd__md__school__d__full
--          dwd__md__whole_organization__d__full
--  ###################################################################################################
--  版本信息：版本注释，描述修改内容：
--  ###################################################################################################
--  版本号：v1.0
--  修改日期：2024-08-22
--  修改内容：新建模板
--  修改人员：10017103
--  ###############################################
--  版本号：
--  修改日期：
--  修改内容：
--  修改人员：
--  ###################################################################################################
-- 获取班级对应学校所挂靠的区域组织节点明细， -1 为直属学校
WITH activity_data AS (
    SELECT period_code
         , period_type_code
         , period_start_date
         , period_end_date
         , period_type_text
         , parent_id
         , region_id
         , region_name
         , province_id
         , province_name
         , city_id
         , city_name
         , county_id
         , county_name
         , area_type
         , activity_type
         , activity_type_name
         , section_type_code
         , section_type_name
         , SUM(publish_count) AS publish_count
         , stat_date
    FROM dws__tala__area_activity_publish_stat__da__full
    WHERE pc IN ('10', '21', '22', '30', '31', '50', '61', '62', '99')
      AND activity_type IN ('homework', 'schedule', 'afterclass', 'habit', 'vote', 'score', 'assessment')
      AND area_tag = ('NORMAL')
      AND school_id = 0
      AND NVL(area_type, '') <> 'school'
      AND section_type_code IN ('$ON020000', 'OTHER', '$ON030000', '$ON040000', 'ALL')
      AND class_type_code = 'ALL'
      AND activity_internal_type = 'ALL'
      AND subject_code = 'ALL'
      -- 补数的时候去掉这个条件
      AND stat_date = '${biz_date}'
    GROUP BY period_code
           , period_type_code
           , period_start_date
           , period_end_date
           , period_type_text
           , parent_id
           , region_id
           , region_name
           , province_id
           , province_name
           , city_id
           , city_name
           , county_id
           , county_name
           , area_type
           , area_tag
           , activity_type
           , activity_type_name
           , section_type_code
           , section_type_name
           , stat_date
)
   , school_stat AS (
    SELECT t2.period_code
         , t2.period_start_date
         , t2.period_end_date
         , t2.period_type_code
         , t2.period_type_text
         , t2.section_type_code
         , t2.section_type_name
         , t2.activity_type
         , t2.activity_type_name
         , t1.*
    FROM (
             SELECT CASE
                        WHEN city_id IS NULL AND county_id IS NULL THEN 0
                        WHEN province_id IS NOT NULL AND county_id IS NULL THEN province_id
                        WHEN city_id IS NOT NULL THEN city_id
                 END                                               AS parent_id
                  , CASE
                        WHEN province_id IS NULL AND city_id IS NULL AND county_id IS NULL THEN 0
                        WHEN province_id IS NOT NULL AND city_id IS NULL AND county_id IS NULL THEN province_id
                        WHEN province_id IS NOT NULL AND city_id IS NOT NULL AND county_id IS NULL THEN city_id
                        WHEN province_id IS NOT NULL AND city_id IS NOT NULL AND county_id IS NOT NULL
                            THEN county_id END                     AS region_id
                  , NVL(province_id, 0)                            AS province_id
                  , NVL(province_name, '全国')                       AS province_name
                  , NVL(city_id, 0)                                AS city_id
                  , NVL(city_name, '全省')                           AS city_name
                  , NVL(county_id, 0)                              AS area_id
                  , NVL(county_name, '全市')                         AS area_name
                  , CASE
                        WHEN province_id IS NULL THEN 'all'
                        WHEN province_id IS NOT NULL AND city_id IS NULL THEN 'province'
                        WHEN city_id IS NOT NULL AND county_id IS NULL THEN 'city'
                        WHEN county_id IS NOT NULL THEN 'area' END AS area_type
                  , COUNT(DISTINCT school_id)                      AS school_num
             FROM (SELECT * FROM nddc.dim__school WHERE dt = '${full_biz_date}') sc
             GROUP BY province_id, province_name, city_id, city_name, county_id, county_name
                 GROUPING SETS (
                 ( province_id, province_name, city_id, city_name, county_id, county_name),
                 ( province_id, province_name, city_id, city_name),
                 ( province_id, province_name),
                 ()
                 )
         ) t1
             JOIN (
        SELECT period_code,
               period_start_date,
               period_type_code,
               period_end_date,
               period_type_text,
               section_type_code,
               section_type_name,
               activity_type,
               activity_type_name
        FROM activity_data
        GROUP BY period_code, period_start_date, period_end_date, period_type_code, period_type_text, section_type_code,
                 section_type_name,
                 activity_type, activity_type_name
    ) t2
)
   , school_avg_stat AS (
    SELECT a.period_code
         , a.period_start_date
         , a.period_end_date
         , a.period_type_code
         , a.period_type_text
         , a.parent_id
         , a.region_id
         , a.province_id
         , a.province_name
         , a.city_id
         , a.city_name
         , a.area_id
         , a.area_name
         , a.area_type
         , a.activity_type                        AS activity_type
         , a.activity_type_name                   AS activity_type_name
         , a.section_type_code                    AS section_type_code
         , a.section_type_name                    AS section_type_name
         , NVL(b.publish_count, 0)                AS publish_count
         , NVL(b.publish_count, 0) / a.school_num AS school_publish_avg
    FROM school_stat a
             LEFT JOIN activity_data b
                       ON a.province_id = b.province_id
                           AND a.city_id = b.city_id
                           AND a.area_id = b.county_id
                           AND a.period_code = b.period_code
                           AND a.period_end_date = b.period_end_date
                           AND a.section_type_code = b.section_type_code
                           AND a.activity_type = b.activity_type
)
   , rank_stat AS (
    SELECT period_code
         , period_start_date
         , period_end_date
         , period_type_code
         , period_type_text
         , parent_id
         , region_id
         , province_id
         , province_name
         , city_id
         , city_name
         , area_id
         , area_name
         , area_type
         , activity_type
         , activity_type_name
         , section_type_code
         , section_type_name
         , publish_count
         , ROW_NUMBER() OVER (PARTITION BY period_code,period_end_date,parent_id,activity_type,section_type_code ORDER BY publish_count DESC )      AS publish_num_rank
         , school_publish_avg
         , ROW_NUMBER() OVER (PARTITION BY period_code,period_end_date,parent_id,activity_type,section_type_code ORDER BY school_publish_avg DESC ) AS school_publish_avg_rank
    FROM school_avg_stat
    WHERE region_id > 0
)
INSERT OVERWRITE TABLE ads__region_app_class_area_stat_d PARTITION(dt='${biz_date}')
SELECT FROM_UTC_TIMESTAMP(CURRENT_TIMESTAMP(), 'yyyy-MM-dd HH:mm:ss') AS stat_time,
       '${biz_date}'                                                  AS stat_date,
       prac.period_start_date,
       '${biz_date}'                                                  AS period_end_date,
       prac.period_type_code,
       prac.period_type_text,
       prac.parent_id,
       prac.region_id,
       prac.province_id,
       prac.province_name,
       prac.city_id,
       prac.city_name,
       prac.area_id,
       prac.area_name,
       prac.area_type,
       uo.is_leaf                         AS is_leaf,
       prac.section_type_code,
       prac.section_type_name,
       prac.class_num,
       prac.regular_class_num,
       prac.administrative_class_num,
       prac.regular_class_cover_school_num,
       prac.administrative_class_cover_school_num,
       CONCAT(class_rank,'/',MAX(class_rank) OVER (PARTITION BY period_type_code,parent_id,section_type_code)) AS class_rank,
       administrative_class_rank,
       null as administrative_class_cover_rate,
       null as administrative_class_cover_rate_rank,
       CONCAT(class_rank,'/',MAX(class_rank) OVER (PARTITION BY period_type_code,parent_id,section_type_code)) AS regular_class_rank,
       CONCAT(administrative_class_cover_school_rank,'/',MAX(administrative_class_cover_school_rank) OVER (PARTITION BY period_type_code,parent_id,section_type_code)) AS administrative_class_cover_school_rank,
       administrative_class_cover_school_rate,
       CONCAT(administrative_class_cover_school_rate_rank,'/',MAX(administrative_class_cover_school_rate_rank) OVER (PARTITION BY period_type_code,parent_id,section_type_code)) AS administrative_class_cover_school_rate_rank,
       CONCAT(regular_class_cover_school_rank,'/',MAX(regular_class_cover_school_rank) OVER (PARTITION BY period_type_code,parent_id,section_type_code)) AS regular_class_cover_school_rank,
       regular_class_cover_school_rate,
       CONCAT(regular_class_cover_school_rate_rank,'/',MAX(regular_class_cover_school_rate_rank) OVER (PARTITION BY period_type_code,parent_id,section_type_code)) AS regular_class_cover_school_rate_rank
FROM rank_stat prac
         LEFT JOIN (select DISTINCT org_id ,is_leaf from nddc.dwd__md__whole_organization__d__full where dt = '${full_biz_date}') uo
                   ON prac.region_id = uo.org_id
UNION ALL
SELECT FROM_UTC_TIMESTAMP(CURRENT_TIMESTAMP(), 'yyyy-MM-dd HH:mm:ss') AS stat_time,
       '${biz_date}'                                                  AS stat_date,
       period_start_date,
       '${biz_date}'                                                  AS period_end_date,
       period_type_code,
       period_type_text,
       parent_id,
       region_id,
       province_id,
       province_name,
       city_id,
       city_name,
       area_id,
       area_name,
       area_type,
       0                         AS is_leaf,
       section_type_code,
       section_type_name,
       class_num,
       regular_class_num,
       administrative_class_num,
       regular_class_cover_school_num,
       administrative_class_cover_school_num,
       NULL AS class_rank,
     NULL AS   administrative_class_rank,
     NULL AS   administrative_class_cover_rate,
     NULL AS   administrative_class_cover_rate_rank,
       NULL AS regular_class_rank,
       NULL AS administrative_class_cover_school_rank,
       administrative_class_cover_school_rate,
       NULL AS administrative_class_cover_school_rate_rank,
       NULL AS regular_class_cover_school_rank,
       regular_class_cover_school_rate,
       NULL AS regular_class_cover_school_rate_rank
FROM rank_stat  WHERE region_id <=0