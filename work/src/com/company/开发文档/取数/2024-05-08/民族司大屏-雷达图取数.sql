WITH nation_province_data AS (
    SELECT 594033008585 AS province_id, 594033008585 AS real_province_id, '西藏' AS province_name
    UNION ALL
    SELECT 594033008543 AS province_id, 594033008543 AS real_province_id, '内蒙古' AS province_name
    UNION ALL
    SELECT 594033008593 AS province_id, 594033008593 AS real_province_id, '宁夏' AS province_name
    UNION ALL
    SELECT 594033008573 AS province_id, 594033008573 AS real_province_id, '广西' AS province_name
    UNION ALL
    -- 新疆生产建设兵团
    SELECT 594033008595 AS province_id, 594033008597 AS real_province_id, '新疆（含兵团）' AS province_name
    UNION ALL
    SELECT 594033008595 AS province_id, 594033008595 AS real_province_id, '新疆（含兵团）' AS province_name
    UNION ALL
    SELECT 594033008591 AS province_id, 594033008591 AS real_province_id, '青海' AS province_name
)
--教师应用
SELECT t1.province_id,
       t1.province_name,
       t3.activity_type,
       COUNT(DISTINCT t3.activity_id) AS activity_publish_count
FROM nation_province_data t1
         INNER JOIN nddc.dwd__md__person_account__d__full t2
                    ON t2.user_province_id = t1.real_province_id
         INNER JOIN nddc.dwd__tala__group_activity__d__full t3
                    ON t3.activity_created_by = t2.account_id
WHERE t2.dt = '${biz_date}'
  AND t2.is_teacher = 1
  AND t3.dt = '${biz_date}'
  AND t3.activity_deleted = 0
  AND t3.x_product_code = 'zxx'
  AND t3.activity_deleted = 0
  AND t3.activity_original_id <> '-1'
  AND t2.is_teacher = 1
GROUP BY t1.province_id, t3.activity_type, t1.province_name

         -- 授课数据
UNION ALL
SELECT t1.province_id,
       t1.province_name,
       '授课',
       COUNT(*) AS activity_publish_count
FROM nation_province_data t1
         INNER JOIN nddc.dws__talr__teaching_stat__full t2
                    ON t1.real_province_id = t2.province_id
WHERE t2.identity = 'TEACHER'
  AND t2.dt = '${biz_date}'
GROUP BY t1.province_id, t1.province_name

         -- 备课数据
UNION ALL
SELECT t1.province_id,
       t1.province_name,
       '备课',
       COUNT(*) AS activity_publish_count
FROM nation_province_data t1
         INNER JOIN nddc.dws__talr__prepare_lesson_stat__full t2
                    ON t1.real_province_id = t2.province_id
WHERE t2.identity = 'TEACHER'
  AND t2.dt = '${biz_date}'
GROUP BY t1.province_id, t1.province_name

         -- 触控（白板）数据
UNION ALL
SELECT t1.province_id, t1.province_name, '触控', SUM(t.click_num) AS activity_publish_count
FROM nation_province_data t1
         INNER JOIN nddc.ads__zxx__white_plate_event_area_stat__d t
                    ON t1.real_province_id = t.province_id
WHERE t.dt = '${biz_date}'
  AND t.period_type_code = 99
  AND t.channel_code = 'all'
  AND t.subject_code = 'all'
  AND t.hour_code = 'all'
  AND t.weeks_code = 'all'
  AND t.area_type = 'province'
GROUP BY t1.province_id, t1.province_name

-- 学生应用

SELECT tmp.province_id,
       activity_type,
       province_name,
       SUM(tmp.participate_count) AS participate_count
