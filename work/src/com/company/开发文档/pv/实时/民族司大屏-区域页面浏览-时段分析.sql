select
    t1.event_hour
    ,IF(t2.province='新疆','新疆（含兵团）',t2.province) as province
    ,t1.pv
from (
    SELECT
        province_id
    ,event_hour
    ,sum(pv) as pv
    from
         (SELECT IF(province_id = '594033008597', '594033008595', province_id) AS province_id,
                 event_hour,
                 pv
          FROM dws__pv__event_hour_stat__dy__incr
          WHERE product_code = 'zxx'
            AND identity = 'all'
            AND country_name = '中国'
            AND province_id IN
                ('594033008543', '594033008593', '594033008573', '594033008595', '594033008585', '594033008591', '594033008597')
            AND city_id = 0
            AND language = 'all'
            AND module_code = 'all'
         ) t GROUP BY province_id, event_hour
) t1
    join
      (
    select org_id as province_id,org_name as province from dim_area_user_cardinality dauc
    where org_id != 0
      ) t2
      on t1.province_id=t2.province_id