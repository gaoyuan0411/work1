-- SELECT
--   app_type
--   ,case when app_type = 'app' then '手机APP'
--        when app_type = 'app_hd' then '平板APP'
--        when app_type = 'pc' then '电脑客户端'
--        when app_type = 'web-all' then '浏览器' end app_type_name
--   ,stat_hour AS hour
--   ,if(stat_hour >= HOUR(now()), null, sum(if(stat_date = #{stat_date}, uv, 0))) as uv
--   ,sum(if(stat_date != #{stat_date}, uv, 0)) as yesterday_uv
--   ,if(stat_hour >= HOUR(now()), null, sum(if(stat_date = #{stat_date}, pv, 0))) as pv
--   ,sum(if(stat_date != #{stat_date}, pv, 0)) as yesterday_pv
-- FROM (
-- SELECT
--   app_type
--   ,stat_date
--   ,stat_hour
--   ,sum(pv) pv
--   ,sum(uv) uv
-- <if test="site_type == null or site_type=='' or site_type == 'zxx'">
-- FROM ads_zxx_stat_data_h
-- WHERE 1=1
-- </if>
-- <if test="site_type !='' and site_type != null and site_type != 'zxx'">
-- FROM ads_platform_stat_data_h
-- WHERE site_type = #{site_type}
-- </if>
--    AND app_type IN ('app','app_hd','web-all','pc')
--    AND stat_date in (#{stat_date}, date_add(#{stat_date}, interval -1 day))
-- GROUP BY app_type, stat_date, stat_hour
-- ) t
-- GROUP BY app_type,stat_hour
-- order by app_type,stat_hour
--
SELECT
    app_type
     ,case when app_type = 'app' then '手机APP'
          when app_type = 'app_hd' then '平板APP'
          when app_type = 'pc' then '电脑客户端'
          when app_type = 'web-all' then '浏览器' end app_type_name
    ,event_hour AS hour
,if(event_hour = now_hour, null, sum(if(stat_date = #{stat_date}, uv, 0))) as uv
,sum(if(stat_date != #{stat_date}, uv, 0)) as yesterday_uv
,if(event_hour = now_hour, null, sum(if(stat_date = #{stat_date}, pv, 0))) as pv
,sum(if(stat_date != #{stat_date}, pv, 0)) as yesterday_pv
from (
         SELECT CASE
                    WHEN product_platform IN ('android_hd', 'ios_hd') THEN 'app_hd'
                    WHEN product_platform IN ('ios', 'android') THEN 'app'
                    WHEN product_platform IN ('web') THEN 'web-all'
                    ELSE
                        product_platform END AS app_type
              , cast(event_hour as int)event_hour
              , HOUR(now()) as now_hour
              , stat_date
              , COUNT(DISTINCT user_id)      AS uv
              , SUM(visit_times)             AS pv
         FROM dwm__pv__event_detail__ih__incr
         WHERE stat_date IN (#{stat_date},DATE_SUB(#{stat_date}, INTERVAL  1 DAY))
           AND product_code =#{site_type}
AND product_platform IN ('android_hd','ios_hd','ios','android','web','pc')
         GROUP BY CASE
                    WHEN product_platform IN ('android_hd', 'ios_hd') THEN 'app_hd'
                    WHEN product_platform IN ('ios', 'android') THEN 'app'
             WHEN product_platform IN ('web') THEN 'web-all'
                    ELSE
                        product_platform end , event_hour, stat_date
     ) a
GROUP BY app_type,event_hour,now_hour