FROM (
         SELECT COALESCE(sbt.province_id, rd.province_id)             AS province_id,
                COALESCE(sbt.province_name, rd.province_name)         AS province_name,
                COALESCE(sbt.activity_type, rd.activity_type)            activity_type,
                COALESCE(sbt.participate_count, rd.participate_count) AS participate_count
         FROM (
                  -- 提交数据
                  SELECT t3.province_id,
                         t3.province_name,
                         t1.user_id,
                         t1.activity_id,
                         t1.activity_type,
                         COUNT(DISTINCT t1.event_id, t1.activity_id) AS participate_count
                  FROM nation_province_data t3
                           INNER JOIN nddc.dwd__tala__group_activity__d__full t2
                                      ON t2.group_province_id = t3.real_province_id
                           INNER JOIN nddc.dwd__tala__user_activity_submit__d__full t1
                                      ON t1.activity_id = t2.activity_id AND t1.activity_type = t2.activity_type
                  WHERE t1.dt = '${biz_date}'
                    AND t2.dt = '${biz_date}'
                    AND t1.user_is_student = 1
                    AND t2.x_product_code = 'zxx'
                    AND t1.x_product_code = 'zxx'
                    AND t1.event_date <= '${biz_date}'
                    AND t1.activity_deleted = 0
                    AND t1.activity_original_id <> '-1'
                    AND t1.user_is_student = 1
                  GROUP BY t3.province_id, t1.user_id, t1.activity_id, t3.province_name, t1.activity_type
              ) sbt
                  FULL OUTER JOIN(
             -- 触达数据
             SELECT t3.province_id,
                    t3.province_name,
                    t1.user_id,
                    t1.activity_id,
                    t1.activity_type,
                    1 AS participate_count
             FROM nation_province_data t3
                      INNER JOIN nddc.dwd__tala__group_activity__d__full t2
                                 ON t2.group_province_id = t3.real_province_id
                      INNER JOIN nddc.dwd__tala__user_activity_read__d__full t1
                                 ON t1.activity_id = t2.activity_id AND t1.activity_type = t2.activity_type
             WHERE t1.dt = '${biz_date}'
               AND t2.dt = '${biz_date}'
               AND t1.user_is_student = 1
               AND t2.x_product_code = 'zxx'
               AND t1.x_product_code = 'zxx'
               AND t1.event_date <= '${biz_date}'
               AND t1.activity_deleted = 0
               AND t1.activity_original_id <> '-1'
               AND t1.user_is_student = 1
             GROUP BY t3.province_id, t1.user_id, t1.activity_id, t3.province_name, t1.activity_type
         ) rd ON sbt.province_id = rd.province_id AND sbt.user_id = rd.user_id AND
                 sbt.activity_id = rd.activity_id
     ) tmp
GROUP BY tmp.province_id, activity_type, province_name

--资源评价情况
SELECT npd.province_id
     , npd.province_name
     , SUM(assessment_total_count) assessment_total_count
     , SUM(favorite_total_count)   favorite_total_count
     , SUM(share_total_count)      share_total_count
     , SUM(like_total_like_count)  like_total_like_count
FROM nation_province_data npd
         INNER JOIN (SELECT province_id, assessment_total_count
                     FROM nddc.dws__ri__area_assessment_stat__dd__full t
                     WHERE dt = '${biz_date}'
                       AND city_id = 0
                       AND x_product_code = 'zxx'
                       AND content_channel_code = 'ALL') assessment
                    ON npd.real_province_id = assessment.province_id
         INNER JOIN (SELECT province_id, favorite_total_count
                     FROM nddc.dws__ri__area_favorite_stat__dd__full t
                     WHERE dt = '${biz_date}'
                       AND t.city_id = 0
                       AND x_product_code = 'zxx'
                       AND content_channel_code = 'ALL') favorite
                    ON npd.real_province_id = favorite.province_id
         INNER JOIN (SELECT province_id, share_total_count
                     FROM nddc.dws__ri__area_share_stat__da__full_v2 t
                     WHERE dt = '${biz_date}'
                       AND t.city_id = 0
                       AND x_product_code = 'zxx'
                       AND share_object_type = 'resource'
                       AND share_object_internal_type = 'ALL'
                       AND t.period_type_code = 99) share ON npd.real_province_id = share.province_id
         INNER JOIN (SELECT province_id, SUM(like_total_like_count) AS like_total_like_count
                     FROM nddc.dws__ri__area_like_stat__dd__full_v2
                     WHERE dt = '${biz_date}'
                       AND city_id = 0
                       AND x_product_code = 'zxx'
                     GROUP BY province_id) like_data ON npd.real_province_id = like_data.province_id
GROUP BY npd.province_id, npd.province_name