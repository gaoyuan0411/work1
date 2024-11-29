-- 研修相关分省搜索量
WITH search_data AS (
    SELECT '2023' AS stat_type, user_id, device_id, province_id, province_name, COUNT(eid) search_count
    FROM nddc.dwd__ri__search_event_detail__d__incr
    WHERE dt BETWEEN '2023-07-01' AND '2023-07-14'
      AND event_code IN ('edu_Platform_confirmSearch_click', 'edu_Platform_searchHistory_click')
      AND province_id <> -2
      AND search_keyword IN ('暑期教师研修', '暑期研修', '教师研修', '2023年暑期教师研修', '暑期教师培训', '暑期培训', '教师培训', '2023年暑期教师培训')
    GROUP BY user_id, device_id, province_id, province_name
    UNION ALL
    SELECT '2024' AS stat_type, user_id, device_id, province_id, province_name, COUNT(eid) search_count
    FROM nddc.dwd__ri__search_event_detail__d__incr
    WHERE dt BETWEEN '2024-07-01' AND '2024-07-20'
      AND event_code IN ('edu_Platform_confirmSearch_click', 'edu_Platform_searchHistory_click')
      AND province_id <> -2
      AND search_keyword IN ('暑期教师研修', '暑期研修', '教师研修', '2024年暑期教师研修', '暑期教师培训', '暑期培训', '教师培训', '2024年暑期教师培训')
    GROUP BY user_id, device_id, province_id, province_name
)
SELECT province_name as `省份`
     , SUM(IF(stat_type = '2023', search_count, 0))            AS `搜索次数(2023年)`
     , COUNT(DISTINCT IF(stat_type = '2023', user_id, NULL))   AS `用户数(2023年)`
     , COUNT(DISTINCT IF(stat_type = '2023', device_id, NULL)) AS `设备数(2023年)`
     , SUM(IF(stat_type = '2024', search_count, 0))            AS `搜索次数(2024年)`
     , COUNT(DISTINCT IF(stat_type = '2024', user_id, NULL))   AS `用户数(2024年)`
     , COUNT(DISTINCT IF(stat_type = '2024', device_id, NULL)) AS `设备数(2024年)`
FROM search_data
GROUP BY province_name
;
-- 超额完成分省教师数
WITH teacher_info AS (
    --参与培训教师
    SELECT user_id, user_province_id, user_province_name
    FROM nddc.dwd__tt__verify_teacher_info__dd__full
    WHERE dt = '${biz_date}'
      AND verify_status = 1
      AND NVL(user_province_id, -2) <> -2
)
   , train_info AS (
    SELECT train_id,
           train_name
    FROM nddc.dwd__tt__training_info__dd__full
    WHERE dt = '${biz_date}'
      AND train_id IN ('bb042e69-9a11-49a1-af22-0c3fab2e92b9', -- bb042e69-9a11-49a1-af22-0c3fab2e92b9=2022年“暑期教师研修”专题
                       '71a83441-6d45-4644-80f0-00efa40df164', -- 71a83441-6d45-4644-80f0-00efa40df164=2023年“暑期教师研修”专题
                       '5d7cf98c-3a42-4b13-8e5f-56f40ce08b1d') -- 5d7cf98c-3a42-4b13-8e5f-56f40ce08b1d=2024年“暑期教师研修”专题
)
   , train_course AS (
    SELECT tc.course_id,
           tc.title,
           tc.train_id,
           tc.period_limit,
           tc.period,
           ti.train_name
    FROM (SELECT *
          FROM nddc.ods__elearning_train_api__train_course__mysql__full
          WHERE dt = '${biz_date}'
         ) tc
             JOIN train_info ti
                  ON tc.train_id = ti.train_id
)
   , train_course_user_progress AS (
    SELECT tcu.train_id,
           tcu.course_id,
           tcu.user_id,
           tcu.effective_time,
           IF(tcu.effective_time IS NOT NULL, ROUND(tcu.effective_time / 2700, 2), 0) AS study_time,  --学习学时
           tc.train_name
    FROM (SELECT * FROM nddc.ods__elearning_train_api__train_course_user_progress__mysql__full WHERE dt = '${biz_date}') tcu
             JOIN train_course tc
                  ON tcu.course_id = tc.course_id
                      AND tcu.train_id = tc.train_id
)
   , train_user_study AS (
    SELECT train_id, train_name, user_id, SUM(study_time) AS study_time
    FROM train_course_user_progress
    WHERE study_time > 0
    GROUP BY train_id, train_name, user_id
)
SELECT ti.user_province_name                                                        AS `省份`
     , tus.train_name                                                               AS `年份`
     , COUNT(DISTINCT IF(study_time >= 10 AND study_time <= 12, tus.user_id, NULL)) AS `10（含）-12（含）教师数`
     , COUNT(DISTINCT IF(study_time > 12 AND study_time <= 15, tus.user_id, NULL))  AS `12-15（含）教师数`
     , COUNT(DISTINCT IF(study_time > 15 AND study_time <= 20, tus.user_id, NULL))  AS `15-20（含）教师数`
     , COUNT(DISTINCT IF(study_time > 20, tus.user_id, NULL))                       AS `20以上教师数`
FROM train_user_study tus
         INNER JOIN teacher_info ti
                    ON tus.user_id = ti.user_id
GROUP BY ti.user_province_name, tus.train_name
ORDER BY user_province_name,train_name
