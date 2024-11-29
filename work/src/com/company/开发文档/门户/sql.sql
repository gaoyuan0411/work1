insert overwrite table ads__edu__training_resource_upv_screan_d partition(dt='${dt}')
select training_id,province,uv,pv,cum_pv,stat_date
from ads__edu__training_resource_upv_stat_d
    where dt = '${dt}'
      and province = '全国'
      and training_id in ('71a83441-6d45-4644-80f0-00efa40df164', 'bdbe4c1e-f540-4e9f-9fae-855ab44e2d32', 'bb042e69-9a11-49a1-af22-0c3fab2e92b9')
UNION ALL
SELECT channel_code                                              AS training_id
     , '全国'                                                      AS province
     , COUNT(DISTINCT IF(incr_visit_times > 0, device_id, NULL)) AS uv
     , SUM(incr_visit_times)                                     AS pv
     , SUM(total_visit_times)                                    AS cum_pv
     , '${dt}'                                                   AS stat_date
FROM dwm__smart_special__event_detail__dd__full
WHERE dt = '${dt}'
  AND channel_code = 'cpc20'
GROUP BY channel_code