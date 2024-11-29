-- 全局参数：biz_date=$[yyyy-MM-dd-1]
--  任务流名称：区域看板&学校看板-应用分析
--  ads__region_app_class_area_stat_d
--  ###################################################################################################
--  表说明与统计周期： ads-区域数据统计-应用分析-省市区-班级分析
--  统计说明：维度：日期、地区（省级、市级、区县级、校级）、班级类型（普通班级、行政班）
--  ###################################################################################################
--  依赖：dwd__md__class__d__full
--          dwd__md__school__d__full
--          dwd__md__whole_organization__d__full
--  ###################################################################################################
--  版本信息：版本注释，描述修改内容：
--  ###################################################################################################
--  版本号：v1.0
--  修改日期：2023-07-26
--  修改内容：新建模板
--  修改人员：10017103
--  ###############################################
--  版本号：
--  修改日期：
--  修改内容：
--  修改人员：
--  ###################################################################################################
-- 获取班级对应学校所挂靠的区域组织节点明细， -1 为直属学校
WITH dim_date_period_tmp AS (
    -- 获取周期维度数据
    SELECT t.day_code,
           t.period_type_code,
           DATE_FORMAT(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(t.start_date AS STRING), 'yyyyMMdd'), 'yyyy-MM-dd'),
                       'yyyy-MM-dd') AS start_date,
           t.end_date,
           CASE
               WHEN t.period_type_code = 10 THEN '昨日'
               WHEN t.period_type_code = 21 THEN '过去7日'
               WHEN t.period_type_code = 22 THEN '过去14日'
               WHEN t.period_type_code = 31 THEN '过去30日'
               END                   AS period_type_text
    FROM nddc.dim_date_period t
    WHERE t.period_type_code IN (10, 21, 22, 31)
      AND t.end_date = '${short_biz_date}'
),
     tmp_region_app_class_school_info AS (
         SELECT COALESCE(t2.level_1_org_id, -1) AS                                                  province_id,
                COALESCE(t2.level_2_org_id, -1) AS                                                  city_id,
                COALESCE(t2.level_3_org_id, -1) AS                                                  area_id,
                t1.school_id                    AS                                                  school_id,
                t2.node_name                    AS                                                  school_name,
                t1.grade_section,
                CASE
                    WHEN t1.grade_section IN ('$ON020000', '$PRIMARY', '$ON050000') THEN '$ON020000'
                    WHEN t1.grade_section IN ('$ON030000', '$ON060000', '$MIDDLE') THEN '$ON030000'
                    WHEN t1.grade_section IN ('$ON040000', '$HIGH') THEN '$ON040000'
                    ELSE 'OTHER' END            AS                                                  section_code,
                t1.class_id,
                t1.class_name,
                t1.class_type
                 ,
                FROM_UNIXTIME(UNIX_TIMESTAMP(t1.created_time, 'yyyy-MM-dd HH:mm:ss'), 'yyyy-MM-dd') create_date
                 ,
                t2.is_leaf
         FROM (SELECT a.*
               FROM nddc.dwd__md__class__d__full a
                        INNER JOIN (SELECT *
                                    FROM nddc.dwd__md__school__d__full
                                    WHERE dt = '${full_biz_date}'
                                      AND archive_status = 0) b
                                   ON a.school_id = b.school_id
               WHERE a.dt = '${full_biz_date}'
                 AND a.delete_timestamp = 0
                 AND a.archive_status = 0
                 AND a.class_type IN ('CLASS', 'NETWORK_CLASS')
                 AND FROM_UNIXTIME(UNIX_TIMESTAMP(a.created_time, 'yyyy-MM-dd HH:mm:ss'), 'yyyy-MM-dd') <= '${biz_date}'
              ) t1
                  LEFT JOIN nddc.dwd__md__whole_organization__d__full t2
                            ON t1.school_id = t2.org_id AND t2.dt = '${full_biz_date}'
         WHERE (t2.level_1_org_id IS NOT NULL OR t2.level_2_org_id IS NOT NULL OR t2.level_3_org_id IS NOT NULL)
     ),
     tmp_period_data AS (
         SELECT ddpt.start_date AS period_start_date
              , ddpt.period_type_code
              , ddpt.period_type_text
              , tracsi.*
         FROM tmp_region_app_class_school_info tracsi
                  INNER JOIN dim_date_period_tmp ddpt ON DATE_FORMAT(tracsi.create_date, 'yyyyMMdd') = ddpt.day_code
         WHERE tracsi.create_date >= DATE_SUB(TO_DATE('${biz_date}'), 29)
         UNION ALL
         SELECT '2022-03-01' AS period_start_date
              , 99           AS period_type_code
              , '至今'         AS period_type_text
              , *
         FROM tmp_region_app_class_school_info
         WHERE create_date <= '${biz_date}'
     )
        ,
