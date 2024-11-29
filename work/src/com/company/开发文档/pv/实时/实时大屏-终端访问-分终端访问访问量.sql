-- SELECT
--   app_type
--   ,case when app_type = 'app' then '手机APP'
--        when app_type = 'app_hd' then '平板APP'
--        when app_type = 'pc' then '电脑客户端'
--        when app_type = 'web-all' then '浏览器' end app_type_name
-- <if test="period_type_code == null or period_type_code=='' or period_type_code != '99'">
--   ,sum(pv) pv
--   ,sum(uv) uv
-- </if>
-- <if test="period_type_code == '99'">
--   ,sum(cum_pv+pv) as pv
--   ,sum(cum_uv+new_uv) as uv
-- </if>
-- <if test="site_type == null or site_type=='' or site_type == 'zxx'">
-- FROM ads_zxx_stat_data_i
-- WHERE 1=1
-- </if>
-- <if test="site_type !='' and site_type != null and site_type != 'zxx'">
-- FROM ads_platform_stat_data_i
-- WHERE site_type = #{site_type}
-- </if>
--    AND app_type IN ('app','app_hd','web-all','pc')
--    AND stat_date = #{stat_date}
-- GROUP BY app_type
SELECT app_type
     , CASE
           WHEN app_type = 'app' THEN '手机APP'
           WHEN app_type = 'app_hd' THEN '平板APP'
           WHEN app_type = 'pc' THEN '电脑客户端'
           WHEN app_type = 'web' THEN '浏览器' END app_type_name
     , SUM(pv) AS                               pv
     , SUM(uv) AS                               uv
FROM (
         SELECT app_type
              , pv
              , uv
         FROM ads__platform_area_stat__d
         WHERE period_type_code =#{period_type_code}
AND end_date=date_sub(#{stat_date}, interval  1 day)
AND site_type=#{site_type}
AND identity='all'
AND country='全球'
AND province_id='all'
AND language='all'
AND app_type IN ('app_hd','app','pc','web')
         UNION ALL
         SELECT CASE WHEN product_platform IN ('android_hd', 'ios_hd') THEN 'app_hd'
             WHEN product_platform IN ('ios', 'android') THEN 'app'
             ELSE
             product_platform END AS app_type,
             count(DISTINCT user_id) AS uv, sum(visit_times) AS pv
         FROM dwm__pv__event_detail__dd__incr
         WHERE stat_date=#{stat_date}
AND  product_code=#{site_type}
AND product_platform IN ('android_hd','ios_hd','ios','android','web','pc')
         GROUP BY CASE WHEN product_platform IN ('android_hd', 'ios_hd') THEN 'app_hd'
                      WHEN product_platform IN ('ios', 'android') THEN 'app'
                      ELSE
                      product_platform end
     ) a
GROUP BY app_type


