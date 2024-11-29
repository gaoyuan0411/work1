-- 时间范围：
-- 2023年1月-2024年11月
-- 统计范围：
-- 24年积分排名前30的教师
-- 统计逻辑：
-- 1. 访问量：教师画像“活跃情况”中的平台访问量
-- 2. 平台使用次数：教师画像“活跃情况”中的平台使用次数
-- 3. 资源访问量：教师画像“整体资源使用情况”中的全部频道的访问次数
-- 4. 资源分享次数：教师画像“教师课下引导学习情况”中的分享资源次数
-- 用户解密
DROP TEMPORARY FUNCTION IF EXISTS nd_uc_name_dec;
CREATE TEMPORARY FUNCTION nd_uc_name_dec AS 'com.nd.udf.NdUcNameDecUDF' USING JAR 'hdfs://cmss/user/nddc/udf/nd-uc-udfdes-0.3.jar';
WITH teacher_top30 AS (
    --教师积分前30名
    SELECT *
    FROM (
             SELECT user_id,
                    nd_uc_name_dec(user_name)                         AS user_name,
                    ROW_NUMBER() OVER (ORDER BY incentive_score DESC) AS rk
             FROM nddc.ads__incentive__teacher__user_period_stat__d
             WHERE dt = '2024'
         ) r
    WHERE rk <= 30
)
   , month_period_type_list AS (
    --月份数据
    SELECT DISTINCT period_code
                  , period_type_code
                  , period_start_date
                  , period_end_date
                  , period_type_text
    FROM nddc.dim__date_period t
    WHERE period_type_code IN (30)
      AND date_code <= '${biz_date}'
      AND DATE_FORMAT(date_code, 'yyyy') IN ('2023', '2024')
)
   , teacher_top30_month AS (
    SELECT tt.*, mp.*
    FROM teacher_top30 tt
             INNER JOIN month_period_type_list mp
)
   , pv_data AS (
    --平台访问数据
    SELECT user_id, period_code, page_views
    FROM nddc.ads__personal__use_platform__d__full2
    WHERE period_type_code = 30
      AND SUBSTRING(period_code, 0, 4) IN ('2023', '2024')
)
   , use_platform_data AS (
    --平台使用数据
    SELECT user_id, period_code, platform_usage_times
    FROM nddc.ads__personal__use_platform_detail__d__full2
    WHERE period_type_code = 30
      AND SUBSTRING(period_code, 0, 4) IN ('2023', '2024')
)
   , visit_data AS (
--        资源浏览数据
    SELECT a.user_id, a.period_code, SUM(NVL(visit_count, 0)) AS visit_count
    FROM (
             SELECT *,
                    CAST(GET_JSON_OBJECT(visit_info, '$.visit_count') AS BIGINT) AS visit_count
             FROM nddc.ads__personal__overall_resource_usage__d__full2 t
                      LATERAL VIEW EXPLODE(SPLIT(
                              REGEXP_REPLACE(REGEXP_REPLACE(channel_access_pv, '\\[|\\]', ''), '\\}\\,\\{', '\\}\\;\\{'),
                              '\\;')) b AS visit_info
             WHERE t.period_type_code = 30
               AND SUBSTRING(period_code, 0, 4) IN ('2024', '2023')
         ) a
    GROUP BY a.user_id, a.period_code
)
   , share_data AS (
       --资源分享数据
    SELECT user_id, period_code, share_count
    FROM nddc.ads__portrait__tt__train_su__dd__full
    WHERE dt = '${biz_date}'
      AND period_type_code = 30
      AND SUBSTRING(period_code, 0, 4) IN ('2024', '2023')
)
SELECT tm.user_name                                         -- 教师名称
     , tm.period_code                                       -- 月份
     , NVL(pd.page_views, 0)            AS pv               -- 平台访问量
     , NVL(upd.platform_usage_times, 0) AS use_num          -- 平台使用次数
     , NVL(vd.visit_count, 0)           AS visit_count      -- 资源访问量
     , NVL(sd.share_count, 0)           AS share_count      -- 资源分享次数
     , tm.rk
FROM teacher_top30_month tm
         LEFT JOIN pv_data pd ON tm.user_id = pd.user_id AND tm.period_code = pd.period_code
         LEFT JOIN use_platform_data upd ON tm.user_id = upd.user_id AND tm.period_code = upd.period_code
         LEFT JOIN visit_data vd ON tm.user_id = vd.user_id AND tm.period_code = vd.period_code
         LEFT JOIN share_data sd ON tm.user_id = sd.user_id AND tm.period_code = sd.period_code
ORDER BY rk, period_code