-- 获取省市区-班级统计值-分组处理
     tmp_region_app_class_all_area_stat_01 AS (
         SELECT period_start_date,
                period_type_code,
                period_type_text,
                COALESCE(province_id, 0)                                                  AS province_id,
                COALESCE(city_id, 0)                                                      AS city_id,
                COALESCE(area_id, 0)                                                      AS area_id,
                COALESCE(section_code, 'ALL')                                             AS section_code,
                -- total_class_region_rank  --累计班级个数-区域排名
                COUNT(DISTINCT class_id)                                                  AS class_num,                            --班级个数
                COUNT(DISTINCT CASE WHEN class_type = 'NETWORK_CLASS' THEN class_id END)  AS regular_class_num,                    --普通班个数
                COUNT(DISTINCT CASE WHEN class_type = 'CLASS' THEN class_id END)          AS administrative_class_num,             --行政班个数
                COUNT(DISTINCT CASE WHEN class_type = 'NETWORK_CLASS' THEN school_id END) AS regular_class_cover_school_num,--普通班覆盖学校数
                COUNT(DISTINCT CASE WHEN class_type = 'CLASS' THEN school_id END)         AS administrative_class_cover_school_num --行政班覆盖学校数
         FROM tmp_period_data
         WHERE COALESCE(province_id, '0') NOT IN ('594035816785', '594036056566')--去除央馆省和阳光学校
         GROUP BY period_start_date, period_type_code, period_type_text, province_id, city_id, area_id, section_code
             GROUPING SETS (
             ( period_start_date, period_type_code, period_type_text),
             ( period_start_date, period_type_code, period_type_text, province_id),
             ( period_start_date, period_type_code, period_type_text, province_id, city_id),
             ( period_start_date, period_type_code, period_type_text, province_id, city_id, area_id),
             ( period_start_date, period_type_code, period_type_text, section_code),
             ( period_start_date, period_type_code, period_type_text, province_id, section_code),
             ( period_start_date, period_type_code, period_type_text, province_id, city_id, section_code),
             ( period_start_date, period_type_code, period_type_text, province_id, city_id, area_id, section_code)
             )
     ),
-- 获取省市区县名称
     tmp_region_app_class_all_area_stat AS (
         SELECT period_start_date,
                period_type_code,
                period_type_text,
                province_id,
                CASE
                    WHEN t1.province_id = -1 THEN '直属学校'
                    WHEN t1.province_id = 0 THEN '全国'
                    ELSE t2.node_name END                                                                 AS province_name,
                city_id,
                CASE WHEN t1.city_id = -1 THEN '直属学校' WHEN t1.city_id = 0 THEN '全省' ELSE t3.node_name END AS city_name,
                area_id,
                CASE WHEN t1.area_id = -1 THEN '直属学校' WHEN t1.area_id = 0 THEN '全市' ELSE t4.node_name END AS area_name,
                section_code                                                                              AS section_type_code,
                CASE
                    WHEN t1.section_code = '$ON020000' THEN '小学'
                    WHEN t1.section_code = '$ON030000' THEN '初中'
                    WHEN t1.section_code = '$ON040000' THEN '高中'
                    WHEN t1.section_code = 'ALL' THEN '全部'
                    ELSE '其他' END                                                                         AS section_type_name,
                class_num,
                regular_class_num,
                administrative_class_num,
                regular_class_cover_school_num,
                administrative_class_cover_school_num
         FROM tmp_region_app_class_all_area_stat_01 t1
                  LEFT JOIN nddc.dwd__md__whole_organization__d__full t2
                            ON t1.province_id = t2.org_id AND t2.dt = '${full_biz_date}'
                  LEFT JOIN nddc.dwd__md__whole_organization__d__full t3
                            ON t1.city_id = t3.org_id AND t3.dt = '${full_biz_date}'
                  LEFT JOIN nddc.dwd__md__whole_organization__d__full t4
                            ON t1.area_id = t4.org_id AND t4.dt = '${full_biz_date}'
     ),
