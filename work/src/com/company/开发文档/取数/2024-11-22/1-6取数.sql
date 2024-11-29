-- 取数1
-- 时间范围：
-- 2023年1月-2023年11月
-- 2024年1月-2024年11月
-- 统计范围：
-- 不区分注册来源，注册时间2024年之前
-- 统计逻辑：
-- 注册时间在24年之前的教师用户和教师画像关联，画像数据中该用户每个月的平台使用次数都大于0
WITH teacher_info AS (
    --教师信息
    SELECT account_id, if(created_date<'2023-01-01',11,202312 - CAST(DATE_FORMAT(created_date, 'yyyyMM') AS INT)) AS sub_month
    FROM nddc.dwd__md__person_account__d__full
    WHERE dt = '${biz_date}'
      AND is_teacher = 1
      AND created_date < '2024-01-01'
)
   , use_platform_data AS (
    --平台使用数据
    SELECT user_id, data_year, COUNT(DISTINCT period_code) AS month_num
    FROM (
             SELECT user_id, period_code, SUBSTRING(period_code, 0, 4) AS data_year
             FROM nddc.ads__personal__use_platform_detail__d__full2
             WHERE period_type_code = 30
               AND SUBSTRING(period_code, 0, 4) IN ('2023', '2024')
               AND period_code != '202312' --去除2023年12月份的数据
               AND platform_usage_times > 0
         ) a
    GROUP BY user_id, data_year
)
   , user_data AS (
    SELECT upd.*
         , CASE
               WHEN upd.data_year = '2024' AND upd.month_num = 11 THEN upd.user_id
               WHEN upd.data_year = '2023' AND upd.month_num=ti.sub_month THEN upd.user_id
               ELSE NULL END AS stat_id
    FROM use_platform_data upd
             INNER JOIN teacher_info ti
                        ON upd.user_id = ti.account_id
)
SELECT data_year, COUNT(DISTINCT stat_id) AS teacher_num
FROM user_data
GROUP BY data_year
ORDER BY data_year
;

-- 取数2
-- 时间范围：
-- 2023年1月-2023年11月
-- 2024年1月-2024年11月
-- 统计范围：
-- 不区分注册来源，注册时间2024年之前，并且教师所属的学段是中小学学段
-- 统计逻辑：
-- 注册时间在24年之前的教师用户和教师画像关联，画像数据中该用户每个月的平台使用次数都大于0
WITH teacher_info AS (
    --教师信息
    SELECT account_id,if(created_date<'2023-01-01',11,202312 - CAST(DATE_FORMAT(created_date, 'yyyyMM') AS INT)) AS sub_month
    FROM nddc.dwd__md__person_account__d__full
    WHERE dt = '${biz_date}'
      AND is_teacher = 1
      AND school_section IN (SELECT section_code FROM nddc.dim__k12_school_section) --取中小学学段
      AND created_date < '2024-01-01'
)
   , use_platform_data AS (
    --平台使用数据
    SELECT user_id, data_year, COUNT(DISTINCT period_code) AS month_num
    FROM (
             SELECT user_id, period_code, SUBSTRING(period_code, 0, 4) AS data_year
             FROM nddc.ads__personal__use_platform_detail__d__full2
             WHERE period_type_code = 30
               AND SUBSTRING(period_code, 0, 4) IN ('2023', '2024')
               AND period_code != '202312' --去除2023年12月份的数据
               AND platform_usage_times > 0
         ) a
    GROUP BY user_id, data_year
)
   , user_data AS (
    SELECT upd.*
         , CASE
               WHEN upd.data_year = '2024' AND upd.month_num = 11 THEN upd.user_id
               WHEN upd.data_year = '2023' AND upd.month_num=ti.sub_month THEN upd.user_id
               ELSE NULL END AS stat_id
    FROM use_platform_data upd
             INNER JOIN teacher_info ti
                        ON upd.user_id = ti.account_id
)
SELECT data_year, COUNT(DISTINCT stat_id) AS teacher_num
FROM user_data
GROUP BY data_year
ORDER BY data_year
;

