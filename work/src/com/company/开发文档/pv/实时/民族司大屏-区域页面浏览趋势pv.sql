--
-- select
-- stat_date,
--       CASE WHEN province='内蒙' THEN '内蒙古'
--    WHEN province='新疆' THEN '新疆(含兵团)'
--    ELSE province END AS province,
--   sum(pv) as pv
-- from
--   ads_zxx_province_stat_d
-- where
--   identity = 'all'
--   and app_type in (
--     'web-all',
--     'app',
--     'pc',
--     'app_hd'
--   )
--   and province in ('宁夏','西藏','新疆','青海','广西','内蒙')
--   and stat_date BETWEEN '20000101' and CONVERT (DATE_SUB(CURDATE(), INTERVAL 1 DAY),char)
-- group by
--   province,stat_date
--
select
t1.stat_date
,IF(t2.province='新疆','新疆（含兵团）',t2.province) as province
,t1.pv
from (
    select stat_date
    ,province_id
    , sum(pv) as pv
           from
         (
             SELECT end_date                                                      AS stat_date
                  , IF(province_id = '594033008597', '594033008595', province_id) AS province_id
                  , pv
             FROM ads__platform_area_stat__d
             WHERE period_type_code = 10
               AND end_date BETWEEN '2022-03-01' AND DATE_SUB(CURDATE(), INTERVAL 1 DAY)
               AND site_type = 'zxx'
               AND identity = 'all'
               AND country = '中国'
               AND province_id IN ('594033008543', '594033008593', '594033008573', '594033008595', '594033008585', '594033008591',
                                   '594033008597')
               AND city_id = 'all'
               AND language = 'all'
               AND app_type = 'all'

         ) t GROUP BY stat_date,  province_id
) t1
  join
  (
select org_id as province_id,org_name as province from dim_area_user_cardinality dauc
where org_id != 0
  ) t2
  on t1.province_id=t2.province_id