-- 对结果增加父级id和聚合地域id
     tmp_parent_region_app_class AS (
         SELECT period_start_date,
                period_type_code,
                period_type_text,
                CASE
                    WHEN city_id = 0 AND area_id = 0 THEN 0
                    WHEN province_id != 0 AND area_id = 0 THEN province_id
                    WHEN city_id != 0 THEN city_id
                    END                                                                      AS parent_id,
                CASE
                    WHEN province_id = 0 AND city_id = 0 AND area_id = 0 THEN 0
                    WHEN province_id != 0 AND city_id = 0 AND area_id = 0 THEN province_id
                    WHEN province_id != 0 AND city_id != 0 AND area_id = 0 THEN city_id
                    WHEN province_id != 0 AND city_id != 0 AND area_id != 0 THEN area_id END AS region_id,
                province_id,
                province_name,
                city_id,
                city_name,
                area_id,
                area_name,
                CASE
                    WHEN province_id = 0 THEN 'all'
                    WHEN province_id != 0 AND city_id = 0 THEN 'province'
                    WHEN city_id != 0 AND area_id = 0 THEN 'city'
                    WHEN area_id != 0 THEN 'area' END                                        AS area_type,
--                 CASE WHEN province_id=0 THEN 0
--                     ELSE  cast(t2.is_leaf as int)
--                     AS is_leaf,
                section_type_code,
                section_type_name,
                class_num,
                regular_class_num,
                administrative_class_num,
                regular_class_cover_school_num,
                administrative_class_cover_school_num
         FROM tmp_region_app_class_all_area_stat t
     )
     -- 2024-08-20 新增内容
        ,
     school_stat AS (
         SELECT t2.period_start_date, t2.period_type_code, t2.period_type_text, t2.section_type_code, t2.section_type_name, t1.*
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
                  JOIN (SELECT period_start_date, period_type_code, period_type_text, section_type_code, section_type_name
                        FROM tmp_region_app_class_all_area_stat
                        GROUP BY period_start_date, period_type_code, period_type_text, section_type_code, section_type_name) t2
     )
        ,
     school_cover_stat AS (
         SELECT a.period_start_date
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
              , a.section_type_code                                            AS section_type_code
              , a.section_type_name                                            AS section_type_name
              , NVL(b.class_num, 0)                                            AS class_num
              , NVL(b.regular_class_num, 0)                                    AS regular_class_num
              , NVL(b.administrative_class_num, 0)                             AS administrative_class_num
              , NVL(b.regular_class_cover_school_num, 0)                       AS regular_class_cover_school_num
              , NVL(b.administrative_class_cover_school_num, 0)                AS administrative_class_cover_school_num
              , NVL(b.administrative_class_cover_school_num, 0) / a.school_num AS administrative_class_cover_school_rate
              , NVL(b.regular_class_cover_school_num, 0) / a.school_num        AS regular_class_cover_school_rate
         FROM school_stat a
                  LEFT JOIN tmp_parent_region_app_class b
                            ON a.province_id = b.province_id
                                AND a.city_id = b.city_id
                                AND a.area_id = b.area_id
                                AND a.period_type_code = b.period_type_code
                                AND a.section_type_code = b.section_type_code
     )
        ,
     class_area_rank AS (
         SELECT period_start_date
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
              , section_type_code
              , section_type_name
              , class_num
              , regular_class_num
              , administrative_class_num
              , regular_class_cover_school_num
              , administrative_class_cover_school_num
              , administrative_class_cover_school_rate
              , regular_class_cover_school_rate
              , ROW_NUMBER() OVER (PARTITION BY period_type_code,parent_id,section_type_code ORDER BY class_num DESC )                             AS class_rank
              , ROW_NUMBER() OVER (PARTITION BY period_type_code,parent_id,section_type_code ORDER BY regular_class_num DESC)                      AS regular_class_rank
              , ROW_NUMBER() OVER (PARTITION BY period_type_code,parent_id,section_type_code ORDER BY administrative_class_num DESC)               AS administrative_class_rank
              , ROW_NUMBER() OVER (PARTITION BY period_type_code,parent_id,section_type_code ORDER BY regular_class_cover_school_num DESC)         AS regular_class_cover_school_rank
              , ROW_NUMBER() OVER (PARTITION BY period_type_code,parent_id,section_type_code ORDER BY administrative_class_cover_school_num DESC)  AS administrative_class_cover_school_rank
              , ROW_NUMBER() OVER (PARTITION BY period_type_code,parent_id,section_type_code ORDER BY administrative_class_cover_school_rate DESC) AS administrative_class_cover_school_rate_rank
              , ROW_NUMBER() OVER (PARTITION BY period_type_code,parent_id,section_type_code ORDER BY regular_class_cover_school_rate DESC)        AS regular_class_cover_school_rate_rank
         FROM school_cover_stat
         WHERE region_id > 0
     )