-- 取数3
-- 时间范围：
-- 2024年1月-2024年11月
-- 统计范围：
-- 不区分注册来源，注册时间2024年的教师教师
-- 统计逻辑：
-- 注册时间在24年的教师用户和教师画像关联，画像数据中该用户每个月的平台使用次数都大于0（使用月份=注册月时长）
WITH teacher_info AS (
    --教师信息
    SELECT account_id, 202412 - CAST(DATE_FORMAT(created_date, 'yyyyMM') AS INT) AS sub_month
    FROM nddc.dwd__md__person_account__d__full
    WHERE dt = '${biz_date}'
      AND is_teacher = 1
      AND created_date >= '2024-01-01'
)
   , use_platform_data AS (
    --平台使用数据
    SELECT user_id, COUNT(DISTINCT period_code) AS month_num
    FROM (
             SELECT user_id, period_code
             FROM nddc.ads__personal__use_platform_detail__d__full2
             WHERE period_type_code = 30
               AND SUBSTRING(period_code, 0, 4) IN ('2024')
               AND platform_usage_times > 0
         ) a
    GROUP BY user_id
)
   , user_data AS (
    SELECT upd.*
         , IF(upd.month_num = ti.sub_month, upd.user_id, NULL) AS stat_id
    FROM use_platform_data upd
             INNER JOIN teacher_info ti
                        ON upd.user_id = ti.account_id
)
SELECT COUNT(DISTINCT stat_id) AS teacher_num
FROM user_data
;

-- 取数4
-- 时间范围：
-- 2023年1月-2023年11月
-- 2024年1月-2024年11月
-- 统计范围：
-- 教师身份的总访问量
-- 统计逻辑：
-- 页面浏览的身份等于教师的月访问之和
SELECT data_year, SUM(pv) AS pv
FROM (
         SELECT pv
              , DATE_FORMAT(end_date, 'yyyy') AS data_year
         FROM nddc.ads__platform_area_stat__d t
         WHERE ptc = '30'
           AND DATE_FORMAT(bd, 'yyyy') IN ('2023', '2024')
           AND bd != '2023-12-31' --去除23年12月份的数据
           AND app_type = 'all'
           AND site_type = 'zxx'
           AND identity = 'TEACHER'
           AND country = 'all'
           AND language = 'all'
--2024年11月数据
         UNION ALL
         SELECT SUM(pv) AS pv, '2024' AS data_year
         FROM nddc.dws__pv__event_stat__dm__incr t
         WHERE dt = '2024-11'
           AND pc = 'zxx'
           AND t.identity = 'TEACHER'
     ) t
GROUP BY data_year
ORDER BY data_year
;

-- 取数5
-- 时间范围：
-- 2023年1月-2023年11月
-- 2024年1月-2024年11月
-- 统计范围：
-- 教师画像中所有用户
-- 统计逻辑：
-- 教师画像中所有用户的每个月全部频道的资源访问量之和
WITH teacher_info AS (
    --教师画像用户信息
    SELECT user_id
    FROM nddc.ads__personal__teacher_basic_information__d__full
    WHERE dt = '${biz_date}'
)
   , visit_data AS (
    SELECT user_id, data_year, SUM(NVL(visit_count, 0)) AS visit_count
    FROM (
             SELECT *,
                    CAST(GET_JSON_OBJECT(visit_info, '$.visit_count') AS BIGINT) AS visit_count,
                    SUBSTRING(period_code, 0, 4)                                 AS data_year
             FROM nddc.ads__personal__overall_resource_usage__d__full2 t
                      LATERAL VIEW EXPLODE(SPLIT(
                              REGEXP_REPLACE(REGEXP_REPLACE(channel_access_pv, '\\[|\\]', ''), '\\}\\,\\{', '\\}\\;\\{'),
                              '\\;')) b AS visit_info
             WHERE t.period_type_code = 30
               AND SUBSTRING(period_code, 0, 4) IN ('2024', '2023')
               AND period_code != '202312' --去除23年12月份的数据
         ) a
    GROUP BY a.user_id, a.data_year
)
SELECT data_year, SUM(visit_count) AS visit_count
FROM teacher_info ti
         INNER JOIN visit_data vd
                    ON ti.user_id = vd.user_id
GROUP BY data_year
ORDER BY data_year
;

-- 取数6
-- 时间范围：
-- 2023年1月-2023年11月
-- 2024年1月-2024年11月
-- 统计范围：
-- 教师画像中所有用户
-- 统计逻辑：
-- 教师画像中所有用户的每个月“教师课下引导学习情况”中的分享资源次数之和
WITH teacher_info AS (
    --教师画像用户信息
    SELECT user_id
    FROM nddc.ads__personal__teacher_basic_information__d__full
    WHERE dt = '${biz_date}'
)
   , share_data AS (
    SELECT user_id, share_count, SUBSTRING(period_code, 0, 4) AS data_year
    FROM nddc.ads__portrait__tt__train_su__dd__full
    WHERE dt = '${biz_date}'
      AND period_type_code = 30
      AND SUBSTRING(period_code, 0, 4) IN ('2024', '2023')
      AND period_code != '202312' --去除23年12月份的数据
)
SELECT data_year, SUM(share_count) AS share_count
FROM teacher_info ti
         INNER JOIN share_data sd
                    ON ti.user_id = sd.user_id
GROUP BY data_year
ORDER BY data_year