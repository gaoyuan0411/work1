-- SELECT app_type,
--        CASE
--            WHEN province = '内蒙' THEN '内蒙古'
--            WHEN province = '新疆' THEN '新疆(含兵团)'
--            ELSE province END AS province,
--        SUM(cum_uv + new_uv)  AS uv,
--        SUM(cum_pv + pv)      AS pv
-- FROM ads_zxx_province_stat_d
-- WHERE identity = 'all'
--   AND app_type IN ('android', 'ios_hd', 'android_hd', 'ios', 'web-all', 'pc')
--   AND province IN ('宁夏', '西藏', '新疆', '青海', '广西', '内蒙')
--   AND stat_date = CONVERT(DATE_SUB(CURDATE(), INTERVAL 1 DAY), char)
-- GROUP BY province, app_type
SELECT app_type
     , IF(t2.province = '新疆', '新疆（含兵团）', t2.province) AS province
     , pv
     , uv
FROM (SELECT app_type
,province_id
,sum(pv) as pv
,sum(uv) as uv
             from
         (SELECT IF(province_id = '594033008597', '594033008595', province_id) AS province_id
               , uv
               , pv
               , app_type
          FROM ads__platform_area_stat__d
          WHERE period_type_code = 99
            AND end_date = DATE_SUB(CURDATE(), INTERVAL 1 DAY)
            AND site_type = 'zxx'
            AND identity = 'all'
            AND country = '中国'
            AND province_id IN
                ('594033008543', '594033008593', '594033008573', '594033008595', '594033008585', '594033008591', '594033008597')
            AND city_id = 'all'
            AND language = 'all'
            AND app_type IN ('android', 'ios_hd', 'android_hd', 'ios', 'web', 'pc')

         )  t  GROUP BY  province_id,app_type
     ) t1
         JOIN
     (
         SELECT org_id AS province_id, org_name AS province, dauc.student_num + dauc.teacher_num AS base_num
         FROM dim_area_user_cardinality dauc
         WHERE org_id != 0
     ) t2
     ON t1.province_id = t2.province_id