-- **************************  结果数据整合  *************************************************
INSERT OVERWRITE TABLE ads__region_app_class_area_stat_d PARTITION(dt='${biz_date}')
SELECT FROM_UTC_TIMESTAMP(CURRENT_TIMESTAMP(), 'yyyy-MM-dd HH:mm:ss') AS                                                                 stat_time,
       '${biz_date}' AS                                                                                                                  stat_date,
       prac.period_start_date,
       '${biz_date}' AS                                                                                                                  period_end_date,
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
       uo.is_leaf AS                                                                                                                     is_leaf,
       prac.section_type_code,
       prac.section_type_name,
       prac.class_num,
       prac.regular_class_num,
       prac.administrative_class_num,
       prac.regular_class_cover_school_num,
       prac.administrative_class_cover_school_num,
       CONCAT(class_rank, '/', MAX(class_rank)
                                   OVER (PARTITION BY period_type_code,parent_id,section_type_code)) AS                                  class_rank,
       administrative_class_rank,
       NULL AS                                                                                                                           administrative_class_cover_rate,
       NULL AS                                                                                                                           administrative_class_cover_rate_rank,
       CONCAT(class_rank, '/', MAX(class_rank)
                                   OVER (PARTITION BY period_type_code,parent_id,section_type_code)) AS                                  regular_class_rank,
       CONCAT(administrative_class_cover_school_rank, '/', MAX(administrative_class_cover_school_rank)
                                                               OVER (PARTITION BY period_type_code,parent_id,section_type_code)) AS      administrative_class_cover_school_rank,
       administrative_class_cover_school_rate,
       CONCAT(administrative_class_cover_school_rate_rank, '/', MAX(administrative_class_cover_school_rate_rank)
                                                                    OVER (PARTITION BY period_type_code,parent_id,section_type_code)) AS administrative_class_cover_school_rate_rank,
       CONCAT(regular_class_cover_school_rank, '/', MAX(regular_class_cover_school_rank)
                                                        OVER (PARTITION BY period_type_code,parent_id,section_type_code)) AS             regular_class_cover_school_rank,
       regular_class_cover_school_rate,
       CONCAT(regular_class_cover_school_rate_rank, '/', MAX(regular_class_cover_school_rate_rank)
                                                             OVER (PARTITION BY period_type_code,parent_id,section_type_code)) AS        regular_class_cover_school_rate_rank
FROM class_area_rank prac
         LEFT JOIN (SELECT DISTINCT org_id, is_leaf
                    FROM nddc.dwd__md__whole_organization__d__full
                    WHERE dt = '${full_biz_date}') uo
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
       0                                                              AS is_leaf,
       section_type_code,
       section_type_name,
       class_num,
       regular_class_num,
       administrative_class_num,
       regular_class_cover_school_num,
       administrative_class_cover_school_num,
       NULL                                                           AS class_rank,
       NULL                                                           AS administrative_class_rank,
       NULL                                                           AS administrative_class_cover_rate,
       NULL                                                           AS administrative_class_cover_rate_rank,
       NULL                                                           AS regular_class_rank,
       NULL                                                           AS administrative_class_cover_school_rank,
       administrative_class_cover_school_rate,
       NULL                                                           AS administrative_class_cover_school_rate_rank,
       NULL                                                           AS regular_class_cover_school_rank,
       regular_class_cover_school_rate,
       NULL                                                           AS regular_class_cover_school_rate_rank
FROM school_cover_stat
WHERE region_id <= 0
