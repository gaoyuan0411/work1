SELECT 50                                                   AS period_type_code
     , CONCAT(DATE_FORMAT('${biz_date}', 'yyyy'), '-12-31') AS end_date
     , '年'                                                  AS period_type_text
     , identity
     , IF(province_id IS NULL, NULL, MAX(province_name))    AS province_name
     , COALESCE(province_id, 'all')                         AS province_id
     , IF(city_id IS NULL, NULL, MAX(city_name))            AS city_name
     , COALESCE(city_id, 'all')                             AS city_id
     , IF(area_id IS NULL, NULL, MAX(area_name))            AS area_name
     , COALESCE(area_id, 'all')                             AS area_id
     , module_code
     , MAX(module_name)                                     AS module_name
     , COUNT(DISTINCT device_id)                            AS uv
     , SUM(NVL(pv, 0))                                      AS pv
FROM (SELECT identity
           , province_name
           , province_id
           , city_name
           , city_id
           , area_name
           , area_id
           , module_code
           , module_name
           , device_id
           , SUM(NVL(visit_times, 0)) AS pv
      FROM nddc.dwm__pv__event_detail__dy__incr
      WHERE dt = DATE_FORMAT('${biz_date}', 'yyyy')
        AND pc = 'zxx'
        AND country_name = '中国'
        AND NVL(identity, '') != 'all'
      GROUP BY identity, province_name, province_id, city_name, city_id, area_name, area_id, module_code, module_name, device_id
     )
GROUP BY module_code, identity, province_id, city_id, area_id
    GROUPING SETS (
    ( module_code, identity, province_id, city_id, area_id),
    ( module_code, identity, province_id, city_id),
    ( module_code, identity, province_id),
    ( module_code, identity)
    )