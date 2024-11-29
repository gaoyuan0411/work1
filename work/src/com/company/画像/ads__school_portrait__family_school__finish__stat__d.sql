-- ==================================================================
-- 脚本名称： ads__school_portrait__family_school__finish__stat__d
-- 所属专题： 学校画像
-- 实现功能： 学校画像--家校共育完成情况
-- 任务流：学校画像二期（家校共育、班级互动）
-- 统计周期： 日
-- 创建者：   10017103
-- 创建日期： 2024-01-10
-- 修改者：
-- 修改日期：
-- 修改内容：
-- 依赖表：    dwd__tala__group_activity__d__full                   活动域表
-- --          dwd__sc__group_member__d__full
-- --          dwd__tala__user_activity_submit__d__full        活动域表
--              dwd__tala__user_activity_assign__d__full        活动域表
-- --          dwd__md__whole_school__d__full            基础域 组织表
-- ==================================================================2min
WITH -- 当天的时间维度编码数据
    today_period_type_list AS (
        SELECT date_code
             , period_code
             , period_type_code
             , period_start_date
             , period_end_date
             , period_type_text
        FROM nddc.dim__date_period t
        WHERE period_type_code IN (30, 50, 61)
          AND period_start_date <= '${biz_date}'
          AND period_end_date >= '${biz_date}'
          AND date_code <= '${biz_date}'
    )
   , group_number_info AS (
    SELECT DISTINCT user_id, group_id
    FROM nddc.dwd__sc__group_member__d__full gm
    WHERE dt = '${full_biz_date}'
      AND group_delete_flag = 0
      AND group_member_delete_flag = 0
      AND group_tag IN (9)
      AND product_code = 'zxx'
      AND user_identity LIKE '%GUARDIAN%'
)
   ,
   --发布的活动信息
    publish_activity_info AS (
        SELECT DISTINCT activity_id
                      , activity_original_id
                      , activity_name
                      , activity_internal_type
                      , activity_type
                      , activity_created_by
                      , group_type                                                  -- 0-普通群；8-课程群（师生群）；9-家校群； 10-工作室群；11-教研群
                      , CASE
                            WHEN activity_publish_date < '2022-03-01' THEN '2022-03-01'
                            ELSE activity_publish_date END AS activity_publish_date --发布日期
                      , group_school_id                    AS school_id
                      , group_id
                      , group_deleted
        FROM nddc.dwd__tala__group_activity__d__full vi
        WHERE dt = '${full_biz_date}'
          AND group_type IN ('9')
          AND activity_publish_date <= '${biz_date}'
          AND activity_deleted = 0
          AND activity_type IN ('notice', 'vote')
          AND group_activity_source = 'CLASS'
          AND activity_original_id <> '-1'
          AND NVL(group_school_id, -2) NOT IN (-1, -2, 0)
    )
   , submit_activity_info AS (--提交活动
    SELECT DISTINCT pa.activity_id
                  , pa.activity_original_id
                  , vuas.user_id
                  , pa.activity_type
                  , pa.activity_name
                  , pa.activity_internal_type --活动类型（0-日常活动、1-长期活动、2-自主探索、3-假期活动、4-作业活动
                  , pa.activity_publish_date  --发布日期
                  , pa.school_id
                  , gm.user_id AS member_id
                  , 'submit'      type
    FROM publish_activity_info pa
             LEFT JOIN
         (SELECT user_id,activity_original_id,activity_type
          FROM nddc.dwd__tala__user_activity_submit__d__full
          WHERE dt = '${full_biz_date}'
            AND event_date <= '${biz_date}'
            AND activity_deleted = 0
            AND activity_original_id <> '-1'
            AND activity_type IN ('vote')
            AND user_is_guardian = 1
         --通知 触达就算完成
             UNION ALL
          SELECT user_id,activity_original_id,activity_type
                    FROM nddc.dwd__tala__user_activity_read__d__full
                    WHERE dt = '${full_biz_date}'
                      AND event_date <= '${biz_date}'
                      AND activity_deleted = 0
                      AND activity_original_id <> '-1'
                      AND activity_type IN ('notice')
                      AND user_is_guardian = 1
         ) vuas
         ON vuas.activity_original_id = pa.activity_original_id
             AND vuas.activity_type = pa.activity_type
             LEFT JOIN group_number_info gm
                       ON pa.group_id = gm.group_id
                           AND vuas.user_id = gm.user_id
)
   , submit_activity_period_data AS (
    SELECT tptl.period_code
         , tptl.period_type_code
         , tptl.period_start_date
         , tptl.period_end_date
         , tptl.period_type_text
         , spai.*
    FROM submit_activity_info spai
             INNER JOIN today_period_type_list tptl
                        ON spai.activity_publish_date = tptl.date_code
    UNION ALL
    SELECT 'ALL'         period_code
         , 99            period_type_code
         , '2022-03-01'  period_start_date
         , '${biz_date}' period_end_date
         , '至今'          period_type_text
         , *
    FROM submit_activity_info
)
   , submit_activity_stat AS (
    SELECT period_code
         , period_type_code
         , period_start_date
         , period_end_date
         , period_type_text
         , activity_original_id
         , activity_type
         , school_id
         , COUNT(DISTINCT member_id) AS submit_activity_user_num
    FROM submit_activity_period_data
    GROUP BY activity_original_id, period_code, period_type_code, period_start_date, period_end_date, period_type_text,
             activity_type, school_id
)
--收到活动
   , assign_activity_info AS (
    select a.user_id as member_user_id,b.activity_type,b.activity_original_id,b.school_id,b.activity_publish_date   as activity_created_date
    from (select user_id,cast(group_id as string)  as group_id from nddc.dwd__sc__group_member__d__full t
    where dt='${full_biz_date}'
    and t.group_tag=9
    and t.user_identity='GUARDIAN'
    and t.group_delete_flag=0
    ) a inner join (
            SELECT DISTINCT
                           activity_type
                          , group_id
                          ,activity_original_id
                          ,school_id
                          ,activity_publish_date
            FROM publish_activity_info vi
        ) b
        on a.group_id=b.group_id
        group by a.user_id,b.activity_type,b.activity_original_id,b.school_id,b.activity_publish_date
)
   , assign_activity_period_data AS (
    SELECT tptl.period_code
         , tptl.period_type_code
         , tptl.period_start_date
         , tptl.period_end_date
         , tptl.period_type_text
         , pai.*
    FROM assign_activity_info pai
             INNER JOIN today_period_type_list tptl
                        ON pai.activity_created_date = tptl.date_code
    UNION ALL
    SELECT 'ALL'         period_code
         , 99            period_type_code
         , '2022-03-01'  period_start_date
         , '${biz_date}' period_end_date
         , '至今'          period_type_text
         , *
    FROM assign_activity_info
)
   , assign_activity_stat AS (
    SELECT period_code
         , period_type_code
         , period_start_date
         , period_end_date
         , period_type_text
         , activity_type
         , activity_original_id
         , school_id
         , COUNT(DISTINCT member_user_id) AS assign_num
    FROM assign_activity_period_data
    GROUP BY activity_original_id, period_code, period_type_code, period_start_date,
             period_end_date, period_type_text, activity_type, school_id
)
   , activity_stat AS (
    SELECT period_code
         , period_type_code
         , period_start_date
         , period_end_date
         , period_type_text
         , activity_type
         , activity_original_id
         , school_id
         , SUM(submit_activity_user_num)                                     AS submit_activity_user_num
         , SUM(assign_num)                                                   AS assign_num
         , ROUND(NVL(SUM(submit_activity_user_num) / SUM(assign_num), 0), 6) AS finish_rate
    FROM (
             SELECT period_code
                  , period_type_code
                  , period_start_date
                  , period_end_date
                  , period_type_text
                  , activity_type
                  , activity_original_id
                  , school_id
                  , submit_activity_user_num
                  , 0 AS assign_num
             FROM submit_activity_stat
             UNION ALL
             SELECT period_code
                  , period_type_code
                  , period_start_date
                  , period_end_date
                  , period_type_text
                  , activity_type
                  , activity_original_id
                  , school_id
                  , 0 AS submit_activity_user_num
                  , assign_num
             FROM assign_activity_stat
         ) t
    GROUP BY activity_original_id, period_code, period_type_code, period_start_date, period_end_date, period_type_text,
             activity_type, school_id
)
   , activity_finish_stat AS (
    SELECT period_code
         , period_type_code
         , period_start_date
         , period_end_date
         , period_type_text
         , activity_type
         , school_id
         , finish_rate_section
         , COUNT(DISTINCT activity_original_id) AS activity_num
    FROM (
             SELECT period_code
                  , period_type_code
                  , period_start_date
                  , period_end_date
                  , period_type_text
                  , activity_type
                  , activity_original_id
                  , school_id
                  , CASE
                        WHEN finish_rate >= 0 AND finish_rate < 0.1 THEN '0-10%'
                        WHEN finish_rate >= 0.1 AND finish_rate < 0.2 THEN '10-20%'
                        WHEN finish_rate >= 0.2 AND finish_rate < 0.3 THEN '20-30%'
                        WHEN finish_rate >= 0.3 AND finish_rate < 0.4 THEN '30-40%'
                        WHEN finish_rate >= 0.4 AND finish_rate < 0.5 THEN '40-50%'
                        WHEN finish_rate >= 0.5 AND finish_rate < 0.6 THEN '50-60%'
                        WHEN finish_rate >= 0.6 AND finish_rate < 0.7 THEN '60-70%'
                        WHEN finish_rate >= 0.7 AND finish_rate < 0.8 THEN '70-80%'
                        WHEN finish_rate >= 0.8 AND finish_rate < 0.9 THEN '80-90%'
                        ELSE '90-100%' END AS finish_rate_section
             FROM activity_stat
         ) t
    GROUP BY period_code, period_type_code, period_start_date, period_end_date, period_type_text, activity_type,
             school_id, finish_rate_section
)
   , all_data AS (
    SELECT '${biz_date}'                                                                  AS stat_date
         , period_code
         , period_type_code
         , period_start_date
         , period_end_date
         , period_type_text
         , school_id                                                                      AS region_id
         , acs.activity_type                                                              AS activity_type_code
         , dat.name                                                                       AS activity_type_name
         , activity_num
         , finish_rate_section
         , CAST(FROM_UTC_TIMESTAMP(CURRENT_TIMESTAMP(), 'yyyy-MM-dd HH:mm:ss') AS STRING) AS stat_time
    FROM activity_finish_stat acs
             --补充活动类型名称
             LEFT JOIN nddc.dim_dict dat
                       ON acs.activity_type = dat.value
                           AND dat.dict_code = 'tal_activity_type'
)
   --昨日周期数据去除包含今天日期涉及周期的编码的数据
   , yesterday_stat_data AS (
    SELECT stat_date
         , a.period_code
         , period_type_code
         , period_start_date
         , period_end_date
         , period_type_text
         , region_id
         , activity_type_code
         , activity_type_name
         , activity_num
         , finish_rate_section
         , stat_time
    FROM ads__school_portrait__family_school__finish__stat__d a
    WHERE dt = DATE_SUB('${biz_date}', 1)
      AND period_type_code <> (99)
      AND a.period_code NOT IN (SELECT DISTINCT b.period_code
                                FROM today_period_type_list b)
)
INSERT OVERWRITE TABLE ads__school_portrait__family_school__finish__stat__d PARTITION (dt = '${biz_date}')
SELECT stat_date
     , period_code
     , period_type_code
     , period_start_date
     , period_end_date
     , period_type_text
     , region_id
     , school_name                                                                    AS region_name
     , activity_type_code
     , activity_type_name
     , activity_num
     , finish_rate_section
     , CAST(FROM_UTC_TIMESTAMP(CURRENT_TIMESTAMP(), 'yyyy-MM-dd HH:mm:ss') AS STRING) AS stat_time
FROM (
         SELECT *
         FROM all_data ad
         WHERE ad.region_id >= 0
         UNION ALL
         SELECT *
         FROM yesterday_stat_data ysd
         WHERE ysd.region_id >= 0
     ) tmp
         INNER JOIN
     (
         SELECT DISTINCT school_id,
                         school_name
         FROM nddc.dwd__md__whole_school__d__full
         WHERE dt = '${full_biz_date}'
     ) sc ON tmp.region_id = sc.school_id



